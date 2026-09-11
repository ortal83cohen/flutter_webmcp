# Runtime semantics isolation spike

## Gate scope and precedence

This artifact executes baseline task 1.1 and observation task O1.1 only. It
applies the recorded supersession mapping as follows:

- AC-019 refines AC-001/AC-006 setup with one shared conceptual session and a
  distinct observer per Navigator. The fixture proves that a root observer does
  not receive a nested Navigator push.
- AC-020 refines route/modal activity. The fixture proves observer revocation,
  wrapped root-modal isolation, and fail-closed unwrapped root-modal behavior.
- AC-021 refines AC-005 invalidation. The fixture proves owner notification,
  changed permitted projection, detached stale nodes, and mount-token rejection
  of a late post-frame callback.
- AC-027 extends AC-009 resource requirements. The fixture proves semantic
  returned/visited/depth/UTF-8 byte bounds, but not every proposed session,
  observer, waiter, event-ring, operation, or deadline bound.
- AC-026 supersedes only the page-disposal delivery portion of AC-016. This
  spike has no app-owned operation implementation and therefore proves only
  that no new semantic dispatch occurs after target disable/disposal.
- All other AC-001/005/006/008/009/016 obligations remain in force.

## Verdict

**FAIL**

The release-safe identifier boundary, nearest-wrapper traversal, route/root
modal behavior, projection invalidation, disposal, action revalidation, and
semantic traversal bounds passed in real Chrome debug/profile/release runs on
Flutter 3.47.0 and 3.47.3. The gate still fails because multiple Flutter views,
actual PipelineOwner/SemanticsOwner replacement, interactive gesture
interruption, and the remaining AC-027 one-over-limit matrix were unavailable
or unproved. Per AC-001/AC-020/AC-021/AC-027, automatic semantics must remain
blocked; no global-root or ancestor-wide fallback is authorized.

## Exact environments

The path supplied as the baseline, `/Users/ortalcohen/flutter`, was inspected
without modification and did not match the stated baseline:

```text
$ /Users/ortalcohen/flutter/bin/flutter --version
Flutter 3.38.4 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 66dd93f9a2 (9 months ago) • 2025-12-03 14:56:10 -0800
Engine • hash 360877569ab6632a564a0a8a815b2e0fe5ae294a (revision a5cb96369e) (9 months ago) • 2025-12-03 20:56:06.000Z
Tools • Dart 3.10.3 • DevTools 2.51.1
$ git rev-parse HEAD
66dd93f9a27ffe2a9bfc8297506ce066ff51265f
```

It was not used as gate evidence. Two reversible detached shallow clones were
created under `/tmp`; `/Users/ortalcohen/flutter` was not mutated.

```text
$ git clone --branch 3.47.0 --depth 1 https://github.com/flutter/flutter.git /tmp/flutter-3.47.0-page-semantics
Note: switching to '4cf24164269a5ebf0c16a028a00727d0e77bbb05'.
$ /tmp/flutter-3.47.0-page-semantics/bin/flutter --version
Flutter 3.47.0 • channel [user-branch] • https://github.com/flutter/flutter.git
Framework • revision 4cf2416426 (4 weeks ago) • 2026-08-11 11:53:49 -0700
Engine • hash 59d54a2b2896a6bbf356c94b7fac7b9e235bdacd (revision 5f77625673) (29 days ago) • 2026-08-11 16:38:36.000Z
Tools • Dart 3.13.0 • DevTools 2.60.0
$ git rev-parse HEAD
4cf24164269a5ebf0c16a028a00727d0e77bbb05
```

```text
$ git clone --branch 3.47.3 --depth 1 https://github.com/flutter/flutter.git /tmp/flutter-3.47.3-page-semantics
Note: switching to 'e8113bf45620cbeb8aff64947ee4c93e16adb4cf'.
$ /tmp/flutter-3.47.3-page-semantics/bin/flutter --version
Flutter 3.47.3 • channel [user-branch] • https://github.com/flutter/flutter.git
Framework • revision e8113bf456 (6 days ago) • 2026-09-04 13:20:08 -0700
Engine • hash 0e228ec8c8d2abc9fcf1d053e8a40665bb859ec7 (revision 06a2e2a110) (6 days ago) • 2026-09-03 16:07:13.000Z
Tools • Dart 3.13.3 • DevTools 2.60.0
$ git rev-parse HEAD
e8113bf45620cbeb8aff64947ee4c93e16adb4cf
```

