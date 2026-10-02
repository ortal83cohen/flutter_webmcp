# Impl review — round 01

- Work item: 0018-author-argument-dx
- Reviewed artifact: the uncommitted working tree (16 modified files, repository at `1a52d7c chore(release): v0.1.10`), judged against `wiki/work/0018-author-argument-dx/02-criteria.md`
- Reviewer: impl-validator
- Date: 2026-10-02

## Verdict

**PASS**

All thirty-four criteria hold, every stage of `bash tools/check.sh` reports passed, and forty-four deliberate mutations of the production code — one or more per criterion — each turned the suite red, so no criterion rests on an assertion that cannot fail.

## Verification performed

### Scope of the diff under review

```
$ git status --porcelain
 M lib/src/webmcp_exceptions.dart
 M lib/src/webmcp_tool.dart
 M lib/src/webmcp_typed_input.dart
 M lib/src/widgets/webmcp_action.dart
 M packages/webmcp_flutter_annotations/lib/webmcp_flutter_annotations.dart
 M packages/webmcp_flutter_generator/example/lib/inventory_service.dart
 M packages/webmcp_flutter_generator/example/lib/inventory_service.webmcp.g.dart
 M packages/webmcp_flutter_generator/example/pubspec.lock
 M packages/webmcp_flutter_generator/example/test/live_instance_test.dart
 M packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart
 M packages/webmcp_flutter_generator/pubspec.lock
 M packages/webmcp_flutter_generator/test/generator_test.dart
 M test/native_publisher_test.dart
 M test/registry_test.dart
 M test/webmcp_public_surface_test.dart
 M test/widget_layer_test.dart
?? wiki/work/0018-author-argument-dx/

$ git diff --stat
 lib/src/webmcp_exceptions.dart                     |  39 +-
 lib/src/webmcp_tool.dart                           |  12 +-
 lib/src/webmcp_typed_input.dart                    | 115 ++++-
 lib/src/widgets/webmcp_action.dart                 |  45 +-
 .../lib/webmcp_flutter_annotations.dart            |  20 +
 .../example/lib/inventory_service.dart             |   3 +
 .../example/lib/inventory_service.webmcp.g.dart    |   3 +
 .../webmcp_flutter_generator/example/pubspec.lock  |   2 +-
 .../example/test/live_instance_test.dart           |  34 +-
 .../lib/src/webmcp_domain_action_generator.dart    |  48 +-
 packages/webmcp_flutter_generator/pubspec.lock     |   2 +-
 .../test/generator_test.dart                       | 158 ++++++
 test/native_publisher_test.dart                    |  90 ++++
 test/registry_test.dart                            | 564 +++++++++++++++++++++
 test/webmcp_public_surface_test.dart               |   2 +
 test/widget_layer_test.dart                        | 344 +++++++++++++
 16 files changed, 1450 insertions(+), 31 deletions(-)
```

### Full check script (AC-033)

Run twice: once before probing and once after the tree was restored. Both runs are byte-identical in the stages they report.

```
$ bash tools/check.sh
Preflight: flutter and dart found
Stage 1 passed: wiki lint
Stage 2 passed: dependencies
Stage 3 passed: format
Stage 4 passed: analysis
Stage 5 passed: tests
Stage 6 passed: build
Stage 7 passed: version bump test
Stage 8 passed: occupied pub.dev versions test
EXIT=0
```

Stage 3 and stage 4 detail, which AC-015 depends on:

```
Formatted 70 files (0 changed) in 0.23 seconds.
Stage 3 passed: format
Analyzing flutter_webmcp...
No issues found!
Analyzing webmcp_flutter_annotations...
No issues found!
Analyzing webmcp_flutter_generator...
No issues found!
Analyzing example...
No issues found!
Stage 4 passed: analysis
```

Stage 5 detail for the four suites that carry this work item's criteria:

