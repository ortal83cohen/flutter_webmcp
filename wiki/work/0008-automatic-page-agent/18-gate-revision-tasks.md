# Tasks: Empirical gate revision

## Legend

- All tasks below are future work. This planning request does not authorize implementation.
- This file extends 03-tasks.md and 15-observation-tasks.md through their existing owners. It does not cancel publisher, page, example, generator, documentation, provider-follow-up, or independent-verification work.
- One done-when condition is superseded rather than extended: task 2.3 in 03-tasks.md and task O2.3 in 15-observation-tasks.md no longer close on the real-agent trace. Per clause 4 of the 01-plan.md supersession in 16-gate-revision-plan.md, they close on page-conformance evidence plus an explicit unsupported marking, and the authenticated Chrome-only trace moves to R7.1 as a claim gate. No other done-when condition in either file changes.
- Groups run in dependency order. A later group cannot use a page-conformance result as native support proof.
- The same implementation owner writes the positive and negative tests for its component. Shared source, export, configuration, manifest, lockfile, example, documentation, criteria, and STATE files retain one owner.
- Existing AC-001 through AC-028 remain active subject only to the clause-level supersessions in 17-gate-revision-criteria.md. New work cites AC-029 through AC-035.

## Groups

### Group R1 — Validate and freeze the revised contract

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| R1.1 | Run one fresh blind plan validation against 06-gate-decision.md, 16-gate-revision-plan.md, and the combined acceptance contract in 02-criteria.md, 14-observation-criteria.md, and 17-gate-revision-criteria.md. | AC-001 through AC-035 | A new append-only plan validation report under wiki/work/0008-automatic-page-agent/validation/ | No | The validator issues one verdict, every finding receives a recorded main-agent disposition through the established workflow, and no runtime edit is used to repair a plan defect. |
| R1.2 | Freeze the combined criteria only after an acceptable validation outcome and record the freeze through the main-agent-owned workflow state. | AC-001 through AC-035 | Main agent only: STATE.yaml and any append-only freeze record required by the validated workflow | No | The freeze identifies all three criteria artifacts and their supersession precedence. Until then, implementation remains blocked. |

### Group R2 — Implement the bounded Chrome publisher

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| R2.1 | Extend baseline task 2.1 and observation task O2.1 with explicit publisher capabilities for registration cleanup, cancel-before-dispatch, and unavailable post-start invocation cancellation; preserve additive registry ownership, manual/custom transports, wire safety, and local behavior. | AC-002, AC-010, AC-011, AC-015, AC-016, AC-019, AC-022, AC-026, AC-028, AC-029, AC-030 | Baseline owner 2.1 retains lib/src/webmcp.dart, lib/src/transport/, public exports, dependency/configuration/manifest/lockfile changes, and transport/registry/public-surface tests | No | JavaScript and Wasm conformance tests register, discover, invoke, reject invalid input, sanitize results/errors, clean registration ownership, cancel before dispatch, and report no post-start invocation signal without changing local tool behavior. |
| R2.2 | Add bounded publisher-side waiter, operation, receipt, and outstanding-execution accounting with no automatic replay and no claim to terminate application work. | AC-007, AC-011, AC-016, AC-022 through AC-024, AC-026 through AC-029, AC-034 | Through baseline owner 2.1 for transport tracking; page-operation contract requests are serialized through baseline owner 2.2 | No | Exact-limit and one-over-limit tests pass; caller abort after callback start can coexist with callback settlement, tracking remains bounded, receipt expiry does not free a never-settled execution slot, and no invocation is replayed. |