The browser and temporary driver were:

```text
Google Chrome 152.0.7977.83
ChromeDriver 152.0.7977.83 (79460ebecaa5625e57a5fb679a735659e73dc687-refs/branch-heads/7977@{#2323})
```

## Exact public methods used

The fixture uses only release-safe public runtime APIs for gate assertions:

- `SemanticsBinding.ensureSemantics()` and `SemanticsHandle.dispose()`.
- `RendererBinding.renderViews`, `RenderView.owner`,
  `PipelineOwner.semanticsOwner`, and `SemanticsOwner.rootSemanticsNode`.
- `SemanticsNode.identifier`, `SemanticsNode.visitChildren`,
  `SemanticsNode.getSemanticsData()`, `SemanticsNode.flagsCollection`,
  `SemanticsNode.attached`, and `SemanticsNode.isMergedIntoParent`.
- `SemanticsOwner.addListener()`, `SemanticsOwner.removeListener()`, and
  `SemanticsOwner.performAction()`.
- `SemanticsData.hasAction()` and `SemanticsAction.tap`.
- `NavigatorObserver.didPush()`, `didPop()`, `didChangeTop()`,
  `didStartUserGesture()`, and `didStopUserGesture()`.
- `TransitionRoute.animation`, `Animation.addStatusListener()`, and
  `Animation.removeStatusListener()`.
- `WidgetsBinding.addPostFrameCallback()`.

`RenderObject.debugSemantics` remains only in legacy diagnostic widget-test
helpers. Flutter source states that it always returns null in release. The
executable matrix resolves exact marker identifiers from the selected
SemanticsOwner root and does not call it.

## Reproducible fixture

The matrix entry point is
`spikes/page-semantics/integration_test/semantics_gate_test.dart`. The host
driver is `spikes/page-semantics/test_driver/integration_test.dart`. A matching
temporary ChromeDriver must listen on port 4444:

```text
$ /tmp/chromedriver-spike/chromedriver/mac_arm-152.0.7977.83/chromedriver-mac-arm64/chromedriver --port=4444
Starting ChromeDriver 152.0.7977.83 (79460ebecaa5625e57a5fb679a735659e73dc687-refs/branch-heads/7977@{#2323}) on port 4444
Only local connections are allowed.
Please see https://chromedriver.chromium.org/security-considerations for suggestions on keeping ChromeDriver safe.
ChromeDriver was started successfully on port 4444.
```

For either SDK, substitute its absolute `flutter` path:

```text
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/semantics_gate_test.dart -d web-server --debug --driver-port=4444 --timeout=300
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/semantics_gate_test.dart -d web-server --profile --driver-port=4444 --timeout=300
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/semantics_gate_test.dart -d web-server --release --driver-port=4444 --timeout=300
```

## Per-case results

- `ownership-siblings-ambiguity`: **PASS** on all six runs. Unique markers
  resolve exactly once, sibling node IDs/labels do not overlap, and duplicate
  markers return boundary unavailable.
- `nested-nearest-owner`: **PASS** on all six runs. Flutter's raw parent walk
  reaches the nested scope, while the bounded owned walk stops at the nested
  marker. The nested scope remains independently accessible.
- `merge-exclude-block-obscured`: **PASS** on all six runs. Merged labels are
  represented by Flutter, excluded content is absent, `BlockSemantics` removes
  earlier sibling semantics, and the safe record omits the obscured value.
- `route-root-modal-transition`: **PASS** on all six runs. Both package and
  consumer observers receive navigation callbacks; revocation occurs in the
  callback; a wrapped root modal has its own marker; an unwrapped root modal
  exposes no opted-in marker; the covered page marker is absent while blocked.
- `navigator-forest`: **PASS** on all six runs. A nested push reaches its own
  observer and not the root observer, proving that one root adapter is
  insufficient.
- `projection-disposal-late-callback`: **PASS** on all six runs. Changed
  permitted labels produce a changed projection and owner notification; the
  old node detaches; a mount-generation check rejects a queued post-frame
  callback after disposal.
- `action-revalidation`: **PASS** on all six runs. An advertised tap dispatches
  once. After disabling and refreshing the node, tap is no longer advertised
  and `performAction` produces no callback.
