# Research review — round 01

- Work item: 0014-example-feature-coverage
- Reviewed artifact: `wiki/work/0014-example-feature-coverage/00-research.md` plus its sub-reports
  `research/api-surface-coverage.md`, `research/browser-verification.md`,
  `research/generator-coverage.md`, checked against
  `wiki/work/0014-example-feature-coverage/02-criteria.md` (git revision `5601815`, working tree clean)
- Reviewer: research validator (Opus 5)
- Date: 2026-09-15

## Verdict

**CONDITIONAL**

The artifact's API-surface survey, exception/transport/observer/policy claims and generator claims
verify correctly against source, but one factual enumeration the browser criteria depend on is wrong,
the page-endpoint eligibility precondition that five criteria rely on is never established, the
Answer section overstates the browser evidence in a way its own body contradicts, and the only
non-in-repo option for a positive native reading was never considered.

## Verification performed

This reviewer had no shell tool in this session, so no command output can be pasted. All
verification below is direct file reading of the cited sources plus two external fetches. Every
line reference in the findings was opened and read.

Sources opened to check the artifact's claims:

- `lib/webmcp_flutter.dart` (11 export lines), `lib/src/page/page.dart:4-15` — export barrel and page
  `show` list.
- `lib/src/webmcp.dart` — `addRegistryObserver:73`, `registerTool:88`, `registerSource:104`,
  `unregisterTool:111`, `tools:125`, `invokeTool:134`, `reset:150`, `transportId:175`,
  `WebMcpRegistryObserver:10`, `WebMcpRegistrySubscription:19`, `WebMcpRegistryResetObserver:44`.
  All match the artifact's citations.
- `lib/src/webmcp_tool.dart:13-29,32-58`, `lib/src/webmcp_tool_source.dart:4-7`,
  `lib/src/webmcp_scope.dart:22-58`, `lib/src/webmcp_exceptions.dart:1-46`,
  `lib/src/widgets/webmcp_screen.dart:6-41`, `lib/src/widgets/webmcp_action.dart:56-58`. All match.
- `lib/src/page/webmcp_page_protocol.dart` — 18 error codes incl. `staleSnapshot:27`,
  `unknownHandle:33`, `actionUnavailable:39`; `WebMcpPageLimits:128-242`; `WebMcpPagePolicy:245-303`
  with exactly eight configurable fields and `maxTextLength` ceiling 4096. All match.
- `lib/src/page/webmcp_page.dart:21-30,100-121,300-348,569-599,601-616,493-507,975-983,1173-1181`.
- `lib/src/page/webmcp_app_session.dart:50-58,74,92-152,157-183`.
- `lib/src/transport/webmcp_transport.dart`, `webmcp_native_capabilities.dart:2-76`,
  `webmcp_native_publisher.dart:11-29,32-74`.
- `example/lib/main.dart`, `example/lib/example_screen.dart`, `example/lib/example_tools.dart`,
  `example/pubspec.yaml`; `Glob example/{lib,test}/**/*.dart` returns exactly four files, confirming
  `api-surface-coverage.md:30-32`.
- `packages/webmcp_flutter_annotations/lib/webmcp_flutter_annotations.dart`,
  `packages/webmcp_flutter_generator/{pubspec.yaml,build.yaml,README.md}`,
  `packages/webmcp_flutter_generator/example/{pubspec.yaml,lib/inventory_service.dart,test/live_instance_test.dart}`.
- `tools/check.sh` (seven stages, stage 6 = `flutter build web` for `example/` plus the generator
  fixture `build_runner build`), `README.md:581-582,606-612`.
- `wiki/product/webmcp-contract.md:85-101,103-114,116-144,146-157`,
  `wiki/work/0008-automatic-page-agent/05-transport-spike.md:80-113`.

External checks (the artifact cites no external source at all):

- `https://developer.chrome.com/docs/ai/webmcp` — WebMCP origin trial "from Chrome 149"; local
  development via `chrome://flags/#enable-webmcp-testing`; the stated security requirement is an
  origin-isolated document (disabled when `Origin-Agent-Cluster: ?0`) and the `tools` Permissions
  Policy defaulting to `self`. The page states no HTTPS-certificate or COOP/COEP requirement.
- Web search on current WebMCP browser status — origin trial running Chrome 149 to 156; API moved
  from `navigator.modelContext` to `document.modelContext` in July 2026 (consistent with
  `lib/src/transport/native_publisher_boundary_web.dart`).

## Findings

### F-001 — the runtime tool-name enumeration omits the automatic endpoints the registry actually holds

