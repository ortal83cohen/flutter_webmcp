# Research: Author-facing argument DX improvements

## Question

Four related sub-questions drive this research, each corresponding to one improvement axis:

1. **Schema from fields** — Which small change lets a browser agent see the same fields a manual decoder checks, without making the registry validate at runtime?
2. **Generator publication metadata** — Which annotation changes let a generated domain tool carry the same `title`, `debugging`, and `exposedTo` metadata as a hand-written `WebMcpTool`?
3. **Decode-failure detail** — Can the failed field name and a closed failure reason be added to a decode failure response without leaking argument values, messages, or stacks — for both manual and generated tools?
4. **Widget action decoded fields** — Which option gives `WebMcpAction` declared-field decoding matching `WebMcpTool.withDecodedArguments` without changing descriptor freeze, child rendering, or authorization?

## Answer

All four improvements are achievable with purely additive, independently deployable changes. Schema consistency for manual tools requires deriving a JSON schema from the `fields` list when `inputSchema` is omitted (Option B in that stream). Generated tool publication metadata gaps (`title`, `debugging`, `exposedTo`) close by extending `WebMcpDomainAction` with three optional fields. For decode-failure detail, the manual-tool path already throws `WebMcpInvalidArgumentsException` and can carry a new `field` key and closed `reason` enum; the generated-tool path catches `FormatException` locally before the publisher sees it and returns a bare `invalidArguments` map that already reaches the agent. Whether that generated return should also name the failed field is listed under Unresolved and is not closed here. `WebMcpAction` gains declared-field decoding by accepting an optional `fields` parameter captured at first mount, building the registered tool via `WebMcpTool.withDecodedArguments`.

## Findings

---

### Area 1 — Schema from declared fields (manual tools)

#### F1.1 — `withDecodedArguments` stores fields and schema independently

- Claim: `WebMcpTool.withDecodedArguments` requires `List<WebMcpInputField> fields` and accepts an optional `Map<String, Object?> inputSchema` (default empty). Both are stored independently; `inputSchema` is passed straight through to the inner `WebMcpTool`; `fields` is used only inside the `callHandler` closure.
- Evidence: The factory at lines 104–135 passes `inputSchema: inputSchema,` when constructing the inner `WebMcpTool`, and the closure calls `webMcpDecodeArguments(fields, call.arguments)` with no reference to `inputSchema`.
- Source: `lib/src/webmcp_tool.dart` lines 105–135

#### F1.2 — `webMcpDecodeArguments` reads only the fields list

- Claim: `webMcpDecodeArguments` builds a lookup map from `fields`, rejects unknown keys, checks required fields, and dispatches shape decoding. It does not read the `inputSchema` map at any point.
- Evidence: The function at lines 68–91 of `lib/src/webmcp_typed_input.dart` accepts only `List<WebMcpInputField>` and `Map<String, Object?> arguments`. No `inputSchema` parameter exists; no schema map is referenced.
- Source: `lib/src/webmcp_typed_input.dart` lines 68–91

#### F1.3 — Registry explicitly separates schema from decoding (shared with Area 4)

- Claim: The product contract and README state that the schema is descriptive, the registry performs no runtime JSON Schema validation, and declared-field decoding is a separate check that does not read the schema map.
- Evidence: Contract: "The schema is descriptive; the registry performs no runtime JSON Schema validation. Declared-field decoding is a separate check." README lines 582–587 confirm.
- Source: `wiki/product/webmcp-contract.md` lines 35–40; `README.md` lines 582–587

#### F1.4 — Generator already derives schema from type-level shapes

- Claim: `webmcp_flutter_generator` calls `_schemaFor(method)` to derive a JSON schema from parameter shapes and writes it to `inputSchema:` in the emitted tool. The decoder uses the same shapes. Schema and decoder are consistent by construction in generated tools.
- Evidence: `_schemaFor` at lines 455–470 iterates `method.parameters`, calling `parameter.shape.schema` (lines 550–575) to produce per-property schema objects with `type`, `enum`, `items`, and `additionalProperties`. `_emitDecoder` at lines 258–271 emits the runtime shape check from the same shapes.
- Source: `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart` lines 255–275, 292–299, 455–482, 550–577

#### F1.5 — No existing pattern ensures a hand-written schema matches a hand-written field list

- Claim: In the example codebase, no file uses `WebMcpTool.withDecodedArguments` with a matching `inputSchema`. Hand-written tools supply schema separately; generated tools derive theirs.
- Evidence: `example/lib/example_counter_source.dart` line 31 uses `WebMcpTool` with a hand-written schema and no `fields` list. `example/lib/example_task_service.webmcp.g.dart` lines 44–68 use a generator-derived schema.
- Source: `example/lib/example_counter_source.dart` lines 31–44; `example/lib/example_task_service.webmcp.g.dart` lines 44–68

#### F1.6 — `WebMcpInputShape` maps cleanly to JSON Schema scalar types