- `resource-limits`: **PASS** for the semantic traversal subset on all six
  runs. Returned nodes stop at 200, visited traversal stops when the
  one-over observation reaches 101 for a limit of 100, depth stops at 32, and
  exact UTF-8 exposed-string accounting stays within 512 bytes.
- `multiple-views`: **UNAVAILABLE** on all six runs. Chrome supplied one
  `RenderView`; no second `FlutterView` was created.
- `semantics-owner-replacement`: **UNAVAILABLE** on all six runs. Listener
  notification was proved, but the fixture had no public hook to replace the
  live `RenderView`'s `PipelineOwner`.
- `interactive-gesture-interruption`: **UNAVAILABLE** on all six runs.
  Headless Chrome did not provide a platform back gesture. Observer methods
  compile and are registered, but compilation is not runtime proof.
- Remaining AC-027 caps for 128 scopes, 32 Navigator adapters, event ring,
  waits, operation retention, coalesced queued capture, and two-second
  no-frame timeout: **NOT RUN / FAIL FOR THIS GATE**. Those runtime/session
  components do not exist in this spike, so protective values were not treated
  as observed behavior.

## Raw matrix output

Flutter 3.47.0 / Dart 3.13.0 debug:

```text
Formatted 16 files (0 changed) in 0.10 seconds.
Analyzing page-semantics...
No issues found! (ran in 7.7s)
Launching integration_test/semantics_gate_test.dart on Web Server in debug mode...
Waiting for connection from debug service on Web Server...         21.6s
All tests passed.
EVIDENCE|ownership-siblings-ambiguity|PASS|unique markers isolate siblings; duplicate marker resolves unavailable
EVIDENCE|nested-nearest-owner|PASS|raw parent reaches child marker; bounded walk stops before nested scope
EVIDENCE|merge-exclude-block-obscured|PASS|merged labels retained; excluded and blocked secrets absent; obscured value omitted
EVIDENCE|route-root-modal-transition|PASS|observer revokes; wrapped root modal is isolated; unwrapped modal exposes no scope
EVIDENCE|navigator-forest|PASS|nested push reaches nested observer only; root adapter alone is incomplete
EVIDENCE|projection-disposal-late-callback|PASS|projection changed; owner notified; old node detached; token rejected late callback
EVIDENCE|action-revalidation|PASS|advertised tap dispatched once; disabled target rejected after refresh
EVIDENCE|resource-limits|PASS|returned=200 visited-stop=101 depth=32 bytes<=512 with explicit reasons
EVIDENCE|multiple-views|UNAVAILABLE|renderViews=1; fixture runner did not provide a second FlutterView
EVIDENCE|semantics-owner-replacement|UNAVAILABLE|owner notifications proved; no public fixture hook replaced the RenderView PipelineOwner
EVIDENCE|interactive-gesture-interruption|UNAVAILABLE|headless Chrome did not provide a platform back gesture
Application finished.
```

Flutter 3.47.0 / Dart 3.13.0 profile:

```text
Launching integration_test/semantics_gate_test.dart on Web Server in profile mode...
Compiling integration_test/semantics_gate_test.dart for the Web...        22.8s
✓ Built build/web
All tests passed.
EVIDENCE|ownership-siblings-ambiguity|PASS|unique markers isolate siblings; duplicate marker resolves unavailable
EVIDENCE|nested-nearest-owner|PASS|raw parent reaches child marker; bounded walk stops before nested scope
EVIDENCE|merge-exclude-block-obscured|PASS|merged labels retained; excluded and blocked secrets absent; obscured value omitted
EVIDENCE|route-root-modal-transition|PASS|observer revokes; wrapped root modal is isolated; unwrapped modal exposes no scope
EVIDENCE|navigator-forest|PASS|nested push reaches nested observer only; root adapter alone is incomplete
EVIDENCE|projection-disposal-late-callback|PASS|projection changed; owner notified; old node detached; token rejected late callback
EVIDENCE|action-revalidation|PASS|advertised tap dispatched once; disabled target rejected after refresh
EVIDENCE|resource-limits|PASS|returned=200 visited-stop=101 depth=32 bytes<=512 with explicit reasons
EVIDENCE|multiple-views|UNAVAILABLE|renderViews=1; fixture runner did not provide a second FlutterView
EVIDENCE|semantics-owner-replacement|UNAVAILABLE|owner notifications proved; no public fixture hook replaced the RenderView PipelineOwner
EVIDENCE|interactive-gesture-interruption|UNAVAILABLE|headless Chrome did not provide a platform back gesture
Application finished.
```

