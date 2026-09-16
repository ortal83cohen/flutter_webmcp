# Plan: Example app covers every webmcp_flutter feature and is verified in Chrome

Round 2. This plan replaces the round-1 plan in full after `validation/plan-review-01.md` returned
FAIL with twelve blockers. It is derived from `00-research.md` including its
"Corrections from validation round 1" section, which is authoritative where it contradicts anything
earlier in that file, and from the binding decisions D-0014-01 through D-0014-06 in `STATE.yaml`.

## Goal

After this change, a developer who runs the single top-level `example/` application in Chrome can
see, on screen, every public feature of `webmcp_flutter` that this work item commits to
demonstrating: batch registration through a hand-written tool source and through a generated
domain-action adapter, a custom transport, a registry observer including its reset hook, the four
members of the exception family, non-default tool annotations and input schemas, a page with a fully
non-default page policy exercising text setting, long press and scrolling, direct invocation of the
application observe endpoint and of a page's read and act endpoints, and the complete native
publisher and application session diagnostic surfaces. The same behaviour is asserted by tests in
`example/test/` so that `bash tools/check.sh` fails if any demonstration stops working, and the
browser run is recorded as an observation of whatever native support level a stock Chrome reports
rather than as a claim about Chrome's WebMCP conformance.

## Approach

The work is confined to `example/` plus this work item's own wiki artifacts. Nothing under `lib/`,
no published package version and no repository-level script changes.

The centre of the design is a new file, `example/lib/example_runtime.dart`, holding a class named
`ExampleRuntime`. It owns every long-lived object the demonstrations need — the counter, the task
service, the recording transport, the registry log, the application session and the native
publisher — and it owns the one fixed startup sequence that installs them into the process-wide
registry. Both `example/lib/main.dart` and the widget-test harness drive the application through
this single class, so the startup order, the session attachment and the Navigator adapter
parameters have exactly one definition in the repository. This is the direct answer to the round-1
finding that two parallel tasks each needed, and would each have invented, a page-eligibility
harness: there is now one runtime and one harness, each owned by one task, both created before any
screen work starts.

Around that runtime sit four screens. The existing `ExampleScreen` becomes the home screen and
grows the registry-facing panels: the unfiltered tool list with per-tool annotation and schema
markers, the screen scope's owned and skipped names, a positive `WebMcpScreen.maybeScopeOf` lookup
made from a `Builder` inside the home subtree, the most recent registry-observer lines, the live
task list, buttons that invoke individual tools by name, and a button that invokes the home page's
own read endpoint. A new `ExampleFormScreen` carries a `WebMcpPage` whose `WebMcpPagePolicy` differs
from the default in all eight fields and whose subtree contains one node per policy behaviour; it
also hosts the on-screen agent probe that performs a read-then-act round trip and prints the
transcript. A new `ExampleDiagnosticsScreen` renders the publisher diagnostic map once, the nine
application-session diagnostic getters, the transport identifiers and counters, and two buttons that
invoke the application observe endpoint — one without a wait and one with a positive wait, so the
library's honest refusal of positive waits is visible rather than hidden. A new
`ExampleExceptionScreen` triggers and catches the registry exceptions and shows the negative
`maybeScopeOf` reading.

The generated-domain-action slice is built first because it changes `example/pubspec.yaml` and adds
a checked-in generated file that every later group compiles against. A new annotated service,
`ExampleTaskService`, is processed by `webmcp_flutter_generator` through `build_runner` into a
checked-in adapter file, and `ExampleRuntime` registers that adapter's source at application level
so the generated tool names are present in the home screen's list for the whole session — the
registration site that round 1 left undecided.

Every widget test that touches a page endpoint goes through one shared support library,
`example/test/example_test_support.dart`, which builds the harness the library's own page tests
build (attached session, Navigator adapter wrapping the Navigator, a `MaterialApp` with that adapter
as a navigator observer, five pumped frames) and which also installs the setUp and tearDown
discipline the process-wide session static requires.

## Why this approach

Three alternatives were considered and rejected.

Pointing readers at `packages/webmcp_flutter_generator/example/` for the generated-actions
demonstration instead of adding it to the top-level example was rejected by D-0014-01: that package
is a test fixture with no runnable user interface, and this work item requires the demonstrated
features to be visible in a browser.

