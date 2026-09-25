import 'dart:async';
import 'dart:collection';

import 'webmcp_typed_input.dart';

/// Handles one invocation of a registered WebMCP tool.
typedef WebMcpToolHandler = FutureOr<Object?> Function(
  Map<String, Object?> arguments,
);

/// Handles one invocation that can observe a browser execution signal.
typedef WebMcpToolCallHandler = FutureOr<Object?> Function(WebMcpToolCall call);

/// Author-owned view of a browser execution signal.
///
/// The library never aborts this signal and never finishes the handler because
/// the signal aborted.
abstract interface class WebMcpExecutionSignal {
  /// Whether the browser has aborted this execution.
  bool get aborted;

  /// Registers [listener] to run if the signal later aborts.
  void addAbortListener(void Function() listener);

  /// Removes a listener previously passed to [addAbortListener].
  void removeAbortListener(void Function() listener);
}

/// Arguments and optional execution signal for one tool call.
final class WebMcpToolCall {
  /// Creates a call with [arguments] and an optional [executionSignal].
  const WebMcpToolCall({
    required this.arguments,
    required this.executionSignal,
  });

  /// The decoded or raw argument map.
  final Map<String, Object?> arguments;

  /// The browser execution signal, or null when the caller has none.
  final WebMcpExecutionSignal? executionSignal;
}

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
    this.debugging,
  });

  /// Whether the tool is declared not to modify state.
  final bool readOnlyHint;

  /// Whether returned content may be untrusted.
  final bool untrustedContentHint;

  /// Whether invocation may have significant real-world consequences.
  final bool consequentialHint;

  /// Whether the author marked this tool as a debugging hint.
  ///
  /// Null means the browser registration omits the member.
  final bool? debugging;
}

/// Describes a tool that can be exposed through WebMCP.
final class WebMcpTool {
  /// Creates an immutable tool descriptor.
  ///
  /// Exactly one of [handler] and [callHandler] is required.
  WebMcpTool({
    required this.name,
    required this.description,
    Map<String, Object?> inputSchema = const <String, Object?>{},
    this.annotations = const WebMcpToolAnnotations(),
    this.title,
    List<String>? exposedTo,
    WebMcpToolHandler? handler,
    WebMcpToolCallHandler? callHandler,
  }) : inputSchema = UnmodifiableMapView<String, Object?>(
         Map<String, Object?>.of(inputSchema),
       ),
       exposedTo = exposedTo == null
           ? null
           : List<String>.unmodifiable(exposedTo),
       handler = handler,
       callHandler = callHandler {
    if ((handler == null) == (callHandler == null)) {
      throw ArgumentError(
        'A tool requires exactly one of handler or callHandler.',
      );
    }
  }

  /// Creates a tool that decodes [fields] before [callHandler] runs.
  ///
  /// Decode failure throws before [callHandler] runs. This constructor does not
  /// set [handler].
  factory WebMcpTool.withDecodedArguments({
    required String name,
    required String description,
    required List<WebMcpInputField> fields,
    Map<String, Object?> inputSchema = const <String, Object?>{},
    WebMcpToolAnnotations annotations = const WebMcpToolAnnotations(),
    String? title,
    List<String>? exposedTo,
    required WebMcpToolCallHandler callHandler,
  }) {
    return WebMcpTool(
      name: name,
      description: description,
      inputSchema: inputSchema,
      annotations: annotations,
      title: title,
      exposedTo: exposedTo,
      callHandler: (WebMcpToolCall call) {
        final Map<String, Object?> decoded = webMcpDecodeArguments(
          fields,
          call.arguments,
        );
        return callHandler(
          WebMcpToolCall(
            arguments: decoded,
            executionSignal: call.executionSignal,
          ),
        );
      },
    );
  }

  /// The globally unique tool name.
  final String name;

  /// A human-readable explanation of the tool.
  final String description;

  /// Optional display title.
  ///
  /// Null means the browser registration omits the member.
  final String? title;

  /// The JSON-schema-like input description for the tool.
  final Map<String, Object?> inputSchema;

  /// Optional browser-agent hints that do not replace authorization.
  final WebMcpToolAnnotations annotations;

  /// Origin strings forwarded to the browser, or null when omitted.
  final List<String>? exposedTo;

  /// The one-argument function invoked when [callHandler] is null.
  final WebMcpToolHandler? handler;

  /// The call function invoked when [handler] is null.
  final WebMcpToolCallHandler? callHandler;
}
