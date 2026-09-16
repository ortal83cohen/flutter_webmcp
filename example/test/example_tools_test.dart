import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';
import 'package:webmcp_flutter_example/example_tools.dart';

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

  test('increment adds one, notifies listeners and returns the new value', () {
    final ExampleCounter counter = ExampleCounter();
    var notifications = 0;
    counter.addListener(() => notifications++);

    final int result = counter.increment();

    expect(result, 1);
    expect(counter.value, 1);
    expect(notifications, 1);
  });

  test('incrementBy adds a positive amount, notifies listeners and returns the new value', () {
    final ExampleCounter counter = ExampleCounter();
    var notifications = 0;
    counter.addListener(() => notifications++);

    final int result = counter.incrementBy(3);

    expect(result, 3);
    expect(counter.value, 3);
    expect(notifications, 1);
  });

  test(
    'incrementBy rejects a non-positive amount and leaves the value unchanged',
    () {
      final ExampleCounter counter = ExampleCounter();
      var notifications = 0;
      counter.addListener(() => notifications++);

      expect(() => counter.incrementBy(0), throwsArgumentError);
      expect(() => counter.incrementBy(-1), throwsArgumentError);
      expect(counter.value, 0);
      expect(notifications, 0);
    },
  );

  test('reset sets the value to zero, notifies listeners and returns zero', () {
    final ExampleCounter counter = ExampleCounter();
    counter.incrementBy(5);
    var notifications = 0;
    counter.addListener(() => notifications++);

    final int result = counter.reset();

    expect(result, 0);
    expect(counter.value, 0);
    expect(notifications, 1);
  });
}
