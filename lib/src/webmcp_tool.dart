import 'dart:async';
import 'dart:collection';

/// Handles one invocation of a registered WebMCP tool.
typedef WebMcpToolHandler = FutureOr<Object?> Function(
  Map<String, Object?> arguments,
);

/// Describes a tool that can be exposed through WebMCP.
final class WebMcpTool {
  /// Creates an immutable tool descriptor.
  WebMcpTool({
    required this.name,
    required this.description,
    Map<String, Object?> inputSchema = const <String, Object?>{},
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

  /// The function invoked when the tool is called.
  final WebMcpToolHandler handler;
}