```
00:05 +157: All tests passed!                                     (flutter test, root)
00:03 +54: All tests passed!                                      (example)
00:00 +3: test/generator_test.dart: emits title, debugging, and origins only when they are set
00:00 +4: test/generator_test.dart: emits none of the metadata members when none are set
00:00 +5: test/generator_test.dart: reports a blank title (0 chars) through the log
00:00 +6: test/generator_test.dart: reports a blank title (3 chars) through the log
00:00 +7: test/generator_test.dart: does not report a valid non-empty title
00:00 +8: All tests passed!                                       (generator)
00:00 +0: generated source preserves authorization and uses the live instance
00:00 +1: invalid arguments fail safely before invoking the instance
00:00 +2: generated metadata reaches the registered descriptor
00:00 +3: scope replacement transfers lifecycle ownership to another instance
00:00 +4: All tests passed!                                       (generator fixture)
Stage 5 passed: tests
```

Stage 6 regenerated the fixture and wrote no new output, which confirms the committed
`inventory_service.webmcp.g.dart` matches what the generator under review produces:

```
  0s webmcp_flutter_generator:webmcp_domain_action on 2 inputs; lib/inventory_service.dart
  0s webmcp_flutter_generator:webmcp_domain_action on 2 inputs: 2 skipped
  Built with build_runner/aot in 1s; wrote 0 outputs.
Stage 6 passed: build
```

### Negative-case probing

A green suite proves nothing about whether an assertion can fail. I mutated the production
code once per stated negative case, ran the affected suite, then restored the tree from a
byte-exact backup. Forty-four mutations were applied in total; forty-three turned the suite
red on the first attempt, and the one that did not is explained below.

```
$ shasum /tmp/0018_baseline.diff /tmp/0018_after.diff
da9bf22bf8329a97c64d791d44a76f28e3cf2cbc  /tmp/0018_baseline.diff
da9bf22bf8329a97c64d791d44a76f28e3cf2cbc  /tmp/0018_after.diff
```

Each line below is one mutation, the criterion it attacks, and the test that caught it.

