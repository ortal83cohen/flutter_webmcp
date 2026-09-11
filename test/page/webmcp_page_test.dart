import 'dart:async';
import 'dart:convert';
import 'dart:ui' show SemanticsUpdate;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_flutter/src/page/page.dart';
import 'package:webmcp_flutter/src/webmcp.dart';
import 'package:webmcp_flutter/src/webmcp_tool.dart';
import 'package:webmcp_flutter/src/webmcp_tool_source.dart';

void main() {
  setUp(() {
    WebMcp.instance.reset();
  });

  tearDown(() {
    WebMcpAppSession.activeSession?.detach();
    WebMcp.instance.reset();
  });

  testWidgets('one wrapper discovers ordinary semantics without descriptors', (
    WidgetTester tester,
  ) async {
    final _Harness harness = _Harness();
    await harness.pump(
      tester,
      WebMcpPage(
        pageId: 'home',
        child: Semantics(
          label: 'Automatic control',
          button: true,
          onTap: () {},
          child: const SizedBox(width: 20, height: 20),
        ),
      ),
    );

    final Map<String, Object?> read = await _read('home');

    expect(read['ok'], isTrue);
    expect(read['pageId'], 'home');
    expect(read.toString(), contains('Automatic control'));
    expect(
      WebMcp.instance.tools.map((WebMcpTool tool) => tool.name),
      containsAll(<String>['home.page.read', 'home.page.act']),
    );
  });

  testWidgets('an unwrapped page exposes no automatic endpoints', (
    WidgetTester tester,
  ) async {
    final _Harness harness = _Harness();
    await harness.pump(tester, const Text('Plain page'));

    expect(
      WebMcp.instance.tools.map((WebMcpTool tool) => tool.name),
      isNot(contains('plain.page.read')),
    );
    expect(
      WebMcp.instance.tools.map((WebMcpTool tool) => tool.name),
      contains('fixture.app.observe'),
    );
  });

  testWidgets(
    'nearest wrapper owns nested content and siblings do not overlap',
    (WidgetTester tester) async {
      final _Harness harness = _Harness();
      await harness.pump(
        tester,
        Row(
          textDirection: TextDirection.ltr,
          children: <Widget>[
            WebMcpPage(
              pageId: 'outer',
              child: Column(
                children: <Widget>[
                  const Text('outer-only'),
                  WebMcpPage(pageId: 'inner', child: const Text('inner-only')),
                ],
              ),
            ),
            WebMcpPage(pageId: 'sibling', child: const Text('sibling-only')),
          ],
        ),
      );

      final Map<String, Object?> outer = await _read('outer');
      final Map<String, Object?> inner = await _read('inner');
      final Map<String, Object?> sibling = await _read('sibling');

      expect(outer.toString(), contains('outer-only'));
      expect(outer.toString(), isNot(contains('inner-only')));
      expect(outer.toString(), isNot(contains('sibling-only')));
      expect(inner.toString(), contains('inner-only'));
      expect(sibling.toString(), contains('sibling-only'));
    },
  );

  testWidgets('stale revision, handle, and request order refuse dispatch', (
    WidgetTester tester,
  ) async {
    final _Harness harness = _Harness();
    int taps = 0;
    bool enabled = true;
    late StateSetter mutate;
    await harness.pump(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          mutate = setState;
          return WebMcpPage(
            pageId: 'actions',
            child: Semantics(
              identifier: 'target',
              label: 'Tap target',
              button: true,
              enabled: enabled,
              onTap: enabled ? () => taps++ : null,
              child: const SizedBox(width: 20, height: 20),
            ),
          );
        },
      ),
    );
    final Map<String, Object?> read = await _read('actions');
    final Map<String, Object?> node = _actionNode(read, 'tap');

    final Map<String, Object?> first = await _act(
      'actions',
      read,
      node,
      requestId: 2,
      action: 'tap',
    );
    final Map<String, Object?> exactRepeat = await _act(
      'actions',
      read,
      node,
      requestId: 2,
      action: 'tap',
    );
    final Map<String, Object?> outOfOrder = await _act(
      'actions',
      read,
      node,
      requestId: 1,
      action: 'tap',
    );

    expect(first['dispatched'], isTrue);
    expect(exactRepeat, first);
    expect(outOfOrder['code'], 'duplicateRequest');
    expect(taps, 1);

    mutate(() => enabled = false);
    await tester.pumpAndSettle();
    final Map<String, Object?> stale = await _act(
      'actions',
      read,
      node,
      requestId: 3,
      action: 'tap',
    );
    expect(stale['code'], 'staleSnapshot');
    expect(taps, 1);
  });

  testWidgets('cancel-before-dispatch causes no callback', (
    WidgetTester tester,
  ) async {
    final _Harness harness = _Harness();
    int taps = 0;
    await harness.pump(
      tester,
      WebMcpPage(
        pageId: 'cancel',
        child: Semantics(
          label: 'Cancel target',
          button: true,
          onTap: () => taps++,
          child: const SizedBox(width: 20, height: 20),
        ),
      ),
    );
    final Map<String, Object?> read = await _read('cancel');
    final Map<String, Object?> result = await _act(
      'cancel',
      read,
      _actionNode(read, 'tap'),
      requestId: 1,
      action: 'tap',
      arguments: <String, Object?>{'cancelled': true},
    );

    expect(result['code'], 'cancelled');
    expect(taps, 0);
  });

  testWidgets('accepts integer-valued JSON doubles at the action boundary', (
    WidgetTester tester,
  ) async {
    final _Harness harness = _Harness();
    int taps = 0;
    await harness.pump(
      tester,
      WebMcpPage(
        pageId: 'numeric-action',
        child: Semantics(
          label: 'Numeric target',
          button: true,
          onTap: () => taps++,
          child: const SizedBox(width: 20, height: 20),
        ),
      ),
    );
    final Map<String, Object?> read = await _read('numeric-action');
    final Map<String, Object?> node = _actionNode(read, 'tap');
    final Map<String, Object?> receipt = await WebMcp.instance.invokeTool(
      'numeric-action.page.act',
      <String, Object?>{
        'pageId': 'numeric-action',
        'mountToken': read['mountToken'],
        'revision': (read['revision']! as int).toDouble(),
        'handle': node['handle'],
        'action': 'tap',
        'requestId': 1.0,
        'arguments': <String, Object?>{},
      },
    ) as Map<String, Object?>;

    expect(receipt['dispatched'], isTrue);
    expect(taps, 1);
  });

  testWidgets(
    'semantic change records visible effect separately from dispatch',
    (WidgetTester tester) async {
      final _Harness harness = _Harness();
      int count = 0;
      late StateSetter mutate;
      await harness.pump(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            mutate = setState;
            return WebMcpPage(
              pageId: 'evidence',
              child: Column(
                children: <Widget>[
                  Text('count=$count'),
                  Semantics(
                    label: 'Increment visible count',
                    button: true,
                    onTap: () => mutate(() => count++),
                    child: const SizedBox(width: 10, height: 10),
                  ),
                ],
              ),
            );
          },
        ),
      );
      final Map<String, Object?> initialObserve =
          await WebMcp.instance.invokeTool(
            'fixture.app.observe',
            const <String, Object?>{},
          ) as Map<String, Object?>;
      final Map<String, Object?> read = await _read('evidence');
      final Map<String, Object?> receipt = await _act(
        'evidence',
        read,
        _actionNode(read, 'tap'),
        requestId: 1,
        action: 'tap',
      );
      expect(receipt['evidence'], 'commandDispatched');

      await tester.pumpAndSettle();
      final Map<String, Object?> observed = await WebMcp.instance.invokeTool(
        'fixture.app.observe',
        <String, Object?>{'cursor': initialObserve['cursor']},
      ) as Map<String, Object?>;

      expect(observed.toString(), contains('visibleEffectObserved'));
      expect(observed.toString(), contains(receipt['operationId']));
      expect((await _read('evidence')).toString(), contains('count=1'));
    },
  );

  testWidgets('unchanged activity notification emits no content event', (
    WidgetTester tester,
  ) async {
    final _Harness harness = _Harness();
    final _ActivitySignal activity = _ActivitySignal();
    await harness.pump(
      tester,
      WebMcpPage(
        pageId: 'unchanged',
        activity: activity,
        child: const Text('stable-content'),
      ),
    );
    final Map<String, Object?> before = await _read('unchanged');
    final Map<String, Object?> observedBefore =
        await WebMcp.instance.invokeTool(
          'fixture.app.observe',
          const <String, Object?>{},
        ) as Map<String, Object?>;

    activity.emit();
    await tester.pumpAndSettle();

    final Map<String, Object?> after = await _read('unchanged');
    final Map<String, Object?> observedAfter = await WebMcp.instance.invokeTool(
      'fixture.app.observe',
      <String, Object?>{'cursor': observedBefore['cursor']},
    ) as Map<String, Object?>;
    expect(after['revision'], before['revision']);
    expect(observedAfter['events'], isEmpty);
    expect(observedAfter['unchanged'], isTrue);
  });

  testWidgets('dirty page without a serviced frame stays unavailable', (
    WidgetTester tester,
  ) async {
    final _ActivitySignal activity = _ActivitySignal();
    final _Harness harness = _Harness(
      limits: WebMcpPageLimits(
        captureDeadline: const Duration(milliseconds: 10),
      ),
    );
    await harness.pump(
      tester,
      WebMcpPage(
        pageId: 'deadline',
        activity: activity,
        child: const Text('deadline-content'),
      ),
    );
    expect((await _read('deadline'))['ok'], isTrue);

    activity.emit();
    await tester.runAsync<void>(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );

    expect((await _read('deadline'))['code'], 'snapshotUnavailable');
  });

  testWidgets('privacy omits obscured and excluded subtrees', (
    WidgetTester tester,
  ) async {
    final _Harness harness = _Harness();
    await harness.pump(
      tester,
      WebMcpPage(
        pageId: 'privacy',
        policy: WebMcpPagePolicy(
          excludedSemanticsIdentifiers: <String>{'excluded'},
          editableValueIdentifiers: <String>{'field'},
        ),
        child: Column(
          children: <Widget>[
            Semantics(
              identifier: 'excluded',
              label: 'SECRET-EXCLUDED',
              child: const SizedBox(width: 10, height: 10),
            ),
            Semantics(
              identifier: 'password',
              label: 'Password',
              value: 'SECRET-PASSWORD',
              textField: true,
              obscured: true,
              child: const SizedBox(width: 10, height: 10),
            ),
            Semantics(
              identifier: 'field',
              label: 'Editable',
              value: 'PRIVATE-VALUE',
              textField: true,
              onSetText: (_) {},
              child: const SizedBox(width: 10, height: 10),
            ),
          ],
        ),
      ),
    );

    final Map<String, Object?> read = await _read('privacy');
    expect(read.toString(), isNot(contains('SECRET-EXCLUDED')));
    expect(read.toString(), isNot(contains('SECRET-PASSWORD')));
    expect(read.toString(), contains('PRIVATE-VALUE'));
    final Map<String, Object?> editable = _nodeByLabel(read, 'Editable');
    expect(editable['actions'], isNot(contains('setText')));
  });

  testWidgets('setText requires separate explicit mutation opt-in', (
    WidgetTester tester,
  ) async {
    final _Harness harness = _Harness();
    String? changed;
    await harness.pump(
      tester,
      WebMcpPage(
        pageId: 'input',
        policy: WebMcpPagePolicy(
          editableValueIdentifiers: <String>{'field'},
          setTextIdentifiers: <String>{'field'},
        ),
        child: Semantics(
          identifier: 'field',
          label: 'Editable field',
          value: 'current',
          textField: true,
          onSetText: (String value) => changed = value,
          child: const SizedBox(width: 10, height: 10),
        ),
      ),
    );
    final Map<String, Object?> read = await _read('input');
    final Map<String, Object?> node = _actionNode(read, 'setText');
    final Map<String, Object?> result = await _act(
      'input',
      read,
      node,
      requestId: 1,
      action: 'setText',
      arguments: <String, Object?>{'text': 'updated'},
    );

    expect(result['dispatched'], isTrue);
    expect(changed, 'updated');
  });

  testWidgets('pagination is bounded to one revision and expires on change', (
    WidgetTester tester,
  ) async {
    final _Harness harness = _Harness();
    String label = 'node-a';
    late StateSetter mutate;
    await harness.pump(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          mutate = setState;
          return WebMcpPage(
            pageId: 'paging',
            child: Column(
              children: <Widget>[
                Text(label),
                const Text('node-b'),
                const Text('node-c'),
              ],
            ),
          );
        },
      ),
    );

    final Map<String, Object?> first = await _read('paging', <String, Object?>{
      'limit': 1,
    });
    final String cursor = first['nextCursor']! as String;
    final Map<String, Object?> second = await _read('paging', <String, Object?>{
      'limit': 1,
      'cursor': cursor,
    });
    expect(second['ok'], isTrue);
    final List<Map<String, Object?>> secondNodes =
        (second['nodes']! as List<Object?>).cast<Map<String, Object?>>();
    final Set<Object?> returnedHandles = secondNodes
        .map((Map<String, Object?> node) => node['handle'])
        .toSet();
    expect(
      secondNodes
          .where((Map<String, Object?> node) => node['parentHandle'] != null)
          .every(
            (Map<String, Object?> node) =>
                returnedHandles.contains(node['parentHandle']),
          ),
      isTrue,
    );

    mutate(() => label = 'node-a-changed');
    await tester.pumpAndSettle();
    final Map<String, Object?> expired = await _read(
      'paging',
      <String, Object?>{'limit': 1, 'cursor': cursor},
    );
    expect(expired['code'], 'invalidCursor');
  });

  testWidgets('response byte limit omits whole optional fields explicitly', (
    WidgetTester tester,
  ) async {
    final _Harness harness = _Harness(
      limits: WebMcpPageLimits(readBytes: 1024),
    );
    final String oversizedLabel = 'sensitive-' * 800;
    await harness.pump(
      tester,
      WebMcpPage(
        pageId: 'bytes',
        child: Semantics(
          label: oversizedLabel,
          child: const SizedBox(width: 10, height: 10),
        ),
      ),
    );

    final Map<String, Object?> read = await _read('bytes');
    final int encodedBytes = utf8.encode(jsonEncode(read)).length;
    final Map<String, Object?> coverage =
        read['coverage']! as Map<String, Object?>;
    final Map<String, Object?> omissions =
        coverage['omissionReasons']! as Map<String, Object?>;

    expect(read['ok'], isTrue);
    expect(encodedBytes, lessThanOrEqualTo(1024));
    expect(read.toString(), isNot(contains(oversizedLabel)));
    expect(omissions['responseBytes'], greaterThan(0));
  });

  testWidgets('capture node, visit, and depth ceilings truncate explicitly', (
    WidgetTester tester,
  ) async {
    final _Harness returnedHarness = _Harness(
      limits: WebMcpPageLimits(returnedNodes: 2),
    );
    await returnedHarness.pump(
      tester,
      WebMcpPage(
        pageId: 'returned',
        child: const Column(
          children: <Widget>[Text('a'), Text('b'), Text('c')],
        ),
      ),
    );
    final Map<String, Object?> returned = await _read('returned');
    final Map<String, Object?> returnedCoverage =
        returned['coverage']! as Map<String, Object?>;
    expect((returned['nodes']! as List<Object?>).length, 2);
    expect(returnedCoverage['truncated'], isTrue);
    returnedHarness.dispose();
    await tester.pumpWidget(const SizedBox.shrink());

    final _Harness visitedHarness = _Harness(
      appId: 'visited-app',
      limits: WebMcpPageLimits(visitedNodes: 3),
    );
    await visitedHarness.pump(
      tester,
      WebMcpPage(
        pageId: 'visited',
        child: const Column(
          children: <Widget>[Text('a'), Text('b'), Text('c'), Text('d')],
        ),
      ),
    );
    final Map<String, Object?> visited = await _read('visited');
    final Map<String, Object?> visitedCoverage =
        visited['coverage']! as Map<String, Object?>;
    expect(visitedCoverage['visited'], 3);
    expect(
      (visitedCoverage['omissionReasons']! as Map<String, Object?>).containsKey(
        'visitedNodes',
      ),
      isTrue,
    );
    visitedHarness.dispose();
    await tester.pumpWidget(const SizedBox.shrink());

    final _Harness depthHarness = _Harness(
      appId: 'depth-app',
      limits: WebMcpPageLimits(maxDepth: 1),
    );
    await depthHarness.pump(
      tester,
      WebMcpPage(
        pageId: 'depth',
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          label: 'level-one',
          child: Semantics(
            container: true,
            label: 'level-two',
            child: const SizedBox(width: 10, height: 10),
          ),
        ),
      ),
    );
    final Map<String, Object?> depth = await _read('depth');
    final Map<String, Object?> depthCoverage =
        depth['coverage']! as Map<String, Object?>;
    expect(
      (depthCoverage['omissionReasons']! as Map<String, Object?>).containsKey(
        'maxDepth',
      ),
      isTrue,
    );
  });

  testWidgets('zero and two view providers refuse automatic exposure', (
    WidgetTester tester,
  ) async {
    final _Harness zero = _Harness(
      provider: const _FixedProvider(<WebMcpViewBinding>[]),
    );
    await zero.pump(
      tester,
      WebMcpPage(pageId: 'zero', child: const Text('hidden')),
    );
    expect(
      WebMcp.instance.tools.map((WebMcpTool tool) => tool.name),
      isNot(contains('zero.page.read')),
    );
    zero.dispose();
    await tester.pumpWidget(const SizedBox.shrink());

    final _Harness two = _Harness(
      appId: 'fixture2',
      provider: const _FixedProvider(<WebMcpViewBinding>[
        WebMcpViewBinding(pipelineOwner: null, semanticsOwner: null),
        WebMcpViewBinding(pipelineOwner: null, semanticsOwner: null),
      ]),
    );
    await two.pump(
      tester,
      WebMcpPage(pageId: 'two', child: const Text('hidden')),
    );
    expect(
      WebMcp.instance.tools.map((WebMcpTool tool) => tool.name),
      isNot(contains('two.page.read')),
    );
  });

  testWidgets('owner replacement revokes, rebinds, and ignores old callbacks', (
    WidgetTester tester,
  ) async {
    final WebMcpViewBinding current = const WebMcpBindingViewProvider()
        .getViews()
        .single;
    final _MutableProvider provider = _MutableProvider(current);
    final ValueNotifier<bool> active = ValueNotifier<bool>(true);
    final _Harness harness = _Harness(provider: provider);
    await harness.pump(
      tester,
      WebMcpPage(
        pageId: 'replacement',
        activity: active,
        child: Semantics(
          label: 'original-owner',
          button: true,
          onTap: () {},
          child: const SizedBox(width: 10, height: 10),
        ),
      ),
    );
    final Map<String, Object?> original = await _read('replacement');
    final Map<String, Object?> observed = await WebMcp.instance.invokeTool(
      'fixture.app.observe',
      const <String, Object?>{},
    ) as Map<String, Object?>;
    final String scopeReference =
        (observed['eligibleScopes']! as List<Object?>).single! as String;
    final _ReplacementOwners replacement = _ReplacementOwners(
      'webmcp-page-scope:$scopeReference',
    );

    provider.binding = replacement.binding;
    active.value = false;
    expect((await _read('replacement'))['code'], 'inactiveScope');
    final int capturesBeforeReplacement = provider.calls;
    active.value = true;
    await tester.pumpAndSettle();
    expect(provider.calls, capturesBeforeReplacement + 1);

    final Map<String, Object?> rebound = await _read('replacement');
    expect(rebound['ok'], isTrue, reason: rebound.toString());
    expect(rebound.toString(), contains('replacement-owner'));
    expect(replacement.owner.listenerCount, 1);
    final Map<String, Object?> stale = await _act(
      'replacement',
      original,
      _actionNode(original, 'tap'),
      requestId: 1,
      action: 'tap',
    );
    expect(stale['code'], 'staleSnapshot');

    final _ReplacementOwners secondReplacement = _ReplacementOwners(
      'webmcp-page-scope:$scopeReference',
    );
    provider.binding = secondReplacement.binding;
    active.value = false;
    active.value = true;
    await tester.pumpAndSettle();
    expect(replacement.owner.listenerCount, 0);
    expect(secondReplacement.owner.listenerCount, 1);
    final int reboundRevision =
        (await _read('replacement'))['revision']! as int;
    replacement.owner.emit();
    await tester.pump();
    expect((await _read('replacement'))['revision'], reboundRevision);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(secondReplacement.owner.listenerCount, 0);
    replacement.dispose();
    secondReplacement.dispose();
  });

  testWidgets('unknown transition remains inactive after frames', (
    WidgetTester tester,
  ) async {
    final _Harness harness = _Harness();
    final ValueNotifier<bool> active = ValueNotifier<bool>(true);
    await harness.pump(
      tester,
      WebMcpPage(
        pageId: 'unknown',
        activity: active,
        child: const Text('content'),
      ),
    );
    expect((await _read('unknown'))['ok'], isTrue);

    harness.adapter.markTransitionUnknown();
    active.value = false;
    active.value = true;
    await tester.pumpAndSettle();

    final Map<String, Object?> refused = await _read('unknown');
    expect(refused['code'], 'inactiveScope');
  });

  testWidgets(
    'root modals suspend underlying pages and wrapped modals isolate',
    (WidgetTester tester) async {
      final _Harness harness = _Harness(rootModalRelationship: true);
      late BuildContext pageContext;
      await harness.pump(
        tester,
        Builder(
          builder: (BuildContext context) {
            pageContext = context;
            return WebMcpPage(
              pageId: 'underlying',
              child: const Text('underlying-content'),
            );
          },
        ),
      );
      expect((await _read('underlying'))['ok'], isTrue);

      showDialog<void>(
        context: pageContext,
        useRootNavigator: true,
        builder: (BuildContext context) =>
            const AlertDialog(content: Text('unwrapped-modal')),
      );
      await tester.pumpAndSettle();
      expect((await _read('underlying'))['code'], 'inactiveScope');

      Navigator.of(pageContext, rootNavigator: true).pop();
      await tester.pumpAndSettle();
      expect((await _read('underlying'))['ok'], isTrue);

      showDialog<void>(
        context: pageContext,
        useRootNavigator: true,
        builder: (BuildContext context) => WebMcpPage(
          pageId: 'modal',
          child: const AlertDialog(content: Text('wrapped-modal')),
        ),
      );
      await tester.pumpAndSettle();

      expect((await _read('underlying'))['code'], 'inactiveScope');
      final Map<String, Object?> modal = await _read('modal');
      expect(modal['ok'], isTrue);
      expect(modal.toString(), contains('wrapped-modal'));
      expect(modal.toString(), isNot(contains('underlying-content')));
    },
  );

  testWidgets(
    'nested Navigator uses its forwarding observer and current route',
    (WidgetTester tester) async {
      final WebMcpAppSession session = WebMcpAppSession();
      session.attach(appId: 'nested-app');
      final WebMcpNavigatorAdapter rootAdapter = WebMcpNavigatorAdapter(
        session: session,
        navigatorId: 'root',
      );
      final WebMcpNavigatorAdapter nestedAdapter = WebMcpNavigatorAdapter(
        session: session,
        navigatorId: 'nested',
        parentNavigatorId: 'root',
      );
      late BuildContext nestedContext;
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: <NavigatorObserver>[rootAdapter],
          home: Navigator(
            observers: <NavigatorObserver>[nestedAdapter],
            onGenerateRoute: (RouteSettings settings) =>
                MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    nestedContext = context;
                    return WebMcpPage(
                      pageId: 'nested.home',
                      child: const Text('nested-home'),
                    );
                  },
                ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect((await _read('nested.home'))['ok'], isTrue);

      nestedContext.findAncestorStateOfType<NavigatorState>()!.push<void>(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => WebMcpPage(
            pageId: 'nested.details',
            child: const Text('nested-details'),
          ),
        ),
      );
      expect((await _read('nested.home'))['code'], 'inactiveScope');
      await tester.pumpAndSettle();

      expect((await _read('nested.home'))['code'], 'inactiveScope');
      expect(
        (await _read('nested.details')).toString(),
        contains('nested-details'),
      );
      nestedAdapter.dispose();
      rootAdapter.dispose();
      session.detach();
    },
  );

  testWidgets('navigation action returns receipt and observes destination', (
    WidgetTester tester,
  ) async {
    final _Harness harness = _Harness(rootModalRelationship: true);
    await harness.pump(
      tester,
      Builder(
        builder: (BuildContext context) => WebMcpPage(
          pageId: 'home',
          child: Semantics(
            label: 'Open details',
            button: true,
            onTap: () {
              Navigator.of(context).pushReplacement<void, void>(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => WebMcpPage(
                    pageId: 'details',
                    child: const Text('details-content'),
                  ),
                ),
              );
            },
            child: const SizedBox(width: 20, height: 20),
          ),
        ),
      ),
    );
    final Map<String, Object?> observedBefore =
        await WebMcp.instance.invokeTool(
          'fixture.app.observe',
          const <String, Object?>{},
        ) as Map<String, Object?>;
    final Map<String, Object?> home = await _read('home');
    final Map<String, Object?> receipt = await _act(
      'home',
      home,
      _actionNode(home, 'tap'),
      requestId: 1,
      action: 'tap',
    );

    expect(receipt['dispatched'], isTrue);
    expect(receipt['evidence'], 'commandDispatched');
    await tester.pumpAndSettle();

    final Map<String, Object?> observedAfter = await WebMcp.instance.invokeTool(
      'fixture.app.observe',
      <String, Object?>{'cursor': observedBefore['cursor']},
    ) as Map<String, Object?>;
    final Map<String, Object?> details = await _read('details');
    expect(observedAfter['ok'], isTrue);
    expect(observedAfter['eligibleScopes'], isNotEmpty);
    expect(details['ok'], isTrue);
    expect(details.toString(), contains('details-content'));
    expect(
      WebMcp.instance.tools.map((WebMcpTool tool) => tool.name),
      isNot(contains('home.page.read')),
    );
  });

  testWidgets(
    'settled Navigator top route controls eligibility during replacement',
    (WidgetTester tester) async {
      final _Harness harness = _Harness();
      await harness.pump(
        tester,
        Builder(
          builder: (BuildContext context) => WebMcpPage(
            pageId: 'top-route-home',
            child: Semantics(
              label: 'Open details',
              button: true,
              onTap: () {
                Navigator.of(context).pushReplacement<void, void>(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => WebMcpPage(
                      pageId: 'top-route-details',
                      child: const Text('top-route-details-content'),
                    ),
                  ),
                );
              },
              child: const SizedBox(width: 20, height: 20),
            ),
          ),
        ),
      );
      final Map<String, Object?> home = await _read('top-route-home');
      final Map<String, Object?> receipt = await _act(
        'top-route-home',
        home,
        _actionNode(home, 'tap'),
        requestId: 1,
        action: 'tap',
      );

      expect(receipt['dispatched'], isTrue);
      await tester.pumpAndSettle();

      expect(
        WebMcp.instance.tools.map((WebMcpTool tool) => tool.name),
        isNot(contains('top-route-home.page.read')),
      );
      expect((await _read('top-route-details'))['ok'], isTrue);
    },
  );

  testWidgets(
    'domain execution saturation rejects before handler side effects',
    (WidgetTester tester) async {
      final _Harness harness = _Harness();
      final List<Completer<Object?>> pending = <Completer<Object?>>[];
      int calls = 0;
      final _ToolSource source = _ToolSource(
        WebMcpTool(
          name: 'domain.pending',
          description: 'Starts a bounded pending domain operation.',
          handler: (Map<String, Object?> arguments) {
            calls++;
            final Completer<Object?> completer = Completer<Object?>();
            pending.add(completer);
            return completer.future;
          },
        ),
      );
      await harness.pump(
        tester,
        WebMcpPage(
          pageId: 'domain',
          sources: <WebMcpToolSource>[source],
          child: const Text('domain-page'),
        ),
      );

      final List<Future<Object?>> executions = <Future<Object?>>[];
      for (int index = 0; index < 32; index++) {
        executions.add(WebMcp.instance.invokeTool('domain.pending', const {}));
      }
      expect(calls, 32);

      final Object? saturated = await WebMcp.instance.invokeTool(
        'domain.pending',
        const {},
      );
      expect((saturated! as Map<String, Object?>)['code'], 'busy');
      expect(calls, 32);

      for (final Completer<Object?> completer in pending) {
        completer.complete(null);
      }
      await Future.wait(executions);
    },
  );

  testWidgets('disposing a page removes owned endpoints and remounts fresh', (
    WidgetTester tester,
  ) async {
    final _Harness harness = _Harness();
    await harness.pump(
      tester,
      WebMcpPage(pageId: 'lifecycle', child: const Text('first')),
    );
    final Map<String, Object?> first = await _read('lifecycle');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(
      WebMcp.instance.tools.map((WebMcpTool tool) => tool.name),
      isNot(contains('lifecycle.page.read')),
    );

    await harness.pump(
      tester,
      WebMcpPage(pageId: 'lifecycle', child: const Text('second')),
      reuseSession: true,
    );
    final Map<String, Object?> second = await _read('lifecycle');
    expect(second['mountToken'], isNot(first['mountToken']));
  });
}

