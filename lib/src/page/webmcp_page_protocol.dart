import 'dart:collection';

/// The page and observation protocol version.
const int webMcpPageProtocolVersion = 1;

/// The largest exactly representable JSON integer.
const int webMcpMaxSafeInteger = 9007199254740991;

/// Fixed safe error codes returned by page tools.
enum WebMcpPageErrorCode {
  /// The request shape or a value is invalid.
  invalidArguments,

  /// The requested page mount no longer exists.
  scopeGone,

  /// The requested page is not currently eligible.
  inactiveScope,

  /// The page semantics boundary cannot be resolved.
  boundaryUnavailable,

  /// No usable immutable semantics snapshot is available.
  snapshotUnavailable,

  /// The supplied revision is no longer current.
  staleSnapshot,

  /// The supplied cursor is malformed, foreign, or expired.
  invalidCursor,

  /// The handle is not present in the current page snapshot.
  unknownHandle,

  /// The requested action is outside the protocol allowlist.
  unsupportedAction,

  /// The current node no longer advertises the requested action.
  actionUnavailable,

  /// Page policy denies the requested operation.
  policyDenied,

  /// The request identifier was already used or is out of order.
  duplicateRequest,

  /// A bounded operation pool is saturated.
  busy,

  /// The request was cancelled before dispatch.
  cancelled,

  /// A fixed resource ceiling was reached.
  resourceLimit,

  /// Positive observation waits are unavailable.
  unsupportedWait,

  /// Automatic pages require exactly one bound Flutter view.
  unsupportedViewConfiguration,

  /// An unexpected failure was safely contained.
  internalError,
}

/// Creates a versioned safe error response.
Map<String, Object?> webMcpPageError(
  WebMcpPageErrorCode code, {
  bool retryable = false,
  bool refreshRequired = false,
}) {
  return <String, Object?>{
    'protocolVersion': webMcpPageProtocolVersion,
    'ok': false,
    'code': code.name,
    'message': _safeMessage(code),
    'retryable': retryable,
    'refreshRequired': refreshRequired,
  };
}

/// Creates a versioned success response containing [fields].
Map<String, Object?> webMcpPageSuccess(Map<String, Object?> fields) {
  return <String, Object?>{
    'protocolVersion': webMcpPageProtocolVersion,
    'ok': true,
    ...fields,
  };
}

String _safeMessage(WebMcpPageErrorCode code) {
  return switch (code) {
    WebMcpPageErrorCode.invalidArguments => 'The request is invalid.',
    WebMcpPageErrorCode.scopeGone => 'The page scope is no longer available.',
    WebMcpPageErrorCode.inactiveScope =>
      'The page scope is not currently active.',
    WebMcpPageErrorCode.boundaryUnavailable =>
      'The page boundary is unavailable.',
    WebMcpPageErrorCode.snapshotUnavailable =>
      'A page snapshot is not currently available.',
    WebMcpPageErrorCode.staleSnapshot =>
      'The page snapshot is no longer current.',
    WebMcpPageErrorCode.invalidCursor => 'The supplied cursor cannot be used.',
    WebMcpPageErrorCode.unknownHandle =>
      'The node handle is not available in this snapshot.',
    WebMcpPageErrorCode.unsupportedAction =>
      'The requested action is not supported.',
    WebMcpPageErrorCode.actionUnavailable =>
      'The requested action is not currently available.',
    WebMcpPageErrorCode.policyDenied =>
      'Page policy denied the requested operation.',
    WebMcpPageErrorCode.duplicateRequest =>
      'The request identifier was already used or is out of order.',
    WebMcpPageErrorCode.busy => 'The bounded operation pool is busy.',
    WebMcpPageErrorCode.cancelled =>
      'The request was cancelled before dispatch.',
    WebMcpPageErrorCode.resourceLimit => 'A fixed resource limit was reached.',
    WebMcpPageErrorCode.unsupportedWait =>
      'Positive observation waits are not supported.',
    WebMcpPageErrorCode.unsupportedViewConfiguration =>
      'Automatic pages require exactly one supported Flutter view.',
    WebMcpPageErrorCode.internalError =>
      'The operation failed without exposing internal details.',
  };
}

