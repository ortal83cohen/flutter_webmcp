# Research: Prior art for a Flutter WebMCP package, and pub.dev scoring conventions

## Question

(a) What client-side/browser-embedded MCP tool servers exist in any language? (b) Does any Dart/Flutter package on pub.dev already implement an MCP client or server (WebMCP or otherwise)? (c) What package layout/conventions do high-`pana`-score Flutter packages actually use, so a new package can be structured to score well from day one?

## Answer

A package literally named `flutter_webmcp` already exists on pub.dev (publisher `kicknext.dev`, MIT-licensed, repo `github.com/KickNext/flutter_webmcp`), does the same thing this work item set out to build — "a typed Dart API for exposing Flutter Web actions as WebMCP tools" without hand-written JS interop — and currently scores the maximum 160/160 pub points. This is a direct, functioning competitor, not an abandoned stub, and the name we intended to use is already taken. On the JS/TS side, the WebMCP-org / MCP-B project ships a mature multi-package toolkit (`@mcp-b/global`, `@mcp-b/webmcp-ts-sdk`, browser extension) for turning any web page into an MCP tool source, which is the reference implementation this Flutter work would be wrapping conceptually. Several other Dart MCP packages exist (`dart_mcp`, `mcp_dart`, `mcp_server`, `mcp_client`, `mcp_models`) but these target native/server MCP, not the browser `document.modelContext`/`navigator.modelContext` WebMCP surface — `intentcall_webmcp` is the other browser-facing exception. High-scoring single-package Flutter repos (e.g. `equatable`) converge on a small, consistent root layout: `lib/`, `example/`, `test/`, `README.md`, `CHANGELOG.md`, `LICENSE`, `analysis_options.yaml`, `pubspec.yaml`, plus community-health files; pub.dev's 160-point rubric rewards exactly this plus full platform declarations, 100% analyzer cleanliness, up-to-date dependency bounds, and ≥1 example with ≥20% doc-comment coverage (observed as 100% on the competing package).

## Findings

### A pub.dev package named `flutter_webmcp` already exists and does the same job

