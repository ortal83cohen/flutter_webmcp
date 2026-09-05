# Research: Stack and architecture for a Flutter WebMCP package

## Question

Which stack and architecture fit a pub.dev-publishable Flutter package that (a) lets a Flutter Web app register app actions as WebMCP tools with minimum integration, and (b) auto-generates "navigate to X" tools from the app's router, so an in-browser or dev-time AI agent can discover and invoke them via Chrome's experimental WebMCP API — covering the browser API's real shape, the Dart-to-JS bridge, the Dart-side registry architecture, and the existing prior art?

## Answer

Build on plain **Dart/Flutter stable, sound null-safety, `package:web` + `dart:js_interop`** (never the deprecated `dart:html`/`dart:js`). Bridge to the browser API by adding an `extension` with `external` members onto `package:web`'s existing `Document` type (not `Navigator` — see the correction below — and not a new standalone interop type, not `@JS()` globals, not `dart:js_interop_unsafe` as the primary path, which is reserved for feature detection only). On the Dart side, use a **plain singleton/service-locator registry** (`WebMcp.registerTool(...)`), not a widget-tree/`InheritedWidget` mechanism, with an *optional* thin widget wrapper layered on top later for lifecycle sugar; the registry composes directly with `go_router`'s non-widget `configuration.routes` getter to auto-generate navigation tools, and stays platform-agnostic so a future non-web transport is additive.

Two hard qualifiers on this recommendation. First, **WebMCP is not a stable target**: it's a Community Group draft in a Chrome-only origin trial (M149–156, ship target M157), and unregistration and other lifecycle details continue to evolve release over release (Chrome 153 changed unregister-without-cancelling behavior, for instance) — the package must expect the surface to keep moving even though the current entry point and unregistration mechanism are now confirmed (see corrections below). Second, **a functionally identical package already exists on pub.dev** — `flutter_webmcp` (publisher `kicknext.dev`, MIT, 160/160 pub score) — which blocks reusing that name and requires this project to differentiate on scope or angle, not just re-implement the same thing under a new label. The user has reviewed this and elected to proceed under a different package name with a differentiated focus (stronger router-driven auto-navigation and dev-time tooling), rather than contribute upstream or abandon the idea.

