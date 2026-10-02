# Research review — round 02

- Work item: 0018-author-argument-dx
- Reviewed artifact: `wiki/work/0018-author-argument-dx/00-research.md` (working tree, untracked; repository sources read at the same working-tree state)
- Reviewer: research-validator
- Date: 2026-10-02

## Verdict

**CONDITIONAL**

No blockers remain. All three round-01 blockers and all four round-01 IMPORTANT findings are closed and were re-checked against source rather than accepted as claimed. Two new IMPORTANT findings stand: a claim about the pinned `source_gen` `ConstantReader` API that carries no source and whose mechanism the library contradicts, and a provenance table that points at an unresolved item the list does not contain.

## Verification performed

Every repository path the artifact cites was opened and read directly, plus the pinned `source_gen` package the artifact makes a behavioural claim about: `lib/src/webmcp_tool.dart`, `lib/src/webmcp_typed_input.dart`, `lib/src/webmcp_exceptions.dart`, `lib/src/transport/webmcp_native_publisher.dart`, `lib/src/widgets/webmcp_action.dart`, `lib/src/widgets/webmcp_screen.dart`, `packages/webmcp_flutter_annotations/lib/webmcp_flutter_annotations.dart`, `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart`, `packages/webmcp_flutter_generator/pubspec.yaml`, `example/lib/example_counter_source.dart`, `example/lib/example_task_service.webmcp.g.dart`, `packages/webmcp_flutter_generator/example/lib/inventory_service.webmcp.g.dart`, `wiki/product/webmcp-contract.md`, `README.md`, `test/registry_test.dart`, `test/webmcp_public_surface_test.dart`, `test/widget_layer_test.dart`, `example/test/example_task_service_test.dart`, `packages/webmcp_flutter_generator/example/test/live_instance_test.dart`, `~/.pub-cache/hosted/pub.dev/source_gen-4.2.4/lib/src/constants/reader.dart`, `~/.pub-cache/hosted/pub.dev/source_gen-4.2.4/lib/src/constants/utils.dart`.

This review is against the artifact and the repository sources only. `01-plan.md`, `02-criteria.md` and `STATE.yaml` were not read.

### Round-01 blocker re-checks

Command:

```
grep -rn "oneOf" wiki/work/0018-author-argument-dx/00-research.md
```

Output:

```
wiki/work/0018-author-argument-dx/00-research.md:317:6. **`nullable` fields need a schema representation.** The generator wraps a nullable schema in `anyOf` with a null type at `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart` line 577. It does not emit `oneOf`.
```

The only surviving occurrence states that the generator does **not** emit `oneOf`, which matches the source. Round-01 F-001 is closed.

Command:

```
awk 'NR>=550 && NR<=582 {print NR": "$0}' packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart
```

Output (excerpt):

```
554:      _ShapeKind.integer => <String, Object?>{
555:        'type': 'integer',
556:        'minimum': -9007199254740991,
557:        'maximum': 9007199254740991,
558:      },
559:      _ShapeKind.doubleValue => <String, Object?>{'type': 'number'},
...
576:    return <String, Object?>{
577:      'anyOf': <Object?>[
578:        nonNull,
579:        const <String, Object?>{'type': 'null'},
580:      ],
581:    };
```

Artifact constraint 3 (line 311) and F1.6 (line 54) now assert that the generator emits the inclusive integer bounds and `type: number`, which the source confirms, and the committed fixture repeats them at `packages/webmcp_flutter_generator/example/lib/inventory_service.webmcp.g.dart:94-98`. Round-01 F-002 is closed.

Unresolved item 2 (line 348) now carries the generated-path field-naming question, and a fourth options row (line 292) names "Name the field on the generated return map". Round-01 F-003 and F-004 are closed.

Command:

```
awk 'NR>=47 && NR<=74 {print NR": "$0}' lib/src/webmcp_exceptions.dart
```

Output (excerpt):

```
48: class WebMcpToolException implements Exception {
50:   const WebMcpToolException({
51:     required this.code,
52:     required this.retryable,
53:     this.details,
54:   });
70: final class WebMcpInvalidArgumentsException extends WebMcpToolException {
72:   const WebMcpInvalidArgumentsException()
73:     : super(code: 'invalidArguments', retryable: false);
```

Artifact constraint 14 (line 332) now states that the const constructor can stay and only the individual throw site loses constness, which matches. The options row at line 291 no longer claims `_decodeValue` needs the field passed in. Round-01 F-005 and F-008 are closed.

