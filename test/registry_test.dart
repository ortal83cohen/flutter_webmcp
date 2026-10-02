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

  group('derived input schema', () {
    WebMcpTool decoded(
      List<WebMcpInputField> fields, {
      Map<String, Object?> inputSchema = const <String, Object?>{},
    }) => WebMcpTool.withDecodedArguments(
      name: 'derived',
      description: 'Declared fields',
      fields: fields,
      inputSchema: inputSchema,
      callHandler: (WebMcpToolCall call) => call.arguments,
    );

    Map<String, Object?> propertiesOf(WebMcpTool tool) =>
        tool.inputSchema['properties']! as Map<String, Object?>;

    test('builds an object wrapper with one property per field', () {
      final WebMcpTool tool = decoded(const <WebMcpInputField>[
        WebMcpInputField(key: 'a', shape: WebMcpInputShape.string),
        WebMcpInputField(key: 'b', shape: WebMcpInputShape.boolean),
      ]);
      expect(tool.inputSchema['type'], 'object');
      expect(tool.inputSchema['additionalProperties'], isFalse);
      expect(propertiesOf(tool).keys, <String>['a', 'b']);

      final WebMcpTool explicitEmpty = decoded(const <WebMcpInputField>[
        WebMcpInputField(key: 'a', shape: WebMcpInputShape.string),
      ], inputSchema: const <String, Object?>{});
      expect(propertiesOf(explicitEmpty).keys, <String>['a']);
    });

    test('keeps a non-empty author schema unchanged', () {
      final WebMcpTool tool = decoded(
        const <WebMcpInputField>[
          WebMcpInputField(key: 'a', shape: WebMcpInputShape.string),
        ],
        inputSchema: const <String, Object?>{'description': 'author'},
      );
      expect(tool.inputSchema, <String, Object?>{'description': 'author'});
      expect(tool.inputSchema.containsKey('type'), isFalse);
      expect(tool.inputSchema.containsKey('properties'), isFalse);
      expect(tool.inputSchema.containsKey('additionalProperties'), isFalse);
    });

    test('lists only required keys and omits required when none', () {
      final WebMcpTool mixed = decoded(const <WebMcpInputField>[
        WebMcpInputField(key: 'must', shape: WebMcpInputShape.string),
        WebMcpInputField(
          key: 'may',
          shape: WebMcpInputShape.string,
          isRequired: false,
        ),
        WebMcpInputField(key: 'also', shape: WebMcpInputShape.boolean),
      ]);
      expect(mixed.inputSchema['required'], <String>['must', 'also']);

      final WebMcpTool optional = decoded(const <WebMcpInputField>[
        WebMcpInputField(
          key: 'may',
          shape: WebMcpInputShape.string,
          isRequired: false,
        ),
      ]);
      expect(optional.inputSchema.containsKey('required'), isFalse);

      final WebMcpTool none = decoded(const <WebMcpInputField>[]);
      expect(none.inputSchema, <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'properties': <String, Object?>{},
      });
    });

    test('derives scalar property schemas', () {
      final WebMcpTool tool = decoded(const <WebMcpInputField>[
        WebMcpInputField(key: 's', shape: WebMcpInputShape.string),
        WebMcpInputField(key: 'b', shape: WebMcpInputShape.boolean),
        WebMcpInputField(key: 'i', shape: WebMcpInputShape.safeInteger),
        WebMcpInputField(key: 'd', shape: WebMcpInputShape.finiteDouble),
      ]);
      expect(propertiesOf(tool), <String, Object?>{
        's': <String, Object?>{'type': 'string'},
        'b': <String, Object?>{'type': 'boolean'},
        'i': <String, Object?>{
          'type': 'integer',
          'minimum': -9007199254740991,
          'maximum': 9007199254740991,
        },
        'd': <String, Object?>{'type': 'number'},
      });
      final Map<String, Object?> integer =
          propertiesOf(tool)['i']! as Map<String, Object?>;
      expect(integer['minimum'], webMcpSafeIntegerMinimum);
      expect(integer['maximum'], webMcpSafeIntegerMaximum);
    });

    test('derives enumeration schemas including an empty name list', () {
      final WebMcpTool tool = decoded(const <WebMcpInputField>[
        WebMcpInputField(
          key: 'mode',
          shape: WebMcpInputShape.enumeration,
          allowedNames: <String>['fast', 'slow'],
        ),
        WebMcpInputField(key: 'none', shape: WebMcpInputShape.enumeration),
      ]);
      expect(propertiesOf(tool), <String, Object?>{
        'mode': <String, Object?>{
          'type': 'string',
          'enum': <String>['fast', 'slow'],
        },
        'none': <String, Object?>{'type': 'string', 'enum': <String>[]},
      });
    });

    test('wraps only nullable fields in an anyOf union', () {
      final WebMcpTool tool = decoded(const <WebMcpInputField>[
        WebMcpInputField(
          key: 'maybe',
          shape: WebMcpInputShape.string,
          nullable: true,
        ),
        WebMcpInputField(
          key: 'maybeMode',
          shape: WebMcpInputShape.enumeration,
          nullable: true,
          allowedNames: <String>['x'],
        ),
        WebMcpInputField(key: 'plain', shape: WebMcpInputShape.string),
      ]);
      expect(propertiesOf(tool), <String, Object?>{
        'maybe': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{'type': 'string'},
            <String, Object?>{'type': 'null'},
          ],
        },
        'maybeMode': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'enum': <String>['x'],
            },
            <String, Object?>{'type': 'null'},
          ],
        },
        'plain': <String, Object?>{'type': 'string'},
      });
      expect(propertiesOf(tool).toString(), isNot(contains('oneOf')));
    });

    test('recurses through list and map children', () {
      const WebMcpInputField nullableInt = WebMcpInputField(
        key: 'ignored',
        shape: WebMcpInputShape.safeInteger,
        isRequired: false,
        nullable: true,
      );
      final WebMcpTool tool = decoded(const <WebMcpInputField>[
        WebMcpInputField(
          key: 'ints',
          shape: WebMcpInputShape.list,
          child: nullableInt,
        ),
        WebMcpInputField(
          key: 'groups',
          shape: WebMcpInputShape.map,
          child: WebMcpInputField(
            key: 'ignored',
            shape: WebMcpInputShape.list,
            child: WebMcpInputField(
              key: 'ignored',
              shape: WebMcpInputShape.string,
            ),
          ),
        ),
      ]);
      final Map<String, Object?> integer = <String, Object?>{
        'type': 'integer',
        'minimum': webMcpSafeIntegerMinimum,
        'maximum': webMcpSafeIntegerMaximum,
      };
      expect(propertiesOf(tool), <String, Object?>{
        'ints': <String, Object?>{
          'type': 'array',
          'items': <String, Object?>{
            'anyOf': <Object?>[
              integer,
              <String, Object?>{'type': 'null'},
            ],
          },
        },
        'groups': <String, Object?>{
          'type': 'object',
          'additionalProperties': <String, Object?>{
            'type': 'array',
            'items': <String, Object?>{'type': 'string'},
          },
        },
      });
    });

    test('a childless list or map constructs with only its base type', () {
      late final WebMcpTool tool;
      expect(() {
        tool = decoded(const <WebMcpInputField>[
          WebMcpInputField(key: 'l', shape: WebMcpInputShape.list),
          WebMcpInputField(key: 'm', shape: WebMcpInputShape.map),
        ]);
      }, returnsNormally);
      expect(propertiesOf(tool), <String, Object?>{
        'l': <String, Object?>{'type': 'array'},
        'm': <String, Object?>{'type': 'object'},
      });
    });

    test('two tools from one field list share no nested state', () {
      const List<WebMcpInputField> fields = <WebMcpInputField>[
        WebMcpInputField(
          key: 'mode',
          shape: WebMcpInputShape.enumeration,
          allowedNames: <String>['a'],
        ),
        WebMcpInputField(
          key: 'items',
          shape: WebMcpInputShape.list,
          child: WebMcpInputField(key: 'x', shape: WebMcpInputShape.string),
        ),
      ];
      final WebMcpTool first = decoded(fields);
      final WebMcpTool second = decoded(fields);
      propertiesOf(first)['injected'] = true;
      (propertiesOf(first)['mode']! as Map<String, Object?>)['enum'] = <String>[
        'changed',
      ];
      ((propertiesOf(first)['items']! as Map<String, Object?>)['items']!
              as Map<String, Object?>)['type'] =
          'changed';
      expect(propertiesOf(second).containsKey('injected'), isFalse);
      expect(propertiesOf(second)['mode'], <String, Object?>{
        'type': 'string',
        'enum': <String>['a'],
      });
      expect(propertiesOf(second)['items'], <String, Object?>{
        'type': 'array',
        'items': <String, Object?>{'type': 'string'},
      });
      expect(
        identical(propertiesOf(first)['mode'], propertiesOf(second)['mode']),
        isFalse,
      );
    });

    test('a plain tool keeps an empty schema', () {
      expect(_tool('plain').inputSchema, isEmpty);
    });

    test('invocation never validates arguments against a schema', () async {
      var plainCalls = 0;
      WebMcp.instance.registerTool(
        WebMcpTool(
          name: 'plain.schema',
          description: 'Hand-written schema',
          inputSchema: const <String, Object?>{
            'type': 'object',
            'required': <Object?>['needed'],
          },
          handler: (Map<String, Object?> arguments) {
            plainCalls++;
            return 'ran';
          },
        ),
      );
      expect(await WebMcp.instance.invokeTool('plain.schema', const {}), 'ran');
      expect(plainCalls, 1);

      // The derived schema says integer with a minimum; only decoding decides.
      WebMcp.instance.registerTool(
        WebMcpTool.withDecodedArguments(
          name: 'derived.only',
          description: 'Decoded',
          fields: const <WebMcpInputField>[
            WebMcpInputField(key: 'n', shape: WebMcpInputShape.safeInteger),
          ],
          callHandler: (WebMcpToolCall call) => call.arguments,
        ),
      );
      expect(
        await WebMcp.instance.invokeTool('derived.only', const {'n': 5}),
        <String, Object?>{'n': 5},
      );
      await expectLater(
        WebMcp.instance.invokeTool('derived.only', const {'n': 'five'}),
        throwsA(
          isA<WebMcpInvalidArgumentsException>().having(
            (WebMcpInvalidArgumentsException e) => e.reason,
            'reason',
            WebMcpDecodeFailureReason.type,
          ),
        ),
      );
    });
  });

  group('decode failure key and reason', () {
    const List<WebMcpInputField> fields = <WebMcpInputField>[
      WebMcpInputField(key: 'req', shape: WebMcpInputShape.string),
      WebMcpInputField(
        key: 's',
        shape: WebMcpInputShape.string,
        isRequired: false,
      ),
      WebMcpInputField(
        key: 'b',
        shape: WebMcpInputShape.boolean,
        isRequired: false,
      ),
      WebMcpInputField(
        key: 'i',
        shape: WebMcpInputShape.safeInteger,
        isRequired: false,
      ),
      WebMcpInputField(
        key: 'd',
        shape: WebMcpInputShape.finiteDouble,
        isRequired: false,
      ),
      WebMcpInputField(
        key: 'e',
        shape: WebMcpInputShape.enumeration,
        isRequired: false,
        allowedNames: <String>['one'],
      ),
      WebMcpInputField(
        key: 'l',
        shape: WebMcpInputShape.list,
        isRequired: false,
        child: WebMcpInputField(key: 'item', shape: WebMcpInputShape.string),
      ),
      WebMcpInputField(
        key: 'm',
        shape: WebMcpInputShape.map,
        isRequired: false,
        child: WebMcpInputField(key: 'value', shape: WebMcpInputShape.string),
      ),
      WebMcpInputField(
        key: 'cl',
        shape: WebMcpInputShape.list,
        isRequired: false,
      ),
      WebMcpInputField(
        key: 'cm',
        shape: WebMcpInputShape.map,
        isRequired: false,
      ),
    ];

    setUp(() {
      WebMcp.instance.registerTool(
        WebMcpTool.withDecodedArguments(
          name: 'keyed',
          description: 'Declared fields',
          fields: fields,
          callHandler: (WebMcpToolCall call) => call.arguments,
        ),
      );
    });

    Future<WebMcpInvalidArgumentsException> caught(
      Map<String, Object?> arguments,
    ) async {
      try {
        await WebMcp.instance.invokeTool('keyed', arguments);
      } on WebMcpInvalidArgumentsException catch (error) {
        return error;
      }
      fail('Expected an invalid-arguments exception for $arguments');
    }

    test('an undeclared key is unknown and names the caller key', () async {
      final WebMcpInvalidArgumentsException error = await caught(
        const <String, Object?>{'req': 'ok', 'surprise': 1},
      );
      expect(error.key, 'surprise');
      expect(error.reason, WebMcpDecodeFailureReason.unknown);
      expect(error.details, <String, Object?>{
        'field': 'surprise',
        'reason': 'unknown',
      });
    });

    test('a declared key is never reported as unknown', () async {
      final WebMcpInvalidArgumentsException error = await caught(
        const <String, Object?>{'req': 1},
      );
      expect(error.reason, isNot(WebMcpDecodeFailureReason.unknown));
    });

    test(
      'an absent required key is missing and names the declared key',
      () async {
        final WebMcpInvalidArgumentsException error = await caught(
          const <String, Object?>{'s': 'x'},
        );
        expect(error.key, 'req');
        expect(error.reason, WebMcpDecodeFailureReason.missing);
        expect(error.details, <String, Object?>{
          'field': 'req',
          'reason': 'missing',
        });
      },
    );

    test('an absent optional key neither throws nor is decoded', () async {
      final Object? result = await WebMcp.instance.invokeTool(
        'keyed',
        const <String, Object?>{'req': 'ok'},
      );
      expect(result, <String, Object?>{'req': 'ok'});
    });

    test('every shape rejection is type and names the top-level key', () async {
      final Map<String, Object?> rejections = <String, Object?>{
        'req': null,
        's': 5,
        'b': 'yes',
        'i': 1.5,
        'd': 'NaN',
        'e': 'two',
        'l': 'not a list',
        'm': <Object?>['not a map'],
        'cl': <Object?>[],
        'cm': <String, Object?>{},
      };
      for (final MapEntry<String, Object?> entry in rejections.entries) {
        final WebMcpInvalidArgumentsException error = await caught(
          <String, Object?>{
            if (entry.key != 'req') 'req': 'ok',
            entry.key: entry.value,
          },
        );
        expect(error.key, entry.key, reason: entry.key);
        expect(error.reason, WebMcpDecodeFailureReason.type, reason: entry.key);
        expect(error.details, <String, Object?>{
          'field': entry.key,
          'reason': 'type',
        });
      }

      final List<Object?> outOfRange = <Object?>[
        9007199254740992,
        -9007199254740992,
      ];
      for (final Object? value in outOfRange) {
        final WebMcpInvalidArgumentsException error = await caught(
          <String, Object?>{'req': 'ok', 'i': value},
        );
        expect(error.key, 'i');
        expect(error.reason, WebMcpDecodeFailureReason.type);
      }
      for (final double value in <double>[
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        final WebMcpInvalidArgumentsException error = await caught(
          <String, Object?>{'req': 'ok', 'd': value},
        );
        expect(error.key, 'd');
        expect(error.reason, WebMcpDecodeFailureReason.type);
      }
      final WebMcpInvalidArgumentsException nonStringKey = await caught(
        <String, Object?>{
          'req': 'ok',
          'm': <Object?, Object?>{1: 'value'},
        },
      );
      expect(nonStringKey.key, 'm');
      expect(nonStringKey.reason, WebMcpDecodeFailureReason.type);
    });

    test('values that satisfy each shape decode without throwing', () async {
      final Object? result = await WebMcp.instance.invokeTool(
        'keyed',
        const <String, Object?>{
          'req': 'ok',
          's': 'x',
          'b': true,
          'i': 3,
          'd': 2,
          'e': 'one',
          'l': <Object?>['a'],
          'm': <String, Object?>{'k': 'v'},
        },
      );
      expect(result, <String, Object?>{
        'req': 'ok',
        's': 'x',
        'b': true,
        'i': 3,
        'd': 2.0,
        'e': 'one',
        'l': <Object?>['a'],
        'm': <String, Object?>{'k': 'v'},
      });
    });

    test('a nested failure names the top-level key, not the child', () async {
      final WebMcpInvalidArgumentsException inList = await caught(
        const <String, Object?>{
          'req': 'ok',
          'l': <Object?>['fine', 7],
        },
      );
      expect(inList.key, 'l');
      expect(inList.key, isNot('item'));
      expect(inList.reason, WebMcpDecodeFailureReason.type);

      final WebMcpInvalidArgumentsException inMap = await caught(
        const <String, Object?>{
          'req': 'ok',
          'm': <String, Object?>{'k': 7},
        },
      );
      expect(inMap.key, 'm');
      expect(inMap.key, isNot('value'));
      expect(inMap.reason, WebMcpDecodeFailureReason.type);
    });

    test('details never carry the rejected value', () async {
      final WebMcpInvalidArgumentsException error = await caught(
        const <String, Object?>{'req': 'ok', 'i': 'distinctive-rejected'},
      );
      expect(error.details!.length, 2);
      expect(error.details.toString(), isNot(contains('distinctive')));
    });

    test('the const no-argument constructor records nothing', () {
      const WebMcpInvalidArgumentsException error =
          WebMcpInvalidArgumentsException();
      expect(error.details, isNull);
      expect(error.key, isNull);
      expect(error.reason, isNull);
      expect(error.code, 'invalidArguments');
      expect(error.retryable, isFalse);
    });

    test('the failure constructor keeps the code and retryable flag', () {
      final WebMcpInvalidArgumentsException error =
          WebMcpInvalidArgumentsException.withFailure(
            key: 'k',
            reason: WebMcpDecodeFailureReason.missing,
          );
      expect(error.code, 'invalidArguments');
      expect(error.retryable, isFalse);
    });

    test('the reason enum is closed and ordered', () {
      expect(WebMcpDecodeFailureReason.values.map((e) => e.name), <String>[
        'missing',
        'unknown',
        'type',
      ]);
    });
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
