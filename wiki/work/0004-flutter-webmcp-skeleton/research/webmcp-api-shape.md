# Research: WebMCP API shape, lifecycle and stability

## Question

What is the actual current shape of Chrome's WebMCP API — the concrete object/method names, the tool-registration shape (name, description, input schema, handler signature), its lifecycle (when it becomes available on `window`/`navigator`, any feature-detection pattern, origin-trial or flag-gated status), and how stable vs. likely-to-change this API is right now (2026-09-04)?

## Answer

WebMCP is a **Community Group draft** (CG-DRAFT, not a W3C standard) from the Web Machine Learning Community Group, currently shipping in Chrome as an **origin trial in Chrome 149–156** (shipping target M157) and behind a local dev flag. The spec's current authoritative IDL exposes the API as `document.modelContext` (a `ModelContext` interface with `registerTool()`, `getTools()`, `executeTool()`, and a `toolchange` event), but earlier explainer material and even the Chromium "Intent to Experiment" thread describe the entry point as `navigator.modelContext`. This inconsistency between primary sources is itself evidence the API surface has moved and is still moving — treat the exact global as **not yet settled** and feature-detect defensively on both. The API is explicitly a draft, has no browser interoperability commitment (Firefox/WebKit have not adopted), and is scoped for Chrome-only origin-trial experimentation as of today.

## Findings

### Spec status and governing body

- Claim: WebMCP's formal specification source (`index.bs`) declares itself a Community Group Draft (`Status: CG-DRAFT`) of the Web Machine Learning Community Group, not a W3C Recommendation-track document.
- Evidence: Fetched raw `index.bs` metadata header: `Status: CG-DRAFT`, `Group: Web Machine Learning Community Group`, `Repository: webmachinelearning/webmcp`.
- Source: https://raw.githubusercontent.com/webmachinelearning/webmcp/main/index.bs (consulted 2026-09-04)

### Rendered spec draft also self-describes as non-final

- Claim: The rendered spec page states it is a "Draft Community Group Report," not a W3C Standard.
- Evidence: WebFetch of the rendered spec page returned: "Draft Community Group Report, published September 3, 2026 by the Web Machine Learning Community Group. Not a W3C Standard."
- Source: https://webmachinelearning.github.io/webmcp/ (consulted 2026-09-04)

### Global object — spec IDL says `Document.modelContext`

- Claim: The current formal IDL exposes `ModelContext` as a read-only attribute on `Document`, secure-context only, same-object.
- Evidence: Raw `index.bs` quoted verbatim: `partial interface Document { [SecureContext, SameObject] readonly attribute ModelContext modelContext; };`
- Source: https://raw.githubusercontent.com/webmachinelearning/webmcp/main/index.bs (consulted 2026-09-04)

### Global object — earlier/parallel sources say `navigator.modelContext`

- Claim: The Chromium "Intent to Experiment" thread for WebMCP describes the API as `navigator.modelContext`, and the repo's `docs/proposal.md` (an earlier explainer, dated August 2025) shows code samples using `window.navigator.modelContext.registerTool(...)` with feature detection `if ("modelContext" in window.navigator)`.
- Evidence: Blink-dev thread text: "WebMCP provides `navigator.modelContext`... `agent-service interaction takes place via app-controlled UI`." Proposal doc code sample: `window.navigator.modelContext.registerTool({ execute: ({ text }, agent) => {...}, name: "add-todo", description: "Add a new todo item to the list", inputSchema: {...} });` with the guard `if ("modelContext" in window.navigator)`.
- Source: https://groups.google.com/a/chromium.org/g/blink-dev/c/gmYffo5WOE8/m/OJxuQRP3AAAJ (consulted 2026-09-04); https://webmachinelearning.github.io/webmcp/docs/proposal.html (consulted 2026-09-04)

### Global object — Chrome's own docs page does not commit to either name in prose

- Claim: `developer.chrome.com/docs/ai/webmcp` describes tool registration conceptually (name, description, inputSchema, outputSchema, "handler executes visibly on the page") but the fetched prose extraction did not surface a code sample pinning down `window`/`navigator`/`document` — the extraction tool reported the exact entry point "not explicitly stated" in the material it returned.
- Evidence: Two separate WebFetch passes over the same URL returned inconsistent/partial extractions; neither produced a verbatim `document.modelContext` or `navigator.modelContext` code sample from this specific page.
- Source: https://developer.chrome.com/docs/ai/webmcp (consulted 2026-09-04) — `[UNVERIFIED: exact global object name used in Chrome's own docs page code samples, since the fetch tool could not reliably extract verbatim code blocks from this page]`

