import 'dart:collection';
import 'dart:developer' as developer;

import 'webmcp.dart';
import 'webmcp_exceptions.dart';
import 'webmcp_tool.dart';
import 'webmcp_tool_source.dart';

/// Owns a lifetime-bounded group of registry entries.
final class WebMcpScope {
  /// Creates a scope identified by [scopeName] in diagnostics.
  WebMcpScope({required this.scopeName});

  /// A diagnostic name that never changes registered tool names.
  final String scopeName;

  final Set<String> _ownedNames = <String>{};
  final Set<String> _skippedNames = <String>{};
  bool _isClosed = false;

  /// Adds [tool] and returns whether this scope acquired ownership.
  bool addTool(WebMcpTool tool) {
    _ensureOpen();
    try {
      WebMcp.instance.registerTool(tool);
      _ownedNames.add(tool.name);
      return true;
    } on WebMcpDuplicateToolException {
      _skippedNames.add(tool.name);
      developer.log(
        'Skipped duplicate tool ${tool.name} in scope $scopeName.',
        name: 'webmcp_flutter',
      );
      return false;
    }
  }

  /// Adds every tool declared by [source].
  void addSource(WebMcpToolSource source) {
    _ensureOpen();
    for (final WebMcpTool tool in source.getWebMcpTools()) {
      addTool(tool);
    }
  }

  /// Removes [name] only when this scope owns it.
  bool removeTool(String name) {
    if (!_ownedNames.remove(name)) {
      return false;
    }
    return WebMcp.instance.unregisterTool(name);
  }

  /// Returns owned names sorted ascending.
  List<String> get ownedNames => _sortedSnapshot(_ownedNames);

  /// Returns skipped duplicate names sorted ascending.
  List<String> get skippedNames => _sortedSnapshot(_skippedNames);

  /// Whether this scope has been closed.
  bool get isClosed => _isClosed;

  /// Removes all owned tools and permanently closes this scope.
  void close() {
    if (_isClosed) {
      return;
    }
    for (final String name in _ownedNames.toList()) {
      WebMcp.instance.unregisterTool(name);
    }
    _ownedNames.clear();
    _skippedNames.clear();
    _isClosed = true;
  }

  void _ensureOpen() {
    if (_isClosed) {
      throw StateError('WebMcpScope $scopeName is closed.');
    }
  }

  static List<String> _sortedSnapshot(Set<String> names) {
    final List<String> sorted = names.toList()..sort();
    return UnmodifiableListView<String>(sorted);
  }

  @override
  String toString() => 'WebMcpScope($scopeName)';
}
