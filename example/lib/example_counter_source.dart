import 'package:webmcp_flutter/webmcp_flutter.dart';

import 'example_tools.dart';

/// The failure envelope shape handlers in this example use instead of
/// throwing across the registry boundary, matching the shape the generated
/// domain-action adapter emits.
Map<String, Object?> _invalidArguments() => const <String, Object?>{
  'ok': false,
  'error': <String, Object?>{'code': 'invalidArguments', 'retryable': false},
};

/// A hand-written [WebMcpToolSource] exposing the live [ExampleCounter]
/// through a batch of three descriptors: a read-only read, a consequential
/// amount-taking add and a consequential reset.
final class ExampleCounterSource implements WebMcpToolSource {
  /// Creates an adapter over the supplied live counter.
  const ExampleCounterSource(this.counter);

  /// The live counter instance this source reads and mutates.
  final ExampleCounter counter;

  @override
  List<WebMcpTool> getWebMcpTools() => <WebMcpTool>[
    WebMcpTool(
      name: 'example.source.counter.read',
      description: 'Reads the example counter through the tool source.',
      annotations: const WebMcpToolAnnotations(readOnlyHint: true),
      handler: _read,
    ),
    WebMcpTool(
      name: 'example.source.counter.add',
      description: 'Adds a positive amount to the example counter.',
      inputSchema: const <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'properties': <String, Object?>{
          'amount': <String, Object?>{'type': 'integer'},
        },
        'required': <Object?>['amount'],
      },
      annotations: const WebMcpToolAnnotations(consequentialHint: true),
      handler: _add,
    ),
    WebMcpTool(
      name: 'example.source.counter.reset',
      description: 'Resets the example counter to zero.',
      annotations: const WebMcpToolAnnotations(consequentialHint: true),
      handler: _reset,
    ),
  ];

  Object? _read(Map<String, Object?> arguments) => counter.value;

  Object? _add(Map<String, Object?> arguments) {
    final Object? rawAmount = arguments['amount'];
    if (rawAmount is! int || rawAmount <= 0) {
      return _invalidArguments();
    }
    try {
      return counter.incrementBy(rawAmount);
    } on ArgumentError {
      // Defensive fallback: `incrementBy` already validates its argument,
      // so this branch should be unreachable given the check above, but the
      // registry boundary must never propagate an uncaught exception.
      return _invalidArguments();
    }
  }

  Object? _reset(Map<String, Object?> arguments) => counter.reset();
}