### Resolution / working conclusion on the global

- Claim: The spec (formal IDL, most recently dated) is the more authoritative and more recently updated source, so `document.modelContext` should be treated as the current target. `navigator.modelContext` was the shape used in mid-2025/early-2026 explainer material and the original Intent-to-Experiment. Third-party corroboration explicitly states Chrome maintains `navigator.modelContext` as a **backward-compatible alias** returning the same instance as `document.modelContext`.
- Evidence: Search-result synthesis: "The canonical location for the modelContext API is `document.modelContext`, with `navigator.modelContext` maintained as a backward-compatible alias that returns the same instance." This claim originates from third-party blog/aggregator content, not from the spec or Chrome docs directly.
- Source: web search synthesis over multiple 2026 sources including https://www.openhermit.com/blog/navigator-modelcontext-2026 and https://webfuse.com/webmcp-cheat-sheet (consulted 2026-09-04) — `[UNVERIFIED: the "backward-compatible alias" claim is not confirmed directly in index.bs or Chrome's own docs; it is corroboration-tier content only, per this task's source priority]`

### `ModelContext` interface — methods

- Claim: The `ModelContext` interface (exposed on `Window`, `SecureContext`) is an `EventTarget` with three async methods and one event handler attribute.
- Evidence: Verbatim IDL from `index.bs`:
```
[Exposed=Window, SecureContext]
interface ModelContext : EventTarget {
  Promise<undefined> registerTool(ModelContextTool tool, optional ModelContextRegisterToolOptions options = {});
  Promise<sequence<RegisteredTool>> getTools(optional ModelContextGetToolOptions options = {});
  Promise<DOMString> executeTool(RegisteredTool tool, optional object inputObject = {}, optional ModelContextExecuteToolOptions options = {});
  attribute EventHandler ontoolchange;
};
```
- Source: https://raw.githubusercontent.com/webmachinelearning/webmcp/main/index.bs (consulted 2026-09-04)

### Tool registration shape — `ModelContextTool` dictionary

- Claim: A tool is registered with `name` (required), `title` (optional display name), `description` (required), `inputSchema` (a JSON-Schema-shaped plain object), a required `execute` callback, and optional `annotations`.
- Evidence: Verbatim IDL:
```
dictionary ModelContextTool {
  required DOMString name;
  USVString title;
  required DOMString description;
  object inputSchema;
  required ToolExecuteCallback execute;
  ToolAnnotations annotations;
};

dictionary ToolAnnotations {
  boolean readOnlyHint = false;
  boolean untrustedContentHint = false;
  boolean consequentialHint = false;
};

callback ToolExecuteCallback = Promise<any> (object inputObject, ToolExecuteCallbackOptions options);
```
Tool `name` is constrained to 1–128 characters, ASCII alphanumerics/underscore/hyphen/period only.
- Source: https://raw.githubusercontent.com/webmachinelearning/webmcp/main/index.bs (consulted 2026-09-04)

### Handler signature

- Claim: The handler (`execute`) is a callback returning a `Promise<any>`, invoked with `(inputObject, options)` where `options` carries a required `AbortSignal`.
- Evidence: Verbatim IDL: `callback ToolExecuteCallback = Promise<any> (object inputObject, ToolExecuteCallbackOptions options);` and `dictionary ToolExecuteCallbackOptions { required AbortSignal signal; };`. Note: the earlier `docs/proposal.md` explainer sample used a two-arg-with-agent shape `execute: ({ text }, agent) => {...}` — a different handler signature than the current IDL's `(inputObject, options)`, another sign the handler contract has changed across drafts.
- Source: https://raw.githubusercontent.com/webmachinelearning/webmcp/main/index.bs; https://webmachinelearning.github.io/webmcp/docs/proposal.html (both consulted 2026-09-04)

### Registration/execution options and discovery

- Claim: `registerTool` accepts options `{ exposedTo: sequence<USVString>, signal: AbortSignal }`; `getTools` accepts `{ fromOrigins: sequence<USVString> }` for cross-origin discovery; `executeTool` accepts `{ signal: AbortSignal }`; a discovered tool is returned as a `RegisteredTool` dictionary carrying `name`, `title`, `description`, `inputSchema`, a required `window`, a required `origin`, and `annotations`.
- Evidence: Verbatim IDL blocks for `ModelContextRegisterToolOptions`, `ModelContextGetToolOptions`, `ModelContextExecuteToolOptions`, and `RegisteredTool` (see spec fetch output above).
- Source: https://raw.githubusercontent.com/webmachinelearning/webmcp/main/index.bs (consulted 2026-09-04)

