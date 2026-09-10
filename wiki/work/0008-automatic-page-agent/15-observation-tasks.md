# Tasks: Low-boilerplate page observation

## Legend

- All tasks are future work, not started; this request authorizes planning only.
- This extends 03-tasks.md. Its publisher, generator, documentation and full verification work remains required for corresponding stage claims. These rows refine observation responsibilities rather than creating duplicate owners.
- Every newly named implementation/evidence path is PROPOSED. Recheck unused evidence numbers before writing them. Original artifacts remain available.
- Groups run sequentially; shared architecture, interface freeze and validation verdict are never parallel. The same owner implements and tests each module.
- Original and added criteria freeze together only after the future gate review. A change after freeze requires a recorded validation round.

## Groups

### Group 1 — Extend baseline feasibility gates

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| O1.1 | Extend baseline task 1.1 with navigator forest, root modality, branch activity, gesture/transition gating, semantics rebinding, projection comparison and resource spikes. | AC-001, AC-005, AC-006, AC-008, AC-009, AC-016, AC-019, AC-020, AC-021, AC-027 | Through baseline owner 1.1: proposed spikes/page-semantics/; new proposed observation-semantics evidence artifact | No | Supported debug/profile/release outputs establish ownership, prompt invalidation, final settling and fixed bounds; unavailable SDK or failed safety evidence blocks dependents. |
| O1.2 | Extend baseline task 1.2 with app observe, navigation during dispatch, app-owned receipts, optional waits, cancellation, cursor-gap recovery and immediate polling fallback. | AC-002, AC-011, AC-014, AC-022, AC-023, AC-024, AC-026, AC-027, AC-028 | Through baseline owner 1.2: proposed spikes/native-publisher/; new proposed observation-transport evidence artifact | No | Real native browser-agent trace records exact builds and successful post-navigation observation/receipt behavior; positive wait support is enabled only if demonstrated. |
| O1.3 | Extend baseline task 1.3 gate decision with all observation evidence and a fresh blind review before criteria freeze. | AC-001, AC-002, AC-017, AC-018, AC-019 through AC-028 | Through baseline owner 1.3: append-only new gate/validation artifacts; main agent alone owns STATE.yaml | No | All empirical questions have evidence or explicit excluded support; hard bounds, versioned contracts and finding dispositions are fixed. Failure never triggers an unreviewed runtime workaround. |

### Group 2 — Shared-owner MVP implementation

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| O2.1 | Extend baseline task 2.1 publisher integration for the stable app tool and bounded invocation/cancellation lifetime, preserving existing registry and custom transport behavior. | AC-002, AC-010, AC-011, AC-016, AC-019, AC-022, AC-026 | Baseline owner 2.1 retains lib/src/webmcp.dart, lib/src/transport/, public exports, manifests/lockfiles and transport/registry tests | No | Original regression checks and new app-tool attach/collision/detach/cancellation tests pass with pasted outputs. |
| O2.2 | Extend baseline task 2.2 to implement the shared session, per-Navigator adapters, eligibility generations, semantic projections, single broker, app observe, command evidence and post-navigation receipts with their tests. | AC-003 through AC-009, AC-015, AC-016, AC-019 through AC-024, AC-026 through AC-028 | Baseline owner 2.2 retains proposed lib/src/page/ and test/page/; all shared exports requested from 2.1 | No | All core observation criteria have positive and negative evidence, including caps/expiry/redaction and no forbidden post-disposal dispatch. |
| O2.3 | Extend baseline task 2.3 minimal setup and native example with observe-before/after-navigation, disabled positive waits, measurements and unsupported-browser manual use. | AC-003, AC-014, AC-017, AC-019, AC-022, AC-023, AC-024, AC-026, AC-028 | Baseline owner 2.3 retains example/lib/, example/test/ and proposed integration_test/page_agent_test.dart; new proposed observation-mvp evidence artifact | No | Actual browser agent reads, acts, navigates, receives a receipt, discovers the next eligible page through observe and reads it; all claims cite measured versioned evidence. |

### Group 3 — Optional adapters after MVP

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| O3.1 | Implement optional generic selected signals, Flutter Actions composition and versioned router/state adapters only for a declared release scope; document exact coverage and replacement/disposal behavior. | AC-015, AC-016, AC-018, AC-020, AC-025, AC-028 | Proposed lib/src/observation_adapters/ and test/observation_adapters/; any package/config/export change requested from baseline 2.1 and page-contract change from 2.2 | No | Selected instances invalidate without payload leakage; uninstrumented callbacks remain explicitly outside coverage; pinned adapter versions and all composition/cleanup fixtures have evidence. This stage is not required for MVP completion. |
| O3.2 | Extend baseline generator stage only if chosen with operation-linked evidence hooks and optional owned-route wrapping/proxy generation; retain opt-in method, type and authorization limits. | AC-012, AC-013, AC-018, AC-024, AC-025, AC-026 | Baseline owner 3.1 retains proposed annotation/generator packages and lifecycle tests; routing examples requested from 2.3 | No | Generator gates pass; proxy bypasses and unsupported route ownership are documented, and generated calls obey existing domain lifetime and confirmation boundaries. |

