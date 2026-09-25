import '../webmcp_tool.dart';
import 'native_publisher_boundary.dart';

/// Creates the non-browser publication boundary.
WebMcpNativeBoundary createPlatformWebMcpNativeBoundary() =>
    const NoopWebMcpNativeBoundary();

/// A boundary that preserves local-only behavior outside browsers.
final class NoopWebMcpNativeBoundary implements WebMcpNativeBoundary {
  /// Creates a local-only boundary.
  const NoopWebMcpNativeBoundary();

  @override
  bool get isDetected => false;

  @override
  Future<WebMcpNativeRegistration> registerTool(
    WebMcpTool tool,
    WebMcpNativeInvocationHandler invoke,
  ) async {
    return _NoopWebMcpNativeRegistration();
  }

  @override
  bool subscribeToolActivity(
    void Function(WebMcpNativeToolActivity activity) listener,
  ) {
    return false;
  }

  @override
  void unsubscribeToolActivity() {}
}

final class _NoopWebMcpNativeRegistration implements WebMcpNativeRegistration {
  @override
  void abort() {}
}
