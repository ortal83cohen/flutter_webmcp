/// Base class for errors raised by the WebMCP registry and widget layer.
abstract class WebMcpException implements Exception {
  /// Creates an exception for [toolName] with [message].
  const WebMcpException(this.toolName, this.message);

  /// The tool related to the error.
  final String toolName;

  /// A human-readable error message.
  final String message;

  @override
  String toString() => '$runtimeType: $message (tool: $toolName)';
}

/// Indicates that a tool name violates the registry's naming rules.
final class WebMcpInvalidToolNameException extends WebMcpException {
  /// Creates an invalid-name exception.
  const WebMcpInvalidToolNameException(String toolName)
    : super(
        toolName,
        'Tool names must contain 1 to 128 ASCII letters, digits, underscores, hyphens, or periods.',
      );
}

/// Indicates that a tool name is already registered.
final class WebMcpDuplicateToolException extends WebMcpException {
  /// Creates a duplicate-name exception.
  const WebMcpDuplicateToolException(String toolName)
    : super(toolName, 'A tool with this name is already registered.');
}

/// Indicates that an invocation named an unregistered tool.
final class WebMcpToolNotFoundException extends WebMcpException {
  /// Creates a missing-tool exception.
  const WebMcpToolNotFoundException(String toolName)
    : super(toolName, 'No registered tool has this name.');
}

/// Indicates that an action has no enclosing WebMCP screen scope.
final class WebMcpScopeMissingException extends WebMcpException {
  /// Creates a missing-scope exception.
  const WebMcpScopeMissingException(String toolName)
    : super(toolName, 'No enclosing WebMcpScreen scope was found.');
}
