# Plan review — round 01

- Work item: 0018-author-argument-dx
- Reviewed artifact: `wiki/work/0018-author-argument-dx/01-plan.md` and `wiki/work/0018-author-argument-dx/02-criteria.md`, working tree at 2026-10-02 (both files untracked, `git status` shows them as `??`)
- Reviewer: plan-validator
- Date: 2026-10-02

## Verdict

**FAIL**

Three criteria rest on assumptions about the repository that the source contradicts: two of them (AC-013, AC-014) specify a check that cannot fail no matter what the implementation does, and the third (AC-013's non-string origin element) requires an input that the plan's own step 6 makes impossible to construct.

## Verification performed

Plan shape and criteria wording:

```
$ grep -n '```' wiki/work/0018-author-argument-dx/01-plan.md | head
(no output — zero fenced code blocks)
$ grep -nE "correctly|properly|as expected" wiki/work/0018-author-argument-dx/02-criteria.md
(no output — no uncheckable wording)
```

Which stages `tools/check.sh` actually runs, and where `build_runner` runs:

```
$ cat tools/check.sh
...
python3 tools/lint_wiki.py || stage_failed 1 "wiki lint"
...
dart format --output=none --set-exit-if-changed \
  lib test example/lib example/test \
  packages/webmcp_flutter_annotations/lib \
  packages/webmcp_flutter_generator/lib \
  packages/webmcp_flutter_generator/test \
  packages/webmcp_flutter_generator/example/lib \
  packages/webmcp_flutter_generator/example/test || stage_failed 3 "format"
...
flutter test || stage_failed 5 "tests"
(cd example && flutter test) || stage_failed 5 "tests"
(cd packages/webmcp_flutter_generator && dart test) || stage_failed 5 "generator tests"
(cd packages/webmcp_flutter_generator/example && flutter test) || stage_failed 5 "generator fixture tests"
echo "Stage 5 passed: tests"

(cd example && flutter build web) || stage_failed 6 "build"
test -f example/build/web/index.html || stage_failed 6 "build"
(cd packages/webmcp_flutter_generator/example &&
  dart run build_runner build) || stage_failed 6 "generator build"
echo "Stage 6 passed: build"

sh tools/test_bump_patch_version.sh || stage_failed 7 "version bump test"
sh tools/test_occupied_pubdev_versions.sh || stage_failed 8 "occupied pub.dev versions test"

$ rg -n "build_runner" tools/ .github/
tools/check.sh:66:  dart run build_runner build) ||
.github/workflows/checks.yml:49:        run: bash tools/check.sh
.github/workflows/release.yml:67:        run: bash tools/check.sh
```

How the generator harness surfaces an `InvalidGenerationSource`:

```
$ cd packages/webmcp_flutter_generator && dart test
00:00 +0: loading test/generator_test.dart
00:00 +0: test/generator_test.dart: generates schemas, strict decoders, hints, and a live instance source
00:00 +1: test/generator_test.dart: rejects unsupported annotated signatures at build time
00:00 +2: test/generator_test.dart: rejects duplicate explicit tool names
00:00 +3: All tests passed!
```

Both existing negative generator tests pass while collecting the error through `onLog` and never expecting a throw (`packages/webmcp_flutter_generator/test/generator_test.dart:87-105` and `:109-131`), and `source_gen` does not catch its own `InvalidGenerationSource`:

```
$ grep -rn "InvalidGenerationSource" ~/.pub-cache/hosted/pub.dev/source_gen-4.2.4/lib/
lib/source_gen.dart:10:    show Generator, InvalidGenerationSource, InvalidGenerationSourceError;
lib/src/generator.dart:34:typedef InvalidGenerationSourceError = InvalidGenerationSource;
lib/src/generator.dart:40:class InvalidGenerationSource implements Exception {
lib/src/generator.dart:61:  InvalidGenerationSource(
```

Claims about the codebase that I checked and found **true**:

```
$ rg -n "withDecodedArguments" --glob '!wiki/**'
lib/src/webmcp_tool.dart:105:  factory WebMcpTool.withDecodedArguments({
test/registry_test.dart:294:      WebMcpTool.withDecodedArguments(
README.md:40, README.md:79, README.md:584
```

(the only in-repository tool built from the decoding factory is in `test/registry_test.dart`, as the first risk row claims)

```
$ grep -n "on WebMcpToolException\|_toolExceptionFailure" lib/src/transport/webmcp_native_publisher.dart
369:    } on WebMcpToolException catch (error) {
375:      return _toolExceptionFailure(error);
414:  String _toolExceptionFailure(WebMcpToolException error) {
$ grep -n "details" lib/src/transport/webmcp_native_publisher.dart
422:    final Map<String, Object?>? details = error.details;
423:    if (details != null) { ... 430: body['details'] = normalized;
$ rg -n "details" lib/src/page/*.dart
lib/src/page/webmcp_page_protocol.dart:123:      'The operation failed without exposing internal details.',
```

(the publisher already serializes an accepted details map and the page path never forwards one, so "the publisher is not touched" at `01-plan.md:16` holds; the page-session leak test at `test/page/webmcp_app_session_test.dart:66-79` does exercise a hand-built envelope, not the decoder)

```
$ sed -n '550,582p' packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart
  _ShapeKind.integer => {'type': 'integer', 'minimum': -9007199254740991, 'maximum': 9007199254740991},
  _ShapeKind.doubleValue => {'type': 'number'},
  ...
  return <String, Object?>{'anyOf': <Object?>[nonNull, const {'type': 'null'}]};
```

(the `anyOf` reading at `01-plan.md:85` and AC-005 matches the source; the escalation is correctly raised)

```
$ sed -n '262,275p' ~/.pub-cache/hosted/pub.dev/source_gen-4.2.4/lib/src/constants/reader.dart
  ConstantReader? peek(String field) {
    final constant = ConstantReader(getFieldRecursive(objectValue, field));
    return constant.isNull ? null : constant;
  }
  ConstantReader read(String field) { ... assertHasField(...) ... }
```

(the `peek` versus `read` claim at `01-plan.md:72` is accurate for the pinned `source_gen: 4.2.4` in `packages/webmcp_flutter_generator/pubspec.yaml:13`)

## Per-criterion results

Not applicable — this is a plan review, not an implementation review. Criterion coverage defects are reported as findings below.

## Findings

### F-001 — AC-013 asserts the generator build throws, but this harness reports generation errors as logs

- Severity: BLOCKER
- Location: `wiki/work/0018-author-argument-dx/02-criteria.md:24`, with the same assumption restated at `wiki/work/0018-author-argument-dx/01-plan.md:124`
- Criterion affected: AC-013
- Observation: AC-013's "How it is checked" column says the builder test "asserts the build throws for each of the two inputs and that the message contains the method name", and the plan's verification approach repeats "checked by asserting the build throws an invalid-generation-source error". The two negative tests already in `packages/webmcp_flutter_generator/test/generator_test.dart:87-105` and `:109-131` throw `InvalidGenerationSource` from exactly the same generator (`webmcp_domain_action_generator.dart:113`, `:35`) and do not expect a throw: they collect `onLog` records and assert on the message text. `dart test` in that package passes all three tests, which it could not do if `testBuilder` rethrew. `source_gen 4.2.4` does not catch the exception itself, so the swallow-and-log happens in the build harness below it.
- Why it matters: an implementer following AC-013 literally writes an expectation that cannot be satisfied, and the only way out is editing a frozen criterion. Worse, if the implementer instead writes a passing variant, the criterion no longer pins the stated behaviour.

### F-002 — AC-014's no-diff check runs against a file that nothing in `tools/check.sh` regenerates

- Severity: BLOCKER
- Location: `wiki/work/0018-author-argument-dx/02-criteria.md:25`, with the same assumption in step 7 at `wiki/work/0018-author-argument-dx/01-plan.md:41`
- Criterion affected: AC-014
- Observation: AC-014 says `example/lib/example_task_service.webmcp.g.dart` "shows no diff after the generator build stage of `bash tools/check.sh` completes". The generator build stage of `tools/check.sh:63-67` runs `dart run build_runner build` only in `packages/webmcp_flutter_generator/example`. The main application's generated file lives in `example/`, where the only stage that runs is `flutter build web` (`tools/check.sh:62`) and `flutter test` (`tools/check.sh:57`), neither of which invokes `build_runner`, even though `example/pubspec.yaml:19` has the dev dependency. No CI workflow adds a regeneration step; both workflows only call `tools/check.sh`.
- Why it matters: the criterion that is supposed to prove "every existing annotated method regenerates byte-identical output" (`01-plan.md:14`) is vacuous. The file cannot show a diff because nothing rewrites it, so a regression in the emission path for annotations that set none of the three new fields would pass AC-014 unnoticed.

### F-003 — AC-013's non-string origin element cannot be constructed given the plan's own step 6

- Severity: BLOCKER
- Location: `wiki/work/0018-author-argument-dx/02-criteria.md:24` against `wiki/work/0018-author-argument-dx/01-plan.md:40` and the validation rule at `01-plan.md:39`
- Criterion affected: AC-013, and the step 5 rule it checks
- Observation: step 5 requires the generator to reject "a non-string origin-list element" and AC-013 requires a test that feeds one in. The annotation field is specified at `01-plan.md:37` as a typed, nullable, null-defaulting field on `WebMcpDomainAction`, and the shared decision at `01-plan.md:78` names it a string list; step 6 instructs the test harness's duplicated annotation class (`packages/webmcp_flutter_generator/test/generator_test.dart:6-22`) to gain "the same three fields". With a `List<String>?` field, a fixture writing a non-string element is a compile error in the fixture library, so `_actionChecker.firstAnnotationOf(method, throwOnUnresolved: true)` at `webmcp_domain_action_generator.dart:25-28` fails on an unresolved annotation before `_readMethod` ever runs, and the resulting message names the annotation, not the offending method as AC-013 demands. AC-015 independently forbids relaxing the field's type.
- Why it matters: a criterion that cannot be exercised is a criterion that silently passes, and the implementer is told to add a generator branch that no reachable input can enter.

### F-004 — AC-022 has no step that produces its test

- Severity: IMPORTANT
- Location: `wiki/work/0018-author-argument-dx/01-plan.md:44` (step 10) and `:126` (verification approach), against `02-criteria.md:33`
- Criterion affected: AC-022
- Observation: AC-022 requires a test that constructs `WebMcpInvalidArgumentsException` with no arguments **in a const context** and asserts `details`, `key` and `reason` are all null. Step 10 enumerates the tests to add — typed properties for the three reasons, the serialized details map, the code and retryable entries, the absence of value, message and stack, and the nested key — and none of them is AC-022. The verification approach paragraph for the decode-detail criteria names the same set and also omits it. Step 8 at `01-plan.md:42` states the outcome ("the default construction still produces null details") but assigns no test and never mentions the const context, which is the part that protects the source compatibility argument made at `01-plan.md:26`.
- Why it matters: the whole justification for keeping the const no-argument constructor is const-context compatibility; if no step writes that test, the one criterion guarding the decision is unimplemented.

### F-005 — AC-030's disabled-child clause is in no step

- Severity: IMPORTANT
- Location: `wiki/work/0018-author-argument-dx/01-plan.md:47` (step 13) and `:128` (verification approach), against `02-criteria.md:41`
- Criterion affected: AC-030
- Observation: AC-030 requires three things for a field-list action: the child renders unchanged, "the tool shall remain invokable while the child is disabled or visually hidden", and unmount removes the registered name only when the state owns it. Step 13 lists the unchanged child and removal on unmount but not the disabled-child invocation, and the widget paragraph of the verification approach lists the same incomplete set. The existing suite covers the disabled child only for an action without a field list (`test/widget_layer_test.dart:125-140`), which is a different registration branch from the one step 12 adds.
- Why it matters: the new branch builds the registered tool through a different factory, so the existing disabled-child test does not transitively cover it; part of a criterion with no step behind it is a criterion the verifier cannot mark pass on evidence.

### F-006 — The plan calls the four slices independent while two of them own the same files, and states no ownership boundary

- Severity: IMPORTANT
- Location: `wiki/work/0018-author-argument-dx/01-plan.md:9`
- Criterion affected: none
- Observation: the approach opens with "four independent, purely additive slices that share one file set". Slice one and slice three both modify `lib/src/webmcp_typed_input.dart` (steps 1 and 9, `01-plan.md:34` and `:43`). Steps 3 and 10 both modify `test/registry_test.dart`, and both also modify `test/webmcp_public_surface_test.dart`. Slice four's AC-029 depends on slice one and two having landed. The plan says the slices are sequenced but never states which task group owns which file, and the only sequencing statement is the general one at `01-plan.md:9-10`.
- Why it matters: the task breakdown is produced from this plan. Two task groups marked parallel on the strength of the word "independent" would both edit `lib/src/webmcp_typed_input.dart` and both edit two shared test files.

### F-007 — The plan assigns a decode reason to a case no criterion pins

- Severity: IMPORTANT
- Location: `wiki/work/0018-author-argument-dx/01-plan.md:64` ("Reason assignment") against `02-criteria.md:29`
- Criterion affected: none (AC-018 is the nearest)
- Observation: the Reason assignment paragraph lists nine rejections mapped to reason `type`, the ninth being "a list or map field declared with no child". AC-018 enumerates exactly eight and omits that one. In the current decoder the childless case shares a throw site with the wrong-container-type case (`lib/src/webmcp_typed_input.dart:134` and `:142`), so step 9's instruction to touch "every throw site" covers it in practice, but nothing in the criteria holds it to reason `type`, and `02-criteria.md:57` separately declares the construction-time rejection out of scope without saying anything about the invocation-time reason.
- Why it matters: specified behaviour with no criterion is either scope that will be unverified or a criterion that should have existed; either way the verifier has nothing to check it against.

### F-008 — Step 14 and AC-033 enumerate the check script's stages inaccurately

- Severity: NIT
- Location: `wiki/work/0018-author-argument-dx/01-plan.md:48` and `02-criteria.md:49`
- Criterion affected: AC-033
- Observation: both describe the run as "the format stage over all five source roots ... all four packages, all five test suites, and the generator build". `tools/check.sh` formats nine directories, runs four test commands (`tools/check.sh:56-59`), and has eight numbered stages, including an `example` web build, a version-bump test and an `occupied pub.dev versions` test that the enumeration never mentions. The criterion's operative clause ("every stage shall report passed") is still checkable because the list is introduced by "including".
- Why it matters: only an accuracy point, but the enumeration is the thing an implementer will check their pasted output against.

### F-009 — The second risk row miscounts the existing invalid-arguments assertions

- Severity: NIT
- Location: `wiki/work/0018-author-argument-dx/01-plan.md:93`
- Criterion affected: none
- Observation: the mitigation says "the four existing tests that assert on an invalid-arguments code read that single entry rather than the whole envelope". There are seven such assertion sites: `example/test/example_counter_source_test.dart:83`, `:104`, `:125`, `example/test/example_task_service_test.dart:96`, `example/test/example_home_screen_test.dart:199`, `test/page/webmcp_app_session_test.dart:78`, and `packages/webmcp_flutter_generator/example/test/live_instance_test.dart:55`. The last one asserts whole-map equality on the error object, not a single entry. The conclusion survives, because that site is on the generated path this work item leaves alone and none of the seven exercises `webMcpDecodeArguments`, but the stated count and the blanket "read that single entry" are both wrong.
- Why it matters: the blast-radius argument is the mitigation; an implementer re-deriving it from the wrong set may miss that `live_instance_test.dart:54-57` would break if the generated path ever gained a details entry.

## Recurrence check

- Previous round: none — first round
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | plan |
| F-002 | plan |
| F-003 | plan |
| F-004 | plan |
| F-005 | plan |
| F-006 | plan |
| F-007 | plan |
| F-008 | plan |
| F-009 | plan |
