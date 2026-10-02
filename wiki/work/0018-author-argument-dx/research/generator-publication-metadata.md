<!-- Research artifact for work item 0018-author-argument-dx. -->

# Research: Generator publication metadata gap vs hand-written WebMcpTool

## Question

Which publication metadata fields can a generated domain tool carry today,
compared with a hand-written `WebMcpTool`, and which annotation fields can be
added without the generator constructing services or granting authorization?

## Answer

A generated tool today carries `name`, `description`, `readOnlyHint`,
`untrustedContentHint`, and `consequentialHint`. It never carries `title`,
`debugging`, or `exposedTo`, because the `WebMcpDomainAction` annotation has no
fields for them and the generator emits no corresponding `WebMcpTool` arguments.
All three missing fields are pure publication metadata; adding them to the
annotation and forwarding them in the generator template requires no service
construction and grants no authorization. The simplest path that closes the gap
without fragmenting the annotation surface is Option B: extend
`WebMcpDomainAction` with the three optional fields.

## Findings

### Fields present on WebMcpTool but absent from WebMcpDomainAction

- Claim: `WebMcpTool` accepts `title` (nullable `String`), `exposedTo`
  (nullable `List<String>`), and `debugging` (nullable `bool` inside
  `WebMcpToolAnnotations`). The `WebMcpDomainAction` annotation has none of
  these fields.
- Evidence: `WebMcpTool` constructor at lines 77–98 and
  `WebMcpToolAnnotations` at lines 48–69.
  `WebMcpDomainAction` fields at lines 1–33.
- Source: `lib/src/webmcp_tool.dart` lines 48–98;
  `packages/webmcp_flutter_annotations/lib/webmcp_flutter_annotations.dart`
  lines 1–33.

### Generator never emits title, debugging, or exposedTo

- Claim: The `_emitClass` method of the generator writes a `WebMcpTool(…)`
  literal that includes `name`, `description`, `inputSchema`, `annotations`
  (with `readOnlyHint`, `untrustedContentHint`, `consequentialHint`), and
  `handler`. It does not emit `title:`, `debugging:`, or `exposedTo:`.
- Evidence: Lines 293–308 of the generator show exactly those five arguments
  and nothing more.
- Source: `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart`
  lines 293–308.

### Confirmed gap visible in both generated fixtures

- Claim: Both `ExampleTaskServiceWebMcpSource` and `InventoryServiceWebMcpSource`
  omit `title` and `exposedTo` from every `WebMcpTool` call, and
  `WebMcpToolAnnotations` is always constructed without `debugging:`.
- Evidence: Generated tool constructors at lines 44–60 and 62–76 of the task
  fixture; lines 86–118 of the inventory fixture.
- Source: `example/lib/example_task_service.webmcp.g.dart` lines 44–76;
  `packages/webmcp_flutter_generator/example/lib/inventory_service.webmcp.g.dart`
  lines 86–118.

### Null means omit, per the product contract

- Claim: A null `title`, null `debugging`, or null origin list causes those
  fields to be omitted from the browser registration object. An omitted
  `debugging` is not sent as `false`. This makes all three fields safe to
  leave as null by default without altering existing tool behavior.
- Evidence: Contract section "Browser boundary" states this explicitly.
- Source: `wiki/product/webmcp-contract.md` lines 132–136.

### The _readMethod helper reads only the five annotation fields it knows

- Claim: `_readMethod` calls `annotation.read('description')`,
  `annotation.peek('name')`, `annotation.read('readOnlyHint')`,
  `annotation.read('untrustedContentHint')`, and
  `annotation.read('consequentialHint')`. It reads nothing else from the
  annotation, so adding new optional fields to the annotation class does not
  break existing reads.
- Evidence: Lines 119–166 of the generator.
- Source: `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart`
  lines 119–166.

### _ExposedMethod carries no title, debugging, or exposedTo today