### Group R3 — Implement the single-view automatic page surface

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| R3.1 | Extend baseline task 2.2 and observation task O2.2 with an exactly-one-view eligibility gate. Detect zero, multiple, or changed-unbound views before exposure and fail closed without global, ancestor, first-view, or other-view fallback. | AC-001, AC-003 through AC-006, AC-015, AC-016, AC-019 through AC-021, AC-028, AC-031 | Baseline owner 2.2 retains proposed lib/src/page/ and test/page/; shared exports/configuration are requested from R2.1 | No | Single-view positive cases preserve the six-run marker contract, while zero/multiple/ambiguous-view negative cases expose no page content or action and retain manual explicit tools. |
| R3.2 | Implement PipelineOwner and SemanticsOwner replacement with synchronous eligibility revocation, stale-handle invalidation, old-listener removal, late-callback rejection, replacement binding, and recapture before exposure. | AC-005, AC-006, AC-016, AC-021, AC-028, AC-032 | Through baseline owner 2.2 in proposed page lifecycle modules and their tests | No | Ordering and listener-count evidence proves revoke-before-rebind, the replacement owner can recover safely, and missing or ambiguous replacement remains unavailable without fallback. |
| R3.3 | Preserve fail-closed route, branch, overlay, gesture, and transition eligibility. Advertise no Chrome web platform-back-gesture support until separately demonstrated. | AC-005, AC-006, AC-020, AC-021, AC-028, AC-033 | Through baseline owner 2.2 in proposed navigation/session modules and tests | No | Known callbacks revoke immediately; unknown/interrupted state stays inactive; a frame, timeout, quiet animation, or history event alone cannot reactivate the page. |
| R3.4 | Complete the page read/act, app observe, privacy projection, bounded broker, cursor recovery, command evidence, and app-owned receipt behavior required by baseline and observation plans. | AC-003 through AC-009, AC-015, AC-016, AC-019 through AC-028, AC-029, AC-031 through AC-034 | Through baseline owner 2.2 in proposed lib/src/page/ and test/page/ | No | Every applicable retained and new criterion has a positive and negative test, including inactive history redaction, no replay, post-disposal no-dispatch, honest evidence levels, and bounded metadata. |

### Group R4 — Prove all implementation-time resource boundaries

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| R4.1 | Extend baseline feasibility task 1.1 evidence with implementation-level owner replacement and exactly-one-view rejection results; retain the original six-run semantics evidence without rewriting it. | AC-001, AC-005, AC-006, AC-016, AC-020, AC-021, AC-028, AC-031 through AC-033 | Append-only implementation evidence owned by the baseline semantics/page verification owner; existing 04-semantics-spike.md is read-only | No | The delivered implementation, not a conceptual spike, proves owner replacement and multiple-view rejection on the supported Flutter matrix. |
| R4.2 | Run exact-limit and one-over-limit tests for every implemented AC-027 component: live scopes, Navigator adapters, ring count and bytes, response count and bytes, app and filtered waiters, wait duration, queued capture, operation retention, capture deadline, and outstanding executions. | AC-009, AC-017, AC-022, AC-023, AC-026 through AC-028, AC-034 | Each component's existing owner retains its test files; the verification owner owns append-only raw evidence | No | Every applicable value remains unchanged, configuration only lowers ceilings, excess fails before side effects without evicting live owners, and unavailable or unrun checks are reported as blockers. |
| R4.3 | Run synthetic-secret and ownership scans across publisher capability output, broker events, gap/cancellation/timeout paths, owner changes, multiple-view rejection, diagnostics, logs, and receipts. | AC-008, AC-011, AC-015, AC-023, AC-026, AC-028 through AC-034 | Existing transport/page component owners retain tests; verification evidence remains append-only | No | Only allowlisted metadata appears; labels, values, routes, arguments, results, state, exception text, stacks, and inactive historical identities remain absent. |

