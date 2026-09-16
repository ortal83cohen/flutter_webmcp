import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:webmcp_flutter_example/example_diagnostics_screen.dart';
import 'package:webmcp_flutter_example/example_runtime.dart';

import 'example_test_support.dart';

// Every test below disposes its harness via a `try`/`finally` in the test
// body rather than `addTearDown`. An `await` inside a bare `addTearDown`
// async callback under `testWidgets` does not settle here — confirmed
// empirically, `tester.runAsync` does not fix it either — even though the
// exact same await settles immediately inside the test body. See the doc
// comment on `ExampleRuntime.dispose`.
//
// `ExampleDiagnosticsScreen` takes the runtime as a constructor argument,
// but the harness only exposes its `runtime` field once `pump()` has run,
// and Dart evaluates constructor arguments before the call. So each test
// first pumps a placeholder through the harness (which installs the
// runtime and reaches page eligibility for the rest of the application),
// then pumps the real screen — now able to reference `harness.runtime` —
// directly over it. `ExampleDiagnosticsScreen` needs no navigator adapter
// of its own, so the swap is safe.
Future<void> _pumpDiagnostics(
  WidgetTester tester,
  ExampleRuntimeHarness harness,
) async {
  await harness.pump(tester, const SizedBox.shrink());
  await tester.pumpWidget(
    MaterialApp(home: ExampleDiagnosticsScreen(runtime: harness.runtime)),
  );
  await tester.pump();
}

void main() {
  installExampleSessionDiscipline();

  Finder publisherRows() => find.byWidgetPredicate(
    (Widget widget) =>
        widget is Text &&
        widget.key is ValueKey<String> &&
        (widget.key! as ValueKey<String>).value.startsWith('publisher.'),
  );

  Finder sessionRows() => find.byWidgetPredicate(
    (Widget widget) =>
        widget is Text &&
        widget.key is ValueKey<String> &&
        (widget.key! as ValueKey<String>).value.startsWith('session.'),
  );

  testWidgets(
    'the publisher section renders exactly one row per diagnostic-map key '
    'with no duplicated capability row',
    (WidgetTester tester) async {
      final ExampleRuntimeHarness harness = ExampleRuntimeHarness();
      try {
        await _pumpDiagnostics(tester, harness);

        final Map<String, Object> diagnosticMap = harness
            .runtime
            .publisher
            .status
            .toDiagnosticMap();

        expect(publisherRows(), findsNWidgets(diagnosticMap.length));

        for (final String capabilityKey in <String>[
          'registrationSignalCleanup',
          'cancelBeforeDispatch',
          'invocationCancellationAfterCallbackStart',
          'positiveWait',
        ]) {
          final Finder matches = find.byWidgetPredicate(
            (Widget widget) =>
                widget is Text &&
                widget.key == ValueKey<String>('publisher.$capabilityKey'),
          );
          expect(
            matches,
            findsOneWidget,
            reason: 'capability key $capabilityKey must appear exactly once',
          );
        }
      } finally {
        await harness.dispose();
      }
    },
  );

  testWidgets('an empty reason-code list renders the literal text none', (
    WidgetTester tester,
  ) async {
    // A publisher that has never attached reports no failure reason
    // codes at all (an empty set, not merely a set without failures),
    // which is the case this test exercises: under the Flutter test
    // runner the browser boundary is never detected, so any *attached*
    // publisher always carries the `browserUnavailable` reason. An
    // uninstalled runtime's publisher therefore stands in for the "no
    // failure reason codes" case the criterion describes.
    final ExampleRuntime runtime = ExampleRuntime();
    try {
      expect(runtime.publisher.status.reasonCodes, isEmpty);

      await tester.pumpWidget(
        MaterialApp(home: ExampleDiagnosticsScreen(runtime: runtime)),
      );
      await tester.pump();

      final Text row = tester.widget<Text>(
        find.byKey(const ValueKey<String>('publisher.reasonCodes')),
      );
      expect(row.data, 'publisher.reasonCodes: none');
      expect(row.data, isNotEmpty);
    } finally {
      await runtime.dispose();
    }
  });

  testWidgets('exactly nine session rows are rendered with no tenth', (
    WidgetTester tester,
  ) async {
    final ExampleRuntimeHarness harness = ExampleRuntimeHarness();
    try {
      await _pumpDiagnostics(tester, harness);

      expect(sessionRows(), findsNWidgets(9));

      const List<String> expectedNames = <String>[
        'session.isAttached',
        'session.ownsObserveTool',
        'session.appMount',
        'session.liveScopeCount',
        'session.navigatorAdapterCount',
        'session.routeEvidenceReady',
        'session.retainedEventCount',
        'session.retainedOperationCount',
        'session.outstandingExecutionCount',
      ];
      for (final String name in expectedNames) {
        expect(find.byKey(ValueKey<String>(name)), findsOneWidget);
      }
      expect(
        find.byKey(const ValueKey<String>('session.tenthGetter')),
        findsNothing,
      );
    } finally {
      await harness.dispose();
    }
  });

  testWidgets(
    'a tap on the plain-observe button shows a successful response with a '
    'non-empty cursor',
    (WidgetTester tester) async {
      final ExampleRuntimeHarness harness = ExampleRuntimeHarness();
      try {
        await _pumpDiagnostics(tester, harness);

        final Finder observeButton = find.widgetWithText(
          ElevatedButton,
          'Observe',
        );
        await tester.ensureVisible(observeButton);
        await tester.pump();
        await tester.tap(observeButton);
        await tester.pump();

        final Text result = tester.widget<Text>(
          find.byKey(const ValueKey<String>('observeResult')),
        );
        expect(result.data, contains('ok: true'));
        final RegExp cursorPattern = RegExp(r'cursor: (\S+)');
        final RegExpMatch? match = cursorPattern.firstMatch(result.data!);
        expect(match, isNotNull);
        expect(match!.group(1), isNotEmpty);
      } finally {
        await harness.dispose();
      }
    },
  );

  testWidgets(
    'a tap on the positive-wait button shows the unsupported-wait code and '
    'both wait-capability fields',
    (WidgetTester tester) async {
      final ExampleRuntimeHarness harness = ExampleRuntimeHarness();
      try {
        await _pumpDiagnostics(tester, harness);

        final Finder observeWaitButton = find.widgetWithText(
          ElevatedButton,
          'Observe with wait',
        );
        await tester.ensureVisible(observeWaitButton);
        await tester.pump();
        await tester.tap(observeWaitButton);
        await tester.pump();

        final Text result = tester.widget<Text>(
          find.byKey(const ValueKey<String>('observeWaitResult')),
        );
        expect(result.data, contains('ok: false'));
        expect(result.data, contains('code: unsupportedWait'));
        expect(
          result.data,
          contains('waitCapability.positiveWaitSupported: false'),
        );
        expect(result.data, contains('waitCapability.maxWaitMs: 0'));
      } finally {
        await harness.dispose();
      }
    },
  );
}
