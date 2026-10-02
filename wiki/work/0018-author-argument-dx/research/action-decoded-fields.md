# Research: How WebMcpAction registers for its mounted lifetime, and which option gives it declared-field decoding matching WebMcpTool.withDecodedArguments

## Question

How does `WebMcpAction` register a tool for its mounted lifetime, and which option gives a widget action the same declared-field decoding as `WebMcpTool.withDecodedArguments` without changing descriptor freeze, child rendering, or authorization?

## Answer

`WebMcpAction` registers exactly once in `didChangeDependencies`, guarded by a `_registered` boolean, by calling `scope.addTool(WebMcpTool(...))` with the descriptor fields frozen at that moment. The handler closure always dispatches to the *current* `widget.onInvoke` or `widget.onCall` at call time. The cleanest option that matches `WebMcpTool.withDecodedArguments` without touching descriptor freeze, child rendering, or authorization is Option B: add an optional `fields` list that is captured at first mount and wraps the registered `callHandler` with `webMcpDecodeArguments` exactly as the factory does, while the closure still forwards to the newest `widget.onCall`.

## Findings

### Registration mechanism: didChangeDependencies, guarded boolean

- Claim: `_WebMcpActionState.didChangeDependencies` is the registration site. A `_registered` boolean prevents any second call from re-registering.
- Evidence: Lines 76–107 of `lib/src/widgets/webmcp_action.dart` — `if (_registered) return;` is the first line; `scope.addTool(WebMcpTool(...))` is the only registration call; it never runs again.
- Source: `lib/src/widgets/webmcp_action.dart:76–107`

### Descriptor fields are frozen at that single first call

- Claim: `name`, `description`, `inputSchema`, `annotations`, `title`, and `exposedTo` are read from `widget.*` only inside the guarded block that runs once. Later rebuilds cannot alter the registered `WebMcpTool`.
- Evidence: All six descriptor reads happen on lines 92–98, inside the `if (_registered) return;` guard.
- Source: `lib/src/widgets/webmcp_action.dart:88–107`

### Callback closure dispatches to the newest widget callback

- Claim: The registered closure reads `widget.onInvoke` or `widget.onCall` at invocation time, not at mount time. Rebuilding with a new callback is picked up without re-registering.
- Evidence: Lines 99–105 use `widget.onInvoke!(arguments)` and `widget.onCall!(call)` inside arrow lambdas captured at mount; `widget` is a live reference to the current widget.
- Source: `lib/src/widgets/webmcp_action.dart:99–105`; confirmed by `widget_layer_test.dart:110–123` ("action forwards invocation to the latest callback").

### Unregistration on dispose, conditioned on ownership

- Claim: `dispose` calls `scope.removeTool(_registeredName!)` only when `_ownsTool` is true (i.e., the scope accepted the registration — a duplicate skips ownership).
- Evidence: Lines 111–117 of `lib/src/widgets/webmcp_action.dart`.
- Source: `lib/src/widgets/webmcp_action.dart:111–117`

### WebMcpTool.withDecodedArguments wraps callHandler only

- Claim: The factory adds a `callHandler` wrapper that calls `webMcpDecodeArguments(fields, call.arguments)` and forwards a `WebMcpToolCall` with the decoded map. It never sets `handler`. Decode failure throws `WebMcpInvalidArgumentsException` before the author callback runs.
- Evidence: Lines 104–134 of `lib/src/webmcp_tool.dart`. The returned `WebMcpTool` passes `callHandler:` with the wrapping lambda; `handler:` is not passed.
- Source: `lib/src/webmcp_tool.dart:104–134`; `test/registry_test.dart:291–330` exercises the rejection path.

### WebMcpAction has no fields parameter today

- Claim: `WebMcpAction` accepts `onInvoke` or `onCall` but has no `fields` parameter. There is no declared-field decoding path in the widget layer.
- Evidence: The constructor signature at lines 16–36 of `lib/src/widgets/webmcp_action.dart` lists no `fields` argument.
- Source: `lib/src/widgets/webmcp_action.dart:16–36`

### WebMcpScreen provides the scope via mixin, not inheritance

