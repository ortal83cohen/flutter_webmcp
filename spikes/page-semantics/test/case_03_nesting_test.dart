// Case 03 — Nested boundaries (nearest-wrapper wins).
//
// An outer Semantics wrapper contains an inner one. The outer scope's walk
// sees the inner wrapper as an opaque child node but must not penetrate its
// internal labels. The inner scope owns its own subtree.
//
// FINDING (Flutter 3.47.0 single-PipelineOwner setup):
// - By default, walking from the outer node DOES reach inner node labels
//   because all widgets share one PipelineOwner/SemanticsOwner.
// - ExcludeSemantics at the inner boundary DOES stop the outer walk.
//   This is the mechanism the production wrapper must use.
//
// Satisfies: AC-001, AC-006.
// Run with: flutter test --platform=chrome test/case_03_nesting_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:page_semantics_spike/semantics_probe.dart';

bool anyContains(List<String> labels, String text) =>
    labels.any((l) => l.contains(text));

void main() {
  group('Case 03 – nested boundaries', () {
    testWidgets('POSITIVE: inner scope walk yields only inner labels', (
      tester,
    ) async {
      final innerKey = GlobalKey(debugLabel: 'inner');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Semantics(
              label: 'outer-label',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('outer-child'),
                  Semantics(
                    key: innerKey,
                    label: 'inner-label',
                    child: const Text('inner-child'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final innerNode = semanticsNodeForContext(innerKey.currentContext!);
      expect(innerNode, isNotNull);

      final innerLabels = reachableLabels(innerNode!);
      // Inner scope must contain its own label.
      expect(
        anyContains(innerLabels, 'inner-label'),
        isTrue,
        reason: 'Inner scope must contain inner-label',
      );
      // Walking from inner scope must NOT reach outer label.
      expect(
        anyContains(innerLabels, 'outer-label'),
        isFalse,
        reason: 'Walking from inner scope must not reach outer-label',
      );
    });

    testWidgets(
      'DOCUMENTED BEHAVIOR: outer walk reaches inner nodes (single PipelineOwner)',
      (tester) async {
        // This test DOCUMENTS actual Flutter behavior: in a single-PipelineOwner
        // setup, walking from the outer Semantics node DOES reach inner nodes.
        // This is expected and is why the proposed design uses ExcludeSemantics
        // at nested wrapper boundaries.
        final outerKey = GlobalKey(debugLabel: 'outer');
        final innerKey = GlobalKey(debugLabel: 'inner');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Semantics(
                key: outerKey,
                label: 'outer-label',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('outer-child'),
                    Semantics(
                      key: innerKey,
                      label: 'inner-label',
                      child: const Text('inner-child'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final outerNode = semanticsNodeForContext(outerKey.currentContext!);
        expect(outerNode, isNotNull);

        final outerLabels = reachableLabels(outerNode!);
        // DOCUMENTED: outer walk DOES see inner labels in default setup.
        // This is the behavior the proposed ExcludeSemantics boundary must
        // prevent at nested scope edges.
        final outerSeesInner = anyContains(outerLabels, 'inner-label');

        addTearDown(() {
          // ignore: avoid_print
          print(
            'Case 03 FINDING: outer walk ${outerSeesInner ? "DOES" : "does NOT"} '
            'reach inner-label in default single-PipelineOwner setup. '
            'ExcludeSemantics is required at nested boundaries.',
          );
        });
      },
    );

    testWidgets(
      'POSITIVE: ExcludeSemantics at inner boundary stops outer traversal',
      (tester) async {
        final outerKey = GlobalKey(debugLabel: 'outer');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Semantics(
                key: outerKey,
                label: 'outer-label',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('outer-child'),
                    // Simulate what the proposed wrapper does at its boundary:
                    // ExcludeSemantics blocks the inner subtree from outer walk.
                    ExcludeSemantics(
                      child: Semantics(
                        label: 'inner-label',
                        child: const Text('inner-child'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final outerNode = semanticsNodeForContext(outerKey.currentContext!);
        expect(outerNode, isNotNull);

        final outerLabels = reachableLabels(outerNode!);
        // With ExcludeSemantics, the outer walk must NOT reach inner-label.
        expect(
          anyContains(outerLabels, 'inner-label'),
          isFalse,
          reason: 'ExcludeSemantics must prevent outer scope from reaching inner labels',
        );
      },
    );
  });
}
