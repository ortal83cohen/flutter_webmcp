import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:page_semantics_spike/semantics_probe.dart';

const markerPrefix = 'webmcp-spike:';
final List<String> evidenceLines = <String>[];

void evidence(String name, String verdict, String detail) {
  // This stable format is copied verbatim into the gate report.
  evidenceLines.add('EVIDENCE|$name|$verdict|$detail');
}

SemanticsNode scopeNode(String identifier) {
  final owner = primarySemanticsOwner();
  expect(owner, isNotNull, reason: 'A real SemanticsOwner must be active.');
  final node = resolveUniqueScope(owner!, identifier);
  expect(
    node,
    isNotNull,
    reason: 'Marker $identifier must resolve exactly once.',
  );
  return node!;
}

bool labelsContain(Iterable<String> labels, String value) =>
    labels.any((label) => label.contains(value));

class RecordingObserver extends NavigatorObserver {
  RecordingObserver(this.name);

  final String name;
  final List<String> events = <String>[];
  bool settled = true;
  bool gestureActive = false;
  int revocations = 0;

  void _watchTransition(Route<dynamic> route) {
    if (route is! TransitionRoute<dynamic>) {
      settled = true;
      return;
    }
    void listener(AnimationStatus status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        settled = true;
        route.animation?.removeStatusListener(listener);
      }
    }

    route.animation?.addStatusListener(listener);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    events.add('$name:push');
    revocations++;
    settled = false;
    _watchTransition(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    events.add('$name:pop');
    revocations++;
    settled = false;
    _watchTransition(previousRoute ?? route);
  }

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    events.add('$name:top');
  }

  @override
  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    events.add('$name:gesture-start');
    revocations++;
    gestureActive = true;
    settled = false;
  }

  @override
  void didStopUserGesture() {
    events.add('$name:gesture-stop');
    gestureActive = false;
  }
}