- Claim: The generator already emits a schema for the shapes it builds: string, boolean, integer with the decoder's inclusive bounds, number for a double, string plus an enum array, array with items, and object with additionalProperties. A manual field can also be a list or map with no child, or an enumeration with an empty allowed-names list. The generator never builds those two inputs, so this finding does not specify their schema fragments.
- Evidence: `webmcp_typed_input.dart` lines 10–31 define the enum values and lines 112–125 enforce the integer bounds and finite doubles. The generator emits the integer bounds and the number type at lines 554–559, and the committed fixture repeats the bounds.
- Source: `lib/src/webmcp_typed_input.dart` lines 10–31, 112–125; `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart` lines 554–559; `packages/webmcp_flutter_generator/example/lib/inventory_service.webmcp.g.dart` lines 94–98

#### F1.7 — Constraints narrowing schema derivation for manual tools

- Claim: The derived schema must be built at construction time only (no runtime validation per contract). `WebMcpTool`'s constructor wraps the outer map in `UnmodifiableMapView` but leaves nested values shared. The `fields` list is not stored on the public `WebMcpTool` descriptor; it is captured only inside the `callHandler` closure. `allowedNames` for enumeration fields must appear in the schema `enum` array. `nullable` fields require a schema representation consistent with the generator's `anyOf` null union.
- Evidence: `lib/src/webmcp_tool.dart` lines 86–88, 122–130; contract lines 35–37; generator lines 562, 573–577.
- Source: `lib/src/webmcp_tool.dart` lines 86–88, 122–130; `wiki/product/webmcp-contract.md` lines 37–38; `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart` lines 562, 573–577

---

### Area 2 — Generator publication metadata gap

#### F2.1 — `WebMcpTool` accepts title, exposedTo, and debugging; annotation has none

- Claim: `WebMcpTool` accepts `title` (nullable `String`), `exposedTo` (nullable `List<String>`), and `debugging` (nullable `bool` inside `WebMcpToolAnnotations`). `WebMcpDomainAction` has none of these fields.
- Evidence: `WebMcpTool` constructor at lines 77–98 and `WebMcpToolAnnotations` at lines 48–69. `WebMcpDomainAction` fields at lines 1–33.
- Source: `lib/src/webmcp_tool.dart` lines 48–98; `packages/webmcp_flutter_annotations/lib/webmcp_flutter_annotations.dart` lines 1–33

#### F2.2 — Generator never emits title, debugging, or exposedTo

- Claim: `_emitClass` writes a `WebMcpTool(…)` literal including `name`, `description`, `inputSchema`, `annotations` (with `readOnlyHint`, `untrustedContentHint`, `consequentialHint`), and `handler`. It does not emit `title:`, `debugging:`, or `exposedTo:`.
- Evidence: Lines 293–308 of the generator show exactly those five arguments and nothing more.
- Source: `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart` lines 293–308

#### F2.3 — Gap confirmed in both generated fixtures

- Claim: Both `ExampleTaskServiceWebMcpSource` and `InventoryServiceWebMcpSource` omit `title` and `exposedTo` from every `WebMcpTool` call, and `WebMcpToolAnnotations` is always constructed without `debugging:`.
- Evidence: Generated tool constructors at lines 44–60 and 62–76 of the task fixture; lines 86–118 of the inventory fixture.
- Source: `example/lib/example_task_service.webmcp.g.dart` lines 44–76; `packages/webmcp_flutter_generator/example/lib/inventory_service.webmcp.g.dart` lines 86–118

#### F2.4 — Null means omit per the product contract

- Claim: A null `title`, null `debugging`, or null origin list causes those fields to be omitted from the browser registration object. An omitted `debugging` is not sent as `false`. All three fields are therefore safe to leave null by default without altering existing tool behavior.
- Evidence: Contract section "Browser boundary" states this explicitly.
- Source: `wiki/product/webmcp-contract.md` lines 132–136

#### F2.5 — `_readMethod` reads only the five annotation fields it knows; adding fields is non-breaking

- Claim: `_readMethod` calls `annotation.read('description')`, `annotation.peek('name')`, `annotation.read('readOnlyHint')`, `annotation.read('untrustedContentHint')`, and `annotation.read('consequentialHint')`. It reads nothing else, so adding new optional fields to the annotation class does not break existing reads.
- Evidence: Lines 119–166 of the generator.
- Source: `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart` lines 119–166

#### F2.6 — `_ExposedMethod` carries no title, debugging, or exposedTo today

- Claim: `_ExposedMethod` has fields `methodName`, `toolName`, `description`, `readOnlyHint`, `untrustedContentHint`, `consequentialHint`, `parameters`, and `returnShape`. Adding `title`, `debugging`, and `exposedTo` there and forwarding them in `_emitClass` is the complete mechanical change needed.
- Evidence: `_ExposedMethod` definition at lines 608–628.
- Source: `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart` lines 608–628

