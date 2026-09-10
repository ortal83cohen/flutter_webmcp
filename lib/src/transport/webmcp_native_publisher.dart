import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import '../webmcp.dart';
import '../webmcp_tool.dart';
import 'native_publisher_boundary.dart';
import 'webmcp_native_capabilities.dart';

/// Maximum nested collection depth accepted at the browser wire boundary.
const int webMcpNativeMaxJsonDepth = 32;

/// Maximum UTF-8 encoded input or output size at the browser wire boundary.
const int webMcpNativeMaxJsonBytes = 64 * 1024;

/// Maximum browser registrations owned by one publisher.
const int webMcpNativeMaxRegistrations = 128;

/// Maximum retained operation records.
const int webMcpNativeMaxOperations = 32;

/// Maximum asynchronous executions that have not actually settled.
const int webMcpNativeMaxOutstandingExecutions = 32;

/// Maximum lifetime of an identifiable operation record.
const Duration webMcpNativeOperationRetention = Duration(seconds: 30);

/// Supplies time to package-internal retention conformance tests.
DateTime Function() webMcpNativeClock = DateTime.now;

/// An immutable native-publisher status snapshot.
final class WebMcpNativePublisherStatus {
  WebMcpNativePublisherStatus._({
    required this.support,
    required this.capabilities,
    required this.publishedToolCount,
    required this.skippedToolCount,
    required this.retainedOperationCount,
    required this.outstandingExecutionCount,
    required Set<String> reasonCodes,
  }) : reasonCodes = UnmodifiableSetView<String>(Set<String>.of(reasonCodes));

  /// The strongest state established by this publisher.
  final WebMcpNativeSupport support;

  /// The evidence-backed Chrome capability matrix.
  final WebMcpNativeCapabilities capabilities;

  /// Number of browser registrations this publisher currently owns.
  final int publishedToolCount;

  /// Number of current local tools this publisher could not publish.
  final int skippedToolCount;

  /// Number of identifiable operation records still retained.
  final int retainedOperationCount;

  /// Number of asynchronous executions that have not actually settled.
  final int outstandingExecutionCount;

  /// Safe classifications for current publication failures.
  final Set<String> reasonCodes;

  /// Returns allowlisted diagnostics without descriptors or invocation data.
  Map<String, Object> toDiagnosticMap() => <String, Object>{
    'support': support.name,
    ...capabilities.toDiagnosticMap(),
    'publishedToolCount': publishedToolCount,
    'skippedToolCount': skippedToolCount,
    'retainedOperationCount': retainedOperationCount,
    'outstandingExecutionCount': outstandingExecutionCount,
    'reasonCodes': reasonCodes.toList(growable: false),
  };
}

enum _WebMcpNativeOperationKind { executing, completed, failed }

final class _WebMcpNativeOperationRecord {
  _WebMcpNativeOperationRecord({
    required this.identity,
    required this.startedAt,
  });

  final int identity;
  final DateTime startedAt;
  var revision = 0;
  var kind = _WebMcpNativeOperationKind.executing;
  WebMcpNativeReasonCode? reason;
}