### Group 4 — Documentation and independent verification

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| O4.1 | Extend baseline task 4.1 with consumer setup recipe, shared broker/cursor model, stage coverage, fixed limits, typed evidence, versioned support and rollback. | AC-015, AC-016, AC-018, AC-019 through AC-028 | Baseline documentation owner retains README.md, wiki/product/webmcp-contract.md, wiki/INDEX.md and next verified unused ADR; new proposed observation-delivery artifact | No | Documentation matches only delivered stages and actual support, without universal capture, frame-success or state-push claims; original wiki artifacts remain reachable. |
| O4.2 | Extend baseline task 4.2 verification with all additional criteria, native navigation traces, resource/privacy matrix, exact full suite/wiki lint output and independent blind implementation review. | AC-001 through AC-028 | Baseline verification owner retains append-only evidence and new numbered implementation validation report | No | Required stage criteria pass, every finding has a recorded disposition, and unavailable or failing checks block the corresponding claim. Optional adapters/generation may be reported unshipped but never silently marked complete. |

## Serialised files

| File | Owning task |
|---|---|
| Registry, transports, exports, dependency/configuration/lockfiles | Baseline 2.1, extended by O2.1; every other owner requests edits. |
| Proposed lib/src/page/ and test/page/ | Baseline 2.2, extended by O2.2; one owner decides all session, broker, projection and dispatcher changes. |
| Example and native integration fixture | Baseline 2.3, extended by O2.3. |
| Proposed optional observation adapter modules/tests | O3.1; cross-cutting requests go to baseline 2.1 or 2.2. |
| Proposed generator packages/lifecycle fixtures | Baseline 3.1, extended by O3.2. |
| README, product contract, wiki router and ADR | Baseline 4.1, extended by O4.1. |
| STATE.yaml and criteria freeze/revision decisions | Main agent only. |

## Test tasks

| # | Covers | Positive case | Negative case |
|---|---|---|---|
| O1.1/O2.2 | AC-019, AC-020 | Multiple distinct observers preserve consumer callbacks; selected branch and completed uncovered route expose only their owned scopes. | Same observer reused, missing root adapter, background branch, root modal, intermediate frame and interrupted gesture never permit stale reads/actions. |
| O1.1/O2.2 | AC-021 | Changed permitted projection advances content revision; owner rebind and replacement clean up old listeners. | Same-value storms create no content change; no frame times out at 2 seconds; disposed late callback never publishes. |
| O1.2/O2.3 | AC-022, AC-023 | Real agent uses immediate observe, navigates, receives new mount refs and reconciles ring gaps through fresh reads. | Foreign/pagination/app-remount cursor returns gap; unsupported positive waits safely advertise polling; inactive history is not revealed. |
| O2.2/O2.3 | AC-024, AC-026 | A navigation action returns app-owned dispatch receipt after page teardown; explicit operation-linked confirmation reports its actual evidence level. | Human change, unchanged read, plain Future return or quiet frame never proves backend success; no queued action starts after disposal. |
| O3.1/O3.2 | AC-025 | Selected generic/provider signals invalidate, existing dispatchers/observers still execute, generated proxy calls declare coverage. | Nearer dispatcher, unselected provider, direct callback or original service reference is not claimed captured; replacement/disposal removes subscriptions. |
| O1.1/O1.2/O2.2 | AC-027 | Exact-limit events, references, waits and operation sets remain bounded, cancellation frees capacity, whole-event paging retains cursor continuity. | One-over-limit returns busy/resourceLimit; no-frame/hung Future expires, ring overflow returns gap, forged session token grants no reserved capacity. |
| O2.2/O4.2 | AC-028 | Synthetic-secret scan sees only allowlisted metadata and current eligible references; release/native/full-check outputs support declared claims. | Labels, URLs, state, arguments, results, errors, unchecked identifiers and inactive-history identities never appear; missing native/release evidence blocks claims. |
| O4.1/O4.2 | AC-001 through AC-028 | Baseline positive/negative matrix remains in force; stage documentation and rollback match tested behavior. | Failed original criterion, unshipped optional feature or unverified support cannot be hidden by observation test success. |
