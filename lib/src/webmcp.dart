import 'dart:collection';

import 'transport/transport_selector.dart';
import 'transport/webmcp_transport.dart';
import 'webmcp_exceptions.dart';
import 'webmcp_tool.dart';
import 'webmcp_tool_source.dart';

/// Observes successful mutations of a [WebMcp] registry.
abstract interface class WebMcpRegistryObserver {
  /// Receives a tool after it has been registered locally.
  void onToolRegistered(WebMcpTool tool);

  /// Receives a tool name after it has been unregistered locally.
  void onToolUnregistered(String name);
}

/// An active registry-observer registration.
final class WebMcpRegistrySubscription {
  WebMcpRegistrySubscription._(this._cancel);

  void Function()? _cancel;

  /// Whether this subscription will receive later registry mutations.
  bool get isActive => _cancel != null;

  /// Stops later notifications.
  ///
  /// Calling this method more than once has no effect.
  void cancel() {
    final void Function()? cancel = _cancel;
    if (cancel == null) {
      return;
    }
    _cancel = null;
    cancel();
  }
}

/// Receives subscription cancellation performed by registry reset.
///
/// This lifecycle hook lets integrations release resources when [WebMcp.reset]
/// is used as a safety net. Ordinary observers do not need to implement it.
abstract interface class WebMcpRegistryResetObserver {
  /// Releases resources owned through the cancelled subscription.
  void onRegistryReset();
}

/// Kinds of payload-free tool log records.
enum WebMcpLogKind {
  /// A tool was registered locally.
  registered,

  /// A tool was unregistered locally.
  unregistered,

  /// A tool invocation finished.
  invoked,

  /// A tool invocation failed.
  invocationFailed,

  /// The browser reported tool activity.
  nativeActivity,
}

/// A log record that carries a kind, a tool name, and an optional reason code.
final class WebMcpLogRecord {
  /// Creates a record with no argument, result, or schema payload.
  const WebMcpLogRecord({
    required this.kind,
    required this.toolName,
    this.reasonCode,
  });

  /// The event kind.
  final WebMcpLogKind kind;

  /// The tool name associated with the event.
  final String toolName;

  /// An optional allowlisted reason code.
  final String? reasonCode;

  @override
  String toString() {
    final String? reasonCode = this.reasonCode;
    if (reasonCode == null) {
      return 'WebMcpLogRecord(${kind.name}, $toolName)';
    }
    return 'WebMcpLogRecord(${kind.name}, $toolName, $reasonCode)';
  }
}

/// Writes [kind] for [toolName] when a log hook is installed.
///
/// Failures from the hook are ignored.
void webMcpRecordLog(
  WebMcpLogKind kind,
  String toolName, {
  String? reasonCode,
}) {
  final void Function(WebMcpLogRecord record)? hook = WebMcp.logHook;
  if (hook == null) {
    return;
  }
  try {
    hook(
      WebMcpLogRecord(kind: kind, toolName: toolName, reasonCode: reasonCode),
    );
  } on Object {
    // A failing hook cannot change registration, invocation, or publication.
  }
}

/// The process-wide registry of tools exposed by this package.
final class WebMcp {
  WebMcp._() : _transport = createDefaultTransport();

  static final WebMcp _instance = WebMcp._();

  /// Receives payload-free tool events. Null until an application installs it.
  static void Function(WebMcpLogRecord record)? logHook;

  /// Returns the process-wide registry.
  static WebMcp get instance => _instance;

  static final RegExp _validName = RegExp(r'^[A-Za-z0-9_.-]{1,128}$');

  final Map<String, WebMcpTool> _tools = <String, WebMcpTool>{};
  final Map<int, WebMcpRegistryObserver> _observers =
      <int, WebMcpRegistryObserver>{};
  final Map<int, WebMcpRegistrySubscription> _observerSubscriptions =
      <int, WebMcpRegistrySubscription>{};
  var _nextObserverId = 0;
  WebMcpTransport _transport;

  /// Adds an observer without replacing the active transport.
  ///
  /// Observers are called in subscription order after transport notification.
  /// Observer failures are isolated from the registry mutation and from other
  /// observers.
  WebMcpRegistrySubscription addRegistryObserver(
    WebMcpRegistryObserver observer,
  ) {
    final int observerId = _nextObserverId++;
    _observers[observerId] = observer;
    final WebMcpRegistrySubscription subscription =
        WebMcpRegistrySubscription._(() {
          _observers.remove(observerId);
          _observerSubscriptions.remove(observerId);
        });
    _observerSubscriptions[observerId] = subscription;
    return subscription;
  }