#### F2.7 — Annotation must remain const-constructible; peek required for optional fields

- Claim: `WebMcpDomainAction` is a `const` constructor; new optional fields must have default values of `null` and must be `final`. For optional annotation fields, `annotation.peek(…)` must be used (not `annotation.read(…)`); `read` throws when the field is absent.
- Evidence: Annotation class at lines 10–17; generator `name` is already read with `peek` at line 126.
- Source: `packages/webmcp_flutter_annotations/lib/webmcp_flutter_annotations.dart` lines 10–17; `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart` line 126

#### F2.8 — `debugging` lives inside WebMcpToolAnnotations, not on WebMcpTool directly

- Claim: The generator emits `const WebMcpToolAnnotations(…)`. Adding `debugging` requires changing the annotations literal, not the outer tool constructor.
- Evidence: `lib/src/webmcp_tool.dart` lines 48–69.
- Source: `lib/src/webmcp_tool.dart` lines 48–69

---

### Area 3 — Decode-failure detail (manual tools vs generated tools)

> **Note:** Manual tools (`webMcpDecodeArguments` in `webmcp_typed_input.dart`) and generated tools (generated `_invoke` in `.g.dart` files) use different exception paths. The findings below are separated by path. They are not contradictions; they describe two distinct code paths that happen to produce identical wire JSON today.

#### F3.1 — Manual path: every decode failure throws `WebMcpInvalidArgumentsException`

- Claim: Every decode failure in `webMcpDecodeArguments` and `_decodeValue` throws `const WebMcpInvalidArgumentsException()`, which carries no field key, no reason, and no value.
- Evidence: All `throw` sites in both functions use the no-argument const constructor.
- Source: `lib/src/webmcp_typed_input.dart` lines 77–154; `lib/src/webmcp_exceptions.dart` lines 69–73

#### F3.2 — Generated path: `_$webMcpInvalid()` throws a `FormatException`

- Claim: The generator emits a top-level helper `_$webMcpInvalid()` whose sole body is `throw const FormatException('Invalid WebMCP arguments.')`.
- Evidence: Generator source writes `"Never _\$webMcpInvalid() => throw const FormatException('Invalid WebMCP arguments.');"`.
- Source: `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart` lines 74–76

#### F3.3 — Generated path: every decoder validation calls `_$webMcpInvalid()`

- Claim: Null checks, type checks, integer range checks, double finiteness checks, enum name mismatches, unknown-key checks, and missing-required-key checks all call `_$webMcpInvalid()`, so every invalid-argument condition in generated code throws the same `FormatException`.
- Evidence: `_emitDecoder` and `_emitInvoker` emit `_$webMcpInvalid()` in every guard branch. Confirmed in generated output files.
- Source: `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart` lines 80–93, 397–449

#### F3.4 — Generated path: `_invoke` catches `FormatException` and returns a map — does not rethrow

- Claim: The generated invoker wraps everything in `try { … } on FormatException { return const <String, Object?>{'ok': false, 'error': <String, Object?>{'code': 'invalidArguments', 'retryable': false}}; }`. The exception never propagates to the publisher.
- Evidence: Both generated example files show identical catch-and-return blocks.
- Source: `example/lib/example_task_service.webmcp.g.dart` lines 87–95; `packages/webmcp_flutter_generator/example/lib/inventory_service.webmcp.g.dart` lines 152–159

#### F3.5 — Manual path: `WebMcpInvalidArgumentsException` reaches the publisher via the WebMcpToolException branch

- Claim: `WebMcpInvalidArgumentsException` extends `WebMcpToolException`. When thrown by a manual tool, the publisher catches it at the `on WebMcpToolException` branch and calls `_toolExceptionFailure`, which settles the operation as `handlerFailed` and logs `WebMcpLogKind.invocationFailed`.
- Evidence: Class declaration `final class WebMcpInvalidArgumentsException extends WebMcpToolException`. Publisher catch at line 369 routes to `_toolExceptionFailure`.
- Source: `lib/src/webmcp_exceptions.dart` lines 69–73; `lib/src/transport/webmcp_native_publisher.dart` lines 369–375

#### F3.6 — Both paths produce identical wire JSON today; they differ only in operation-tracker outcome and log kind

- Claim: The generated `FormatException` route: publisher receives the handler's returned map (success path), normalizes and JSON-encodes it, settles operation as **completed**, logs `WebMcpLogKind.invoked`. The manual `WebMcpInvalidArgumentsException` route: publisher catches the exception, settles as **handlerFailed**, logs `WebMcpLogKind.invocationFailed`. Both produce wire output `{"ok":false,"error":{"code":"invalidArguments","retryable":false}}`.
- Evidence: Publisher success path at lines 384–391; `on WebMcpToolException` block at lines 370–375; `WebMcpInvalidArgumentsException` supplies `code: 'invalidArguments'` and `retryable: false`.
- Source: `lib/src/transport/webmcp_native_publisher.dart` lines 356–392, 413–435; `lib/src/webmcp_exceptions.dart` lines 70–74

