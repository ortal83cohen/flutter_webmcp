# Tasks: Example app covers every webmcp_flutter feature and is verified in Chrome

Round 2. Replaces the round-1 task list in full.

## Legend

- `[P]` — may run in a parallel subagent. A task is marked `[P]` only when no other `[P]` task in
  the same group touches any of the same files **and** no other `[P]` task in the same group defines
  a class it imports or constructs. Every cross-task interface is already fixed in
  `01-plan.md`'s interfaces section.
- Every task cites the criteria it satisfies. The criterion-ownership table below names exactly one
  owning task per criterion; a task may also contribute to a criterion owned elsewhere.
- Owned files are exclusive. Two tasks never list the same file. A task that discovers a needed
  change in a file it does not own requests it from that file's owner rather than editing it.

## Groups

Groups run in sequence. Tasks within a group run in the order listed, except that consecutive `[P]`
tasks may run concurrently.

### Group 1 — Generated domain-action slice

Runs first because it changes dependency resolution and adds a checked-in generated file that
every later group compiles against.

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 1.1 | Add the annotations path dependency, the build-runner and generator dev dependencies and the non-transitive annotations override to the example's pubspec; add the unconditional analyzer exclusion for the generated path; write the annotated task service with two annotated methods and one unannotated public method; run the generator; check in and format the generated adapter; write the generated-source test | AC-029, AC-030, AC-031, AC-032, AC-033 | `example/pubspec.yaml`, `example/analysis_options.yaml`, `example/lib/example_task_service.dart`, `example/lib/example_task_service.webmcp.g.dart`, `example/test/example_task_service_test.dart` | | Dependency resolution picks the in-repo annotations package, the generated file is tracked and reproducible, and the test asserts the two generated names, the schema's required title, both annotation flags, the authorization refusal and the absence of the unannotated method |

**Task 1.1 status: done (2026-09-15).** All five owned files are in place; `cd example && flutter test test/example_task_service_test.dart` passes six tests, `dart format --set-exit-if-changed example/lib` and `dart analyze --fatal-infos --fatal-warnings example/lib` are clean, and `dart run build_runner build` followed by `dart format example/lib` reproduces the checked-in generated adapter byte-for-byte (`git diff --exit-code example/lib` is empty).

### Group 2 — Counter shape

Sequential and alone in its group because every task in Group 3 imports `ExampleCounter`.

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 2.1 | Reshape `ExampleCounter` into a notifier with a read-only value getter and exactly three mutators (add one, add an amount, reset), keep `registerExampleTools` registering the two original names against it, and update the existing test | contributes to AC-002, AC-026 | `example/lib/example_tools.dart`, `example/test/example_tools_test.dart` | | The three mutators and their notifications are covered by the test, and the two original tool names are unchanged |

