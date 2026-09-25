import 'dart:collection';

import 'package:flutter/widgets.dart';

import '../webmcp_exceptions.dart';
import '../webmcp_scope.dart';
import '../webmcp_tool.dart';
import 'webmcp_screen.dart';

/// Exposes an explicit tool for exactly as long as [child] is mounted.
final class WebMcpAction extends StatefulWidget {
  /// Creates an action that leaves [child] unchanged.
  ///
  /// Exactly one of [onInvoke] and [onCall] is required.
  WebMcpAction({
    super.key,
    required this.name,
    required this.description,
    Map<String, Object?> inputSchema = const <String, Object?>{},
    this.annotations = const WebMcpToolAnnotations(),
    this.title,
    List<String>? exposedTo,
    this.onInvoke,
    this.onCall,
    required this.child,
  }) : inputSchema = UnmodifiableMapView<String, Object?>(
         Map<String, Object?>.of(inputSchema),
       ),
       exposedTo = exposedTo == null
           ? null
           : List<String>.unmodifiable(exposedTo) {
    if ((onInvoke == null) == (onCall == null)) {
      throw ArgumentError(
        'WebMcpAction requires exactly one of onInvoke or onCall.',
      );
    }
  }

  /// The globally unique tool name, registered verbatim.
  final String name;

  /// A human-readable explanation of the action.
  final String description;

  /// The JSON-schema-like input description.
  final Map<String, Object?> inputSchema;

  /// Optional browser-agent hints captured at the first mount.
  final WebMcpToolAnnotations annotations;

  /// Optional display title captured at the first mount.
  final String? title;

  /// Optional origin list captured at the first mount.
  final List<String>? exposedTo;

  /// The one-argument invocation callback, when this action has no [onCall].
  final WebMcpToolHandler? onInvoke;

  /// The call callback, when this action has no [onInvoke].
  final WebMcpToolCallHandler? onCall;

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
    final WebMcpToolHandler? onInvoke = widget.onInvoke;
    final WebMcpToolCallHandler? onCall = widget.onCall;
    _ownsTool = scope.addTool(
      WebMcpTool(
        name: widget.name,
        description: widget.description,
        inputSchema: widget.inputSchema,
        annotations: widget.annotations,
        title: widget.title,
        exposedTo: widget.exposedTo,
        handler: onInvoke == null
            ? null
            : (Map<String, Object?> arguments) => widget.onInvoke!(arguments),
        callHandler: onCall == null
            ? null
            : (WebMcpToolCall call) => widget.onCall!(call),
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
