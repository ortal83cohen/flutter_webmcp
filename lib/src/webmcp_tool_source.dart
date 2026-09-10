import 'webmcp_tool.dart';

/// Supplies a batch of WebMCP tool descriptors.
abstract interface class WebMcpToolSource {
  /// Returns the tools currently declared by this source.
  List<WebMcpTool> getWebMcpTools();
}