- Claim: The private `_ExposedMethod` data class has fields `methodName`,
  `toolName`, `description`, `readOnlyHint`, `untrustedContentHint`,
  `consequentialHint`, `parameters`, and `returnShape`. Adding `title`,
  `debugging`, and `exposedTo` there, then forwarding them in `_emitClass`,
  is the complete mechanical change needed.
- Evidence: `_ExposedMethod` definition at lines 608–628.
- Source: `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart`
  lines 608–628.

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| A – Leave annotation unchanged | Generated tools permanently lack `title`, `debugging`, `exposedTo`. Authors who need them must hand-write `WebMcpTool`. | Zero change cost now; ongoing per-method boilerplate for authors. | Rejected. The gap is mechanical and the missing fields are safe pure metadata. Leaving it forces authors to abandon the generator for any tool that needs a title or origin filter. |
| B – Extend `WebMcpDomainAction` with optional `title`, `debugging`, `exposedTo` | Add three nullable fields to the annotation, update `_readMethod` and `_ExposedMethod` to carry them, and update `_emitClass` to emit them when non-null. | One annotation class change, three generator changes, one new generated-code code path. | Chosen. Single annotation type, minimal surface area, purely additive, does not alter any existing usage, does not construct services or grant authorization. |
| C – Add a second annotation type (e.g. `WebMcpDomainPublication`) | A separate annotation placed alongside `@WebMcpDomainAction` carries `title`, `debugging`, `exposedTo`. Generator reads both. | Two annotation types to document and discover; generator must read and merge two annotations per method; error messages become more complex. | Rejected. Splitting one tool descriptor across two annotations increases friction without delivering functionality that Option B cannot provide. There is no semantic reason to separate these fields from the action annotation. |

## Constraints discovered

- **Null semantics are load-bearing.** The contract mandates that null `title`,
  null `debugging`, and null `exposedTo` are omitted from browser registration.
  The generator must emit these fields only when non-null, not always.
  (`wiki/product/webmcp-contract.md` lines 132–136)
- **`debugging` lives inside `WebMcpToolAnnotations`, not on `WebMcpTool`
  directly.** The generator emits `const WebMcpToolAnnotations(…)`. Adding
  `debugging` requires changing the annotations literal, not the outer tool
  constructor.
  (`lib/src/webmcp_tool.dart` lines 48–69)
- **The annotation class must remain `const`-constructible.** `WebMcpDomainAction`
  is a `const` constructor. New optional fields must have default values of
  `null` and must be `final`, matching the existing pattern.
  (`packages/webmcp_flutter_annotations/lib/webmcp_flutter_annotations.dart`
  lines 10–17)
- **`exposedTo` on `WebMcpTool` is `List<String>?`, not `List<String>`.** A
  null list means omit; an empty list is a different (probably unintended)
  state. The annotation field must likewise be nullable.
  (`lib/src/webmcp_tool.dart` lines 88–91)
- **The generator must use `annotation.peek(…)` not `annotation.read(…)` for
  optional fields.** `peek` returns null when the field is absent or set to
  null; `read` throws. `name` is already read with `peek` at line 126.
  (`packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart`
  line 126)

## Unresolved

- [UNRESOLVED: What is the correct Dart annotation field type to hold a
  `List<String>?` that is declared `const`? A const list literal is allowed,
  but a null default combined with a nullable type must be verified against
  `source_gen`'s `ConstantReader` list-reading API for the generator side.]

## Sources

| Source | Consulted |
|---|---|
| `packages/webmcp_flutter_annotations/lib/webmcp_flutter_annotations.dart` | 2026-10-02 |
| `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart` | 2026-10-02 |
| `lib/src/webmcp_tool.dart` | 2026-10-02 |
| `example/lib/example_task_service.dart` | 2026-10-02 |
| `example/lib/example_task_service.webmcp.g.dart` | 2026-10-02 |
| `packages/webmcp_flutter_generator/example/lib/inventory_service.dart` | 2026-10-02 |
| `packages/webmcp_flutter_generator/example/lib/inventory_service.webmcp.g.dart` | 2026-10-02 |
| `wiki/product/webmcp-contract.md` | 2026-10-02 |
