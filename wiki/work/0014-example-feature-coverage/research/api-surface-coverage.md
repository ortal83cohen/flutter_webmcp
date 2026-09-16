# Research: example app coverage of the `webmcp_flutter` public API surface

## Question

For every public feature exported by `webmcp_flutter` (via `lib/webmcp_flutter.dart`), does `example/lib/*.dart` (and `example/test/*.dart`) exercise it fully, partially, or not at all?

## Answer

The example app exercises the "happy path" of the manual-tool registry, the `WebMcpScreen`/`WebMcpAction` widget lifecycle, one automatic `WebMcpPage`, one `WebMcpNavigatorAdapter`, and the native publisher's attach/detach and top-level status fields. It does not exercise error handling (`WebMcpException` family), the observer API, custom transports, tool sources (`WebMcpToolSource`, `registerSource`/`addSource`/`WebMcpPage.sources`), tool annotations, page-policy customization (bounds, editable text, long press), page-limit customization, or most of `WebMcpAppSession`'s diagnostic surface. Roughly a third of the exported public declarations have no exercise at all in `example/`.

## Findings

All line numbers below are current as of this research (repository at `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`, `main` branch, commit `5601815`).

### Export barrel

- Claim: `webmcp_flutter.dart` re-exports whole files for the registry, tool, tool-source, scope, exception, action-widget and screen-mixin modules (no `show`/`hide`), and a curated `show` list for the page-lifecycle module.
- Evidence: `export 'src/webmcp.dart';`, `export 'src/webmcp_tool.dart';`, `export 'src/webmcp_tool_source.dart';`, `export 'src/webmcp_scope.dart';`, `export 'src/webmcp_exceptions.dart';`, `export 'src/widgets/webmcp_action.dart';`, `export 'src/widgets/webmcp_screen.dart';`, `export 'src/transport/webmcp_native_capabilities.dart';`, `export 'src/transport/webmcp_native_publisher.dart';`, `export 'src/transport/webmcp_transport.dart';`, plus `export 'src/page/page.dart';` which itself re-exports a `show` list.
- Source: `lib/webmcp_flutter.dart:1-11`, `lib/src/page/page.dart:4-15`.

### `native_publisher_boundary*.dart` is not part of the public surface

- Claim: `WebMcpNativeBoundary`, `WebMcpNativeReasonCode`, `WebMcpNativeInvocationContext`, `WebMcpNativeRegistration`, `WebMcpNativeBoundaryException`, and `createWebMcpNativeBoundary` are declared in `lib/src/transport/native_publisher_boundary.dart` but that file is never exported from `lib/webmcp_flutter.dart`.
- Evidence: no `export` line references `native_publisher_boundary.dart`, `native_publisher_boundary_web.dart`, `native_publisher_boundary_noop.dart`, or `native_publisher_boundary_selector.dart`.
- Source: `lib/webmcp_flutter.dart:1-11`; declarations at `lib/src/transport/native_publisher_boundary.dart:1-83`.
- These are excluded from the coverage table below because they are not public API of the package (the objective asked to "read" them, which is done here, but they cannot appear as an example-app gap since a consumer cannot import them).

### Example app inventory

- Claim: the example app is exactly three `lib` files and one test file; there is no widget test.
- Evidence: `example/lib/main.dart`, `example/lib/example_screen.dart`, `example/lib/example_tools.dart`; `example/test/example_tools_test.dart` is the only test and it only exercises `registerExampleTools`/`WebMcp.instance.tools`/`invokeTool`/`reset`.
- Source: `Glob` over `example/lib/*.dart` and `example/test/*.dart` (session tool output); `example/test/example_tools_test.dart:1-23`.

## Coverage table

