import 'package:webmcp_flutter/webmcp_flutter.dart';

/// Mutable state used by the example's imperative tools.
final class ExampleCounter {
  /// The current counter value.
  int value = 0;

  /// Increments the counter and returns its new value.
  int increment() => ++value;
}

/// Registers the two imperative tools demonstrated by the example.
void registerExampleTools(ExampleCounter counter) {
  WebMcp.instance
    ..registerTool(
      WebMcpTool(
        name: 'example.counter.read',
        description: 'Reads the example counter.',
        handler: (Map<String, Object?> arguments) => counter.value,
      ),
    )
    ..registerTool(
      WebMcpTool(
        name: 'example.counter.increment',
        description: 'Increments the example counter.',
        handler: (Map<String, Object?> arguments) => counter.increment(),
      ),
    );
}
