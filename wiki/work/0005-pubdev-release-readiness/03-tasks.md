# Tasks: pub.dev release readiness

## Legend

All tasks below are future work and are not done. Paths described as new are planned outputs, not existing evidence. Groups run in order. Each owned file has one task owner; other tasks request changes through that owner. No implementation begins before scope decisions, authorization, validation and criteria freeze.

## Groups

### Group 1 — Research and decision gates

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 1.1 | Complete the prior required capability comparison and route scope changes back through planning. | AC-001 | New 08-capability-comparison.md in this work item | No | Every compared behavior has versioned sources and a disposition. |
| 1.2 | Resolve uploader rights to occupied flutter_webmcp, existing-release compatibility, unused version, URLs and redistribution rights; maintain state and criteria freeze through subsequent gates. | AC-001, AC-002, AC-010 | STATE.yaml, 02-criteria.md; new 09-release-decisions.md in this work item | No | Decisions and validation dispositions are recorded and implementation is authorized. |

### Group 2 — Prepare the candidate

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 2.1 | Rename package/barrel and update all imports and hygiene name literals; prepare manifest, versioned release notes and exclusions preserving generated-file protections. | AC-002, AC-003, AC-008 | pubspec.yaml, CHANGELOG.md, new .pubignore; lib/ and existing test/ files for rename only; example/ imports and manifest; active package-name references in tools/ | No | Requested rename is complete, existing tests use the new public import, metadata is consistent and payload decisions are explicit. |
| 2.2 | Replace scaffold copy and old package-name references in active documentation, document existing edge semantics and compile the public usage example with relevant negative checks. | AC-004, AC-005 | README.md, wiki/product/webmcp-contract.md, other active consumer documentation containing package-name references, new test/readme_example_test.dart | No | Public documentation matches existing behavior and its example passes. |
| 2.3 | Add browser runtime detection coverage and compatibility execution with no new public interface; return interface defects to planning. | AC-006, AC-007 | New test/browser_detection_test.dart, .github/workflows/checks.yml | No | Present/absent runtime evidence and the agreed SDK matrix are reproducible. |

### Group 3 — Verify and decide publication

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 3.1 | Run the complete suite, SDK compatibility checks, pub dry-run and isolated payload consumer, including negative cases; inspect privacy and archive contents. | AC-003, AC-004, AC-005, AC-006, AC-007, AC-008, AC-009, AC-011 | New 10-release-verification.md in this work item; disposable external consumer outside repository | No | Exact candidate evidence has no unresolved failed or partial gate. |
| 3.2 | Obtain blind implementation verdict, record dispositions through the state owner, update routing if new product documents were added, and prepare the final publication decision and recovery record. | AC-010, AC-011 | New validation/impl-review-01.md and 11-release-decision.md in this work item; wiki/INDEX.md | No | Independent validator writes verdict once; every finding has a disposition and the exact candidate is ready for owner decision. |
| 3.3 | Only after explicit publication authorization, publish the approved candidate and verify hosted installation and package page; apply immutable-release recovery if necessary. | AC-009, AC-010, AC-011 | New 12-publication-result.md in this work item | No | Authorized upload and hosted checks have recorded outcomes; failures remain open. |

## Serialised files

| File | Owning task |
|---|---|
| STATE.yaml and 02-criteria.md | 1.2 throughout the lifecycle; amendments after freeze require recorded validation |
| pubspec.yaml and .pubignore | 2.1; verification requests changes through this owner |
| README.md and product contract | 2.2; reviewers report findings rather than edit |
| .github/workflows/checks.yml | 2.3 |

## Test tasks

| # | Covers | Positive case | Negative case |
|---|---|---|---|
| 1.1–1.2 | AC-001, AC-002 | Versioned comparison and resolved release decisions | Unsupported parity, unknown authority or placeholder URLs block freeze |
| 2.1 | AC-003, AC-008 | Matching unused version, renamed public imports, valid metadata, required archive assets | Stale old imports, version reuse or lost generated exclusions is rejected |
| 2.2 | AC-004, AC-005 | Public example compiles; documented lifecycle matches tests | Invalid names, duplicate ownership and unsupported atomic/deep-copy promises are rejected |
| 2.3 | AC-006, AC-007 | Browser capability present; supported SDK checks pass | Capability absent stays absent; incomplete SDK run blocks release |
| 3.1 | AC-007, AC-008, AC-009, AC-011 | Full candidate suite, reviewed payload and clean consumer pass | Removed required library fails consumer; leaked or unwanted payload material blocks release |
| 3.2–3.3 | AC-009, AC-010, AC-011 | Approved candidate has hosted smoke evidence and recovery record | No approval means no upload; changed candidate invalidates evidence; failed hosted smoke triggers recovery |

## Superseded by consolidated release planning

On 2026-09-10, [20-tasks-consolidated.md](20-tasks-consolidated.md) superseded the instructions above after the accepted rename and completed capability comparison. This artifact is retained as historical evidence. STATE.yaml identifies the operative artifacts.
