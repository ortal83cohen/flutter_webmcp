# Research review — round 01

- Work item: 0002-flutter-webmcp-stack
- Reviewed artifact: `wiki/work/0002-flutter-webmcp-stack/00-research.md` (git revision 663cf48, working tree clean)
- Reviewer: research validator (blind — artifact and `02-criteria.md` only; no author transcript, notes or self-assessment consulted)
- Date: 2026-09-04

## Verdict

**FAIL**

The artifact's headline recommendation names the wrong host object for the browser API bridge (contradicting the artifact's own Finding two paragraphs later and the current IDL), and a spec design question it reports as open has been closed since 2026-03-26; both are load-bearing for the bridge and unregistration design a plan would build on, so this returns to the research phase rather than being patched forward.

## Verification performed

No shell tool was available in this review session, so `tools/lint_wiki.py` was not run; all verification below is source fetching, performed by the reviewer, not accepted from the artifact.

Sources opened and what they actually say:

1. `https://raw.githubusercontent.com/webmachinelearning/webmcp/main/index.bs`
   - `Status: CG-DRAFT` — confirms artifact line 17.
   - `partial interface Document { [SecureContext, SameObject] readonly attribute ModelContext modelContext; };` — the attribute is on **Document**, not Navigator.
   - `interface ModelContext : EventTarget` with `registerTool`, `getTools`, `executeTool`, `attribute EventHandler ontoolchange` — confirms artifact line 29.
   - `dictionary ModelContextTool { required DOMString name; USVString title; required DOMString description; object inputSchema; required ToolExecuteCallback execute; ToolAnnotations annotations; };` and `callback ToolExecuteCallback = Promise<any> (object inputObject, ToolExecuteCallbackOptions options);` with `required AbortSignal signal` — confirms artifact line 29.
   - Name rule: "The [tool definition/name]'s length must be between 1 and 128, inclusive, and only consist of ASCII alphanumeric code points, U+005F LOW LINE (_), U+002D HYPHEN-MINUS (-), and U+002E FULL STOP (.)" — confirms artifact line 29 and grounds AC-006.
   - `outputSchema` does not appear — see F-006 context.

2. `https://webmachinelearning.github.io/webmcp/docs/proposal.html` — dated August 13, 2025; uses `window.navigator.modelContext` and `if ("modelContext" in window.navigator)`; handler shape `execute: ({ text }, agent) => { ... }`. Confirms artifact line 23's contrast.

3. `https://groups.google.com/a/chromium.org/g/blink-dev/c/gmYffo5WOE8/m/OJxuQRP3AAAJ` — posted May 15, 2026. Milestone table: DevTrial 146, OT start 149, OT end 156, Shipping 157. Confirms artifact lines 17 and 97.

4. `https://raw.githubusercontent.com/webmachinelearning/webmcp/main/implementation-status.md` — full raw text retrieved. Contains sections for **Brave** ("Experimental support is added to Leo AI chat", issue 55232) and **ChatGPT Desktop** ("WebMCP is supported in ChatGPT Desktop") in addition to Chrome 149 and Edge 150. See F-005.

5. `https://developer.chrome.com/docs/ai/webmcp` — confirms `chrome://flags/#enable-webmcp-testing`, "WebMCP is only available in origin-isolated documents", "Both APIs are gated by the `tools` Permissions Policy. The policy defaults to `self`", and "this API is primarily designed for local browser workflows with a human in the loop". The phrase "Both APIs" refers to an Imperative API and a Declarative API, each with its own documentation page. See F-004.