| Feature | Source location | Covered in example? | What's missing |
|---|---|---|---|
| `WebMcp.instance` singleton | `lib/src/webmcp.dart:56` | yes | — |
| `WebMcp.registerTool` | `lib/src/webmcp.dart:88` | yes | `example/lib/example_tools.dart:16,23` register two tools directly |
| `WebMcp.registerSource` (`WebMcpToolSource` batch registration) | `lib/src/webmcp.dart:104` | no | No `WebMcpToolSource` implementation exists in `example/`; never called |
| `WebMcp.unregisterTool` | `lib/src/webmcp.dart:111` | no | Never called directly; only exercised transitively through `WebMcpScope.close()`/widget dispose, never as a standalone demonstrated call, and its `bool` return is never inspected |
| `WebMcp.tools` getter | `lib/src/webmcp.dart:125` | yes | `example/lib/example_screen.dart:45`, `example/test/example_tools_test.dart:12` |
| `WebMcp.invokeTool` | `lib/src/webmcp.dart:134` | yes (test only) | Only exercised in `example/test/example_tools_test.dart:17`; never invoked from the running app UI (tools are invoked in-process via `WebMcpAction.onInvoke`, not through the registry's `invokeTool`); the `WebMcpToolNotFoundException` path is never triggered |
| `WebMcp.reset()` (default transport) | `lib/src/webmcp.dart:150` | yes (test only) | `example/test/example_tools_test.dart:6` (`setUp`) |
| `WebMcp.reset(transport)` (explicit custom transport) | `lib/src/webmcp.dart:150` | no | No call anywhere passes a transport argument to `reset` |
| `WebMcp.transportId` | `lib/src/webmcp.dart:175` | yes | `example/lib/example_screen.dart:58` displays it, but only the platform default id (`noop`/`web-detection`) is ever seen — see next row |
| `WebMcp.addRegistryObserver` / `WebMcpRegistryObserver` / `WebMcpRegistrySubscription` | `lib/src/webmcp.dart:73`, `:10`, `:19` | no | No observer is ever registered or implemented in `example/` |
| `WebMcpRegistryResetObserver` | `lib/src/webmcp.dart:44` | no | Never implemented; only exercised internally by `WebMcpNativePublisher`'s own observer, which the example never inspects |
| `WebMcpTool` descriptor (`name`, `description`, `handler`) | `lib/src/webmcp_tool.dart:32-58` | yes | `example/lib/example_tools.dart:16-27`, `example/lib/example_screen.dart:31-36` |
| `WebMcpTool.inputSchema` | `lib/src/webmcp_tool.dart:37,40-42,51` | no | Every `WebMcpTool`/`WebMcpAction` in `example/` uses the default empty schema; the unmodifiable-shallow-copy behavior is never exercised |
| `WebMcpToolAnnotations` (`readOnlyHint`, `untrustedContentHint`, `consequentialHint`) | `lib/src/webmcp_tool.dart:13-29` | no | Never instantiated; every `WebMcpTool` in `example/` uses the default `const WebMcpToolAnnotations()` |
| `WebMcpToolSource` interface | `lib/src/webmcp_tool_source.dart:4-7` | no | No custom implementation in `example/` |
| `WebMcpScope` (`addTool`, `addSource`, `removeTool`, `ownedNames`, `skippedNames`, `close`) | `lib/src/webmcp_scope.dart:10-89` | partial | `addTool` is used only through `WebMcpScreen.mcpScope.addTool` (`example/lib/example_screen.dart:30`); direct `WebMcpScope(...)` construction, `addSource`, `removeTool`, `ownedNames`, `skippedNames`, and the duplicate-name skip path (`WebMcpDuplicateToolException` swallow) are never exercised |
| `WebMcpScreen<T>` mixin, `registerWebMcpTools()` | `lib/src/widgets/webmcp_screen.dart:6-41` | yes | `example/lib/example_screen.dart:18-19,29-36` |
| `WebMcpScreen.maybeScopeOf` | `lib/src/widgets/webmcp_screen.dart:13-23` | yes (indirect only) | Only exercised transitively when `WebMcpAction` looks up its enclosing scope (`lib/src/widgets/webmcp_action.dart:56`); never called directly by example code |
| `WebMcpAction` widget | `lib/src/widgets/webmcp_action.dart:11-82` | partial | `example/lib/example_screen.dart:68-79` uses it with an empty `inputSchema`; the "no enclosing `WebMcpScreen`" error path (`WebMcpScopeMissingException`) is never triggered; unmount/remount behavior is never exercised (the action is mounted once and lives for the screen's lifetime) |
| `WebMcpException` / `WebMcpInvalidToolNameException` / `WebMcpDuplicateToolException` / `WebMcpToolNotFoundException` / `WebMcpScopeMissingException` | `lib/src/webmcp_exceptions.dart:1-46` | no | None of the five exception types is ever thrown, caught, or asserted anywhere in `example/lib` or `example/test` |
| `WebMcpAppSession` — `attach`/`detach` | `lib/src/page/webmcp_app_session.dart:157,187` | yes | `example/lib/main.dart:10-11,52` |
| `WebMcpAppSession` custom `limits`/`viewProvider`/`clock` constructor params | `lib/src/page/webmcp_app_session.dart:52-58` | no | `example/lib/main.dart:10` uses the no-arg constructor only; no custom `WebMcpPageLimits` or `WebMcpViewProvider` is ever supplied |
| `WebMcpAppSession` diagnostics (`isAttached`, `ownsObserveTool`, `appMount`, `liveScopeCount`, `navigatorAdapterCount`, `routeEvidenceReady`, `retainedEventCount`, `retainedOperationCount`, `outstandingExecutionCount`) | `lib/src/page/webmcp_app_session.dart:92-152` | no | None of these getters is read or displayed anywhere in `example/` |
| `WebMcpAppSession` `<appId>.app.observe` tool (cursor/wait/scope filtering, gap/partial/refresh semantics) | `lib/src/page/webmcp_app_session.dart:370-494` | no | The tool is registered (as a side effect of `attach`) but never invoked by `example/` code or tests; none of the observe response fields are exercised |
| `WebMcpAppSession.beginOperation`/`recordEvidence`/`confirmBackend`/`operationReceipt` | `lib/src/page/webmcp_app_session.dart:262-323` | no (indirect only) | Exercised internally whenever `WebMcpPage._act` dispatches, but the example never inspects an operation receipt or calls `confirmBackend` for a domain-tool source (no source is attached at all — see `WebMcpToolSource` row) |
| `WebMcpNavigatorAdapter` — basic construction + `dispose` | `lib/src/page/webmcp_app_session.dart:642-848` | partial | `example/lib/main.dart:37-46,51` constructs exactly one root adapter with `rootModalRelationship: true` and disposes it; `parentNavigatorId`, `persistentParallelBranch`, and `selectedBranch` (nested/parallel Navigator support) are never demonstrated; `markTransitionUnknown` is only reachable via framework callbacks (`didRemove`, `didStartUserGesture`), never directly observed or asserted |
| `WebMcpPage` — `pageId`, default `policy`, default `sources` | `lib/src/page/webmcp_page.dart:19-60` | partial | `example/lib/example_screen.dart:48-49,104-105` create two pages (`example.home`, `example.details`) with only `pageId` set; `policy`, `activity`, and `sources` constructor parameters are never supplied |
| `WebMcpPage` — `.page.read` tool | `lib/src/page/webmcp_page.dart:569-597,693-856` | no (only indirect via Semantics) | The endpoint is registered but never invoked through `WebMcp.instance.invokeTool` or the native publisher in any test; pagination (`cursor`/`limit`), `roles`/`actions`/`query` filtering, and the byte-budget truncation path are unexercised |
| `WebMcpPage` — `.page.act` tool (tap/scroll/increase/decrease/setText/longPress) | `lib/src/page/webmcp_page.dart:920-1103` | no (only indirect via UI taps) | A human tapping the "Increment"/"Open details"/"Return home" buttons in a running app would exercise `tap` end-to-end, but there is no automated test that calls `.page.act`, checks revalidation, staleness, duplicate-request idempotency, or the receipt shape; `setText`, `longPress`, `increase`, `decrease`, and scroll actions are entirely unexercised (the example screen has no text field, no long-pressable widget, and no scrollable content) |
| `WebMcpPage.sources` (attached `WebMcpToolSource` list) | `lib/src/page/webmcp_page.dart:26,44-45,601-667` | no | Always the default empty list in `example/` |
| `WebMcpPagePolicy` customization (`allowLongPress`, `includeBounds`, `includeNonEditableValues`, `maxTextLength`, `excludedSemanticsIdentifiers`, `sensitiveSemanticsIdentifiers`, `editableValueIdentifiers`, `setTextIdentifiers`) | `lib/src/page/webmcp_page_protocol.dart:245-303` | no | Every `WebMcpPage` in `example/` uses `WebMcpPagePolicy.defaults`; none of the eight configurable fields is ever set to a non-default value |
| `WebMcpPageLimits` customization | `lib/src/page/webmcp_page_protocol.dart:128-242` | no | Never constructed with non-default arguments anywhere in `example/` |
| `WebMcpPageErrorCode` / `webMcpPageError` / `webMcpPageSuccess` | `lib/src/page/webmcp_page_protocol.dart:10-89` | no | These are return-value shapes of the page/session tools; since those tools are never invoked directly in `example/`, no error code or success envelope is ever inspected |
| `WebMcpViewProvider` / `WebMcpBindingViewProvider` / `WebMcpViewBinding` | `lib/src/page/webmcp_view_provider.dart:1-42` | no (default only) | `WebMcpAppSession` always falls back to `const WebMcpBindingViewProvider()`; no custom `WebMcpViewProvider` is ever supplied, and the multi-view / zero-view rejection paths are never demonstrated |
| `WebMcpTransport` interface | `lib/src/transport/webmcp_transport.dart:4-13` | no | No custom implementation exists in `example/`; only the package-selected platform default (`NoopTransport`/`WebDetectionTransport`) is ever active, and it is never swapped in explicitly via `reset(transport)` |
| Platform default transport selection (`NoopTransport` / `WebDetectionTransport`) | `lib/src/transport/transport_selector.dart:1`, `transport_noop.dart:5-20`, `transport_web.dart:11-48` | yes (as ambient default, not as an explicit feature) | `transportId` is displayed (`example/lib/example_screen.dart:58`), but this is incidental to using `WebMcp.instance` — no example code chooses or configures a transport |
| `WebMcpNativePublisher` — `attach`/`detach` | `lib/src/transport/webmcp_native_publisher.dart:154,176,209` | yes | `example/lib/main.dart:12-13,53` |
| `WebMcpNativePublisher({registry: ...})` custom registry | `lib/src/transport/webmcp_native_publisher.dart:156-159` | no | `example/lib/main.dart:12` uses the no-arg constructor (process-wide registry) only |
| `WebMcpNativePublisher.status` → `WebMcpNativePublisherStatus` | `lib/src/transport/webmcp_native_publisher.dart:226-254`, status class at `:32-74` | partial | `example/lib/example_screen.dart:59,61-63` reads only `status.support.name` and `status.capabilities.positiveWait`; `publishedToolCount`, `skippedToolCount`, `retainedOperationCount`, `outstandingExecutionCount`, `reasonCodes`, and `toDiagnosticMap()` are never displayed or asserted |
| `WebMcpNativeCapabilities` (`registrationSignalCleanup`, `cancelBeforeDispatch`, `invocationCancellationAfterCallbackStart`, `positiveWait`, `toDiagnosticMap`) | `lib/src/transport/webmcp_native_capabilities.dart:2-58` | partial | Only `positiveWait` is read (`example/lib/example_screen.dart:62`); the other three fields and `toDiagnosticMap()` are never shown |
| `WebMcpNativeSupport` enum (`localOnly`, `browserDetected`, `conformanceUsable`, `failed`) | `lib/src/transport/webmcp_native_capabilities.dart:64-76` | partial | Only `.name` is interpolated into a string (`example/lib/example_screen.dart:59`); no example code branches on or explains the individual enum values |

## Gaps ranked by importance to demonstrate

1. **`WebMcpToolSource` / `registerSource` / `WebMcpScope.addSource` / `WebMcpPage.sources`.** This is the package's primary extensibility seam for "generated domain actions" per the product contract, and it is completely absent from the example. A pilot user has no worked example of attaching a reusable tool source to a screen or a page.
2. **Error handling (`WebMcpException` family).** None of `WebMcpInvalidToolNameException`, `WebMcpDuplicateToolException`, `WebMcpToolNotFoundException`, or `WebMcpScopeMissingException` is ever triggered or caught. A consumer copying the example has no template for the registry's actual failure contract (duplicate names, missing scope, etc.), which the product contract treats as a first-class, deterministic behavior.
3. **Custom `WebMcpTransport` and `reset(transport)`.** The objective specifically calls this out, and it is entirely undemonstrated — the example only ever displays whatever platform default transport id is active.
4. **`WebMcpPagePolicy` customization, especially `setText`/`allowLongPress`.** The example's only interactive elements are a counter button and navigation buttons (`tap` only). None of `setText`, `longPress`, `increase`/`decrease`, or scroll actions from `.page.act` is reachable, so the richest part of the automatic-page action surface is silent.
5. **`addRegistryObserver` / `WebMcpRegistryObserver` / `WebMcpRegistryResetObserver`.** The observer pattern that `WebMcpNativePublisher` itself relies on internally is never shown as something a consumer can also use.
6. **`WebMcpToolAnnotations` and `WebMcpTool.inputSchema`.** Every tool in the example uses defaults for both, so the schema/hint machinery that a real MCP consumer would rely on is never illustrated.
7. **`WebMcpAppSession` diagnostics and the `.app.observe`/`.page.read`/`.page.act` tools as directly invokable endpoints.** They are only exercised as a side effect of manual UI interaction in a running app; there is no automated demonstration (test or example code) of calling them and reading the response shape.
8. **`WebMcpNativePublisherStatus`/`WebMcpNativeCapabilities` full diagnostics.** Only two of roughly ten available diagnostic fields are surfaced in the UI.
9. **`WebMcpViewProvider` and `WebMcpPageLimits`/`WebMcpAppSession` custom-constructor injection.** Lower priority — these are advanced/test-seam features, and defaults are reasonable for a pilot app, but they remain entirely undemonstrated.
10. **Nested/parallel `WebMcpNavigatorAdapter` usage (`parentNavigatorId`, `persistentParallelBranch`, `selectedBranch`).** Lower priority given the example's single-Navigator structure, but if the example ever adds tabs or nested navigators this gap would immediately matter.

## Deliberate omissions (excluded from the gap list above per `wiki/product/webmcp-contract.md`)

The following are explicitly listed under "Deliberate omissions" in `wiki/product/webmcp-contract.md:146-153` and are therefore **not** flagged as gaps even though the example does not exercise them:

- Multiple-Flutter-view operation (relevant to `WebMcpViewProvider`/`WebMcpAppSession` view-count handling).
- Positive observation waits (relevant to `WebMcpPageLimits.maxWaitMs`, `.app.observe`'s `waitMs` argument, and `WebMcpNativeCapabilities.positiveWait`, which the example does display as always `false`).
- Generated route wrapping, generalized service proxies, framework-specific state adapters, and custom data providers (relevant to the separate `webmcp_flutter_generator` package, out of this research's scope per the delegation boundary).
- Chrome web platform-back-gesture support.
- In-flight callback termination (relevant to `WebMcpNativeCapabilities.invocationCancellationAfterCallbackStart`, fixed `false`).
- Deep schema immutability (relevant to `WebMcpTool.inputSchema`'s documented shallow-copy behavior).
- Transactional source registration and notification rollback (relevant to `WebMcp.registerSource` and custom-transport exception behavior).
- Automatic cleanup of custom transports on `reset()` (relevant to `WebMcpTransport`/`WebMcp.reset`; note this only excuses the *auto-cleanup* behavior from being a gap — using a custom transport at all, ranked gap #3 above, is a separate, undelivered demonstration and is not on this omissions list).
- Non-web product support.

## Constraints discovered

- `lib/src/transport/native_publisher_boundary*.dart` declarations are not reachable from `package:webmcp_flutter/webmcp_flutter.dart` at all, so they cannot be a "missing example coverage" item — there is nothing for a consumer to call.
- The example app has zero widget tests. The only test (`example/test/example_tools_test.dart`) covers exactly the imperative-tool registry path (`registerTool`, `tools`, `invokeTool`, `reset`) and nothing about widgets, pages, sessions, navigator adapters, or the native publisher.
- Several "coverage" instances in the running app (e.g. tapping "Increment", pushing/popping the details route) would exercise `WebMcpAction`'s handler and `WebMcpNavigatorAdapter`'s `didPush`/`didPop` callbacks *if a human runs the app*, but this is not automated and not asserted anywhere, so it is marked "indirect only" or "no" in the table rather than "yes".

## Unresolved

- [UNRESOLVED: Whether the `webmcp_flutter_generator` package (referenced in `wiki/product/webmcp-contract.md:90-101` as "Generated domain actions") has its own example coverage; that generator's exports were out of this research's stated boundary (`webmcp_flutter` package only) and were not investigated.]
- [UNRESOLVED: Whether there is a separate, unreviewed manual/exploratory test plan for the example app (e.g. a QA checklist outside `wiki/` and `example/`) that exercises the UI-only paths (tap, navigate) not covered by automated tests. No such document was found under `wiki/` during this research, but the search was limited to the repository.]

## Sources

- `lib/webmcp_flutter.dart` — read 2026-09-15.
- `lib/src/webmcp.dart` — read 2026-09-15.
- `lib/src/webmcp_tool.dart` — read 2026-09-15.
- `lib/src/webmcp_tool_source.dart` — read 2026-09-15.
- `lib/src/webmcp_scope.dart` — read 2026-09-15.
- `lib/src/webmcp_exceptions.dart` — read 2026-09-15.
- `lib/src/widgets/webmcp_screen.dart` — read 2026-09-15.
- `lib/src/widgets/webmcp_action.dart` — read 2026-09-15.
- `lib/src/page/page.dart` — read 2026-09-15.
- `lib/src/page/webmcp_app_session.dart` — read 2026-09-15.
- `lib/src/page/webmcp_page.dart` — read 2026-09-15.
- `lib/src/page/webmcp_page_protocol.dart` — read 2026-09-15.
- `lib/src/page/webmcp_view_provider.dart` — read 2026-09-15.
- `lib/src/transport/webmcp_transport.dart` — read 2026-09-15.
- `lib/src/transport/webmcp_native_publisher.dart` — read 2026-09-15.
- `lib/src/transport/webmcp_native_capabilities.dart` — read 2026-09-15.
- `lib/src/transport/native_publisher_boundary.dart` — read 2026-09-15.
- `lib/src/transport/transport_selector.dart` — read 2026-09-15.
- `lib/src/transport/transport_noop.dart` — read 2026-09-15.
- `lib/src/transport/transport_web.dart` — read 2026-09-15.
- `example/lib/main.dart` — read 2026-09-15.
- `example/lib/example_screen.dart` — read 2026-09-15.
- `example/lib/example_tools.dart` — read 2026-09-15.
- `example/test/example_tools_test.dart` — read 2026-09-15.
- `wiki/product/webmcp-contract.md` — read 2026-09-15.