/// Downward-only resource configuration for one application session.
final class WebMcpPageLimits {
  /// Creates limits that cannot exceed the frozen protocol ceilings.
  WebMcpPageLimits({
    this.liveScopes = 128,
    this.navigatorAdapters = 32,
    this.ringEvents = 256,
    this.ringBytes = 65536,
    this.observeEvents = 32,
    this.observeBytes = 16384,
    this.pendingWaits = 8,
    this.pendingWaitsPerScope = 2,
    this.maxWaitMs = 1000,
    this.trackedOperations = 32,
    this.operationRetention = const Duration(seconds: 30),
    this.outstandingExecutions = 32,
    this.captureDeadline = const Duration(seconds: 2),
    this.returnedNodes = 200,
    this.visitedNodes = 1000,
    this.maxDepth = 32,
    this.readBytes = 65536,
  }) {
    _requireRange(liveScopes, 1, 128, 'liveScopes');
    _requireRange(navigatorAdapters, 1, 32, 'navigatorAdapters');
    _requireRange(ringEvents, 1, 256, 'ringEvents');
    _requireRange(ringBytes, 256, 65536, 'ringBytes');
    _requireRange(observeEvents, 1, 32, 'observeEvents');
    _requireRange(observeBytes, 256, 16384, 'observeBytes');
    _requireRange(pendingWaits, 1, 8, 'pendingWaits');
    _requireRange(pendingWaitsPerScope, 1, 2, 'pendingWaitsPerScope');
    _requireRange(maxWaitMs, 0, 1000, 'maxWaitMs');
    _requireRange(trackedOperations, 1, 32, 'trackedOperations');
    _requireRange(outstandingExecutions, 1, 32, 'outstandingExecutions');
    _requireRange(returnedNodes, 1, 200, 'returnedNodes');
    _requireRange(visitedNodes, 1, 1000, 'visitedNodes');
    _requireRange(maxDepth, 1, 32, 'maxDepth');
    _requireRange(readBytes, 1024, 65536, 'readBytes');
    if (operationRetention <= Duration.zero ||
        operationRetention > const Duration(seconds: 30)) {
      throw ArgumentError.value(
        operationRetention,
        'operationRetention',
        'Must be positive and at most 30 seconds.',
      );
    }
    if (captureDeadline <= Duration.zero ||
        captureDeadline > const Duration(seconds: 2)) {
      throw ArgumentError.value(
        captureDeadline,
        'captureDeadline',
        'Must be positive and at most 2 seconds.',
      );
    }
  }

  /// Maximum concurrently mounted automatic page scopes.
  final int liveScopes;

  /// Maximum registered Navigator adapters.
  final int navigatorAdapters;

  /// Maximum retained observation events.
  final int ringEvents;

  /// Maximum encoded bytes retained in the event ring.
  final int ringBytes;

  /// Maximum whole events returned by one observe call.
  final int observeEvents;

  /// Maximum encoded bytes returned by one observe call.
  final int observeBytes;

  /// Maximum pending waits for the app.
  final int pendingWaits;

  /// Maximum pending waits for one filtered scope.
  final int pendingWaitsPerScope;

  /// Maximum accepted wait duration.
  final int maxWaitMs;

  /// Maximum retained operation receipts.
  final int trackedOperations;

  /// Maximum receipt retention.
  final Duration operationRetention;

  /// Maximum unsettled asynchronous source executions.
  final int outstandingExecutions;

  /// Maximum time to obtain a usable capture.
  final Duration captureDeadline;

  /// Maximum nodes returned from one captured window.
  final int returnedNodes;

  /// Maximum semantic nodes visited while capturing.
  final int visitedNodes;

  /// Maximum semantic traversal depth.
  final int maxDepth;

  /// Maximum UTF-8 bytes in one read response.
  final int readBytes;

  static void _requireRange(int value, int minimum, int maximum, String name) {
    if (value < minimum || value > maximum) {
      throw ArgumentError.value(
        value,
        name,
        'Must be between $minimum and $maximum.',
      );
    }
  }
}

/// Privacy and action policy for one automatic page boundary.
final class WebMcpPagePolicy {
  /// Creates a fail-closed page policy.
  WebMcpPagePolicy({
    this.allowLongPress = false,
    this.includeBounds = false,
    this.includeNonEditableValues = true,
    this.maxTextLength = 1024,
    Set<String> excludedSemanticsIdentifiers = const <String>{},
    Set<String> sensitiveSemanticsIdentifiers = const <String>{},
    Set<String> editableValueIdentifiers = const <String>{},
    Set<String> setTextIdentifiers = const <String>{},
  }) : excludedSemanticsIdentifiers = UnmodifiableSetView<String>(
         Set<String>.of(excludedSemanticsIdentifiers),
       ),
       sensitiveSemanticsIdentifiers = UnmodifiableSetView<String>(
         Set<String>.of(sensitiveSemanticsIdentifiers),
       ),
       editableValueIdentifiers = UnmodifiableSetView<String>(
         Set<String>.of(editableValueIdentifiers),
       ),
       setTextIdentifiers = UnmodifiableSetView<String>(
         Set<String>.of(setTextIdentifiers),
       ) {
    if (maxTextLength < 1 || maxTextLength > 4096) {
      throw ArgumentError.value(
        maxTextLength,
        'maxTextLength',
        'Must be between 1 and 4096.',
      );
    }
  }

  /// Default restrictive policy.
  static final WebMcpPagePolicy defaults = WebMcpPagePolicy();

  /// Whether advertised long-press actions may be exposed.
  final bool allowLongPress;

  /// Whether nodes may include view-relative bounds.
  final bool includeBounds;

  /// Whether ordinary non-editable semantic values may be exposed.
  final bool includeNonEditableValues;

  /// Maximum accepted setText value length.
  final int maxTextLength;

  /// Semantic identifiers whose complete subtrees are excluded.
  final Set<String> excludedSemanticsIdentifiers;

  /// Semantic identifiers whose complete subtrees are sensitive and omitted.
  final Set<String> sensitiveSemanticsIdentifiers;

  /// Editable fields whose values may be exposed when not obscured.
  final Set<String> editableValueIdentifiers;

  /// Editable fields that explicitly permit setText.
  final Set<String> setTextIdentifiers;
}
