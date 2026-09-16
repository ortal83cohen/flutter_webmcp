import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';
import 'package:webmcp_flutter_example/example_agent_probe.dart';
import 'package:webmcp_flutter_example/example_form_screen.dart';

import 'example_test_support.dart';

void main() {
  installExampleSessionDiscipline();

  test(
    'the form page policy differs from the default policy in all eight fields',
    () {
      final WebMcpPagePolicy policy = ExampleFormScreen.policy;
      final WebMcpPagePolicy defaults = WebMcpPagePolicy.defaults;

      expect(policy.allowLongPress, isTrue);
      expect(defaults.allowLongPress, isFalse);

      expect(policy.includeBounds, isTrue);
      expect(defaults.includeBounds, isFalse);

      expect(policy.includeNonEditableValues, isFalse);
      expect(defaults.includeNonEditableValues, isTrue);

      expect(policy.maxTextLength, 120);
      expect(defaults.maxTextLength, isNot(120));

      expect(policy.excludedSemanticsIdentifiers, <String>{
        'example.form.excluded',
      });
      expect(defaults.excludedSemanticsIdentifiers, isEmpty);

      expect(policy.sensitiveSemanticsIdentifiers, <String>{
        'example.form.secret',
      });
      expect(defaults.sensitiveSemanticsIdentifiers, isEmpty);

      expect(policy.editableValueIdentifiers, <String>{'example.form.note'});
      expect(defaults.editableValueIdentifiers, isEmpty);

      expect(policy.setTextIdentifiers, <String>{'example.form.note'});
      expect(defaults.setTextIdentifiers, isEmpty);
    },
  );

  testWidgets(
    'a read omits the excluded and sensitive subtrees, omits the non-editable '
    'value, includes bounds, and reports no coverage truncation',
    (WidgetTester tester) async {
      final ExampleRuntimeHarness harness = ExampleRuntimeHarness();
      try {
        await harness.pump(tester, const ExampleFormScreen());

        final Map<String, Object?> read = await readExamplePage(
          ExampleFormScreen.pageId,
        );
        final String encoded = jsonEncode(read);

        expect(encoded, isNot(contains('EXCLUDED-CONTENT')));
        expect(encoded, isNot(contains('SENSITIVE-VALUE')));
        expect(encoded, isNot(contains('NON-EDITABLE-VALUE')));
        expect(findExampleNodeByLabel(read, 'Excluded panel'), isNull);
        expect(findExampleNodeByLabel(read, 'Secret panel'), isNull);

        final Map<String, Object?>? status = findExampleNodeByLabel(
          read,
          'Save status',
        );
        expect(status, isNotNull);
        expect(status!.containsKey('value'), isFalse);
        expect(
          (status['actions']! as List<Object?>).cast<String>(),
          containsAll(<String>['increase', 'decrease']),
        );

        final Map<String, Object?>? note = findExampleNodeByLabel(
          read,
          'Note field',
        );
        expect(note, isNotNull);
        expect(note!.containsKey('bounds'), isTrue);
        expect(
          (note['bounds']! as Map<String, Object?>)['coordinateSpace'],
          'flutterView',
        );

        final Map<String, Object?> coverage =
            read['coverage']! as Map<String, Object?>;
        expect(coverage['truncated'], isFalse);
      } finally {
        await harness.dispose();
      }
    },
  );

  testWidgets(
    'a successful setText changes the visible note text and a too-long '
    'setText is refused with the visible text unchanged',
    (WidgetTester tester) async {
      final ExampleRuntimeHarness harness = ExampleRuntimeHarness();
      try {
        await harness.pump(tester, const ExampleFormScreen());

        Map<String, Object?> read = await readExamplePage(
          ExampleFormScreen.pageId,
        );
        Map<String, Object?> note = findExampleNodeByLabel(read, 'Note field')!;
        final String acceptedText = 'a' * 50;

        final Map<String, Object?> success = await _act(
          read,
          note,
          action: 'setText',
          requestId: 1,
          arguments: <String, Object?>{'text': acceptedText},
        );
        expect(success['ok'], isTrue);
        expect(success['dispatched'], isTrue);
        expect(success['evidence'], 'commandDispatched');

        await tester.pumpAndSettle();
        expect(find.text('Note text: $acceptedText'), findsOneWidget);

        read = await readExamplePage(ExampleFormScreen.pageId);
        note = findExampleNodeByLabel(read, 'Note field')!;
        final String tooLongText = 'b' * 121;

        final Map<String, Object?> denied = await _act(
          read,
          note,
          action: 'setText',
          requestId: 2,
          arguments: <String, Object?>{'text': tooLongText},
        );
        expect(denied['ok'], isFalse);
        expect(denied['code'], 'policyDenied');

        await tester.pumpAndSettle();
        expect(find.text('Note text: $acceptedText'), findsOneWidget);
      } finally {
        await harness.dispose();
      }
    },
  );

  testWidgets(
    'a long press is advertised on the archive node and dispatching it '
    'changes the visible archive state',
    (WidgetTester tester) async {
      final ExampleRuntimeHarness harness = ExampleRuntimeHarness();
      try {
        await harness.pump(tester, const ExampleFormScreen());

        final Map<String, Object?> read = await readExamplePage(
          ExampleFormScreen.pageId,
        );
        final Map<String, Object?> archive = findExampleNodeByLabel(
          read,
          'Archive note',
        )!;
        expect(
          (archive['actions']! as List<Object?>).cast<String>(),
          contains('longPress'),
        );

        final Map<String, Object?> receipt = await _act(
          read,
          archive,
          action: 'longPress',
          requestId: 1,
        );
        expect(receipt['ok'], isTrue);

        await tester.pumpAndSettle();
        expect(find.text('Archived'), findsOneWidget);
      } finally {
        await harness.dispose();
      }
    },
  );

  testWidgets(
    'the identical widget subtree under the default policy advertises no '
    'long press and refuses an act requesting it',
    (WidgetTester tester) async {
      final ExampleRuntimeHarness harness = ExampleRuntimeHarness();
      const String defaultPolicyPageId = 'example.form.default';
      try {
        await harness.pump(
          tester,
          Scaffold(
            body: WebMcpPage(
              pageId: defaultPolicyPageId,
              child: Semantics(
                identifier: 'example.form.default.archive',
                label: 'Archive note',
                onLongPress: () {},
                child: const SizedBox(width: 20, height: 20),
              ),
            ),
          ),
        );

        final Map<String, Object?> read = await readExamplePage(
          defaultPolicyPageId,
        );
        final Map<String, Object?> archive = findExampleNodeByLabel(
          read,
          'Archive note',
        )!;
        expect(
          (archive['actions']! as List<Object?>).cast<String>(),
          isNot(contains('longPress')),
        );
        expect(archive.containsKey('bounds'), isFalse);

        final Object? result = await WebMcp.instance.invokeTool(
          '$defaultPolicyPageId.page.act',
          <String, Object?>{
            'pageId': defaultPolicyPageId,
            'mountToken': read['mountToken'],
            'revision': read['revision'],
            'handle': archive['handle'],
            'action': 'longPress',
            'requestId': 1,
            'arguments': const <String, Object?>{},
          },
        );
        final Map<String, Object?> receipt = result as Map<String, Object?>;
        expect(receipt['ok'], isFalse);
      } finally {
        await harness.dispose();
      }
    },
  );

  testWidgets('a downward scroll dispatches successfully and changes the page '
      'revision, while an unsupported action name is refused', (
    WidgetTester tester,
  ) async {
    final ExampleRuntimeHarness harness = ExampleRuntimeHarness();
    try {
      await harness.pump(tester, const ExampleFormScreen());

      final Map<String, Object?> before = await readExamplePage(
        ExampleFormScreen.pageId,
      );
      final Map<String, Object?> history = findExampleNodeByLabel(
        before,
        'Note history',
      )!;

      final Map<String, Object?> receipt = await _act(
        before,
        history,
        action: 'scrollDown',
        requestId: 1,
      );
      expect(receipt['ok'], isTrue);

      await tester.pumpAndSettle();
      final Map<String, Object?> after = await readExamplePage(
        ExampleFormScreen.pageId,
      );
      expect(after['revision'], isNot(before['revision']));

      final Map<String, Object?> historyAfter = findExampleNodeByLabel(
        after,
        'Note history',
      )!;
      final Object? unsupportedResult = await WebMcp.instance.invokeTool(
        '${ExampleFormScreen.pageId}.page.act',
        <String, Object?>{
          'pageId': ExampleFormScreen.pageId,
          'mountToken': after['mountToken'],
          'revision': after['revision'],
          'handle': historyAfter['handle'],
          'action': 'notARealAction',
          'requestId': 2,
          'arguments': const <String, Object?>{},
        },
      );
      final Map<String, Object?> unsupportedReceipt =
          unsupportedResult as Map<String, Object?>;
      expect(unsupportedReceipt['code'], 'unsupportedAction');
    } finally {
      await harness.dispose();
    }
  });

  testWidgets(
    'a probe retry after a forced stale snapshot ends in success with a '
    'strictly higher request identifier than the failed first attempt',
    (WidgetTester tester) async {
      final ExampleRuntimeHarness harness = ExampleRuntimeHarness();
      try {
        await harness.pump(tester, const ExampleFormScreen());

        final ExampleAgentProbe probe = ExampleAgentProbe();
        final List<String> transcript = await probe.run(
          pageId: ExampleFormScreen.pageId,
          nodeLabel: 'Note field',
          action: 'setText',
          arguments: <String, Object?>{'text': 'set after retry'},
          maxAttempts: 2,
          beforeFirstAct: () => _forceContentChange(tester),
        );

        expect(transcript.length, 4);
        expect(transcript[1], contains('code=staleSnapshot'));
        expect(transcript[3], contains('ok=true'));
        expect(transcript[3], contains('code=ok'));

        final int firstRequestId = _extractRequestId(transcript[1]);
        final int secondRequestId = _extractRequestId(transcript[3]);
        expect(secondRequestId, greaterThan(firstRequestId));

        expect(transcript.join(), isNot(contains('SENSITIVE-VALUE')));
        expect(transcript.join(), isNot(contains('EXCLUDED-CONTENT')));

        await tester.pumpAndSettle();
        expect(find.text('Note text: set after retry'), findsOneWidget);
      } finally {
        await harness.dispose();
      }
    },
  );

  testWidgets(
    'a single-attempt probe run ends in the stale-snapshot code with the '
    'note text unchanged and no duplicate-request code in the transcript',
    (WidgetTester tester) async {
      final ExampleRuntimeHarness harness = ExampleRuntimeHarness();
      try {
        await harness.pump(tester, const ExampleFormScreen());

        final ExampleAgentProbe probe = ExampleAgentProbe();
        final List<String> transcript = await probe.run(
          pageId: ExampleFormScreen.pageId,
          nodeLabel: 'Note field',
          action: 'setText',
          arguments: <String, Object?>{'text': 'should not apply'},
          maxAttempts: 1,
          beforeFirstAct: () => _forceContentChange(tester),
        );

        expect(transcript.length, 2);
        expect(transcript.last, contains('code=staleSnapshot'));
        expect(transcript.join(), isNot(contains('duplicateRequest')));

        await tester.pumpAndSettle();
        expect(find.text('Note text: initial note'), findsOneWidget);
      } finally {
        await harness.dispose();
      }
    },
  );
}