final class _Harness {
  _Harness({
    this.appId = 'fixture',
    this.provider,
    this.rootModalRelationship = false,
    this.limits,
  });

  final String appId;
  final WebMcpViewProvider? provider;
  final bool rootModalRelationship;
  final WebMcpPageLimits? limits;
  late final WebMcpAppSession session;
  late final WebMcpNavigatorAdapter adapter;
  bool _initialized = false;

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    bool reuseSession = false,
  }) async {
    if (!_initialized) {
      session = WebMcpAppSession(viewProvider: provider, limits: limits);
      session.attach(appId: appId);
      adapter = WebMcpNavigatorAdapter(
        session: session,
        navigatorId: 'root',
        rootModalRelationship: rootModalRelationship,
      );
      _initialized = true;
    } else if (!reuseSession) {
      throw StateError('Harness can only be initialized once.');
    }
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: <NavigatorObserver>[adapter],
        home: Scaffold(body: child),
      ),
    );
    for (int frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  void dispose() {
    if (!_initialized) {
      return;
    }
    adapter.dispose();
    session.detach();
    _initialized = false;
  }
}

final class _FixedProvider implements WebMcpViewProvider {
  const _FixedProvider(this.views);

  final List<WebMcpViewBinding> views;

  @override
  List<WebMcpViewBinding> getViews() => views;
}