  /// Registers [tool], rejecting invalid or duplicate names.
  void registerTool(WebMcpTool tool) {
    if (!_validName.hasMatch(tool.name)) {
      throw WebMcpInvalidToolNameException(tool.name);
    }
    if (_tools.containsKey(tool.name)) {
      throw WebMcpDuplicateToolException(tool.name);
    }
    _tools[tool.name] = tool;
    webMcpRecordLog(WebMcpLogKind.registered, tool.name);
    try {
      _transport.onToolRegistered(tool);
    } finally {
      _notifyRegistered(tool);
    }
  }

  /// Registers every descriptor returned by [source].
  void registerSource(WebMcpToolSource source) {
    for (final WebMcpTool tool in source.getWebMcpTools()) {
      registerTool(tool);
    }
  }

  /// Removes [name], returning whether it was registered.
  bool unregisterTool(String name) {
    final WebMcpTool? removed = _tools.remove(name);
    if (removed == null) {
      return false;
    }
    webMcpRecordLog(WebMcpLogKind.unregistered, name);
    try {
      _transport.onToolUnregistered(name);
    } finally {
      _notifyUnregistered(name);
    }
    return true;
  }

  /// Returns an immutable, ascending-by-name snapshot of registered tools.
  List<WebMcpTool> get tools {
    final List<WebMcpTool> sorted = _tools.values.toList()
      ..sort(
        (WebMcpTool left, WebMcpTool right) => left.name.compareTo(right.name),
      );
    return UnmodifiableListView<WebMcpTool>(sorted);
  }

  /// Invokes the registered tool named [name] with [arguments].
  Future<Object?> invokeTool(
    String name,
    Map<String, Object?> arguments,
  ) async {
    final WebMcpTool? tool = _tools[name];
    if (tool == null) {
      throw WebMcpToolNotFoundException(name);
    }
    try {
      final Object? result = await _dispatch(tool, arguments, null);
      webMcpRecordLog(WebMcpLogKind.invoked, name);
      return result;
    } on Object {
      webMcpRecordLog(WebMcpLogKind.invocationFailed, name);
      rethrow;
    }
  }

  Future<Object?> _dispatch(
    WebMcpTool tool,
    Map<String, Object?> arguments,
    WebMcpExecutionSignal? executionSignal,
  ) {
    final WebMcpToolCallHandler? callHandler = tool.callHandler;
    if (callHandler != null) {
      return Future<Object?>.value(
        callHandler(
          WebMcpToolCall(
            arguments: arguments,
            executionSignal: executionSignal,
          ),
        ),
      );
    }
    return Future<Object?>.value(tool.handler!(arguments));
  }

  /// Clears all tools and installs [transport] or the platform default.
  ///
  /// A native publisher should be detached before reset. Reset also cancels
  /// every observer subscription and asks reset-aware integrations to detach
  /// as a safety net.
  void reset([WebMcpTransport? transport]) {
    final List<WebMcpRegistryObserver> observers = _observers.values.toList(
      growable: false,
    );
    final List<WebMcpRegistrySubscription> subscriptions =
        _observerSubscriptions.values.toList(growable: false);
    _observers.clear();
    _observerSubscriptions.clear();
    for (final WebMcpRegistrySubscription subscription in subscriptions) {
      subscription.cancel();
    }
    for (final WebMcpRegistryObserver observer in observers) {
      if (observer case WebMcpRegistryResetObserver resetObserver) {
        try {
          resetObserver.onRegistryReset();
        } on Object {
          // Reset remains authoritative even when integration cleanup fails.
        }
      }
    }
    _tools.clear();
    _transport = transport ?? createDefaultTransport();
  }

  /// Identifies the active transport.
  String get transportId => _transport.id;

  void _notifyRegistered(WebMcpTool tool) {
    for (final WebMcpRegistryObserver observer in _observers.values.toList(
      growable: false,
    )) {
      try {
        observer.onToolRegistered(tool);
      } on Object {
        // Observers cannot roll back or escape a successful local mutation.
      }
    }
  }

  void _notifyUnregistered(String name) {
    for (final WebMcpRegistryObserver observer in _observers.values.toList(
      growable: false,
    )) {
      try {
        observer.onToolUnregistered(name);
      } on Object {
        // One failing observer must not prevent later observer notifications.
      }
    }
  }
}
