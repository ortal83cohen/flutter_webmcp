/// Browser capabilities used by the native WebMCP publisher.
final class WebMcpNativeCapabilities {
  /// Creates an immutable capability report.
  const WebMcpNativeCapabilities({
    required this.registrationSignalCleanup,
    required this.cancelBeforeDispatch,
    required this.invocationCancellationAfterCallbackStart,
    required this.positiveWait,
  });

  /// The capabilities observed in the Chrome 152 JavaScript and Wasm matrix.
  static const WebMcpNativeCapabilities chrome152 = WebMcpNativeCapabilities(
    registrationSignalCleanup: true,
    cancelBeforeDispatch: true,
    // See wiki/work/0008-automatic-page-agent/05-transport-spike.md.
    invocationCancellationAfterCallbackStart: false,
    // See wiki/work/0008-automatic-page-agent/05-transport-spike.md.
    positiveWait: false,
  );

  /// Whether aborting the registration signal removes the browser tool.
  final bool registrationSignalCleanup;

  /// Whether an already-aborted browser call is stopped before dispatch.
  final bool cancelBeforeDispatch;

  /// Whether Chrome supplies cancellation after the callback has started.
  final bool invocationCancellationAfterCallbackStart;

  /// Whether the native surface supports a positive observation wait.
  final bool positiveWait;

  /// Returns an allowlisted scalar-only diagnostic representation.
  Map<String, Object> toDiagnosticMap() => <String, Object>{
    'registrationSignalCleanup': registrationSignalCleanup,
    'cancelBeforeDispatch': cancelBeforeDispatch,
    'invocationCancellationAfterCallbackStart':
        invocationCancellationAfterCallbackStart,
    'positiveWait': positiveWait,
  };

  @override
  bool operator ==(Object other) =>
      other is WebMcpNativeCapabilities &&
      other.registrationSignalCleanup == registrationSignalCleanup &&
      other.cancelBeforeDispatch == cancelBeforeDispatch &&
      other.invocationCancellationAfterCallbackStart ==
          invocationCancellationAfterCallbackStart &&
      other.positiveWait == positiveWait;

  @override
  int get hashCode => Object.hash(
    registrationSignalCleanup,
    cancelBeforeDispatch,
    invocationCancellationAfterCallbackStart,
    positiveWait,
  );
}

/// The strongest browser-publication state established by current evidence.
///
/// There is deliberately no "native agent supported" value. AC-030 requires
/// an authenticated official-Chrome natural-language trace before that claim.
enum WebMcpNativeSupport {
  /// Tools remain available only in the local registry.
  localOnly,

  /// A browser property was detected but not proved usable.
  browserDetected,

  /// Registration and invocation conformance are usable.
  conformanceUsable,

  /// Browser publication failed.
  failed,
}
