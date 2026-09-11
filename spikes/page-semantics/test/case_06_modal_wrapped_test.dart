// Case 06 — Wrapped modal (dialog) as a distinct semantics scope.
//
// A dialog opened via showDialog is rendered in a separate route overlay.
// When wrapped with its own Semantics marker, it must form an isolated
// scope distinct from the underlying page.
//
// POSITIVE: Dialog's Semantics wrapper has its own node with its own label.
// POSITIVE: Dialog node is accessible while dialog is showing.
// POSITIVE: After dialog closes, dialog nodes are gone from the tree.
// NEGATIVE: Background page nodes should not be confused with dialog nodes.
//
// Satisfies: AC-001, AC-006, AC-020.
// Run with: flutter test --platform=chrome test/case_06_modal_wrapped_test.dart
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:page_semantics_spike/semantics_probe.dart';

void main() {
  group('Case 06 – wrapped modal as distinct scope', () {
    testWidgets(
      'POSITIVE: dialog Semantics wrapper has own node while showing',
      (tester) async {
        final dialogKey = GlobalKey(debugLabel: 'dialog-scope');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (_) => Semantics(
                          key: dialogKey,
                          label: 'dialog-scope-label',
                          child: const AlertDialog(title: Text('dialog-title')),
                        ),
                      );
                    },
                    child: Semantics(
                      label: 'open-dialog-button',
                      child: const Text('Open'),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Open the dialog.
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Dialog scope node must exist.
        expect(
          dialogKey.currentContext,
          isNotNull,
          reason: 'Dialog must be mounted',
        );
        final dialogNode = semanticsNodeForContext(dialogKey.currentContext!);
        expect(
          dialogNode,
          isNotNull,
          reason: 'Dialog scope must have a semantics node',
        );

        final dialogLabels = reachableLabels(dialogNode!);
        expect(dialogLabels, contains('dialog-scope-label'));

        // Dialog node must NOT contain the background button label.
        expect(
          dialogLabels,
          isNot(contains('open-dialog-button')),
          reason: 'Dialog scope must not include background page labels',
        );
      },
    );

    testWidgets(
      'POSITIVE: dialog scope is at a distinct subtree from background page',
      (tester) async {
        final pageKey = GlobalKey(debugLabel: 'page-scope');
        final dialogKey = GlobalKey(debugLabel: 'dialog-scope');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Semantics(
                    key: pageKey,
                    label: 'page-scope-label',
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (_) => Semantics(
                            key: dialogKey,
                            label: 'dialog-scope-label',
                            child: const AlertDialog(title: Text('dialog')),
                          ),
                        );
                      },
                      child: const Text('Open'),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        final pageNode = semanticsNodeForContext(pageKey.currentContext!);
        final dialogNode = semanticsNodeForContext(dialogKey.currentContext!);
        expect(pageNode, isNotNull);
        expect(dialogNode, isNotNull);

        final pageIds = reachableIds(pageNode!);
        final dialogIds = reachableIds(dialogNode!);

        // No ID overlap between page scope and dialog scope.
        final overlap = pageIds.intersection(dialogIds);
        expect(
          overlap,
          isEmpty,
          reason:
              'Page scope and dialog scope must not share semantics node IDs; '
              'overlap=$overlap',
        );
      },
    );

    testWidgets('POSITIVE: dialog nodes gone from tree after close', (
      tester,
    ) async {
      SemanticsNode? capturedDialogNode;
      final dialogKey = GlobalKey(debugLabel: 'dialog-scope');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (_) => Semantics(
                            key: dialogKey,
                            label: 'dialog-label',
                            child: AlertDialog(
                              title: const Text('Dialog'),
                              actions: [
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: const Text('Open'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open.
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      capturedDialogNode = semanticsNodeForContext(dialogKey.currentContext!);
      expect(capturedDialogNode, isNotNull);

      // Close.
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Dialog context is gone.
      expect(
        dialogKey.currentContext,
        isNull,
        reason: 'Dialog widget must be unmounted after close',
      );

      // The previously captured node should be detached.
      // After disposal, 'attached' is false; the node ID may be reused.
      final isAttached = capturedDialogNode!.attached;
      addTearDown(() {
        // ignore: avoid_print
        print(
          'Case 06 FINDING: After dialog close, previously captured '
          'SemanticsNode.attached=$isAttached. '
          'Production handles must be invalidated when a scope unmounts.',
        );
      });
      // attached must be false after unmount.
      expect(
        isAttached,
        isFalse,
        reason: 'SemanticsNode must be detached (attached=false) after dialog closes',
      );
    });
  });
}