Constraint 1 (line 306) and F1.7 (line 62) now cite `wiki/product/webmcp-contract.md` lines 37–38 only; the stray 155–158 range is gone. Contract lines 37–38 read "The schema is descriptive; the registry performs / no runtime JSON Schema validation." Round-01 F-006 is closed.

F1.6 (line 54) now scopes itself to the shapes the generator builds and explicitly declines to specify fragments for a childless list/map and an empty-`allowedNames` enumeration; unresolved item 1 (line 347) carries that question. Round-01 F-007 is closed.

### New-claim checks

Command:

```
grep -n "source_gen" packages/webmcp_flutter_generator/pubspec.yaml
awk 'NR>=260 && NR<=276 {print NR": "$0}' ~/.pub-cache/hosted/pub.dev/source_gen-4.2.4/lib/src/constants/reader.dart
grep -n -A9 "void assertHasField" ~/.pub-cache/hosted/pub.dev/source_gen-4.2.4/lib/src/constants/utils.dart
```

Output:

```
13:  source_gen: 4.2.4

262:  ConstantReader? peek(String field) {
263:    final constant = ConstantReader(getFieldRecursive(objectValue, field));
264:    return constant.isNull ? null : constant;
265:  }
266:
267:  @override
268:  ConstantReader read(String field) {
269:    final reader = peek(field);
270:    if (reader == null) {
271:      assertHasField(objectValue.type!.element as InterfaceElement, field);
272:      return const _NullConstant();
273:    }
274:    return reader;
275:  }

11:void assertHasField(InterfaceElement root, String name) {
12:  InterfaceElement? element = root;
13:  while (element != null) {
14:    final field = element.getField(name);
15:    if (field != null) {
16:      return;
17:    }
18:    element = element.supertype?.element;
19:  }
```

Command:

```
awk '/^## Unresolved/,/^## Sources/' wiki/work/0018-author-argument-dx/00-research.md | grep -c "UNRESOLVED"
```

Output:

```
8
```

Claims confirmed as stated (opened and read, no finding): F1.1, F1.2, F1.3, F1.5, F1.6, F1.7, F2.1, F2.2, F2.3, F2.4, F2.5, F2.6, F2.8, F3.1, F3.2, F3.4, F3.6, F3.7, F3.8, F3.9, F3.10, F3.11, F3.12, F3.13, F3.14, F4.2, F4.3, F4.4, F4.5, F4.6, F4.7, F4.8, and constraints 1–8, 10–18. Specifically re-verified beyond the artifact's citation: `WebMcpTool.withDecodedArguments` is the only non-test use of that factory in the repository (`rg -n "withDecodedArguments" --glob '*.dart'` returns `lib/src/webmcp_tool.dart:105` and `test/registry_test.dart:294` only), supporting F1.5; `_normalizeJson` accepts `String` unconditionally at `lib/src/transport/webmcp_native_publisher.dart:455`, supporting F3.9; `WebMcpToolAnnotations.debugging` exists as a nullable `bool` at `lib/src/webmcp_tool.dart:54,69`, supporting F2.1 and F2.8.

## Per-criterion results

Not applicable. This is a research review, not an implementation review; `02-criteria.md` is not the subject of this round.

## Findings

### F-001 — The `source_gen` `read`/`peek` claim carries no source and the library contradicts the stated mechanism

- Severity: IMPORTANT
- Location: `wiki/work/0018-author-argument-dx/00-research.md:106`, `:323`, `:358-379`
- Criterion affected: none
- Observation: F2.7 at line 106 states "For optional annotation fields, `annotation.peek(…)` must be used (not `annotation.read(…)`); `read` throws when the field is absent", and constraint 9 at line 323 repeats "`peek` returns null when the field is absent or set to null; `read` throws." The evidence line 107 cites only the annotation class and the generator's existing `peek` call at line 126 — neither is evidence for `read`'s failure behaviour — and `source_gen` appears nowhere in the Sources table at lines 358–379. The generator pins `source_gen: 4.2.4` (`packages/webmcp_flutter_generator/pubspec.yaml:13`). In that version, `ConstantReader.read` (`lib/src/constants/reader.dart:268-275`) calls `peek`, and when `peek` returns null it calls `assertHasField` and then returns `const _NullConstant()`. `assertHasField` (`lib/src/constants/utils.dart:11-19`) returns normally whenever the class declares the field, which a new optional annotation field with a `null` default always does. So for the exact case the constraint governs — an author omitting an optional annotation argument — `read` does not throw; it returns a null constant. The throw occurs one step later, at the typed accessor on `_NullConstant` (`reader.dart:126-156`).
- Why it matters: the constraint is a hard instruction to the implementation phase, and its stated justification is not the behaviour of the pinned dependency. The `peek` conclusion survives because `read(field).stringValue` does ultimately throw, but the artifact asserts a mechanism it never verified and never marked `[UNVERIFIED]`, while unresolved item 3 at line 349 simultaneously records that the `ConstantReader` list-reading API still "must be verified" — the same API, treated as settled in one place and open in another.

