# Research: External demand for unshipped author-facing capabilities

## Question

What external evidence shows Flutter application authors need from an agent-tool library that webmcp_flutter does not already document as shipped, and which of those needs are strong enough to justify a feature versus a documentation fix? Which of at least two demand sources is stronger?

## Answer

No retrieved source contains a Flutter application author asking for a capability this package does not already document as shipped. The issue tracker is empty and discussions are disabled, which is low visible demand, not evidence that a feature is unwanted. The stronger of the two demand sources is the published comparable package `flutter_webmcp`, because it is the only source that names concrete capabilities absent from this README; pub.dev usage of `webmcp_flutter` is larger but states no unmet need. Neither source is strong enough to justify a feature or a new documentation fix. Defer.

## Findings

### This repository has no author requests

- Claim: On 2026-09-25, `gh issue list --repo ortal83cohen/flutter_webmcp --state all --limit 100` and `gh search issues --repo ortal83cohen/flutter_webmcp --limit 50` both returned an empty list. No issue titles were retrieved.
- Evidence: Empty JSON arrays from both commands. The REST repository payload reported `open_issues: 0`, `has_issues: true`, `has_discussions: false`, `stars: 1`, and `forks: 0`. `gh api repos/ortal83cohen/flutter_webmcp/discussions` returned HTTP 410, `Discussions are disabled for this repo`.
- Source: https://github.com/ortal83cohen/flutter_webmcp (consulted 2026-09-25 via `gh`).

- Claim: An empty issue list is low visible demand. It does not show that a feature is unwanted, because authors who never filed an issue are invisible to this source.
- Evidence: Issues are enabled and the list is empty, so the tracker can receive requests and currently shows none. Discussions cannot receive requests at all.
- Source: https://github.com/ortal83cohen/flutter_webmcp (consulted 2026-09-25).

### pub.dev shows use of the published package and no dependent packages

- Claim: `webmcp_flutter` 0.1.8, published 2026-09-17, has 3 likes, 160 of 160 pub points, and 372 downloads in the score window. The search `dependency:webmcp_flutter` returned no packages.
- Evidence: Score JSON `likeCount: 3`, `downloadCount30Days: 372`, `grantedPoints: 160`. Search JSON was `{"packages":[]}`.
- Source: https://pub.dev/api/packages/webmcp_flutter/score and https://pub.dev/api/search?q=dependency:webmcp_flutter (consulted 2026-09-25).

- Claim: The live changelog tab does not record a user-requested capability. Versions 0.1.2 through 0.1.8 are each "Automated patch release from main." The Unreleased notes describe capabilities the README already presents as shipped: page semantics, guarded actions, navigation observation, receipts, native Chrome publication, and optional annotation and generator packages.
- Evidence: Changelog text on the package page. README feature table lists the same surfaces as available APIs.
- Source: https://pub.dev/packages/webmcp_flutter/changelog (consulted 2026-09-25); README.md lines 72-84.

- Claim: The live example tab publishes `example/lib/main.dart`, which installs one runtime, one root navigator adapter, and `ExampleScreen`. It does not add a request for a missing API.
- Evidence: Example tab source begins with those imports and `runtime.install()`.
- Source: https://pub.dev/packages/webmcp_flutter/example (consulted 2026-09-25).

### The README already assigns several jobs to the application author

- Claim: Authors must validate arguments and enforce authorization themselves. Manual input schemas are descriptive; the package does not validate them at runtime. Tool annotations are hints, not authorization checks. A disabled child does not disable the registered tool.
- Evidence: Setup step 2 and the manual-tool and current-contract sections say this in those words.
- Source: README.md lines 55-56, 159-161, 209-210, 563-569.

- Claim: Positive observation waits are unsupported, so the client chooses the polling interval. Backend confirmation is an application call. Other Flutter platforms are not supported. Chrome 152 supplies no invocation `AbortSignal` after a callback starts. Companion-package publication is not established; the documented consumer setup uses path dependencies.
- Evidence: Observation, platform-support, and generator-setup sections.
- Source: README.md lines 381-382, 386-387, 440-454, 583-584, 600-603.