final class _MutableProvider implements WebMcpViewProvider {
  _MutableProvider(this.binding);

  WebMcpViewBinding binding;
  int calls = 0;

  @override
  List<WebMcpViewBinding> getViews() {
    calls++;
    return <WebMcpViewBinding>[binding];
  }
}

final class _ActivitySignal extends ChangeNotifier
    implements ValueListenable<bool> {
  @override
  bool get value => true;

  void emit() {
    notifyListeners();
  }
}

final class _ReplacementOwners {
  _ReplacementOwners(String marker) {
    owner = _TestSemanticsOwner();
    pipelineOwner = _TestPipelineOwner(owner);
    final SemanticsNode root = SemanticsNode.root(owner: owner)
      ..rect = const Rect.fromLTWH(0, 0, 100, 100);
    final SemanticsNode boundary = SemanticsNode()
      ..rect = const Rect.fromLTWH(0, 0, 100, 100);
    final SemanticsConfiguration boundaryConfig = SemanticsConfiguration()
      ..identifier = marker
      ..label = 'replacement-owner'
      ..textDirection = TextDirection.ltr;
    boundary.updateWith(config: boundaryConfig);
    root.updateWith(
      config: SemanticsConfiguration(),
      childrenInInversePaintOrder: <SemanticsNode>[boundary],
    );
    binding = WebMcpViewBinding(
      pipelineOwner: pipelineOwner,
      semanticsOwner: owner,
    );
  }

