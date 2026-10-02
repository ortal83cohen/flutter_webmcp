import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';

WebMcpTool _tool(String name, Object? result) => WebMcpTool(
  name: name,
  description: 'Tool $name',
  handler: (Map<String, Object?> arguments) => result,
);

final class _Screen extends StatefulWidget {
  const _Screen({
    super.key,
    this.screenTool,
    this.actionName,
    this.actionResult = 'action',
    this.actionHandler,
    this.child,
  });

  final String? screenTool;
  final String? actionName;
  final Object? actionResult;
  final WebMcpToolHandler? actionHandler;
  final Widget? child;

  @override
  State<_Screen> createState() => _ScreenState();
}

final class _ScreenState extends State<_Screen> with WebMcpScreen<_Screen> {
  @override
  void registerWebMcpTools() {
    final String? name = widget.screenTool;
    if (name != null) {
      mcpScope.addTool(_tool(name, 'screen'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? name = widget.actionName;
    if (name == null) {
      return widget.child ?? const SizedBox();
    }
    final Widget child =
        widget.child ?? GestureDetector(onTap: () {}, child: const Text('Tap'));
    return WebMcpAction(
      name: name,
      description: 'Action $name',
      onInvoke:
          widget.actionHandler ??
          (Map<String, Object?> arguments) => widget.actionResult,
      child: child,
    );
  }
}

Widget _host(Widget child) =>
    Directionality(textDirection: TextDirection.ltr, child: child);

void main() {
  setUp(WebMcp.instance.reset);

  testWidgets('screen mixin registers while mounted and closes on dispose', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(const _Screen(screenTool: 'screen.tool')));
    expect(WebMcp.instance.tools.single.name, 'screen.tool');

    await tester.pumpWidget(_host(const SizedBox()));
    expect(WebMcp.instance.tools, isEmpty);
  });

  testWidgets('action registers verbatim and unregisters independently', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(const _Screen(actionName: 'literal.name')));
    expect(WebMcp.instance.tools.single.name, 'literal.name');

    await tester.pumpWidget(_host(const _Screen()));
    expect(WebMcp.instance.tools, isEmpty);
  });

  testWidgets('action returns the identical tappable child', (
    WidgetTester tester,
  ) async {
    final ValueNotifier<int> counter = ValueNotifier<int>(0);
    final Widget button = GestureDetector(
      onTap: () => counter.value++,
      child: const Text('Original'),
    );
    final WebMcpAction action = WebMcpAction(
      name: 'tap.action',
      description: 'Tap action',
      onInvoke: (Map<String, Object?> arguments) => null,
      child: button,
    );
    await tester.pumpWidget(_host(_Screen(child: action)));

    final Element actionElement = tester.element(find.byWidget(action));
    Element? directChild;
    actionElement.visitChildren((Element element) => directChild = element);
    expect(directChild?.widget, same(button));
    await tester.tap(find.byWidget(button));
    expect(counter.value, 1);
  });

  testWidgets('action forwards invocation to the latest callback', (
    WidgetTester tester,
  ) async {
    Object? firstHandler(Map<String, Object?> arguments) => 'first';
    Object? secondHandler(Map<String, Object?> arguments) => 'second';
    await tester.pumpWidget(
      _host(_Screen(actionName: 'changing', actionHandler: firstHandler)),
    );
    expect(await WebMcp.instance.invokeTool('changing', const {}), 'first');

    await tester.pumpWidget(
      _host(_Screen(actionName: 'changing', actionHandler: secondHandler)),
    );
    expect(await WebMcp.instance.invokeTool('changing', const {}), 'second');
  });

  testWidgets('disabled child does not disable direct tool invocation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        _Screen(
          actionName: 'disabled.child',
          actionResult: 'invoked',
          child: GestureDetector(onTap: null, child: const Text('Disabled')),
        ),
      ),
    );

    expect(
      await WebMcp.instance.invokeTool('disabled.child', const {}),
      'invoked',
    );
  });

  testWidgets(
    'action keeps its mounted descriptor identity until replacement',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const _Screen(actionName: 'original', actionResult: 'first')),
      );
      await tester.pumpWidget(
        _host(const _Screen(actionName: 'renamed', actionResult: 'latest')),
      );
      expect(WebMcp.instance.tools.single.name, 'original');
      expect(await WebMcp.instance.invokeTool('original', const {}), 'latest');

      await tester.pumpWidget(_host(const _Screen()));
      expect(WebMcp.instance.tools, isEmpty);
    },
  );

  testWidgets('action copies its input schema', (WidgetTester tester) async {
    final Map<String, Object?> schema = <String, Object?>{'type': 'object'};
    await tester.pumpWidget(
      _host(
        _Screen(
          child: WebMcpAction(
            name: 'schema.action',
            description: 'Schema action',
            inputSchema: schema,
            onInvoke: (Map<String, Object?> arguments) => null,
            child: const SizedBox(),
          ),
        ),
      ),
    );
    schema['type'] = 'changed';
    expect(WebMcp.instance.tools.single.inputSchema['type'], 'object');
    expect(
      () => WebMcp.instance.tools.single.inputSchema['new'] = true,
      throwsUnsupportedError,
    );
  });

  testWidgets(
    'action without a screen reports the tool and registers nothing',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          WebMcpAction(
            name: 'orphan',
            description: 'Orphan action',
            onInvoke: (Map<String, Object?> arguments) => null,
            child: const SizedBox(),
          ),
        ),
      );
      final Object? error = tester.takeException();
      expect(error, isA<WebMcpScopeMissingException>());
      expect(error.toString(), contains('orphan'));
      expect(WebMcp.instance.tools, isEmpty);
    },
  );

  testWidgets('duplicate actions preserve the first owner', (
    WidgetTester tester,
  ) async {
    const Key firstKey = Key('first');
    const Key secondKey = Key('second');
    await tester.pumpWidget(
      _host(
        const Column(
          children: <Widget>[
            _Screen(key: firstKey, actionName: 'shared', actionResult: 'first'),
            _Screen(
              key: secondKey,
              actionName: 'shared',
              actionResult: 'second',
            ),
          ],
        ),
      ),
    );
    expect(WebMcp.instance.tools, hasLength(1));
    expect(await WebMcp.instance.invokeTool('shared', const {}), 'first');
    final _ScreenState second = tester.state(find.byKey(secondKey));
    expect(second.mcpScope.skippedNames, <String>['shared']);

    await tester.pumpWidget(
      _host(
        const Column(
          children: <Widget>[
            _Screen(key: firstKey, actionName: 'shared', actionResult: 'first'),
          ],
        ),
      ),
    );
    expect(await WebMcp.instance.invokeTool('shared', const {}), 'first');
  });

  testWidgets('onCall and onInvoke each mount one callback', (
    WidgetTester tester,
  ) async {
    WebMcpToolCall? seen;
    await tester.pumpWidget(
      _host(
        _Screen(
          child: WebMcpAction(
            name: 'call.only',
            description: 'Call only',
            onCall: (WebMcpToolCall call) {
              seen = call;
              return 'called';
            },
            child: const SizedBox(),
          ),
        ),
      ),
    );
    final WebMcpTool callTool = WebMcp.instance.tools.single;
    expect(callTool.callHandler, isNotNull);
    expect(callTool.handler, isNull);
    expect(
      await WebMcp.instance.invokeTool('call.only', const {'n': 1}),
      'called',
    );
    expect(seen!.arguments, <String, Object?>{'n': 1});
    expect(seen!.executionSignal, isNull);

    await tester.pumpWidget(_host(const SizedBox()));
    await tester.pumpWidget(
      _host(
        _Screen(
          child: WebMcpAction(
            name: 'invoke.only',
            description: 'Invoke only',
            onInvoke: (Map<String, Object?> arguments) => arguments['n'],
            child: const SizedBox(),
          ),
        ),
      ),
    );
    final WebMcpTool invokeTool = WebMcp.instance.tools.single;
    expect(invokeTool.handler, isNotNull);
    expect(invokeTool.callHandler, isNull);
    expect(await WebMcp.instance.invokeTool('invoke.only', const {'n': 2}), 2);
  });

  test('both widget callbacks throw and register nothing', () {
    expect(
      () => WebMcpAction(
        name: 'both.callbacks',
        description: 'Invalid',
        onInvoke: (Map<String, Object?> arguments) => null,
        onCall: (WebMcpToolCall call) => null,
        child: const SizedBox(),
      ),
      throwsArgumentError,
    );
    expect(WebMcp.instance.tools, isEmpty);
  });

  testWidgets('first mount keeps the published title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        _Screen(
          child: WebMcpAction(
            name: 'titled.action',
            description: 'Title',
            title: 'First title',
            onInvoke: (Map<String, Object?> arguments) => null,
            child: const SizedBox(),
          ),
        ),
      ),
    );
    expect(WebMcp.instance.tools.single.title, 'First title');
    await tester.pumpWidget(
      _host(
        _Screen(
          child: WebMcpAction(
            name: 'titled.action',
            description: 'Title',
            title: 'Second title',
            onInvoke: (Map<String, Object?> arguments) => null,
            child: const SizedBox(),
          ),
        ),
      ),
    );
    expect(WebMcp.instance.tools.single.title, 'First title');
  });

  testWidgets('invalid action names fail loudly', (WidgetTester tester) async {
    await tester.pumpWidget(_host(const _Screen(actionName: 'invalid name')));
    expect(tester.takeException(), isA<WebMcpInvalidToolNameException>());
    expect(WebMcp.instance.tools, isEmpty);
  });

  group('action with a field list', () {
    const List<WebMcpInputField> nameFields = <WebMcpInputField>[
      WebMcpInputField(key: 'name', shape: WebMcpInputShape.string),
    ];
    const List<WebMcpInputField> otherFields = <WebMcpInputField>[
      WebMcpInputField(key: 'other', shape: WebMcpInputShape.string),
    ];

    Widget fieldAction({
      List<WebMcpInputField>? fields = nameFields,
      required WebMcpToolCallHandler onCall,
      Widget child = const SizedBox(),
      Map<String, Object?> inputSchema = const <String, Object?>{},
    }) => _host(
      _Screen(
        child: WebMcpAction(
          name: 'field.action',
          description: 'Field action',
          inputSchema: inputSchema,
          fields: fields,
          onCall: onCall,
          child: child,
        ),
      ),
    );

    testWidgets('decodes before the callback and rejects undeclared keys', (
      WidgetTester tester,
    ) async {
      final List<Map<String, Object?>> received = <Map<String, Object?>>[];
      await tester.pumpWidget(
        fieldAction(
          onCall: (WebMcpToolCall call) {
            received.add(call.arguments);
            return 'ok';
          },
        ),
      );

      expect(
        await WebMcp.instance.invokeTool('field.action', const {'name': 'a'}),
        'ok',
      );
      expect(received, hasLength(1));
      expect(received.single, <String, Object?>{'name': 'a'});

      await expectLater(
        WebMcp.instance.invokeTool('field.action', const {
          'name': 'a',
          'extra': 1,
        }),
        throwsA(isA<WebMcpInvalidArgumentsException>()),
      );
      expect(received, hasLength(1));
    });

    test('field list with the one-argument callback throws', () {
      expect(
        () => WebMcpAction(
          name: 'bad.pairing',
          description: 'Invalid',
          fields: nameFields,
          onInvoke: (Map<String, Object?> arguments) => null,
          child: const SizedBox(),
        ),
        throwsArgumentError,
      );
      // An empty list is still non-null and is rejected the same way.
      expect(
        () => WebMcpAction(
          name: 'bad.pairing',
          description: 'Invalid',
          fields: const <WebMcpInputField>[],
          onInvoke: (Map<String, Object?> arguments) => null,
          child: const SizedBox(),
        ),
        throwsArgumentError,
      );
      expect(WebMcp.instance.tools, isEmpty);
    });

    test('exactly-one-callback error still reports first', () {
      Matcher exactlyOne() => throwsA(
        isA<ArgumentError>().having(
          (ArgumentError e) => e.message,
          'message',
          'WebMcpAction requires exactly one of onInvoke or onCall.',
        ),
      );
      expect(
        () => WebMcpAction(
          name: 'no.callbacks',
          description: 'Invalid',
          fields: nameFields,
          child: const SizedBox(),
        ),
        exactlyOne(),
      );
      expect(
        () => WebMcpAction(
          name: 'both.callbacks',
          description: 'Invalid',
          fields: nameFields,
          onInvoke: (Map<String, Object?> arguments) => null,
          onCall: (WebMcpToolCall call) => null,
          child: const SizedBox(),
        ),
        exactlyOne(),
      );
      expect(
        () => WebMcpAction(
          name: 'no.callbacks',
          description: 'Invalid',
          child: const SizedBox(),
        ),
        exactlyOne(),
      );
    });

    test('either callback alone constructs without a field list', () {
      expect(
        WebMcpAction(
          name: 'invoke.alone',
          description: 'Valid',
          onInvoke: (Map<String, Object?> arguments) => null,
          child: const SizedBox(),
        ).fields,
        isNull,
      );
      expect(
        WebMcpAction(
          name: 'call.alone',
          description: 'Valid',
          onCall: (WebMcpToolCall call) => null,
          child: const SizedBox(),
        ).fields,
        isNull,
      );
      expect(
        WebMcpAction(
          name: 'call.fields',
          description: 'Valid',
          fields: nameFields,
          onCall: (WebMcpToolCall call) => null,
          child: const SizedBox(),
        ).fields,
        nameFields,
      );
    });

    testWidgets('keeps the field list captured at the first mount', (
      WidgetTester tester,
    ) async {
      int calls = 0;
      Object? onCall(WebMcpToolCall call) {
        calls++;
        return call.arguments;
      }

      await tester.pumpWidget(fieldAction(onCall: onCall));
      await tester.pumpWidget(fieldAction(fields: otherFields, onCall: onCall));

      expect(
        await WebMcp.instance.invokeTool('field.action', const {'name': 'a'}),
        <String, Object?>{'name': 'a'},
      );
      expect(calls, 1);
      await expectLater(
        WebMcp.instance.invokeTool('field.action', const {'other': 'b'}),
        throwsA(isA<WebMcpInvalidArgumentsException>()),
      );
      expect(calls, 1);
    });

    testWidgets('dispatches a successful decode to the newest callback', (
      WidgetTester tester,
    ) async {
      int firstCalls = 0;
      int secondCalls = 0;
      await tester.pumpWidget(
        fieldAction(
          onCall: (WebMcpToolCall call) {
            firstCalls++;
            return 'first';
          },
        ),
      );
      await tester.pumpWidget(
        fieldAction(
          onCall: (WebMcpToolCall call) {
            secondCalls++;
            return 'second';
          },
        ),
      );

      expect(
        await WebMcp.instance.invokeTool('field.action', const {'name': 'a'}),
        'second',
      );
      expect(secondCalls, 1);
      expect(firstCalls, 0);
    });

    testWidgets('publishes the schema derived from the field list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        fieldAction(
          fields: const <WebMcpInputField>[
            WebMcpInputField(key: 'name', shape: WebMcpInputShape.string),
            WebMcpInputField(
              key: 'count',
              shape: WebMcpInputShape.safeInteger,
              isRequired: false,
            ),
          ],
          onCall: (WebMcpToolCall call) => null,
        ),
      );

      final Map<String, Object?> schema =
          WebMcp.instance.tools.single.inputSchema;
      expect(schema['type'], 'object');
      final Map<Object?, Object?> properties =
          schema['properties']! as Map<Object?, Object?>;
      expect(properties.keys, containsAll(<String>['name', 'count']));
      expect(properties, hasLength(2));
    });

    testWidgets('an empty field list still registers and derives a schema', (
      WidgetTester tester,
    ) async {
      int calls = 0;
      await tester.pumpWidget(
        fieldAction(
          fields: const <WebMcpInputField>[],
          onCall: (WebMcpToolCall call) {
            calls++;
            return 'ok';
          },
        ),
      );

      expect(WebMcp.instance.tools.single.inputSchema['type'], 'object');
      expect(await WebMcp.instance.invokeTool('field.action', const {}), 'ok');
      await expectLater(
        WebMcp.instance.invokeTool('field.action', const {'extra': 1}),
        throwsA(isA<WebMcpInvalidArgumentsException>()),
      );
      expect(calls, 1);
    });

    testWidgets('an explicit input schema is kept unchanged', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        fieldAction(
          inputSchema: const <String, Object?>{'type': 'object', 'x': 1},
          onCall: (WebMcpToolCall call) => null,
        ),
      );
      expect(WebMcp.instance.tools.single.inputSchema, <String, Object?>{
        'type': 'object',
        'x': 1,
      });
    });

    testWidgets('renders the child unchanged and survives disabled children', (
      WidgetTester tester,
    ) async {
      int calls = 0;
      final Widget disabled = GestureDetector(
        onTap: null,
        child: const Text('Disabled'),
      );
      final WebMcpAction action = WebMcpAction(
        name: 'field.action',
        description: 'Field action',
        fields: nameFields,
        onCall: (WebMcpToolCall call) {
          calls++;
          return 'ran';
        },
        child: Visibility(visible: false, child: disabled),
      );
      await tester.pumpWidget(_host(_Screen(child: action)));

      final Element actionElement = tester.element(find.byWidget(action));
      final List<Widget> directChildren = <Widget>[];
      actionElement.visitChildren(
        (Element element) => directChildren.add(element.widget),
      );
      expect(directChildren, hasLength(1));
      expect(directChildren.single, same(action.child));

      expect(
        await WebMcp.instance.invokeTool('field.action', const {'name': 'a'}),
        'ran',
      );
      expect(calls, 1);

      await tester.pumpWidget(_host(const SizedBox()));
      expect(WebMcp.instance.tools, isEmpty);
    });

    testWidgets('a state that does not own the name leaves it on unmount', (
      WidgetTester tester,
    ) async {
      const Key firstKey = Key('first');
      const Key secondKey = Key('second');
      Widget screen(Key key, String result) => _Screen(
        key: key,
        child: WebMcpAction(
          name: 'field.action',
          description: 'Field action',
          fields: nameFields,
          onCall: (WebMcpToolCall call) => result,
          child: const SizedBox(),
        ),
      );
      await tester.pumpWidget(
        _host(
          Column(
            children: <Widget>[
              screen(firstKey, 'first'),
              screen(secondKey, 'second'),
            ],
          ),
        ),
      );
      expect(WebMcp.instance.tools, hasLength(1));

      // Unmounting the non-owning duplicate must keep the owner's tool.
      await tester.pumpWidget(
        _host(Column(children: <Widget>[screen(firstKey, 'first')])),
      );
      expect(
        await WebMcp.instance.invokeTool('field.action', const {'name': 'a'}),
        'first',
      );
    });
  });
}