#### F3.7 — Throwing `WebMcpInvalidArgumentsException` from generated code would change operation settlement and logs

- Claim: If the generator replaced the local `FormatException` catch with a thrown `WebMcpInvalidArgumentsException`, the publisher's `on WebMcpToolException` branch would fire and produce the **identical wire JSON** (`{"ok":false,"error":{"code":"invalidArguments","retryable":false}}`), but operation settlement would change from `completed` to `handlerFailed`, and the log kind from `invoked` to `invocationFailed`.
- Evidence: `_toolExceptionFailure` builds the body from `error.code` and `error.retryable`; `WebMcpInvalidArgumentsException` supplies exactly those values. Settlement difference confirmed at publisher lines 370–375 vs 388–390.
- Source: `lib/src/transport/webmcp_native_publisher.dart` lines 367–391, 413–435; `lib/src/webmcp_exceptions.dart` lines 70–74

#### F3.8 — Current manual-path payload carries no field name; publisher accepts a details map

- Claim: Because `WebMcpInvalidArgumentsException` passes `details: null`, the agent receives `{"ok":false,"error":{"code":"invalidArguments","retryable":false}}` with no details field. `_toolExceptionFailure` adds `body['details']` only when `error.details != null`.
- Evidence: `_toolExceptionFailure` at lines 413–436. `WebMcpInvalidArgumentsException` does not set `details`.
- Source: `lib/src/transport/webmcp_native_publisher.dart` lines 413–436; `lib/src/webmcp_exceptions.dart` lines 70–73

#### F3.9 — A field key + closed reason enum is small and cannot leak a value

- Claim: A details map of the form `{"field":"<key>","reason":"missing"|"unknown"|"type"}` is a fixed-size, enumerated object. It carries no decoded value, no free-form message, and no stack. It satisfies the normalization rules (string-keyed map, string values, no cycles, depth < 32, well under 64 KB).
- Evidence: `_normalizeJson` accepts a string-keyed map of strings unconditionally. Reason values are a closed set chosen by the library, not echoed from caller input.
- Source: `lib/src/transport/webmcp_native_publisher.dart` lines 480–501

#### F3.10 — Log hook records only event kind and tool name

- Claim: `webMcpRecordLog` is called with `WebMcpLogKind.invocationFailed` and `tool.name` only. No argument data, field name, or exception detail is passed to the hook.
- Evidence: Both failure call sites call `webMcpRecordLog(WebMcpLogKind.invocationFailed, tool.name)` with no third argument.
- Source: `lib/src/transport/webmcp_native_publisher.dart` lines 374, 382; `wiki/product/webmcp-contract.md` line 40

#### F3.11 — Contract mandates publisher omits exception message and stack (shared with F3.7 constraints)

- Claim: The product contract explicitly states that the publisher "maps an accepted WebMcpToolException to an allowlisted error and omits the exception message and stack."
- Evidence: Direct quote from the contract document.
- Source: `wiki/product/webmcp-contract.md` lines 30–33

#### F3.12 — Unknown-key and missing-key detection sites have the key in scope; `_decodeValue` has it via field.key

- Claim: `webMcpDecodeArguments` iterates `arguments.keys` (unknown-key detection) and `fields` (missing-key detection), so the key is available at both throw sites. `_decodeValue` receives the `WebMcpInputField` which carries `field.key`.
- Evidence: `lib/src/webmcp_typed_input.dart` lines 76–88.
- Source: `lib/src/webmcp_typed_input.dart` lines 76–88

#### F3.13 — A details value outside publisher limits downgrades to handler-failed

- Claim: If details normalization or size check throws, `_toolExceptionFailure` returns `_safeFailure(WebMcpNativeReasonCode.handlerFailed)`, which loses even the `invalidArguments` code.
- Evidence: `catch (Object)` block at line 431 calls `_safeFailure`.
- Source: `lib/src/transport/webmcp_native_publisher.dart` lines 430–433; `wiki/product/webmcp-contract.md` line 31

#### F3.14 — Existing tests confirm the exception is thrown but do not inspect its details

- Claim: Existing tests verify `WebMcpInvalidArgumentsException` is thrown for unknown keys, missing required keys, and bad shapes. No test asserts on a `details` map or a field name.
- Evidence: `throwsA(isA<WebMcpInvalidArgumentsException>())` at line 310; `webmcp_public_surface_test.dart` line 64 checks the type exists only.
- Source: `test/registry_test.dart` lines 307–325; `test/webmcp_public_surface_test.dart` line 64

---

### Area 4 — Widget action declared-field decoding

#### F4.1 — `WebMcpAction` registers once in `didChangeDependencies`, guarded by a boolean