Demonstrating the custom transport by swapping it at runtime from a button was rejected because
`WebMcp.reset` clears every registered tool and cancels every observer subscription; a button that
empties the registry mid-session would destroy the very state the other panels exist to show.
Installing the recording transport once, as the first registry call of the process before anything is
registered, demonstrates the same seam without a destructive step, and the native publisher is
unaffected because it attaches through `addRegistryObserver` rather than through the transport.

Building the text-setting demonstration on a real `TextField` was rejected in favour of an explicit
`Semantics` wrapper. Text setting requires the semantics node that carries the `textField` flag and
the `setText` action to be the same node whose `Semantics.identifier` appears in both the policy's
editable-value set and its set-text set. A `TextField` distributes those properties across nodes
Flutter owns, so whether a single node satisfies all three conditions is not something this plan can
guarantee; the library's own passing tests use an explicit `Semantics` wrapper with an
`onSetText` callback over an inert child, and this plan uses the same shape with a visible text
display as the child, so the demonstrated effect is still a change a person sees in the browser.

A fourth alternative — forcing `document.modelContext` to appear by serving the example from a
hardened HTTPS fixture — was rejected by D-0014-03 and by the research answer section: the only
positive in-repo evidence for that surface came from a flagged Chrome against a
COOP/COEP-isolated origin, and the product contract disclaims manual console invocation as
agent proof. Browser verification here targets the application's own registry, pages and diagnostic
output, and records the observed support level verbatim.

## Steps

1. **Declare the generated-actions dependencies.** Edit `example/pubspec.yaml`: add
   `webmcp_flutter_annotations` as a path dependency on `../packages/webmcp_flutter_annotations`,
   add `build_runner` and a path dev dependency on `../packages/webmcp_flutter_generator`, and add a
   `dependency_overrides` entry pointing `webmcp_flutter_annotations` at the same in-repo path. The
   override is required because `packages/webmcp_flutter_generator/pubspec.yaml` depends on the
   *hosted* `webmcp_flutter_annotations` and overrides it only for itself, and Dart dependency
   overrides are not transitive — this mirrors
   `packages/webmcp_flutter_generator/example/pubspec.yaml`, which carries the same override for the
   same reason. In the same step, add an analyzer exclusion for
   `lib/**.webmcp.g.dart` to `example/analysis_options.yaml`, unconditionally rather than only if
   analysis complains, so no later group has to reach back into a file it does not own. Complete
   when `cd example && flutter pub get` resolves and the resolved annotations package is the in-repo
   path package.

2. **Write the annotated service.** Create `example/lib/example_task_service.dart` with
   `ExampleTaskService`, a `ChangeNotifier` holding a list of task titles and an
   application-owned `authorized` flag. Two public instance methods carry `@WebMcpDomainAction`; a
   third public method does not and therefore stays unexposed. The creating method refuses with a
   `StateError` when `authorized` is false, which is the application enforcing its own
   authorization — the generated adapter never grants any. Complete when the file analyses clean.

3. **Generate and check in the adapter.** Run the generator in `example/` and check in
   `example/lib/example_task_service.webmcp.g.dart` per D-0014-02. Run the repository formatter
   over `example/lib` afterwards and commit the formatted result; formatting the generated file is
   permitted, editing its logic is not. Complete when the file exists, exposes a source class for the
   two annotated methods only, and both the formatter and the analyzer accept `example/lib`.

4. **Fix the counter's shape.** Edit `example/lib/example_tools.dart` so `ExampleCounter` is a
   `ChangeNotifier` with a read-only `value` getter and three mutating methods — increment by one,
   increment by an amount, and reset to zero — each notifying its listeners, and keep
   `registerExampleTools` registering the two original tool names against it. Update
   `example/test/example_tools_test.dart` for the new shape. Complete when both the amount and the
   reset paths are covered by that test and the two original tool names are unchanged.

5. **Write the hand-written tool source.** Create `example/lib/example_counter_source.dart` with
   `ExampleCounterSource`, which implements `WebMcpToolSource` over a live `ExampleCounter` and
   returns three descriptors: a read-only one, an amount-taking one with a non-default input schema
   and a consequential annotation, and a reset one. The amount-taking handler validates its own
   arguments and returns the failure envelope shape the generated adapter uses rather than throwing.
   Complete when its test asserts the three names, the non-empty schema, the annotation flags, a
   successful amount increment and a rejected out-of-range amount that leaves the counter unchanged.