- Claim: `webmcp_flutter_annotations` and `webmcp_flutter_generator` are not on pub.dev. Each package API URL returned HTTP 404 on 2026-09-25.
- Evidence: `curl` status codes 404 for both names.
- Source: https://pub.dev/api/packages/webmcp_flutter_annotations and https://pub.dev/api/packages/webmcp_flutter_generator (consulted 2026-09-25). The README already states that publication availability is not established (README.md lines 440-441).

- Claim: Maintainers already treated a README gap and an example-coverage gap as worth fixing. That is maintainer priority, not external author demand.
- Evidence: Work item 0012 records an expanded consumer feature guide. Work item 0014 is titled as example coverage and its state file records `phase: done`.
- Source: wiki/work/0012-readme-feature-guide/RECORD.md lines 1-10; wiki/work/0014-example-feature-coverage/STATE.yaml lines 1-9.

### The comparable WebMCP package names capabilities this README does not list as shipped

- Claim: `flutter_webmcp` 0.3.0, publisher kicknext.dev, was opened on pub.dev. It says it exposes Flutter Web actions "without writing JavaScript interop code," supports JavaScript and WebAssembly when the browser exposes WebMCP, and treats Android, iOS, desktop, and the Dart VM as "Safe no-op detection; registration is unsupported."
- Evidence: Compatibility table and install section on its package page. Score JSON: 1 like, 180 downloads in 30 days, 160 pub points.
- Source: https://pub.dev/packages/flutter_webmcp and https://pub.dev/api/packages/flutter_webmcp/score (consulted 2026-09-25).

- Claim: The same page documents typed decode (`WebMcpTypedTool` and `decodeInput`), `WebMcpResult.text` and `WebMcpResult.structured`, `WebMcpToolException` mapped to an agent-visible error, execution cancellation through `AbortSignal`, `exposedTo` origins, and a `WebMcp.logger` hook. Its security section still tells the application to validate input, enforce authorization, and confirm destructive operations.
- Evidence: Quoted headings and sentences on the fetched package page: "Typed input," "Results and errors," "execution cancellation through AbortSignal," "exposedTo origins," and "Logging."
- Source: https://pub.dev/packages/flutter_webmcp (consulted 2026-09-25).

- Claim: That comparable also has no retrieved author issues. `gh issue list` and `gh search issues` for `KickNext/flutter_webmcp` returned empty lists. The repository API `open_issues` value of 1 matches open pull request 8, "Bump actions/deploy-pages from 5.0.0 to 5.0.1," not an issue title. Discussions are disabled.
- Evidence: Empty issue JSON; pull-request list; API object `{discussions: false, open_issues: 1, stars: 1}`.
- Source: https://github.com/KickNext/flutter_webmcp (consulted 2026-09-25 via `gh`).

- Claim: `intentcall_webmcp` 0.6.0 was opened on pub.dev. It describes a pre-release `WebMcpPublishAdapter` that hot-syncs a registry to `document.modelContext`. Its score is 0 likes and 21 downloads in 30 days. It does not state an author request against `webmcp_flutter`.
- Evidence: Package-page description and score JSON.
- Source: https://pub.dev/packages/intentcall_webmcp and https://pub.dev/api/packages/intentcall_webmcp/score (consulted 2026-09-25).

### Which source is stronger