  late final _TestSemanticsOwner owner;
  late final _TestPipelineOwner pipelineOwner;
  late final WebMcpViewBinding binding;

  void dispose() {
    owner.dispose();
  }
}

final class _TestPipelineOwner extends PipelineOwner {
  _TestPipelineOwner(this.testOwner)
    : super(onSemanticsUpdate: (SemanticsUpdate update) {});

  final SemanticsOwner testOwner;

  @override
  SemanticsOwner? get semanticsOwner => testOwner;
}

final class _TestSemanticsOwner extends SemanticsOwner {
  _TestSemanticsOwner() : super(onSemanticsUpdate: (SemanticsUpdate update) {});

  int listenerCount = 0;

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    listenerCount++;
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    listenerCount--;
  }

  void emit() {
    notifyListeners();
  }
}

final class _ToolSource implements WebMcpToolSource {
  const _ToolSource(this.tool);

  final WebMcpTool tool;

  @override
  List<WebMcpTool> getWebMcpTools() => <WebMcpTool>[tool];
}

Future<Map<String, Object?>> _read(
  String pageId, [
  Map<String, Object?> arguments = const <String, Object?>{},
]) async {
  return await WebMcp.instance.invokeTool('$pageId.page.read', arguments)
      as Map<String, Object?>;
}

Future<Map<String, Object?>> _act(
  String pageId,
  Map<String, Object?> read,
  Map<String, Object?> node, {
  required int requestId,
  required String action,
  Map<String, Object?> arguments = const <String, Object?>{},
}) async {
  return await WebMcp.instance.invokeTool('$pageId.page.act', <String, Object?>{
    'pageId': pageId,
    'mountToken': read['mountToken'],
    'revision': read['revision'],
    'handle': node['handle'],
    'action': action,
    'requestId': requestId,
    'arguments': arguments,
  }) as Map<String, Object?>;
}

Map<String, Object?> _actionNode(Map<String, Object?> read, String action) {
  return (read['nodes']! as List<Object?>)
      .cast<Map<String, Object?>>()
      .firstWhere(
        (Map<String, Object?> node) =>
            (node['actions']! as List<Object?>).contains(action),
      );
}

Map<String, Object?> _nodeByLabel(Map<String, Object?> read, String label) {
  return (read['nodes']! as List<Object?>)
      .cast<Map<String, Object?>>()
      .firstWhere((Map<String, Object?> node) => node['label'] == label);
}
