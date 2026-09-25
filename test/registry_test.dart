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
  setUp(() {
    WebMcp.logHook = null;
    WebMcp.instance.reset();
  });

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

  test('one callback receives the map and exposedTo is copied', () async {
    final List<String> origins = <String>['https://one.example'];
    final List<Map<String, Object?>> seen = <Map<String, Object?>>[];
    final WebMcpTool tool = WebMcpTool(
      name: 'one.callback',
      description: 'One argument',
      exposedTo: origins,
      handler: (Map<String, Object?> arguments) {
        seen.add(arguments);
        return arguments['value'];
      },
    );
    origins.add('https://two.example');
    WebMcp.instance.registerTool(tool);
    expect(tool.exposedTo, <String>['https://one.example']);
    expect(
      await WebMcp.instance.invokeTool('one.callback', const {'value': 'map'}),
      'map',
    );
    expect(seen.single, <String, Object?>{'value': 'map'});
  });

  test('both tool callbacks throw and leave the registry unchanged', () {
    expect(
      () => WebMcpTool(
        name: 'both',
        description: 'Both callbacks',
        handler: (Map<String, Object?> arguments) => null,
        callHandler: (WebMcpToolCall call) => null,
      ),
      throwsArgumentError,
    );
    expect(WebMcp.instance.tools, isEmpty);
  });

  test('local invoke throws the tool exception', () async {
    final WebMcpToolException failure = const WebMcpToolException(
      code: 'author.code',
      retryable: true,
    );
    WebMcp.instance.registerTool(
      WebMcpTool(
        name: 'local.fail',
        description: 'Throws structured',
        handler: (Map<String, Object?> arguments) => throw failure,
      ),
    );
    await expectLater(
      WebMcp.instance.invokeTool('local.fail', const {}),
      throwsA(
        isA<WebMcpToolException>().having(
          (WebMcpToolException error) => error.code,
          'code',
          'author.code',
        ),
      ),
    );
  });

  test('log hook records kind and tool name without arguments', () async {
    const String secret = 'distinctive-argument-secret';
    final List<WebMcpLogRecord> records = <WebMcpLogRecord>[];
    WebMcp.logHook = records.add;
    WebMcp.instance.registerTool(
      WebMcpTool(
        name: 'logged',
        description: 'Logged tool',
        handler: (Map<String, Object?> arguments) {
          if (arguments['fail'] == true) {
            throw StateError('distinctive-exception-message');
          }
          return arguments[secret];
        },
      ),
    );
    await WebMcp.instance.invokeTool('logged', const {secret: 'value'});
    await expectLater(
      WebMcp.instance.invokeTool('logged', const {'fail': true}),
      throwsStateError,
    );
    WebMcp.instance.unregisterTool('logged');
    expect(
      records.map((WebMcpLogRecord record) => record.kind),
      <WebMcpLogKind>[
        WebMcpLogKind.registered,
        WebMcpLogKind.invoked,
        WebMcpLogKind.invocationFailed,
        WebMcpLogKind.unregistered,
      ],
    );
    expect(
      records.map((WebMcpLogRecord record) => record.toolName),
      everyElement('logged'),
    );
    expect(records.join('\n'), isNot(contains(secret)));
    WebMcp.logHook = null;
  });

  test('a throwing hook leaves the tool registered', () async {
    WebMcp.logHook = (WebMcpLogRecord record) => throw StateError('hook');
    WebMcp.instance.registerTool(
      WebMcpTool(
        name: 'kept',
        description: 'Stays registered',
        handler: (Map<String, Object?> arguments) => 'ok',
      ),
    );
    expect(await WebMcp.instance.invokeTool('kept', const {}), 'ok');
    WebMcp.logHook = null;
  });

  test('declared input rejects bad values before the callback', () async {
    var calls = 0;
    WebMcp.instance.registerTool(
      WebMcpTool.withDecodedArguments(
        name: 'decoded',
        description: 'Declared fields',
        fields: const <WebMcpInputField>[
          WebMcpInputField(key: 'label', shape: WebMcpInputShape.string),
          WebMcpInputField(key: 'count', shape: WebMcpInputShape.safeInteger),
        ],
        callHandler: (WebMcpToolCall call) {
          calls++;
          return call.arguments;
        },
      ),
    );
    Future<void> expectRejected(Map<String, Object?> arguments) async {
      await expectLater(
        WebMcp.instance.invokeTool('decoded', arguments),
        throwsA(isA<WebMcpInvalidArgumentsException>()),
      );
    }

    await expectRejected(const <String, Object?>{
      'label': 'ok',
      'count': 1,
      'extra': true,
    });
    await expectRejected(const <String, Object?>{'label': 'ok'});
    await expectRejected(const <String, Object?>{'label': 'ok', 'count': 1.0});
    await expectRejected(const <String, Object?>{
      'label': 'ok',
      'count': 9007199254740992,
    });
    expect(calls, 0);

    final Object? decoded = await WebMcp.instance.invokeTool('decoded', const {
      'label': 'ok',
      'count': 1,
    });
    expect(calls, 1);
    expect(decoded, <String, Object?>{'label': 'ok', 'count': 1});
  });

  test('free-form schema is a shallow copy and is not validated', () async {
    final Map<String, Object?> nested = <String, Object?>{'inner': true};
    final Map<String, Object?> schema = <String, Object?>{
      'type': 'object',
      'required': <Object?>['needed'],
      'properties': nested,
    };
    var calls = 0;
    final WebMcpTool tool = WebMcpTool(
      name: 'free.form',
      description: 'Schema is descriptive',
      inputSchema: schema,
      handler: (Map<String, Object?> arguments) {
        calls++;
        return 'ran';
      },
    );
    schema['type'] = 'changed';
    WebMcp.instance.registerTool(tool);
    expect(await WebMcp.instance.invokeTool('free.form', const {}), 'ran');
    expect(calls, 1);
    expect(identical(tool.inputSchema, schema), isFalse);
    expect(identical(tool.inputSchema['properties'], nested), isTrue);
  });

  test('unregister is idempotent', () {
    WebMcp.instance.registerTool(_tool('temporary'));
    expect(WebMcp.instance.unregisterTool('temporary'), isTrue);
    expect(WebMcp.instance.tools, isEmpty);
    expect(WebMcp.instance.unregisterTool('temporary'), isFalse);
    expect(WebMcp.instance.tools, isEmpty);
  });
}