**Task 2.1 status: done (2026-09-15).** `ExampleCounter` is now a `ChangeNotifier` with a private `_value` field, a read-only `value` getter and three mutators — `increment()`, `incrementBy(int amount)` and `reset()` — each calling `notifyListeners()`. `incrementBy` documents that a non-positive `amount` throws `ArgumentError` (the chosen contract for Group 3's tool source to catch or pre-validate against). `registerExampleTools` is unchanged in behaviour, still registering `example.counter.read` and `example.counter.increment`. `cd example && flutter test test/example_tools_test.dart` passes five tests (including the new amount and reset coverage with listener-fire assertions); `dart format --set-exit-if-changed example/lib/example_tools.dart example/test/example_tools_test.dart` and `dart analyze --fatal-infos --fatal-warnings example/lib/example_tools.dart` are both clean.

### Group 3 — Independent manual-API building blocks

All four tasks import only `example_tools.dart` (Group 2) and the package's public surface. None
imports or constructs a class another task in this group defines, and no two share a file.

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 3.1 | Write the hand-written tool source over the live counter with three descriptors, a non-default input schema on the amount-taking one, non-default annotations on all three, and self-validating arguments that return a failure envelope rather than throwing | AC-002, contributes to AC-001, AC-003 | `example/lib/example_counter_source.dart`, `example/test/example_counter_source_test.dart` | `[P]` | The test asserts the three names, the non-empty schema, the annotation flags, a successful amount increment and a rejected out-of-range amount leaving the counter unchanged |

**Task 3.1 status: done (2026-09-15).** `ExampleCounterSource` implements `WebMcpToolSource` over a live `ExampleCounter`, returning `example.source.counter.read` (read-only hint), `example.source.counter.add` (non-empty object schema requiring integer `amount`, consequential hint) and `example.source.counter.reset` (consequential hint). The add handler validates `amount` is a strictly-positive `int` itself and returns the `{'ok': false, 'error': {'code': 'invalidArguments', ...}}` envelope for zero, negative or missing amounts, calling `incrementBy` only after that check passes, with a defensive `on ArgumentError` catch around the call that also returns the same envelope rather than propagating. `cd example && flutter test test/example_counter_source_test.dart` passes seven tests; `dart format --set-exit-if-changed example/lib/example_counter_source.dart example/test/example_counter_source_test.dart` and `dart analyze --fatal-infos --fatal-warnings example/lib/example_counter_source.dart` are both clean.
| 3.2 | Write the recording transport reporting the fixed identifier and counting registrations, unregistrations and the most recent registered name | AC-004 | `example/lib/example_recording_transport.dart`, `example/test/example_recording_transport_test.dart` | `[P]` | The test installs it through the registry reset, asserts the identifier and both counters, and asserts a plain reset restores the default identifier |

**Task 3.2 status: done (2026-09-15).** `ExampleRecordingTransport implements WebMcpTransport`, reports the fixed identifier `example-recording`, and exposes read-only `registrationCount`, `unregistrationCount` and `lastRegisteredName` (nullable until the first registration). `cd example && flutter test test/example_recording_transport_test.dart` passes two tests: installing the transport via `WebMcp.instance.reset(transport)` then registering and unregistering a probe tool asserts the identifier and both counters; a second test asserts a plain `WebMcp.instance.reset()` restores the platform default identifier `noop`. `dart format --set-exit-if-changed example/lib/example_recording_transport.dart example/test/example_recording_transport_test.dart` and `dart analyze --fatal-infos --fatal-warnings example/lib/example_recording_transport.dart` are both clean.
| 3.3 | Write the registry log as a notifier implementing both the registry observer and the reset observer, retaining the most recent sixty-four lines and counting resets | AC-006, AC-007, contributes to AC-005 | `example/lib/example_registry_log.dart`, `example/test/example_registry_log_test.dart` | `[P]` | The test covers both notification directions, the eviction boundary at sixty-four and sixty-five events, the reset hook and the subscription becoming inactive |

**Task 3.3 status: done (2026-09-15).** `ExampleRegistryLog` is a `ChangeNotifier` implementing `WebMcpRegistryObserver` and `WebMcpRegistryResetObserver`, appending one human-readable line per registration, unregistration and reset (via `onRegistryReset`, which also increments a `resetCount`), retaining only the most recent 64 lines (`retentionBound`) and calling `notifyListeners()` on every append. `cd example && flutter test test/example_registry_log_test.dart` passes four tests covering both notification directions, the exact 64/65-event eviction boundary, the reset hook with its counter and inactive subscription, and a cancelled subscription receiving neither a reset nor a later registration line. `dart format --set-exit-if-changed example/lib/example_registry_log.dart example/test/example_registry_log_test.dart` and `dart analyze --fatal-infos --fatal-warnings example/lib/example_registry_log.dart` are both clean.
| 3.4 | Write the exception demonstration producing three caught-exception lines plus one unscoped screen-scope lookup line, and its test including the action-without-scope case captured through the tester | AC-009, contributes to AC-008, AC-010 | `example/lib/example_exception_demo.dart`, `example/test/example_exception_demo_test.dart` | `[P]` | The test asserts the three caught exception types, the fourth line reporting no scope, the missing-scope exception from an unscoped action widget, and the absence of that exception when the same action is built inside a screen scope |

**Task 3.4 status: done (2026-09-15).** `example/lib/example_exception_demo.dart` exposes `triggerAndCatchExceptions()` — an async, context-free function that triggers and catches, in order, an invalid tool name registration, a duplicate tool registration (cleaning up the tool it registers so repeat calls are stable) and an invocation of a never-registered tool, returning one transcript line per caught exception naming its runtime type and the offending tool name — plus `describeUnscopedLookup(BuildContext)`, a small pure function wrapping `WebMcpScreen.maybeScopeOf` for the fourth line, split out because that lookup genuinely needs a `BuildContext` a plain Dart function cannot manufacture; this split is documented in the file's doc comments and consumed by the exception screen (5.3). `cd example && flutter test test/example_exception_demo_test.dart` passes six tests, including a `WebMcpAction` built with no enclosing `WebMcpScreen` raising `WebMcpScopeMissingException` (captured via `tester.takeException()`) and the identical action built inside a local `WebMcpScreen`-mixin host raising nothing and registering its tool. `dart format --set-exit-if-changed lib/example_exception_demo.dart test/example_exception_demo_test.dart` and `dart analyze --fatal-infos --fatal-warnings lib/example_exception_demo.dart` (run from `example/`) are both clean.

### Group 4 — Runtime and test harness

One task, no parallelism: this is the shared hotspot where the startup order, the session and the
Navigator adapter parameters get their single definition, together with the test-side harness that
reproduces the page-eligibility preconditions.

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 4.1 | Write the runtime class owning the counter, task service, transport, registry log, session, publisher and observer subscription, with the fixed startup order, the root Navigator adapter factory and a disposal method; write the test support library holding the harness, the shared setUp and tearDown discipline, and the read-and-locate-by-label helpers; write the runtime test | AC-001, AC-005 | `example/lib/example_runtime.dart`, `example/test/example_test_support.dart`, `example/test/example_runtime_test.dart` | | The runtime test asserts the twelve startup registrations in order and the first and last names, the harness reaches page eligibility (a page's read and act names are registered after five pumped frames), and a second test in the same file passes without a session resource-limit failure |

### Group 5 — Demonstration screens

Three independent screens. No screen imports another, each owns its own test file, and every
constructor parameter list is already fixed in `01-plan.md`. All three consume the Group 4 harness
read-only.

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 5.1 | Write the agent probe with the incrementing request-identifier rule, the retry-on-stale-snapshot loop, the attempt budget and the single-shot before-first-act callback; write the form screen with the fully non-default page policy and one labelled node per policy behaviour, the probe buttons and the transcript view; write their test against the shared harness | AC-012, AC-013, AC-014, AC-015, AC-016, AC-017, AC-018, AC-019, AC-039 | `example/lib/example_agent_probe.dart`, `example/lib/example_form_screen.dart`, `example/test/example_form_screen_test.dart` | `[P]` | The test asserts the eight policy values, both omitted subtrees, the omitted non-editable value, the bounds field, a successful and a refused text set, an advertised and dispatched long press, a dispatched scroll, strictly increasing request identifiers across a retry, a single-attempt run ending in the stale-snapshot code, and no coverage truncation |

**Task 5.1 status: done (2026-09-15).** `ExampleAgentProbe.run` performs the read-then-act round trip: a private counter starting at one is consumed on every act attempt (including retries), `beforeFirstAct` (typed `Future<void> Function()?` so a caller may drive real widget-tester gestures and frame pumps from it) fires once immediately before the first act and is then cleared, and an attempt is retried only on the stale-snapshot code up to `maxAttempts`. `ExampleFormScreen` carries a `WebMcpPage` with a fully non-default `WebMcpPagePolicy` (`allowLongPress`, `includeBounds` true; `includeNonEditableValues` false; `maxTextLength` 120; all four identifier sets populated) and six labelled semantics nodes — Note field, Archive note, Note history, Save status, Excluded panel, Secret panel — plus two probe-demonstration buttons, a third test-only "Force content change" button (documented in the file: it changes visible content with no involvement of the act protocol, because any real `.page.act` call before the probe's own first attempt, which always starts at request identifier one, would make that first attempt look reused rather than stale), and a transcript view. Node labels that had a `Text` descendant initially merged into the parent's semantics label (e.g. `"Archive note\nNot archived"`); fixed by moving each descriptive `Text` to a sibling position, matching the Note field's already-working shape. `cd example && flutter test test/example_form_screen_test.dart` passes eight tests; `dart format --set-exit-if-changed example/lib/example_agent_probe.dart example/lib/example_form_screen.dart example/test/example_form_screen_test.dart` and `dart analyze --fatal-infos --fatal-warnings example/lib/example_agent_probe.dart example/lib/example_form_screen.dart` are both clean.
| 5.2 | Write the diagnostics screen rendering the publisher map once under the prefixed one-row-per-key rule with empty lists shown as `none`, the nine named session getters, the transport identifier and counters, the page protocol version, and the two observe buttons; write its test | AC-021, AC-022, AC-023, AC-024, AC-025 | `example/lib/example_diagnostics_screen.dart`, `example/test/example_diagnostics_screen_test.dart` | `[P]` | The test asserts the publisher row count with no duplicated capability row, the `none` rendering, the nine session names with no tenth, a successful observe response with a non-empty cursor, and a positive-wait response carrying the unsupported-wait code and both wait-capability fields |

**Task 5.2 status: done (2026-09-15).** `ExampleDiagnosticsScreen(runtime)` renders the publisher's `toDiagnosticMap()` once, one `Text` row per key keyed `ValueKey('publisher.<key>')`; an empty list (e.g. `reasonCodes` with no failures) renders the literal `none`. The nine session getters (`isAttached`, `ownsObserveTool`, `appMount`, `liveScopeCount`, `navigatorAdapterCount`, `routeEvidenceReady`, `retainedEventCount`, `retainedOperationCount`, `outstandingExecutionCount`) render as `session.<name>` rows, and the transport's `id`/`registrationCount`/`unregistrationCount` render as `transport.<name>` rows. `webMcpPageProtocolVersion` renders as its own row. Two buttons invoke `example.app.observe` — one with no arguments, one with `waitMs: 250` — each showing the decoded response (`ok`, `code`, `cursor`, and both `waitCapability` fields when present) in a keyed `Text`. `cd example && flutter test test/example_diagnostics_screen_test.dart` passes five tests: the publisher row count matches the diagnostic map's key count with each of the four capability keys appearing exactly once; an uninstalled runtime's never-attached publisher (the only way to observe an empty `reasonCodes` set under the Flutter test runner, since an attached publisher always carries `browserUnavailable` there) renders `publisher.reasonCodes: none`; exactly nine `session.`-prefixed rows render with the tenth absent; a tap on the plain-observe button shows `ok: true` with a non-empty `cursor`; a tap on the positive-wait button shows `ok: false`, `code: unsupportedWait`, `waitCapability.positiveWaitSupported: false` and `waitCapability.maxWaitMs: 0`. `dart format --set-exit-if-changed example/lib/example_diagnostics_screen.dart example/test/example_diagnostics_screen_test.dart` and `dart analyze --fatal-infos --fatal-warnings example/lib/example_diagnostics_screen.dart` (and the test file) are both clean.
| 5.3 | Write the exception screen rendering the demonstration transcript, without the screen-scope mixin so its scope lookup is genuinely unscoped; write its test | AC-008, contributes to AC-010 | `example/lib/example_exception_screen.dart`, `example/test/example_exception_screen_test.dart` | `[P]` | The test asserts the three exception type names and the no-scope line are on screen and that no uncaught framework exception is raised while the screen is displayed |

**Task 5.3 status: done (2026-09-15).** `ExampleExceptionScreen` is a `StatefulWidget` (no `WebMcpScreen` mixin) that runs `triggerAndCatchExceptions()` once in `initState`, holds the resulting transcript, and on build appends the fourth line from `describeUnscopedLookup(context)` using its own (genuinely unscoped) `BuildContext`, rendering all four lines as `Text` widgets in a `Scaffold`/`ListView`. `cd example && flutter test test/example_exception_screen_test.dart` passes one test asserting all three exception type names and the "no scope" line are present via `find.textContaining` after `pumpAndSettle`, and that `tester.takeException()` is `null`. `dart format --set-exit-if-changed example/lib/example_exception_screen.dart example/test/example_exception_screen_test.dart` and `dart analyze --fatal-infos --fatal-warnings example/lib/example_exception_screen.dart` are both clean.

### Group 6 — Home screen and entry point

One task, no parallelism: it imports all three Group 5 screens and the Group 4 runtime, and the two
files must change together.

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 6.1 | Rewire the home screen to take the runtime as its single argument, stop registering the counter tools from its own initState, render the tool list with annotation and schema markers, the scope's owned and skipped names, the positive scope lookup from a builder inside its subtree, the recent log lines, the task panel, the invoke buttons and the home-page read button; add navigation to the three new screens and keep the details route; rewire the entry point to build, install and dispose the runtime; write the home-screen test | AC-003, AC-010, AC-011, AC-020, AC-026, AC-027, AC-028 | `example/lib/example_screen.dart`, `example/lib/main.dart`, `example/test/example_home_screen_test.dart` | | The test asserts the exact twelve-name list, the marker rules, the owned and skipped names, the positive scope lookup, a successful direct home-page read and its invalid-argument rejection, the appearance and disappearance of a pushed page's two endpoints across a push and a pop with the screen-owned names present throughout, and the covered-page failure code |

**Task 6.1 status: done (2026-09-15).** `ExampleScreen` now takes exactly one required `runtime` argument and no longer registers the imperative counter tools from `initState` (registered once by `ExampleRuntime.install()`). It renders the unfiltered `WebMcp.instance.tools` list with `[ro]`/`[uc]`/`[cq]`/`[schema]` line markers, the screen scope's owned/skipped names (with a deliberate re-registration of the already-application-owned `example.counter.read`, which is skipped rather than thrown, populating the skipped list), a positive `WebMcpScreen.maybeScopeOf` lookup from a `Builder` inside the home subtree, the registry log's recent lines, the live task list, invoke buttons for a couple of named tools, a "Read home page" button that calls `example.home.page.read` directly and renders `ok`/`code`/`nodes`, and navigation buttons to `ExampleFormScreen`, `ExampleDiagnosticsScreen`, `ExampleExceptionScreen` plus the pre-existing "Open details" route. The screen listens to `runtime.registryLog` (a `ChangeNotifier`) and rebuilds on a deferred post-frame callback so registrations that happen after the widget's first build (the home page's own `.page.read`/`.page.act` endpoints, and `WebMcpAction`'s own registration) are reflected in the rendered list rather than frozen at first build. `main.dart` constructs an `ExampleRuntime`, awaits `install()`, and runs the app with `runtime.createRootNavigatorAdapter()` as the sole navigator observer and `ExampleScreen(runtime: runtime)` as home; the app State disposes the adapter and calls `unawaited(runtime.dispose())` on teardown, matching the prior dispose-on-State-dispose shape. The test harness pattern mirrors task 5.2's swap-after-placeholder workaround, additionally reusing the harness's own Navigator adapter for the real `MaterialApp` so the home page (and any page pushed over it) still reaches page eligibility; navigation assertions use `tester.pumpAndSettle()` after each push/pop before the fixed five-frame eligibility pump, which was needed because the popped details page's `WebMcpPage.dispose()` (and its tool unregistration) only completes once the pop's route transition animation fully settles. `cd example && flutter test test/example_home_screen_test.dart` passes six tests (all criteria above); the full `cd example && flutter test` suite (54 tests) also passes. `dart format --set-exit-if-changed example/lib/example_screen.dart example/lib/main.dart example/test/example_home_screen_test.dart` and `dart analyze --fatal-infos --fatal-warnings example/lib/example_screen.dart example/lib/main.dart` are both clean.

### Group 7 — Checks and browser walkthrough

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 7.1 | Run the full check suite and the wiki linter from the repository root, run the root hygiene test, run the two scope greps, and paste every command's output; route any required source change to the owning task in the table below rather than editing another task's file | AC-036, AC-037, AC-038, AC-040, AC-041 | none | | Both commands pass with all seven stage lines present, the hygiene test passes, both greps return no match, and all output is pasted |
| 7.2 | Serve the example, read the served URL from the command-line output, follow the fixed click sequence, and record every observation verbatim in the walkthrough file | AC-034, AC-035 | `wiki/work/0014-example-feature-coverage/verification/chrome-walkthrough.md` | | The walkthrough file exists with one recorded observation per item in the sequence, each carrying the value read from the screen, and the native support level transcribed as shown |

## Serialised files

| File | Owning task |
|---|---|
| `example/pubspec.yaml` | 1.1 |
| `example/analysis_options.yaml` | 1.1 |
| `example/lib/example_tools.dart` | 2.1 |
| `example/test/example_tools_test.dart` | 2.1 |
| `example/lib/example_runtime.dart` | 4.1 |
| `example/test/example_test_support.dart` | 4.1 |
| `example/lib/example_screen.dart` | 6.1 |
| `example/lib/main.dart` | 6.1 |

The analyzer exclusion for the generated path is added unconditionally by task 1.1, so no later task
ever needs to reach back into `example/analysis_options.yaml`.

## Criterion ownership

Exactly one owning task per criterion. Contributing tasks are listed in the group tables above.

| Criteria | Owning task |
|---|---|
| AC-001, AC-005 | 4.1 |
| AC-002 | 3.1 |
| AC-004 | 3.2 |
| AC-006, AC-007 | 3.3 |
| AC-009 | 3.4 |
| AC-008 | 5.3 |
| AC-012 – AC-019, AC-039 | 5.1 |
| AC-021 – AC-025 | 5.2 |
| AC-003, AC-010, AC-011, AC-020, AC-026 – AC-028 | 6.1 |
| AC-029 – AC-033 | 1.1 |
| AC-034, AC-035 | 7.2 |
| AC-036 – AC-038, AC-040, AC-041 | 7.1 |

## Test tasks

Tests are written by the task that writes the code they cover.

| # | Covers | Positive case | Negative case |
|---|---|---|---|
| 1.1 | AC-029 – AC-031, AC-033 | The two generated names are registered, the schema requires the title, the read-only and consequential hints are set, and an authorized create grows the task list | The unannotated method contributes no tool name; a create with no title returns an invalid-arguments envelope; an unauthorized create leaves the list unchanged |
| 2.1 | AC-002, AC-026 contribution | The three counter mutators change the value and notify; the two original names register | A value setter does not exist on the counter; registering the original names twice raises the duplicate exception |
| 3.1 | AC-002 | An amount of three raises the counter by three; the schema is non-empty; the annotation flags match | An amount of zero returns an invalid-arguments envelope and the counter is unchanged |
| 3.2 | AC-004 | The identifier is `example-recording` and the counters track registrations and unregistrations | A plain registry reset reports `noop` |
| 3.3 | AC-006, AC-007 | Sixty-four events retain the first line; the reset hook fires once | The sixty-fifth event evicts the first line; a cancelled subscription receives no reset |
| 3.4 | AC-009, AC-008 and AC-010 contribution | The three exception types are caught and named; an unscoped action widget raises the missing-scope exception | The unscoped lookup line reports no scope; the same action inside a screen scope raises nothing |
| 4.1 | AC-001, AC-005 | Twelve startup registrations in the fixed order; the harness reaches page eligibility | A second log subscribed after install holds no startup lines; a second test in the file attaches without a resource-limit failure |
| 5.1 | AC-012 – AC-019, AC-039 | Eight non-default policy values; bounds present; text set applied and visible; long press advertised and dispatched; scroll dispatched; retry succeeds with a higher request identifier | Excluded and sensitive markers absent; non-editable value absent; over-length text refused with the policy-denied code; default policy advertises no long press; single-attempt run ends in the stale-snapshot code with nothing changed; coverage reports no truncation |
| 5.2 | AC-021 – AC-025 | Publisher rows equal the map's key count; nine session rows; observe returns success with a non-empty cursor | No capability key appears twice; no tenth session row; the empty reason-code list renders `none` and not blank; a positive wait returns the unsupported-wait code |
| 5.3 | AC-008 | The three exception lines and the no-scope line are on screen | No uncaught framework exception while the screen is displayed |
| 6.1 | AC-003, AC-010, AC-011, AC-020, AC-026 – AC-028 | Exactly the twelve expected names; markers per tool; owned names; the positive scope lookup; a successful direct page read; the pushed page's two endpoints appear | The duplicate name is skipped and not owned; an unknown read argument is rejected; the two endpoints disappear on pop while the screen-owned names remain; a covered page read returns a failure code |
| 7.1 | AC-036 – AC-038, AC-040, AC-041 | Seven stage-passed lines; a clean wiki lint; a passing hygiene test | Both scope greps return no match; a fenced block added to the plan makes the linter fail |
| 7.2 | AC-034, AC-035 | Every walkthrough item recorded with its on-screen value | No red error overlay at any point; no recorded value substituted for an expected one |
