// Case 02 — Sibling boundaries.
//
// Three sibling Semantics wrappers in a Row; each must own exactly its
// subtree and must not see nodes from the others.
//
// POSITIVE: Each scope yields its own label.
// NEGATIVE: No scope yields a label from either other scope.
//
// FINDING (Flutter 3.47.0): Semantics with a Text child merges labels
// into a single node string. Label checks use String.contains().
//
// Satisfies: AC-001, AC-006.
// Run with: flutter test --platform=chrome test/case_02_siblings_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:page_semantics_spike/semantics_probe.dart';

// Check if any label string in the list contains the expected text.
bool anyContains(List<String> labels, String expected) =>
    labels.any((l) => l.contains(expected));

void main() {
  testWidgets(
    'Case 02 – three siblings have non-overlapping semantics subtrees',
    (tester) async {
      final keys = List.generate(3, (i) => GlobalKey(debugLabel: 'scope-$i'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                for (var i = 0; i < 3; i++)
                  Expanded(
                    child: Semantics(
                      key: keys[i],
                      label: 'sibling-$i',
                      child: Text('content-$i'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final nodes = <int, Set<int>>{};
      final labelSets = <int, List<String>>{};
      for (var i = 0; i < 3; i++) {
        final node = semanticsNodeForContext(keys[i].currentContext!);
        expect(node, isNotNull, reason: 'scope $i must have a semantics node');
        nodes[i] = reachableIds(node!);
        labelSets[i] = reachableLabels(node);
      }

      // Each scope must contain its own label (as substring, may be merged).
      for (var i = 0; i < 3; i++) {
        expect(
          anyContains(labelSets[i]!, 'sibling-$i'),
          isTrue,
          reason: 'scope $i must contain sibling-$i in its label(s)',
        );
      }

      // No two scopes may share a node ID.
      for (var i = 0; i < 3; i++) {
        for (var j = i + 1; j < 3; j++) {
          final overlap = nodes[i]!.intersection(nodes[j]!);
          expect(
            overlap,
            isEmpty,
            reason: 'Scopes $i and $j share IDs: $overlap',
          );
        }
      }

      // Each scope must NOT contain another scope's root label.
      for (var i = 0; i < 3; i++) {
        for (var j = 0; j < 3; j++) {
          if (i == j) continue;
          expect(
            anyContains(labelSets[i]!, 'sibling-$j'),
            isFalse,
            reason: 'Scope $i must not contain sibling-$j',
          );
        }
      }
    },
  );
}
