// Shared test support for the example's widget tests.
//
// Not a `_test.dart` file, so the test runner does not treat it as its own
// suite. Every test file that touches a page — directly or through
// [ExampleRuntimeHarness] — must call [installExampleSessionDiscipline],
// because the application session is a process-wide static and attaching a
// second session while another is still attached returns a resource-limit
// envelope instead of attaching.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';

import 'package:webmcp_flutter_example/example_runtime.dart';

/// Builds an [ExampleRuntime], installs it, and pumps a [MaterialApp] whose
/// sole navigator observer is the runtime's root Navigator adapter, so a
/// [WebMcpPage] inside [home] reaches page eligibility.
///
/// Mirrors the shape of the harness in `test/page/webmcp_page_test.dart`:
/// an attached session, a root Navigator adapter, a [MaterialApp] built
/// through [WidgetTester.pumpWidget], and five pumped frames of one hundred
/// milliseconds each.
final class ExampleRuntimeHarness {
  /// The runtime this harness constructed and installed.
  late final ExampleRuntime runtime;

  /// The root Navigator adapter this harness created from [runtime].
  late final WebMcpNavigatorAdapter adapter;

  bool _pumped = false;

  /// Constructs the runtime, installs it, builds the root Navigator adapter
  /// and pumps [home] inside a [MaterialApp] using that adapter as its only
  /// navigator observer, then pumps five frames of one hundred milliseconds
  /// each to reach page eligibility.
  Future<void> pump(WidgetTester tester, Widget home) async {
    if (_pumped) {
      throw StateError('ExampleRuntimeHarness can only be pumped once.');
    }
    _pumped = true;
    runtime = ExampleRuntime();
    await runtime.install();
    adapter = runtime.createRootNavigatorAdapter();
    await tester.pumpWidget(
      MaterialApp(navigatorObservers: <NavigatorObserver>[adapter], home: home),
    );
    for (int frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Disposes the adapter and the runtime.
  ///
  /// Callers must `await` this directly inside the test body, inside a
  /// `try`/`finally` around the pumped widget — never from a bare
  /// `addTearDown` async callback. The awaited disposal (through
  /// [ExampleRuntime.dispose], which awaits [WebMcpNativePublisher.detach])
  /// does not settle when invoked that way under `testWidgets`, even though
  /// `tester.runAsync` does not fix it either; the same await settles
  /// immediately when made directly in the test body.
  Future<void> dispose() async {
    if (!_pumped) {
      return;
    }
    adapter.dispose();
    await runtime.dispose();
  }
}

/// Installs the shared setUp/tearDown discipline the process-wide session
/// static requires.
///
/// `setUp` resets the registry; `tearDown` detaches whatever
/// [WebMcpAppSession] is currently active and then resets the registry
/// again. Every test file that attaches a session — directly or through
/// [ExampleRuntimeHarness] — must call this exactly once, and must not
/// declare its own session handling.
void installExampleSessionDiscipline() {
  setUp(() {
    WebMcp.instance.reset();
  });
  tearDown(() {
    WebMcpAppSession.activeSession?.detach();
    WebMcp.instance.reset();
  });
}

/// Invokes `<pageId>.page.read` through [WebMcp.instance.invokeTool], with
/// an optional [query], and returns the decoded response.
Future<Map<String, Object?>> readExamplePage(
  String pageId, {
  String? query,
}) async {
  final Object? result = await WebMcp.instance.invokeTool(
    '$pageId.page.read',
    <String, Object?>{'query': ?query},
  );
  return result as Map<String, Object?>;
}

/// Locates the first node in a decoded read response whose `label` field
/// exactly matches [label]. Returns `null` if no such node is found.
Map<String, Object?>? findExampleNodeByLabel(
  Map<String, Object?> readResponse,
  String label,
) {
  final Object? nodes = readResponse['nodes'];
  if (nodes is! List<Object?>) {
    return null;
  }
  for (final Object? node in nodes) {
    if (node is Map<String, Object?> && node['label'] == label) {
      return node;
    }
  }
  return null;
}