### F-002 — The provenance table maps unresolved items that do not exist and misattributes the ones that do

- Severity: IMPORTANT
- Location: `wiki/work/0018-author-argument-dx/00-research.md:389-393`, against the unresolved list at `:347-354`
- Criterion affected: none
- Observation: The unresolved list contains exactly eight items (lines 347–354; counted by `grep -c "UNRESOLVED"` over the section, result 8). The provenance table claims `schema-from-fields.md` contributed "Unresolved items 1–3" (line 389), `generator-publication-metadata.md` "item 4" (line 390), `generator-argument-errors.md` "item 5" (line 391), `invalid-argument-details.md` "items 6–7" (line 392), and `action-decoded-fields.md` "items 8–9" (line 393). Item 9 does not exist. The mapping is also wrong for the items that do: item 2 (line 348) is the generated-path field-naming question, attributed to the schema stream; item 3 (line 349) is the annotation `List<String>?` question, also attributed to the schema stream rather than the metadata stream; item 4 (line 350) is the operation-tracker question, which the table assigns to the metadata stream.
- Why it matters: the provenance table is the only record of which research stream a given open question came from, and the unresolved list is the handover surface the plan reads. A dangling reference to a ninth item leaves a reader unable to tell whether a question was renumbered during the patch or dropped from the merge, which is precisely the ambiguity provenance exists to remove.

### F-003 — Line citations remain systematically off by one or two, unchanged from round 01

- Severity: NIT
- Location: `wiki/work/0018-author-argument-dx/00-research.md:71`, `:72`, `:78`, `:107`, `:108`, `:124`, `:150`, `:167`, `:180`, `:231`, `:232`, `:250`, `:256`, `:319`, `:327`, `:329`
- Criterion affected: none
- Observation: Examples re-checked this round: F2.1 at line 71 cites the `WebMcpTool` constructor at "77–98", actual 77–99, and `WebMcpToolAnnotations` at "48–69", actual 48–70; lines 71 and 72 cite `packages/webmcp_flutter_annotations/lib/webmcp_flutter_annotations.dart` "lines 1–33" for a file that is 32 lines long (`wc -l` = 32); F2.7 at lines 107–108 and constraint 7 at line 319 cite the annotation class at "10–17", actual 10–16; F2.2 at line 78 cites "293–308", actual 292–307; F3.1 at line 124 and F3.5 at line 150 cite `webmcp_exceptions.dart` "69–73" while F3.8 cites "70–73", actual 70–74; F3.10 at line 180 cites log sites "374, 382", actual 374 and 381; F4.4 at lines 231–232 and F4.8 at line 256 cite the `WebMcpAction` constructor at "16–36", actual 15–37; F4.7 at line 250 cites dispose at "111–117", actual 112–118; constraint 11 at line 327 cites the code regex at "line 414", actual 415; constraint 12 at line 329 cites the byte limit at "line 14", actual 15.
- Why it matters: each citation still lands inside or adjacent to the construct it names, so no claim is unverifiable. This is materially the same finding as round-01 F-009 and is recorded again only for the recurrence check.

### F-004 — F4.1 still describes the registration guard as the first line of `didChangeDependencies`

- Severity: NIT
- Location: `wiki/work/0018-author-argument-dx/00-research.md:213`
- Criterion affected: none
- Observation: The evidence states "Lines 76–107 — `if (_registered) return;` is the first line". In `lib/src/widgets/webmcp_action.dart:77-82`, `super.didChangeDependencies()` is the first statement at line 78, the guard is a block-bodied `if (_registered) { return; }` at lines 79–81, and `_registered = true` is line 82. The substantive claim — the boolean prevents re-registration — holds.
- Why it matters: cosmetic only. Materially identical to round-01 F-010.

### F-005 — Area 1 options still omit a merge of derived and author-supplied schema

- Severity: NIT
- Location: `wiki/work/0018-author-argument-dx/00-research.md:265-268`
- Criterion affected: none
- Observation: The options remain A (author writes both), B (derive only when `inputSchema` is empty) and C (always replace). Option C is rejected at line 268 because it "eliminates author ability to provide per-property descriptions, examples, or richer constraints". An option that merges derived type information with author-supplied per-property prose — the option that directly answers that rejection reason — is still unnamed.
- Why it matters: the chosen Option B is defensible without it, since an author who supplies any schema retains full control. Materially identical to round-01 F-011.

