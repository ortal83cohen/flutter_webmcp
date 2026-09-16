import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';
import 'package:webmcp_flutter_example/example_screen.dart';

import 'example_test_support.dart';

// Every test below disposes its harness via a `try`/`finally` in the test
// body rather than `addTearDown`. An `await` inside a bare `addTearDown`
// async callback under `testWidgets` does not settle here — confirmed
// empirically, `tester.runAsync` does not fix it either — even though the
// exact same await settles immediately inside the test body. See the doc
// comment on `ExampleRuntime.dispose`.
//
// `ExampleScreen` takes the runtime as a constructor argument, but the
// harness only exposes its `runtime` (and `adapter`) fields once `pump()`
// has run, and Dart evaluates constructor arguments before the call. So
// each test first pumps a placeholder through the harness (which installs
// the runtime and creates the root Navigator adapter), then pumps the real
// screen — now able to reference `harness.runtime` — inside its own
// `MaterialApp` that reuses the harness's adapter as its navigator
// observer, so the home page (and any page later pushed over it) still
// reaches page eligibility.
Future<void> _pumpHome(
  WidgetTester tester,
  ExampleRuntimeHarness harness,
) async {
  await harness.pump(tester, const SizedBox.shrink());
  await tester.pumpWidget(
    MaterialApp(
      navigatorObservers: <NavigatorObserver>[harness.adapter],
      home: ExampleScreen(runtime: harness.runtime),
    ),
  );
  for (int frame = 0; frame < 5; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

List<String> _renderedToolNames(WidgetTester tester) {
  final Iterable<Text> texts = tester.widgetList<Text>(
    find.byWidgetPredicate(
      (Widget widget) =>
          widget is Text &&
          widget.key is ValueKey<String> &&
          (widget.key! as ValueKey<String>).value.startsWith('tool.'),
    ),
  );
  return texts
      .map((Text text) => (text.key! as ValueKey<String>).value.substring(5))
      .toList();
}

String _toolLineText(WidgetTester tester, String name) {
  final Text text = tester.widget<Text>(
    find.byKey(ValueKey<String>('tool.$name')),
  );
  return text.data!;
}

void main() {
  installExampleSessionDiscipline();

  const List<String> expectedTwelveNames = <String>[
    'example.app.observe',
    'example.counter.increment',
    'example.counter.read',
    'example.home.page.act',
    'example.home.page.read',
    'example.screen.describe',
    'example.screen.increment',
    'example.source.counter.add',
    'example.source.counter.read',
    'example.source.counter.reset',
    'example.tasks.create',
    'example.tasks.list',
  ];

  testWidgets(
    'the rendered tool list holds exactly the twelve expected names in '
    'ascending order',
    (WidgetTester tester) async {
      final ExampleRuntimeHarness harness = ExampleRuntimeHarness();
      try {
        await _pumpHome(tester, harness);

        expect(_renderedToolNames(tester), expectedTwelveNames);
      } finally {
        await harness.dispose();
      }
    },
  );

  testWidgets(
    'the tool-line marker format is applied correctly for a read-only, a '
    'consequential-and-schema-carrying, and an unmarked tool',
    (WidgetTester tester) async {
      final ExampleRuntimeHarness harness = ExampleRuntimeHarness();
      try {
        await _pumpHome(tester, harness);

        final String readOnlyLine = _toolLineText(
          tester,
          'example.source.counter.read',
        );
        expect(readOnlyLine, startsWith('example.source.counter.read'));
        expect(readOnlyLine, contains('[ro]'));
        expect(readOnlyLine, isNot(contains('[cq]')));

        final String addLine = _toolLineText(
          tester,
          'example.source.counter.add',
        );
        expect(addLine, startsWith('example.source.counter.add'));
        expect(addLine, contains('[cq]'));
        expect(addLine, contains('[schema]'));

        final String bareLine = _toolLineText(tester, 'example.counter.read');
        expect(bareLine, 'example.counter.read');
        expect(bareLine, isNot(contains('[ro]')));
      } finally {
        await harness.dispose();
      }
    },
  );

  testWidgets(
    'the owned-name and skipped-name lists are both populated correctly',
    (WidgetTester tester) async {
      final ExampleRuntimeHarness harness = ExampleRuntimeHarness();
      try {
        await _pumpHome(tester, harness);

        final Text owned = tester.widget<Text>(
          find.byKey(const ValueKey<String>('ownedNames')),
        );
        expect(owned.data, contains('example.screen.describe'));
        expect(owned.data, contains('example.screen.increment'));
        expect(owned.data, isNot(contains('example.counter.read')));

        final Text skipped = tester.widget<Text>(
          find.byKey(const ValueKey<String>('skippedNames')),
        );
        expect(skipped.data, contains('example.counter.read'));
      } finally {
        await harness.dispose();
      }
    },
  );

  testWidgets('the positive scope lookup succeeds', (
    WidgetTester tester,
  ) async {
    final ExampleRuntimeHarness harness = ExampleRuntimeHarness();
    try {
      await _pumpHome(tester, harness);

      final Text lookup = tester.widget<Text>(
        find.byKey(const ValueKey<String>('scopeLookup')),
      );
      expect(lookup.data, isNot(contains('no scope')));
      expect(lookup.data, contains('_ExampleScreenState'));
    } finally {
      await harness.dispose();
    }
  });

  testWidgets('a successful direct home-page read via the read button, and an '
      'invalid-argument rejection with a bad argument', (
    WidgetTester tester,
  ) async {
    final ExampleRuntimeHarness harness = ExampleRuntimeHarness();
    try {
      await _pumpHome(tester, harness);

      final Finder readButton = find.widgetWithText(
        ElevatedButton,
        'Read home page',
      );
      await tester.ensureVisible(readButton);
      await tester.pump();
      await tester.tap(readButton);
      await tester.pump();

      final Text result = tester.widget<Text>(
        find.byKey(const ValueKey<String>('homeReadResult')),
      );
      expect(result.data, contains('ok: true'));
      final RegExp nodesPattern = RegExp(r'nodes: (\d+)');
      final RegExpMatch? match = nodesPattern.firstMatch(result.data!);
      expect(match, isNotNull);
      expect(int.parse(match!.group(1)!), greaterThanOrEqualTo(1));

      final Map<String, Object?> invalid = await WebMcp.instance.invokeTool(
        'example.home.page.read',
        const <String, Object?>{'unknownKey': true},
      ) as Map<String, Object?>;
      expect(invalid['ok'], isFalse);
      expect(invalid['code'], 'invalidArguments');
    } finally {
      await harness.dispose();
    }
  });

  testWidgets(
    'a pushed page endpoints appear and disappear across a push and a pop '
    'while the screen-owned names remain registered throughout, and a '
    'covered-page read fails while the endpoint stays registered',
    (WidgetTester tester) async {
      final ExampleRuntimeHarness harness = ExampleRuntimeHarness();
      try {
        await _pumpHome(tester, harness);

        List<String> toolNames() =>
            WebMcp.instance.tools.map((WebMcpTool tool) => tool.name).toList();

        expect(toolNames(), contains('example.screen.describe'));
        expect(toolNames(), contains('example.screen.increment'));
        expect(toolNames(), isNot(contains('example.details.page.read')));
        expect(toolNames(), isNot(contains('example.details.page.act')));

        final Finder openDetails = find.widgetWithText(
          ElevatedButton,
          'Open details',
        );
        await tester.ensureVisible(openDetails);
        await tester.pump();
        await tester.tap(openDetails);
        await tester.pumpAndSettle();
        for (int frame = 0; frame < 5; frame++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        expect(toolNames(), contains('example.details.page.read'));
        expect(toolNames(), contains('example.details.page.act'));
        expect(toolNames(), contains('example.screen.describe'));
        expect(toolNames(), contains('example.screen.increment'));

        final Map<String, Object?> coveredRead =
            await WebMcp.instance.invokeTool(
              'example.home.page.read',
              const <String, Object?>{},
            ) as Map<String, Object?>;
        expect(coveredRead['ok'], isFalse);
        expect(toolNames(), contains('example.home.page.read'));

        final Finder returnHome = find.widgetWithText(
          ElevatedButton,
          'Return home',
        );
        await tester.tap(returnHome);
        await tester.pumpAndSettle();
        for (int frame = 0; frame < 5; frame++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        expect(toolNames(), isNot(contains('example.details.page.read')));
        expect(toolNames(), isNot(contains('example.details.page.act')));
        expect(toolNames(), contains('example.screen.describe'));
        expect(toolNames(), contains('example.screen.increment'));

        final Map<String, Object?> restoredRead =
            await WebMcp.instance.invokeTool(
              'example.home.page.read',
              const <String, Object?>{},
            ) as Map<String, Object?>;
        expect(restoredRead['ok'], isTrue);
      } finally {
        await harness.dispose();
      }
    },
  );
}
