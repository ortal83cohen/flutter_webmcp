// Case 01 — Exact subtree ownership.
//
// POSITIVE: Walking from a Semantics-wrapper's root yields only nodes whose
//           labels are within that wrapper's subtree.
// NEGATIVE: Walking from scope A's root does NOT yield scope B's labels, and
//           vice versa.
//
// FINDING (Flutter 3.47.0): Semantics(label: 'X', child: Text('Y')) produces a
// single merged node with attributedLabel.string == 'X\nY'. Label checks
// use String.contains() not equality.
//
// Satisfies: AC-001, AC-006 (exact subtree boundary).
// Run with: flutter test --platform=chrome test/case_01_ownership_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:page_semantics_spike/semantics_probe.dart';

// Helper: check if any label string in the list contains the expected text.
bool anyLabelContains(List<String> labels, String expected) =>
    labels.any((l) => l.contains(expected));

void main() {
  group('Case 01 – subtree ownership', () {
    testWidgets('POSITIVE: scope A root only yields A-prefixed nodes', (
      tester,
    ) async {
      final keyA = GlobalKey(debugLabel: 'scopeA');
      final keyB = GlobalKey(debugLabel: 'scopeB');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                // Scope A: labeled children.
                Semantics(
                  key: keyA,
                  label: 'scope-A-root',
                  child: const Text('A-child'),
                ),
                // Scope B: labeled children.
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

      // Retrieve A's semantics node via the render object.
      final nodeA = semanticsNodeForContext(keyA.currentContext!);
      expect(nodeA, isNotNull, reason: 'scope A must have a semantics node');

      final labelsA = reachableLabels(nodeA!);
      // FINDING: Flutter 3.47.0 merges Semantics.label with child Text label.
      // The node label is 'scope-A-root\nA-child' (combined, not separate).
      // Check that the combined label CONTAINS the scope identifier.
      expect(
        anyLabelContains(labelsA, 'scope-A-root'),
        isTrue,
        reason: 'Scope A node must contain scope-A-root in its label',
      );
      // Scope A must NOT contain scope B's identifier.
      expect(
        anyLabelContains(labelsA, 'scope-B-root'),
        isFalse,
        reason: 'Scope A must not contain scope-B-root label',
      );

      addTearDown(() {
        // ignore: avoid_print
        print(
          'Case 01 scope-A labels: $labelsA '
          '(FINDING: label="scope-A-root\\nA-child" is ONE merged node)',
        );
      });
    });

    testWidgets('NEGATIVE: scope B root does not yield scope A labels', (
      tester,
    ) async {
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

      final nodeB = semanticsNodeForContext(keyB.currentContext!);
      expect(nodeB, isNotNull);

      final labelsB = reachableLabels(nodeB!);
      // B's subtree must NOT reach A.
      expect(
        anyLabelContains(labelsB, 'scope-A-root'),
        isFalse,
        reason: 'Scope B must not contain scope-A-root label',
      );
      // B's subtree must contain B's own label.
      expect(
        anyLabelContains(labelsB, 'scope-B-root'),
        isTrue,
        reason: 'Scope B node must contain scope-B-root in its label',
      );
    });

    testWidgets('POSITIVE: sibling node IDs do not overlap', (tester) async {
      final keyA = GlobalKey(debugLabel: 'scopeA');
      final keyB = GlobalKey(debugLabel: 'scopeB');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                Semantics(key: keyA, label: 'A', child: const Text('alpha')),
                Semantics(key: keyB, label: 'B', child: const Text('beta')),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final nodeA = semanticsNodeForContext(keyA.currentContext!);
      final nodeB = semanticsNodeForContext(keyB.currentContext!);
      expect(nodeA, isNotNull);
      expect(nodeB, isNotNull);

      final idsA = reachableIds(nodeA!);
      final idsB = reachableIds(nodeB!);

      // No ID should appear in both subtrees.
      final overlap = idsA.intersection(idsB);
      expect(
        overlap,
        isEmpty,
        reason:
            'Sibling semantics subtrees must not share node IDs; '
            'overlap=$overlap',
      );
    });
  });
}