- Claim: GitHub issues on this repository are the weaker demand source: zero request titles. pub.dev metrics for this package are larger than `flutter_webmcp` (372 downloads and 3 likes versus 180 and 1) but contain no statement of an unmet need. `flutter_webmcp`'s package page is the stronger demand signal for this question because it is the only consulted source that names capabilities this README does not document as shipped. It remains a weak signal: the other package has fewer downloads, and neither tracker contains an author asking for those capabilities.
- Evidence: Counts and page text cited above.
- Source: https://github.com/ortal83cohen/flutter_webmcp; https://pub.dev/api/packages/webmcp_flutter/score; https://pub.dev/packages/flutter_webmcp (consulted 2026-09-25).

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Build the capabilities named by `flutter_webmcp` | Add typed manual-tool decode, structured agent errors, cancellation, origin exposure, invocation logging, or non-web no-op registration so authors write less boilerplate or fail more safely. | New public behavior, tests, and a support boundary beyond the web-only release. | Rejected. The strongest signal names these capabilities, but no author requested them, and that package has fewer downloads than this one. README.md lines 567-569 and 583-603 already state the current validation and platform limits. |
| Document an existing capability | Expand the README or example so authors can find a shipped API that already covers typed decode, cancellation, or non-web use. | Another documentation pass after work items 0012 and 0014. | Rejected. The README already says manual schemas are not validated, other platforms are unsupported, and post-start `AbortSignal` is absent. The generator path is already documented for annotated methods (README.md lines 419-501). A doc edit would not give authors those missing behaviors. |
| Defer | Leave the library surface unchanged until an author request names a missing behavior. | No product change. Authors keep the responsibilities the README already lists. | Chosen. Neither demand source is strong enough to justify a feature, and the remaining gaps are already written as application responsibilities rather than undocumented shipped APIs. |

## Constraints discovered

- Issues are enabled and empty. Discussions are disabled, so that channel cannot produce demand. Source: https://github.com/ortal83cohen/flutter_webmcp (consulted 2026-09-25).
- The published package is web-only (`platforms.web`) and depends on Flutter `>=3.47.0` and the `web` package. Source: https://pub.dev/api/packages/webmcp_flutter (consulted 2026-09-25); README.md lines 583-584.
- Companion annotation and generator packages are absent from pub.dev (HTTP 404). Authors who need them follow the path-dependency setup the README already prints. Source: https://pub.dev/api/packages/webmcp_flutter_annotations; README.md lines 440-454.
- No other pub.dev package declares a dependency on `webmcp_flutter`. Source: https://pub.dev/api/search?q=dependency:webmcp_flutter (consulted 2026-09-25).

## Unresolved

- [UNRESOLVED: whether any of the 372 score-window downloads are application authors rather than the maintainer or release automation]
- [UNRESOLVED: whether authors want the annotation and generator packages published to pub.dev, given that no issue asks and both package URLs 404]
- [UNRESOLVED: whether `flutter_webmcp`'s typed decode, structured errors, `AbortSignal`, `exposedTo`, or non-web no-op would change a real application's safety or boilerplate enough to matter, because no author described that workflow]

## Sources

- https://github.com/ortal83cohen/flutter_webmcp — issues, discussions, stars, forks; 2026-09-25
- https://pub.dev/packages/webmcp_flutter — package page metadata via API; 2026-09-25
- https://pub.dev/packages/webmcp_flutter/changelog — 2026-09-25
- https://pub.dev/packages/webmcp_flutter/example — 2026-09-25
- https://pub.dev/api/packages/webmcp_flutter/score — 2026-09-25
- https://pub.dev/api/search?q=dependency:webmcp_flutter — 2026-09-25
- https://pub.dev/api/search?q=webmcp — 2026-09-25
- https://pub.dev/packages/flutter_webmcp — 2026-09-25
- https://pub.dev/api/packages/flutter_webmcp/score — 2026-09-25
- https://github.com/KickNext/flutter_webmcp — issues and pull requests; 2026-09-25
- https://pub.dev/packages/intentcall_webmcp — 2026-09-25
- https://pub.dev/api/packages/intentcall_webmcp/score — 2026-09-25
- https://pub.dev/api/packages/webmcp_flutter_annotations — HTTP 404; 2026-09-25
- https://pub.dev/api/packages/webmcp_flutter_generator — HTTP 404; 2026-09-25
- README.md lines 55-56, 72-84, 159-161, 209-210, 381-387, 419-501, 440-454, 563-603
- wiki/work/0012-readme-feature-guide/RECORD.md lines 1-10
- wiki/work/0014-example-feature-coverage/STATE.yaml lines 1-9