- Claim: `_WebMcpActionState.didChangeDependencies` is the registration site. A `_registered` boolean prevents any second call from re-registering.
- Evidence: Lines 76–107 — `if (_registered) return;` is the first line; `scope.addTool(WebMcpTool(...))` is the only registration call; it never runs again.
- Source: `lib/src/widgets/webmcp_action.dart` lines 76–107

#### F4.2 — Descriptor fields are frozen at that single first call

- Claim: `name`, `description`, `inputSchema`, `annotations`, `title`, and `exposedTo` are read from `widget.*` only inside the guarded block that runs once. Later rebuilds cannot alter the registered `WebMcpTool`.
- Evidence: All six descriptor reads happen on lines 92–98, inside the `if (_registered) return;` guard.
- Source: `lib/src/widgets/webmcp_action.dart` lines 88–107

#### F4.3 — Callback closure dispatches to the newest widget callback

- Claim: The registered closure reads `widget.onInvoke` or `widget.onCall` at invocation time, not at mount time. Rebuilding with a new callback is picked up without re-registering.
- Evidence: Lines 99–105 use `widget.onInvoke!(arguments)` and `widget.onCall!(call)` inside arrow lambdas captured at mount; `widget` is a live reference.
- Source: `lib/src/widgets/webmcp_action.dart` lines 99–105; `test/widget_layer_test.dart` lines 110–123

#### F4.4 — `WebMcpAction` has no `fields` parameter today

- Claim: `WebMcpAction` accepts `onInvoke` or `onCall` but has no `fields` parameter. There is no declared-field decoding path in the widget layer.
- Evidence: Constructor signature at lines 16–36 lists no `fields` argument.
- Source: `lib/src/widgets/webmcp_action.dart` lines 16–36

#### F4.5 — `WebMcpTool.withDecodedArguments` wraps `callHandler` only; throws before author callback runs

- Claim: The factory adds a `callHandler` wrapper that calls `webMcpDecodeArguments(fields, call.arguments)` and forwards a `WebMcpToolCall` with the decoded map. Decode failure throws `WebMcpInvalidArgumentsException` before the author callback runs. `handler:` is not passed.
- Evidence: Lines 104–134 of `lib/src/webmcp_tool.dart`. `test/registry_test.dart` lines 291–330 exercise the rejection path.
- Source: `lib/src/webmcp_tool.dart` lines 104–134; `test/registry_test.dart` lines 291–330

#### F4.6 — `WebMcpScreen` provides scope via mixin; `WebMcpAction` finds it via ancestor walk

- Claim: `WebMcpScreen` is a mixin on `State<T>`. It creates `WebMcpScope` in `initState` and closes it in `dispose`. `WebMcpAction` finds the scope via `WebMcpScreen.maybeScopeOf(context)`, which walks ancestor elements.
- Evidence: `lib/src/widgets/webmcp_screen.dart` lines 6–41; `lib/src/widgets/webmcp_action.dart` lines 83–87.
- Source: `lib/src/widgets/webmcp_screen.dart` lines 6–41

#### F4.7 — Unregistration on dispose, conditioned on ownership

- Claim: `dispose` calls `scope.removeTool(_registeredName!)` only when `_ownsTool` is true (a duplicate registration skips ownership).
- Evidence: Lines 111–117 of `lib/src/widgets/webmcp_action.dart`.
- Source: `lib/src/widgets/webmcp_action.dart` lines 111–117

#### F4.8 — `fields` applies only to `onCall`, not `onInvoke`; `inputSchema` and fields remain independent

- Claim: `WebMcpTool.withDecodedArguments` sets only `callHandler`; `handler:` is incompatible with it. If `fields` is provided alongside `onInvoke`, the library must either reject the combination at construction time or silently ignore `fields`. The contract also states declared-field decoding does not read the schema map (`webmcp-contract.md` lines 38–40).
- Evidence: `lib/src/webmcp_tool.dart` lines 104–134; `wiki/product/webmcp-contract.md` lines 38–40.
- Source: `lib/src/webmcp_tool.dart` lines 104–134; `wiki/product/webmcp-contract.md` lines 38–40; `lib/src/widgets/webmcp_action.dart` lines 16–36

---

## Options considered

### Schema from declared fields (Area 1)

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| **A — Status quo: author hand-writes both** | Author supplies `fields` for decoding and a separate `inputSchema` for agents. Library never connects them. | Zero library change. | Rejected: schema and fields can silently disagree; agent sees a description that does not match what the decoder enforces. |
| **B — Derive schema from fields when `inputSchema` is omitted (or empty)** | `withDecodedArguments` inspects `inputSchema`; if empty (the default), builds a JSON schema from the `fields` list using the same shape-to-schema mapping the generator uses. Author can still supply an explicit schema. | Small pure-function derivation at construction time; no registry change. | **Chosen.** Default case becomes consistent automatically. Author override is preserved. Mirrors proven generator pattern. Does not validate at runtime. |
| **C — Always replace supplied schema with a derived one** | `withDecodedArguments` ignores any supplied `inputSchema` and always derives from `fields`. | Same derivation cost; breaks author intent to supply a custom schema. | Rejected: eliminates author ability to provide per-property descriptions, examples, or richer constraints. |