- Claim: `flutter_webmcp` v0.3.0, published by verified publisher `kicknext.dev`, is "A typed Dart API for exposing Flutter Web actions as WebMCP tools" without requiring hand-written JS interop, with `WebMcpToolScope` for Flutter-lifecycle-tied registration, typed input decoding, structured result/error helpers, feature detection, and graceful no-op behaviour on unsupported platforms.
- Evidence: pub.dev listing shows platforms Android/iOS/Linux/macOS/Web/Windows, MIT license, and a pub score of 160/160 (Follow Dart file conventions 30/30, Provide documentation 20/20 with 100% of 87 public API elements documented and an example present, Platform support 20/20 with all 6 platforms + WASM, Pass static analysis 50/50, Support up-to-date dependencies 40/40). Repository is `github.com/KickNext/flutter_webmcp`, containing `lib/`, `example/`, `test/`, `.github/`, `pubspec.yaml`, `README.md`, `CHANGELOG.md`, `LICENSE`, `analysis_options.yaml`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`.
- Source: https://pub.dev/packages/flutter_webmcp (consulted 2026-09-04), https://pub.dev/packages/flutter_webmcp/score (consulted 2026-09-04), https://github.com/KickNext/flutter_webmcp (consulted 2026-09-04).
- Note: package publish timestamp read as "8 hours ago" relative to the fetch time on 2026-09-04; exact calendar publish date is `[UNVERIFIED: exact publish date of flutter_webmcp v0.3.0]` — pub.dev's fetched page did not surface an absolute date.

### A second Dart/browser-facing WebMCP adapter exists under a different name

- Claim: `intentcall_webmcp` v0.6.0 (publisher `xsoulspace.dev`, MIT, part of a monorepo at `github.com/Arenukvern/intentcall`) is a "WebMCP publish adapter for intentcall registry (modelContext)" that syncs a Dart-first tool registry to `document.modelContext`/`navigator.modelContext`, explicitly marked pre-release/experimental and "not recommended for production use." Sibling packages `intentcall_core`, `intentcall_platform` in the same monorepo cover transport-agnostic registry and multi-target emission (web manifests, WebMCP JS, native handoff, Apple App Intents).
- Evidence: pub.dev score 140 pts, last published 2 months before the 2026-09-04 fetch, depends on `intentcall_core`, `intentcall_schema`, `meta`.
- Source: https://pub.dev/packages/intentcall_webmcp (consulted 2026-09-04).

### No other pub.dev package targets browser WebMCP; the rest of the "mcp" results are server/native MCP

- Claim: Searching pub.dev for "mcp" and "model context protocol" surfaces `mcp_dart`, `dart_mcp`, `mcp_server`, `mcp_client`, `mcp_llm`, `mcp_models`, `agentic_mcp`, `dart_pubdev_mcp`, `serverpod_mcp`, `mcp_dart_cli`, `mcpe2e`, `marionette_flutter`/`marionette_mcp`, `patrol_mcp`, `flutter_agent_lens` — all of these implement the *stdio/HTTP server-side* MCP protocol (agent-to-app tooling, dev-tool automation, LLM integration) rather than the browser `navigator.modelContext`/`document.modelContext` WebMCP surface. None of them touch the in-browser tool-registration API this work item targets, except `flutter_webmcp` and `intentcall_webmcp` already covered above.
- Evidence: package descriptions gathered from pub.dev search result pages for both query terms.
- Source: https://pub.dev/packages?q=mcp (consulted 2026-09-04), https://pub.dev/packages?q=model+context+protocol (consulted 2026-09-04).

### Reference JS/TS implementation for browser-embedded MCP tool servers: WebMCP-org / MCP-B

- Claim: The WebMCP-org GitHub organization ships `npm-packages` (including `@mcp-b/global`, a WebMCP polyfill exposing `document.modelContext`; `@mcp-b/webmcp-ts-sdk`, a browser-adapted fork of the official `@modelcontextprotocol/sdk` supporting dynamic tool registration) plus an `examples` repo and a browser extension that discovers page-registered tools and lets AI agents (Claude, ChatGPT, Gemini) call them. This is the most mature client-side/browser-embedded MCP tool-server implementation found in any language, and predates/parallels Chrome's own native WebMCP flag.
- Evidence: npm package descriptions for `@mcp-b/global`, `@mcp-b/webmcp-ts-sdk`; GitHub repos `WebMCP-org/npm-packages` and `WebMCP-org/examples`.
- Source: https://www.npmjs.com/org/mcp-b (consulted 2026-09-04), https://github.com/WebMCP-org/npm-packages (consulted 2026-09-04), https://github.com/WebMCP-org/examples (consulted 2026-09-04).
- `[UNVERIFIED: whether @mcp-b/global or webmcp-ts-sdk is still the recommended/maintained entry point as of today, vs. having been superseded by Chrome's native chrome://flags/#enable-webmcp-testing implementation]` — not cross-checked against the packages' own changelog.

### Chrome ships a native, flag-gated WebMCP implementation (context only, not this stream's job to spec)

- Claim: Chrome 146 exposes a flag `chrome://flags/#enable-webmcp-testing`; the API is only available in secure contexts (HTTPS). This is background context confirming WebMCP is an active, evolving browser API, not settled spec — relevant to why `flutter_webmcp`'s README states it was "tested against WebMCP Draft Community Group Report (August 2026)."
- Evidence: search results referencing `developer.chrome.com/docs/ai/webmcp` and a third-party guide.
- Source: https://developer.chrome.com/docs/ai/webmcp (link surfaced, not independently fetched — `[UNVERIFIED: exact wording of Chrome's own WebMCP docs]`), consulted via search 2026-09-04. Per this stream's boundary, the WebMCP API's own shape is out of scope and intentionally not verified further here.

### pub.dev pub-points rubric: six categories, 160 points total, verified against a real 160/160 package

- Claim: pub.dev's automated score (computed by `pana`) is split into: Follow Dart file conventions (max 30: valid pubspec.yaml, README.md, CHANGELOG.md, OSI-approved license each contributing sub-points), Provide documentation (max 20: public API doc-comment coverage plus presence of an example), Platform support (max 20: declared/detected platforms across Android/iOS/Web/Windows/macOS/Linux, with extra credit for Swift Package Manager and Wasm readiness), Pass static analysis (max 50: zero errors/warnings/lint violations under `dart analyze`/`flutter analyze` with the standard lints package), Support up-to-date dependencies (max 40: current Dart/Flutter SDK compatibility and current dependency versions). These five category names/order were confirmed on both pub.dev's help page and the `dart-lang/pana` README; the numeric maxima (30/20/20/50/40 = 160) were cross-checked against the actual score breakdown shown for `flutter_webmcp` (160/160 exactly matching this split).
- Evidence: pub.dev help page lists the same category names without numbers; `dart-lang/pana` README lists five category links, also without numbers in the fetched excerpt; the numeric maxima come from the live score breakdown of an existing 160/160 package, so they are corroborated by an actual scored example rather than asserted from a single source.
- Source: https://pub.dev/help/scoring (consulted 2026-09-04), https://github.com/dart-lang/pana (consulted 2026-09-04), https://pub.dev/packages/flutter_webmcp/score (consulted 2026-09-04).
- `[UNVERIFIED: whether pub.dev's help page states these exact numeric maxima somewhere the fetch tool did not surface]` — the WebFetch summaries of the help page textually omitted numbers twice in a row; treat the 30/20/20/50/40 split as inferred-and-corroborated, not quoted verbatim from the help page's own prose.

### Directory/file layout common to high-scoring single-package Flutter/Dart repos

- Claim: `equatable` (felangel/equatable), a widely used, high-scoring single-package Dart repo, uses this root layout: `lib/`, `example/`, `test/`, `.github/`, `README.md`, `CHANGELOG.md`, `LICENSE`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `analysis_options.yaml`, `pubspec.yaml`, plus a `coverage_badge.svg` and a `benchmarks/` folder. `flutter_webmcp` (the direct competitor found above) uses the same core set — `lib/`, `example/`, `test/`, `.github/`, `README.md`, `CHANGELOG.md`, `LICENSE`, `analysis_options.yaml`, `pubspec.yaml` — plus `SECURITY.md`. `provider` (rrousselGit/provider) is a monorepo (`packages/` containing multiple packages) rather than a single-package layout, so its root does not directly map to a single-package template; it was not useful as a same-shape example.
- Evidence: GitHub root file listings for both repos, gathered by fetch.
- Source: https://github.com/felangel/equatable (consulted 2026-09-04), https://github.com/KickNext/flutter_webmcp (consulted 2026-09-04), https://github.com/rrousselGit/provider (consulted 2026-09-04).
- `[UNVERIFIED: exact internal structure of equatable's example/ folder — e.g. whether it is a runnable Flutter app or a bare Dart script — the fetch did not expose file-level contents]`.

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Build a brand-new `flutter_webmcp` package as originally planned | Publish a new pub.dev package under the name already used by kicknext.dev's package | Name collision is impossible (pub.dev enforces unique names); would require renaming, and duplicates functionality already scoring 160/160 | Rejected as-is: the name is taken and the functional gap it would fill is already filled by an actively maintained, top-scoring package |
| Fork or contribute to the existing `KickNext/flutter_webmcp` | Extend/patch the existing MIT-licensed repo instead of publishing a competing package | Requires coordinating with an external maintainer (`kicknext.dev`); no control over release cadence or design direction | Not evaluated further here — a build/reuse decision belongs to the plan phase, not this research stream, but flagged as the most obvious way to avoid duplicated work |
| Build a differently-named, differently-scoped package (e.g. focused on a specific gap `flutter_webmcp`/`intentcall_webmcp` don't cover) | Identify a concrete capability gap versus the two existing browser-facing packages before naming/building anything | Requires a feature-level diff against `KickNext/flutter_webmcp` and `intentcall_webmcp`, which is explicitly out of this stream's boundary (architecture/API shape belongs to other branches) | Left open for the plan phase; this research only establishes that such a diff is now mandatory before proceeding |

## Constraints discovered

- The package name `flutter_webmcp` is already registered on pub.dev by a different publisher (`kicknext.dev`); this project cannot publish under that exact name. Source: https://pub.dev/packages/flutter_webmcp.
- pub.dev pub points cap at 160 and are fully mechanical (pana-driven): any new package needs, at minimum, `pubspec.yaml` + `README.md` + `CHANGELOG.md` + OSI license, an `example/`, ≥20% public API doc coverage (the competing package hit 100%), zero analyzer warnings under standard lints, current SDK/dependency bounds, and explicit platform declarations (ideally all 6 platforms plus Wasm-readiness for web credit) to be competitive with the existing top-scoring alternative. Source: https://pub.dev/help/scoring, https://pub.dev/packages/flutter_webmcp/score.
- WebMCP itself is a moving target — Chrome ships it behind a flag (`chrome://flags/#enable-webmcp-testing`) as of Chrome 146, and the existing competing package explicitly versions itself against "WebMCP Draft Community Group Report (August 2026)," meaning any new package inherits the same spec-churn risk already being managed by `flutter_webmcp`. Source: search-surfaced references to `developer.chrome.com/docs/ai/webmcp` (not independently fetched, see UNVERIFIED note above).
- A monorepo layout (as in `provider`) is a legitimate high-score pattern but does not map to a single-package template; if this project intends a single publishable package, `equatable`/`KickNext/flutter_webmcp`'s flat single-package layout is the more directly applicable template.

## Unresolved

- [UNRESOLVED: What exact feature/API gap, if any, exists between `KickNext/flutter_webmcp` (or `intentcall_webmcp`) and what this project needs — has anyone done a line-by-line capability diff?]
- [UNRESOLVED: Exact calendar publish date of `flutter_webmcp` v0.3.0 (fetched as relative "8 hours ago" on 2026-09-04).]
- [UNRESOLVED: Whether pub.dev's own help page states the 30/20/20/50/40 point-per-category numbers explicitly anywhere, versus these being pana implementation details not published verbatim on the help page — the fetch tool's extraction omitted numbers on two separate attempts.]
- [UNRESOLVED: Whether `@mcp-b/global` / `@mcp-b/webmcp-ts-sdk` (WebMCP-org/MCP-B) are still actively maintained/recommended, or superseded now that Chrome ships a native flag-gated implementation.]
- [UNRESOLVED: Whether `KickNext/flutter_webmcp`'s maintainer would accept contributions/PRs, and what license terms would apply to reusing any of its code — this needs a maintainer/Legal check before any code reuse, not just a design decision.]
- [UNRESOLVED: Full internal directory structure of `KickNext/flutter_webmcp`'s `lib/` — e.g. how many source files, whether it's a single-file or multi-file library — was not enumerated at the file level, only at the top-level folder name.]

## Sources

- https://pub.dev/packages?q=mcp — consulted 2026-09-04
- https://pub.dev/packages?q=model+context+protocol — consulted 2026-09-04
- https://pub.dev/packages?q=webmcp — consulted 2026-09-04
- https://pub.dev/packages/flutter_webmcp — consulted 2026-09-04
- https://pub.dev/packages/flutter_webmcp/score — consulted 2026-09-04
- https://pub.dev/packages/intentcall_webmcp — consulted 2026-09-04
- https://github.com/KickNext/flutter_webmcp — consulted 2026-09-04
- https://github.com/Arenukvern/intentcall/tree/main/packages/intentcall_webmcp — referenced via pub.dev listing, not independently fetched, 2026-09-04
- https://www.npmjs.com/org/mcp-b — consulted 2026-09-04
- https://github.com/WebMCP-org/npm-packages — consulted 2026-09-04
- https://github.com/WebMCP-org/examples — consulted 2026-09-04
- https://pub.dev/help/scoring — consulted 2026-09-04
- https://github.com/dart-lang/pana — consulted 2026-09-04
- https://github.com/felangel/equatable — consulted 2026-09-04
- https://github.com/rrousselGit/provider — consulted 2026-09-04
- Web search: "flutter_webmcp pub.dev github" — consulted 2026-09-04
- Web search: "browser-embedded MCP tool server javascript npm package modelContext client-side website" — consulted 2026-09-04
- Web search: "KickNext flutter_webmcp WebMCP Chrome" — consulted 2026-09-04