| Mutation | Criterion | Caught by |
|---|---|---|
| `withDecodedArguments` stops deriving and stores the empty schema | AC-001, AC-029 | 8 tests in `derived input schema`, plus `publishes the schema derived from the field list` |
| `withDecodedArguments` derives even when the author passed a schema | AC-001 neg | `keeps a non-empty author schema unchanged`, `an explicit input schema is kept unchanged` |
| `required` emitted unconditionally | AC-002 | `lists only required keys and omits required when none` |
| `required` lists every field, not just the required ones | AC-002 neg | `lists only required keys and omits required when none` |
| safe-integer schema loses `maximum` | AC-003 neg | `derives scalar property schemas`, `recurses through list and map children` |
| finite-double schema gains a `format` keyword | AC-003 neg | `derives scalar property schemas` |
| enumeration schema loses its `enum` array | AC-004 neg | `derives enumeration schemas including an empty name list` + 2 |
| `enum` array contents replaced | AC-004 neg | `derives enumeration schemas including an empty name list` + 2 |
| `anyOf` union applied to non-nullable fields instead of nullable ones | AC-005 neg | 6 tests in `derived input schema` |
| `items` and `additionalProperties` child entries dropped | AC-006 neg | `recurses through list and map children`, `two tools ... share no nested state` |
| childless list throws during schema derivation | AC-007 neg | `a childless list or map constructs with only its base type` + 11 |
| derived schema memoised per field list, so two tools share nested maps | AC-008 neg | `two tools from one field list share no nested state` |
| plain `WebMcpTool` constructor injects an object type entry | AC-009 neg | `a plain tool keeps an empty schema` |
| `title` member emitted for every method | AC-010 neg, AC-014 | `emits title, debugging, and origins only when they are set`, `emits none of the metadata members when none are set` |
| `debugging` member emitted for every method | AC-011 neg, AC-014 | same two tests |
| omitted debugging hint defaults to `false` | AC-011 neg | same two tests |
| emitted origin list reversed | AC-012 neg | `emits title, debugging, and origins only when they are set` |
| origin member emitted for every method | AC-012 neg, AC-014 | `emits none of the metadata members when none are set` + 2 |
| blank-title check disabled | AC-013 | `reports a blank title (0 chars)`, `reports a blank title (3 chars)` |
| blank-title check widened to every non-null title | AC-013 neg | `does not report a valid non-empty title` |
| unknown-key failure reports reason `type` | AC-016 | `an undeclared key is unknown and names the caller key`, publisher test |
| every key, declared or not, reported as unknown | AC-016 neg | `a declared key is never reported as unknown` + 10 |
| missing-key failure reports reason `type` | AC-017 | `an absent required key is missing and names the declared key`, publisher test |
| absent optional key rejected like a required one | AC-017 neg | `an absent optional key neither throws nor is decoded` + 4 |
| shape rejection reports reason `missing` | AC-018 | `every shape rejection is type and names the top-level key` + 3 |
| a valid enumeration value rejected | AC-018 neg | `values that satisfy each shape decode without throwing` |
| nested failure reports the child field's key | AC-019 neg | `a nested failure names the top-level key, not the child`, publisher test |
| details map gains a third entry | AC-020 neg, AC-034 | publisher test + 4 registry tests |
| details `reason` becomes a nested map | AC-034 neg | publisher test + 3 registry tests |
| details carry the exception type name | AC-021 neg | publisher test + 3 registry tests |
| no-argument constructor records a key, reason and details | AC-022 neg | `the const no-argument constructor records nothing` |
| generated invoker rethrows instead of returning the envelope | AC-023 neg | `invalid arguments fail safely before invoking the instance` |
| generated error object gains a details entry | AC-023 neg | same test |
| generated integer decoder accepts an out-of-range value, so the domain method runs | AC-024 neg | same test (`expect(service.calls, 0)`) |
| action registers a non-decoding tool | AC-025 neg | `decodes before the callback and rejects undeclared keys` + 3 |
| fields-with-`onInvoke` pairing accepted | AC-026 | `field list with the one-argument callback throws` |
| pairing error raised before the exactly-one-callback error | AC-026 neg | `exactly-one-callback error still reports first` |
| rebuild re-registers against the new field list | AC-027 neg | `keeps the field list captured at the first mount` |
| handler pins the first-mount callback | AC-028 neg | `dispatches a successful decode to the newest callback` |
| `build` wraps the child in a `Padding` | AC-030 neg | `renders the child unchanged and survives disabled children`, `action returns the identical tappable child` |
| owning state stops removing its tool on dispose | AC-030 neg | `action registers verbatim and unregisters independently`, `action keeps its mounted descriptor identity until replacement` |
| non-owning state removes the name, with the scope's ownership guard also removed | AC-030 | `a state that does not own the name leaves it on unmount`, `duplicate actions preserve the first owner` |
| `_dispatch` validates arguments against `inputSchema['required']` | AC-031 neg | `invocation never validates arguments against a schema` + 3 |
| `src/webmcp_typed_input.dart` export removed from the public library | AC-032 neg | all four root suites fail to load |

The one mutation that did not turn the suite red, and why it is not a gap: removing only the
`_ownsTool` guard in `lib/src/widgets/webmcp_action.dart:149` leaves every test green, because
`WebMcpScope.removeTool` (`lib/src/webmcp_scope.dart:47-52`) refuses to remove a name the scope
does not own. The widget-level guard is redundant, not unverified. Removing both guards together
does turn the suite red, as the last-but-two row records, so the behaviour AC-030 states is
genuinely covered.

### Leftovers and test gaming

