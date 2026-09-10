import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';

WebMcpTool _tool(String name, [Object? value]) => WebMcpTool(
  name: name,
  description: 'Tool $name',
  handler: (Map<String, Object?> arguments) => value,
);

final class _Source implements WebMcpToolSource {
  _Source(this.values);

  final List<WebMcpTool> values;

  @override
  List<WebMcpTool> getWebMcpTools() => values;
}

void main() {
  setUp(WebMcp.instance.reset);

  test('registers tools and lists them in ascending order', () {
    WebMcp.instance
      ..registerTool(_tool('zeta'))
      ..registerTool(_tool('alpha'))
      ..registerTool(_tool('middle'));

    expect(WebMcp.instance.tools.map((WebMcpTool tool) => tool.name), <String>[
      'alpha',
      'middle',
      'zeta',
    ]);
  });

  test('registers sources through duplicate validation', () {
    WebMcp.instance.registerSource(
      _Source(<WebMcpTool>[_tool('source.one'), _tool('source.two')]),
    );
    expect(WebMcp.instance.tools, hasLength(2));

    WebMcp.instance.registerTool(_tool('collision'));
    expect(
      () => WebMcp.instance.registerSource(
        _Source(<WebMcpTool>[_tool('collision')]),
      ),
      throwsA(isA<WebMcpDuplicateToolException>()),
    );
  });

  test('source registration retains tools added before a later failure', () {
    WebMcp.instance.registerTool(_tool('collision'));

    expect(
      () => WebMcp.instance.registerSource(
        _Source(<WebMcpTool>[_tool('added.first'), _tool('collision')]),
      ),
      throwsA(isA<WebMcpDuplicateToolException>()),
    );
    expect(WebMcp.instance.tools.map((WebMcpTool tool) => tool.name), <String>[
      'added.first',
      'collision',
    ]);
  });

  test('rejects duplicates without replacing the first handler', () async {
    WebMcp.instance.registerTool(_tool('same', 'first'));
    expect(
      () => WebMcp.instance.registerTool(_tool('same', 'second')),
      throwsA(
        isA<WebMcpDuplicateToolException>().having(
          (WebMcpDuplicateToolException error) => error.toolName,
          'toolName',
          'same',
        ),
      ),
    );
    expect(await WebMcp.instance.invokeTool('same', const {}), 'first');
  });

  test('validates empty, long, and unsupported names', () {
    for (final String name in <String>['', 'x' * 129, 'has space']) {
      expect(
        () => WebMcp.instance.registerTool(_tool(name)),
        throwsA(isA<WebMcpInvalidToolNameException>()),
      );
    }
    WebMcp.instance.registerTool(_tool('x' * 128));
    expect(WebMcp.instance.tools, hasLength(1));
  });

  test('passes arguments through and awaits the handler', () async {
    WebMcp.instance.registerTool(
      WebMcpTool(
        name: 'echo',
        description: 'Echoes input',
        handler: (Map<String, Object?> arguments) async => arguments['value'],
      ),
    );
    expect(await WebMcp.instance.invokeTool('echo', const {'value': 42}), 42);
  });

  test(
    'passes handler result and exception objects through unchanged',
    () async {
      final Object result = <String, Object?>{'raw': Object()};
      final StateError failure = StateError('handler failed');
      WebMcp.instance
        ..registerTool(_tool('raw.result', result))
        ..registerTool(
          WebMcpTool(
            name: 'raw.failure',
            description: 'Throws its original exception',
            handler: (Map<String, Object?> arguments) => throw failure,
          ),
        );

      expect(
        await WebMcp.instance.invokeTool('raw.result', const {}),
        same(result),
      );
      await expectLater(
        WebMcp.instance.invokeTool('raw.failure', const {}),
        throwsA(same(failure)),
      );
    },
  );

  test(
    'input schema is shallow copied and is not runtime validation',
    () async {
      final List<Object?> required = <Object?>['value'];
      final Map<String, Object?> schema = <String, Object?>{
        'type': 'object',
        'required': required,
      };
      final WebMcpTool tool = WebMcpTool(
        name: 'schema.behavior',
        description: 'Documents schema behavior',
        inputSchema: schema,
        handler: (Map<String, Object?> arguments) => 'invoked',
      );
      schema['type'] = 'string';
      required.add('later');
      WebMcp.instance.registerTool(tool);

      expect(tool.inputSchema['type'], 'object');
      expect(tool.inputSchema['required'], <Object?>['value', 'later']);
      expect(
        await WebMcp.instance.invokeTool('schema.behavior', const {}),
        'invoked',
      );
    },
  );

  test('throws for a missing tool without invoking another handler', () async {
    var calls = 0;
    WebMcp.instance.registerTool(
      WebMcpTool(
        name: 'present',
        description: 'Present tool',
        handler: (Map<String, Object?> arguments) => calls++,
      ),
    );
    await expectLater(
      WebMcp.instance.invokeTool('missing', const {}),
      throwsA(
        isA<WebMcpToolNotFoundException>().having(
          (WebMcpToolNotFoundException error) => error.toolName,
          'toolName',
          'missing',
        ),
      ),
    );
    expect(calls, 0);
  });

  test('unregister is idempotent', () {
    WebMcp.instance.registerTool(_tool('temporary'));
    expect(WebMcp.instance.unregisterTool('temporary'), isTrue);
    expect(WebMcp.instance.tools, isEmpty);
    expect(WebMcp.instance.unregisterTool('temporary'), isFalse);
    expect(WebMcp.instance.tools, isEmpty);
  });
}
