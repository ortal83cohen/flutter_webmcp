import 'dart:collection';

import 'package:flutter/widgets.dart';

import '../webmcp_exceptions.dart';
import '../webmcp_scope.dart';
import '../webmcp_tool.dart';
import 'webmcp_screen.dart';

/// Exposes an explicit tool for exactly as long as [child] is mounted.
final class WebMcpAction extends StatefulWidget {
  /// Creates an action that leaves [child] unchanged.
  WebMcpAction({
    super.key,
    required this.name,
    required this.description,
    Map<String, Object?> inputSchema = const <String, Object?>{},
    required this.onInvoke,
    required this.child,
  }) : inputSchema = UnmodifiableMapView<String, Object?>(
         Map<String, Object?>.of(inputSchema),
       );

  /// The globally unique tool name, registered verbatim.
  final String name;

  /// A human-readable explanation of the action.
  final String description;

  /// The JSON-schema-like input description.
  final Map<String, Object?> inputSchema;

  /// The invocation callback currently associated with this widget.
  final WebMcpToolHandler onInvoke;

  /// The unchanged child rendered by this wrapper.
  final Widget child;

  @override
  State<WebMcpAction> createState() => _WebMcpActionState();
}

final class _WebMcpActionState extends State<WebMcpAction> {
  WebMcpScope? _scope;
  String? _registeredName;
  bool _registered = false;
  bool _ownsTool = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_registered) {
      return;
    }
    _registered = true;
    final WebMcpScope? scope = WebMcpScreen.maybeScopeOf(context);
    if (scope == null) {
      throw WebMcpScopeMissingException(widget.name);
    }
    _scope = scope;
    _registeredName = widget.name;
    _ownsTool = scope.addTool(
      WebMcpTool(
        name: widget.name,
        description: widget.description,
        inputSchema: widget.inputSchema,
        handler: (Map<String, Object?> arguments) => widget.onInvoke(arguments),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    if (_ownsTool) {
      _scope?.removeTool(_registeredName!);
    }
    super.dispose();
  }
}