**Corrections applied 2026-09-04 after validation round 1** (see `validation/research-review-01.md`, findings F-001 through F-006): the entry-point recommendation below was wrong (recommended `Navigator`, should be `Document`), the unregistration finding was wrong (reported issue #130 as open; it closed 2026-03-26 with a documented `AbortSignal`-based mechanism), and several findings understated the evidence (a directly on-point Chrome source, `docs/ai/webmcp/imperative-api`, was never consulted; the Declarative API and additional non-Chrome implementations were omitted or under-qualified). The corrected findings replace the original text in place below rather than appending a second contradictory answer.

## Findings

### WebMCP is an unsettled Chrome-only origin trial, not a shipped standard

- Claim: WebMCP is a Community Group Draft (Web Machine Learning CG), not a W3C standard, running as a Chrome-only origin trial in Chrome 149–156 (shipping target M157), with a DevTrial window from M146 and a local flag `chrome://flags/#enable-webmcp-testing`. Chrome and Edge (both Chromium) are the only browsers with a native flag-gated implementation; Firefox/Safari have only open standards-positions issues. Independent of browser engines, two application-level implementations also exist today: Brave ships experimental support in its Leo AI chat, and ChatGPT Desktop supports WebMCP in its embedded browser (per `flutter_webmcp`'s own README) — so "Chrome-only" describes the browser-engine implementation, not the full set of surfaces where a page's registered tools might already be reachable.
- Evidence: raw spec source `index.bs` header (`Status: CG-DRAFT`); Chromium blink-dev "Intent to Experiment" thread milestone table; `implementation-status.md` in the spec repo, which documents Brave (Leo AI chat, issue 55232) and ChatGPT Desktop sections in addition to Chrome 149 and Edge 150.
- Source: https://raw.githubusercontent.com/webmachinelearning/webmcp/main/index.bs; https://groups.google.com/a/chromium.org/g/blink-dev/c/gmYffo5WOE8/m/OJxuQRP3AAAJ; https://github.com/webmachinelearning/webmcp/blob/main/implementation-status.md; https://pub.dev/packages/flutter_webmcp (all consulted 2026-09-04)

### The API's entry point is `document.modelContext`; `navigator.modelContext` was an earlier explainer name, now superseded

- Claim: **Corrected 2026-09-04** (validation round 1, F-001/F-003 — the original version of this finding recommended `Navigator` as the bridge target; that was wrong). The current formal IDL exposes `ModelContext` as `document.modelContext` (`[SecureContext, SameObject] readonly attribute ModelContext modelContext` on `partial interface Document`), and Chrome's own Imperative API reference page — published 2026-05-18, last updated 2026-09-01 — confirms this directly: every code sample on that page uses `document.modelContext` for registration (`await document.modelContext.registerTool(...)`), discovery (`await document.modelContext.getTools()`), and execution (`await document.modelContext.executeTool(...)`). Chrome also documents a second, separate surface: a Declarative API (`https://developer.chrome.com/docs/ai/webmcp/declarative-api`, published 2026-05-18) that annotates standard HTML `<form>` elements with attributes (`toolname`, `tooldescription`, `toolparamdescription`, `toolautosubmit`) to create a tool without JavaScript; Chrome's overview page states "Both APIs are gated by the `tools` Permissions Policy," confirming both are current, not one superseding the other. The August-2025 explainer's `window.navigator.modelContext` shape is the earlier design; `intentcall_webmcp`'s own pub.dev description independently corroborates this, calling `navigator.modelContext` an "older experiment treated as a compatibility shim." `flutter_webmcp`'s README states plainly: "WebMCP requires `document.modelContext`."
- Evidence: verbatim `index.bs` IDL; verbatim code samples from the Imperative API reference page; the Declarative API reference page; `flutter_webmcp` and `intentcall_webmcp` pub.dev descriptions, both independently confirming `Document` as current.
- Source: https://raw.githubusercontent.com/webmachinelearning/webmcp/main/index.bs; https://developer.chrome.com/docs/ai/webmcp/imperative-api; https://developer.chrome.com/docs/ai/webmcp/declarative-api; https://developer.chrome.com/docs/ai/webmcp; https://pub.dev/packages/flutter_webmcp; https://pub.dev/packages/intentcall_webmcp (all consulted 2026-09-04)
- The Declarative (form-annotation) API is not adopted for this package: a Flutter Web app renders to a `<canvas>`/DOM tree the framework owns, not developer-authored semantic `<form>` elements the declarative API's attributes are designed to annotate, so the Imperative API is the only one applicable to this package's registration model. This reasoning was absent from the original research pass and is recorded here so the plan does not have to re-derive it.

### Core tool-registration and execution shape

- Claim: `ModelContext` (an `EventTarget`) exposes `registerTool(tool, options)`, `getTools(options)`, `executeTool(tool, inputObject, options)`, and a `toolchange` event. A registered tool is `{name, title?, description, inputSchema, execute, annotations?}` where `execute` is `Promise<any> (inputObject, {signal})`; `name` is constrained to 1–128 ASCII alphanumeric/underscore/hyphen/period characters. The handler signature has already changed once between the 2025 explainer (`execute: ({text}, agent) => ...`) and the current IDL (`execute(inputObject, {signal})`) — a concrete sign the contract is still moving.
- Evidence: verbatim IDL blocks for `ModelContext`, `ModelContextTool`, `ToolAnnotations`, `ToolExecuteCallback`.
- Source: https://raw.githubusercontent.com/webmachinelearning/webmcp/main/index.bs (consulted 2026-09-04)

### Security/lifecycle constraints on the browser side

- Claim: The API requires a secure context and origin isolation (disabled if `Origin-Agent-Cluster: ?0`), and is gated by a `tools` Permissions-Policy defaulting to `self` (cross-origin iframes need `allow="tools"`). Chrome's own docs frame the API as designed for human-in-the-loop local browser workflows, not headless/unattended automation, though headless use "may be possible."
- Evidence: Chrome docs quotes on Origin Isolation/Permissions Policy.
- Source: https://developer.chrome.com/docs/ai/webmcp (consulted 2026-09-04)

### Tool unregistration is a resolved, documented mechanism, not an open design question

- Claim: **Corrected 2026-09-04** (validation round 1, F-002 — the original version of this finding stated unregistration semantics were "still an open design issue (#130)"; that was wrong). Spec repo issue #130 ("Tool unregistration design") closed on 2026-03-26. The resolved mechanism is documented on Chrome's Imperative API reference page: unregistration is performed via the `AbortSignal` passed in `registerTool`'s options object — `const controller = new AbortController(); await document.modelContext.registerTool(tool, {signal: controller.signal}); controller.abort();` — and, as of Chrome 153, aborting no longer cancels or breaks in-flight executions of that tool. The same options object also carries an `exposedTo` origin array (matching the IDL's `ModelContextRegisterToolOptions`), which the original research pass never checked the contents of — that gap in checking is what let the stale "open issue" claim stand uncorrected.
- Evidence: GitHub API response for issue #130 (`"state": "closed"`, `"closed_at": "2026-03-26T15:06:18Z"`); verbatim code sample and prose from the Imperative API reference page.
- Source: https://api.github.com/repos/webmachinelearning/webmcp/issues/130; https://developer.chrome.com/docs/ai/webmcp/imperative-api (both consulted 2026-09-04)

### Dart-to-JS bridge: extend `package:web`'s `Document`, don't re-declare or use legacy interop

- Claim: **Corrected 2026-09-04** (validation round 1, F-001 — see the entry-point finding above for why `Document`, not `Navigator`, is the current target). The current, non-deprecated Dart interop foundation is `dart:js_interop` + `package:web` (SDK ≥3.4, `package:web` latest `1.1.1`), replacing `dart:html`/`dart:js`/`package:js`. To call a not-yet-generated property like `modelContext`, the sanctioned Dart 3.3+ mechanism is a plain `extension` block adding `external` members onto `package:web`'s existing `Document` extension type (e.g. `extension DocumentModelContext on Document { external JSObject? get modelContext; }`), not a standalone re-declared interop type and not a top-level `@JS()` global (that pattern is for binding brand-new globals like `document`/`window` themselves, not members of an already-typed object). The mechanism — an `extension` adding `external` members to an existing `package:web` type — is unaffected by the Document/Navigator correction; only the target type changes.
- Evidence: dart.dev interop docs on `package:web`, extension types, and "amending outdated DOM native APIs" via external static-extension members.
- Source: https://dart.dev/interop/js-interop/package-web; https://dart.dev/interop/js-interop/usage; https://dart.dev/interop/js-interop/js-types (all consulted 2026-09-04)

### Feature detection and schema serialization

- Claim: An `external` getter for an absent JS property resolves to `null`/`undefined` rather than throwing, but the robust existence check is `hasProperty`/`has()` from `dart:js_interop_unsafe` (the one place that library is the recommended tool, not a fallback of last resort) — calling a method on a null/undefined reference does throw, so a presence check must gate any call. Tool parameter schemas should be built via an `extension type` with an `external factory` constructor for the fixed outer shape (name/type/description), combined with `jsify()` on a `Map<String, Object?>` for arbitrary nested JSON-schema `properties` — never via string-keyed `setProperty` calls as the primary path.
- Evidence: `dart:js_interop_unsafe` API docs (`hasProperty`, `has`); dart.dev usage docs on object-literal factory constructors and `jsify()`.
- Source: https://api.dart.dev/dart-js_interop_unsafe/JSObjectUnsafeUtilExtension.html; https://dart.dev/interop/js-interop/usage (both consulted 2026-09-04)

### Registry architecture: singleton over widget-tree

- Claim: A plain singleton/service-locator registry (`WebMcp.registerTool(...)`) fits better than an `InheritedWidget`/`Provider`-style widget (`WebMcpTool` wrapping a subtree) for this MVP. `go_router` (v18.0.1) exposes its route table as a plain non-widget getter (`GoRouter.configuration.routes` → `List<RouteBase>`, no `BuildContext` needed), so navigation-tool generation needs no widget-tree coupling. Raw Navigator 2.0 (`Router`/`RouteInformationParser`) has no framework-level route table at all — Flutter's own docs point developers to `go_router` instead — so nothing is gained by tying registration to widget lifecycle there either. Flutter's testing docs require `WidgetTester.pumpWidget` for anything depending on widget lifecycle, so a widget-based registry fails "unit-test without pumping a tree." Framework precedent for tree-scoped capability resolution does exist (`Actions`/`Shortcuts`, nearest-ancestor-wins) but fits a future per-screen-shadowing need, not this MVP's flat tool namespace.
- Evidence: `go_router` API docs for `GoRouter`/`RouteConfiguration`; Flutter navigation and testing docs; `Actions` class docs.
- Source: https://pub.dev/documentation/go_router/latest/go_router/RouteConfiguration-class.html; https://docs.flutter.dev/ui/navigation; https://docs.flutter.dev/testing/overview; https://api.flutter.dev/flutter/widgets/Actions-class.html (all consulted 2026-09-04)

### Platform isolation is orthogonal to the registry choice, but cleaner under a singleton

- Claim: Either registry shape can hide the web-only JS-interop layer behind a `WebMcpTransport`/`WebMcpPlatform` interface, invoked only on register/invoke, so a future non-web transport (e.g. a desktop MCP server) is additive. A singleton registry is marginally cleaner here because it has no `BuildContext`/widget dependency to strip out later — the same class is reusable unmodified in a non-Flutter Dart context (e.g. a headless CLI), whereas a widget-based registry's core mechanism is Flutter-`Widget`-specific by construction.
- Evidence: architectural reasoning cross-referencing the registry-architecture and JS-interop-bridge findings above.
- Source: synthesis of the two branches above (consulted 2026-09-04)

### A functionally identical package already exists on pub.dev

- Claim: `flutter_webmcp` v0.3.0 (publisher `kicknext.dev`, MIT, `github.com/KickNext/flutter_webmcp`) already provides "a typed Dart API for exposing Flutter Web actions as WebMCP tools" without hand-written JS interop, including a `WebMcpToolScope` widget for lifecycle-tied registration, typed input decoding, feature detection, and graceful no-op on unsupported platforms — and scores the maximum 160/160 pub points. A second, more experimental package, `intentcall_webmcp` v0.6.0 (publisher `xsoulspace.dev`, pre-release, explicitly "not recommended for production use"), also syncs a Dart-first registry to `document.modelContext`/`navigator.modelContext`. No other pub.dev "mcp" package touches the browser WebMCP surface — the rest (`dart_mcp`, `mcp_dart`, `mcp_server`, etc.) implement server-side/native MCP.
- Evidence: pub.dev listing and score breakdown for `flutter_webmcp`; pub.dev listing for `intentcall_webmcp`; pub.dev search results for "mcp" and "model context protocol".
- Source: https://pub.dev/packages/flutter_webmcp; https://pub.dev/packages/flutter_webmcp/score; https://pub.dev/packages/intentcall_webmcp; https://github.com/KickNext/flutter_webmcp (all consulted 2026-09-04)
- User decision (2026-09-04): proceed under a different package name (working title `webmcp_flutter`, to be finalized in the plan phase) with a differentiated scope emphasis (stronger `go_router`-driven auto-navigation and dev-time agent tooling), rather than contribute to the existing repo or abandon the idea. Recorded here as a research-phase input to the plan, not re-litigated.

### Reference JS implementation for browser-embedded MCP

- Claim: The WebMCP-org/MCP-B project (`@mcp-b/global`, `@mcp-b/webmcp-ts-sdk`, a browser extension) is the most mature client-side/browser-embedded MCP tool-server implementation in any language, predating/paralleling Chrome's native flag-gated implementation, and is a reasonable conceptual reference for what a "WebMCP tool server" should feel like from the JS side. Whether it remains the maintained/recommended entry point now that Chrome ships a native implementation is unconfirmed — see Unresolved.
- Evidence: npm package descriptions; GitHub repos `WebMCP-org/npm-packages`, `WebMCP-org/examples`.
- Source: https://www.npmjs.com/org/mcp-b; https://github.com/WebMCP-org/npm-packages (both consulted 2026-09-04)

### pub.dev scoring rubric and package layout template

- Claim: pub.dev's automated score (via `pana`) splits into five categories totalling 160 points: Dart file conventions (30), documentation (20), platform support (20), static analysis (50), up-to-date dependencies (40) — numeric maxima corroborated against `flutter_webmcp`'s actual 160/160 breakdown, since pub.dev's help page text omitted the numbers in the fetched extraction. High-scoring single-package Flutter/Dart repos (`equatable`, and `flutter_webmcp` itself) converge on: `lib/`, `example/`, `test/`, `README.md`, `CHANGELOG.md`, `LICENSE`, `analysis_options.yaml`, `pubspec.yaml`, plus community-health files (`CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, optionally `SECURITY.md`). A monorepo layout (`provider`) is a legitimate alternative but doesn't fit a single-package intent.
- Evidence: pub.dev help page category names; `dart-lang/pana` README; live score breakdown for `flutter_webmcp`; GitHub root listings for `equatable` and `KickNext/flutter_webmcp`.
- Source: https://pub.dev/help/scoring; https://github.com/dart-lang/pana; https://pub.dev/packages/flutter_webmcp/score; https://github.com/felangel/equatable (all consulted 2026-09-04)

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Dart→JS bridge: `extension` with `external` members on `package:web`'s `Document` | `extension DocumentModelContext on Document { external JSObject? get modelContext; }` | Low, statically typed, forward-compatible if `package:web` later adds the real binding | **Chosen.** Matches both the documented Dart 3.3+ pattern for amending outdated DOM APIs and the confirmed current entry point (IDL + Chrome's Imperative API reference page both target `Document`, not `Navigator` — corrected 2026-09-04, validation round 1 F-001). |
| Dart→JS bridge: `extension` with `external` members on `package:web`'s `Navigator` | `extension NavigatorModelContext on Navigator { external JSObject? get modelContext; }` | Same low cost, but targets the wrong current entry point | Rejected: this was the original (incorrect) chosen row before validation round 1 caught it. `Navigator` matched only the August-2025 explainer's design, since superseded; kept here as a corrected row rather than silently deleted. |
| Dart→JS bridge: standalone re-declared interop type / `@JS()` global / `dart:js_interop_unsafe` as primary | Various ways to reach `document.modelContext` without extending `package:web`'s type | Duplicates typed API, or bypasses static checking entirely | Rejected as primary; `dart:js_interop_unsafe` kept only for feature detection. |
| Registry: singleton/service-locator (`WebMcp.registerTool`) | Top-level registry, no widget-tree dependency, reads `go_router.configuration.routes` directly | Apps must remember manual unregistration if not using the optional widget sugar; registry is global state, tests must reset it | **Chosen.** Minimum integration, unit-testable with no `pumpWidget`, platform-agnostic. |
| Registry: `InheritedWidget`/`Provider`-style (`WebMcpTool` widget) | Tool registered/unregistered via widget lifecycle, propagated down the tree | Every tool needs a widget in the tree; requires `pumpWidget` to test; gains nothing for `go_router` or raw Navigator 2.0 introspection | Rejected as primary; the `Actions`/`Shortcuts` precedent for tree-scoped capability resolution doesn't match this MVP's flat namespace. |
| Registry: hybrid (singleton core + optional widget lifecycle wrapper) | Widget wrapper is thin sugar calling the singleton in `initState`/`dispose` | Two ways to register, needs clear documentation of which is authoritative | **Chosen as the eventual full shape**, additive on top of the singleton; not required for MVP. |
| Package strategy: publish new package under the taken name `flutter_webmcp` | — | Impossible — pub.dev enforces unique names | Rejected outright. |
| Package strategy: contribute to/fork `KickNext/flutter_webmcp` | Extend the existing MIT repo instead of publishing a new one | Requires external maintainer coordination, no control over direction | Considered, not chosen — user elected to proceed independently. |
| Package strategy: new name, differentiated scope | Publish under a new name (e.g. `webmcp_flutter`, to finalize in plan), emphasizing router-driven auto-navigation and dev-time tooling | Requires clearly articulating the differentiation so the effort isn't a pure duplicate | **Chosen** per user decision, 2026-09-04. |

## Constraints discovered

- WebMCP's native browser-engine implementation is Chrome/Edge-only (both Chromium), origin-trial-gated (M149–156, ship target M157); Brave (Leo AI chat) and ChatGPT Desktop separately support it at the application level. The confirmed entry point is `document.modelContext` (corrected 2026-09-04 — see above), but the spec is still an active CG-Draft and lifecycle details continue to change release over release (e.g. Chrome 153's change to unregister-without-cancelling behavior), so the package should still isolate the browser call behind a seam even though the entry point itself is now settled.
- The API requires secure context, origin isolation, and `tools` Permissions-Policy grants for iframes; this constrains where/how a Flutter web app embedding it can even attempt to call it.
- `dart:js_interop`/`package:web` are web-only SDK surfaces (SDK ≥3.4 for `package:web` 1.1.1); the package must declare platform support accordingly for `pana` scoring.
- `go_router` has no built-in route-flattening helper (must recurse `RouteBase`/`ShellRoute`/`StatefulShellRoute` manually); raw Navigator 2.0 has no introspectable route table at all, so navigation-tool auto-generation for non-`go_router` apps requires the app to supply its own route table explicitly.
- The pub.dev name `flutter_webmcp` is already taken by an actively maintained, top-scoring competitor; a new package needs both a different name and a genuine differentiation to justify existing alongside it.
- pub.dev's 160-point pana rubric is fully mechanical: conventions, docs (≥20% API coverage plus an example), platform declarations, zero-warning static analysis, and current dependency bounds are all required to be competitive with the existing top-scoring alternative.

