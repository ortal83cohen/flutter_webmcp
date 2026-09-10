import '../webmcp_tool.dart';
import 'webmcp_transport.dart';

/// Creates the transport used outside a browser.
WebMcpTransport createDefaultTransport() => const NoopTransport();

/// A transport that deliberately performs no work.
final class NoopTransport implements WebMcpTransport {
  /// Creates a no-op transport.
  const NoopTransport();

  @override
  String get id => 'noop';

  @override
  void onToolRegistered(WebMcpTool tool) {}

  @override
  void onToolUnregistered(String name) {}
}
