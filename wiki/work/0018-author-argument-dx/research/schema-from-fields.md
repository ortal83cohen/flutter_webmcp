---
id: 0018-schema-from-fields
title: "Relationship between WebMcpInputField list and inputSchema on manual tools"
status: active
owner: researcher
created: "2026-10-02"
last_verified: "2026-10-02"
applies_to: ["lib/src/webmcp_tool.dart", "lib/src/webmcp_typed_input.dart"]
summary: >
  Research into how a Flutter author supplies both a declared field list and an input
  schema on manual tools today, and which option lets an agent see the same fields
  the decoder checks, without making the registry validate at runtime.
---

# Research: Relationship between WebMcpInputField list and inputSchema on manual tools

## Question

How does a Flutter author using `webmcp_flutter` supply both a declared field list
(`List<WebMcpInputField>`) and an `inputSchema` map today on a
`WebMcpTool.withDecodedArguments` tool, and which option lets a browser agent see
the same fields the decoder checks — without making the registry validate the schema
at runtime?

## Answer

Today the two are completely independent and unrelated: the author writes a `fields`
list for decoding and a separate `inputSchema` map for the agent, and the library never
derives one from the other. The decoder never reads the schema map; the schema is
never derived from or checked against the fields. The best option going forward is
**Option B — derive a descriptive JSON schema from the field list when the caller
omits or leaves `inputSchema` empty**, because it achieves consistency in the default
case without breaking authors who intentionally supply a richer schema, and it mirrors
the proven approach already used by the generator.

## Findings

### Finding 1 — withDecodedArguments accepts both fields and inputSchema independently

- Claim: `WebMcpTool.withDecodedArguments` requires a `List<WebMcpInputField> fields`
  parameter and accepts an optional `Map<String, Object?> inputSchema` (default empty).
  Both are stored independently; the constructor passes `inputSchema` straight through
  to the inner `WebMcpTool(...)` and uses `fields` only inside the closure passed to
  `callHandler`.
- Evidence: The factory at lines 104–135 of `lib/src/webmcp_tool.dart` reads:
  `inputSchema: inputSchema,` when constructing the inner `WebMcpTool`, and the closure
  calls `webMcpDecodeArguments(fields, call.arguments)` with no reference to
  `inputSchema`.
- Source: `lib/src/webmcp_tool.dart` lines 105–135

### Finding 2 — webMcpDecodeArguments reads only the fields list

- Claim: `webMcpDecodeArguments` builds a lookup map from `fields`, rejects unknown
  keys, checks required fields, and dispatches shape decoding. It does not read the
  `inputSchema` map at any point.
- Evidence: The function body at lines 68–91 of `lib/src/webmcp_typed_input.dart`
  takes `List<WebMcpInputField> fields` and `Map<String, Object?> arguments`. There
  is no `inputSchema` parameter and no reference to any schema map.
- Source: `lib/src/webmcp_typed_input.dart` lines 68–91

### Finding 3 — The registry and contract explicitly separate schema from decoding

- Claim: The product contract and README both state that the schema is descriptive,
  the registry performs no runtime JSON Schema validation, and declared-field decoding
  is a separate check that does not read the schema map.
- Evidence (contract): "The schema is descriptive; the registry performs no runtime
  JSON Schema validation. Declared-field decoding is a separate check. It runs only
  for a tool built from a field list, and it does not read the schema map."
- Evidence (README): "Manual input schemas are descriptive only. [...] The package
  does not validate arguments against the schema at runtime.
  `WebMcpTool.withDecodedArguments` checks a separate declared field list before the
  author callback."
- Source: `wiki/product/webmcp-contract.md` lines 35–40;
  `README.md` lines 582–587

### Finding 4 — The generator already derives a JSON schema from type-level shapes

- Claim: `webmcp_flutter_generator` calls `_schemaFor(method)` to derive a JSON schema
  from the method's parameter shapes and writes that schema to `inputSchema:` in the
  emitted tool. The decoder in the generated code uses the same shapes to check argument
  values. Schema and decoder are therefore consistent by construction in generated tools.
- Evidence: `_schemaFor` at lines 455–470 iterates `method.parameters`, calling
  `parameter.shape.schema` (defined at lines 550–575) to produce per-property schema
  objects with `type`, `enum`, `items`, and `additionalProperties`. The same
  `_emitDecoder` at lines 258–271 emits the runtime shape check from the same shapes.
- Source: `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart`
  lines 255–275, 292–299, 455–482, 550–577

### Finding 5 — Manual example tools hand-write both schema and fields separately

- Claim: In the example codebase, manual tools that use `withDecodedArguments` do not
  exist in the example source; instead, the example uses hand-written `WebMcpTool`
  instances with a hand-written `inputSchema` and no `fields` list, while generated
  tools (`.webmcp.g.dart`) have a consistent schema derived from type shapes. There is
  no existing pattern that ensures a hand-written schema matches a hand-written field list.
- Evidence: `example/lib/example_counter_source.dart` line 31 uses `WebMcpTool` with a
  hand-written schema. `example/lib/example_task_service.webmcp.g.dart` lines 44–68 use
  a generator-derived schema. No example file uses `WebMcpTool.withDecodedArguments`
  with a matching `inputSchema`.
- Source: `example/lib/example_counter_source.dart` lines 31–44;
  `example/lib/example_task_service.webmcp.g.dart` lines 44–68

### Finding 6 — WebMcpInputShape maps cleanly to JSON Schema scalar types

