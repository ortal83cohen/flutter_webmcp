import 'dart:collection';

import 'transport/transport_selector.dart';
import 'transport/webmcp_transport.dart';
import 'webmcp_exceptions.dart';
import 'webmcp_tool.dart';
import 'webmcp_tool_source.dart';

/// The process-wide registry of tools exposed by this package.
final class WebMcp {
  WebMcp._() : _transport = createDefaultTransport();

  static final WebMcp _instance = WebMcp._();

  /// Returns the process-wide registry.
  static WebMcp get instance => _instance;

  static final RegExp _validName = RegExp(r'^[A-Za-z0-9_.-]{1,128}$');

  final Map<String, WebMcpTool> _tools = <String, WebMcpTool>{};
  WebMcpTransport _transport;

  /// Registers [tool], rejecting invalid or duplicate names.
  void registerTool(WebMcpTool tool) {
    if (!_validName.hasMatch(tool.name)) {
      throw WebMcpInvalidToolNameException(tool.name);
    }
    if (_tools.containsKey(tool.name)) {
      throw WebMcpDuplicateToolException(tool.name);
    }
    _tools[tool.name] = tool;
    _transport.onToolRegistered(tool);
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
    _transport.onToolUnregistered(name);
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
    return tool.handler(arguments);
  }

  /// Clears all tools and installs [transport] or the platform default.
  void reset([WebMcpTransport? transport]) {
    _tools.clear();
    _transport = transport ?? createDefaultTransport();
  }

  /// Identifies the active transport.
  String get transportId => _transport.id;
}