6. **Write the recording transport.** Create `example/lib/example_recording_transport.dart` with
   `ExampleRecordingTransport`, which implements `WebMcpTransport`, reports the fixed identifier
   chosen below, and counts registrations and unregistrations while retaining the most recent
   registered name. Complete when its test installs it through `WebMcp.reset`, asserts the
   identifier and the counts after registrations and unregistrations, and asserts that a plain
   `WebMcp.reset` with no argument restores a different identifier.

7. **Write the registry log.** Create `example/lib/example_registry_log.dart` with
   `ExampleRegistryLog`, a `ChangeNotifier` implementing both `WebMcpRegistryObserver` and
   `WebMcpRegistryResetObserver`. It appends one line per registration and per unregistration,
   retains the most recent lines up to the bound fixed below, counts resets and records a reset
   line. Complete when its test covers both notification directions, the eviction boundary at the
   bound, and the reset hook including the subscription becoming inactive.

8. **Write the exception demonstration.** Create `example/lib/example_exception_demo.dart` with a
   function that produces a transcript of three lines by triggering and catching an invalid tool
   name, a duplicate tool name and a missing tool invocation, each line naming the caught exception
   type and the offending tool name, plus a fourth line reporting the outcome of a
   `WebMcpScreen.maybeScopeOf` lookup made from a context with no screen ancestor. Complete when its
   test asserts the three caught types, asserts the fourth line reports no scope, and separately
   asserts that a `WebMcpAction` built with no enclosing screen scope throws the missing-scope
   exception, captured through the widget tester's exception accessor.

9. **Write the runtime.** Create `example/lib/example_runtime.dart` with `ExampleRuntime`, owning
   the counter, the task service, the recording transport, the registry log, the session, the
   publisher and the observer subscription. It exposes the install method that performs the fixed
   startup order given below, a factory method returning the root Navigator adapter with the fixed
   parameters, and a dispose method that detaches the publisher, detaches the session, cancels the
   subscription and resets the registry. Calling install twice on one instance raises a state error.
   Complete when a unit test asserts the twelve startup registrations in order.

10. **Write the test support library.** Create `example/test/example_test_support.dart` exposing:
    a harness type that constructs an `ExampleRuntime`, awaits its install, creates the root
    Navigator adapter from it, pumps a `MaterialApp` with that adapter as its only navigator
    observer and the supplied widget as its home, then pumps five frames of one hundred
    milliseconds; a disposal method that disposes the adapter and the runtime; a function that
    installs the shared setUp and tearDown discipline described below; and two helpers that invoke a
    page's read endpoint with an optional query and locate a returned node by its exact label. This
    file has no `_test` suffix, so the test runner does not treat it as a suite. Complete when the
    form-screen test and the home-screen test both drive their pages through it without declaring
    their own session.

11. **Build the form screen and the probe.** Create `example/lib/example_agent_probe.dart` with
    `ExampleAgentProbe`, which performs the read-then-act round trip described in the interfaces
    section, and `example/lib/example_form_screen.dart` with `ExampleFormScreen`, whose `WebMcpPage`
    carries the fully non-default policy and one labelled node per policy behaviour, plus buttons
    that run the probe and a text view of the transcript. Complete when its test asserts, through the
    shared harness: the eight non-default policy values, the omission of the excluded and sensitive
    subtrees, the omitted non-editable value, the presence of bounds, a successful text set with the
    visible text changed, a refused over-length text set, an advertised and dispatched long press, a
    dispatched scroll, a strictly increasing request identifier across a retried attempt, and a
    single-attempt run that ends in a stale-snapshot code with nothing changed.

12. **Build the diagnostics screen.** Create `example/lib/example_diagnostics_screen.dart` with
    `ExampleDiagnosticsScreen`, rendering the publisher diagnostic map once under the rendering rule
    fixed below, the nine named session getters, the transport identifier and counters, the page
    protocol version constant, and the two observe buttons. Complete when its test asserts the row
    count and the absence of duplicated capability rows, the empty-reason-code rendering, the nine
    getter names, a successful observe call and a positive-wait call that reports the unsupported-wait
    code together with its wait-capability fields.

13. **Build the exception screen.** Create `example/lib/example_exception_screen.dart` with
    `ExampleExceptionScreen`, which renders the transcript from step 8 and does not use the
    `WebMcpScreen` mixin, so the negative scope lookup it performs is genuinely unscoped. Complete
    when its test asserts the four transcript lines are on screen and that no uncaught framework
    exception is raised while the screen is displayed.

