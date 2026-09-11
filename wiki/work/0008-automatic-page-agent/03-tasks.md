# Tasks: Automatic page content and actions

## Legend

- All tasks below are future work and are not started. This planning-only work item does not authorize their execution.
- Paths labeled proposed are intended output locations, not claims that files or packages already exist.
- Groups run sequentially. Each implementation owner also writes its tests; no parallel shared-file editing is permitted.
- Every task cites its acceptance criteria. Shared files have one owner; other tasks request changes from that owner.
- Empirical gates stop dependent tasks on failure. A narrowed interface or support claim requires a recorded new validation round before implementation proceeds.

## Groups

### Group 1 — Mandatory feasibility gates

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 1.1 | Prove runtime semantic boundary, lifecycle, activity, and resource behavior using the actual declared baseline and upper test SDK; record fallback decisions. | AC-001, AC-005, AC-006, AC-008, AC-009, AC-016 | Proposed spikes/page-semantics/ and wiki/work/0008-automatic-page-agent/04-semantics-spike.md | No | Debug/profile/release fixtures have recorded outputs, scope safety is proven for the supported matrix, and unsupported cases fail closed. |
| 1.2 | Prove native browser transport and agent invocation against an explicit draft/browser/build matrix. | AC-002, AC-010, AC-011, AC-014 | Proposed spikes/native-publisher/ and wiki/work/0008-automatic-page-agent/05-transport-spike.md | No | Real registration, invocation, cancellation, errors, teardown, and build compatibility have evidence; no property-detection-only pass is accepted. |
| 1.3 | Review both gate reports, finalize supported limits and interface details, and obtain a fresh blind plan verdict before freezing implementation criteria. | AC-001, AC-002, AC-017, AC-018 | Proposed wiki/work/0008-automatic-page-agent/06-gate-decision.md and new numbered validation reports | No | Every gate finding has a recorded decision; frozen criteria are approved through the pipeline, or dependent implementation remains blocked. |

### Group 2 — MVP native publisher and automatic page surface

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 2.1 | Implement additive registry observation, publisher ownership, native interop, wire safety, cancellation, lifecycle, and safe support diagnostics while retaining manual behavior; own all shared public exports/configuration. | AC-002, AC-010, AC-011, AC-016, AC-018 | lib/src/webmcp.dart; lib/src/transport/; public library exports identified before implementation; pubspec.yaml and lockfile if required; test/registry_test.dart; test/transport_web_source_test.dart; test/transport_selection_test.dart; test/transport_web_browser_test.dart; test/webmcp_public_surface_test.dart; proposed test/native_publisher_test.dart | No | Existing manual registry tests and new attach/detach/publication/wire tests pass with output; real-browser fixture still invokes tools. |
| 2.2 | Implement the wrapper, scope controller, privacy/activity policy, snapshot read/act protocol, bounded traversal/query, dispatch guards, and safe diagnostics together with all page tests. | AC-003, AC-004, AC-005, AC-006, AC-007, AC-008, AC-009, AC-015, AC-016 | Proposed lib/src/page/ and test/page/ | No | Every page criterion has positive/negative evidence, race cases refuse dispatch, and resource limits and teardown hold. Shared export or registry changes are requested from task 2.1. |
| 2.3 | Add the minimal consumer example and real native agent discover-read-act-read scenario, unsupported-browser path, performance measurements, and final MVP integration evidence. | AC-003, AC-014, AC-015, AC-016, AC-017 | example/lib/ and example/test/; proposed integration_test/page_agent_test.dart and wiki/work/0008-automatic-page-agent/07-mvp-evidence.md | No | The real agent trace observes the control effect, unsupported browsers retain manual use, and actual measurements plus check output are archived without unsupported claims. |

### Group 3 — Optional generated instance adapters after MVP

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 3.1 | Solve generator dependencies on the declared SDK/analyzer matrix; implement annotations, generated live-instance sources, supported decoding/schema rules, diagnostics, and generation/lifecycle/auth fixtures. | AC-012, AC-013, AC-017 | Proposed packages/webmcp_flutter_annotations/; packages/webmcp_flutter_generator/; test/generated_source_lifecycle_test.dart; wiki/work/0008-automatic-page-agent/08-generator-evidence.md | No | Dependency solve, positive golden/runtime fixtures, unsupported-signature diagnostics, late-state initialization, source replacement, and revoked-authorization tests have passing output. Generator failure does not block use of the separately completed runtime MVP. |

