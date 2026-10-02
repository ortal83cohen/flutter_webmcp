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

/// A structured tool failure an agent may receive as an allowlisted error.
class WebMcpToolException implements Exception {
  /// Creates a failure with an author [code] and [retryable] flag.
  const WebMcpToolException({
    required this.code,
    required this.retryable,
    this.details,
  });

  /// The author error code.
  final String code;

  /// Whether the author marked the failure as retryable.
  final bool retryable;

  /// Optional JSON details, included only when the publisher accepts them.
  final Map<String, Object?>? details;

  @override
  String toString() => 'WebMcpToolException($code)';
}

/// The closed set of reasons declared-field decoding can reject an argument.
enum WebMcpDecodeFailureReason {
  /// A required declared key was absent from the argument map.
  missing,

  /// The argument map held a key that no declared field names.
  unknown,

  /// A present value, or a field declaration, failed the declared shape.
  type,
}

/// Indicates that declared tool arguments did not match the field list.
final class WebMcpInvalidArgumentsException extends WebMcpToolException {
  /// Creates an invalid-arguments failure with no details, key or reason.
  const WebMcpInvalidArgumentsException()
    : key = null,
      reason = null,
      super(code: 'invalidArguments', retryable: false);

  /// Creates an invalid-arguments failure for the top-level argument [key].
  ///
  /// The inherited details map holds exactly two string entries, `field` and
  /// `reason`. It never carries the rejected value, a message or a stack.
  WebMcpInvalidArgumentsException.withFailure({
    required String key,
    required WebMcpDecodeFailureReason reason,
  }) : key = key,
       reason = reason,
       super(
         code: 'invalidArguments',
         retryable: false,
         details: <String, Object?>{'field': key, 'reason': reason.name},
       );

  /// The top-level argument key that failed, or null when not recorded.
  final String? key;

  /// Why the argument failed, or null when not recorded.
  final WebMcpDecodeFailureReason? reason;
}
