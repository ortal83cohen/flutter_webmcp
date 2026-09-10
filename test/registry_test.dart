import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_pilot/webmcp_pilot.dart';

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
