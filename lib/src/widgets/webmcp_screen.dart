import 'package:flutter/widgets.dart';

import '../webmcp_scope.dart';

/// Adds a registry scope to the lifetime of a Flutter [State].
mixin WebMcpScreen<T extends StatefulWidget> on State<T> {
  late final WebMcpScope _mcpScope;

  /// The scope owned by this state while it is mounted.
  WebMcpScope get mcpScope => _mcpScope;

  /// Finds the nearest ancestor state carrying a WebMCP screen scope.
  static WebMcpScope? maybeScopeOf(BuildContext context) {
    WebMcpScope? result;
    context.visitAncestorElements((Element element) {
      if (element is StatefulElement && element.state is WebMcpScreen) {
        result = (element.state as WebMcpScreen).mcpScope;
        return false;
      }
      return true;
    });
    return result;
  }

  /// Declares screen-owned tools after the scope has been created.
  @protected
  void registerWebMcpTools() {}

  @override
  void initState() {
    super.initState();
    _mcpScope = WebMcpScope(scopeName: runtimeType.toString());
    registerWebMcpTools();
  }

  @override
  void dispose() {
    _mcpScope.close();
    super.dispose();
  }
}
