import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_flutter/src/page/webmcp_app_session.dart';
import 'package:webmcp_flutter/src/page/webmcp_page_protocol.dart';
import 'package:webmcp_flutter/src/page/webmcp_view_provider.dart';
import 'package:webmcp_flutter/src/webmcp.dart';
import 'package:webmcp_flutter/src/webmcp_tool.dart';

void main() {
  setUp(() {
    WebMcp.instance.reset();
  });

  tearDown(() {
    WebMcpAppSession.activeSession?.detach();
    WebMcp.instance.reset();
  });

  test('attach is stable and detach removes only its owned observe tool', () {
    final WebMcpAppSession session = WebMcpAppSession();
    final Map<String, Object?> first = session.attach(appId: 'fixture');
    final Map<String, Object?> second = session.attach(appId: 'fixture');

    expect(first['appMount'], second['appMount']);
    expect(session.ownsObserveTool, isTrue);
    expect(
      WebMcp.instance.tools.map((WebMcpTool tool) => tool.name),
      contains('fixture.app.observe'),
    );

    session.detach();
    session.detach();
    expect(WebMcp.instance.tools, isEmpty);
  });

  test('first live observe registration wins without removing its owner', () {
    WebMcp.instance.registerTool(
      WebMcpTool(
        name: 'fixture.app.observe',
        description: 'Existing owner.',
        handler: (Map<String, Object?> _) => null,
      ),
    );
    final WebMcpAppSession session = WebMcpAppSession();

    final Map<String, Object?> state = session.attach(appId: 'fixture');

    expect(state['observeOwned'], isFalse);
    session.detach();
    expect(
      WebMcp.instance.tools.map((WebMcpTool tool) => tool.name),
      contains('fixture.app.observe'),
    );
  });

  test(
    'observe polls immediately and rejects positive waits and fields',
    () async {
      final WebMcpAppSession session = WebMcpAppSession();
      session.attach(appId: 'fixture');

      final Map<String, Object?> initial = await WebMcp.instance.invokeTool(
        'fixture.app.observe',
        <String, Object?>{'waitMs': 0},
      ) as Map<String, Object?>;
      final Map<String, Object?> waited = await WebMcp.instance.invokeTool(
        'fixture.app.observe',
        <String, Object?>{'waitMs': 1},
      ) as Map<String, Object?>;
      final Map<String, Object?> unknown = await WebMcp.instance.invokeTool(
        'fixture.app.observe',
        <String, Object?>{'secret': 'must-not-appear'},
      ) as Map<String, Object?>;

      expect(initial['ok'], isTrue);
      expect(initial['unchanged'], isTrue);
      expect(waited['code'], 'unsupportedWait');
      expect(unknown['code'], 'invalidArguments');
      expect(unknown.toString(), isNot(contains('must-not-appear')));
    },
  );

  test('foreign and evicted cursors recover with a redacted gap', () async {
    final WebMcpAppSession session = WebMcpAppSession(
      limits: WebMcpPageLimits(ringEvents: 2),
    );
    session.attach(appId: 'fixture');
    final _FakePage page = _FakePage(session.allocateScopeReference());
    expect(session.registerPage(page), isNull);
    final Map<String, Object?> initial = await WebMcp.instance.invokeTool(
      'fixture.app.observe',
      <String, Object?>{},
    ) as Map<String, Object?>;
    final String oldCursor = initial['cursor']! as String;
    for (int index = 0; index < 3; index++) {
      session.publishPageState(page, kind: 'contentChanged');
    }
    page.eligible = false;

    final Map<String, Object?> gap = await WebMcp.instance.invokeTool(
      'fixture.app.observe',
      <String, Object?>{'cursor': oldCursor},
    ) as Map<String, Object?>;
    final Map<String, Object?> foreign = await WebMcp.instance.invokeTool(
      'fixture.app.observe',
      <String, Object?>{'cursor': 'not-a-cursor'},
    ) as Map<String, Object?>;

    expect(gap['gap'], isTrue);
    expect(gap['refreshRequired'], isTrue);
    expect(gap['eligibleScopes'], isEmpty);
    expect(gap.toString(), isNot(contains(page.scopeReference)));
    expect(foreign['gap'], isTrue);
  });

  test('ring byte overflow drops whole events and reports a gap', () async {
    final WebMcpAppSession session = WebMcpAppSession(
      limits: WebMcpPageLimits(ringBytes: 256),
    );
    session.attach(appId: 'fixture');
    final _FakePage page = _FakePage('s${'x' * 300}');
    session.registerPage(page);
    final Map<String, Object?> before = await WebMcp.instance.invokeTool(
      'fixture.app.observe',
      const <String, Object?>{},
    ) as Map<String, Object?>;

    session.publishPageState(page, kind: 'contentChanged');
    final Map<String, Object?> after = await WebMcp.instance.invokeTool(
      'fixture.app.observe',
      <String, Object?>{'cursor': before['cursor']},
    ) as Map<String, Object?>;

    expect(session.retainedEventCount, 0);
    expect(after['gap'], isTrue);
    expect(after['refreshRequired'], isTrue);
  });

  test(
    'observe returns 32 whole events and marks remaining history partial',
    () async {
      final WebMcpAppSession session = WebMcpAppSession();
      session.attach(appId: 'fixture');
      final _FakePage page = _FakePage(session.allocateScopeReference());
      expect(session.registerPage(page), isNull);
      final Map<String, Object?> initial = await WebMcp.instance.invokeTool(
        'fixture.app.observe',
        <String, Object?>{},
      ) as Map<String, Object?>;
      for (int index = 0; index < 40; index++) {
        session.publishPageState(page, kind: 'contentChanged');
      }

      final Map<String, Object?> response = await WebMcp.instance.invokeTool(
        'fixture.app.observe',
        <String, Object?>{'cursor': initial['cursor']},
      ) as Map<String, Object?>;
      final List<Object?> events = response['events']! as List<Object?>;
      final Map<String, Object?> coverage =
          response['eventCoverage']! as Map<String, Object?>;

      expect(events, hasLength(32));
      expect(coverage['partial'], isTrue);
    },
  );

  test(
    'observe fails safely when a lowered byte cap cannot fit metadata',
    () async {
      final WebMcpAppSession session = WebMcpAppSession(
        limits: WebMcpPageLimits(observeBytes: 256),
      );
      session.attach(appId: 'fixture');

      final Map<String, Object?> response = await WebMcp.instance.invokeTool(
        'fixture.app.observe',
        const <String, Object?>{},
      ) as Map<String, Object?>;

      expect(response['code'], 'resourceLimit');
      expect(response.toString(), isNot(contains('eligibleScopes')));
    },
  );

  test('non-selected settled branch does not invalidate other navigators', () {
    final WebMcpAppSession session = WebMcpAppSession();
    session.attach(appId: 'fixture');
    final WebMcpNavigatorAdapter root = WebMcpNavigatorAdapter(
      session: session,
      navigatorId: 'root',
    );
    final ValueNotifier<bool> selected = ValueNotifier<bool>(false);
    final WebMcpNavigatorAdapter branch = WebMcpNavigatorAdapter(
      session: session,
      navigatorId: 'branch',
      persistentParallelBranch: true,
      selectedBranch: selected,
    );

    expect(session.routeEvidenceReady, isTrue);
    expect(root.isSettled, isTrue);
    expect(branch.hasSettledEvidence, isTrue);
    expect(branch.isSettled, isFalse);
    selected.value = true;
    expect(branch.isSettled, isTrue);
    root.dispose();
    branch.dispose();
  });

  test('live scope cap accepts exactly 128 and refuses one over', () {
    final WebMcpAppSession session = WebMcpAppSession();
    session.attach(appId: 'fixture');
    for (int index = 0; index < 128; index++) {
      expect(session.registerPage(_FakePage('scope-$index')), isNull);
    }

    expect(
      session.registerPage(_FakePage('scope-over')),
      WebMcpPageErrorCode.resourceLimit,
    );
    expect(session.liveScopeCount, 128);
  });

  test('Navigator cap accepts exactly 32 and refuses one over', () {
    final WebMcpAppSession session = WebMcpAppSession();
    session.attach(appId: 'fixture');
    final List<WebMcpNavigatorAdapter> adapters = <WebMcpNavigatorAdapter>[];
    for (int index = 0; index < 32; index++) {
      final WebMcpNavigatorAdapter adapter = WebMcpNavigatorAdapter(
        session: session,
        navigatorId: 'nav-$index',
      );
      adapters.add(adapter);
      expect(adapter.registrationError, isNull);
    }

    final WebMcpNavigatorAdapter over = WebMcpNavigatorAdapter(
      session: session,
      navigatorId: 'nav-over',
    );
    expect(over.registrationError, WebMcpPageErrorCode.resourceLimit);
    expect(session.navigatorAdapterCount, 32);
    for (final WebMcpNavigatorAdapter adapter in adapters) {
      adapter.dispose();
    }
  });

  test(
    'known user gesture revokes immediately and stop does not reactivate',
    () {
      final WebMcpAppSession session = WebMcpAppSession();
      session.attach(appId: 'fixture');
      final _FakePage page = _FakePage(session.allocateScopeReference());
      session.registerPage(page);
      final WebMcpNavigatorAdapter adapter = WebMcpNavigatorAdapter(
        session: session,
        navigatorId: 'root',
      );
      final MaterialPageRoute<void> route = MaterialPageRoute<void>(
        builder: (BuildContext context) => const SizedBox.shrink(),
      );

      adapter.didStartUserGesture(route, null);
      expect(page.eligible, isFalse);
      final int revokedRevision = page.revision;
      adapter.didStopUserGesture();
      expect(page.eligible, isFalse);
      expect(page.revision, revokedRevision);
    },
  );

  test('operation and execution caps refuse before side effects', () {
    final WebMcpAppSession session = WebMcpAppSession();
    session.attach(appId: 'fixture');
    for (int index = 0; index < 32; index++) {
      expect(
        session.beginOperation(scopeReference: 'scope', requestId: index + 1),
        isNotNull,
      );
      expect(session.beginAsynchronousExecution(), isTrue);
    }

    expect(
      session.beginOperation(scopeReference: 'scope', requestId: 33),
      isNull,
    );
    expect(session.beginAsynchronousExecution(), isFalse);
    expect(session.retainedOperationCount, 32);
    expect(session.outstandingExecutionCount, 32);
    session.settleAsynchronousExecution();
    expect(session.beginAsynchronousExecution(), isTrue);
  });

  test('operation receipts expire without freeing execution capacity', () {
    DateTime now = DateTime.utc(2026, 9, 10);
    final WebMcpAppSession session = WebMcpAppSession(clock: () => now);
    session.attach(appId: 'fixture');
    for (int index = 0; index < 32; index++) {
      expect(
        session.beginOperation(scopeReference: 'scope', requestId: index + 1),
        isNotNull,
      );
      expect(session.beginAsynchronousExecution(), isTrue);
    }

    now = now.add(const Duration(seconds: 30));

    expect(session.retainedOperationCount, 0);
    expect(session.outstandingExecutionCount, 32);
    expect(session.beginAsynchronousExecution(), isFalse);
    expect(
      session.beginOperation(scopeReference: 'scope', requestId: 33),
      isNotNull,
    );
  });

  test('Future completion and backend confirmation remain distinct', () async {
    final WebMcpAppSession session = WebMcpAppSession();
    session.attach(appId: 'fixture');
    final String operationId = session.beginOperation(
      scopeReference: 'scope',
      requestId: 1,
    )!;

    session.recordEvidence(
      operationId,
      WebMcpEvidenceKind.domainFutureCompleted,
    );
    expect(
      session.operationReceipt(operationId)!['evidence'],
      'domainFutureCompleted',
    );
    expect(
      session.confirmBackend(operationId: operationId, outcome: 'unknown'),
      isFalse,
    );
    expect(
      session.confirmBackend(operationId: operationId, outcome: 'succeeded'),
      isTrue,
    );
    expect(
      session.operationReceipt(operationId)!['evidence'],
      'backendConfirmed',
    );
    expect(
      session.operationReceipt(operationId)!['backendOutcome'],
      'succeeded',
    );
  });

  test(
    'operation evidence survives page disposal without scope identity',
    () async {
      final WebMcpAppSession session = WebMcpAppSession();
      session.attach(appId: 'fixture');
      final _FakePage page = _FakePage(session.allocateScopeReference());
      session.registerPage(page);
      final String operationId = session.beginOperation(
        scopeReference: page.scopeReference,
        requestId: 1,
      )!;
      final Map<String, Object?> before = await WebMcp.instance.invokeTool(
        'fixture.app.observe',
        const <String, Object?>{},
      ) as Map<String, Object?>;

      session.unregisterPage(page);
      session.recordEvidence(
        operationId,
        WebMcpEvidenceKind.domainFutureCompleted,
      );
      final Map<String, Object?> after = await WebMcp.instance.invokeTool(
        'fixture.app.observe',
        <String, Object?>{'cursor': before['cursor']},
      ) as Map<String, Object?>;

      expect(after.toString(), contains('domainFutureCompleted'));
      expect(after.toString(), contains(operationId));
      expect(after.toString(), isNot(contains(page.scopeReference)));
    },
  );

  test('limits reject every configured value above its hard ceiling', () {
    expect(() => WebMcpPageLimits(liveScopes: 129), throwsArgumentError);
    expect(() => WebMcpPageLimits(navigatorAdapters: 33), throwsArgumentError);
    expect(() => WebMcpPageLimits(ringEvents: 257), throwsArgumentError);
    expect(() => WebMcpPageLimits(ringBytes: 65537), throwsArgumentError);
    expect(() => WebMcpPageLimits(observeEvents: 33), throwsArgumentError);
    expect(() => WebMcpPageLimits(observeBytes: 16385), throwsArgumentError);
    expect(() => WebMcpPageLimits(pendingWaits: 9), throwsArgumentError);
    expect(
      () => WebMcpPageLimits(pendingWaitsPerScope: 3),
      throwsArgumentError,
    );
    expect(() => WebMcpPageLimits(maxWaitMs: 1001), throwsArgumentError);
    expect(() => WebMcpPageLimits(trackedOperations: 33), throwsArgumentError);
    expect(
      () => WebMcpPageLimits(operationRetention: const Duration(seconds: 31)),
      throwsArgumentError,
    );
    expect(
      () => WebMcpPageLimits(outstandingExecutions: 33),
      throwsArgumentError,
    );
    expect(
      () =>
          WebMcpPageLimits(captureDeadline: const Duration(milliseconds: 2001)),
      throwsArgumentError,
    );
  });

  test('zero and two injected views expose no page owner', () {
    final WebMcpAppSession zero = WebMcpAppSession(
      viewProvider: const _FixedViewProvider(<WebMcpViewBinding>[]),
    );
    zero.attach(appId: 'zero');
    expect(zero.viewProvider.getViews(), isEmpty);
    zero.detach();

    final WebMcpAppSession two = WebMcpAppSession(
      viewProvider: const _FixedViewProvider(<WebMcpViewBinding>[
        WebMcpViewBinding(pipelineOwner: null, semanticsOwner: null),
        WebMcpViewBinding(pipelineOwner: null, semanticsOwner: null),
      ]),
    );
    two.attach(appId: 'two');
    expect(two.viewProvider.getViews(), hasLength(2));
  });
}

final class _FakePage implements WebMcpPageSessionClient {
  _FakePage(this.scopeReference);

  @override
  final String scopeReference;

  bool eligible = true;
  int revision = 1;

  @override
  int get currentRevision => revision;

  @override
  bool get isEligibleForObservation => eligible;

  @override
  void detachForSession() {
    eligible = false;
  }

  @override
  void requestSessionRecapture() {}

  @override
  void revokeForSession(WebMcpPageErrorCode reason) {
    eligible = false;
    revision++;
  }
}

final class _FixedViewProvider implements WebMcpViewProvider {
  const _FixedViewProvider(this.views);

  final List<WebMcpViewBinding> views;

  @override
  List<WebMcpViewBinding> getViews() => views;
}