### Group 4 — Documentation, independent verification, and deferred stage

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 4.1 | Document each delivered stage with consumer setup, ownership, privacy, browser support, omissions, rollback, safe diagnostics, and a versioned decision record. Supersede outdated claims without deleting artifacts. | AC-015, AC-016, AC-018 | README.md; wiki/product/webmcp-contract.md; wiki/INDEX.md; proposed ADR at the next verified unused number; proposed wiki/work/0008-automatic-page-agent/09-delivery-notes.md | No | Documentation matches each delivered release and clearly marks generator/provider stages not yet shipped. This owner updates docs with each stage, not as a deferred documentation debt. |
| 4.2 | Run the full repository and supported-environment checks, paste output, and commission a blind implementation review against the frozen criteria and diff; record all limitations. | AC-001 through AC-018 | Proposed wiki/work/0008-automatic-page-agent/10-verification-evidence.md and new numbered implementation validation report | No | Required suite and environment evidence exist, review passes, and every finding has a recorded disposition. Runtime MVP claims cover only MVP criteria; full-plan completion requires the optional generator criteria too. |
| 4.3 | Record a separate future custom-provider proposal only after MVP feedback establishes an application-data need. | AC-018 | Proposed wiki/work/0008-automatic-page-agent/11-provider-followup.md | No | The follow-up names the explicit data/authorization boundary and independent pagination requirement without claiming it is part of semantic discovery or an implemented API. |

## Serialised files

| File | Owning task |
|---|---|
| lib/src/webmcp.dart, lib/src/transport/, public exports, package manifest and lockfile | 2.1; all dependent requests are serialized through this owner. |
| Proposed lib/src/page/ | 2.2; generation uses the established source contract and requests lifecycle changes from this owner. |
| example/lib/ and example/test/ | 2.3; generator examples are integrated through this owner after task 3.1. |
| README.md, wiki/product/webmcp-contract.md, wiki/INDEX.md | 4.1; documentation lands alongside each corresponding implementation stage. |
| STATE.yaml | Main agent only; gate and validation decisions never delegate ownership. |
| 02-criteria.md after implementation freeze | Main agent only through a recorded new validation round; otherwise immutable. |

## Test tasks

| # | Covers | Positive case | Negative case |
|---|---|---|---|
| 1.1 | AC-001, AC-005, AC-006, AC-008, AC-009, AC-016 | Owned page nodes and modal scope resolve in supported release builds. | Ambiguous marker, covered page, unsupported view, secret value, or exceeded budget fails closed. |
| 1.2 | AC-002, AC-010, AC-011, AC-014 | Actual native registration invokes a Dart handler and releases it. | Present-but-broken API, denied policy, cancellation, or unsupported build cannot pass support verification. |
| 1.3 | AC-001, AC-002, AC-017, AC-018 | Complete versioned evidence permits a recorded interface freeze. | Installed 3.38.4-only evidence or missing browser trace leaves the gate blocked. |
| 2.1 | AC-002, AC-010, AC-011, AC-016, AC-018 | Attach syncs existing/later tools; detach cleans native ownership while local invocation remains unchanged. | Duplicate names, repeated attach, unsafe wire objects, thrown callbacks, and cancelled calls never violate ownership or leak errors. |
| 2.2 | AC-003 through AC-009, AC-015, AC-016 | One page wrapper yields bounded semantic reads and guarded actions with valid receipts. | Unwrapped, stale, foreign, disabled, private, out-of-order duplicate, inactive, and disposed requests disclose nothing forbidden and dispatch nothing forbidden. |
| 2.3 | AC-003, AC-014, AC-015, AC-016, AC-017 | Native agent reads, acts, then observes changed content; metrics identify the tested fixture and environment. | Unsupported browser still works manually; incomplete coverage and absent measurements never become completeness or performance claims. |
| 3.1 | AC-012, AC-013, AC-017 | Supported generated methods invoke the current authorized live instance. | Unsupported signature, wrong JSON, late initialization misuse, replaced source, or revoked role fails before forbidden behavior. |
| 4.1 | AC-015, AC-016, AC-018 | Consumer documentation and rollback match delivered stage behavior. | Unshipped package/provider, guessed support matrix, or deleted wiki artifact fails review. |
| 4.2 | AC-001 through AC-018 | Full output and independent per-criterion findings support the appropriate stage claim. | Any missing, failing, or partial required check prevents that claim. |
| 4.3 | AC-018 | Follow-up separates explicit application data from semantic coverage. | A provider is advertised as delivered by the MVP or as automatic hidden-data discovery. |
