import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_pilot/webmcp_pilot.dart';
import 'package:webmcp_pilot_example/example_tools.dart';

void main() {
  setUp(WebMcp.instance.reset);

  test('registers two imperative tools and increments the counter', () async {
    final ExampleCounter counter = ExampleCounter();
    registerExampleTools(counter);

    expect(WebMcp.instance.tools.map((WebMcpTool tool) => tool.name), <String>[
      'example.counter.increment',
      'example.counter.read',
    ]);
    expect(counter.value, 0);
    await WebMcp.instance.invokeTool(
      'example.counter.increment',
      const <String, Object?>{},
    );
    expect(counter.value, 1);
  });
}