### Lifecycle event

- Claim: `ModelContext` fires a `toolchange` event (via `ontoolchange` handler / `addEventListener("toolchange", ...)`) when tools are registered or unregistered, allowing consumers to react to dynamic tool-set changes.
- Evidence: IDL attribute `attribute EventHandler ontoolchange;` plus corroborating description from spec-page fetch: "`toolchange` event fires at ModelContext when tools are registered or unregistered."
- Source: https://raw.githubusercontent.com/webmachinelearning/webmcp/main/index.bs; https://webmachinelearning.github.io/webmcp/ (both consulted 2026-09-04)

### Origin trial and flag-gated availability in Chrome

- Claim: WebMCP is available in Chrome as an **origin trial from Chrome 149 through Chrome 156 inclusive**, with a **shipping target of Chrome 157**, across Desktop, Android, and WebView. A DevTrial window started at Chrome M146. Chrome's public docs additionally describe a dedicated local-testing flag: `chrome://flags/#enable-webmcp-testing`.
- Evidence: Blink-dev "Intent to Experiment" thread quote: "DevTrial start: Chrome M146", "Origin trial: M149–M156 (inclusive)", "Shipping target: M157", "All platforms: Desktop, Android, and WebView." Approval quote: Mike Taylor, May 18, 2026: "LGTM to experiment from M149 to M156 inclusive." Chrome docs page quote: "Open Chrome and navigate to `chrome://flags/#enable-webmcp-testing`."
- Source: https://groups.google.com/a/chromium.org/g/blink-dev/c/gmYffo5WOE8/m/OJxuQRP3AAAJ (consulted 2026-09-04); https://developer.chrome.com/docs/ai/webmcp (consulted 2026-09-04)

### Flag-name discrepancy

- Claim: The Intent-to-Experiment thread names the generic "Experimental Web Platform features" flag as the gating mechanism, while Chrome's current docs page names a dedicated flag `#enable-webmcp-testing`. These are two different flags mentioned in sources from different points in time.
- Evidence: Blink-dev thread: "Flag Name: 'Experimental Web Platform features' on about://flags." Chrome docs: "chrome://flags/#enable-webmcp-testing".
- Source: same as above — `[UNVERIFIED: whether the dedicated #enable-webmcp-testing flag replaced the generic experimental-features flag gate, or whether both currently work; this level of Chrome-internal flag plumbing detail was not independently confirmed against a chrome://flags listing]`

### Chrome Platform Status entry

- Claim: WebMCP is tracked on Chrome Status under feature ID `5117755740913664`, listing origin trial milestones "Origin trial desktop first: 149, Origin trial desktop last: 156" and "Shipping on desktop expected: 157."
- Evidence: Search-result synthesis of the Chrome Status entry (the page itself is JS-rendered and could not be scraped directly by the fetch tool, which returned only the page shell/header).
- Source: https://chromestatus.com/feature/5117755740913664 (consulted 2026-09-04, JS-rendered content not directly retrievable by tooling) — `[UNVERIFIED: milestone numbers came from a search-engine synthesis of the Chrome Status page content, not a direct verbatim read of chromestatus.com, because the fetch tool could only retrieve the page's client-rendered shell]`

### Cross-browser implementation status

- Claim: As of the consulted implementation-status document, WebMCP has an active Chrome 149 origin trial and an Edge 150 origin trial ("aligned to Chrome's implementation"); Brave has experimental exploration in Leo AI chat; Firefox has an open standards-positions issue and Bugzilla entry under review; Safari/WebKit has an open standards-positions issue pending evaluation. No browser besides Chrome/Edge ships or trials it.
- Evidence: Repository doc summary: "Chrome: An Origin Trial is currently active in Chrome 149... Edge: An Origin Trial is live in Edge 150... Brave: Experimental support is being explored... Firefox: Under standards review... Safari: Pending standards evaluation."
- Source: https://github.com/webmachinelearning/webmcp/blob/main/implementation-status.md (consulted 2026-09-04)

### Two registration mechanisms: imperative and declarative

- Claim: WebMCP supports both a JavaScript imperative API (`registerTool`, as above) and a declarative API that adds annotations directly to standard HTML `<form>` elements to create a tool without JavaScript.
- Evidence: Chrome docs: "Declarative API: Add annotations to a standard HTML forms to create a WebMCP tool." Repository has a dedicated `declarative-api-explainer.md` file separate from the imperative spec (`index.bs`).
- Source: https://developer.chrome.com/docs/ai/webmcp; https://github.com/webmachinelearning/webmcp (both consulted 2026-09-04)

