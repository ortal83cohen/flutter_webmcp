# Research review — round 01

- Work item: 0016-user-facing-feature-opportunities
- Reviewed artifact: `wiki/work/0016-user-facing-feature-opportunities/00-research.md` (uncommitted; workspace HEAD `bc1d786b001ad160133e50dcbc88026c5021962b`)
- Reviewer: research-validator
- Date: 2026-09-25

## Verdict

**PASS**

The three branch verdicts, the AbortSignal disagreement, the demand counts, and the unresolved list match the cited branch files and the sources opened for this round. One evidence sentence mislabels author duties as contract omissions; the constraints section quotes the real omission list, so the approach is not invalidated.

## Verification performed

Read the artifact, `wiki/conventions/validation-rubrics.md`, `wiki/templates/validation-report.md`, and the three stream files only as cited sources. Opened the local citations named by the load-bearing claims: `lib/src/transport/native_publisher_boundary_web.dart`, `lib/src/transport/webmcp_native_publisher.dart`, `lib/src/transport/webmcp_native_capabilities.dart`, `lib/src/webmcp.dart`, `lib/src/widgets/webmcp_action.dart`, `wiki/product/webmcp-contract.md`, `README.md`, `example/lib/example_diagnostics_screen.dart`, `wiki/work/0008-automatic-page-agent/STATE.yaml`, `wiki/work/0012-readme-feature-guide/RECORD.md`, `wiki/work/0014-example-feature-coverage/STATE.yaml`, `wiki/adr/0003-webmcp-detection-first-registry.md`. `rg confirmBackend example` returned no matches. Ignored author reasoning outside the artifact.

Command: `curl` against pub.dev score, package, and search endpoints; companion package URLs; `https://pub.dev/packages/flutter_webmcp`; `https://pub.dev/packages/webmcp_flutter/changelog` (2026-09-25).

```text
webmcp_flutter score likeCount 3, downloadCount30Days 372, grantedPoints 160, maxPoints 160
latest 0.1.8 published 2026-09-17; platforms.web; flutter >=3.47.0; deps flutter, web
dependency:webmcp_flutter packages []
annotations HTTP 404; generator HTTP 404
flutter_webmcp score likeCount 1, downloadCount30Days 180, grantedPoints 160
intentcall_webmcp score likeCount 0, downloadCount30Days 21
changelog 0.1.2 through 0.1.8 each "Automated patch release from main."
```

`flutter_webmcp` 0.3.0 page text includes "tools without writing JavaScript interop code", "Safe no-op detection; registration is unsupported", `WebMcpTypedTool`, `decodeInput`, `WebMcpResult.text`, `WebMcpResult.structured`, `WebMcpToolException`, "execution cancellation through AbortSignal", "exposedTo origins", `WebMcp.logger`, and "Validate input in decodeInput, enforce authorization inside the handler, and require normal user confirmation for destructive or sensitive operations."

Command: `gh issue list` / `gh search issues` / `gh api` for `ortal83cohen/flutter_webmcp` and `KickNext/flutter_webmcp`.

```text
ortal83cohen/flutter_webmcp issues []
open_issues 0, has_issues true, has_discussions false, stargazers_count 1, forks 0
discussions HTTP 410 "Discussions are disabled for this repo"
KickNext/flutter_webmcp issues []
open PR 8 "Bump actions/deploy-pages from 5.0.0 to 5.0.1"
open_issues 1, has_discussions false, stargazers_count 1
```

Fetched `https://github.com/webmachinelearning/webmcp/blob/main/index.bs` (raw, 1946 lines), that repository's `README.md`, and the four Chrome URLs. Chrome last-updated dates: imperative 2026-09-21, overview 2026-08-07, declarative 2026-05-18, origin-trial post published 2026-06-09. Draft metadata `Status: CG-DRAFT`, URL `https://webmachinelearning.github.io/webmcp`. `ModelContext` IDL is on `Document` (`index.bs` 597–624). `execute` is invoked with `ToolExecuteCallbackOptions.signal` (506–512, 1101–1105). Cancel-pending-execution signals that controller and fires `toolcancel` (290–296). Registration abort steps unregister and reject the registration promise (732–743). `title` is an optional `USVString` (1087). `debugging = false` (1098). `executeTool` returns `Promise<DOMString>` (619). `getTools` prose limits that method to in-page agents (640–645). Declarative heading says the section is entirely a TODO (1282–1284). Permissions policy default `self` (1393–1397); `Permissions-Policy: tools=()` (1886–1887). `outputSchema` is absent from `index.bs` and present under README "Open Questions" linking issue 9. The one `navigator` hit is `NavigatorLanguage/language` at `index.bs:1119`, not a `navigator.modelContext` attribute.