### Generator publication metadata (Area 2)

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| **A — Leave annotation unchanged** | Generated tools permanently lack `title`, `debugging`, `exposedTo`. Authors who need them must hand-write `WebMcpTool`. | Zero change cost now; ongoing per-method boilerplate. | Rejected: gap is mechanical and the missing fields are safe pure metadata. Forces authors to abandon the generator for any tool needing a title or origin filter. |
| **B — Extend `WebMcpDomainAction` with optional `title`, `debugging`, `exposedTo`** | Add three nullable fields to the annotation, update `_readMethod` and `_ExposedMethod` to carry them, update `_emitClass` to emit them when non-null. | One annotation class change, three generator changes, one new generated-code path. | **Chosen.** Single annotation type, minimal surface area, purely additive, does not alter existing usage, does not construct services or grant authorization. |
| **C — Add a second annotation type (e.g., `WebMcpDomainPublication`)** | A separate annotation placed alongside `@WebMcpDomainAction` carries `title`, `debugging`, `exposedTo`. Generator reads both. | Two annotation types to document; generator must merge two annotations per method. | Rejected: splitting one tool descriptor across two annotations increases friction without delivering functionality Option B cannot provide. No semantic reason to separate these fields. |

### Generator decode-error path (Area 3 — generated tools)

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| **Keep `FormatException` (current)** | `_$webMcpInvalid()` throws `FormatException`; generated `_invoke` catches it locally and returns the error map via the handler success path. Browser sees `invalidArguments`. | Zero change cost. Operation logged as `invoked`, not `invocationFailed`. | **Chosen as baseline.** Already surfaces `invalidArguments` to the agent. Semantically inconsistent (a failed invocation is counted as completed) but wire-correct. |
| **Throw `WebMcpInvalidArgumentsException`, remove local catch** | `_$webMcpInvalid()` throws `WebMcpInvalidArgumentsException`; no local catch; publisher's `on WebMcpToolException` branch fires; `_toolExceptionFailure` encodes the same wire JSON. | Requires generator change and regeneration of all `.g.dart` files. Operation logged as `invocationFailed`. | Not rejected — produces identical wire output. Semantically correct (operation recorded as failed). Preferred if operational accuracy matters; not required for agent visibility. |
| **Throw `WebMcpToolException` with a different code** | Handler throws with a non-`invalidArguments` code. Publisher encodes the different code. | Agent sees a different error code. | **Rejected.** Does not produce `invalidArguments`. Breaks agent contract for decode failures. |

### Decode-failure detail payload (Area 3 — manual tools)

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| **Keep empty `invalidArguments` (status quo)** | Throw `const WebMcpInvalidArgumentsException()` with `details: null`. Agent sees code + retryable only. | Zero implementation change. | Rejected: agent cannot distinguish missing key from wrong type; retry guidance is generic. |
| **Add field key + closed reason enum (no value)** | Throw an invalid-arguments exception carrying the failed key and a closed reason of missing, unknown, or type. The publisher serializes those two strings into details. | Throw sites that pass a runtime key cannot themselves be const expressions. The existing const no-argument constructor can stay, because a const constructor may still have optional fields. `_decodeValue` already receives the field. | **Chosen:** gives the agent actionable repair information, leaks no value or message, passes publisher constraints (small fixed-schema map, all strings). |
| **Name the field on the generated return map** | The generator already knows each parameter name at each guard. The returned invalid-arguments map could add the same key and reason without throwing. | Changes the generated envelope that live-instance tests compare as a whole map, and changes every generated file. | Not chosen by this research. Recorded under Unresolved. It is a fourth option beside the three exception-type rows above. |
| **Add the rejected value in details** | Include the caller-supplied raw value alongside the field key. | Same as above plus value serialization. | **Rejected** by shared constraint: do not put the rejected value into the agent-visible error. |

### Widget action declared-field decoding (Area 4)

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| **A — Author decodes in the callback** | `onCall` callback manually calls `webMcpDecodeArguments(fields, call.arguments)` before using arguments. No change to the widget. | Boilerplate in every handler; no library-level guarantee decode runs before the callback. | Rejected. Parity with `WebMcpTool.withDecodedArguments` requires the decode to be a library-enforced step, not an optional author convention. |
| **B — Optional `fields` list captured at first mount** | Add `List<WebMcpInputField>? fields` to `WebMcpAction`. If non-null at first mount, build the registered `WebMcpTool` via `WebMcpTool.withDecodedArguments(... callHandler: (call) => widget.onCall!(call))`, capturing `fields` at mount time. If null, existing behavior is unchanged. | One new optional constructor parameter; a branch in `didChangeDependencies`. `fields` is meaningful only with `onCall`. | **Chosen.** Fields freeze with the descriptor. Newest-callback dispatch is preserved. Descriptor freeze, child rendering, and authorization are untouched. Matches `WebMcpTool.withDecodedArguments` semantics exactly. |
| **C — Separate widget (e.g., `WebMcpDecodedAction`)** | A new stateful widget with the same lifecycle as `WebMcpAction` that requires both `fields` and `onCall`. `WebMcpAction` is unchanged. | New public API surface; authors must choose between two widgets for one conceptual feature. | Rejected. Adding a parameter to an existing widget is less surface area and keeps the registration/lifecycle path in one place. A new widget is justified only if the two have genuinely incompatible invariants, which they do not. |