### Security/permissions gating relevant to lifecycle

- Claim: The API requires the document to be origin-isolated (disabled if the response sends `Origin-Agent-Cluster: ?0`), and access is gated by a `tools` Permissions Policy that defaults to `self`; cross-origin iframes must be granted `allow="tools"` to use it.
- Evidence: Chrome docs quotes: "Origin Isolation: Required; disabled if `Origin-Agent-Cluster: ?0` header present." "Permissions Policy: Gated by `tools` policy; defaults to `self`; cross-origin iframes need `allow=\"tools\"`." Spec IDL corroborates a `SecureContext` requirement on both the `Document.modelContext` attribute and the `ModelContext` interface itself.
- Source: https://developer.chrome.com/docs/ai/webmcp; https://raw.githubusercontent.com/webmachinelearning/webmcp/main/index.bs (both consulted 2026-09-04)

### Explicit "not for headless automation" framing

- Claim: Chrome's docs explicitly frame WebMCP as designed for human-in-the-loop, local browser workflows, not headless/unattended agent automation, though headless use "may be possible."
- Evidence: Quote: "While it may be possible to run WebMCP tools in headless environments, this API is primarily designed for local browser workflows with a human in the loop."
- Source: https://developer.chrome.com/docs/ai/webmcp (consulted 2026-09-04)

### Open issue/PR volume as a stability signal