Widget markedScope(
  String id,
  Widget child, {
  String? label,
  bool explicitChildNodes = true,
}) {
  return Semantics(
    identifier: '$markerPrefix$id',
    container: true,
    explicitChildNodes: explicitChildNodes,
    label: label,
    child: child,
  );
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  tearDownAll(() {
    binding.reportData = <String, dynamic>{'evidence': evidenceLines};
  });

  testWidgets('release-safe ownership, siblings, and ambiguity', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          textDirection: TextDirection.ltr,
          children: <Widget>[
            markedScope('a', const Text('A-only'), label: 'scope-A'),
            markedScope('b', const Text('B-only'), label: 'scope-B'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final a = scopeNode('${markerPrefix}a');
    final b = scopeNode('${markerPrefix}b');
    final aLabels = reachableLabels(a);
    final bLabels = reachableLabels(b);
    expect(labelsContain(aLabels, 'scope-A'), isTrue);
    expect(labelsContain(aLabels, 'scope-B'), isFalse);
    expect(labelsContain(bLabels, 'scope-B'), isTrue);
    expect(labelsContain(bLabels, 'scope-A'), isFalse);
    expect(reachableIds(a).intersection(reachableIds(b)), isEmpty);

    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          textDirection: TextDirection.ltr,
          children: <Widget>[
            markedScope('duplicate', const Text('first')),
            markedScope('duplicate', const Text('second')),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      resolveUniqueScope(primarySemanticsOwner()!, '${markerPrefix}duplicate'),
      isNull,
      reason: 'Ambiguous markers must fail closed.',
    );
    evidence(
      'ownership-siblings-ambiguity',
      'PASS',
      'unique markers isolate siblings; duplicate marker resolves unavailable',
    );
  });

  testWidgets('nearest marked scope owns nested descendants', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: markedScope(
          'outer',
          Column(
            children: <Widget>[
              const Text('outer-only'),
              markedScope('inner', const Text('inner-only')),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final outer = scopeNode('${markerPrefix}outer');
    final inner = scopeNode('${markerPrefix}inner');
    final rawOuter = reachableLabels(outer);
    final ownedOuter = ownedLabels(outer, markerPrefix: markerPrefix);
    final ownedInner = ownedLabels(inner, markerPrefix: markerPrefix);

    expect(labelsContain(rawOuter, 'inner-only'), isTrue);
    expect(labelsContain(ownedOuter, 'outer-only'), isTrue);
    expect(labelsContain(ownedOuter, 'inner-only'), isFalse);
    expect(labelsContain(ownedInner, 'inner-only'), isTrue);
    expect(labelsContain(ownedInner, 'outer-only'), isFalse);
    evidence(
      'nested-nearest-owner',
      'PASS',
      'raw parent reaches child marker; bounded walk stops before nested scope',
    );
  });

  testWidgets('merge, exclusion, blocking, and obscured policy', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: <Widget>[
            markedScope(
              'merge-exclude',
              const Column(
                children: <Widget>[
                  MergeSemantics(
                    child: Row(
                      children: <Widget>[Text('merge-A'), Text('merge-B')],
                    ),
                  ),
                  ExcludeSemantics(child: Text('SECRET-EXCLUDED')),
                ],
              ),
            ),
            markedScope(
              'blocked',
              const Column(
                children: <Widget>[
                  Text('removed-by-block'),
                  BlockSemantics(child: Text('blocking-overlay')),
                ],
              ),
            ),
            markedScope(
              'obscured',
              Semantics(
                identifier: 'obscured-field',
                obscured: true,
                value: 'SECRET-VALUE',
                label: 'Password',
                child: const SizedBox(width: 20, height: 20),
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final mergeLabels = reachableLabels(
      scopeNode('${markerPrefix}merge-exclude'),
    );
    final blockedLabels = reachableLabels(scopeNode('${markerPrefix}blocked'));
    final obscuredScope = scopeNode('${markerPrefix}obscured');
    final obscured = findNodesByIdentifier(obscuredScope, 'obscured-field');
    expect(labelsContain(mergeLabels, 'merge-A'), isTrue);
    expect(labelsContain(mergeLabels, 'merge-B'), isTrue);
    expect(labelsContain(mergeLabels, 'SECRET-EXCLUDED'), isFalse);
    expect(labelsContain(blockedLabels, 'removed-by-block'), isFalse);
    expect(labelsContain(blockedLabels, 'blocking-overlay'), isTrue);
    expect(obscured, hasLength(1));
    expect(obscured.single.flagsCollection.isObscured, isTrue);
    final safe = walkSemantics(obscuredScope);
    expect(
      safe.nodes.any(
        (node) =>
            node.label.contains('SECRET-VALUE') ||
            node.hint.contains('SECRET-VALUE'),
      ),
      isFalse,
    );
    evidence(
      'merge-exclude-block-obscured',
      'PASS',
      'merged labels retained; excluded and blocked secrets absent; obscured value omitted',
    );
  });

  testWidgets('route and wrapped modal activity fail closed', (tester) async {
    final gateObserver = RecordingObserver('gate');
    final consumerObserver = RecordingObserver('consumer');
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: <NavigatorObserver>[consumerObserver, gateObserver],
        home: Scaffold(
          body: markedScope(
            'route-home',
            Builder(
              builder: (context) => Column(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => Scaffold(
                            body: markedScope(
                              'route-second',
                              const Text('second-route'),
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Text('Push route'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        useRootNavigator: true,
                        builder: (_) => markedScope(
                          'root-modal',
                          const AlertDialog(title: Text('root modal')),
                        ),
                      );
                    },
                    child: const Text('Open root modal'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        useRootNavigator: true,
                        builder: (_) =>
                            const AlertDialog(title: Text('unwrapped modal')),
                      );
                    },
                    child: const Text('Open unwrapped modal'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final revocationsBeforeRoute = gateObserver.revocations;
    await tester.tap(find.text('Push route'));
    await tester.pump();
    expect(gateObserver.revocations, greaterThan(revocationsBeforeRoute));
    expect(consumerObserver.events, contains('consumer:push'));
    await tester.pumpAndSettle();
    expect(gateObserver.settled, isTrue);
    expect(scopeNode('${markerPrefix}route-second').attached, isTrue);
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    final revocationsBeforeModal = gateObserver.revocations;
    await tester.tap(find.text('Open root modal'));
    await tester.pump();
    expect(gateObserver.revocations, greaterThan(revocationsBeforeModal));
    await tester.pumpAndSettle();
    expect(scopeNode('${markerPrefix}root-modal').attached, isTrue);
    expect(
      resolveUniqueScope(primarySemanticsOwner()!, '${markerPrefix}route-home'),
      isNull,
      reason: 'Flutter blocked the covered route from the semantics tree.',
    );
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    final revocationsBeforeUnwrapped = gateObserver.revocations;
    await tester.tap(find.text('Open unwrapped modal'));
    await tester.pumpAndSettle();
    expect(gateObserver.revocations, greaterThan(revocationsBeforeUnwrapped));
    expect(
      resolveUniqueScope(primarySemanticsOwner()!, '${markerPrefix}route-home'),
      isNull,
    );
    expect(
      findNodesByIdentifier(
        primarySemanticsOwner()!.rootSemanticsNode!,
        '${markerPrefix}root-modal',
      ),
      isEmpty,
      reason: 'An unwrapped modal must not be imported as an opted-in scope.',
    );
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    evidence(
      'route-root-modal-transition',
      'PASS',
      'observer revokes; wrapped root modal is isolated; unwrapped modal exposes no scope',
    );
  });

  testWidgets('navigator forest requires one observer per navigator', (
    tester,
  ) async {
    final rootObserver = RecordingObserver('root');
    final nestedObserver = RecordingObserver('nested');
    final nestedKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: <NavigatorObserver>[rootObserver],
        home: Navigator(
          key: nestedKey,
          observers: <NavigatorObserver>[nestedObserver],
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const Text('nested destination'),
                    ),
                  );
                },
                child: const Text('Nested push'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final rootPushesBefore = rootObserver.events
        .where((event) => event == 'root:push')
        .length;
    final nestedPushesBefore = nestedObserver.events
        .where((event) => event == 'nested:push')
        .length;
    await tester.tap(find.text('Nested push'));
    await tester.pumpAndSettle();
    expect(
      rootObserver.events.where((event) => event == 'root:push').length,
      rootPushesBefore,
      reason: 'Root observer must not claim nested Navigator events.',
    );
    expect(
      nestedObserver.events.where((event) => event == 'nested:push').length,
      nestedPushesBefore + 1,
    );
    evidence(
      'navigator-forest',
      'PASS',
      'nested push reaches nested observer only; root adapter alone is incomplete',
    );
  });

  testWidgets('projection changes and disposal invalidate captured nodes', (
    tester,
  ) async {
    final owner = primarySemanticsOwner();
    var ownerNotifications = 0;
    void ownerListener() {
      ownerNotifications++;
    }

    owner?.addListener(ownerListener);
    addTearDown(() => owner?.removeListener(ownerListener));

    var label = 'revision-1';
    var mounted = true;
    var mountGeneration = 1;
    var latePublished = false;
    late void Function(void Function()) mutate;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          mutate = setState;
          return MaterialApp(
            home: mounted
                ? markedScope('lifecycle', Text(label), label: label)
                : const Text('scope disposed'),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    final first = scopeNode('${markerPrefix}lifecycle');
    final firstProjection = reachableLabels(first).join('|');
    mutate(() => label = 'revision-2');
    await tester.pumpAndSettle();
    final secondProjection = reachableLabels(
      scopeNode('${markerPrefix}lifecycle'),
    ).join('|');
    expect(secondProjection, isNot(firstProjection));
    expect(ownerNotifications, greaterThan(0));

    final capturedGeneration = mountGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && capturedGeneration == mountGeneration) {
        latePublished = true;
      }
    });
    mutate(() {
      mounted = false;
      mountGeneration++;
    });
    await tester.pumpAndSettle();
    expect(first.attached, isFalse);
    expect(latePublished, isFalse);
    expect(
      resolveUniqueScope(primarySemanticsOwner()!, '${markerPrefix}lifecycle'),
      isNull,
    );
    evidence(
      'projection-disposal-late-callback',
      'PASS',
      'projection changed; owner notified; old node detached; token rejected late callback',
    );
  });

  testWidgets('advertised action dispatch and stale action rejection', (
    tester,
  ) async {
    var taps = 0;
    var enabled = true;
    late void Function(void Function()) mutate;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          mutate = setState;
          return MaterialApp(
            home: markedScope(
              'actions',
              Semantics(
                identifier: 'action-target',
                button: true,
                onTap: enabled ? () => taps++ : null,
                child: const SizedBox(width: 20, height: 20),
              ),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    final owner = primarySemanticsOwner()!;
    var target = findNodesByIdentifier(
      scopeNode('${markerPrefix}actions'),
      'action-target',
    ).single;
    expect(target.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    owner.performAction(target.id, SemanticsAction.tap);
    expect(taps, 1);

    mutate(() => enabled = false);
    await tester.pumpAndSettle();
    target = findNodesByIdentifier(
      scopeNode('${markerPrefix}actions'),
      'action-target',
    ).single;
    expect(target.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
    owner.performAction(target.id, SemanticsAction.tap);
    expect(taps, 1);
    evidence(
      'action-revalidation',
      'PASS',
      'advertised tap dispatched once; disabled target rejected after refresh',
    );
  });

  testWidgets('traversal enforces return, visit, depth, and UTF-8 limits', (
    tester,
  ) async {
    Widget deep = const Text('deep-leaf');
    for (var i = 39; i >= 0; i--) {
      deep = Semantics(
        identifier: 'depth-$i',
        container: true,
        explicitChildNodes: true,
        label: 'depth-$i',
        child: deep,
      );
    }
    await tester.pumpWidget(
      MaterialApp(
        home: SingleChildScrollView(
          child: markedScope(
            'limits',
            Column(
              children: <Widget>[
                for (var i = 0; i < 260; i++)
                  Semantics(
                    container: true,
                    explicitChildNodes: true,
                    label: 'node-$i-€',
                    child: const SizedBox(width: 1, height: 1),
                  ),
                deep,
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final root = scopeNode('${markerPrefix}limits');
    final returned = walkSemantics(
      root,
      budget: const TraversalBudget(
        maxReturned: 200,
        maxVisited: 1000,
        maxDepth: 100,
        maxBytes: 65536,
      ),
    );
    final visited = walkSemantics(
      root,
      budget: const TraversalBudget(
        maxReturned: 1000,
        maxVisited: 100,
        maxDepth: 100,
        maxBytes: 65536,
      ),
    );
    final depth = walkSemantics(
      root,
      budget: const TraversalBudget(
        maxReturned: 1000,
        maxVisited: 1000,
        maxDepth: 32,
        maxBytes: 65536,
      ),
    );
    final bytes = walkSemantics(
      root,
      budget: const TraversalBudget(
        maxReturned: 1000,
        maxVisited: 1000,
        maxDepth: 100,
        maxBytes: 512,
      ),
    );
    expect(returned.nodes.length, 200);
    expect(returned.truncationReason, 'maxReturned(200)');
    expect(visited.visitedCount, 101);
    expect(visited.truncationReason, 'maxVisited(100)');
    expect(depth.truncationReason, 'maxDepth(32)');
    expect(bytes.estimatedBytes, lessThanOrEqualTo(512));
    expect(bytes.truncationReason, 'maxBytes(512)');
    evidence(
      'resource-limits',
      'PASS',
      'returned=200 visited-stop=101 depth=32 bytes<=512 with explicit reasons',
    );
  });

  testWidgets('multiple-view owner selection is reported honestly', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: markedScope('single-view', const Text('view content'))),
    );
    await tester.pumpAndSettle();
    final viewCount = RendererBinding.instance.renderViews.length;
    expect(viewCount, greaterThanOrEqualTo(1));
    expect(
      semanticsOwnerForView(RendererBinding.instance.renderViews.first),
      same(primarySemanticsOwner()),
    );
    evidence(
      'multiple-views',
      viewCount > 1 ? 'PASS' : 'UNAVAILABLE',
      'renderViews=$viewCount; fixture runner did not provide a second FlutterView',
    );
    evidence(
      'semantics-owner-replacement',
      'UNAVAILABLE',
      'owner notifications proved; no public fixture hook replaced the RenderView PipelineOwner',
    );
    evidence(
      'interactive-gesture-interruption',
      'UNAVAILABLE',
      'headless Chrome did not provide a platform back gesture',
    );
  });
}
