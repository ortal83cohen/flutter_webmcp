import '../webmcp_tool.dart';
import 'native_publisher_boundary_selector.dart';

/// A safe reason reported by the browser publication boundary.
enum WebMcpNativeReasonCode {
  /// The native browser surface was not detected.
  browserUnavailable,

  /// The browser rejected or failed a registration.
  registrationFailed,

  /// Another browser registration already owns the same name.
  duplicateNativeTool,

  /// A fixed registration or execution limit was reached.
  resourceLimit,

  /// Bounded operation or execution capacity was exhausted.
  busy,

  /// Invocation input was not a bounded JSON object.
  invalidInput,

  /// Invocation output was not bounded JSON-safe data.
  invalidOutput,

  /// The application handler threw.
  handlerFailed,

  /// Invocation was cancelled before application dispatch.
  cancelled,
}

/// Browser invocation state available before handler dispatch.
final class WebMcpNativeInvocationContext {
  /// Creates invocation state.
  const WebMcpNativeInvocationContext({required this.cancelledBeforeDispatch});

  /// Whether cancellation was known before application dispatch.
  final bool cancelledBeforeDispatch;
}

/// Handles one browser-originated invocation.
typedef WebMcpNativeInvocationHandler = Future<String> Function(
  Object? input,
  WebMcpNativeInvocationContext context,
);

/// One native browser registration owned by a publisher.
abstract interface class WebMcpNativeRegistration {
  /// Releases this registration.
  void abort();
}

/// The platform-specific native publication boundary.
abstract interface class WebMcpNativeBoundary {
  /// Whether a native model-context property is present.
  bool get isDetected;

  /// Registers one same-origin tool.
  Future<WebMcpNativeRegistration> registerTool(
    WebMcpTool tool,
    WebMcpNativeInvocationHandler invoke,
  );
}

/// A safe failure emitted by a native publication boundary.
final class WebMcpNativeBoundaryException implements Exception {
  /// Creates a failure containing only an allowlisted reason.
  const WebMcpNativeBoundaryException(this.reason);

  /// The safe failure classification.
  final WebMcpNativeReasonCode reason;
}

/// Creates the boundary for the current platform.
WebMcpNativeBoundary createWebMcpNativeBoundary() =>
    createPlatformWebMcpNativeBoundary();

/// Overrides boundary creation in package-internal conformance tests.
WebMcpNativeBoundary Function() webMcpNativeBoundaryFactory =
    createWebMcpNativeBoundary;