6. `https://developer.chrome.com/docs/ai/webmcp/imperative-api` — **Published May 18, 2026, last updated September 1, 2026** (three days before the artifact's stated consultation date). Every code sample uses `document.modelContext`: `await document.modelContext.registerTool(...)`, `const [tool] = await document.modelContext.getTools();`, `await document.modelContext.executeTool(tool, '{"text": "Buy milk"}')`. Unregistration is documented as `const controller = new AbortController(); await document.modelContext.registerTool(addTodoTool, {signal: controller.signal}); controller.abort();` and "As of Chrome 153, you can unregister a tool without cancelling and breaking in-flight executions." Also documents an `exposedTo` array on `registerTool` options. This URL does not appear in the artifact's Sources list (lines 116-149).

7. `https://developer.chrome.com/docs/ai/webmcp/declarative-api` — published May 18, 2026. Documents a form-annotation API (`toolname`, `tooldescription`, `toolparamdescription`, `toolautosubmit`). Not mentioned anywhere in the artifact.

8. `https://api.github.com/repos/webmachinelearning/webmcp/issues/130` — `"title": "Tool unregistration design"`, `"state": "closed"`, `"created_at": "2026-03-05T04:41:33Z"`, `"closed_at": "2026-03-26T15:06:18Z"`. See F-002.

9. `https://pub.dev/packages/web` — latest version 1.1.1. Confirms artifact line 41.

10. `https://pub.dev/packages/go_router` — latest version 18.0.1. Confirms artifact line 53.

11. `https://pub.dev/documentation/go_router/latest/go_router/GoRouter-class.html` (docs for 18.0.1) — `configuration` is a public `late final RouteConfiguration`, no `@internal`/`@visibleForTesting` annotation. `https://pub.dev/documentation/go_router/latest/go_router/RouteConfiguration-class.html` — `routes → List<RouteBase>`, public. Confirms artifact line 53.

12. `https://dart.dev/interop/js-interop/usage` — "Extensions can have `external` instance members and operators, but can't have `external` `static` members or constructors... These extensions are useful for when an interop type doesn't expose the `external` member you need, and you don't want to create a new interop type." Confirms the *technique* claimed at artifact lines 41-42.

13. `https://api.dart.dev/dart-js_interop_unsafe/JSObjectUnsafeUtilExtension.html` — `has`, `hasProperty`, `getProperty`, `setProperty`, `callMethod`, `delete` all present. Confirms artifact line 47.

14. `https://pub.dev/packages/flutter_webmcp` — v0.3.0, publisher `kicknext.dev` (verified), MIT, 160 pub points, "A typed Dart API for exposing Flutter Web actions as WebMCP tools." README documents `WebMcpToolScope`, `WebMcp.support`, typed input decoding via `fromJson`, and states "WebMCP requires `document.modelContext`. It is available in ChatGPT's in-app browser." No mention of `go_router` or navigation-tool generation. Confirms artifact line 65 and, incidentally, supports the differentiation premise at line 68.

15. `https://pub.dev/packages/flutter_webmcp/score` — five categories: conventions 30/30, documentation 20/20, platform support 20/20, static analysis 50/50, up-to-date dependencies 40/40, total 160/160. Confirms artifact line 78's numeric breakdown.

16. `https://pub.dev/packages/intentcall_webmcp` — v0.6.0, publisher `xsoulspace.dev`, "Pre-release train — Highly experimental. APIs may change without notice. Not for production." Mentions `document.modelContext` as the target and `navigator.modelContext` as "older experiments treated as a compatibility shim". Confirms artifact line 65.

17. `https://pub.dev/packages?q=webmcp` — returns `flutter_webmcp`, `intentcall_webmcp`, **`intentcall_platform` v0.6.0** ("platform emitters and sync for intentcall covering web manifests, WebMCP JS, native handoff, and Apple App Intents scaffolds"), `intentcall_core`, plus unrelated `web_*` packages. See F-008.

## Per-criterion results

Not applicable — this is a research review, not an implementation review. The criteria in `02-criteria.md` were used only to judge whether the research grounds a plan that could satisfy them. Grounding coverage was adequate for AC-005/AC-006 (name rule verified against the IDL), AC-013 (go_router route-table access verified, though `02-criteria.md` line 49 excludes go_router from the skeleton), AC-002/AC-003 (package layout and pana categories verified), and AC-016 through AC-021 (toolchain criteria that this research does not attempt to ground and does not need to). Grounding is defective for AC-011 and AC-012, which depend on which global the support query probes and which single file holds the web-only import — see F-001 and F-003 — and for AC-007/AC-009, whose unregister/withdraw seam is grounded on a design question the artifact reports as open — see F-002.

## Findings

### F-001 — The recommended bridge extends `Navigator`, but the current API is on `Document`

- Severity: BLOCKER
- Location: `wiki/work/0002-flutter-webmcp-stack/00-research.md:9`, restated at `:86`
- Criterion affected: AC-011, AC-012
- Observation: Line 9 recommends "adding an `extension` with `external` members onto `package:web`'s existing `Navigator` type", and the Options-considered table at line 86 makes this the Chosen row with the concrete signature `extension NavigatorModelContext on Navigator { external JSObject? get modelContext; }`. The artifact's own Finding at line 23 states that the current formal IDL exposes the attribute on `partial interface Document`. I confirmed that IDL verbatim in `index.bs`, and confirmed that every code sample on Chrome's Imperative API page (last updated 2026-09-01) uses `document.modelContext`. The Options table contains no row weighing `Document` against `Navigator` as the extension host at all; the single chosen row asserts `Navigator` without comparison.
- Why it matters: This is the one sentence of the Answer a plan would transcribe into an interface. A plan grounded on it produces a bridge file whose `external` getter hangs off the wrong host object, and a support query (AC-011) that probes a property the current API does not expose there. The artifact's own body contradicts its Answer, so the defect cannot be resolved by reading further into the document.

### F-002 — Tool-unregistration is reported as an open design issue; issue #130 closed on 2026-03-26

- Severity: BLOCKER
- Location: `wiki/work/0002-flutter-webmcp-stack/00-research.md:35`, source qualifier at `:124`
- Criterion affected: AC-007, AC-009
- Observation: Line 35 claims "tool-unregistration semantics are still an open design issue (#130) in the spec repo." The GitHub API for that issue returns `"state": "closed"`, `"closed_at": "2026-03-26T15:06:18Z"`. Chrome's Imperative API documentation documents the resolved mechanism — an `AbortSignal` passed in `registerTool`'s options, with `controller.abort()` performing the unregistration — and states "As of Chrome 153, you can unregister a tool without cancelling and breaking in-flight executions." The artifact's own Sources line 124 records that this issue was consulted "(title only)", so the open/closed state was never checked. The artifact also never records what `ModelContextRegisterToolOptions` contains, which is where that signal lives.
- Why it matters: AC-007 and AC-009 specify a name-keyed `unregister` and a transport `withdraw` call. The browser's actual contract is signal-keyed and tied to the original registration, which is a materially different seam shape. A plan built on "semantics still open" will either defer the decision or invent one, when the answer is documented and shipped.

### F-003 — A primary source that answers the artifact's top unresolved question was never consulted

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/00-research.md:106` (and the `[UNVERIFIED]` at `:25`); Sources list `:116`-`:149`
- Criterion affected: AC-011
- Observation: The first unresolved item states that which global the shipped Chrome 149+ binary exposes is "not confirmed from spec/docs text alone; needs testing against a live flagged Chrome build." Chrome's own Imperative API reference page, `https://developer.chrome.com/docs/ai/webmcp/imperative-api`, published 2026-05-18 and last updated 2026-09-01, documents the origin-trial API entirely through `document.modelContext` across registration, discovery and execution samples. That URL is absent from the Sources list; only the parent `docs/ai/webmcp` overview page was consulted. Separately, `flutter_webmcp`'s README — a source the artifact did consult, line 67 — states "WebMCP requires `document.modelContext`."
- Why it matters: The question is not merely unresolved, it is resolvable from Chrome's own documentation, and the failure to consult the page is what allowed F-001 to stand. Recording a documented fact as needing live-browser testing sends the plan phase to acquire evidence it does not need while leaving the wrong recommendation in place.

### F-004 — The Declarative API is never named, so only one of Chrome's two documented APIs was considered

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/00-research.md:35` (Chrome-docs finding), Options table `:84`-`:93`
- Criterion affected: none
- Observation: Chrome documents two WebMCP surfaces: an Imperative API and a Declarative API (`https://developer.chrome.com/docs/ai/webmcp/declarative-api`, published 2026-05-18), the latter annotating HTML forms with `toolname`, `tooldescription`, `toolparamdescription` and `toolautosubmit`. The overview page the artifact cites for its Permissions-Policy quote says "Both APIs are gated by the `tools` Permissions Policy", which is the plural the artifact's line 35 silently drops. The research question at line 5 explicitly asks for "the browser API's real shape", and the Options-considered table contains no row for declarative versus imperative.
- Why it matters: A viable option that was not considered. Even if the declarative surface is inapplicable to a canvas-rendering Flutter Web app — a conclusion that is plausible but is nowhere stated or evidenced in the artifact — the plan should inherit the reasoning that dismissed it, not the silence.

### F-005 — "No other browser ships or trials it" is contradicted by the cited implementation-status file

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/00-research.md:17`, restated at `:97`
- Criterion affected: none
- Observation: Line 17 claims "No other browser ships or trials it (Edge trials in parallel as a Chromium browser; Firefox/Safari have only open standards-positions issues)", citing `implementation-status.md`. That file's full text contains two further sections the claim omits: "Brave — Experimental support is added to Leo AI chat" and "ChatGPT Desktop — WebMCP is supported in ChatGPT Desktop." The `flutter_webmcp` README, also cited by the artifact, independently states the API "is available in ChatGPT's in-app browser."
- Why it matters: The claim is refuted by the source cited to support it. It also propagates into the constraint at line 97 ("WebMCP is Chrome-only (plus Edge, both Chromium)"), which frames the whole package's reachable audience.

### F-006 — An `[UNVERIFIED]` raised in the body is absent from the Unresolved list

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/00-research.md:74`; Unresolved section `:104`-`:112`
- Criterion affected: none
- Observation: Line 74 carries `[UNVERIFIED: whether this toolkit is still the maintained/recommended entry point now that Chrome ships a native implementation]` about the MCP-B / `WebMCP-org` reference implementation. No corresponding entry appears among the seven Unresolved items. By contrast the `[UNVERIFIED]` at line 25 is correctly mirrored at line 106, so the omission is inconsistent within the artifact rather than a deliberate convention.
- Why it matters: The Unresolved list is the register a plan reads to decide what still needs answering. A question that lives only in a Findings footnote will not be picked up.

### F-007 — Registration options are described without their contents, omitting `signal` and `exposedTo`

- Severity: NIT
- Location: `wiki/work/0002-flutter-webmcp-stack/00-research.md:29`
- Criterion affected: none
- Observation: The finding lists `registerTool(tool, options)` and enumerates the tool dictionary in full, but never states what `ModelContextRegisterToolOptions` holds. The IDL and Chrome's Imperative API page put the `AbortSignal` there, and Chrome additionally documents an `exposedTo` origin array on the same options object.
- Why it matters: Minor on its own; it is the gap through which F-002 entered.

### F-008 — "No other pub.dev 'mcp' package touches the browser WebMCP surface" overlooks a result in the cited search

- Severity: NIT
- Location: `wiki/work/0002-flutter-webmcp-stack/00-research.md:65`, search source at `:145`
- Criterion affected: none
- Observation: `https://pub.dev/packages?q=webmcp`, cited at line 145, returns `intentcall_platform` v0.6.0, described as covering "web manifests, WebMCP JS, native handoff, and Apple App Intents scaffolds", alongside the two packages the artifact names. It is a sibling of `intentcall_webmcp` from the same publisher, so the substance of the competitive picture is unchanged.
- Why it matters: The claim is stated absolutely and a result in the cited search page contradicts it.

### F-009 — The Answer states the differentiation as settled while the Unresolved list records that no capability diff exists

- Severity: NIT
- Location: `wiki/work/0002-flutter-webmcp-stack/00-research.md:11` and `:68`, against `:110`
- Criterion affected: none
- Observation: Lines 11 and 68 record the decision to ship a differentiated package emphasising "stronger router-driven auto-navigation and dev-time tooling" without an inline caveat, while line 110 correctly records that no line-by-line capability diff against `KickNext/flutter_webmcp` or `intentcall_webmcp` has been performed. I checked `flutter_webmcp`'s README independently: it mentions no `go_router` integration or navigation-tool generation, which happens to support the differentiation premise — but that evidence is not in the artifact.
- Why it matters: The evidence gap is honestly registered at line 110, so this is a placement issue rather than a suppressed question. Flagged because the decision to build alongside a 160/160 incumbent is the artifact's highest-stakes conclusion and the reader of the Answer alone would not know it rests on an unperformed comparison.

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
| F-007 | research (NIT, no action required) |
| F-008 | research (NIT, no action required) |
| F-009 | research (NIT, no action required) |