### F-006 — F3.3's cited ranges still miss one `_$webMcpInvalid()` emission site

- Severity: NIT
- Location: `wiki/work/0018-author-argument-dx/00-research.md:138`
- Criterion affected: none
- Observation: F3.3 cites generator lines 80–93 and 397–449. `_emitInvoker` also emits `_$webMcpInvalid()` at `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart:350`, the fallback for an optional non-nullable parameter with no default value. That site is outside both cited ranges.
- Why it matters: the claim that every invalid-argument condition funnels through the same helper remains true, and the missed site reinforces it. Materially identical to round-01 F-012.

### F-007 — F1.4 locates `_emitDecoder` at its call site rather than its definition

- Severity: NIT
- Location: `wiki/work/0018-author-argument-dx/00-research.md:43`
- Criterion affected: none
- Observation: The evidence states "`_emitDecoder` at lines 258–271 emits the runtime shape check from the same shapes". Lines 256–273 of `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart` are the loop inside `_emitClass` that *calls* `_emitDecoder`; the function itself is defined at lines 387–453 and is not cited anywhere in the finding's source line. The underlying claim holds: the call site at line 269 passes `method.parameters[parameterIndex].shape`, the same `_TypeShape` whose `schema` getter `_schemaFor` reads at line 459.
- Why it matters: a reader following the citation to confirm "the decoder uses the same shapes" lands on a dispatch loop rather than the emission logic. Not previously reported; the surrounding text was rewritten this round.

### F-008 — F3.5 attributes operation settlement to `_toolExceptionFailure`

- Severity: NIT
- Location: `wiki/work/0018-author-argument-dx/00-research.md:148`
- Criterion affected: none
- Observation: The claim reads "the publisher catches it at the `on WebMcpToolException` branch and calls `_toolExceptionFailure`, which settles the operation as `handlerFailed` and logs `WebMcpLogKind.invocationFailed`". In `lib/src/transport/webmcp_native_publisher.dart:369-375`, the catch block itself calls `_operations.settle(operation, reason: handlerFailed)` at lines 370–373 and `webMcpRecordLog(WebMcpLogKind.invocationFailed, tool.name)` at line 374, then calls `_toolExceptionFailure` at line 375. `_toolExceptionFailure` (lines 414–436) only builds and encodes the response body; it neither settles nor logs.
- Why it matters: the settlement and log-kind contrast the finding draws is correct; only the attribution of which function performs it is wrong. Not previously reported.

### F-009 — Neither F1.6 nor Option B states the object envelope a derived schema must produce

- Severity: NIT
- Location: `wiki/work/0018-author-argument-dx/00-research.md:54`, `:267`
- Criterion affected: none
- Observation: F1.6 at line 54 enumerates per-property fragments only. Option B at line 267 says the derivation uses "the same shape-to-schema mapping the generator uses". The generator's schema is not only the per-property mapping: `_schemaFor` (`packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart:455-470`) also wraps properties in `{'type': 'object', 'additionalProperties': false, 'properties': …}` and emits a `required` array built from `parameter.isRequired`. For a manual derivation the analogous input is `WebMcpInputField.isRequired` (`lib/src/webmcp_typed_input.dart:52`). No finding, constraint or unresolved item names the envelope or the `isRequired`-to-`required` mapping.
- Why it matters: the envelope is the part of the schema that tells an agent which keys are mandatory and that unknown keys are rejected — the behaviour `webMcpDecodeArguments` actually enforces at `lib/src/webmcp_typed_input.dart:75-87`. The omission is small because F1.4's cited range already contains `_schemaFor`, but Area 1 exists to make schema and decoder agree, and the required-key half of that agreement is unstated.

## Recurrence check

- Previous round: `wiki/work/0018-author-argument-dx/validation/research-review-01.md`
- Recurring findings: F-003 (= round-01 F-009), F-004 (= round-01 F-010), F-005 (= round-01 F-011), F-006 (= round-01 F-012). All four are materially identical to round 01 and the cited text is unchanged.
- Oscillating: yes, at NIT severity only

Qualification for the main agent: the recurrence is not a fix-then-regress cycle. Every round-01 BLOCKER (F-001, F-002, F-003) and every round-01 IMPORTANT (F-004, F-005, F-006, F-007) is closed, re-checked against source this round rather than accepted as claimed, and none recurs. The four recurring items are the round-01 NITs, carried forward untouched. Under the recurrence rule a materially identical repeat warrants escalation rather than a third round; the two IMPORTANT findings in this report (F-001, F-002) are new and have not been through a round.

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
| F-009 | research |
