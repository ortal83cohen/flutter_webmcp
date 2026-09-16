# Plan review — round 01

- Work item: 0014-example-feature-coverage
- Reviewed artifacts: `wiki/work/0014-example-feature-coverage/01-plan.md`,
  `wiki/work/0014-example-feature-coverage/03-tasks.md` against
  `wiki/work/0014-example-feature-coverage/02-criteria.md`, at git revision 5601815 (working tree clean)
- Reviewer: plan validator (adversarial, blind)
- Date: 2026-09-15

## Verdict

**FAIL**

The plan's central agent-probe and page-surface design rests on a false assumption about the
library — the page read response carries no semantics identifiers at all — and four acceptance
criteria (AC-012, AC-014, AC-024, AC-025) cannot pass as written against the code in `lib/`.

## Verification performed

Toolchain (plan step 1 gate, `01-plan.md:115-119`):

```
$ /bin/sh -c 'command -v dart; command -v flutter'
/Users/ortalcohen/.local/bin/dart
/Users/ortalcohen/.local/bin/flutter

$ dart --version | head -1
Dart SDK version: 3.13.0 (stable) (Wed Aug 5 00:28:05 2026 -0700) on "macos_arm64"

$ flutter --version | head -1
Flutter 3.47.0 • channel [user-branch]
```

Artifact hygiene:

```
$ grep -n '```' wiki/work/0014-example-feature-coverage/01-plan.md
(no output — zero fenced code blocks, AGENTS.md artifact rule satisfied)

$ grep -nEi "correctly|properly|as expected|appropriate|reasonabl|robust" \
    wiki/work/0014-example-feature-coverage/02-criteria.md
(no output)

$ grep -c "^| AC-" wiki/work/0014-example-feature-coverage/02-criteria.md
38
(all 38 rows carry a filled negative-case column)

$ python3 tools/lint_wiki.py
lint_wiki: clean (0 warning(s)).
```

Rollback claim about the resolved dependency file (`01-plan.md:314-316`) — confirmed true:

```
$ git check-ignore -v example/pubspec.lock
.gitignore:35:/example/pubspec.lock	example/pubspec.lock

$ git ls-files example/
example/analysis_options.yaml
example/lib/example_screen.dart
example/lib/example_tools.dart
example/lib/main.dart
example/pubspec.yaml
example/test/example_tools_test.dart
example/web/index.html
```

Analysis scope claim behind the generated-file lint risk (`01-plan.md:303`) — confirmed: the
generator fixture has no `flutter_lints` include while `example/analysis_options.yaml` does.

```
$ cat packages/webmcp_flutter_generator/example/analysis_options.yaml
analyzer:
  exclude: [...]
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

$ head -1 example/analysis_options.yaml
include: package:flutter_lints/flutter.yaml

