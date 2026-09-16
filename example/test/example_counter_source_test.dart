import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';

import 'package:webmcp_flutter_example/example_counter_source.dart';
import 'package:webmcp_flutter_example/example_tools.dart';

void main() {
  setUp(WebMcp.instance.reset);
  tearDown(WebMcp.instance.reset);

  test('the source produces exactly the three fixed tool names', () {
    final ExampleCounter counter = ExampleCounter();
    final ExampleCounterSource source = ExampleCounterSource(counter);

    final List<String> names = source
        .getWebMcpTools()
        .map((WebMcpTool tool) => tool.name)
        .toList();

    expect(names, <String>[
      'example.source.counter.read',
      'example.source.counter.add',
      'example.source.counter.reset',
    ]);
  });

  test('the add descriptor carries a non-empty schema requiring amount, and '
      'the annotation flags match the fixed contract', () {
    final ExampleCounter counter = ExampleCounter();
    final ExampleCounterSource source = ExampleCounterSource(counter);
    final List<WebMcpTool> tools = source.getWebMcpTools();

    final WebMcpTool read = tools.singleWhere(
      (WebMcpTool tool) => tool.name == 'example.source.counter.read',
    );
    final WebMcpTool add = tools.singleWhere(
      (WebMcpTool tool) => tool.name == 'example.source.counter.add',
    );
    final WebMcpTool reset = tools.singleWhere(
      (WebMcpTool tool) => tool.name == 'example.source.counter.reset',
    );

    expect(add.inputSchema, isNotEmpty);
    expect(add.inputSchema['required'], contains('amount'));

    expect(read.annotations.readOnlyHint, isTrue);
    expect(read.annotations.consequentialHint, isFalse);

    expect(add.annotations.consequentialHint, isTrue);
    expect(reset.annotations.consequentialHint, isTrue);
  });

  test('a successful add of three raises the counter by three', () async {
    final ExampleCounter counter = ExampleCounter();
    final WebMcpScope scope = WebMcpScope(scopeName: 'counter-source');
    scope.addSource(ExampleCounterSource(counter));

    final Object? result = await WebMcp.instance.invokeTool(
      'example.source.counter.add',
      <String, Object?>{'amount': 3},
    );

    expect(result, 3);
    expect(counter.value, 3);
  });

  test('an amount of zero returns an invalid-arguments failure envelope and '
      'leaves the counter unchanged', () async {
    final ExampleCounter counter = ExampleCounter();
    final WebMcpScope scope = WebMcpScope(scopeName: 'counter-source');
    scope.addSource(ExampleCounterSource(counter));

    final Object? result = await WebMcp.instance.invokeTool(
      'example.source.counter.add',
      <String, Object?>{'amount': 0},
    );

    expect(result, isA<Map<String, Object?>>());
    final Map<String, Object?> envelope = result! as Map<String, Object?>;
    expect(envelope['ok'], isFalse);
    expect(
      (envelope['error']! as Map<String, Object?>)['code'],
      'invalidArguments',
    );
    expect(counter.value, 0);
  });

  test('a negative amount returns an invalid-arguments failure envelope and '
      'leaves the counter unchanged', () async {
    final ExampleCounter counter = ExampleCounter();
    final WebMcpScope scope = WebMcpScope(scopeName: 'counter-source');
    scope.addSource(ExampleCounterSource(counter));

    final Object? result = await WebMcp.instance.invokeTool(
      'example.source.counter.add',
      <String, Object?>{'amount': -1},
    );

    expect(result, isA<Map<String, Object?>>());
    final Map<String, Object?> envelope = result! as Map<String, Object?>;
    expect(envelope['ok'], isFalse);
    expect(
      (envelope['error']! as Map<String, Object?>)['code'],
      'invalidArguments',
    );
    expect(counter.value, 0);
  });

  test('a missing amount returns an invalid-arguments failure envelope and '
      'leaves the counter unchanged', () async {
    final ExampleCounter counter = ExampleCounter();
    final WebMcpScope scope = WebMcpScope(scopeName: 'counter-source');
    scope.addSource(ExampleCounterSource(counter));

    final Object? result = await WebMcp.instance.invokeTool(
      'example.source.counter.add',
      const <String, Object?>{},
    );

    expect(result, isA<Map<String, Object?>>());
    final Map<String, Object?> envelope = result! as Map<String, Object?>;
    expect(envelope['ok'], isFalse);
    expect(
      (envelope['error']! as Map<String, Object?>)['code'],
      'invalidArguments',
    );
    expect(counter.value, 0);
  });

  test('the reset tool sets the counter back to zero', () async {
    final ExampleCounter counter = ExampleCounter();
    counter.incrementBy(5);
    final WebMcpScope scope = WebMcpScope(scopeName: 'counter-source');
    scope.addSource(ExampleCounterSource(counter));

    final Object? result = await WebMcp.instance.invokeTool(
      'example.source.counter.reset',
      const <String, Object?>{},
    );

    expect(result, 0);
    expect(counter.value, 0);
  });
}