- Claim: `WebMcpScreen` is a mixin on `State<T>`. It creates `WebMcpScope` in `initState` and closes it in `dispose`. `WebMcpAction` finds the scope via `WebMcpScreen.maybeScopeOf(context)`, which walks ancestor elements.
- Evidence: `lib/src/widgets/webmcp_screen.dart:6–41`; `lib/src/widgets/webmcp_action.dart:83–87`.
- Source: `lib/src/widgets/webmcp_screen.dart:6–41`

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| A — author decodes in the callback | `onCall` callback manually calls `webMcpDecodeArguments(fields, call.arguments)` before using arguments. No change to the widget. | Boilerplate in every handler; author must remember the call; no library-level guarantee decode runs before the callback. | Rejected. Parity with `WebMcpTool.withDecodedArguments` requires the decode to be a library-enforced step, not an optional author convention. |
| B — optional `fields` list captured at first mount | Add `List<WebMcpInputField>? fields` to `WebMcpAction`. If non-null at first mount, build the registered `WebMcpTool` via `WebMcpTool.withDecodedArguments(... callHandler: (call) => widget.onCall!(call))`, capturing `fields` at mount time. The callback closure still forwards to the newest `widget.onCall` at call time. If null, existing behaviour is unchanged. | One new optional constructor parameter; a branch in `didChangeDependencies`; `fields` is meaningful only with `onCall` (see Constraints). | **Chosen.** Fields freeze with the descriptor (mount-time capture). The newest-callback dispatch is preserved. Descriptor freeze, child rendering, and authorization are untouched. Matches `WebMcpTool.withDecodedArguments` semantics exactly. |
| C — separate widget (e.g., `WebMcpDecodedAction`) | A new stateful widget with the same lifecycle as `WebMcpAction` that requires both `fields` and `onCall`. `WebMcpAction` is unchanged. | New public API surface and documentation; authors must choose between two widgets for what is conceptually one feature; cannot easily migrate by adding a parameter. | Rejected. Adding a parameter to an existing widget is less surface area and keeps the registration/lifecycle path in one place. A new widget is justified only if the two have genuinely incompatible invariants, which they do not. |

## Constraints discovered

- **`fields` applies only to `onCall`, not `onInvoke`**: `WebMcpTool.withDecodedArguments` sets only `callHandler`; `handler` is incompatible with it. If `fields` is provided alongside `onInvoke`, the library must either reject the combination at construction time or silently ignore `fields`. Rejecting is safer.
- **Fields list is immutable at mount**: consistent with the broader freeze rule. Rebuilding `WebMcpAction` with a different `fields` list has no effect, exactly as rebuilding with a new `description` has no effect.
- **`webMcpDecodeArguments` throws `WebMcpInvalidArgumentsException`**: this propagates to the caller before the author callback runs, matching the behaviour documented in the product contract (`webmcp-contract.md:38–39`).
- **`WebMcpScope.addTool` accepts only one `WebMcpTool`**: the branch in `didChangeDependencies` must produce either a plain `WebMcpTool` or a `WebMcpTool` from the factory; both paths converge to a single `addTool` call.
- **`inputSchema` and `fields` are independent**: the contract states declared-field decoding does not read the schema map (`webmcp-contract.md:38–40`). Authors still supply `inputSchema` separately for browser-agent consumption.

## Unresolved

- [UNRESOLVED: Should `fields` paired with `onInvoke` be a hard `ArgumentError` at construction time, or is there a use case for decoding before a one-argument handler?]
- [UNRESOLVED: Should the public constructor accept `List<WebMcpInputField>` directly, or should it accept an already-built decoder closure to remain agnostic of `WebMcpInputField`?]

## Sources

| Source | Date consulted |
|---|---|
| `lib/src/widgets/webmcp_action.dart` (lines 1–120) | 2026-10-02 |
| `lib/src/webmcp_tool.dart` (lines 1–163) | 2026-10-02 |
| `lib/src/webmcp_typed_input.dart` (lines 1–155) | 2026-10-02 |
| `lib/src/widgets/webmcp_screen.dart` (lines 1–41) | 2026-10-02 |
| `wiki/product/webmcp-contract.md` (Flutter lifecycle and Deliberate omissions sections) | 2026-10-02 |
| `test/widget_layer_test.dart` (lines 62–340) | 2026-10-02 |
| `test/registry_test.dart` (lines 291–330) | 2026-10-02 |