14. **Wire the home screen.** Edit `example/lib/example_screen.dart`: take the runtime as its single
    constructor argument, stop registering the two counter tools from `initState` (the runtime now
    registers them at application level, which also removes the remount duplicate hazard recorded as
    pre-existing in round 1), render the panels listed in the approach with the tool-line format
    fixed below, add the deliberate duplicate registration that populates the scope's skipped-name
    list, add navigation buttons to the three new screens, and keep the existing details route so the
    push-and-pop page-endpoint signal remains available. Complete when its test asserts the exact
    twelve-name startup list, the owned and skipped names, the positive scope lookup, and the
    appearance and disappearance of the pushed page's two endpoints across a push and a pop while the
    screen-owned names stay registered throughout.

15. **Wire the entry point.** Edit `example/lib/main.dart` to construct the runtime, await its
    install, run the application, build the root Navigator adapter from the runtime, and dispose the
    runtime on teardown. Complete when the application starts with no uncaught framework exception in
    a widget test that pumps it.

16. **Run the repository checks.** Run `bash tools/check.sh` and `python3 tools/lint_wiki.py` from
    the repository root and resolve any fallout in the files this work item owns. Complete when both
    commands pass and their output is pasted into the verification record.

17. **Run the Chrome walkthrough.** Run the example with the README's recipe, read the served URL
    from the command-line output because no fixed port exists in this repository, and follow the click
    sequence in the verification section. Record every observation, including the native support
    level whatever it is, in `wiki/work/0014-example-feature-coverage/verification/chrome-walkthrough.md`.
    Complete when that file exists and contains one recorded observation per walkthrough criterion.

## Interfaces and shared decisions

These are fixed here and may not be renegotiated during implementation.

**Files created.** Under `example/lib/`: `example_task_service.dart`,
`example_task_service.webmcp.g.dart` (generated, checked in), `example_counter_source.dart`,
`example_recording_transport.dart`, `example_registry_log.dart`, `example_exception_demo.dart`,
`example_runtime.dart`, `example_agent_probe.dart`, `example_form_screen.dart`,
`example_diagnostics_screen.dart`, `example_exception_screen.dart`. Under `example/test/`:
`example_test_support.dart`, `example_counter_source_test.dart`,
`example_recording_transport_test.dart`, `example_registry_log_test.dart`,
`example_exception_demo_test.dart`, `example_runtime_test.dart`, `example_form_screen_test.dart`,
`example_diagnostics_screen_test.dart`, `example_exception_screen_test.dart`,
`example_home_screen_test.dart`, `example_task_service_test.dart`. Files edited:
`example/pubspec.yaml`, `example/analysis_options.yaml`, `example/lib/example_tools.dart`,
`example/lib/example_screen.dart`, `example/lib/main.dart`,
`example/test/example_tools_test.dart`.