Flutter 3.47.0 / Dart 3.13.0 release:

```text
Launching integration_test/semantics_gate_test.dart on Web Server in release mode...
Compiling integration_test/semantics_gate_test.dart for the Web...        19.7s
✓ Built build/web
All tests passed.
EVIDENCE|ownership-siblings-ambiguity|PASS|unique markers isolate siblings; duplicate marker resolves unavailable
EVIDENCE|nested-nearest-owner|PASS|raw parent reaches child marker; bounded walk stops before nested scope
EVIDENCE|merge-exclude-block-obscured|PASS|merged labels retained; excluded and blocked secrets absent; obscured value omitted
EVIDENCE|route-root-modal-transition|PASS|observer revokes; wrapped root modal is isolated; unwrapped modal exposes no scope
EVIDENCE|navigator-forest|PASS|nested push reaches nested observer only; root adapter alone is incomplete
EVIDENCE|projection-disposal-late-callback|PASS|projection changed; owner notified; old node detached; token rejected late callback
EVIDENCE|action-revalidation|PASS|advertised tap dispatched once; disabled target rejected after refresh
EVIDENCE|resource-limits|PASS|returned=200 visited-stop=101 depth=32 bytes<=512 with explicit reasons
EVIDENCE|multiple-views|UNAVAILABLE|renderViews=1; fixture runner did not provide a second FlutterView
EVIDENCE|semantics-owner-replacement|UNAVAILABLE|owner notifications proved; no public fixture hook replaced the RenderView PipelineOwner
EVIDENCE|interactive-gesture-interruption|UNAVAILABLE|headless Chrome did not provide a platform back gesture
Application finished.
```

Flutter 3.47.3 / Dart 3.13.3 debug:

```text
Analyzing page-semantics...
No issues found! (ran in 13.8s)
Launching integration_test/semantics_gate_test.dart on Web Server in debug mode...
Waiting for connection from debug service on Web Server...         21.0s
All tests passed.
EVIDENCE|ownership-siblings-ambiguity|PASS|unique markers isolate siblings; duplicate marker resolves unavailable
EVIDENCE|nested-nearest-owner|PASS|raw parent reaches child marker; bounded walk stops before nested scope
EVIDENCE|merge-exclude-block-obscured|PASS|merged labels retained; excluded and blocked secrets absent; obscured value omitted
EVIDENCE|route-root-modal-transition|PASS|observer revokes; wrapped root modal is isolated; unwrapped modal exposes no scope
EVIDENCE|navigator-forest|PASS|nested push reaches nested observer only; root adapter alone is incomplete
EVIDENCE|projection-disposal-late-callback|PASS|projection changed; owner notified; old node detached; token rejected late callback
EVIDENCE|action-revalidation|PASS|advertised tap dispatched once; disabled target rejected after refresh
EVIDENCE|resource-limits|PASS|returned=200 visited-stop=101 depth=32 bytes<=512 with explicit reasons
EVIDENCE|multiple-views|UNAVAILABLE|renderViews=1; fixture runner did not provide a second FlutterView
EVIDENCE|semantics-owner-replacement|UNAVAILABLE|owner notifications proved; no public fixture hook replaced the RenderView PipelineOwner
EVIDENCE|interactive-gesture-interruption|UNAVAILABLE|headless Chrome did not provide a platform back gesture
Application finished.
```

Flutter 3.47.3 / Dart 3.13.3 profile:

