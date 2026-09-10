import '../webmcp_tool.dart';

/// Receives registry lifecycle notifications for a platform integration.
abstract interface class WebMcpTransport {
  /// Identifies this transport implementation.
  String get id;

  /// Receives notification that [tool] was registered.
  void onToolRegistered(WebMcpTool tool);

  /// Receives notification that [name] was unregistered.
  void onToolUnregistered(String name);
}
