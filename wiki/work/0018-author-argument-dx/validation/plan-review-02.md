# Plan review — round 02

- Work item: 0018-author-argument-dx
- Reviewed artifact: `wiki/work/0018-author-argument-dx/01-plan.md` and `wiki/work/0018-author-argument-dx/02-criteria.md`, working tree at 2026-10-02 (`git status --porcelain` reports `?? wiki/work/0018-author-argument-dx/`, repository at `1a52d7c chore(release): v0.1.10`)
- Reviewer: plan-validator
- Date: 2026-10-02

## Verdict

**CONDITIONAL**

No blocker remains: every criterion is addressed by a step, every codebase claim I checked is true, and all nine round-01 findings are closed in the artifact text — but one shared decision rests on a reading of the decoder the source contradicts, one new public identifier is never named, and one criterion's assertions appear in no step.

## Verification performed

Artifact shape, and the absence of `03-tasks.md` (not treated as a finding per the task boundary):

````
$ grep -c '```' wiki/work/0018-author-argument-dx/01-plan.md
0
$ grep -nE "correctly|properly|as expected" wiki/work/0018-author-argument-dx/02-criteria.md
(no output)
$ ls wiki/work/0018-author-argument-dx/
00-research.md  01-plan.md  02-criteria.md  STATE.yaml  research  validation
$ ls wiki/work/0018-author-argument-dx/validation/
plan-review-01.md  research-review-01.md  research-review-02.md
````

The decoder, which steps 1, 9 and the schema decisions build on:

```
$ sed -n '68,92p' lib/src/webmcp_typed_input.dart
Map<String, Object?> webMcpDecodeArguments(
  List<WebMcpInputField> fields,
  Map<String, Object?> arguments,
) {
  final Map<String, WebMcpInputField> declared = <String, WebMcpInputField>{
    for (final WebMcpInputField field in fields) field.key: field,
  };
  for (final String key in arguments.keys) {
    if (!declared.containsKey(key)) {
      throw const WebMcpInvalidArgumentsException();
    }
  }
  final Map<String, Object?> decoded = <String, Object?>{};
  for (final WebMcpInputField field in fields) {
    if (!arguments.containsKey(field.key)) {
      if (field.isRequired) {
        throw const WebMcpInvalidArgumentsException();
      }
      continue;
    }
    decoded[field.key] = _decodeValue(field, arguments[field.key]);
  }
  return decoded;
}
```

(the decode loop iterates `fields`, not `declared.values` — see F-001. Every throw site named by step 9 exists: `:78`, `:84`, `:98`, `:103`, `:108`, `:115`, `:120`, `:124`, `:129`, `:135`, `:143`, `:149`, and `_decodeValue` at `:93` currently takes no key parameter)

Claims I checked and found **true**:

```
$ grep -n "webMcpSafeInteger" lib/src/webmcp_typed_input.dart
4:const int webMcpSafeIntegerMinimum = -9007199254740991;
7:const int webMcpSafeIntegerMaximum = 9007199254740991;
$ grep -n "enum WebMcpInputShape" -A 21 lib/src/webmcp_typed_input.dart | grep -E "^\s*[0-9]+[-:]\s+(string|boolean|safeInteger|finiteDouble|enumeration|list|map),"
12-  string,
15-  boolean,
18-  safeInteger,
21-  finiteDouble,
24-  enumeration,
27-  list,
30-  map,
```

(seven shapes; the per-shape list at `01-plan.md:56` covers all seven)

```
$ grep -n "anyOf\|'minimum'\|'maximum'\|'type': 'number'" packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart
556:        'minimum': -9007199254740991,
557:        'maximum': 9007199254740991,
559:      _ShapeKind.doubleValue => <String, Object?>{'type': 'number'},
577:      'anyOf': <Object?>[
$ grep -n "_readMethod\|_ExposedMethod(\|void _emitClass\|Map<String, Object?> _schemaFor\|get schema" packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart
33:        final _ExposedMethod exposedMethod = _readMethod(type, method, reader);
104:  _ExposedMethod _readMethod(
158:    return _ExposedMethod(
254:  void _emitClass(StringBuffer output, _ExposedClass type) {
455:  Map<String, Object?> _schemaFor(_ExposedMethod method) {
550:  Map<String, Object?> get schema {
```

(the escalation note at `01-plan.md:84` is accurate line for line: `anyOf` at 577, the integer bounds and the `number` type at 554–559. `_schemaFor` at 455 builds exactly the wrapper `01-plan.md:56` describes, including `if (required.isNotEmpty) 'required': required`, and `_emitClass` at 294–302 emits `inputSchema:` and a `const _webmcp.WebMcpToolAnnotations(` literal, so the emission instructions in step 5 land on real members)

