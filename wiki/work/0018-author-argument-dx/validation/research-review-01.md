# Research review — round 01

- Work item: 0018-author-argument-dx
- Reviewed artifact: `wiki/work/0018-author-argument-dx/00-research.md` (working tree, untracked; repository sources read at the same working-tree state)
- Reviewer: research-validator
- Date: 2026-10-02

## Verdict

**FAIL**

Three findings are blockers: two factual claims about the generator's schema derivation are contradicted by the generator source and by its own committed fixture output, and a question the artifact's own answer declares "not closed by this research" is absent from the unresolved list, so a plan reading the unresolved list alone would not know it is open.

## Verification performed

Every repository path the artifact cites was opened and read directly: `lib/src/webmcp_tool.dart`, `lib/src/webmcp_typed_input.dart`, `lib/src/webmcp_exceptions.dart`, `lib/src/transport/webmcp_native_publisher.dart`, `lib/src/transport/native_publisher_boundary.dart`, `lib/src/webmcp_scope.dart`, `lib/src/widgets/webmcp_action.dart`, `lib/src/widgets/webmcp_screen.dart`, `packages/webmcp_flutter_annotations/lib/webmcp_flutter_annotations.dart`, `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart`, `example/lib/example_counter_source.dart`, `example/lib/example_task_service.webmcp.g.dart`, `packages/webmcp_flutter_generator/example/lib/inventory_service.webmcp.g.dart`, `wiki/product/webmcp-contract.md`, `README.md`, `test/registry_test.dart`, `test/webmcp_public_surface_test.dart`, `test/widget_layer_test.dart`, `example/test/example_task_service_test.dart`, `packages/webmcp_flutter_generator/example/test/live_instance_test.dart`.

This review is against the artifact and the repository sources only. `01-plan.md` and `STATE.yaml` appear in the raw command output below because a repository-wide search matched them; their content was disregarded for the review.

Command:

```
rg -n "oneOf" .
```