/// Forces a real, observable change to the form page's content -- with no
/// involvement of the WebMcp act protocol -- and settles the widget tree so
/// the page recaptures and its revision changes. Used as the probe's
/// `beforeFirstAct` seam to make the probe's very next act observe a stale
/// snapshot.
Future<void> _forceContentChange(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('example.form.forceContentChange')));
  await tester.pumpAndSettle();
}

int _extractRequestId(String transcriptLine) {
  final RegExpMatch? match = RegExp(r'requestId=(\d+)')
      .firstMatch(transcriptLine);
  if (match == null) {
    fail('Transcript line carries no requestId: $transcriptLine');
  }
  return int.parse(match.group(1)!);
}

Future<Map<String, Object?>> _act(
  Map<String, Object?> read,
  Map<String, Object?> node, {
  required String action,
  required int requestId,
  Map<String, Object?> arguments = const <String, Object?>{},
}) async {
  final Object? result = await WebMcp.instance.invokeTool(
    '${ExampleFormScreen.pageId}.page.act',
    <String, Object?>{
      'pageId': ExampleFormScreen.pageId,
      'mountToken': read['mountToken'],
      'revision': read['revision'],
      'handle': node['handle'],
      'action': action,
      'requestId': requestId,
      'arguments': arguments,
    },
  );
  return result as Map<String, Object?>;
}