---

## Constraints discovered

1. **No runtime validation.** The product contract (`wiki/product/webmcp-contract.md` lines 37–38) states that the schema is descriptive and the registry performs no runtime JSON Schema validation. Any schema derivation must happen at construction time only.

2. **Schema is a shallow-copied, unmodifiable outer map.** `WebMcpTool`'s constructor wraps the outer map in `UnmodifiableMapView` but leaves nested values shared (`lib/src/webmcp_tool.dart` lines 86–88). A derived schema whose nested objects come from a pure derivation function has no shared-state risk.

3. **The generator already emits safe-integer bounds and a number type for doubles.** `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart` lines 554–559 emit an integer schema with the decoder's inclusive bounds and a number schema for a double. A manual derivation that matches the generator uses those same fragments.

4. **`fields` is not stored on the `WebMcpTool` descriptor.** The public `WebMcpTool` class has no `fields` property; the field list is captured only inside the `callHandler` closure (`lib/src/webmcp_tool.dart` lines 122–130). Schema derivation must happen during the `withDecodedArguments` factory call, not later.

5. **`allowedNames` for enumeration fields must appear in the schema `enum` array.** This is already the generator pattern (`webmcp_domain_action_generator.dart` line 562).

6. **`nullable` fields need a schema representation.** The generator wraps a nullable schema in `anyOf` with a null type at `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart` line 577. It does not emit `oneOf`.

7. **Annotation must remain `const`-constructible.** New optional fields must have `null` defaults and must be `final` (`packages/webmcp_flutter_annotations/lib/webmcp_flutter_annotations.dart` lines 10–17).

8. **`exposedTo` on `WebMcpTool` is `List<String>?`.** A null list means omit; an empty list is a different (probably unintended) state. The annotation field must likewise be nullable.

9. **Generator must use `annotation.peek(…)`, not `annotation.read(…)`, for optional fields.** `peek` returns null when the field is absent or set to null; `read` throws.

10. **`debugging` lives inside `WebMcpToolAnnotations`, not on `WebMcpTool` directly.** The generator emits `const WebMcpToolAnnotations(…)`. Adding `debugging` requires changing the annotations literal, not the outer tool constructor.

11. **Publisher code regex `^[A-Za-z0-9_.-]{1,64}$`.** `error.code` must satisfy this or the whole response downgrades to `handlerFailed`. `"invalidArguments"` passes. (`lib/src/transport/webmcp_native_publisher.dart` line 414)

12. **Publisher details size limit: 64 KB.** A two-key string map is orders of magnitude below the limit. (`lib/src/transport/webmcp_native_publisher.dart` lines 14, 505–510)

13. **No value, message, or stack in details.** The product contract and the shared constraints forbid echoing the caller input, a free-form message, or a stack. Only a closed enum and an allowlisted key may appear.

14. **A runtime key cannot appear in a const throw expression.** `WebMcpToolException` at `lib/src/webmcp_exceptions.dart` lines 50–54 is already a const constructor with an optional details field. Adding a key does not require removing const from the no-argument constructor. A throw that passes a key known only at runtime cannot itself be a const expression.

15. **Generator `FormatException` catch is inside every `_invoke` method.** Any change to the exception type requires regenerating all `.g.dart` files; hand-edited generated files would diverge.

16. **`fields` applies only to `onCall`, not `onInvoke`.** `WebMcpTool.withDecodedArguments` sets only `callHandler`; `handler:` is incompatible with it. `fields` combined with `onInvoke` must be rejected or silently ignored by the widget.

17. **Fields list is immutable at mount.** Rebuilding `WebMcpAction` with a different `fields` list has no effect, exactly as rebuilding with a new `description` has no effect.

18. **A details value outside publisher limits becomes the existing handler-failed object,** losing even the `invalidArguments` code.

---

## Unresolved