final class _WebMcpNativeOperationTracker {
  _WebMcpNativeOperationTracker({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final Map<int, _WebMcpNativeOperationRecord> _records =
      <int, _WebMcpNativeOperationRecord>{};
  var _nextIdentity = 1;
  var _outstandingExecutions = 0;

  int get retainedCount {
    _expire();
    return _records.length;
  }

  int get outstandingExecutionCount => _outstandingExecutions;

  _WebMcpNativeOperationRecord? admit() {
    _expire();
    if (_records.length >= webMcpNativeMaxOperations ||
        _outstandingExecutions >= webMcpNativeMaxOutstandingExecutions) {
      return null;
    }
    final _WebMcpNativeOperationRecord record = _WebMcpNativeOperationRecord(
      identity: _nextIdentity++,
      startedAt: _clock(),
    );
    _records[record.identity] = record;
    _outstandingExecutions++;
    return record;
  }

  void settle(
    _WebMcpNativeOperationRecord record, {
    WebMcpNativeReasonCode? reason,
  }) {
    _outstandingExecutions--;
    final _WebMcpNativeOperationRecord? retained = _records[record.identity];
    if (retained == null) {
      return;
    }
    retained.revision++;
    retained
      ..kind = reason == null
          ? _WebMcpNativeOperationKind.completed
          : _WebMcpNativeOperationKind.failed
      ..reason = reason;
  }

  void clearIdentifiableRecords() {
    _records.clear();
  }

  void _expire() {
    final DateTime now = _clock();
    _records.removeWhere(
      (int identity, _WebMcpNativeOperationRecord record) =>
          now.difference(record.startedAt) >= webMcpNativeOperationRetention,
    );
  }
}

/// Additively mirrors a local registry into Chrome's native WebMCP surface.
final class WebMcpNativePublisher {
  /// Creates a publisher for [registry] or the process-wide registry.
  WebMcpNativePublisher({WebMcp? registry})
    : _registry = registry ?? WebMcp.instance,
      _boundary = webMcpNativeBoundaryFactory(),
      _operations = _WebMcpNativeOperationTracker(clock: webMcpNativeClock);

  final WebMcp _registry;
  final WebMcpNativeBoundary _boundary;
  final _WebMcpNativeOperationTracker _operations;
  final Map<String, WebMcpNativeRegistration> _ownedRegistrations =
      <String, WebMcpNativeRegistration>{};
  final Map<String, WebMcpNativeReasonCode> _skippedTools =
      <String, WebMcpNativeReasonCode>{};
  final Set<WebMcpNativeReasonCode> _reasonCodes = <WebMcpNativeReasonCode>{};
  WebMcpRegistrySubscription? _subscription;
  Future<void> _mutationQueue = Future<void>.value();
  Future<WebMcpNativePublisherStatus>? _attaching;
  var _attached = false;
  var _conformanceObserved = false;

  /// Attaches once, mirrors the snapshot, then follows later mutations.
  Future<WebMcpNativePublisherStatus> attach() {
    if (_attached) {
      return Future<WebMcpNativePublisherStatus>.value(status);
    }
    final Future<WebMcpNativePublisherStatus>? attaching = _attaching;
    if (attaching != null) {
      return attaching;
    }
    final Future<WebMcpNativePublisherStatus> future = _attach().whenComplete(
      () => _attaching = null,
    );
    _attaching = future;
    return future;
  }

  Future<WebMcpNativePublisherStatus> _attach() async {
    _attached = true;
    if (!_boundary.isDetected) {
      _reasonCodes.add(WebMcpNativeReasonCode.browserUnavailable);
      return status;
    }

    final _WebMcpNativeRegistryObserver observer =
        _WebMcpNativeRegistryObserver(this);
    _subscription = _registry.addRegistryObserver(observer);
    for (final WebMcpTool tool in _registry.tools) {
      _enqueuePublish(tool);
    }
    await _mutationQueue;
    return status;
  }

  /// Releases every browser registration owned by this publisher.
  Future<void> detach() async {
    _attached = false;
    _subscription?.cancel();
    _subscription = null;
    await _mutationQueue;
    for (final WebMcpNativeRegistration registration
        in _ownedRegistrations.values) {
      registration.abort();
    }
    _ownedRegistrations.clear();
    _skippedTools.clear();
    _reasonCodes.clear();
    _conformanceObserved = false;
    _operations.clearIdentifiableRecords();
  }

  /// Returns current safe publisher diagnostics.
  WebMcpNativePublisherStatus get status {
    final int retainedOperationCount = _operations.retainedCount;
    final WebMcpNativeSupport support;
    if (!_boundary.isDetected) {
      support = WebMcpNativeSupport.localOnly;
    } else if (_reasonCodes.any(
      (WebMcpNativeReasonCode reason) =>
          reason == WebMcpNativeReasonCode.registrationFailed ||
          reason == WebMcpNativeReasonCode.duplicateNativeTool ||
          reason == WebMcpNativeReasonCode.resourceLimit,
    )) {
      support = WebMcpNativeSupport.failed;
    } else if (_conformanceObserved) {
      support = WebMcpNativeSupport.conformanceUsable;
    } else {
      support = WebMcpNativeSupport.browserDetected;
    }
    return WebMcpNativePublisherStatus._(
      support: support,
      capabilities: WebMcpNativeCapabilities.chrome152,
      publishedToolCount: _ownedRegistrations.length,
      skippedToolCount: _skippedTools.length,
      retainedOperationCount: retainedOperationCount,
      outstandingExecutionCount: _operations.outstandingExecutionCount,
      reasonCodes: _reasonCodes
          .map((WebMcpNativeReasonCode reason) => reason.name)
          .toSet(),
    );
  }

  void _enqueuePublish(WebMcpTool tool) {
    _mutationQueue = _mutationQueue.then((_) => _publish(tool));
  }

  Future<void> _publish(WebMcpTool tool) async {
    if (!_attached ||
        _ownedRegistrations.containsKey(tool.name) ||
        _skippedTools.containsKey(tool.name)) {
      return;
    }
    if (_ownedRegistrations.length >= webMcpNativeMaxRegistrations) {
      _skip(tool.name, WebMcpNativeReasonCode.resourceLimit);
      return;
    }
    try {
      final WebMcpNativeRegistration registration = await _boundary
          .registerTool(
            tool,
            (Object? input, WebMcpNativeInvocationContext context) =>
                _invoke(tool, input, context),
          );
      if (!_attached ||
          !_registry.tools.any(
            (WebMcpTool current) =>
                current.name == tool.name && identical(current, tool),
          )) {
        registration.abort();
        return;
      }
      _ownedRegistrations[tool.name] = registration;
      _conformanceObserved = true;
    } on WebMcpNativeBoundaryException catch (failure) {
      _skip(tool.name, failure.reason);
    } on Object {
      _skip(tool.name, WebMcpNativeReasonCode.registrationFailed);
    }
  }

  void _enqueueUnpublish(String name) {
    _mutationQueue = _mutationQueue.then((_) {
      _ownedRegistrations.remove(name)?.abort();
      final WebMcpNativeReasonCode? skipped = _skippedTools.remove(name);
      if (skipped != null && !_skippedTools.containsValue(skipped)) {
        _reasonCodes.remove(skipped);
      }
    });
  }

  void _skip(String name, WebMcpNativeReasonCode reason) {
    _skippedTools[name] = reason;
    _reasonCodes.add(reason);
  }

  Future<String> _invoke(
    WebMcpTool tool,
    Object? input,
    WebMcpNativeInvocationContext context,
  ) async {
    if (context.cancelledBeforeDispatch) {
      return _safeFailure(WebMcpNativeReasonCode.cancelled);
    }
    final Object? normalizedInput;
    try {
      normalizedInput = _normalizeJson(input);
      if (normalizedInput is! Map<String, Object?>) {
        return _safeFailure(WebMcpNativeReasonCode.invalidInput);
      }
      _enforceEncodedSize(normalizedInput);
    } on Object {
      return _safeFailure(WebMcpNativeReasonCode.invalidInput);
    }

    final _WebMcpNativeOperationRecord? operation = _operations.admit();
    if (operation == null) {
      return _safeFailure(WebMcpNativeReasonCode.busy);
    }

    final Object? result;
    try {
      result = await tool.handler(normalizedInput);
    } on Object {
      _operations.settle(
        operation,
        reason: WebMcpNativeReasonCode.handlerFailed,
      );
      return _safeFailure(WebMcpNativeReasonCode.handlerFailed);
    }
    try {
      final Object? normalizedResult = _normalizeJson(result);
      _enforceEncodedSize(normalizedResult);
      final String encoded = jsonEncode(normalizedResult);
      _operations.settle(operation);
      return encoded;
    } on Object {
      _operations.settle(
        operation,
        reason: WebMcpNativeReasonCode.invalidOutput,
      );
      return _safeFailure(WebMcpNativeReasonCode.invalidOutput);
    }
  }

  String _safeFailure(WebMcpNativeReasonCode reason) =>
      jsonEncode(<String, Object>{
        'ok': false,
        'error': <String, Object>{
          'code': reason.name,
          'retryable': reason == WebMcpNativeReasonCode.busy,
        },
      });

  Object? _normalizeJson(
    Object? value, {
    int depth = 0,
    Set<Object>? ancestors,
  }) {
    if (depth > webMcpNativeMaxJsonDepth) {
      throw const _WebMcpNativeWireException();
    }
    if (value == null || value is String || value is bool || value is int) {
      return value;
    }
    if (value is double) {
      if (!value.isFinite) {
        throw const _WebMcpNativeWireException();
      }
      return value;
    }
    if (value is List<Object?>) {
      final Set<Object> path = ancestors ?? HashSet<Object>.identity();
      if (!path.add(value)) {
        throw const _WebMcpNativeWireException();
      }
      try {
        return value
            .map(
              (Object? item) =>
                  _normalizeJson(item, depth: depth + 1, ancestors: path),
            )
            .toList(growable: false);
      } finally {
        path.remove(value);
      }
    }
    if (value is Map<Object?, Object?>) {
      final Set<Object> path = ancestors ?? HashSet<Object>.identity();
      if (!path.add(value)) {
        throw const _WebMcpNativeWireException();
      }
      try {
        final Map<String, Object?> normalized = <String, Object?>{};
        for (final MapEntry<Object?, Object?> entry in value.entries) {
          final Object? key = entry.key;
          if (key is! String) {
            throw const _WebMcpNativeWireException();
          }
          normalized[key] = _normalizeJson(
            entry.value,
            depth: depth + 1,
            ancestors: path,
          );
        }
        return normalized;
      } finally {
        path.remove(value);
      }
    }
    throw const _WebMcpNativeWireException();
  }

  void _enforceEncodedSize(Object? value) {
    final int bytes = utf8.encode(jsonEncode(value)).length;
    if (bytes > webMcpNativeMaxJsonBytes) {
      throw const _WebMcpNativeWireException();
    }
  }
}

final class _WebMcpNativeRegistryObserver
    implements WebMcpRegistryObserver, WebMcpRegistryResetObserver {
  _WebMcpNativeRegistryObserver(this._publisher);

  final WebMcpNativePublisher _publisher;

  @override
  void onToolRegistered(WebMcpTool tool) {
    _publisher._enqueuePublish(tool);
  }

  @override
  void onToolUnregistered(String name) {
    _publisher._enqueueUnpublish(name);
  }

  @override
  void onRegistryReset() {
    unawaited(_publisher.detach());
  }
}

final class _WebMcpNativeWireException implements Exception {
  const _WebMcpNativeWireException();
}
