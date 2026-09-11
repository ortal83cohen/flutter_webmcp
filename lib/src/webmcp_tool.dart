import 'dart:async';
import 'dart:collection';

/// Handles one invocation of a registered WebMCP tool.
typedef WebMcpToolHandler = FutureOr<Object?> Function(
  Map<String, Object?> arguments,
);

/// Optional descriptive hints supplied to browser agents.
///
/// Hints never grant authorization and applications must still enforce current
/// policy inside each handler.
final class WebMcpToolAnnotations {
  /// Creates immutable tool hints.
  const WebMcpToolAnnotations({
    this.readOnlyHint = false,
    this.untrustedContentHint = false,
    this.consequentialHint = false,
  });

  /// Whether the tool is declared not to modify state.
  final bool readOnlyHint;

  /// Whether returned content may be untrusted.
  final bool untrustedContentHint;

  /// Whether invocation may have significant real-world consequences.
  final bool consequentialHint;
}

/// Describes a tool that can be exposed through WebMCP.
final class WebMcpTool {
  /// Creates an immutable tool descriptor.
  WebMcpTool({
    required this.name,
    required this.description,
    Map<String, Object?> inputSchema = const <String, Object?>{},
    this.annotations = const WebMcpToolAnnotations(),
    required this.handler,
  }) : inputSchema = UnmodifiableMapView<String, Object?>(
         Map<String, Object?>.of(inputSchema),
       );

  /// The globally unique tool name.
  final String name;

  /// A human-readable explanation of the tool.
  final String description;

  /// The JSON-schema-like input description for the tool.
  final Map<String, Object?> inputSchema;

  /// Optional browser-agent hints that do not replace authorization.
  final WebMcpToolAnnotations annotations;

  /// The function invoked when the tool is called.
  final WebMcpToolHandler handler;
}
