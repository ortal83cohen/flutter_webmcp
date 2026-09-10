// Debug test to understand case_01 failure.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:page_semantics_spike/semantics_probe.dart';

void main() {
  testWidgets('debug: semantics access pattern', (tester) async {
    final keyA = GlobalKey(debugLabel: 'scopeA');
    final keyB = GlobalKey(debugLabel: 'scopeB');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              Semantics(
                key: keyA,
                label: 'scope-A-root',
                child: const Text('A-child'),
              ),
              Semantics(
                key: keyB,
                label: 'scope-B-root',
                child: const Text('B-child'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check the context is valid.
    expect(keyA.currentContext, isNotNull, reason: 'keyA context null');
    expect(keyB.currentContext, isNotNull, reason: 'keyB context null');

    // Check render objects exist.
    final roA = keyA.currentContext!.findRenderObject();
    final roB = keyB.currentContext!.findRenderObject();
    expect(roA, isNotNull, reason: 'roA null');
    expect(roB, isNotNull, reason: 'roB null');

    // Check debug semantics.
    final semA = roA!.debugSemantics;
    final semB = roB!.debugSemantics;

    // Log the state.
    final semOwner = primarySemanticsOwner();
    addTearDown(() {
      // ignore: avoid_print
      print('DEBUG: semOwner=$semOwner semA=$semA semB=$semB');
      // ignore: avoid_print
      print(
        'DEBUG: root=${semOwner?.rootSemanticsNode} '
        'attachedA=${semA?.attached} attachedB=${semB?.attached}',
      );
      if (semOwner?.rootSemanticsNode != null) {
        final labels = reachableLabels(semOwner!.rootSemanticsNode!);
        // ignore: avoid_print
        print('DEBUG: root labels: $labels');
      }
    });

    // If semantics ARE available, check labels.
    if (semA != null) {
      final labelsA = reachableLabels(semA);
      // ignore: avoid_print
      print('DEBUG labelsA: $labelsA');
      expect(labelsA, contains('scope-A-root'));
    } else {
      // Semantics not available on this node — document why.
      // ignore: avoid_print
      print('DEBUG: semA is null — semantics not flushed or not enabled');
      // Use the tester semantics approach instead.
      final nodeViaFinder = tester.semantics.find(find.byKey(keyA));
      // ignore: avoid_print
      print('DEBUG via finder: $nodeViaFinder label="${nodeViaFinder.label}"');
      expect(nodeViaFinder.label, equals('scope-A-root'));
    }
  });
}