Chrome imperative page documents `execute: async ({ url, priority }, { signal })` passed into `fetch`, "As of Chrome 153, you can unregister a tool without cancelling and breaking in-flight executions", and `debugging` "available from Chrome 156". Overview page: `document.domain` / `Origin-Agent-Cluster: ?0` disables the API. Origin-trial post: trial in Chrome 149; origin trials inform "future iterations of the API."

Local code matches the publisher claims: `native_publisher_boundary_web.dart:54-72` registers `name`, `description`, `inputSchema`, three hints, and `execute` of one argument, with `{ signal }` from an `AbortController`; `_executeSafely` passes `cancelledBeforeDispatch: false` (87–96); `abort()` is 117–119. `webmcp_native_capabilities.dart:12-18` sets both cancellation-after-start and `positiveWait` false. `webmcp.dart:145-171` clears tools and cancels observer subscriptions without disposing the previous transport. `webmcp_native_publisher.dart:10-23` and `309-365` bound JSON and return an allowlisted failure object; `detach` aborts owned registrations (208–217). `WebMcpAction` constructor (13–21) has no annotations parameter. Contract `last_verified` is 2026-09-15 (`webmcp-contract.md:5`). Wasm texts disagree as stated: contract 134–139 versus README 587–603, RECORD.md 8–10, and 0008 `STATE.yaml:15-19`.

## Per-criterion results

Not an implementation review. No frozen acceptance criteria were supplied for this research round.

| Research bar | Result | Evidence |
|---|---|---|
| Claims sourced or explicitly unresolved | pass | Branch answers, options, and `[UNRESOLVED]` markers are retained; live HTTP and `gh` output match the demand counts; F-001 is a misattribution inside an otherwise sourced rank |
| Alternatives considered | pass | Each branch's options are kept (`00-research.md:169-179`); the merge does not add a fourth verdict |
| Stale sources | pass | Contract date 2026-09-15 versus the 2026-09-21 Chrome page is stated as a disagreement (`00-research.md:41`, `205`) |
| Unresolved questions surfaced | pass | Branch markers reappear at `00-research.md:202-212`, plus the three-verdict question |
| No fabricated API, path, or count | pass | Cited symbols, line ranges, versions, and scores matched the files and responses opened above |

## Findings

### F-001 — Rank evidence treats steps 3–11 as contract omissions

- Severity: IMPORTANT
- Location: `wiki/work/0016-user-facing-feature-opportunities/00-research.md:107`
- Criterion affected: none
- Observation: The rank evidence says "Contract omissions are what leave steps 3 through 11 on the author." The omission sentence quoted at `00-research.md:185` and printed at `wiki/product/webmcp-contract.md:146-153` names multiple-view operation, positive waits, generated route wrapping, generalized proxies, framework adapters, custom data providers, back-gesture support, in-flight callback termination, deep schema immutability, transactional registration, notification rollback, custom-transport cleanup, and non-web support. It does not name widget unmount or fixed descriptors (step 4), semantic identifiers and label selection (step 5), publisher attach and detach (step 6, apart from in-flight termination), `confirmBackend` (step 7, apart from positive waits), or nested adapters, `selectedBranch`, and `activity` (step 10). Those behaviors are specified author duties in `wiki/product/webmcp-contract.md:51-59`, `wiki/product/webmcp-contract.md:85-87`, and `README.md:392-396`.
- Why it matters: A plan that uses this sentence as the boundary of what the contract forbids would drop feature options the omission list does not forbid.

### F-002 — Draft search is reported as having no navigator match

- Severity: NIT
- Location: `wiki/work/0016-user-facing-feature-opportunities/00-research.md:48`
- Criterion affected: none
- Observation: The evidence says a search of `index.bs` for `navigator` finds no matches. The fetched source has one match, `{{NavigatorLanguage/language}}` at line 1119. It is not a `navigator` attribute for this API. `modelContext` remains on `Document` at lines 597–598.
- Why it matters: The attribute conclusion still holds. The zero-match sentence does not.

## Recurrence check

- Previous round: none — first round
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | research |
| F-002 | research |