**Tool names.** Registered by the hand-written source: `example.source.counter.read`,
`example.source.counter.add`, `example.source.counter.reset`. Emitted by the generated adapter:
`example.tasks.create`, `example.tasks.list`. Unchanged imperative names:
`example.counter.read`, `example.counter.increment`. Screen-owned names:
`example.screen.describe` (from the screen's registration hook) and `example.screen.increment`
(from the action widget). Library-owned names: `example.app.observe` from the session, and
`example.home.page.read`, `example.home.page.act`, `example.form.page.read`,
`example.form.page.act`, `example.details.page.read`, `example.details.page.act` from the three
pages — the literal endpoint suffixes are `.page.read` and `.page.act`. Page identifiers are
`example.home`, `example.form` and `example.details`.

**The startup list.** With the registry log subscribed before any registration, application startup
produces exactly twelve registration notifications in this order: the three source names, the two
generated names, the two imperative counter names, the observe endpoint, the screen describe name,
the screen increment name, and the home page's read and act endpoints. The deliberate duplicate
registration described below produces no notification, because the registry raises the duplicate
exception before it mutates anything. The home screen's rendered list therefore holds exactly twelve
names, sorted ascending, and grows by two while a route carrying another page is on top.

**Fixed startup order.** The install method performs, in this order and no other: reset the registry
with the recording transport (this must be first, because a reset cancels observer subscriptions);
add the registry log as a registry observer; register the hand-written counter source through
`WebMcp.registerSource`; register the generated task source through `WebMcp.registerSource`; call
`registerExampleTools` with the counter; attach the session with the application identifier
`example`; await the publisher's attach.

**`ExampleCounter`'s shape.** A `ChangeNotifier` with a private integer field, a public `value`
getter and no public setter, and exactly three mutating methods: one that adds one and returns the
new value, one that takes a positive amount and returns the new value, and one that sets the value
to zero. Each notifies listeners. Nothing else is added to this class.

**Screen constructors.** `ExampleScreen`, `ExampleDiagnosticsScreen` and the application widget each
take exactly one required named argument, `runtime`, of type `ExampleRuntime`, plus the inherited
key. `ExampleFormScreen` and `ExampleExceptionScreen` take no arguments other than the inherited
key. No screen takes the publisher, the session or the transport directly; everything is reached
through the runtime. Nothing is nullable.

**Navigator adapter parameters.** The runtime's adapter factory always uses the navigator identifier
`root` and a root-modal relationship of true, with no parent navigator identifier, no persistent
parallel branch and no selected branch. The application widget and the test harness both obtain
their adapter from this factory, so there is one definition.

**Form page node labels.** Node targeting matches on the `label` field, because the read response's
serialized node carries only `handle`, `role`, `label`, `hint`, `value`, `states`, `actions` and
optional `bounds` and `parentHandle` — there is no semantics-identifier field in the response, and
the identifier is retained only inside the library for act-time revalidation. The labels are fixed
as: `Note field`, `Archive note`, `Note history`, `Save status`, `Excluded panel` and
`Secret panel`. The matching semantics identifiers, which exist only so the policy can name them,
are `example.form.note`, `example.form.archive`, `example.form.history`, `example.form.status`,
`example.form.excluded` and `example.form.secret`. The excluded subtree contains the marker text
`EXCLUDED-CONTENT`, the sensitive subtree the marker text `SENSITIVE-VALUE`, and the status node
carries the non-editable value `NON-EDITABLE-VALUE`; these three strings exist so their absence from
a read response is checkable.

**Form page policy.** All eight fields differ from their defaults: long press allowed (default
false), bounds included (default false), non-editable values excluded (default true), maximum
accepted text length one hundred and twenty (default one thousand and twenty-four), the excluded
identifier set holding `example.form.excluded`, the sensitive set holding `example.form.secret`,
and both the editable-value set and the set-text set holding `example.form.note` (all four sets
default to empty). The home and details pages keep the default policy, which is what makes the
absence of bounds on a home page read a usable negative case.

**Probe contract and the request-identifier rule.** `ExampleAgentProbe` holds a private counter that
starts at one. Its run method takes a page identifier, a node label, an action name, action
arguments, a maximum attempt count defaulting to two, and an optional callback invoked once before
the first act attempt. Each attempt invokes the page's read endpoint with the node label as its
query, appends a transcript line naming the attempt number, the success flag, the returned node
count and the revision, then locates the first returned node whose label equals the requested label
exactly and which advertises the requested action. The act call always supplies all seven required
arguments — page identifier, mount token, revision, handle, action, request identifier and
arguments — taking the mount token and revision from the read it just performed. **The request
identifier is taken from the probe's counter and the counter is incremented on every act attempt,
including retries.** Reusing an identifier is forbidden: a retry after a stale snapshot necessarily
carries a different revision and therefore a different request fingerprint, so a reused identifier
returns the duplicate-request code instead of a fresh attempt. An attempt whose act reports the
stale-snapshot code is retried until the attempt budget is exhausted; any other failure stops the
run. The optional before-first-act callback is the only injection seam tests use to force a stale
snapshot, and it fires once and is then cleared.

**Diagnostics rendering rule.** The publisher status diagnostic map is rendered **once**, one row per
key in its own iteration order, and the capability diagnostic map is **not** rendered separately,
because the publisher map already spreads all four capability keys into itself — rendering both
would produce four duplicate rows. A short caption states that the four capability keys originate
in the embedded capability matrix. A value that is an empty list renders as the literal text `none`,
and that rendering counts as a shown value; this is the normal case for the reason-code key when
nothing has failed, and it must not be treated as a missing value. Non-empty lists render
comma-joined. Every row's label is prefixed to say where it came from: `publisher.` for the
publisher map's keys, `session.` for the session getters, `transport.` for the transport's
identifier and counters. The prefix matters because the publisher and the session both expose a
retained-operation count under the same key name.

**The nine session diagnostic getters.** Exactly these, each rendered with its own name: whether the
session is attached, whether it owns its observe endpoint, the application mount, the live scope
count, the Navigator adapter count, whether route evidence is ready, the retained event count, the
retained operation count and the outstanding execution count. The static active-session accessor and
the Navigator adapter's own getters are not part of this set and are not rendered.

**Registry log retention bound.** The most recent sixty-four lines. The bound is deliberately larger
than the twelve startup registrations plus the handful of registration and unregistration events a
full walkthrough produces, so that a criterion checked after navigating away and back can still find
the startup line that names a screen-owned tool. A smaller bound would evict it.

**Transport identifier.** The recording transport reports `example-recording`. The platform default
reports `noop` under the Flutter test runner and `web-detection` in a browser, which is what makes
the default-transport negative case checkable.

**Tool line format.** Each line of the home screen's tool list starts with the tool name, followed by
markers in square brackets: `ro` when the read-only hint is set, `uc` when the untrusted-content
hint is set, `cq` when the consequential hint is set, and `schema` when the input schema is
non-empty. A tool with no hints and an empty schema renders as its bare name. Name-based checks must
therefore match the start of a line, not the whole line.

**Test discipline for the process-wide session.** The application session is a process-wide static,
and attaching a second session while another is still attached returns a resource-limit envelope
instead of attaching, which makes every later page assertion fail for an unrelated reason. Every new
test file that attaches a session — directly or through the harness — calls the support library's
discipline installer, which registers a setUp that resets the registry and a tearDown that detaches
whatever session is active and then resets the registry again. No test file declares its own session
handling.

**Error-handling convention.** Handlers written by the example never throw across the registry
boundary for argument problems; they return a map with a false success flag and an error code, which
is the shape the generated adapter already uses. The only deliberate throws are the three in the
exception demonstration and the service's authorization refusal.

**Forbidden token rule.** The root suite scans every Dart file under `example/lib`, so no file added
there may contain a forbidden import (the browser, JavaScript interop, input-output and HTTP
families) or any token the secret detector matches, including the words for an application key or a
password followed by a colon or an equals sign. Demonstration strings use the fixed marker words
above instead.

## Risks

| Risk | Likelihood | Impact | Mitigation | Trigger that means it happened |
|---|---|---|---|---|
| The generated file fails the repository formatter or the example's stricter lint set | Medium | Check stage three or four fails on a file that must not be hand-edited | The analyzer exclusion for the generated path is added unconditionally in step 1; the formatter is run over `example/lib` in step 3 and the formatted output committed | `dart format --set-exit-if-changed` or `dart analyze` names the generated file |
| The generator rejects the annotated service's shape (a notifier superclass, or a parameter type it cannot decode) | Medium | Step 3 produces no adapter | Keep the annotated methods' parameters to strings, booleans and integers, which the existing fixture proves are supported; if the notifier superclass is the problem, drop it and refresh the task panel from the invoking button instead | `dart run build_runner build` reports an error naming the service |
| The explicit semantics wrapper for the text node does not produce a single node carrying the text-field flag, the identifier and the set-text action | Low | The text-setting demonstration and its criteria cannot pass | The shape mirrors the library's own passing test; if a read still shows the properties split across nodes, replace the visible child with an inert box exactly as that test does | A read of the form page shows no node whose advertised actions include text setting |
| A pushed route's page never becomes eligible, so its endpoints never appear | Low | The navigation criterion cannot pass | The harness reproduces the library's proven eligibility preconditions and pumps five frames; the route used is an ordinary page route, which is not a popup and so does not trip the blocking-root-modal rule | After a push and five pumped frames the pushed page's two endpoint names are absent |
| The read response for the form page exceeds the session's byte budget and starts omitting label fields | Low | Label-based node targeting silently stops finding nodes | Keep the form subtree small, wrap the inner list in a semantics exclusion, and assert in the test that the response's coverage reports no truncation | A read response's coverage reports truncation, or a node that should carry a label has none |
| The twelve-name startup list drifts as implementation proceeds | Medium | The list criterion and the observer criterion both fail | The list and the startup order are fixed above; any change to either is a criteria change and needs a recorded validation round, not an edit | A test asserting the twelve names fails with a thirteenth name |
| A new file under `example/lib` trips the root hygiene suite | Low | A root-suite test fails, which looks unrelated to an example-only change | The forbidden-token rule above; the rollback section records that the root suite is inside the blast radius | The root suite reports a forbidden import or a secret marker naming a file under `example/lib` |

## Rollback

Every change is additive and confined to `example/`, this work item's folder under `wiki/work/`, and
the new walkthrough record. Reverting the commit restores the previous example exactly: the new
files disappear, the four edited files return to their prior contents, and `example/pubspec.yaml`
loses the three dependency entries and the override. The resolved dependency file is git-ignored, so
no lockfile has to be reverted. No library source under `lib/`, no package version and no
repository-level script changes, so no consumer of the published package is affected.

The blast radius is not zero outside `example/`, and the round-1 plan was wrong to claim it was.
`test/repo_hygiene_test.dart` runs from the repository root and scans every Dart file under
`example/lib` for forbidden imports, parse failures and secret markers, so a new file added there can
fail a root-suite test. The repository formatter and analyzer stages also cover `example/lib` and
`example/test`. Those are the only paths by which this change can fail something outside the example.

This is not a one-way door and needs no human escalation before implementation. The generated file
is regenerable from its annotated source at any time, no data is migrated, no interface consumed by
anything outside `example/` changes, and the Chrome walkthrough is read-only observation.

## Out of scope

Two distinct buckets, which must not be conflated.

**Supported features this work item chooses not to demonstrate.** These are real, working, supported
parts of the package; their absence is a scope decision recorded in D-0014-04, not a limitation and
not a prohibition. A custom view provider; customized page limits; nested or parallel Navigator
adapters, meaning the parent-navigator, persistent-parallel-branch and selected-branch parameters;
the page widget's explicit activity listenable; cursor-paginated reads; and the evidence-kind
enumeration and the maximum-safe-integer constant as dedicated demonstrations, since they already
appear inside response shapes other criteria exercise.

**Contract-level deliberate omissions.** Everything on the deliberate-omissions list in
`wiki/product/webmcp-contract.md` stays omitted, and nothing in this work item asserts otherwise.
One of them is demonstrated as an honest refusal rather than silently: the observe endpoint called
with a positive wait reports the unsupported-wait code together with its wait-capability fields, so
a reader sees that positive observation waits are not supported rather than guessing. The example
never claims a usable-conformance native support level, and never asserts that manual invocation from
a browser console proves agent use.

Also out of scope: adding a generator stage for `example/` to `tools/check.sh`, which stays as the
recorded follow-up in `STATE.yaml`; any change under `lib/`; any change to the package version; and
fixing the internal native-publisher boundary's lack of an example, which cannot be a coverage gap
because it is never exported.

## Verification approach

Automated checks run through `bash tools/check.sh`, whose seven stages already include the wiki
lint, dependency resolution for every package, the formatter and analyzer over `example/lib` and
`example/test`, both the root and the example test suites, and a web build of the example. Every
criterion that can be asserted in code is asserted by a test under `example/test/`, each with a
positive case and a case that fails for the stated reason: a source registered twice raising the
duplicate exception, an out-of-range amount leaving the counter unchanged, a plain registry reset
restoring the default transport identifier, the sixty-fifth log line evicting the first, an
over-length text set returning the policy-denied code with the visible text unchanged, the same
widget tree under the default policy advertising no long press, a single-attempt probe run ending in
the stale-snapshot code, an observe call with a positive wait reporting the unsupported-wait code,
and a read call carrying an unknown argument key reporting the invalid-arguments code.

Page-touching tests all drive the shared harness from `example/test/example_test_support.dart`, so
page eligibility is established the way the library's own page tests establish it, and all of them
install the shared session discipline.

The browser walkthrough is manual and read-only. It runs the example with the README's recipe,
reads the served URL from the command-line output, and follows a fixed sequence: load the home
screen and record the twelve tool lines, the transport identifier and the native support level
verbatim; press the invoke buttons and record the counter and task-list changes; open the form
screen and record the two new endpoint names, run both probes and record the transcripts and the
changed note text; return home and record that the two endpoint names are gone while the
screen-owned names are still listed and the startup line naming a screen-owned tool is still in the
log panel; open the diagnostics screen and record every rendered row including the reason-code row's
`none`; press both observe buttons and record both responses; open the exception screen and record
the four transcript lines; and confirm no red error screen appeared at any point. Each observation
is written to the walkthrough record with the value as read, never with an expected value
substituted.