Output (truncated to the repository-source question; the remaining matches are this work item's own files):

```
./wiki/work/0018-author-argument-dx/00-research.md:60:... `nullable` fields require a schema representation consistent with the generator's `oneOf` pattern.
./wiki/work/0018-author-argument-dx/00-research.md:316:6. **`nullable` fields need a schema representation.** The generator handles nullable via a `oneOf` or additional `null` type entry (lines 573–577). ...
./wiki/work/0018-author-argument-dx/00-research.md:348:- [UNRESOLVED: What convention should nullable fields use in the derived schema? The generator uses a `oneOf` with null at lines 573–577. ...]
./wiki/work/0018-author-argument-dx/01-plan.md:84:...
./wiki/work/0018-author-argument-dx/STATE.yaml:26:...
./wiki/work/0018-author-argument-dx/STATE.yaml:32:...
./wiki/work/0018-author-argument-dx/research/schema-from-fields.md:150:   via a `oneOf` or an additional `null` type entry (lines 573–577). Manual field
./wiki/work/0018-author-argument-dx/research/schema-from-fields.md:163:  The generator uses a `oneOf` with null at lines 573–577 of the generator. Manual
```

Command:

```
rg -n "anyOf" .
```

Output (repository sources only; the remaining matches are this work item's own files):

```
./packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart:577:      'anyOf': <Object?>[
```

Command:

```
sed -n '550,582p' packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart
```

Output:

```
  Map<String, Object?> get schema {
    final Map<String, Object?> nonNull = switch (kind) {
      _ShapeKind.string => <String, Object?>{'type': 'string'},
      _ShapeKind.boolean => <String, Object?>{'type': 'boolean'},
      _ShapeKind.integer => <String, Object?>{
        'type': 'integer',
        'minimum': -9007199254740991,
        'maximum': 9007199254740991,
      },
      _ShapeKind.doubleValue => <String, Object?>{'type': 'number'},
      _ShapeKind.enumeration => <String, Object?>{
        'type': 'string',
        'enum': enumValues,
      },
      _ShapeKind.list => <String, Object?>{
        'type': 'array',
        'items': child!.schema,
      },
      _ShapeKind.map => <String, Object?>{
        'type': 'object',
        'additionalProperties': child!.schema,
      },
    };
    if (!nullable) {
      return nonNull;
    }
    return <String, Object?>{
      'anyOf': <Object?>[
        nonNull,
        const <String, Object?>{'type': 'null'},
      ],
    };
  }
```

Command:

```
sed -n '93,102p' packages/webmcp_flutter_generator/example/lib/inventory_service.webmcp.g.dart
```

Output:

```
          "sku": <String, Object?>{"type": "string"},
          "amount": <String, Object?>{
            "type": "integer",
            "minimum": -9007199254740991,
            "maximum": 9007199254740991,
          },
          "mode": <String, Object?>{
            "type": "string",
            "enum": <Object?>["preview", "commit"],
          },
```

Command:

```
sed -n '152,160p' wiki/product/webmcp-contract.md
```

Output:

```
## Deliberate omissions

Multiple-Flutter-view operation, positive observation waits, generated route
wrapping, generalized service proxies, framework-specific state adapters,
custom data providers, Chrome web platform-back-gesture support, in-flight
callback termination, deep schema immutability, transactional source
registration, notification rollback, and automatic cleanup of custom
transports are not delivered. Non-web hosts can register and invoke locally.
Native publication on those hosts reports the browser unavailable, and
```

Command:

```
sed -n '48,56p' lib/src/webmcp_exceptions.dart; sed -n '34,43p' lib/src/webmcp_typed_input.dart
```

Output:

```
class WebMcpToolException implements Exception {
  /// Creates a failure with an author [code] and [retryable] flag.
  const WebMcpToolException({
    required this.code,
    required this.retryable,
    this.details,
  });

  /// The author error code.
final class WebMcpInputField {
  /// Creates a field named [key] with [shape].
  const WebMcpInputField({
    required this.key,
    required this.shape,
    this.isRequired = true,
    this.nullable = false,
    this.allowedNames = const <String>[],
    this.child,
  });
```

Command:

```
awk 'NR>=127 && NR<=143 {print NR": "$0}' lib/src/webmcp_typed_input.dart
```

Output:

```
127:     case WebMcpInputShape.enumeration:
128:       if (value is! String || !field.allowedNames.contains(value)) {
129:         throw const WebMcpInvalidArgumentsException();
130:       }
131:       return value;
132:     case WebMcpInputShape.list:
133:       final WebMcpInputField? child = field.child;
134:       if (child == null || value is! List<Object?>) {
135:         throw const WebMcpInvalidArgumentsException();
136:       }
137:       return value
138:           .map((Object? item) => _decodeValue(child, item))
139:           .toList(growable: false);
140:     case WebMcpInputShape.map:
141:       final WebMcpInputField? child = field.child;
142:       if (child == null || value is! Map<Object?, Object?>) {
143:         throw const WebMcpInvalidArgumentsException();
```

Claims confirmed as stated (opened and read, no finding): F1.1, F1.2, F1.3, F1.4, F1.5, F2.1, F2.2, F2.3, F2.4, F2.5, F2.6, F2.7, F2.8, F3.1, F3.2, F3.4, F3.5, F3.6, F3.7, F3.8, F3.9, F3.10, F3.11, F3.12, F3.13, F3.14, F4.2, F4.3, F4.4, F4.5, F4.6, F4.7, F4.8. Specifically verified beyond the artifact's citation: `_operations.settle` sets `completed` only when `reason` is null (`lib/src/transport/webmcp_native_publisher.dart:124-138`), so F3.6's and F3.7's settlement contrast holds; `WebMcpScope.addTool` returns false on a duplicate (`lib/src/webmcp_scope.dart:22-34`), so F4.7's ownership condition holds; and the registration object omits null `title`, `debugging` and `exposedTo` in code as well as in the contract (`lib/src/transport/native_publisher_boundary.dart:76-84`), so F2.4's inference holds.

## Per-criterion results

Not applicable. This is a research review, not an implementation review; `02-criteria.md` is not the subject of this round.

## Findings

### F-001 — The generator's null union is `anyOf`; the artifact calls it `oneOf` three times

- Severity: BLOCKER
- Location: `wiki/work/0018-author-argument-dx/00-research.md:60`, `:316`, `:348`
- Criterion affected: none
- Observation: Line 60 requires nullable fields to use "a schema representation consistent with the generator's `oneOf` pattern"; line 316 states "The generator handles nullable via a `oneOf` or additional `null` type entry (lines 573–577)"; line 348 states "The generator uses a `oneOf` with null at lines 573–577". The cited source emits `'anyOf'` at `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart:577`. A repository-wide search finds the string `oneOf` nowhere in `lib/`, `packages/*/lib/`, `example/` or `test/` — only inside this work item's own documents.
- Why it matters: `oneOf` and `anyOf` are distinct JSON Schema keywords with distinct validation semantics. The artifact's own instruction to a downstream plan is to be "consistent with the generator"; following the stated keyword produces the opposite of that, and the unresolved item that asks what convention to adopt frames the choice against a keyword the generator does not emit.

### F-002 — The claim that the generator derives no safe-integer or finite-double schema constraints is contradicted by the generator and by its committed fixture

- Severity: BLOCKER
- Location: `wiki/work/0018-author-argument-dx/00-research.md:54`, `:55`, `:310`
- Criterion affected: none
- Observation: Line 54 states "`finiteDouble` and `safeInteger`-specific constraints are not yet derived by the generator"; line 55 states that the decoder's `safeInteger` and `finiteDouble` handling is "not matched by a generator schema entry"; constraint 3 at line 310 states "The generator does not emit range constraints (safe-integer bounds, `type: number` for finite double) in its schemas" and concludes that a manual derivation function "must decide these mappings independently". The cited source range says the opposite: `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart:554-559` emits `{'type': 'integer', 'minimum': -9007199254740991, 'maximum': 9007199254740991}` for an integer and `{'type': 'number'}` for a double, and the bounds are present verbatim in committed generated output at `packages/webmcp_flutter_generator/example/lib/inventory_service.webmcp.g.dart:94-98`. The integer bounds are the same two constants the decoder uses (`lib/src/webmcp_typed_input.dart:4-7`, `112-117`).
- Why it matters: this is the stated premise of unresolved items 1 and 2 (lines 346–347), which present the safe-integer and finite-double fragments as open with no precedent. A precedent exists in the cited file and is already shipped in a fixture, so the artifact invites a plan to invent a mapping that would diverge from the generator it is meant to mirror — the exact inconsistency Area 1 exists to remove.

### F-003 — The generated-path field detail question is declared out of scope in the answer and omitted from the unresolved list

- Severity: BLOCKER
- Location: `wiki/work/0018-author-argument-dx/00-research.md:14`, unresolved list `:346-354`
- Criterion affected: none
- Observation: Sub-question 3 at line 8 asks whether the failed field name and a closed reason can be added "for both manual and generated tools". The answer at line 14 states that for the generated path "adding field-level detail to that path is a separate decision not closed by this research". No entry in the unresolved list (lines 346–354) covers it. The nearest entry, line 350, is scoped to a different question — whether the completed-versus-handlerFailed settlement difference matters — and explicitly says "The research scope excludes this decision" about settlement, not about field detail.
- Why it matters: the unresolved list is the handover surface a plan reads to know what is still open. A question the artifact itself raises and declines to close, on one of the four sub-questions it was commissioned to answer, is invisible there, so the plan can close half of sub-question 3 without recording that it did so.

### F-004 — No generated-path option carries field-level detail

- Severity: IMPORTANT
- Location: `wiki/work/0018-author-argument-dx/00-research.md:280-284`
- Criterion affected: none
- Observation: The three options for the generated decode-error path are: keep `FormatException`, throw `WebMcpInvalidArgumentsException` instead, and throw `WebMcpToolException` with a different code. All three change only the exception type; none adds a field key or reason. A fourth option exists and is not named: the generator emits its own invalid-argument helper (`packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart:73-95`) and every guard site already knows the parameter name it is rejecting, because the emitted guards are generated per parameter with the JSON-encoded name in scope (lines 326-359, 387-449), so a key-carrying helper or a key-carrying local return map is available on that path.
- Why it matters: sub-question 3 covers both paths. The options table answers the question "which exception type" for the generated path and never answers "can the field be named", which is what the sub-question asks.

### F-005 — The claim that the exception constructor must become non-const is uncited and contradicted by the repository

- Severity: IMPORTANT
- Location: `wiki/work/0018-author-argument-dx/00-research.md:291`, `:332`
- Criterion affected: none
- Observation: The chosen option at line 291 lists "Constructor becomes non-const" as a cost, and constraint 14 at line 332 states "Adding a field key forces the constructor off `const`." Neither statement cites a file or line. The same file already contains a `const` constructor with an optional nullable field: `WebMcpToolException` at `lib/src/webmcp_exceptions.dart:50-54` declares `const WebMcpToolException({required this.code, required this.retryable, this.details})`, and `WebMcpInputField` at `lib/src/webmcp_typed_input.dart:36-43` is `const` with four optional fields. What a runtime field key prevents is a `const` expression at the individual throw site, not a `const` constructor on the class.
- Why it matters: the constraint reads as a mandate to remove `const` from a public exception constructor. That is a breaking change for any consumer writing `const WebMcpInvalidArgumentsException()`, and it is not required by the change the artifact chose.

### F-006 — Contract lines 155–158 are cited for a prohibition they do not state

- Severity: IMPORTANT
- Location: `wiki/work/0018-author-argument-dx/00-research.md:62`, `:306`
- Criterion affected: none
- Observation: Constraint 1 at line 306 attributes the prohibition on registry-side schema validation to "`wiki/product/webmcp-contract.md` lines 35–40 and 155–158", and F1.7's source line 62 repeats the same pair. Lines 154–159 of the contract are the "Deliberate omissions" paragraph, listing multiple-Flutter-view operation, generated route wrapping, deep schema immutability, transactional source registration and similar; they say nothing about runtime schema validation. The prohibition is stated at contract lines 37–38 only.
- Why it matters: the claim survives on its other citation, but the stray range sends a reader to a paragraph about undelivered features. The nearest relevant phrase there, "deep schema immutability", concerns a different constraint the artifact handles separately at line 308.

### F-007 — The "maps cleanly" claim does not address a field whose `child` is absent or whose `allowedNames` is empty

- Severity: IMPORTANT
- Location: `wiki/work/0018-author-argument-dx/00-research.md:54`
- Criterion affected: none
- Observation: F1.6 claims that "Every `WebMcpInputShape` variant (`string`, `boolean`, `safeInteger`, `finiteDouble`, `enumeration`, `list`, `map`) maps to a well-defined JSON Schema fragment." On `WebMcpInputField`, `child` is nullable and `allowedNames` defaults to the empty list (`lib/src/webmcp_typed_input.dart:36-43`, `60-61`), while the decoder rejects every value for a `list` or `map` field whose `child` is null (`lib/src/webmcp_typed_input.dart:133-135`, `141-143`) and for an `enumeration` field whose `allowedNames` is empty (`:128`). The generator cannot have this case: its own schema getter dereferences `child!` unconditionally (`webmcp_domain_action_generator.dart:566`, `570`) because a shape is only ever built with a child. No finding, constraint or unresolved item states what the derived schema emits for these two inputs.
- Why it matters: a derivation function over author-supplied fields must have defined behaviour for both, and the artifact presents the mapping as total. A plan built on it has no instruction for the one case where the generator precedent does not transfer.

### F-008 — Options table contradicts F3.12 on whether `_decodeValue` already receives the field

- Severity: NIT
- Location: `wiki/work/0018-author-argument-dx/00-research.md:291`
- Criterion affected: none
- Observation: The cost column states "`_decodeValue` needs the field passed in". F3.12 at line 190 states the opposite and is correct: `_decodeValue(WebMcpInputField field, Object? value)` at `lib/src/webmcp_typed_input.dart:93` already takes the field.
- Why it matters: it overstates the cost of the chosen option and contradicts a finding in the same document.

### F-009 — Line citations are systematically off by one or two

- Severity: NIT
- Location: `wiki/work/0018-author-argument-dx/00-research.md:26`, `:62`, `:72`, `:78`, `:126`, `:150`, `:166`, `:179`, `:232`, `:250`, `:328`
- Criterion affected: none
- Observation: Examples: F1.1 evidence says the factory is at "lines 104–135" and its source line says 105–135, actual 105–135; F2.1 cites the `WebMcpTool` constructor at "lines 77–98", actual 77–99, and `WebMcpToolAnnotations` at "48–69", actual 48–70; F2.2 cites "Lines 293–308", actual 292–307; F3.1 and F3.5 cite `webmcp_exceptions.dart` "lines 69–73" while F3.8 cites "70–73" for the same class, actual 70–74; F3.10 cites log sites at "lines 374, 382", actual 374 and 381; F4.4 cites the constructor at "lines 16–36", actual 15–37; F4.7 cites dispose at "lines 111–117", actual 112–118; constraint 11 cites the code regex at "line 414", actual 415; constraint 12 cites the byte limit at "line 14", actual 15.
- Why it matters: each citation still lands inside or adjacent to the construct it names, so no claim is unverifiable, but a reader checking a single line number will miss.

### F-010 — F4.1 evidence misdescribes the guard as the first line

- Severity: NIT
- Location: `wiki/work/0018-author-argument-dx/00-research.md:213`
- Criterion affected: none
- Observation: The evidence states "`if (_registered) return;` is the first line" of `didChangeDependencies`. In `lib/src/widgets/webmcp_action.dart:77-82`, `super.didChangeDependencies()` is the first statement, the guard is a block-bodied `if (_registered) { return; }` second, and `_registered = true` third. The substantive claim — that the boolean prevents re-registration — holds.
- Why it matters: cosmetic only; the guard's position relative to the super call does not affect the chosen option.

### F-011 — Area 1 options omit a merge of derived and author-supplied schema

- Severity: NIT
- Location: `wiki/work/0018-author-argument-dx/00-research.md:266-268`
- Criterion affected: none
- Observation: Options are: author writes both, derive only when `inputSchema` is empty, and always replace. Option C is rejected at line 268 because it "eliminates author ability to provide per-property descriptions, examples, or richer constraints". A fourth option that merges derived type information with author-supplied per-property prose is not named, although it is the option that directly answers that rejection reason.
- Why it matters: the chosen option is defensible without it, since an author who supplies any schema keeps full control. The omission only narrows the recorded trade-off.

### F-012 — F3.3's cited ranges miss one `_$webMcpInvalid()` emission site

- Severity: NIT
- Location: `wiki/work/0018-author-argument-dx/00-research.md:138`
- Criterion affected: none
- Observation: F3.3 cites generator lines 80–93 and 397–449 as covering every guard that calls `_$webMcpInvalid()`. `_emitInvoker` also emits it at `webmcp_domain_action_generator.dart:350`, as the fallback for an optional non-nullable parameter with no default value. That site is outside both cited ranges.
- Why it matters: the claim that every invalid-argument condition funnels through the same helper is still true, and the missed site reinforces it rather than contradicting it.

## Recurrence check

- Previous round: none — first round
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
| F-009 | research |
| F-010 | research |
| F-011 | research |
| F-012 | research |