```
$ cat packages/webmcp_flutter_annotations/lib/webmcp_flutter_annotations.dart | grep -n "this\.\|final "
    required this.description,
    this.name,
    this.readOnlyHint = false,
    this.untrustedContentHint = false,
    this.consequentialHint = false,
  final String description; / final String? name; / final bool readOnlyHint;
  final bool untrustedContentHint; / final bool consequentialHint;
```

(five existing fields, const constructor — step 4's precondition holds)

```
$ sed -n '255,276p' ~/.pub-cache/hosted/pub.dev/source_gen-4.2.4/lib/src/constants/reader.dart
  ConstantReader? peek(String field) {
    final constant = ConstantReader(getFieldRecursive(objectValue, field));
    return constant.isNull ? null : constant;
  }
  ConstantReader read(String field) {
    final reader = peek(field);
    if (reader == null) {
      assertHasField(objectValue.type!.element as InterfaceElement, field);
...
$ grep -n "List<DartObject> get listValue\|String get stringValue\|bool get boolValue" ~/.pub-cache/hosted/pub.dev/source_gen-4.2.4/lib/src/constants/reader.dart
209:  bool get boolValue => _check(objectValue.toBoolValue(), 'bool');
227:  List<DartObject> get listValue => _check(objectValue.toListValue(), 'List');
246:  String get stringValue => _check(objectValue.toStringValue(), 'String');
$ grep -n "source_gen" packages/webmcp_flutter_generator/pubspec.yaml
13:  source_gen: 4.2.4
```

(`01-plan.md:72` is accurate: `read` reaches `assertHasField` for an absent field, `peek` returns null for absent and null alike, and the three accessors exist on the pinned version)

```
$ sed -n '85,95p' lib/src/webmcp_tool.dart
  }) : inputSchema = UnmodifiableMapView<String, Object?>(
         Map<String, Object?>.of(inputSchema),
       ),
$ sed -n '105,114p' lib/src/webmcp_tool.dart
  factory WebMcpTool.withDecodedArguments({
    ...
    Map<String, Object?> inputSchema = const <String, Object?>{},
$ sed -n '69,74p' lib/src/webmcp_exceptions.dart
final class WebMcpInvalidArgumentsException extends WebMcpToolException {
  /// Creates an invalid-arguments failure with no details.
  const WebMcpInvalidArgumentsException()
    : super(code: 'invalidArguments', retryable: false);
```

(the shallow copy at `01-plan.md:60`, the empty default at `:52`, and the const no-argument constructor at `:70` all hold. `lib/src/widgets/webmcp_action.dart:32-36` holds the exactly-one-callback check step 11 must sequence after, and `:88-105` is the once-guarded block reading name, description, input schema, annotations, title and origin list that step 12 branches)

Blast-radius claims in the risk table:

```
$ grep -rn "invalidArguments" --glob '!lib/src/**' --glob '*.dart' .
example/test/example_task_service_test.dart:96        example/test/example_counter_source_test.dart:83,:104,:125
example/test/example_home_screen_test.dart:199        test/page/webmcp_app_session_test.dart:78
packages/webmcp_flutter_generator/example/test/live_instance_test.dart:55
$ sed -n '49,59p' packages/webmcp_flutter_generator/example/test/live_instance_test.dart
    expect((result! as Map<String, Object?>)['error'], <String, Object?>{
      'code': 'invalidArguments',
      'retryable': false,
    });
    expect(service.calls, 0);
$ grep -rn "WebMcpToolException\|details" lib/src/page/*.dart
lib/src/page/webmcp_page_protocol.dart:123:      'The operation failed without exposing internal details.',
```

(no existing assertion sits on the manual decoder path, so "the blast radius is one test file" at `01-plan.md:90` holds; the whole-map assertion at `live_instance_test.dart:54-57` is on the generated path as `:91` says; the page path never forwards a details map, so "the publisher is not touched" at `:17` holds. AC-023 and AC-024 are already satisfied by `live_instance_test.dart:54-58`)

AC-031's first clause is already covered by an existing test, so its absence from step 3 is not a gap:

```
$ sed -n '137,155p' test/registry_test.dart
      inputSchema: schema,      # schema carries required: ['value', 'later']
      ...
      expect(await WebMcp.instance.invokeTool('schema.behavior', const {}), 'invoked');
```

Harness and check-script facts behind steps 6, 7 and 14:

```
$ sed -n '6,22p' packages/webmcp_flutter_generator/test/generator_test.dart
const String _annotationSource = r'''
class WebMcpDomainAction { const WebMcpDomainAction({ required this.description, this.name,
  this.readOnlyHint = false, this.untrustedContentHint = false, this.consequentialHint = false, });
  ... }
''';
$ grep -n "onLog" packages/webmcp_flutter_generator/test/generator_test.dart
102:      onLog: (log) => logs.add(log.message),
128:      onLog: (log) => logs.add(log.message),
$ sed -n '63,74p' tools/check.sh
(cd example && flutter build web) || stage_failed 6 "build"
test -f example/build/web/index.html || stage_failed 6 "build"
(cd packages/webmcp_flutter_generator/example &&
  dart run build_runner build) ||
  stage_failed 6 "generator build"
echo "Stage 6 passed: build"
sh tools/test_bump_patch_version.sh || stage_failed 7 "version bump test"
sh tools/test_occupied_pubdev_versions.sh || stage_failed 8 "occupied pub.dev versions test"
```

(the inline annotation source still duplicates the five fields, both negative tests still read `onLog`, and `build_runner` still runs only in the generator example — the three facts steps 6, 7 and 40–41 now state correctly)

## Per-criterion results

Not applicable — this is a plan review, not an implementation review. Coverage defects are reported as findings below. Walking AC-001 to AC-034, each is addressed by at least one step: AC-001 to AC-009 by steps 1–3 and the decisions at `01-plan.md:52-60`; AC-010 to AC-015 by steps 4–7; AC-016 to AC-022 by steps 8–10; AC-023 and AC-024 by the existing fixture test the verification approach names at `:124`; AC-025 to AC-030 by steps 11–13; AC-031 by step 2's completion condition plus the existing test at `test/registry_test.dart:137-155`; AC-032 by steps 3 and 10; AC-033 by step 14; AC-034 by step 10. The one incomplete case is AC-007, reported as F-003.

## Findings

### F-001 — The duplicate-key tie-break is justified by a reading of the decoder the source contradicts

- Severity: IMPORTANT
- Location: `wiki/work/0018-author-argument-dx/01-plan.md:58`, against `lib/src/webmcp_typed_input.dart:72-89`
- Criterion affected: none (no criterion covers a duplicate declared key)
- Observation: the decision reads "When two fields declare the same key, the later declaration wins in the properties map, matching the existing last-wins behaviour of the decoder's internal lookup map." The lookup map at `lib/src/webmcp_typed_input.dart:72-74` is indeed last-wins, but it governs only the unknown-key check at `:75-79`. The value-decoding loop at `:81-89` iterates the `fields` list itself, so for a duplicated key every duplicate's required check and shape check runs against the same argument value, and the last write wins only for the entry placed in the decoded map. A field list declaring `x` first as a required string and then as an optional integer is therefore enforced as the conjunction of both fields, while a last-wins properties map would publish only the integer. The decoder's behaviour is not "last wins"; it is "all of them run".
- Why it matters: the goal at `01-plan.md:5` is that "the schema an agent reads and the check the decoder runs can no longer disagree by accident". This is a case where they disagree, and the plan closes it by appealing to an equivalence the source does not support, with no criterion to catch the divergence.

### F-002 — The new public named constructor is never named

- Severity: IMPORTANT
- Location: `wiki/work/0018-author-argument-dx/01-plan.md:17`, `:42`, `:68`, `:70` and `:100`, against `wiki/work/0018-author-argument-dx/02-criteria.md:48`
- Criterion affected: AC-032
- Observation: the plan decides every other new identifier explicitly — the function `webMcpSchemaFromFields` at `:54`, the enum `WebMcpDecodeFailureReason` and its three value names at `:62`, the widget parameter `fields` at `:78`, the details entry names at `:68` — but the constructor is only ever "a second, named, non-const constructor" (`:17`), "the named non-const constructor" (`:42`, step 8) and "the new named constructor" (`:70`). The rollback paragraph at `:100` counts it as one of exactly three additions to the exported public surface, while AC-032 at `02-criteria.md:48` enumerates only "the decode-failure reason enum and the schema-derivation function" for the public-surface test. The implementer therefore chooses a permanent name on the package's exported API that no step, no shared decision and no criterion fixes, and the test that enumerates exported names will not list it.
- Why it matters: naming on an exported surface is precisely the class of shared choice the "Interfaces and shared decisions" section exists to close, and a name chosen in the implement phase cannot be renegotiated after release without a breaking change.

### F-003 — AC-007's assertions appear in no step and in no verification paragraph

- Severity: IMPORTANT
- Location: `wiki/work/0018-author-argument-dx/01-plan.md:37` (step 3) and `:120`, against `wiki/work/0018-author-argument-dx/02-criteria.md:18`
- Criterion affected: AC-007
- Observation: AC-007 requires a test that builds a tool with a childless list field, asserts the derived property schema carries only the base array or object type with no `items` and no `additionalProperties`, and asserts the construction succeeded. Step 3 enumerates the registry assertions as "every shape in `WebMcpInputShape`, the required list, the nullable wrapper, nested list and map children, the empty-schema trigger, the non-empty author override, and the absence of shared nested state", and the verification paragraph at `:120` names the same set; neither mentions a childless field. The only childless mention in the plan's test instructions is step 10 at `:44`, "a childless list or map field whose invocation-time rejection uses reason type", which is AC-018 on the decode path at `lib/src/webmcp_typed_input.dart:134` and `:142`, not the derivation path. The behaviour itself is decided at `:58`, so what is missing is the assertion, not the decision.
- Why it matters: AC-007 is the criterion that stops the derivation from inventing an `items` entry it cannot fill and stops the change from turning a previously constructible field list into a construction error; with no step producing its test, the verifier has no evidence to mark it against.

### F-004 — The details map's entry names are decided only in plan prose, and no criterion pins them

- Severity: NIT
- Location: `wiki/work/0018-author-argument-dx/01-plan.md:68`, against `wiki/work/0018-author-argument-dx/02-criteria.md:31` and `:50`
- Criterion affected: AC-020, AC-034
- Observation: the plan fixes the two entries as the key "under the name field" and the reason "under the name reason", while the exception's typed properties are `key` and `reason` (`02-criteria.md:27`). AC-020 requires "a map with exactly two string entries: the failed key and the reason name" without naming either entry, and AC-034 only requires two string-valued entries. An implementation that names the first entry `key` rather than `field` satisfies both criteria and contradicts the plan. This is the agent-visible wire name that `02-criteria.md:62` defers to the document phase to document.
- Why it matters: the entry name is the part of this change an external agent actually reads, and it is the one new string that no criterion holds the implementation to.

### F-005 — Step 7's "committed" completion condition is checked by nothing

- Severity: NIT
- Location: `wiki/work/0018-author-argument-dx/01-plan.md:41`, against `tools/check.sh:63-68` and `wiki/work/0018-author-argument-dx/02-criteria.md:26`, `:49`
- Criterion affected: AC-015, AC-033
- Observation: step 7 completes "when the regenerated generator-example file is committed and the fixture test passes". The generator build stage runs `dart run build_runner build` in that example but never inspects the working tree afterwards, and neither AC-015 (analysis passes, fixture compiles) nor AC-033 (every stage reports passed) looks at git state. A missing regeneration is caught, because the new `live_instance_test.dart` assertion step 7 adds would fail against a stale generated file; a regeneration that happens locally and is never committed is not caught by any stage.
- Why it matters: minor, and the failure mode is git hygiene rather than behaviour, but it is the one completion condition in the plan that no command can confirm.

## Recurrence check

- Previous round: `wiki/work/0018-author-argument-dx/validation/plan-review-01.md`
- Recurring findings: none. All nine round-01 findings are closed in the artifact text, re-checked against the artifacts rather than against a claim: F-001 — AC-013 at `02-criteria.md:24` now collects the builder log and states "It does not assert that the test function observes a thrown error", matched by step 6 at `01-plan.md:40` and the decision at `:76`. F-002 — AC-014 at `02-criteria.md:25` is now a builder-test criterion on absent member names, and step 7 at `01-plan.md:41` plus `:122` explicitly refuse the application example's generated file as evidence. F-003 — the non-string origin-list element is gone from AC-013; `01-plan.md:39` and `:76` now state it is not a generator check. F-004 — step 10 at `01-plan.md:44` now includes "a const no-argument construction whose details, key and reason are all null". F-005 — step 13 at `01-plan.md:47` and the paragraph at `:126` now include "an invocation that still reaches the callback while the child is disabled". F-006 — `01-plan.md:9` now reads "sequenced because they are not safe to implement in parallel" and assigns each file group to one slice, with "no task marked parallel". F-007 — AC-018 at `02-criteria.md:29` now ends "or is a list or map field declared with no child", and step 10 adds its test. F-008 — step 14 at `01-plan.md:48` and AC-033 at `02-criteria.md:49` no longer enumerate stages and defer to "every stage the script itself defines". F-009 — the second risk row at `01-plan.md:91` no longer states a count of existing assertion sites.
- Oscillating: no. The three findings above are first occurrences at locations round 01 did not report, and none is materially identical to a round-01 finding; no escalation is warranted on recurrence grounds.

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | plan |
| F-002 | plan |
| F-003 | plan |
| F-004 | plan |
| F-005 | plan |