```text
Launching integration_test/semantics_gate_test.dart on Web Server in profile mode...
Compiling integration_test/semantics_gate_test.dart for the Web...        23.2s
✓ Built build/web
All tests passed.
EVIDENCE|ownership-siblings-ambiguity|PASS|unique markers isolate siblings; duplicate marker resolves unavailable
EVIDENCE|nested-nearest-owner|PASS|raw parent reaches child marker; bounded walk stops before nested scope
EVIDENCE|merge-exclude-block-obscured|PASS|merged labels retained; excluded and blocked secrets absent; obscured value omitted
EVIDENCE|route-root-modal-transition|PASS|observer revokes; wrapped root modal is isolated; unwrapped modal exposes no scope
EVIDENCE|navigator-forest|PASS|nested push reaches nested observer only; root adapter alone is incomplete
EVIDENCE|projection-disposal-late-callback|PASS|projection changed; owner notified; old node detached; token rejected late callback
EVIDENCE|action-revalidation|PASS|advertised tap dispatched once; disabled target rejected after refresh
EVIDENCE|resource-limits|PASS|returned=200 visited-stop=101 depth=32 bytes<=512 with explicit reasons
EVIDENCE|multiple-views|UNAVAILABLE|renderViews=1; fixture runner did not provide a second FlutterView
EVIDENCE|semantics-owner-replacement|UNAVAILABLE|owner notifications proved; no public fixture hook replaced the RenderView PipelineOwner
EVIDENCE|interactive-gesture-interruption|UNAVAILABLE|headless Chrome did not provide a platform back gesture
Application finished.
```

Flutter 3.47.3 / Dart 3.13.3 release:

```text
Launching integration_test/semantics_gate_test.dart on Web Server in release mode...
Compiling integration_test/semantics_gate_test.dart for the Web...        21.7s
✓ Built build/web
All tests passed.
EVIDENCE|ownership-siblings-ambiguity|PASS|unique markers isolate siblings; duplicate marker resolves unavailable
EVIDENCE|nested-nearest-owner|PASS|raw parent reaches child marker; bounded walk stops before nested scope
EVIDENCE|merge-exclude-block-obscured|PASS|merged labels retained; excluded and blocked secrets absent; obscured value omitted
EVIDENCE|route-root-modal-transition|PASS|observer revokes; wrapped root modal is isolated; unwrapped modal exposes no scope
EVIDENCE|navigator-forest|PASS|nested push reaches nested observer only; root adapter alone is incomplete
EVIDENCE|projection-disposal-late-callback|PASS|projection changed; owner notified; old node detached; token rejected late callback
EVIDENCE|action-revalidation|PASS|advertised tap dispatched once; disabled target rejected after refresh
EVIDENCE|resource-limits|PASS|returned=200 visited-stop=101 depth=32 bytes<=512 with explicit reasons
EVIDENCE|multiple-views|UNAVAILABLE|renderViews=1; fixture runner did not provide a second FlutterView
EVIDENCE|semantics-owner-replacement|UNAVAILABLE|owner notifications proved; no public fixture hook replaced the RenderView PipelineOwner
EVIDENCE|interactive-gesture-interruption|UNAVAILABLE|headless Chrome did not provide a platform back gesture
Application finished.
```

## Failed and unavailable execution attempts

Direct `flutter drive -d chrome --debug` did not progress beyond connecting and
was terminated; it is not counted as evidence. Direct integration execution
also failed explicitly:

```text
$ /tmp/flutter-3.47.0-page-semantics/bin/flutter test integration_test/semantics_gate_test.dart -d chrome --reporter expanded --timeout 5m
Web devices are not supported for integration tests yet.
```

The documented Web integration path, `flutter drive -d web-server` with a
matching external ChromeDriver, produced the six successful executable runs
above.

## Gate decision and fallback

The tested marker/traversal approach is promising but **not approved for an API
freeze or automatic-semantics shipping**. Missing evidence is a gate failure,
not a caveat. Until a later append-only spike proves multiple views, owner
replacement, interactive gesture interruption, and the complete applicable
resource matrix on the supported SDK range:

- a missing or duplicate marker returns `boundaryUnavailable`;
- an unknown Navigator/branch/modal/transition relationship remains inactive;
- no ancestor, global-root, or other-view search substitutes for failed scope
  lookup;
- explicit application tools remain the only supported fallback.

## Formatting and wiki lint

The final owned Dart format check produced:

```text
$ /tmp/flutter-3.47.0-page-semantics/bin/dart format lib test integration_test test_driver
Formatted 16 files (0 changed) in 0.23 seconds.
```

The wiki linter run after writing this evidence produced:

```text
$ python3 tools/lint_wiki.py
lint_wiki: clean (0 warning(s)).
```

DTD discovery found no live app connected to the Cursor tooling daemon after
the matrix completed, so no additional hot reload/restart was available. The
six `flutter drive` commands each launched and terminated a fresh real Chrome
app build.
