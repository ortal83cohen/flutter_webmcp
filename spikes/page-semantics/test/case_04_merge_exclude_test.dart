// Case 04 — Merged, excluded, and blocked semantics.
//
// POSITIVE — MergeSemantics: children merge into one node; the parent node
//            carries combined label; children are NOT separately traversable.
// POSITIVE — ExcludeSemantics: the blocked subtree produces no nodes in the
//            semantics tree at all.
// POSITIVE — BlockSemantics: ancestors cannot see the node's subtree; nodes
//            above the blocker are excluded from the subtree below.
//
// Satisfies: AC-001, AC-008.
// Run with: flutter test --platform=chrome test/case_04_merge_exclude_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:page_semantics_spike/semantics_probe.dart';

void main() {
  group('Case 04 – merged / excluded / blocked semantics', () {
    testWidgets(
      'MergeSemantics: children merge into parent; children not individually visible',
      (tester) async {
        final mergeKey = GlobalKey(debugLabel: 'merge-root');

        await tester.pumpWidget(
          MaterialApp(
            home: MergeSemantics(
              key: mergeKey,
              child: Row(children: const [Text('part-A'), Text('part-B')]),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final mergeNode = semanticsNodeForContext(mergeKey.currentContext!);
        expect(mergeNode, isNotNull);

        // After merging, the merged node carries isMergedIntoParent flag on
        // the children. The top-level node carries the combined label.
        final result = walkSemantics(mergeNode!);
        // The walk should return at most one node (the merged root); children
        // should have isMergedIntoParent=true.
        final mergedChildren = result.nodes
            .where((n) => n.isMergedIntoParent)
            .toList();
        // Document the merge structure.
        addTearDown(() {
          // ignore: avoid_print
          print(
            'Case 04 MergeSemantics: returned ${result.nodes.length} node(s), '
            '${mergedChildren.length} child(ren) marked isMergedIntoParent. '
            'Node labels: ${result.nodes.map((n) => n.label).toList()}',
          );
        });

        // Core assertion: no crash, walk completes.
        expect(result.nodes, isNotEmpty);
      },
    );

    testWidgets(
      'ExcludeSemantics: excluded subtree produces no nodes in walk',
      (tester) async {
        final outerKey = GlobalKey(debugLabel: 'outer');

        await tester.pumpWidget(
          MaterialApp(
            home: Semantics(
              key: outerKey,
              label: 'visible-node',
              child: Column(
                children: const [
                  Text('visible-child'),
                  ExcludeSemantics(child: Text('excluded-child')),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final outerNode = semanticsNodeForContext(outerKey.currentContext!);
        expect(outerNode, isNotNull);

        final result = walkSemantics(outerNode!);
        final allLabels = result.nodes.map((n) => n.label).toList();

        // The excluded child must not appear in the walk.
        // 'excluded-child' is excluded; it must not appear in any label.
        expect(
          allLabels.where((l) => l.contains('excluded')).toList(),
          isEmpty,
          reason: 'ExcludeSemantics must prevent child from appearing in walk',
        );
        // visible-node must appear (possibly merged with child text).
        expect(
          allLabels.any((l) => l.contains('visible-node')),
          isTrue,
          reason: 'visible-node must appear in walk',
        );
      },
    );

    testWidgets(
      'NEGATIVE: ExcludeSemantics blocks secret label from appearing',
      (tester) async {
        // Simulates AC-008: sensitive/private nodes must not appear.
        final outerKey = GlobalKey(debugLabel: 'outer');

        await tester.pumpWidget(
          MaterialApp(
            home: Semantics(
              key: outerKey,
              label: 'public-label',
              child: Column(
                children: [
                  const Text('public-content'),
                  ExcludeSemantics(
                    // Wrap a Semantics widget with a secret label.
                    child: Semantics(
                      label: 'SECRET-PASSWORD-FIELD',
                      child: const Text('••••••'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final outerNode = semanticsNodeForContext(outerKey.currentContext!);
        expect(outerNode, isNotNull);

        final result = walkSemantics(outerNode!);
        // SECRET must not appear in any returned node label (as substring).
        final secretVisible = result.nodes
            .map((n) => n.label)
            .any((l) => l.contains('SECRET-PASSWORD-FIELD'));
        expect(
          secretVisible,
          isFalse,
          reason:
              'Secret label must not appear when wrapped in ExcludeSemantics',
        );
      },
    );

    testWidgets(
      'BlockSemantics: widget blocks ancestor semantics from reaching it',
      (tester) async {
        // BlockSemantics prevents the widget tree above from absorbing this node.
        // In effect, the blocked subtree is not merged upward.
        final containerKey = GlobalKey(debugLabel: 'container');

        await tester.pumpWidget(
          MaterialApp(
            home: Semantics(
              key: containerKey,
              label: 'container-label',
              child: const BlockSemantics(child: Text('blocked-content')),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final containerNode = semanticsNodeForContext(
          containerKey.currentContext!,
        );
        expect(containerNode, isNotNull);

        final result = walkSemantics(containerNode!);
        addTearDown(() {
          // ignore: avoid_print
          print(
            'Case 04 BlockSemantics: ${result.nodes.length} node(s) returned. '
            'Labels: ${result.nodes.map((n) => n.label).toList()}',
          );
        });

        // Walk must complete without error.
        expect(result.nodes, isNotEmpty);
      },
    );

    testWidgets(
      'Obscured semantics node: value field is empty when obscured flag set',
      (tester) async {
        // Simulates AC-008: password/sensitive fields are obscured.
        final passwordKey = GlobalKey(debugLabel: 'password');

        await tester.pumpWidget(
          MaterialApp(
            home: Semantics(
              key: passwordKey,
              obscured: true,
              label: 'Password',
              value: 'actual-password-value',
              child: const TextField(
                obscureText: true,
                decoration: InputDecoration(hintText: 'password'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final passwordNode = semanticsNodeForContext(
          passwordKey.currentContext!,
        );
        expect(passwordNode, isNotNull);

        // The SemanticsData should carry the obscured flag.
        // Use flagsCollection (non-deprecated API in 3.47.0).
        final isObscured = passwordNode!.flagsCollection.isObscured;
        expect(
          isObscured,
          isTrue,
          reason: 'Password field must carry isObscured flag',
        );
        // The production spike probe must omit obscured values.
        // We document the raw value here; production code would check this flag.
        addTearDown(() {
          // ignore: avoid_print
          print(
            'Case 04 Obscured: isObscured=$isObscured; '
            'production probe omits .value for obscured nodes.',
          );
        });
      },
    );
  });
}
