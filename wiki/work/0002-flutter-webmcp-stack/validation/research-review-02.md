# Research review — round 02

- Work item: 0002-flutter-webmcp-stack
- Reviewed artifact: `wiki/work/0002-flutter-webmcp-stack/00-research.md` (working tree at branch `main`, HEAD `663cf48`)
- Reviewer: research validator (blind — artifact plus `02-criteria.md` only; no author transcript, notes or self-assessment consulted; `validation/research-review-01.md` was opened only after all findings below were formed, and only to complete the recurrence check)
- Date: 2026-09-04

## Verdict

**PASS**

Every load-bearing claim I re-fetched from a primary source — the `Document` entry point, the closed state of issue #130 and its `AbortSignal` resolution, the origin-trial milestones, the non-Chromium application-level implementations, the tool-name rule, the `go_router` route-table access path and the 160-point pana breakdown — is supported by the source cited for it, so nothing invalidates the approach a plan would build on; the four `IMPORTANT` findings are unsourced or unverifiable side-claims and one unconsulted directly-relevant source, none of which violates a criterion in `02-criteria.md`.

## Verification performed

No shell tool was available in this session, so `python3 tools/lint_wiki.py` was not run and no repository command output is pasted. All verification below is primary-source fetching performed by me. I did not accept any "corrected 2026-09-04" claim in the artifact without re-checking the source myself.

1. `https://raw.githubusercontent.com/webmachinelearning/webmcp/main/index.bs`
   - `Status: CG-DRAFT` — supports `00-research.md:19`.
   - `partial interface Document { [SecureContext, SameObject] readonly attribute ModelContext modelContext; };` — supports `:25`. No `modelContext` on `Navigator` anywhere in the file.
   - `interface ModelContext : EventTarget` with `registerTool`, `getTools`, `executeTool`, `attribute EventHandler ontoolchange` — supports `:32`. Note `Promise<DOMString> executeTool(RegisteredTool tool, ...)`.
   - `dictionary ModelContextTool { required DOMString name; USVString title; required DOMString description; object inputSchema; required ToolExecuteCallback execute; ToolAnnotations annotations; };` and `callback ToolExecuteCallback = Promise<any> (object inputObject, ToolExecuteCallbackOptions options);` — supports `:32` except as noted in F-005.
   - `dictionary ModelContextRegisterToolOptions { sequence<USVString> exposedTo; AbortSignal signal; };` with "An AbortSignal that unregisters the tool when aborted." — supports `:44`.
   - "must be between 1 and 128, inclusive, and only consist of ASCII alphanumeric code points, U+005F LOW LINE (_), U+002D HYPHEN-MINUS (-), and U+002E FULL STOP (.)" — supports `:32` and grounds AC-006.
   - "the policy-controlled feature 'tools', which has a default allowlist of 'self'" and the origin-keyed agent-cluster `SecurityError` step — support `:38`.
   - Searched for `outputSchema`: no occurrence. See F-003.

2. `https://api.github.com/repos/webmachinelearning/webmcp/issues/130` — `"title": "Tool unregistration design"`, `"state": "closed"`, `"created_at": "2026-03-05T04:41:33Z"`, `"closed_at": "2026-03-26T15:06:18Z"`, `"state_reason": "completed"`. Supports `:44` and `:117`. The artifact's characterisation of the issue as closed is correct.

3. `https://developer.chrome.com/docs/ai/webmcp/imperative-api` — "Published: May 18, 2026", "Last updated: September 1, 2026", matching `:25`. Every sample uses `document.modelContext` (`registerTool`, `getTools`, `executeTool`, `addEventListener("toolchange", ...)`). Unregistration is documented via `AbortController`/`{signal}`, and verbatim: "As of Chrome 153, you can unregister a tool without cancelling and breaking in-flight executions." `exposedTo` is documented as "list specific origins allowed to view and execute a tool." Supports `:25` and `:44`. Searched for `outputSchema`: no occurrence.

4. `https://developer.chrome.com/docs/ai/webmcp` — published 2026-05-18, last updated 2026-08-07. Verbatim: "Both APIs are gated by the `tools` Permissions Policy. The policy defaults to `self`" — supports `:25` and `:38`. Also confirms `chrome://flags/#enable-webmcp-testing`, "WebMCP is only available in origin-isolated documents", the `Origin-Agent-Cluster: ?0` disabling condition, and "This API is primarily designed for local browser workflows with a human in the loop." No occurrence of `outputSchema`.

