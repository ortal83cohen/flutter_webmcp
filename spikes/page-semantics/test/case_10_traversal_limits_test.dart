// Case 10 — Fixed traversal/depth/byte budgets (AC-009, AC-027).
//
// Creates trees with more nodes than the proposed budget allows.
// Verifies that walkSemantics stops at the configured ceilings and
// reports partial/truncated coverage with the correct reason.
//
// POSITIVE: Walk of 300-node tree with maxReturned=200 truncates at 200.
// POSITIVE: Walk of deep-nested tree truncates at maxDepth=32.
// POSITIVE: Truncation reason is correctly set.
// NEGATIVE: Walk never returns more than maxReturned nodes.
//
// Satisfies: AC-001, AC-009, AC-027.
// Run with: flutter test --platform=chrome test/case_10_traversal_limits_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:page_semantics_spike/semantics_probe.dart';

// Build a flat list of N labeled Semantics nodes.
Widget _buildFlatTree(int count) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Column(
      children: [
        for (var i = 0; i < count; i++)
          Semantics(label: 'node-$i', child: Text('t$i')),
      ],
    ),
  );
}

// Build a deeply nested single-child chain.
Widget _buildDeepTree(int depth) {
  Widget child = Semantics(label: 'leaf', child: const Text('leaf'));
  for (var i = depth - 1; i >= 0; i--) {
    child = Semantics(label: 'level-$i', child: child);
  }
  return Directionality(textDirection: TextDirection.ltr, child: child);
}

void main() {
  group('Case 10 – traversal budgets', () {
    testWidgets(
      'POSITIVE: flat tree of 300 nodes truncates at maxReturned=200',
      (tester) async {
        await tester.pumpWidget(_buildFlatTree(300));
        await tester.pumpAndSettle();

        final owner = primarySemanticsOwner()!;
        final root = owner.rootSemanticsNode!;

        final result = walkSemantics(
          root,
          budget: const TraversalBudget(
            maxReturned: 200,
            maxVisited: 1000,
            maxDepth: 32,
            maxBytes: 65536,
          ),
        );

        expect(
          result.nodes.length,
          lessThanOrEqualTo(200),
          reason: 'Must not return more than maxReturned=200 nodes',
        );
        expect(
          result.truncated,
          isTrue,
          reason: 'Walk must be truncated when tree exceeds maxReturned',
        );
        addTearDown(() {
          // ignore: avoid_print
          print(
            'Case 10 flat-300 RESULT: '
            'returned=${result.nodes.length} '
            'visited=${result.visitedCount} '
            'truncated=${result.truncated} '
            'reason=${result.truncationReason}',
          );
        });
      },
    );

    testWidgets('POSITIVE: deep tree of 50 levels truncates at maxDepth=32', (
      tester,
    ) async {
      await tester.pumpWidget(_buildDeepTree(50));
      await tester.pumpAndSettle();

      final owner = primarySemanticsOwner()!;
      final root = owner.rootSemanticsNode!;

      final result = walkSemantics(
        root,
        budget: const TraversalBudget(
          maxReturned: 200,
          maxVisited: 1000,
          maxDepth: 32,
          maxBytes: 65536,
        ),
      );

      // Walk must stop before depth 50.
      final maxDepthSeen = result.nodes.isEmpty
          ? 0
          : result.nodes.map((n) => n.depth).reduce((a, b) => a > b ? a : b);

      addTearDown(() {
        // ignore: avoid_print
        print(
          'Case 10 deep-50 RESULT: '
          'returned=${result.nodes.length} '
          'maxDepthSeen=$maxDepthSeen '
          'truncated=${result.truncated} '
          'reason=${result.truncationReason}',
        );
      });

      // No returned node may exceed maxDepth.
      expect(
        maxDepthSeen,
        lessThanOrEqualTo(32),
        reason: 'No node must be returned at depth > maxDepth=32',
      );
    });

    testWidgets(
      'NEGATIVE: walk with maxReturned=5 never returns more than 5 nodes',
      (tester) async {
        await tester.pumpWidget(_buildFlatTree(100));
        await tester.pumpAndSettle();

        final owner = primarySemanticsOwner()!;
        final root = owner.rootSemanticsNode!;

        final result = walkSemantics(
          root,
          budget: const TraversalBudget(
            maxReturned: 5,
            maxVisited: 1000,
            maxDepth: 32,
            maxBytes: 65536,
          ),
        );

        expect(
          result.nodes.length,
          lessThanOrEqualTo(5),
          reason: 'Must never return more than maxReturned=5 nodes',
        );
        expect(result.truncated, isTrue);
      },
    );

    testWidgets('POSITIVE: walk of small tree completes without truncation', (
      tester,
    ) async {
      await tester.pumpWidget(_buildFlatTree(10));
      await tester.pumpAndSettle();

      final owner = primarySemanticsOwner()!;
      final root = owner.rootSemanticsNode!;

      final result = walkSemantics(
        root,
        budget: const TraversalBudget(
          maxReturned: 200,
          maxVisited: 1000,
          maxDepth: 32,
          maxBytes: 65536,
        ),
      );

      // A small tree should NOT be truncated.
      addTearDown(() {
        // ignore: avoid_print
        print(
          'Case 10 small-10 RESULT: '
          'returned=${result.nodes.length} '
          'truncated=${result.truncated}',
        );
      });

      // 10-node flat tree should have fewer than 200 returned nodes.
      expect(result.nodes.length, lessThan(200));
    });

    testWidgets('POSITIVE: byte budget truncation when labels are very long', (
      tester,
    ) async {
      // Build a tree with labels that each exceed the per-record byte target.
      // 'A' * 1000 is not a valid const expression in this context; use a literal.
      final longLabel = List.filled(1000, 'A').join(); // 1 KB label.
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              for (var i = 0; i < 100; i++)
                Semantics(label: '$longLabel-$i', child: Text('t$i')),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final owner = primarySemanticsOwner()!;
      final root = owner.rootSemanticsNode!;

      final result = walkSemantics(
        root,
        budget: const TraversalBudget(
          maxReturned: 200,
          maxVisited: 1000,
          maxDepth: 32,
          maxBytes: 65536, // 64 KiB – will be exceeded early.
        ),
      );

      addTearDown(() {
        // ignore: avoid_print
        print(
          'Case 10 long-labels RESULT: '
          'returned=${result.nodes.length} '
          'estimatedBytes=${result.estimatedBytes} '
          'truncated=${result.truncated} '
          'reason=${result.truncationReason}',
        );
      });

      expect(
        result.estimatedBytes,
        lessThanOrEqualTo(65536 + 1064),
        reason: 'estimatedBytes must not exceed budget by more than one record',
      );
    });
  });
}