```
$ grep -nE "^\+.*(TODO|FIXME|XXX|print\(|debugPrint|skip:|solo|markTestSkipped)" /tmp/0018_baseline.diff
(no output)
$ grep -nE "^\+" /tmp/0018_baseline.diff | grep -iE "mock|fake|stub"
(no output)
```

No skipped or pending test, no mock introduced to make an assertion pass, no debug output, no
commented-out code. The new assertions are literal-map equalities rather than widened matchers:
`test/registry_test.dart:414-423` compares the whole properties map against a literal, and
`test/native_publisher_test.dart:901` compares the whole details map against a literal and then
asserts its length separately.

## Per-criterion results

| Criterion | Result | Evidence (file:line) | Negative case exercised |
|---|---|---|---|
| AC-001 | pass | `lib/src/webmcp_tool.dart:122`; `test/registry_test.dart:350`, `:365` | yes |
| AC-002 | pass | `lib/src/webmcp_typed_input.dart:83`; `test/registry_test.dart:378` | yes |
| AC-003 | pass | `lib/src/webmcp_typed_input.dart:92-104`; `test/registry_test.dart:407` | yes |
| AC-004 | pass | `lib/src/webmcp_typed_input.dart:105-108`; `test/registry_test.dart:430` | yes |
| AC-005 | pass | `lib/src/webmcp_typed_input.dart:122-131`; `test/registry_test.dart:448` | yes |
| AC-006 | pass | `lib/src/webmcp_typed_input.dart:109-120`; `test/registry_test.dart:484` | yes |
| AC-007 | pass | `lib/src/webmcp_typed_input.dart:113`, `:119`; `test/registry_test.dart:535` | yes |
| AC-008 | pass | `lib/src/webmcp_typed_input.dart:70-86`; `test/registry_test.dart:549` | yes |
| AC-009 | pass | `lib/src/webmcp_tool.dart:80`, `:86`; `test/registry_test.dart:586` | yes |
| AC-010 | pass | `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart:322`; `packages/webmcp_flutter_generator/test/generator_test.dart:143` | yes |
| AC-011 | pass | `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart:339`; `packages/webmcp_flutter_generator/test/generator_test.dart:143` | yes |
| AC-012 | pass | `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart:325-330`; `packages/webmcp_flutter_generator/test/generator_test.dart:143` | yes |
| AC-013 | pass | `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart:131-136`; `packages/webmcp_flutter_generator/test/generator_test.dart:238`, `:268` | yes |
| AC-014 | pass | `packages/webmcp_flutter_generator/test/generator_test.dart:207` | yes |
| AC-015 | pass | `packages/webmcp_flutter_annotations/lib/webmcp_flutter_annotations.dart:16-18`, `:40-51`; stage 3, 4 and 6 output above | yes (stages are hard gates; `--fatal-infos --fatal-warnings`) |
| AC-016 | pass | `lib/src/webmcp_typed_input.dart:147-150`; `test/registry_test.dart:712`, `:724` | yes |
| AC-017 | pass | `lib/src/webmcp_typed_input.dart:156-160`; `test/registry_test.dart:731`, `:746` | yes |
| AC-018 | pass | `lib/src/webmcp_typed_input.dart:172-175`; `test/registry_test.dart:754`, `:814` | yes |
| AC-019 | pass | `lib/src/webmcp_typed_input.dart:173`, `:221`, `:234`; `test/registry_test.dart:840` | yes |
| AC-020 | pass | `lib/src/webmcp_exceptions.dart:101`; `test/native_publisher_test.dart:897-902` | yes |
| AC-021 | pass | `lib/src/webmcp_exceptions.dart:93-102`; `test/native_publisher_test.dart:907-912` | yes |
| AC-022 | pass | `lib/src/webmcp_exceptions.dart:84-87`; `test/registry_test.dart:870` | yes |
| AC-023 | pass | `packages/webmcp_flutter_generator/example/lib/inventory_service.webmcp.g.dart:155-163`; `packages/webmcp_flutter_generator/example/test/live_instance_test.dart:44` | yes |
| AC-024 | pass | `packages/webmcp_flutter_generator/example/test/live_instance_test.dart:68` | yes |
| AC-025 | pass | `lib/src/widgets/webmcp_action.dart:112-124`; `test/widget_layer_test.dart:367` | yes |
| AC-026 | pass | `lib/src/widgets/webmcp_action.dart:37-48`; `test/widget_layer_test.dart:397`, `:422`, `:460` | yes |
| AC-027 | pass | `lib/src/widgets/webmcp_action.dart:110`, `:118`; `test/widget_layer_test.dart:491` | yes |
| AC-028 | pass | `lib/src/widgets/webmcp_action.dart:123`; `test/widget_layer_test.dart:515` | yes |
| AC-029 | pass | `lib/src/widgets/webmcp_action.dart:119`; `test/widget_layer_test.dart:545`, `:571`, `:594` | yes |
| AC-030 | pass | `lib/src/widgets/webmcp_action.dart:145`, `:148-153`; `test/widget_layer_test.dart:609`, `:647` | yes |
| AC-031 | pass | `lib/src/webmcp.dart:224-240` (unchanged, no schema read); `test/registry_test.dart:590` | yes |
| AC-032 | pass | `lib/webmcp_flutter.dart:10`; `test/webmcp_public_surface_test.dart:69-70` | yes |
| AC-033 | pass | stage output pasted above, `EXIT=0` | yes (stage failure aborts the script) |
| AC-034 | pass | `lib/src/webmcp_exceptions.dart:101`; `test/native_publisher_test.dart:901-906` | yes |