- Severity: BLOCKER
- Location: `wiki/work/0014-example-feature-coverage/00-research.md:44` (repeated in
  `research/browser-verification.md:63-69`)
- Criterion affected: AC-022, AC-023 (and AC-026's "tool list unchanged" re-read)
- Observation: the artifact states flatly "Registered tool names at runtime: `example.counter.read`,
  `example.counter.increment` (always), `example.screen.describe`, `example.screen.increment`".
  The running example registers more than those. `example/lib/main.dart:11` calls
  `session.attach(appId: 'example')`, and `lib/src/page/webmcp_app_session.dart:175-182` registers
  `example.app.observe` on the process-wide registry inside `attach`. `example/lib/example_screen.dart:48`
  wraps the home screen in `WebMcpPage(pageId: 'example.home')`, and
  `lib/src/page/webmcp_page.dart:575-590` registers `example.home.page.read` and
  `example.home.page.act` once the page becomes eligible (`webmcp_page.dart:314-318`); the details
  route adds `example.details.page.*` the same way (`example_screen.dart:104`). The on-screen list is
  built from `WebMcp.instance.tools` unfiltered (`example_screen.dart:45-47`), so every one of those
  names is displayed.
- Why it matters: AC-023 compares the on-screen list against a fixed name list and its negative case
  makes "a name present in the list that is not in the plan's fixed list" a failure. A fixed list
  derived from this enumeration fails browser verification for names the library registers by design.

### F-002 — the eligibility precondition for page endpoints and `WebMcpPage.sources` is never established

- Severity: IMPORTANT
- Location: `wiki/work/0014-example-feature-coverage/00-research.md:23`;
  `research/api-surface-coverage.md:61-67`
- Criterion affected: AC-003, AC-011, AC-012, AC-013, AC-014
- Observation: the artifact records only that the page endpoints "are registered but never invoked"
  and that `WebMcpPage.sources` is "always the default empty list". It never records what makes those
  registrations happen. `lib/src/page/webmcp_page.dart:104-120` binds the page to
  `WebMcpAppSession.activeSession` or records `scopeGone`; `:342-348` requires
  `session.isRouteEligible(route)`, which in `lib/src/page/webmcp_app_session.dart:107-140` requires a
  non-empty set of Navigator adapters with settled evidence and a single owning adapter; only after a
  successful capture (`webmcp_page.dart:304-318`) does `_registerToolsIfNeeded` run, and only then does
  `_replaceSources` (`:319-323,601-616`) register the `sources` tools.
- Why it matters: AC-003 and AC-011 through AC-014 all assume a widget test can pump a screen and
  then find or invoke `<pageId>.page.read` / `.page.act` / page-source names through the registry. A
  test harness without an attached session, an installed `WebMcpNavigatorAdapter` and a settled route
  registers none of those names, and the research gives the plan no warning of that.

### F-003 — the Answer section asserts a negative browser result the cited evidence does not contain

- Severity: IMPORTANT
- Location: `wiki/work/0014-example-feature-coverage/00-research.md:11`
- Criterion affected: none directly; frames AC-022 through AC-032 and the "Explicitly not required"
  section at `02-criteria.md:70-74`
- Observation: line 11 states that `document.modelContext` "only appeared with specific
  `--enable-features` flags over an HTTPS/COOP-COEP-isolated origin, never over a plain HTTP dev
  server in a stock Chrome install". `wiki/work/0008-automatic-page-agent/05-transport-spike.md:98-113`
  records only two launch configurations: the working flag set, and a failed probe using
  `--enable-features=WebMCPForTesting` alone. It contains no plain-HTTP-dev-server probe, so the
  "never over a plain HTTP dev server" clause is an asserted negative with no test behind it. The same
  artifact contradicts itself at line 42 ("A plain `flutter run -d chrome` HTTP dev server was never
  tested against this") and at line 69, and `research/browser-verification.md:97` marks the question
  `[UNRESOLVED]`.
- Why it matters: the Answer paragraph is the part a planner reads as settled, and it carries no
  `[UNVERIFIED]` marker for a claim the artifact's own body marks unresolved.

### F-004 — the only documented low-cost way to obtain a positive native reading was not considered

- Severity: IMPORTANT
- Location: `wiki/work/0014-example-feature-coverage/00-research.md:55` (options table, third row);
  `00-research.md:74-81` (Sources); `research/browser-verification.md:111-115,120-121`
- Criterion affected: none directly; determines the scope boundary at `02-criteria.md:70-74`
- Observation: the option set for obtaining native evidence is "hardened HTTPS/COOP-COEP fixture
  server" versus "do not try". Chrome's own documentation
  (`https://developer.chrome.com/docs/ai/webmcp`, read 2026-09-15) documents a local-development path
  — `chrome://flags/#enable-webmcp-testing` plus relaunch — and an origin trial available from Chrome
  149, and states the security requirement as an origin-isolated document plus the `tools` Permissions
  Policy, not a certificate-backed server or COOP/COEP headers. That option is never named, priced or
  rejected. Every entry in the Sources list (`00-research.md:74-81`) is an in-repo file; no external
  or vendor source on the browser surface was consulted for a question whose subject is an external
  browser.
- Why it matters: the entire Chrome-verification scope decision rests on the premise that a positive
  native reading is only reachable through a bespoke fixture server that is out of scope. That premise
  is not established, and one considered option is not a comparison.

### F-005 — two unresolved questions from the browser sub-report are dropped from the roll-up

- Severity: IMPORTANT
- Location: `research/browser-verification.md:132-133` versus
  `wiki/work/0014-example-feature-coverage/00-research.md:65-70`
- Criterion affected: none directly; supports AC-030 and AC-032
- Observation: the sub-report leaves open (a) whether `document.modelContext.getTools()` and
  `.executeTool()` are stable documented method names, and (b) whether any Chrome newer than the
  tested 152.0.7977.83 ships WebMCP without the experimental flags. Neither appears in the
  roll-up's Unresolved list, while the roll-up's claims at lines 11, 42 and 62 depend on the flag
  requirement still being current. External checking (see Verification performed) shows the surface is
  in an origin trial through Chrome 156, i.e. the currency question is live, not closed.
- Why it matters: `wiki/templates/00-research.md:37-40` states that a silently dropped question is not
  a valid output, and the dropped question is the one that governs what the Chrome walkthrough can
  expect to observe.

### F-006 — the two diagnostic maps are presented as disjoint when one contains the other

- Severity: IMPORTANT
- Location: `research/api-surface-coverage.md:76-77`; rolled up at
  `wiki/work/0014-example-feature-coverage/00-research.md:24`
- Criterion affected: AC-015, AC-030
- Observation: the artifact lists `WebMcpNativePublisherStatus.toDiagnosticMap()` and
  `WebMcpNativeCapabilities.toDiagnosticMap()` as two separate undemonstrated diagnostic surfaces.
  `lib/src/transport/webmcp_native_publisher.dart:65-73` spreads the capability map into the publisher
  map, so all four capability keys (`registrationSignalCleanup`, `cancelBeforeDispatch`,
  `invocationCancellationAfterCallbackStart`, `positiveWait`) are already publisher-map keys.
- Why it matters: AC-015 demands "one labelled row for every key of the publisher's diagnostic map,
  every key of the capability diagnostic map" and its negative case asserts that any label outside
  either map is absent. As written, satisfying it produces four duplicate labels, and a widget test
  asserting one row per key cannot pass on both readings.

### F-007 — the "full feature-by-feature table" omits exported public declarations

- Severity: IMPORTANT
- Location: `wiki/work/0014-example-feature-coverage/00-research.md:28`;
  `research/api-surface-coverage.md:36-78`
- Criterion affected: the work item's own question (`00-research.md:5`); no criterion covers the
  omitted items
- Observation: `lib/src/page/page.dart:4-13` exports `WebMcpEvidenceKind`,
  `webMcpPageProtocolVersion` and `webMcpMaxSafeInteger`; none appears as a table row.
  `lib/src/page/webmcp_app_session.dart:74,114,217` expose the public `activeSession`,
  `isRouteEligible` and `allocateScopeReference` members; `lib/src/transport/webmcp_native_capabilities.dart:12`
  exposes `WebMcpNativeCapabilities.chrome152`; `lib/src/transport/webmcp_native_publisher.dart:11-29`
  exposes six public top-level declarations including the mutable `webMcpNativeClock`. The table is
  nonetheless described as "Full feature-by-feature table" and the coverage estimate is stated as
  "roughly a third".
- Why it matters: the work item's question is whether the example demonstrates every public feature.
  A survey whose completeness claim is unsupported cannot answer it, and the omitted items appear in
  no criterion, so nothing downstream will catch them. `WebMcpEvidenceKind` is consumer-visible: its
  `.name` is returned in act receipts (`lib/src/page/webmcp_page.dart:1095`).

### F-008 — the generator fixture's `dependency_overrides` block, which AC-019 requires, is absent from the evidence

- Severity: IMPORTANT
- Location: `research/generator-coverage.md:94-106` (claim evidenced as "full pubspec and test file
  contents"); constraints repeat at `:161-164`
- Criterion affected: AC-019
- Observation: the description of `packages/webmcp_flutter_generator/example/pubspec.yaml` covers the
  dependencies and dev_dependencies but not lines 24-26, which are a `dependency_overrides` block
  pinning `webmcp_flutter_annotations` to `../../webmcp_flutter_annotations`. The same block exists at
  `packages/webmcp_flutter_generator/pubspec.yaml:23-25`, and the reason is visible at that file's
  line 14: the generator depends on the hosted `webmcp_flutter_annotations: ^0.1.0`. AC-019 requires
  an override in `example/pubspec.yaml` and its negative case asserts that removing it makes
  resolution fail, "which is the recorded reason the override is present" — no such reason is recorded
  in any of the four research files.
- Why it matters: AC-019 is the only criterion whose negative case rests on a stated causal reason,
  and that reason exists nowhere in the artifact under review even though it is directly checkable in
  the repository.

### F-009 — AC-021 attributes three supported features to the contract's deliberate-omissions list

- Severity: IMPORTANT
- Location: `wiki/work/0014-example-feature-coverage/02-criteria.md:34`
- Criterion affected: AC-021
- Observation: AC-021 requires "no demonstration of any item on the deliberate-omissions list of
  `wiki/product/webmcp-contract.md`, specifically ... no nested or parallel navigator adapter, no
  custom view provider and no custom session limits". `wiki/product/webmcp-contract.md:146-153` lists
  multiple-view operation, positive observation waits, generated route wrapping, generalized service
  proxies, framework-specific state adapters, custom data providers, back-gesture support, in-flight
  callback termination, deep schema immutability, transactional source registration, notification
  rollback, automatic custom-transport cleanup and non-web support. Nested or parallel navigator
  adapters, `WebMcpViewProvider` and `WebMcpPageLimits` are not on it; the research classifies them as
  genuine, lower-priority coverage gaps (`00-research.md:25-26`,
  `research/api-surface-coverage.md:90-91`), and `02-criteria.md:75-77` correctly separates them into a
  distinct out-of-scope bullet.
- Why it matters: AC-021 turns an out-of-scope choice into a contract prohibition, contradicting the
  research it is built on, and the same criterion is the one that polices scope creep.

### F-010 — `one automatic WebMcpPage` contradicts the sub-report it summarises

- Severity: NIT
- Location: `wiki/work/0014-example-feature-coverage/00-research.md:9`
- Criterion affected: none
- Observation: the example builds two pages, `example.home` (`example/lib/example_screen.dart:48-49`)
  and `example.details` (`:104-105`), as `research/api-surface-coverage.md:64` correctly records.

### F-011 — `registered unconditionally at startup` misplaces the imperative registration call site

- Severity: NIT
- Location: `research/browser-verification.md:64-65`
- Criterion affected: none
- Observation: `registerExampleTools` is called from `_ExampleScreenState.initState`
  (`example/lib/example_screen.dart:25`), not from `main` (`example/lib/main.dart:8-15`). Because the
  two tools are registered directly on the registry and never unregistered, a second mount of
  `ExampleScreen` would throw `WebMcpDuplicateToolException` (`lib/src/webmcp.dart:92-94`).

### F-012 — two non-exported helpers are listed as public API

- Severity: NIT
- Location: `research/api-surface-coverage.md:70`
- Criterion affected: none
- Observation: `webMcpPageError` and `webMcpPageSuccess` appear as coverage-table features, but
  `lib/src/page/page.dart:7-13` exports only `WebMcpPageErrorCode`, `WebMcpPageLimits`,
  `WebMcpPagePolicy`, `webMcpMaxSafeInteger` and `webMcpPageProtocolVersion` from that library. This
  contradicts the report's own exclusion rule for non-exported declarations at `:21-26`.

### F-013 — the coverage proportion is an estimate with no stated denominator

- Severity: NIT
- Location: `wiki/work/0014-example-feature-coverage/00-research.md:9`;
  `research/api-surface-coverage.md:9`
- Criterion affected: none
- Observation: "Roughly a third of the package's public surface" / "roughly a third of the exported
  public declarations" is given without a counting method. The table itself marks about twenty of its
  forty-two rows "no" and eight more "partial".

## Recurrence check

- Previous round: none — first round (`wiki/work/0014-example-feature-coverage/validation/` did not
  exist before this report)
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | research |
| F-002 | research |
| F-003 | research |
| F-004 | research |
| F-005 | research |
| F-006 | research |
| F-007 | research |
| F-008 | research |
| F-009 | plan (criteria) |
| F-010 | research |
| F-011 | research |
| F-012 | research |
| F-013 | research |