### Group R5 — Integrate the example without making a support claim

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| R5.1 | Extend baseline task 2.3 and observation task O2.3 with the final single-view setup, publisher capability display, immediate observation, read/act/navigation receipt flow, unsupported-browser manual path, and test instrumentation needed for the native trace. | AC-003, AC-014 through AC-017, AC-019, AC-022 through AC-024, AC-026, AC-028 through AC-035 | Baseline owner 2.3 retains example/lib/, example/test/, integration_test/page_agent_test.dart, and its append-only evidence | No | Page-conformance regression succeeds, the example carries an explicit experimental/unsupported marking, and it is ready for native proof. This closes without authentication and supersedes the real-agent done-when of baseline 2.3 and O2.3; native support, delivery, release, and completion stay blocked until R7.1 passes. |

### Group R6 — Preserve optional generator scope

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| R6.1 | Execute baseline generator task 3.1 as extended by O3.2 after the runtime MVP contract is stable. Retain opt-in public instance methods, generated WebMcpToolSource ownership, supported type and diagnostic rules, live-instance replacement, application authorization, and optional operation-linked evidence. | AC-012, AC-013, AC-017, AC-018, AC-024 through AC-026 | Baseline owner 3.1 retains proposed annotation/generator packages, generator tests, lifecycle fixtures, and generator evidence; example changes are requested from R5.1 | No | Dependency solve and positive/negative generator tests pass. If they do not, the runtime MVP remains separately usable but full work-item completion and generator delivery remain blocked. |

### Group R7 — Re-run authenticated Chrome-only native proof

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| R7.1 | Before final verification, re-run the required isolated inspector profile in official Chrome with valid Gemini authentication and a natural-language prompt. Preserve the complete discover, observe, read, act, navigate, receipt, observe, read sequence with model-selected calls and exact environment details. | AC-002, AC-014, AC-017, AC-022 through AC-024, AC-026, AC-028 through AC-030, AC-035 | Baseline browser/example verification owner retains the fixture and owns a new append-only native trace evidence artifact; corrected 05-transport-spike.md remains read-only | No | Every ordered step and visible permitted effect is present for each claimed supported build. Missing authentication, disabled prompt, direct execution, simulated selection, a skipped step, or absent destination read leaves native support, delivery, release, and completion blocked. |
| R7.2 | Re-run JavaScript and Wasm page conformance beside the authenticated native trace and compare capability reporting with the corrected start-aware cancellation evidence. | AC-002, AC-010, AC-011, AC-017, AC-022, AC-026, AC-028, AC-029, AC-034, AC-035 | Same browser verification owner and append-only evidence as R7.1 | No | Registration, invocation, cleanup, cancel-before-dispatch, no post-start signal, no replay, bounds, cursor recovery, and navigation receipts still match the frozen contract. |

### Group R8 — Final independent verification and documentation

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| R8.1 | Extend baseline documentation task 4.1 and O4.1 with the exact single-view support boundary, owner-rebind behavior, Chrome cancellation capabilities, conformance-versus-native distinction, authenticated trace status, retained generator stage, limits, privacy, fallback, and rollback. | AC-015 through AC-018, AC-019 through AC-035 | Baseline documentation owner retains README.md, wiki/product/webmcp-contract.md, wiki/INDEX.md, the next verified unused ADR, and append-only delivery notes | No | Documentation reflects only delivered stages and tested matrices and makes no multiple-view, platform-gesture, in-flight-cancellation, simulated-native, generator, or completion claim beyond evidence. |
| R8.2 | Extend baseline verification task 4.2 and O4.2 to run the full repository checks, supported Flutter matrix, all resource/privacy tests, JavaScript/Wasm conformance, R7 authenticated trace, wiki lint, and one blind implementation review against AC-001 through AC-035. | AC-001 through AC-035 | Baseline verification owner retains append-only verification evidence and a new numbered implementation validation report | No | Exact output is archived, every criterion has a verdict and negative case, every finding has a main-agent disposition, and no failing, unavailable, partial, or unshipped stage is reported complete. |
| R8.3 | Report stage completion honestly. The runtime MVP may be named only when its applicable criteria pass; native support requires R7; full work-item completion also requires every retained in-scope generator and documentation criterion. | AC-012 through AC-018, AC-028 through AC-035 | Main agent only for STATE.yaml and final status; no source ownership | No | Status distinguishes implemented, conformance-tested, natively supported, generator-delivered, and fully complete without collapsing them into one claim. |