$ dart analyze --fatal-infos --fatal-warnings example/lib
Analyzing lib...
No issues found!
```

Dependency-override claim (AC-019) — confirmed: the generator depends on the *hosted*
`webmcp_flutter_annotations: ^0.1.0` (`packages/webmcp_flutter_generator/pubspec.yaml:15`), and a
path-dependency consumer's own `dependency_overrides` are the only ones that apply, so the example
does need its own override, exactly as the fixture has one
(`packages/webmcp_flutter_generator/example/pubspec.yaml:24-26`).

Check-suite claims — confirmed: `tools/check.sh` has seven numbered stages (AC-033), runs
`dart run build_runner build` only in `packages/webmcp_flutter_generator/example`, never in
`example/` (`tools/check.sh:66-71`), and formats/analyses/tests/web-builds `example/`
(`tools/check.sh:30-63`).

Library surface used by the plan — confirmed present: `registerSource` (`lib/src/webmcp.dart:101`),
`reset([transport])` (`lib/src/webmcp.dart:144`), `transportId` (`lib/src/webmcp.dart:166`),
`addRegistryObserver` (`lib/src/webmcp.dart:71`), `WebMcpRegistryResetObserver`
(`lib/src/webmcp.dart:42`), `WebMcpScope.ownedNames`/`skippedNames`
(`lib/src/webmcp_scope.dart:55-58`), `WebMcpScreen.maybeScopeOf`
(`lib/src/widgets/webmcp_screen.dart:12`), the four exceptions
(`lib/src/webmcp_exceptions.dart:17,27,34,41`), `WebMcpToolAnnotations.readOnlyHint` /
`consequentialHint` (`lib/src/webmcp_tool.dart:16-27`), the eight-field `WebMcpPagePolicy`
(`lib/src/page/webmcp_page_protocol.dart:247-255`), and the four
`WebMcpNativeSupport` names (`lib/src/transport/webmcp_native_capabilities.dart:64+`).
Nine `WebMcpAppSession` diagnostic getters exist (`lib/src/page/webmcp_app_session.dart:92,95,98,
101,104,107,143,146,152`).

## Criterion coverage map

| Criterion | Addressed by plan step | Owning task | Coverage |
|---|---|---|---|
| AC-001 | step 4 (`01-plan.md:140`), step 13 (`:222`) | 2.1, 4.1 | test unowned — F-010 |
| AC-002 | step 10 (`:191`) | 3.1 | covered |
| AC-003 | step 11 (`:199`) | 3.2 | blocked by F-004 |
| AC-004 | step 9 (`:182`) | 2.6 | covered |
| AC-005 | step 5 (`:146`), step 13 (`:222`) | 2.2, 4.1 | rendering test unowned — F-012 |
| AC-006 | step 5 (`:146`) | 2.2 | covered |
| AC-007 | step 6 (`:151`) | 2.3 | covered |
| AC-008 | step 7 (`:156`) | 2.4 | covered |
| AC-009 | step 7 (`:156`) | 2.4 | covered |
| AC-010 | step 11 (`:199`) | 3.2 | under-specified — F-016 |
| AC-011 | step 11 (`:207`) | 3.2 | uncheckable — F-002 |
| AC-012 | step 11 (`:209`) | 3.2 | negative case impossible — F-002 |
| AC-013 | step 8 (`:167`) | 2.5 | blocked by F-001 |
| AC-014 | step 8 (`:167`) | 3.2 (wrong file) | contradictory — F-005, F-011 |
| AC-015 | step 12 (`:213`) | 3.3 | dangling reference — F-009, F-015 |
| AC-016 | step 3 (`:127`) | 1.3 | registration site undecided — F-007 |
| AC-017 | step 3 (`:127`) | 1.3 | covered |
| AC-018 | step 3 (`:127`) | 1.3 | covered |
| AC-019 | step 2 (`:121`) | 1.2 | covered |
| AC-020 | step 14 (`:231`) | 4.2 | covered |
| AC-021 | out-of-scope section (`:332`) | 4.2 | covered |
| AC-022 | step 16 (`:241`) | 5.2 | covered |
| AC-023 | step 16 (`:241`) | 5.2 | unsatisfiable — F-007, F-022 |
| AC-024 | step 16 (`:241`) | 5.2 | unachievable — F-008 |
| AC-025 | step 16 (`:241`) | 5.2 | unachievable — F-014 |
| AC-026 – AC-031 | step 16 (`:241`) | 5.2 | covered |
| AC-032 | step 16 (`:241`) | 5.2 | covered |
| AC-033, AC-034 | step 15 (`:237`) | 1.1, 5.1 | covered |
| AC-035 – AC-038 | verification section (`:351`) | 5.1, 5.2 | covered |

Steps satisfying no criterion: the rendered screen-scope lookup line (`01-plan.md:195`) — F-020.

## Findings

### F-001 — The page read response carries no semantics identifiers, so the agent probe cannot target a node

- Severity: BLOCKER
- Location: `wiki/work/0014-example-feature-coverage/01-plan.md:171-173`
- Criterion affected: AC-013, AC-014, AC-028
- Observation: the plan specifies the probe as "the page read endpoint to obtain the mount token,
  the revision and the node handles, the page act endpoint requesting a text-setting action on the
  node whose semantics identifier matches the target". The node wire map built by
  `lib/src/page/webmcp_page.dart:521-548` emits exactly `handle`, `role`, `label`, `hint`, `value`,
  `states`, `actions`, optional `bounds` and optional `parentHandle`. The semantics identifier is
  retained only in the internal `_CapturedNode.semanticsIdentifier`
  (`lib/src/page/webmcp_page.dart:452`) for act-time revalidation
  (`lib/src/page/webmcp_page.dart:1037`) and is never serialised. Grep confirms no `identifier` key
  in any response path; the top-level read response fields are `pageId`, `mountToken`, `revision`,
  `active`, `coverage`, `nodes`, `nextCursor` (`lib/src/page/webmcp_page.dart:891-901`).
- Why it matters: the probe's stated targeting mechanism does not exist. An implementer reaches
  step 8 and cannot proceed without a new decision on how a handle is selected, and the decision
  affects the form screen (task 3.2) and the probe (task 2.5) simultaneously.

### F-002 — AC-011 is uncheckable and AC-012's negative case is unsatisfiable for the same reason

- Severity: BLOCKER
- Location: `wiki/work/0014-example-feature-coverage/02-criteria.md:24-25`; plan assertion at
  `wiki/work/0014-example-feature-coverage/01-plan.md:207-210`
- Criterion affected: AC-011, AC-012
- Observation: AC-011 asserts advertised actions "for the node identified as `example.form.note`",
  but the read response contains no identifier by which a test can select that node (F-001).
  AC-012's negative case — "the same test asserts the response does contain the `example.form.note`
  identifier" — asserts the presence of a string the library never emits, so it can only fail.
  Symmetrically, AC-012's positive half ("the encoded response shall contain neither the string
  `example.form.secret` …") passes vacuously, because no policy-excluded or policy-included
  identifier ever reaches the response.
- Why it matters: one criterion always fails and one always passes for reasons unrelated to the
  behaviour under test, which is exactly the silent-pass failure mode criteria exist to prevent.

### F-003 — The only usable node discriminators, the semantic labels of the form widgets, are not fixed in the plan

- Severity: BLOCKER
- Location: `wiki/work/0014-example-feature-coverage/01-plan.md:263-266`;
  `wiki/work/0014-example-feature-coverage/03-tasks.md:31` and `:39`
- Criterion affected: AC-011, AC-013, AC-014
- Observation: the Interfaces section fixes the six semantics identifiers and the tool names but
  fixes no labels, roles or any other value present in the read wire. Task 2.5 (agent probe,
  `03-tasks.md:31`, marked `[P]`) and task 3.2 (form screen, `03-tasks.md:39`, marked `[P]`) must
  agree on how the probe recognises the note node in the read output, and the plan leaves that
  choice to each of them.
- Why it matters: a cross-task interface decision left open across tasks marked parallel; the two
  tasks will encode incompatible discriminators and neither will know it until integration.

### F-004 — The preconditions for a page to register its endpoints at all are unstated, so no page test in the plan can run

- Severity: BLOCKER
- Location: `wiki/work/0014-example-feature-coverage/01-plan.md:205-211` and `:176-180`
- Criterion affected: AC-003, AC-010, AC-011, AC-012, AC-013, AC-014
- Observation: `<pageId>.page.read` and `<pageId>.page.act` are registered only from
  `_registerToolsIfNeeded`, which returns immediately unless `_eligible`
  (`lib/src/page/webmcp_page.dart:568-572`), and page-level `sources` are registered only from
  `_replaceSources`, which also returns unless `_eligible`
  (`lib/src/page/webmcp_page.dart:601-616`). `_eligible` is set only inside `_captureNow`
  (`lib/src/page/webmcp_page.dart:352`), which requires all of: a non-null attached
  `WebMcpAppSession` captured at `initState` (`:104`, `:113-117`, `:274-277`), exactly one view from
  the view provider (`:281-285`), and `_activityIsProved()` — which needs a non-null
  `ModalRoute.of(context)` whose navigator is owned by exactly one settled `WebMcpNavigatorAdapter`
  (`:341-347`, `lib/src/page/webmcp_app_session.dart:114-139`) — and it runs in a post-frame
  callback. The library's own tests need a 60-line harness to reach this state
  (`test/page/webmcp_page_test.dart:1031-1073`: construct session, `attach`, build a
  `WebMcpNavigatorAdapter`, wrap in `MaterialApp` with the adapter as a navigator observer, then
  pump five frames). The plan says only "Widget test pumps the form screen, asserts both names
  present" with no mention of any of this.
- Why it matters: an implementer following step 11 as written gets
  `WebMcpToolNotFoundException` on the very first read invocation and must stop and ask. This is a
  step you cannot execute without a question, and the same harness is needed by two tasks in two
  different groups with no owner assigned to it.

### F-005 — AC-014's negative case contradicts the retry the plan mandates for the same probe

- Severity: BLOCKER
- Location: `wiki/work/0014-example-feature-coverage/01-plan.md:174-176` versus
  `wiki/work/0014-example-feature-coverage/02-criteria.md:27`
- Criterion affected: AC-014
- Observation: the plan requires the probe to "retry the read-then-act pair at most once when the
  first act attempt reports a stale snapshot". AC-014's negative case requires a test that "runs
  the probe with a revision taken before a rebuild and asserts the act line ends in the
  stale-snapshot code and the field content is unchanged". Because the probe re-reads and re-acts on
  a stale reading, the retry obtains the fresh revision and the act line ends in `ok` with the field
  content changed. The plan specifies no parameter, seam or injection point that lets a test
  suppress the retry or pin a stale revision.
- Why it matters: the probe's only mandated negative case cannot be written against the probe's
  mandated behaviour.

### F-006 — AC-023 requires the generated task tools on the home screen, but no step registers them outside the diagnostics screen

- Severity: BLOCKER
- Location: `wiki/work/0014-example-feature-coverage/02-criteria.md:41`; plan steps at
  `wiki/work/0014-example-feature-coverage/01-plan.md:213-220` and `:222-229`
- Criterion affected: AC-016, AC-023
- Observation: AC-023 requires the on-screen registered-tool list on the home screen to include
  "the two generated task names". Step 12 places the generated-action demonstration on the
  diagnostics screen, and step 13's fixed startup order registers only the observer and the
  application-level hand-written source — the generated source is never registered at application
  level. AC-016's check says only "the generated source added to a scope through `addSource`",
  without saying which scope. If the source is added to the diagnostics screen's scope, the names
  exist only while that screen is mounted and are absent from the home screen's list; if it is
  added at application level, step 13's fixed order must change.
- Why it matters: an unowned shared decision (where the generated source is registered) that
  directly determines whether a criterion can pass, and step 13's order is explicitly declared
  unchangeable ("Startup order … is fixed", `01-plan.md:276`).

### F-007 — AC-024's "lose and then regain the screen-owned names" is unachievable with the navigation the plan uses

- Severity: BLOCKER
- Location: `wiki/work/0014-example-feature-coverage/02-criteria.md:42`
- Criterion affected: AC-024
- Observation: the details route is opened with `Navigator.of(context).push(MaterialPageRoute(...))`
  (`example/lib/example_screen.dart:80-89`), and `MaterialPageRoute.maintainState` defaults to true,
  so `_ExampleScreenState` is never disposed during the push. `WebMcpScreen.dispose` is the only
  thing that calls `mcpScope.close()` (`lib/src/widgets/webmcp_screen.dart:35-39`), so the
  screen-owned names stay registered for the whole navigation. The criterion's own check method
  compounds this: "Observing the list and the two counter values before the push and after the pop"
  never observes the list while the details route is on top, so the "lose" half is not observable
  even in principle. The transport-count half of AC-024 is sound (the details page's own
  `example.details.page.read` and `.act` are registered on push and unregistered on pop).
- Why it matters: a browser-group criterion that cannot be met, and the plan's risk table does not
  mention it.

### F-008 — AC-025 is unachievable given the observer's five-line bound and the startup event volume

- Severity: BLOCKER
- Location: `wiki/work/0014-example-feature-coverage/02-criteria.md:43`;
  `wiki/work/0014-example-feature-coverage/01-plan.md:151-155`
- Criterion affected: AC-025
- Observation: the observer holds "at most the five most recent event lines" (`01-plan.md:152-153`).
  Counting the registrations the fixed startup order and first frame produce with the observer
  already subscribed: two application-level source names, `example.app.observe`
  (`lib/src/page/webmcp_app_session.dart:177`), `example.counter.read` and
  `example.counter.increment` (`example/lib/example_tools.dart:15-27`), `example.screen.describe`
  (`example/lib/example_screen.dart:30`), two screen-level source names (the two colliding ones
  raise `WebMcpDuplicateToolException` in `registerTool` before any transport or observer
  notification, `lib/src/webmcp.dart:87-97`), `example.screen.increment` via `WebMcpAction`, and
  post-frame `example.home.page.read` and `example.home.page.act` — about eleven events. The five
  retained lines after the AC-024 navigation are therefore the `example.details.page.*` and
  `example.home.page.*` events; no line names a screen-owned name. AC-025 requires "at least one
  line naming a screen-owned tool name".
- Why it matters: the criterion fails by construction, and the plan does not reconcile the
  retention bound with the number of startup events.

### F-009 — AC-015 refers to nine session diagnostic getters "named in the plan"; the plan names none

- Severity: BLOCKER
- Location: `wiki/work/0014-example-feature-coverage/02-criteria.md:28`; plan text at
  `wiki/work/0014-example-feature-coverage/01-plan.md:216-219`; task at
  `wiki/work/0014-example-feature-coverage/03-tasks.md:40`
- Criterion affected: AC-015, AC-030
- Observation: AC-015 says "each of the nine session diagnostic getters named in the plan". Step 12
  says only "every session diagnostic getter with its name" and the Interfaces section names none.
  `WebMcpAppSession` does expose exactly nine public diagnostic getters
  (`lib/src/page/webmcp_app_session.dart:92,95,98,101,104,107,143,146,152`), but the class also
  exposes the unrelated static `activeSession` (`:74`), and `WebMcpNavigatorAdapter` exposes four
  more getters (`:699,703,707,710`), so the set of nine is not unambiguous from the artifact.
- Why it matters: the criterion is not checkable without the list it claims exists, and task 3.3's
  "Done when" inherits the same dangling reference.

### F-010 — AC-001 has no owning test file in `03-tasks.md`

- Severity: BLOCKER
- Location: `wiki/work/0014-example-feature-coverage/03-tasks.md:27` and `:46`; criterion at
  `wiki/work/0014-example-feature-coverage/02-criteria.md:14`
- Criterion affected: AC-001
- Observation: AC-001's check is "run `cd example && flutter test`, where a test asserts both names
  are present after the application-level registration", with a negative case requiring a
  no-source absence assertion and a double-registration duplicate exception. Task 2.1 owns only
  `example/lib/example_tool_source.dart` and no test file; task 4.1 owns only
  `example/lib/main.dart`. The "Test tasks" table (`03-tasks.md:69-79`) has no row for AC-001.
- Why it matters: a criterion whose stated check nothing in the task list produces. The
  `example/test/` file that would hold it is also not listed in the serialised-files table, so no
  task may create it.

### F-011 — AC-014 is assigned to a task that does not own the test file the criterion names, in a group that runs after the one that does

- Severity: BLOCKER
- Location: `wiki/work/0014-example-feature-coverage/03-tasks.md:31` and `:39`; criterion at
  `wiki/work/0014-example-feature-coverage/02-criteria.md:27`
- Criterion affected: AC-013, AC-014
- Observation: AC-014's check names `example/test/example_agent_probe_test.dart` and requires it to
  pump the form screen. That file is owned exclusively by task 2.5 in Group 2
  (`03-tasks.md:31`), which is assigned only AC-013 and whose "Done when" says the probe is tested
  "against a page declared inside the test file". AC-014 is assigned to task 3.2
  (`03-tasks.md:39`), which owns `example/test/example_page_surface_test.dart`. Groups run in
  sequence (`03-tasks.md:12`), so task 2.5 executes before `example/lib/example_form_screen.dart`
  exists. The legend states "Owned files are exclusive. Two tasks never list the same file"
  (`03-tasks.md:8`).
- Why it matters: the implementer must either write into a file it does not own or violate the file
  the criterion names; either way the ownership table stops describing reality.

### F-012 — Group 3's three `[P]` tasks are mutually dependent through constructor shapes the plan does not fix

- Severity: BLOCKER
- Location: `wiki/work/0014-example-feature-coverage/03-tasks.md:38-40`; plan decision at
  `wiki/work/0014-example-feature-coverage/01-plan.md:284-286`
- Criterion affected: AC-002, AC-015
- Observation: tasks 3.1, 3.2 and 3.3 are all marked `[P]`. Task 3.1 must render "buttons opening
  the form and diagnostics screens" (`03-tasks.md:38`), which requires importing and constructing
  `ExampleFormScreen` and `ExampleDiagnosticsScreen`, both created by tasks 3.2 and 3.3 running
  concurrently. The plan fixes only the set of constructor arguments in prose — "New screens take
  the publisher, the transport, the observer and the default transport identifier as constructor
  arguments" (`01-plan.md:284-285`) — not the class names, the parameter names, which of the four
  each screen takes, or their nullability. Task 3.1's own widget test
  (`example/test/example_home_screen_test.dart`) cannot compile until both other tasks land.
- Why it matters: three tasks marked parallel that each decide one shared interface. Per
  `wiki/conventions/parallelism.md` and `AGENTS.md`, a cross-cutting interface decision must be
  made before fan-out; here it is left to the fan-out itself.

### F-013 — The publisher and capability diagnostic maps overlap, making AC-015's "one row per key" self-contradictory

- Severity: IMPORTANT
- Location: `wiki/work/0014-example-feature-coverage/01-plan.md:216-217`; criterion at
  `wiki/work/0014-example-feature-coverage/02-criteria.md:28`
- Criterion affected: AC-015, AC-030
- Observation: `WebMcpNativePublisherStatus.toDiagnosticMap()` already spreads the capability map
  into itself (`lib/src/transport/webmcp_native_publisher.dart:65-74`:
  `'support': support.name, ...capabilities.toDiagnosticMap(), …`). The four capability keys
  (`lib/src/transport/webmcp_native_capabilities.dart:34-40`) are therefore a strict subset of the
  publisher keys. Rendering "every entry of the publisher diagnostic map, every entry of the
  capability diagnostic map" produces two rows for each of those four keys, which the stated check
  ("asserts one row per key and getter") rejects. Separately, `reasonCodes` is an empty list
  whenever nothing failed (`lib/src/transport/webmcp_native_publisher.dart:251-253`), so its row has
  no value to show, which AC-015's "each row showing a non-empty value" and AC-030's "A blank value
  … fails" both penalise in the normal, expected `localOnly` case.
- Why it matters: the diagnostics screen cannot simultaneously satisfy the rendering instruction and
  the assertion, and the expected stock-browser reading trips the blank-value rule.

### F-014 — The form policy's `maxTextLength` and `includeNonEditableValues` values are left to the implementer while AC-010 asserts all eight fields are non-default

- Severity: IMPORTANT
- Location: `wiki/work/0014-example-feature-coverage/01-plan.md:201`; criterion at
  `wiki/work/0014-example-feature-coverage/02-criteria.md:23`
- Criterion affected: AC-010
- Observation: the plan says the policy "caps accepted text length below the protocol maximum"
  without naming a number. `WebMcpPagePolicy` defaults `maxTextLength` to 1024 with a ceiling of
  4096 (`lib/src/page/webmcp_page_protocol.dart:251,270-276`), so the default already satisfies
  "below the protocol maximum" while failing AC-010's requirement that the fields "hold those
  non-default values" and its negative case that "the default policy object does not hold those
  values". AC-010 also says "the policy object's eight fields" but names non-default expectations
  for only seven; `includeNonEditableValues` (`:254`) is decided nowhere.
- Why it matters: two policy values the shared-decisions section was supposed to fix are open, and
  one plausible choice makes the criterion fail.

### F-015 — Test discipline for the process-wide `WebMcpAppSession` static is unstated, and two parallel tasks need it

- Severity: IMPORTANT
- Location: `wiki/work/0014-example-feature-coverage/01-plan.md:353-361`;
  `wiki/work/0014-example-feature-coverage/03-tasks.md:31` and `:39`
- Criterion affected: AC-003, AC-011, AC-013, AC-014
- Observation: `WebMcpAppSession.attach` returns a `resourceLimit` error envelope rather than
  attaching whenever a different session is already the static `_activeSession`
  (`lib/src/page/webmcp_app_session.dart:164-167`), and only `detach()` clears it
  (`:210-213`). The library's own page tests therefore run
  `tearDown(() { WebMcpAppSession.activeSession?.detach(); WebMcp.instance.reset(); })`
  (`test/page/webmcp_page_test.dart:19-22`). The plan's verification section states only that
  "The new tests live beside the code they cover, one file per concept" and says nothing about
  setUp/tearDown of the registry singleton or the session static.
- Why it matters: the second test in any file that attaches a session silently gets an unattached
  session and every page assertion fails for an unrelated reason. Two tasks marked `[P]` must each
  rediscover this.

### F-016 — The conditional `example/analysis_options.yaml` edit is owned by a Group 1 task but can only be triggered by evidence produced in Group 5

- Severity: IMPORTANT
- Location: `wiki/work/0014-example-feature-coverage/03-tasks.md:20` and `:53`; plan decision at
  `wiki/work/0014-example-feature-coverage/01-plan.md:288-291`
- Criterion affected: AC-033, AC-038
- Observation: task 1.2 owns `example/analysis_options.yaml` and is told to add the generated-path
  exclusion "if and only if analysis reports an issue located in that generated file". The
  analysis stage that would report it is stage 4 of `tools/check.sh`, run by task 5.1
  (`03-tasks.md:53`), whose "Files owned" column reads `none`. The serialised-files table
  (`03-tasks.md:61`) assigns the file to 1.2 only.
- Why it matters: when the risk at `01-plan.md:303` fires, no task is permitted to apply its own
  stated mitigation, and the file-ownership table forbids the task that discovers it from acting.

### F-017 — `ExampleCounter`'s shape is a shared choice between two `[P]` tasks

- Severity: IMPORTANT
- Location: `wiki/work/0014-example-feature-coverage/03-tasks.md:27` and `:32`
- Criterion affected: AC-001, AC-004
- Observation: task 2.1 builds a tool source that "takes the live counter" and must produce a
  *reset* descriptor; task 2.6 owns `example/lib/example_tools.dart`, where `ExampleCounter` is
  declared (`example/lib/example_tools.dart:4-11`, currently `int value` plus `int increment()`),
  and must make the handler honour a `by` amount. Both are marked `[P]`. Whether `ExampleCounter`
  gains a `reset()` and an `incrementBy(int)`, or both callers mutate `value` directly, is decided
  nowhere.
- Why it matters: task 2.1 compiles against a type another concurrent task may reshape; the plan's
  own rule is that shared design choices are settled before fan-out.

### F-018 — `WebMcpScreen.maybeScopeOf` called from the home screen's own build cannot find that screen's scope, and no criterion covers the rendered line

- Severity: IMPORTANT
- Location: `wiki/work/0014-example-feature-coverage/01-plan.md:195`
- Criterion affected: none
- Observation: the plan adds "the result of the direct screen-scope lookup call" to the home screen
  but does not fix the context it is called from. `maybeScopeOf` uses
  `context.visitAncestorElements` (`lib/src/widgets/webmcp_screen.dart:15-22`), which starts at the
  parent element, so a call made with `_ExampleScreenState`'s own `context` inside `build` skips the
  state that carries the scope and returns null. No criterion in `02-criteria.md` mentions this
  line; AC-002 covers only the owned-name and skipped-name lists.
- Why it matters: the most obvious reading of the step produces a permanent "not found" reading that
  looks like a defect on the demonstration screen, and because no criterion covers it, nothing would
  catch that. Either the call site is a missing decision or the line is scope creep.

### F-019 — AC-023's negative case trips on names the library registers unavoidably

- Severity: IMPORTANT
- Location: `wiki/work/0014-example-feature-coverage/02-criteria.md:41`
- Criterion affected: AC-023
- Observation: AC-023's negative case is "A name present in the list that is not in the plan's fixed
  list … fails this criterion". The home screen's rendered list is
  `WebMcp.instance.tools` (`example/lib/example_screen.dart:44-46`), which at walkthrough time also
  contains `example.app.observe` (`lib/src/page/webmcp_app_session.dart:177`) and
  `example.home.page.read` / `example.home.page.act` (`lib/src/page/webmcp_page.dart:577,585`).
  AC-023's enumeration names ten tools and omits all three.
- Why it matters: a negative case that fires on correct behaviour makes the criterion unusable as a
  gate; the verifier must decide on the spot whether to ignore it.

### F-020 — The rollback section's blast-radius claim is false

- Severity: IMPORTANT
- Location: `wiki/work/0014-example-feature-coverage/01-plan.md:316-318`
- Criterion affected: AC-033
- Observation: the plan states "No library source under `lib/`, no published package version, no
  shared configuration and no continuous-integration script changes, so nothing outside the example
  can regress." The root test `test/repo_hygiene_test.dart` parses every `.dart` file under
  `example/lib` and fails on a parse diagnostic, a forbidden import or a secret marker
  (`test/repo_hygiene_test.dart:225-233` and `:280-306`, which enumerate `example/lib` via
  `_dartFiles` and `git ls-files … example/lib`). A new or generated file under `example/lib` can
  therefore fail a root-suite test, and stage 5 of `tools/check.sh` runs that suite.
- Why it matters: the plan tells the implementer that root-suite failures cannot come from this
  change, which will misdirect diagnosis when they do.

### F-021 — The act call's required arguments and the retry's request-identifier rule are not decided

- Severity: IMPORTANT
- Location: `wiki/work/0014-example-feature-coverage/01-plan.md:167-176`
- Criterion affected: AC-013, AC-014
- Observation: the act endpoint requires all of `pageId`, `mountToken`, `revision`, `handle`,
  `action`, `requestId` and `arguments`
  (`lib/src/page/webmcp_page.dart:1234-1246`, enforced at `:921-941`). The plan names only the mount
  token, the revision and the handle. `requestId` must be at least 1
  (`lib/src/page/webmcp_page.dart:988`) and strictly greater than the highest previously seen value,
  or the call returns `duplicateRequest` unless the request fingerprint is byte-identical
  (`:1004-1010`) — and a retry after a stale reading has a *different* revision, hence a different
  fingerprint. The plan's mandated single retry (`:174-176`) therefore returns `duplicateRequest`
  rather than succeeding if the probe reuses its request identifier, and the plan fixes no
  request-identifier strategy.
- Why it matters: an implementer must invent the request-identifier scheme, and the obvious choice
  (reuse) silently converts every retry into a `duplicateRequest` reading that AC-014 would then
  report as a passing "page error code" under AC-013 while failing AC-014.

### F-022 — Step 1's escalation gate guards a condition that is already false and duplicates the check script

- Severity: NIT
- Location: `wiki/work/0014-example-feature-coverage/01-plan.md:115-119`;
  `wiki/work/0014-example-feature-coverage/03-tasks.md:19`
- Criterion affected: none
- Observation: both binaries resolve in a non-interactive shell (pasted above: Dart 3.13.0, Flutter
  3.47.0), and `tools/check.sh:7-14` already preflights them and exits with a named message. Step 1
  and task 1.1 also list AC-033 and AC-034 as satisfied, which they do not satisfy — running
  `--version` establishes neither the check suite nor the wiki linter.
- Why it matters: a whole task and a human-escalation gate for a resolved question, and two
  criterion references that do not hold.

### F-023 — The page endpoint suffix is described rather than named

- Severity: NIT
- Location: `wiki/work/0014-example-feature-coverage/01-plan.md:261-263`
- Criterion affected: none
- Observation: the Interfaces section names `example.app.observe` exactly but describes the others
  as "the read and act endpoints suffixed onto those page identifiers". The literal suffixes are
  `.page.read` and `.page.act` (`lib/src/page/webmcp_page.dart:577,585`).
- Why it matters: the section exists to remove guesswork; the fixed strings should be written out
  as the observe endpoint's is.

### F-024 — The home screen's imperative tools are registered unscoped, so a remount raises an uncaught duplicate exception

- Severity: PRE_EXISTING
- Location: `example/lib/example_screen.dart:23-26` calling
  `example/lib/example_tools.dart:13-28`
- Criterion affected: AC-036
- Observation: `registerExampleTools` calls `WebMcp.instance.registerTool` directly rather than
  through a scope, and nothing ever unregisters the two names. A second `initState` of
  `_ExampleScreenState` — a hot restart that preserves the registry, or any future route
  replacement — raises `WebMcpDuplicateToolException` (`lib/src/webmcp.dart:90-92`) from
  `initState`, which surfaces as an uncaught framework exception. The AC-024 push-and-pop
  navigation does not remount the screen, so the planned walkthrough does not hit it.
- Why it matters: recorded only. Step 9 edits this file and step 10 edits its caller without
  touching the pattern; expanding this work item to fix it is not warranted, but AC-036's
  "no uncaught Flutter framework exception" is one hot restart away from failing.

## Recurrence check

- Previous round: none — first round. `wiki/work/0014-example-feature-coverage/validation/` was
  empty before this report.
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | research — the page read wire shape was not established; then plan, to redesign probe targeting |
| F-002 | plan — criteria authored against a response field that does not exist |
| F-003 | plan — shared interface decision missing before fan-out |
| F-004 | research — page eligibility preconditions unestablished; then plan, to specify the test harness and its owner |
| F-005 | plan — criterion contradicts the specified behaviour |
| F-006 | plan — undecided registration site for the generated source |
| F-007 | plan — criterion contradicts the navigation the plan uses |
| F-008 | plan — criterion contradicts the retention bound the plan sets |
| F-009 | plan — dangling reference from criteria into the plan |
| F-010 | plan — task decomposition gap |
| F-011 | plan — task decomposition and file-ownership gap |
| F-012 | plan — parallel markers on interdependent tasks |
| F-013 | plan — rendering instruction and criterion cannot both hold |
| F-014 | plan — shared configuration values undecided |
| F-015 | plan — test-harness discipline undecided across parallel tasks |
| F-016 | plan — file ownership versus phase ordering |
| F-017 | plan — shared type shape undecided across parallel tasks |
| F-018 | plan — either a missing decision or scope creep; decide which |
| F-019 | plan — criterion negative case unusable |
| F-020 | plan — incorrect blast-radius statement in the rollback section |
| F-021 | plan — undecided act-call arguments and retry identifier rule |
| F-022 | plan — NIT, no routing required |
| F-023 | plan — NIT, no routing required |
| F-024 | none — pre-existing, record only |

No finding is a one-way door. The plan's rollback reasoning is otherwise sound and needs no human
escalation; F-020 is a factual correction to it, not a new irreversible risk.
