# Research: Automatic page content and actions

## Question

How can `webmcp_flutter` expose useful current-page content and actions with minimal consumer integration while preserving explicit opt-in, Flutter lifecycle ownership, browser WebMCP compatibility, and honest coverage limits?

## Answer

The proposed design is an opt-in runtime wrapper that snapshots the currently materialized Flutter semantics subtree and offers only actions advertised by the current semantic nodes. Applications may add explicitly annotated domain actions, with an optional source generator reducing descriptor and argument-decoding boilerplate. This design is feasible in principle through public Flutter semantics APIs, but scope isolation, stale-handle rejection, overlays, multi-view behavior, and release-mode behavior must pass a dedicated spike on the declared supported Flutter range before the implementation API is frozen.

The native WebMCP bridge should be publisher-only in this work: it synchronizes local tools to the browser's `document.modelContext.registerTool` surface and handles invocation, cancellation, and unregistration. It does not need an MCP network transport or an in-page agent. Automatic coverage is limited to runtime semantics that exist inside the opted-in scope; hidden, excluded, lazily unbuilt, server-only, and unannotated domain state are outside any completeness claim.

## Findings

### Runtime semantics is the credible automatic source

- Claim: Flutter provides public runtime APIs to request semantics collection, select the wrapper's `PipelineOwner`, traverse `SemanticsNode` children, read immutable `SemanticsData`, listen for updates, and dispatch actions through `SemanticsOwner.performAction`.
- Evidence: These APIs expose labels, values, hints, roles, identifiers, flags, actions, and current handlers after the semantics phase. They represent live built state, unlike source generation.
- Sources: [SemanticsBinding.ensureSemantics](https://api.flutter.dev/flutter/semantics/SemanticsBinding/ensureSemantics.html), [PipelineOwner.semanticsOwner](https://api.flutter.dev/flutter/rendering/PipelineOwner/semanticsOwner.html), [SemanticsNode](https://api.flutter.dev/flutter/semantics/SemanticsNode-class.html), [SemanticsData](https://api.flutter.dev/flutter/semantics/SemanticsData-class.html), and [SemanticsOwner.performAction](https://api.flutter.dev/flutter/semantics/SemanticsOwner/performAction.html), consulted 2026-09-10; `research/semantics.md`.

- Design proposal: A mounted wrapper holds a `SemanticsHandle`, creates an internal identifier-marked semantics boundary, locates it in the wrapper's own `PipelineOwner`, and returns revisioned immutable snapshots. Action requests carry opaque snapshot-local handles; the implementation re-resolves the current node, rejects stale revisions, and checks that the action is still advertised immediately before dispatch.
- Status: `[UNVERIFIED]` until the isolation spike proves the marker and ownership model in release mode; `RenderObject.debugSemantics` is not a release-mode solution.
- Sources: [SemanticsProperties.identifier](https://api.flutter.dev/flutter/semantics/SemanticsProperties/identifier.html), [Semantics.container](https://api.flutter.dev/flutter/widgets/Semantics/container.html), and `research/semantics.md`.

### Automatic coverage is useful but deliberately partial

- Claim: Standard widgets commonly contribute labels, values, roles, flags, and actions, while lazy lists expose only instantiated children, `CustomPaint` contributes meaning only when semantics are supplied, merged semantics erase child distinctions, and overlays or platform views can sit outside a wrapper's traversable Flutter subtree.
- Evidence: Flutter documents lazy child lifecycle, custom painter semantics, exclusion and blocking behavior, and its accessibility projection. These boundaries prevent a truthful claim that all visible or application data is discoverable.
- Sources: [ListView child lifecycle](https://api.flutter.dev/flutter/widgets/ListView-class.html), [CustomPainter.semanticsBuilder](https://api.flutter.dev/flutter/rendering/CustomPainter/semanticsBuilder.html), [ExcludeSemantics](https://api.flutter.dev/flutter/widgets/Semantics/excludeSemantics.html), [BlockSemantics](https://api.flutter.dev/flutter/widgets/BlockSemantics-class.html), [Flutter web accessibility](https://docs.flutter.dev/ui/accessibility/web-accessibility), consulted 2026-09-10; `research/semantics.md`.

- Design proposal: Snapshot metadata states that results cover the currently materialized semantic window. Hidden, invisible, excluded, obscured-sensitive, blocked, and out-of-scope nodes are omitted. Lazy collections require scroll-and-refresh behavior and explicit partial-result metadata. Unsupported surfaces fall back to explicit application registration.
- Source: `research/semantics.md`.

### Domain actions remain explicit; generation is optional

- Claim: The existing package already has runtime seams for explicit actions and sources: `WebMcpScreen`, `WebMcpAction`, `WebMcpScope`, and `WebMcpToolSource`. Current descriptors and handlers are handwritten, and the early `WebMcpScreen.initState` hook cannot use a dependency assigned only after `super.initState()` without a lifecycle adjustment or later explicit source registration.
- Evidence: Repository source defines those lifecycle and source interfaces and their ordering.
- Sources: `lib/src/widgets/webmcp_screen.dart`, `lib/src/widgets/webmcp_action.dart`, `lib/src/webmcp_scope.dart`, `lib/src/webmcp_tool_source.dart`, and `research/local-codegen.md`, inspected 2026-09-10.

- Design proposal: Optional annotations opt individual domain methods in. Generated code accepts a consumer-created live instance and implements `WebMcpToolSource`; it may generate descriptors, supported argument decoding, schema metadata, and calls to annotated methods. It never constructs the service, discovers runtime widgets, or exposes unannotated methods.
- Evidence: `source_gen` and `build_runner` support annotated source generation, but build-time inputs cannot recover mounted state, live authorization, lazy children, or closure intent.
- Sources: [source_gen](https://pub.dev/packages/source_gen), [build_runner](https://pub.dev/packages/build_runner), [Dart build runner guide](https://dart.dev/tools/build_runner), consulted 2026-09-10; `research/local-codegen.md`.

- Constraint: The repository declares Dart `^3.13.0`, Flutter `>=3.47.0`, and analyzer `^13.3.0`. Upstream generator dependency ranges appear compatible in principle, but no dependency solve or generator prototype was run; compatibility remains `[UNVERIFIED]`.
- Source: `pubspec.yaml`; `research/local-codegen.md`.

### Installed Flutter evidence does not validate the declared baseline

- Claim: The semantics investigation inspected Flutter 3.38.4 at commit `66dd93f9a27ffe2a9bfc8297506ce066ff51265f`, while this package declares Flutter `>=3.47.0`.
- Implication: Evidence from the installed 3.38.4 checkout can identify candidate APIs and behavior, but it does not validate the declared 3.47.0 minimum or later supported versions. Release/profile/debug isolation tests must run on the actual declared baseline and a chosen current upper test version before the API is frozen.
- Sources: `pubspec.yaml:8`; [installed Flutter source revision](https://github.com/flutter/flutter/tree/66dd93f9a27ffe2a9bfc8297506ce066ff51265f); `research/semantics.md`.

### The competitor confirms that explicit publication is separate from discovery

- Claim: KickNext's external `flutter_webmcp` 0.3.0 requires developers to construct each `WebMcpTool` or `WebMcpTypedTool`, schema, decoder, handler, and lifecycle scope. Its published browser adapter calls `document.modelContext.registerTool`; it does not inspect the widget tree, semantics tree, DOM, routes, or page content and does not implement `getTools()`, `executeTool()`, `toolchange`, or an agent loop.
- Evidence: Its README demonstrates manual construction in `initState`; its published archive contains explicit tool, scope, and registration bindings only. This external package is distinct from this repository's `webmcp_flutter` 0.1.1.
- Sources: [KickNext flutter_webmcp README](https://github.com/KickNext/flutter_webmcp#flutter-usage), [published 0.3.0 archive](https://pub.dev/api/archives/flutter_webmcp-0.3.0.tar.gz), [pub.dev metadata](https://pub.dev/api/packages/flutter_webmcp), consulted 2026-09-10; `pubspec.yaml`; `research/competitor.md`.

### Native WebMCP publication is a browser bridge

- Claim: WebMCP is a secure-context browser API on `document.modelContext`, not MCP over JSON-RPC, stdio, SSE, or Streamable HTTP. Publisher registration requires a valid unique name, non-empty description, JSON Schema input, execute callback, invocation cancellation, signal-based unregistration, and optional cross-origin exposure. The `tools` Permissions Policy defaults to `self`.
- Evidence: The current draft defines `registerTool`, `getTools`, and `executeTool`; it says `getTools()` serves in-page agents while browser agents use an internal retrieval mechanism.
- Sources: [WebMCP API](https://webmachinelearning.github.io/webmcp/#api), [ModelContextTool](https://webmachinelearning.github.io/webmcp/#modelcontexttool), [registration options](https://webmachinelearning.github.io/webmcp/#modelcontextregistertooloptions), and [Permissions Policy](https://webmachinelearning.github.io/webmcp/#permissions-policy), consulted 2026-09-10; `research/competitor.md`.

- Design proposal: This work's bridge is publisher-only. It attaches to the existing process-wide registry, publishes tools already present, observes later registration/removal, preserves first-live-registration-wins ownership semantics, translates Dart invocation/results safely, propagates cancellation, and tears down browser registrations with their owners. Consumer-side `getTools()`, `executeTool()`, and `toolchange` remain out of this implementation unless a later work item requires an in-page agent.
- Sources: `wiki/product/webmcp-contract.md`; `research/competitor.md`.

### Browser and wire compatibility need an isolated spike

- Claim: WebMCP remains experimental. The competitor 0.3.0 targets the 26 August 2026 draft and exposes two annotation fields, while the 9 September 2026 draft also contains `consequentialHint`.
- Implication: Browser property presence alone is insufficient proof of working registration and invocation. Before the public implementation API is frozen, an isolated browser transport spike must verify actual registration, invocation, cancellation, unregistration, errors, annotations, secure-context behavior, and JavaScript/WebAssembly builds against selected browser/draft versions.
- Sources: [competitor compatibility statement](https://github.com/KickNext/flutter_webmcp#compatibility), [current ToolAnnotations](https://webmachinelearning.github.io/webmcp/#dictdef-toolannotations), and [Chrome imperative API status](https://developer.chrome.com/docs/ai/webmcp/imperative-api#engage-and-share-feedback), consulted 2026-09-10; `research/competitor.md`.

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Runtime semantics wrapper plus optional annotated domain actions | Snapshot the opted-in live semantics subtree and dispatch current advertised actions; explicitly annotated methods cover domain operations outside semantics. | Requires release-mode isolation proof, snapshot schema, stale-handle protection, filtering, security policy, and browser publication. | Chosen design proposal, contingent on the semantics and transport spikes. It meets minimal integration without claiming complete application discovery. |
| Optional generated instance adapter | Generate `WebMcpToolSource` glue only for annotated domain methods on a consumer-supplied instance. | Adds annotation/generator packaging, generated files, build latency, type policy, and diagnostics. | Chosen optional extension after the runtime and transport contracts are stable. It reduces boilerplate but is not the discovery engine. |
| Explicit registration only | Require developers to define all content and actions as tools, like the competitor. | Strong identity and schema control; substantial integration work and no automatic page view. | Retain as fallback for unsupported or security-sensitive surfaces; reject as the sole user experience. |
| Declarative HTML forms | Annotate eligible HTML forms with browser WebMCP attributes. | Small for conventional HTML forms; Flutter renderer applicability is unverified and coverage is form-specific. | Complementary only where actual eligible forms exist. Source: [Chrome declarative API](https://developer.chrome.com/docs/ai/webmcp/declarative-api). |
| Generator-first discovery | Infer page content and actions from Dart source. | Cannot observe runtime branches, mounted state, lazy children, enabled state, authorization, or semantics emitted after layout. | Rejected as a discovery engine. |
| DOM or inferred all-page crawling | Crawl rendered output and infer every action and datum. | Web-specific, ambiguous, privacy-sensitive, and unable to establish complete hidden/lazy/server data coverage. | Rejected. |

## Constraints discovered

- Opt-in is mandatory: only a mounted wrapper's proven semantics subtree and explicitly annotated domain methods belong to the surface. Source: design proposal derived from `research/semantics.md` and `research/local-codegen.md`.
- The snapshot is an accessibility projection of currently built state. It is not a database, route model, or promise of all visible pixels and application data. Source: `research/semantics.md`.
- Obscured and sensitive fields require deny-by-default filtering, and authorization remains inside application handlers. Annotations are agent hints rather than security boundaries. Sources: installed Flutter `RenderEditable` evidence in `research/semantics.md`; [Chrome WebMCP tool security](https://developer.chrome.com/docs/ai/webmcp/secure-tools).
- Existing global naming, first-live-registration-wins behavior, scope ownership, non-transactional registration, and local registry source of truth remain in force unless separately revised. Source: `wiki/product/webmcp-contract.md`; `research/local-codegen.md`.
- The first bridge is publisher-only and web-only. Browser availability, secure-context, permission-policy, and draft-version failures must be observable without claiming support from detection alone. Sources: `wiki/product/webmcp-contract.md`; `research/competitor.md`.
- No implementation API freezes before release-mode semantics isolation and browser publication spikes pass on the declared Flutter/browser matrix. Source: design decision based on the unverified gates in `research/semantics.md` and `research/competitor.md`.

## Unresolved

- [UNRESOLVED: Can an identifier-marked wrapper isolate exactly its intended subtree across sibling and nested wrappers, rebuilds, merged/excluded/blocked semantics, overlays, route transitions, multiple views, profile mode, and release mode on Flutter 3.47.0 and the selected upper test version?]
- [UNRESOLVED: What nested-wrapper and overlay ownership rules prevent duplicate or out-of-scope exposure?]
- [UNRESOLVED: What snapshot schema, revision protocol, opaque-handle format, size budget, refresh behavior, and partial-result metadata will be public?]
- [UNRESOLVED: Which semantics fields and actions form the initial allowlist, and what privacy policy governs text, focus, clipboard, dismiss, custom actions, and obscured values?]
- [UNRESOLVED: Which WebMCP draft and browser versions are supported, and which compatibility shims are required for annotations, registration returns, invocation results, and errors?]
- [UNRESOLVED: How will an active page add a generated source whose live dependency is initialized after `super.initState()`?]
- [UNRESOLVED: What Dart parameter/return types, JSON Schema derivation rules, diagnostics, output convention, and package split will the optional generator support?]
- [UNRESOLVED: What exact failure causes the semantics feature to fall back to explicit registration rather than expose a partial or incorrectly scoped tree?]

## Sources

- `wiki/work/0008-automatic-page-agent/research/semantics.md`, verified 2026-09-10, with linked Flutter API documentation and installed Flutter 3.38.4 source evidence.
- `wiki/work/0008-automatic-page-agent/research/local-codegen.md`, verified 2026-09-10, with repository source and official Dart build/source-generation references.
- `wiki/work/0008-automatic-page-agent/research/competitor.md`, verified 2026-09-10, with pub.dev, KickNext, WebMCP draft, and Chrome documentation references.
- `pubspec.yaml`, inspected 2026-09-10; declares `webmcp_flutter` 0.1.1, Dart `^3.13.0`, Flutter `>=3.47.0`, and analyzer `^13.3.0`.
- `wiki/product/webmcp-contract.md`, inspected through the research streams on 2026-09-10.

## Validation clarification — 2026-09-10

This clarification supersedes the wording of the registration-requirements claim under Native WebMCP publication is a browser bridge. The browser draft requires the tool name, description, and execute callback; inputSchema and the registration signal are optional dictionary members. Requiring a schema and signal-backed cleanup is this proposed bridge's policy, not a universal browser API requirement. Source: https://webmachinelearning.github.io/webmcp/#modelcontexttool and https://webmachinelearning.github.io/webmcp/#modelcontextregistertooloptions; independently verified in validation/research-review-01.md, finding F-001.