## Unresolved

- [RESOLVED 2026-09-04, validation round 1: Which global object the shipped API exposes — was listed as unresolved/needing live-browser testing; Chrome's own Imperative API reference page (published 2026-05-18, last updated 2026-09-01), consulted during validation, documents `document.modelContext` directly and was simply never fetched in the original research pass. See the corrected entry-point finding above.]
- [RESOLVED 2026-09-04, validation round 1: Whether tool-unregistration semantics were finalized — issue #130 closed 2026-03-26 with a documented `AbortSignal`-based mechanism. See the corrected unregistration finding above.]
- [UNRESOLVED: Whether `chrome://flags/#enable-webmcp-testing` is the current correct local-dev flag or coexists with/supersedes the generic "Experimental Web Platform features" flag from the original Intent-to-Experiment.]
- [UNRESOLVED: The exact `outputSchema` mechanism Chrome's docs prose mentions, which does not appear in the `index.bs` IDL as extracted — needs a closer line-by-line read of the spec source.]
- [UNRESOLVED: Whether the MVP needs per-screen tool shadowing (same tool name resolving differently by active screen) — if so, the `Actions`/`Shortcuts` precedent becomes directly relevant to the optional widget wrapper's design. This is a product-scope question for the plan phase.]
- [UNRESOLVED: What exact feature/API gap exists between this project's intended scope and `KickNext/flutter_webmcp` / `intentcall_webmcp` — no line-by-line capability diff has been done yet. The plan phase must establish concrete differentiation, not just a different name. Partial evidence: `flutter_webmcp`'s README (checked during validation) documents no `go_router` integration or navigation-tool generation, which supports but does not substitute for a full diff.]
- [UNRESOLVED: Whether `dart-lang/web`'s own issue tracker already has an open proposal to add `modelContext` to the generated `Document` type, which would let the package's `extension`-based workaround be written for clean removal later.]
- [UNRESOLVED: Exact pana scoring rule text penalizing deprecated `dart:html`/`dart:js` usage and missing/incorrect platform declarations — inferred from general deprecation/scoring behavior, not confirmed against pana's own rule source.]
- [UNRESOLVED: Whether the WebMCP-org/MCP-B toolkit (`@mcp-b/global`, `@mcp-b/webmcp-ts-sdk`) is still the maintained/recommended reference implementation now that Chrome ships a native flag-gated implementation — not cross-checked against its own changelog.]
- [UNRESOLVED: `intentcall_platform` (v0.6.0, same publisher as `intentcall_webmcp`) also appears in pub.dev's "webmcp" search results, covering "web manifests, WebMCP JS, native handoff, and Apple App Intents scaffolds" — not evaluated as a possible third prior-art package; the competitive picture's substance is likely unchanged but this was not confirmed.]

## Sources

- https://developer.chrome.com/docs/ai/webmcp — consulted 2026-09-04
- https://github.com/webmachinelearning/webmcp — consulted 2026-09-04
- https://webmachinelearning.github.io/webmcp/ — consulted 2026-09-04
- https://raw.githubusercontent.com/webmachinelearning/webmcp/main/index.bs — consulted 2026-09-04
- https://webmachinelearning.github.io/webmcp/docs/proposal.html — consulted 2026-09-04
- https://github.com/webmachinelearning/webmcp/blob/main/implementation-status.md — consulted 2026-09-04
- https://chromestatus.com/feature/5117755740913664 — consulted 2026-09-04 (client-rendered, data via search synthesis)
- https://groups.google.com/a/chromium.org/g/blink-dev/c/gmYffo5WOE8/m/OJxuQRP3AAAJ — consulted 2026-09-04
- https://github.com/webmachinelearning/webmcp/issues/130 — consulted 2026-09-04; re-checked via https://api.github.com/repos/webmachinelearning/webmcp/issues/130 during validation round 1 (2026-09-04), confirming `state: closed`, `closed_at: 2026-03-26`
- https://developer.chrome.com/docs/ai/webmcp/imperative-api — consulted 2026-09-04 (during validation round 1; published 2026-05-18, last updated 2026-09-01 — confirms `document.modelContext` entry point and the `AbortSignal` unregistration mechanism)
- https://developer.chrome.com/docs/ai/webmcp/declarative-api — consulted 2026-09-04 (during validation round 1; published 2026-05-18 — form-annotation API, not applicable to this package)
- https://dart.dev/interop/js-interop/package-web — consulted 2026-09-04
- https://dart.dev/interop/js-interop/js-types — consulted 2026-09-04
- https://dart.dev/interop/js-interop/usage — consulted 2026-09-04
- https://dart.dev/interop/js-interop/start — consulted 2026-09-04
- https://dart.dev/interop/js-interop/past-js-interop — consulted 2026-09-04
- https://api.flutter.dev/flutter/dart-js_interop_unsafe/ — consulted 2026-09-04
- https://api.dart.dev/dart-js_interop_unsafe/JSObjectUnsafeUtilExtension.html — consulted 2026-09-04
- https://api.dart.dev/dart-js_interop/JSObject-extension-type.html — consulted 2026-09-04
- https://pub.dev/packages/web, /web/changelog — consulted 2026-09-04
- https://github.com/dart-lang/web/releases — consulted 2026-09-04
- https://github.com/dart-lang/sdk/issues/44057 — consulted 2026-09-04
- https://pub.dev/packages/go_router, /documentation/go_router/latest/go_router/GoRouter-class.html, /RouteConfiguration-class.html, /topics/Configuration-topic.html — consulted 2026-09-04
- https://docs.flutter.dev/ui/navigation — consulted 2026-09-04
- https://docs.flutter.dev/testing/overview — consulted 2026-09-04
- https://docs.flutter.dev/data-and-backend/state-mgmt/simple — consulted 2026-09-04
- https://api.flutter.dev/flutter/widgets/Actions-class.html — consulted 2026-09-04
- https://pub.dev/packages/get_it, https://github.com/flutter-it/get_it — consulted 2026-09-04
- https://pub.dev/packages/flutter_webmcp, /flutter_webmcp/score — consulted 2026-09-04
- https://github.com/KickNext/flutter_webmcp — consulted 2026-09-04
- https://pub.dev/packages/intentcall_webmcp — consulted 2026-09-04
- https://pub.dev/packages?q=mcp, ?q=model+context+protocol, ?q=webmcp — consulted 2026-09-04
- https://www.npmjs.com/org/mcp-b, https://github.com/WebMCP-org/npm-packages, /examples — consulted 2026-09-04
- https://pub.dev/help/scoring — consulted 2026-09-04
- https://github.com/dart-lang/pana — consulted 2026-09-04
- https://github.com/felangel/equatable, https://github.com/rrousselGit/provider — consulted 2026-09-04