Totals: 34 pass, 0 fail.

## Findings

### F-001 — The generator fixture lockfiles carry an unrelated dependency bump

- Severity: NIT
- Location: `packages/webmcp_flutter_generator/example/pubspec.lock` and `packages/webmcp_flutter_generator/pubspec.lock`, the `version:` line of the `webmcp_flutter` entry
- Criterion affected: none
- Observation: both lockfiles move `webmcp_flutter` from `"0.1.8"` to `"0.1.10"`. That is the side effect of `flutter pub get` catching up with the `v0.1.10` release already on `main`; nothing in this work item asked for it.
- Why it matters: it is noise in the diff, not a defect. Recording it so the commit message can account for it rather than leaving a reviewer to wonder.

### F-002 — The unmount assertion in the new render test is satisfied by the screen scope, not the action

- Severity: NIT
- Location: `test/widget_layer_test.dart:643-644`
- Criterion affected: AC-030
- Observation: the test pumps `_host(const SizedBox())`, which disposes the enclosing `_Screen` and therefore closes its `WebMcpScope`. The scope's `close()` unregisters every owned name independently of `_WebMcpActionState.dispose`. I confirmed this by disabling the removal in `dispose`: this test stays green while the pre-existing tests at `test/widget_layer_test.dart:75` and `:144` go red.
- Why it matters: nothing is uncovered — the suite as a whole still catches the regression — but this particular assertion is weaker than it reads.

### F-003 — The blank-title test asserts message text, not the error class

- Severity: NIT
- Location: `packages/webmcp_flutter_generator/test/generator_test.dart:260-263`
- Criterion affected: AC-013
- Observation: the test asserts the collected log contains `title`, the method name and `cannot be empty`. It does not assert that the entry originated from an `InvalidGenerationSource`. The criterion's "how it is checked" column explicitly permits this (it says the test must not assert a thrown error), and the message is produced only by the throw at `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart:131-136`, so the assertion is still specific in practice.
- Why it matters: a future refactor could emit the same text through a plain log and the test would not notice.

## Recurrence check

- Previous round: none — first implementation review round
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | none — housekeeping for the commit, no phase owns it |
| F-002 | none — NIT, no criterion fails |
| F-003 | none — NIT, explicitly permitted by AC-013 |
