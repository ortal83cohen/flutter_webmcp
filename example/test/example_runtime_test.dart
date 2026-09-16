import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';

import 'package:webmcp_flutter_example/example_counter_source.dart';
import 'package:webmcp_flutter_example/example_runtime.dart';

import 'example_test_support.dart';

// Every test below disposes its runtime/harness via a `try`/`finally` in the
// test body rather than `addTearDown`. An `await` inside a bare
// `addTearDown` async callback under `testWidgets` does not settle here —
// confirmed empirically, `tester.runAsync` does not fix it either — even
// though the exact same await settles immediately inside the test body. See
// the doc comment on `ExampleRuntime.dispose`.
void main() {
  installExampleSessionDiscipline();

  testWidgets('install performs the fixed startup order', (
    WidgetTester tester,
  ) async {
    final ExampleRuntime runtime = ExampleRuntime();

    expect(WebMcp.instance.tools, isEmpty);

    await runtime.install();
    try {
      final List<String> names = runtime.registryLog.lines
          .where((String line) => line.startsWith('registered '))
          .map((String line) => line.substring('registered '.length))
          .toList(growable: false);

      // Install alone produces eight registrations: three hand-written
      // source names, two generated names, two imperative counter names and
      // the application observe endpoint. The plan's "twelve" total
      // additionally counts `example.screen.describe` and
      // `example.screen.increment`, registered when the home screen's
      // registration hook and action widget mount, and the home page's read
      // and act endpoints, registered when the home screen mounts a
      // `WebMcpPage` — none of that is produced by `install()` itself, so
      // this test asserts the eight `install()`-time registrations rather
      // than the plan's screen-mount-inclusive twelve.
      expect(names, hasLength(8));
      expect(names.first, 'example.source.counter.read');
      expect(names.last, 'example.app.observe');

      expect(
        WebMcp.instance.tools.map((WebMcpTool tool) => tool.name),
        containsAll(<String>[
          'example.source.counter.read',
          'example.source.counter.add',
          'example.source.counter.reset',
          'example.tasks.create',
          'example.tasks.list',
          'example.counter.read',
          'example.counter.increment',
          'example.app.observe',
        ]),
      );

      // A second batch registration of the hand-written source raises the
      // duplicate-tool exception, because the registry already holds those
      // three names.
      expect(
        () => WebMcp.instance.registerSource(
          ExampleCounterSource(runtime.counter),
        ),
        throwsA(isA<WebMcpDuplicateToolException>()),
      );
    } finally {
      await runtime.dispose();
    }
  });

  testWidgets('calling install twice raises a StateError', (
    WidgetTester tester,
  ) async {
    final ExampleRuntime runtime = ExampleRuntime();
    await runtime.install();
    try {
      expect(runtime.install, throwsA(isA<StateError>()));
    } finally {
      await runtime.dispose();
    }
  });

  testWidgets('the harness reaches page eligibility after five pumped frames', (
    WidgetTester tester,
  ) async {
    final ExampleRuntimeHarness harness = ExampleRuntimeHarness();
    try {
      await harness.pump(
        tester,
        WebMcpPage(
          pageId: 'probe',
          child: Semantics(
            label: 'Probe control',
            button: true,
            onTap: () {},
            child: const SizedBox(width: 20, height: 20),
          ),
        ),
      );

      expect(
        WebMcp.instance.tools.map((WebMcpTool tool) => tool.name),
        containsAll(<String>['probe.page.read', 'probe.page.act']),
      );
    } finally {
      await harness.dispose();
    }
  });

  testWidgets(
    'a second test in this file attaches without a resource-limit failure',
    (WidgetTester tester) async {
      final ExampleRuntime runtime = ExampleRuntime();
      await runtime.install();
      try {
        expect(runtime.session.isAttached, isTrue);
      } finally {
        await runtime.dispose();
      }
    },
  );
}