- Claim: The `webmachinelearning/webmcp` GitHub repository had approximately 116 open issues and 15 open pull requests at time of consultation, indicating active, unsettled design discussion (e.g., issue #130 "Tool unregistration design" is open, meaning even tool lifecycle teardown semantics are not finalized).
- Evidence: WebFetch summary of the repository page reporting issue/PR counts; targeted search surfaced the open issue "Tool unregistration design · Issue #130."
- Source: https://github.com/webmachinelearning/webmcp (consulted 2026-09-04); https://github.com/webmachinelearning/webmcp/issues/130 (title only, consulted 2026-09-04 via search, not opened directly) — `[UNVERIFIED: exact current open issue/PR count, since this number changes continuously and was read from a single point-in-time fetch]`

## Options considered

This research question does not admit competing "options" in the usual sense (it is a single external API's shape, not a choice between alternatives for our own design). The one place a real choice exists is which global/entry-point our Dart interop bindings should target:

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Bind only to `document.modelContext` | Matches the current formal spec IDL (`index.bs`, most recently dated primary source) | Low churn if spec is followed as-is; risk of breaking on Chrome's actual shipped origin-trial build if it still uses `navigator.modelContext` | Preferred as primary target, since it is the most authoritative, most recently confirmed source, but must be paired with a fallback (see below) — decision for the planning phase, not this research |
| Bind only to `navigator.modelContext` | Matches the original Intent-to-Experiment description and the 2025 explainer code samples | Matches what Chrome's origin trial may have actually shipped in M149 (unverified); risks being the "legacy alias" per third-party corroboration | Not chosen alone — third-party sources suggest it is only an alias, not verified from spec/Chrome docs directly |
| Feature-detect both (`document.modelContext ?? navigator.modelContext`) at runtime | Defensive coding acknowledging the spec has moved and Chrome's shipped build may lag or lead the spec text | Slightly more interop surface to maintain | This is a scoping/architecture decision that belongs to the planning phase of this work item, not to this research artifact — flagged here as the key input the plan phase needs |

## Constraints discovered

- WebMCP is **not a shipped, stable web platform feature**. It is a CG-DRAFT specification with an active Chrome-only origin trial (M149–M156) and a shipping target of M157 — both of which are Chrome milestones that could slip, since origin trials are explicitly experiments Chrome reserves the right to change or cancel.
- The exact JS entry point (`document.modelContext` vs `navigator.modelContext`) is **inconsistent across the project's own primary sources** as of 2026-09-04. Any Dart/JS-interop binding built against one alone risks breaking against the other.
- The handler/callback signature has already changed shape once between the original explainer (`execute: ({ text }, agent) => {...}`) and the current IDL (`execute(inputObject, { signal })`) — meaning even the "confirmed" spec shape should not be treated as final.
- No browser besides Chrome and Edge (both Chromium-based) currently ships or trials WebMCP; Firefox and Safari have only opened standards-positions discussions with no committed implementation. A Flutter package built on this API is Chromium-only for the foreseeable future.
- The API requires a secure context and origin isolation (`Origin-Agent-Cluster` not disabled), and is Permissions-Policy gated (`tools`, default `self`) — this affects how/where a Flutter web app embedding WebMCP tooling can even attempt to call the API, especially inside iframes.
- Tool lifecycle semantics (e.g., unregistration) are tracked as still-open design issues in the spec repository, meaning any Dart wrapper around tool teardown is binding against an unfinished contract.
- Origin-trial usage in production requires registering the origin at developer.chrome.com/origintrials; local development instead requires enabling a Chrome flag, per Chrome's docs.

## Unresolved

- [UNRESOLVED: Which global object does the actual Chrome 149 origin-trial *binary* expose today — `document.modelContext`, `navigator.modelContext`, or both as aliases? This could not be confirmed from the spec text or Chrome docs alone; it would require testing against a live Chrome 149+ build with the origin trial token or the `#enable-webmcp-testing` flag enabled.]
- [UNRESOLVED: Is `chrome://flags/#enable-webmcp-testing` the current correct local-dev flag, or does it coexist with/supersede the generic "Experimental Web Platform features" flag referenced in the original Intent-to-Experiment? Not confirmed against a live `chrome://flags` listing.]
- [UNRESOLVED: What exact `outputSchema` mechanism exists, if any? Chrome's docs prose mentions an "outputSchema" concept ("expected return format"), but the current `index.bs` IDL fetched here shows only `inputSchema` on `ModelContextTool`/`RegisteredTool` and a `Promise<DOMString>` return type on `executeTool` — no `outputSchema` field appeared in the IDL extraction. This is a direct discrepancy between Chrome's descriptive docs and the spec's formal IDL that needs a closer, line-by-line read of `index.bs` (ideally by fetching the file in chunks rather than via a summarizing fetch) to resolve.]
- [UNRESOLVED: Current exact open issue/PR count on the spec repository, and which specific open issues (beyond #130) most directly affect the shape a Dart interop binding would need to track.]
- [UNRESOLVED: Whether the `exposedTo` field on `ModelContextRegisterToolOptions` and the `fromOrigins` field on `ModelContextGetToolOptions` have defined semantics finalized in the spec prose (not just the IDL signature) — the IDL was retrieved but the accompanying algorithmic/prose text explaining exact cross-origin exposure rules was not read in this pass.]

## Sources

- https://developer.chrome.com/docs/ai/webmcp — consulted 2026-09-04 (Chrome's canonical WebMCP docs page; fetched twice with different extraction prompts)
- https://github.com/webmachinelearning/webmcp — consulted 2026-09-04 (spec/explainer repository root)
- https://webmachinelearning.github.io/webmcp/ — consulted 2026-09-04 (rendered CG Draft Report)
- https://raw.githubusercontent.com/webmachinelearning/webmcp/main/index.bs — consulted 2026-09-04 (formal Bikeshed spec source, primary authority for IDL)
- https://webmachinelearning.github.io/webmcp/docs/proposal.html — consulted 2026-09-04 (earlier/parallel explainer with `navigator.modelContext` code samples, dated August 2025 per its own content)
- https://github.com/webmachinelearning/webmcp/blob/main/implementation-status.md — consulted 2026-09-04 (cross-browser/agent implementation status)
- https://chromestatus.com/feature/5117755740913664 — consulted 2026-09-04 (Chrome Platform Status entry; page is client-rendered, direct fetch returned only page shell, milestone data obtained via search synthesis instead — treat with the caveat noted inline above)
- https://groups.google.com/a/chromium.org/g/blink-dev/c/gmYffo5WOE8/m/OJxuQRP3AAAJ — consulted 2026-09-04 ("Intent to Experiment: WebMCP" blink-dev thread)
- https://github.com/webmachinelearning/webmcp/issues/130 — consulted 2026-09-04 (title/existence only, via search result, not opened directly; corroboration of open lifecycle design questions)
- Corroboration only, not used for API-shape claims without flagging as unverified: https://www.openhermit.com/blog/navigator-modelcontext-2026 (consulted 2026-09-04); https://www.webfuse.com/webmcp-cheat-sheet (consulted 2026-09-04); https://ppc.land/chrome-149-origin-trial-puts-webmcp-in-developers-hands-at-last/ (title only, not opened, consulted via search 2026-09-04); https://www.infoq.com/news/2026/06/webmcp-web-agent-standard-chrome/ (title only, not opened, consulted via search 2026-09-04)
