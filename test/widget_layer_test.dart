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
        const _Screen(
          actionName: 'disabled.child',
          actionResult: 'invoked',
          child: ElevatedButton(onPressed: null, child: Text('Disabled')),
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

  testWidgets('invalid action names fail loudly', (WidgetTester tester) async {
    await tester.pumpWidget(_host(const _Screen(actionName: 'invalid name')));
    expect(tester.takeException(), isA<WebMcpInvalidToolNameException>());
    expect(WebMcp.instance.tools, isEmpty);
  });
}