- Claim: Every `WebMcpInputShape` variant (`string`, `boolean`, `safeInteger`,
  `finiteDouble`, `enumeration`, `list`, `map`) maps to a well-defined JSON Schema
  fragment. The generator demonstrates this mapping at `_TypeShape.schema` for an
  overlapping shape set (`string`, `boolean`, `integer`, `enumeration`, `list`, `map`).
  `finiteDouble` and `safeInteger`-specific constraints (`minimum`/`maximum` for safe
  integer range, `type: number` for finite double) are not yet derived by the generator.
- Evidence: `webmcp_typed_input.dart` lines 10–31 define the enum values. Generator
  lines 550–575 show the mapping to `{'type': 'string'}`, `{'type': 'boolean'}`,
  `{'type': 'integer', ...}`, `{'type': 'string', 'enum': ...}`, array, and object.
  `safeInteger` and `finiteDouble` handling in `webmcp_typed_input.dart` at lines 112–125
  are not matched by a generator schema entry.
- Source: `lib/src/webmcp_typed_input.dart` lines 10–31, 112–125;
  `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart`
  lines 550–575

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| **A — Status quo: author hand-writes both** | Author supplies `fields` for decoding and a separate `inputSchema` for agents. Library never connects them. | Zero library change. | Rejected as the default path forward: schema and fields can silently disagree, so an agent sees a description that does not match what the decoder enforces. |
| **B — Derive schema from fields when inputSchema is omitted (or empty)** | `withDecodedArguments` inspects `inputSchema`; if it is empty (the default), builds a JSON schema from the `fields` list using the same shape-to-schema mapping the generator already uses. Author can still supply an explicit schema. | Small pure-function derivation at construction time; no registry change. | **Chosen.** Default case becomes consistent automatically. Author override is preserved for richer descriptions. Mirrors proven generator pattern. Does not validate at runtime. |
| **C — Always replace supplied schema with a derived one** | `withDecodedArguments` ignores any supplied `inputSchema` and always derives from `fields`. | Same derivation cost; breaks any author intent to supply a custom schema. | Rejected: eliminates author ability to provide per-property descriptions, examples, or richer constraints that go beyond the decoded shape. |

## Constraints discovered

1. **No runtime validation.** The product contract (`wiki/product/webmcp-contract.md`
   lines 35–40) and the deliberate-omissions section (`lines 155–158`) prohibit the
   registry from validating arguments against the schema. Any derivation must happen
   at construction time only.
2. **Schema is a shallow-copied, unmodifiable outer map.** `WebMcpTool`'s constructor
   wraps the outer map in `UnmodifiableMapView` but leaves nested values shared
   (`lib/src/webmcp_tool.dart` lines 86–88; contract lines 35–37). A derived schema
   whose nested objects come from a pure derivation function has no shared-state risk.
3. **`safeInteger` and `finiteDouble` have no established generator-side schema.**
   The generator does not emit `webmcp_flutter` range constraints (safe-integer bounds,
   `type: number` for finite double) in its schemas. A derivation function for manual
   tools would need to decide these mappings independently.
4. **`fields` is not stored on the `WebMcpTool` descriptor.** The public `WebMcpTool`
   class has no `fields` property; the field list is captured only inside the
   `callHandler` closure (`lib/src/webmcp_tool.dart` lines 122–130). Schema derivation
   must happen during the `withDecodedArguments` factory call, not later.
5. **`allowedNames` for enumeration fields must be reflected in the schema `enum`
   array** for the derived schema to be accurate. This is already the pattern in the
   generator (`webmcp_domain_action_generator.dart` line 562).
6. **`nullable` fields need a schema representation.** The generator handles nullable
   via a `oneOf` or an additional `null` type entry (lines 573–577). Manual field
   derivation must adopt a consistent convention.

## Unresolved

- [UNRESOLVED: What JSON Schema fragment should represent `WebMcpInputShape.safeInteger`?
  Options include `{'type': 'integer', 'minimum': -9007199254740991, 'maximum': 9007199254740991}`
  (matching the decoder bounds) or a plain `{'type': 'integer'}`. The decoder uses the
  explicit bounds at `lib/src/webmcp_typed_input.dart` lines 112–117.]
- [UNRESOLVED: What JSON Schema fragment should represent `WebMcpInputShape.finiteDouble`?
  `{'type': 'number'}` is the natural JSON Schema type but does not encode the
  finiteness constraint, which the decoder enforces at lines 119–126.]
- [UNRESOLVED: What convention should nullable fields use in the derived schema?
  The generator uses a `oneOf` with null at lines 573–577 of the generator. Manual
  derivation must match or deliberately diverge from that convention.]

## Sources

| Source | Consulted |
|---|---|
| `lib/src/webmcp_tool.dart` | 2026-10-02 |
| `lib/src/webmcp_typed_input.dart` | 2026-10-02 |
| `wiki/product/webmcp-contract.md` | 2026-10-02 |
| `README.md` lines 35–45, 74–84, 172–182, 579–588 | 2026-10-02 |
| `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart` | 2026-10-02 |
| `packages/webmcp_flutter_generator/example/lib/inventory_service.webmcp.g.dart` | 2026-10-02 |
| `example/lib/example_task_service.webmcp.g.dart` | 2026-10-02 |
| `example/lib/example_counter_source.dart` | 2026-10-02 |
| `test/registry_test.dart` lines 139–358 | 2026-10-02 |