## Dependency order

R1 is a hard prerequisite for all implementation. R2 establishes publisher capabilities and shared transport ownership before R3 requests exports or transport changes. R3 establishes the page/session contracts before R4 can decisively test their component limits. R5 integrates only after R2 and R3. R6 remains after the stable runtime MVP contract and cannot be silently deleted. R7 runs against the integrated final candidate after R2 through R5 and before R8 final verification. R8 cannot claim native support without R7 or full completion without the applicable R6 generator results.

Authentication availability is not a prerequisite for R2 through R6. It is a hard prerequisite for R7's successful verdict and therefore for native support, release, delivery, and completion claims.

## Serialised files

| File or area | Owning task |
|---|---|
| Registry, transports, public exports, dependency/configuration files, package manifest, and lockfile | Baseline 2.1 extended by R2.1 and R2.2; all other tasks request changes. |
| Proposed lib/src/page/ and test/page/ | Baseline 2.2 extended by R3.1 through R3.4; one owner controls view, owner, session, broker, projection, and dispatcher contracts. |
| Example and native integration fixture | Baseline 2.3 extended by R5.1 and exercised by R7; R6 requests example changes from this owner. |
| Proposed annotations and generator packages/tests | Baseline 3.1 extended by R6.1. |
| README, product contract, wiki router, ADR, and delivery notes | Baseline 4.1 extended by R8.1. |
| Append-only implementation, resource, conformance, native trace, and final verification evidence | Baseline verification owners extended by R4, R7, and R8; existing 04 and 05 spike artifacts are never overwritten. |
| Criteria artifacts and STATE.yaml | Main agent only. Criteria change only through a recorded validation round; STATE.yaml is never delegated. |

## Test tasks

| # | Covers | Positive case | Negative case |
|---|---|---|---|
| R2.1 | AC-029, AC-030 | Chrome 152 JavaScript and Wasm publish, invoke, clean up registration, cancel before dispatch, and report capabilities accurately. | Start-aware caller abort supplies no callback signal; callback may finish, no replay occurs, and no in-flight termination claim appears. |
| R3.1 | AC-031 | Exactly one owned view resolves the marker and permits eligible reads/actions. | Zero, two, ambiguous, or changed-unbound views revoke and expose nothing automatically without fallback. |
| R3.2 | AC-032 | Owner identity change revokes, detaches, rebinds, recaptures, and then safely resumes. | Old-owner handles/listeners/callbacks cannot read, act, publish, or survive replacement. |
| R3.3 | AC-033 | Known observer gesture/transition events revoke promptly and proved settling can resume. | Unknown, interrupted, absent, or quiet-only state remains inactive and cannot create a support claim. |
| R4.2 | AC-027, AC-034 | Every implemented component remains bounded at its exact retained ceiling. | One over returns busy/resourceLimit before effects, no owner is evicted, and never-settled work keeps an anonymous occupied slot. |
| R4.3 | AC-028 through AC-034 | Safe capability, view, owner, broker, cancellation, and receipt metadata contains only allowlisted fields. | Synthetic labels, values, routes, arguments, results, state, errors, stacks, and inactive identities appear nowhere. |
| R7.1 | AC-030, AC-035 | Authenticated Chrome natural-language agent completes discover-observe-read-act-navigate-receipt-observe-read with model-selected calls. | Missing authentication, disabled prompt, simulated/manual/direct calls, stale acceptance, absent receipt, or missing destination read fails the gate. |
| R8.2 | AC-001 through AC-035 | Full checks, supported matrices, all negative cases, and blind per-criterion review support the exact delivered stages. | Any missing output, failed criterion, unavailable claimed capability, unshipped generator, or unresolved finding blocks the corresponding claim. |