5. `https://developer.chrome.com/docs/ai/webmcp/declarative-api` — published and last updated 2026-05-18. Attributes `toolname`, `tooldescription`, `toolparamdescription`, `toolautosubmit`, applied to `<form>` and to individual fields. Supports `:25`. No occurrence of `outputSchema`.

6. `https://raw.githubusercontent.com/webmachinelearning/webmcp/main/implementation-status.md` — sections for Brave ("Experimental support is added to Leo AI chat", issue 55232), ChatGPT Desktop ("WebMCP is supported in ChatGPT Desktop"), Chrome 149, Edge 150, and standards-position-only entries for Firefox (mozilla/standards-positions #1412, Bugzilla #2018306) and Safari (WebKit standards-positions #670). Supports `:19` including the browser-exclusivity qualification.

7. `https://groups.google.com/a/chromium.org/g/blink-dev/c/gmYffo5WOE8/m/OJxuQRP3AAAJ` — "Intent to Experiment: WebMCP", 2026-05-15. Milestone table: DevTrial 146, Origin Trial first 149, last 156, Shipping 157. Supports `:19` and `:107`. The thread names the generic "Experimental Web Platform features" flag, which is consistent with the open question recorded at `:118`.

8. `https://webmachinelearning.github.io/webmcp/docs/proposal.html` — dated August 13, 2025, uses `window.navigator.modelContext`, handler shape `execute({ name, ... }, agent)`. Supports the "earlier design" contrast at `:25` and the signature-change claim at `:32`.

9. `https://pub.dev/documentation/go_router/latest/go_router/GoRouter-class.html` and `.../RouteConfiguration-class.html` (both docs for 18.0.1) — `configuration` is a public `late final RouteConfiguration` with no `@internal`/`@visibleForTesting` annotation; `RouteConfiguration.routes → List<RouteBase>` is public and read-only. Supports `:62`.

10. `https://docs.flutter.dev/ui/navigation` — verbatim: "Flutter applications with advanced navigation and routing requirements ... should use a routing package such as go_router". Supports the "Flutter's own docs point developers to `go_router`" clause at `:62`. The page does not discuss route-table introspection either way; the artifact's stronger inference there is not contradicted by any source I found.

11. `https://dart.dev/interop/js-interop/usage` (via dart.dev site search, which surfaced the passage the page render dropped) — "Extensions can have external instance members and operators, but can't have external static members or constructors ... These extensions are useful for when an interop type doesn't expose the external member you need, and you don't want to create a new interop type." Supports the *technique* at `:50`; see F-006 for the quoted phrasing.

12. `https://dart.dev/interop/js-interop/package-web` — the only guidance for a missing binding is "consider filing an issue or uploading a pull request to `package:web`"; the page does not recommend extending existing `package:web` types, and says nothing about absent-property getter behaviour. `https://dart.dev/interop/js-interop/js-types` likewise contains neither. Relevant to F-002 and F-006.

13. `https://api.dart.dev/dart-js_interop_unsafe/JSObjectUnsafeUtilExtension.html` — `has(String) → bool`, `hasProperty(JSAny) → JSBoolean`, `getProperty`, `setProperty`, `delete`, `callMethod` all present. Supports the existence-check half of `:56`. Contains no statement about what an external getter returns for an absent property.

14. `https://pub.dev/packages/flutter_webmcp` and `https://raw.githubusercontent.com/KickNext/flutter_webmcp/main/README.md` — v0.3.0, publisher `kicknext.dev` (verified), MIT, 160 pub points, 6/6 platforms. README documents `WebMcpToolScope` ("registers tools while the feature is mounted"), `WebMcp.support` feature detection, `decodeInput`/`WebMcpTypedTool<T>` typed decoding, and "WebMCP requires `document.modelContext`." No mention of `go_router` or navigation-tool generation. Supports `:74` and the partial-evidence clause at `:121`.

15. `https://pub.dev/packages/flutter_webmcp/score` — conventions 30/30, documentation 20/20, platform support 20/20, static analysis 50/50, up-to-date dependencies 40/40, total 160/160. Supports the five-category, 160-point breakdown at `:87`. (`https://pub.dev/help/scoring` renders category names without numbers, exactly as the artifact says at `:87`.)

16. `https://pub.dev/packages/intentcall_webmcp` — v0.6.0, `xsoulspace.dev`, "Highly experimental. APIs may change without notice. Not for production.", and "Dart-first registry hot-sync to WebMCP `document.modelContext` tool registration, with older `navigator.modelContext` experiments treated as a compatibility shim." Supports `:25` and `:74`.

17. `https://pub.dev/packages?q=webmcp` and `https://pub.dev/packages?q=model+context+protocol+web` — the only WebMCP-surface packages are `flutter_webmcp`, `intentcall_webmcp` and `intentcall_platform` ("web manifests, WebMCP JS, native handoff, and Apple App Intents"); every other `mcp` result (`mcp_dart`, `mcp_server`, `mcp_client`, `agentic_mcp`, `ai_sdk_mcp`, `mcp_bridge`, `dart_pubdev_mcp`, `scout_mcp`) is server-side or native. Supports `:74` except as noted in F-007.

18. `https://developer.chrome.com/docs/devtools/application/webmcp` ("Debug WebMCP tools", last updated 2026-05-12) — a shipped Chrome DevTools panel under Application that lists every registered tool with the name and description as the agent sees it, keeps a filterable invocation log with Status/Input/Output, executes tools manually with custom parameters, and reports schema violations. Not cited anywhere in the artifact. See F-001.

19. `https://pub.dev/packages/web` — latest published version 1.1.1, publisher dart.dev. Supports the version half of `:50`. `https://raw.githubusercontent.com/dart-lang/web/main/web/pubspec.yaml` is now `2.0.0-wip` (`sdk: ^3.12.0`), so it does not speak to 1.1.1's constraint; I could not confirm or refute the "SDK ≥3.4" half from a primary source, and treat it as immaterial to the plan.

## Per-criterion results

Not applicable — this is a research review, not an implementation review. `02-criteria.md` was used only to judge whether the research grounds a plan that could satisfy it. Grounding is adequate: AC-006's name rule matches the IDL verbatim (verification item 1); AC-007/AC-009's unregister/withdraw seam is now grounded on the resolved `AbortSignal` mechanism (items 1, 2, 3); AC-011/AC-012 are grounded on the confirmed `document.modelContext` entry point and the `dart:js_interop`/`package:web` import surface (items 1, 3, 11, 13); AC-013's route source is grounded on the public `RouteConfiguration.routes` getter (item 9), which `02-criteria.md:49` in any case excludes from the skeleton; AC-002/AC-003 are grounded on the layout and pana findings (item 15); AC-016 through AC-021 are toolchain criteria this research does not attempt to ground and does not need to.

## Findings

### F-001 — Chrome's shipped WebMCP DevTools panel is unconsulted, and the "dev-time tooling" differentiator rests on nothing

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/00-research.md:11`, restated at `:77` and `:103`; Sources list `:129`-`:139`
- Criterion affected: none
- Observation: The artifact records the differentiation decision three times as "stronger router-driven auto-navigation and dev-time tooling" / "dev-time agent tooling", and the research question at `:5` explicitly scopes "an in-browser or dev-time AI agent". Chrome documents a shipped DevTools surface for exactly this at `https://developer.chrome.com/docs/devtools/application/webmcp` (last updated 2026-05-12): a WebMCP pane in the Application panel that lists every registered tool with the agent-visible name and description, keeps a filterable invocation log with Status/Input/Output, executes tools manually with custom parameters, and surfaces schema violations. That URL appears nowhere in the artifact's Sources list, and the `WebMCP-org/MCP-B` finding at `:79`-`:83` — the only place browser-side tooling is discussed — does not mention it. The Unresolved item at `:121` registers that no capability diff against the two pub.dev packages exists, but says nothing about the dev-time half of the differentiator.
- Why it matters: Of the two claimed differentiators, one (router-driven auto-navigation) has partial evidence recorded at `:121`; the other has none, and the most obvious thing it would have to be better than is a first-party Chrome panel that already does tool listing, manual invocation and logging. A plan phase told to "establish concrete differentiation" will do so against an incomplete map of what already exists.

### F-002 — The absent-property getter claim is attributed to two sources that do not state it

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/00-research.md:56`, sources at `:58`
- Criterion affected: none
- Observation: The finding asserts that "An `external` getter for an absent JS property resolves to `null`/`undefined` rather than throwing" and that "calling a method on a null/undefined reference does throw", citing `https://api.dart.dev/dart-js_interop_unsafe/JSObjectUnsafeUtilExtension.html` and `https://dart.dev/interop/js-interop/usage`. I opened both. The API page documents only `has`, `hasProperty`, `getProperty`, `setProperty`, `delete` and `callMethod` and says nothing about absent-property getter behaviour; the usage page does not address it either, and neither does `https://dart.dev/interop/js-interop/package-web` or `.../js-types`. The claim carries no `[UNVERIFIED]` marker while the artifact's neighbouring uncertain claims do.
- Why it matters: `AGENTS.md` requires an unverified fact to be marked. The claim is the stated justification for why a presence check is needed at all, and it is the half of the sentence a plan would rely on when specifying what the support query may safely do before it has confirmed support. The design consequence is mitigated — the artifact prescribes `has()`/`hasProperty` regardless — which is why this is not a blocker.

### F-003 — The `outputSchema` unresolved item asserts an unsourced premise I could not confirm on any cited Chrome page

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/00-research.md:119`
- Criterion affected: none
- Observation: The item reads "The exact `outputSchema` mechanism Chrome's docs prose mentions, which does not appear in the `index.bs` IDL as extracted". The second half is correct — I searched `index.bs` and found no `outputSchema`. The first half names no page. I searched all three Chrome WebMCP pages the artifact cites (`docs/ai/webmcp`, `.../imperative-api`, `.../declarative-api`) plus `docs/devtools/application/webmcp`; none mentions `outputSchema`. The bracket marks the *mechanism* as unresolved but states the *existence of the mention* as settled fact with no location.
- Why it matters: The unresolved list is the register the plan phase works from. An item whose premise cannot be traced to a page sends the plan to chase a discrepancy that may not exist, and an unlocatable "Chrome's docs prose mentions" is the shape a fabricated citation takes.

### F-004 — The reasoning that rejects the entire Declarative API is unsourced and unmarked

- Severity: IMPORTANT
- Location: `wiki/work/0002-flutter-webmcp-stack/00-research.md:28`
- Criterion affected: none
- Observation: The Declarative API is dismissed on the ground that "a Flutter Web app renders to a `<canvas>`/DOM tree the framework owns, not developer-authored semantic `<form>` elements". This sentence carries no source, no `[UNVERIFIED]` marker, and no reference to any Flutter rendering documentation; the bullet sits outside the Claim/Evidence/Source structure every other finding in the document uses, and no Flutter rendering source appears in the Sources list at `:129`-`:164`. I verified the other half of the premise independently — the declarative attributes do target `<form>` and its fields — but not the Flutter half.
- Why it matters: This one unsourced sentence is the sole basis for eliminating one of the two APIs Chrome documents, and `:25` establishes on Chrome's own wording that both are current. An unevidenced elimination of half the available surface is the kind of reasoning a plan inherits without re-deriving, as the bullet itself says it should.

### F-005 — `inputSchema` is presented as required; the IDL declares it optional

- Severity: NIT
- Location: `wiki/work/0002-flutter-webmcp-stack/00-research.md:32`
- Criterion affected: none
- Observation: The finding writes the tool shape as `{name, title?, description, inputSchema, execute, annotations?}`, using a trailing `?` to mark optionality. The IDL declares `required DOMString name`, `required DOMString description`, `required ToolExecuteCallback execute`, but plain `object inputSchema` — optional, like `title` and `annotations`.
- Why it matters: Cosmetic against the plan, which does not publish to the browser (`02-criteria.md:48`); recorded because the notation is precise everywhere else in the same line.

### F-006 — A quoted phrase is attributed to dart.dev pages that do not contain it, and "static" contradicts the source

- Severity: NIT
- Location: `wiki/work/0002-flutter-webmcp-stack/00-research.md:51`, sources at `:52`
- Criterion affected: none
- Observation: The evidence line quotes dart.dev as covering "amending outdated DOM native APIs" via "external static-extension members". Neither `https://dart.dev/interop/js-interop/package-web`, `.../usage` nor `.../js-types` contains that phrase; `package-web`'s actual guidance for a missing binding is to copy the implementation or file an issue/PR upstream. The supporting text does exist, on `.../usage`, which is cited: "These extensions are useful for when an interop type doesn't expose the external member you need, and you don't want to create a new interop type." That same passage states extensions "can't have external static members", which is in tension with the artifact's "static-extension members" wording.
- Why it matters: The technique the artifact recommends is genuinely supported, so the recommendation stands; only the quoted framing and the word "static" are unsupported.

### F-007 — `:74`'s absolute "no other package" claim is contradicted by the artifact's own `:125`

- Severity: NIT
- Location: `wiki/work/0002-flutter-webmcp-stack/00-research.md:74`, against `:125`
- Criterion affected: none
- Observation: `:74` states "No other pub.dev 'mcp' package touches the browser WebMCP surface — the rest (`dart_mcp`, `mcp_dart`, `mcp_server`, etc.) implement server-side/native MCP." `:125` records that `intentcall_platform` v0.6.0 covers "web manifests, WebMCP JS, native handoff, and Apple App Intents scaffolds" and was not evaluated. I confirmed that description on `https://pub.dev/packages?q=webmcp`. The two statements cannot both be read literally.
- Why it matters: The gap is disclosed in the Unresolved list, so a plan reading the whole document is not misled; only a reader of the Findings section alone would be. See the recurrence check — this is materially the round-01 `NIT` F-008, now partially remediated rather than closed.

### F-008 — The Options table still has no Imperative-versus-Declarative row

- Severity: NIT
- Location: `wiki/work/0002-flutter-webmcp-stack/00-research.md:93`-`:103`
- Criterion affected: none
- Observation: The Options-considered table compares three bridge mechanisms, three registry shapes and three package strategies, but contains no row weighing the Declarative API against the Imperative API, even though `:25` establishes both are current and `:28` records a rejection rationale for one of them. The comparison exists in the artifact, just not in the table that collects comparisons.
- Why it matters: Placement only; the alternative is named, weighed and dismissed at `:28`, which is what the "at least two options compared" bar requires.

## Recurrence check

- Previous round: `wiki/work/0002-flutter-webmcp-stack/validation/research-review-01.md`
- Recurring findings: F-007 (materially the round-01 `NIT` F-008); F-008 (the residual placement half of the round-01 `IMPORTANT` F-004)
- Oscillating: no

Round 01's two blockers are closed on the evidence, not on the artifact's assertion: I re-fetched `index.bs` and the Imperative API page and confirmed `Document` (closing F-001), and re-fetched the GitHub API for issue #130 and confirmed `"state": "closed"`, `"closed_at": "2026-03-26T15:06:18Z"` with the `AbortSignal` mechanism documented (closing F-002). Round 01's F-003 (unconsulted Imperative API page), F-005 (Brave/ChatGPT Desktop) and F-006 (MCP-B question missing from the Unresolved list) are also closed on re-verification; F-007 is closed at `:44`.

Two findings recur, both at `NIT` severity and both partially remediated rather than repeated verbatim: round-01 F-008's substance is now disclosed at `:125` and only the absolute phrasing at `:74` survives, and round-01 F-004's substance is now argued at `:28` and only the missing table row survives. The loop-limit rule aborts on a finding that is *materially identical* and unaddressed. Neither of these is unaddressed, and neither blocks; the four `IMPORTANT` findings above are all new to this round. The loop is converging, so escalation is not warranted. The four new `IMPORTANT` findings do share one root — a factual assertion carrying no traceable source — which is the pattern to watch if a round 03 is ever opened.

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | plan (record as a named follow-up with an owner before the differentiation is fixed) |
| F-002 | research (source or mark the claim) |
| F-003 | research (source or drop the premise) |
| F-004 | research (source or mark the claim) |
| F-005 | research (NIT, no action required) |
| F-006 | research (NIT, no action required) |
| F-007 | research (NIT, no action required) |
| F-008 | research (NIT, no action required) |