- [UNRESOLVED: What schema fragment should a manual derivation emit for a list or map field whose child is absent, and for an enumeration whose allowed-names list is empty? The generator never builds those inputs.]
- [UNRESOLVED: Whether the generated invalid-argument return should name the failed field and a closed reason. The generated path currently returns an envelope with a code and a retryable flag only. Emitting the parameter name into that map is a separate option from changing the exception type, and this research does not close it.]
- [UNRESOLVED: What is the correct Dart annotation field type to hold a `List<String>?` that is declared `const`? A const list literal is allowed, but a null default combined with a nullable type must be verified against `source_gen`'s `ConstantReader` list-reading API for the generator side.]
- [UNRESOLVED: Whether the operation-tracker semantic difference (completed vs handlerFailed) between the generated `FormatException` route and a thrown `WebMcpInvalidArgumentsException` route matters to any existing consumer or diagnostic surface. The research scope excludes this decision.]
- [UNRESOLVED: What exact Dart identifier should the reason enum use? `DecodeFailureReason`, `WebMcpDecodeFailureReason`, or something else? The naming convention for package-public enums has not been checked for this work item.]
- [UNRESOLVED: Should the `field` property on the exception be surfaced as part of the public API contract documented in `webmcp-contract.md`, or only through the wire `details` map? This affects what must be frozen before implementation.]
- [UNRESOLVED: Should `fields` paired with `onInvoke` be a hard `ArgumentError` at construction time, or is there a use case for decoding before a one-argument handler?]
- [UNRESOLVED: Should the public `WebMcpAction` constructor accept `List<WebMcpInputField>` directly, or should it accept an already-built decoder closure to remain agnostic of `WebMcpInputField`?]

---

## Sources

| Source | Consulted | Contributed to |
|---|---|---|
| `lib/src/webmcp_tool.dart` | 2026-10-02 | F1.1, F1.7, F2.8, F4.5, F4.8 |
| `lib/src/webmcp_typed_input.dart` | 2026-10-02 | F1.2, F1.6, F3.1, F3.12 |
| `lib/src/webmcp_exceptions.dart` | 2026-10-02 | F3.1, F3.5, F3.6, F3.7, F3.8 |
| `lib/src/transport/webmcp_native_publisher.dart` | 2026-10-02 | F3.5, F3.6, F3.7, F3.8, F3.9, F3.10, F3.13 |
| `lib/src/widgets/webmcp_action.dart` | 2026-10-02 | F4.1, F4.2, F4.3, F4.4, F4.7, F4.8 |
| `lib/src/widgets/webmcp_screen.dart` | 2026-10-02 | F4.6 |
| `packages/webmcp_flutter_annotations/lib/webmcp_flutter_annotations.dart` | 2026-10-02 | F2.1, F2.7 |
| `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart` | 2026-10-02 | F1.4, F1.6, F1.7, F2.2, F2.5, F2.6, F2.7, F3.2, F3.3 |
| `example/lib/example_counter_source.dart` | 2026-10-02 | F1.5 |
| `example/lib/example_task_service.webmcp.g.dart` | 2026-10-02 | F1.5, F2.3, F3.4 |
| `packages/webmcp_flutter_generator/example/lib/inventory_service.webmcp.g.dart` | 2026-10-02 | F2.3, F3.4 |
| `wiki/product/webmcp-contract.md` | 2026-10-02 | F1.3, F1.7, F2.4, F3.11, F4.8 |
| `README.md` lines 582–587 | 2026-10-02 | F1.3 |
| `test/registry_test.dart` lines 291–330, 307–325 | 2026-10-02 | F3.14, F4.5 |
| `test/webmcp_public_surface_test.dart` line 64 | 2026-10-02 | F3.14 |
| `test/widget_layer_test.dart` lines 110–123 | 2026-10-02 | F4.3 |
| `example/test/example_task_service_test.dart` lines 86–98 | 2026-10-02 | F3.6 |
| `packages/webmcp_flutter_generator/example/test/live_instance_test.dart` lines 49–58 | 2026-10-02 | F3.6 |

---

## Provenance

Which input file contributed which section of this merged artifact:

| Input file | Contributed |
|---|---|
| `wiki/work/0018-author-argument-dx/research/schema-from-fields.md` | Area 1 all findings (F1.1–F1.7); Area 1 options A/B/C; Constraints 1–6; Unresolved items 1–3 |
| `wiki/work/0018-author-argument-dx/research/generator-publication-metadata.md` | Area 2 all findings (F2.1–F2.8); Area 2 options A/B/C; Constraints 7–10; Unresolved item 4 |
| `wiki/work/0018-author-argument-dx/research/generator-argument-errors.md` | Area 3 generated-path findings (F3.2–F3.4, F3.6–F3.7 generated path, F3.11); Area 3 generated-tool options; Constraints 11, 15; Unresolved item 5 |
| `wiki/work/0018-author-argument-dx/research/invalid-argument-details.md` | Area 3 manual-path findings (F3.1, F3.5, F3.6–F3.8 manual path, F3.9–F3.14); Area 3 manual-tool options; Constraints 11–14, 18; Unresolved items 6–7 |
| `wiki/work/0018-author-argument-dx/research/action-decoded-fields.md` | Area 4 all findings (F4.1–F4.8); Area 4 options A/B/C; Constraints 16–17; Unresolved items 8–9 |
