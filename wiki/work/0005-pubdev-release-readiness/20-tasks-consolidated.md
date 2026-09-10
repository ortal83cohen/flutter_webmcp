# Tasks: consolidated release preparation

## Legend

Supersedes the future task list in 03-tasks.md. Rename work 0006 and comparisons 08/14/15 are done inputs, not repeated tasks. All execution below remains future work. Groups run sequentially; one owner per path, with other tasks requesting amendments from that owner. Evidence filenames below are planned new artifacts within this work folder; if occupied, use the next unused number without overwriting history.

## Groups

### Group 1 — Authorized implementation

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 1.1 | Record authorization, review dispositions, baseline and freeze; retain selected release decisions and launch checks. | AC-001, AC-002, AC-010, AC-011 | STATE.yaml; new 30-release-execution.md | No | Plan validation is accepted and criteria freeze recorded without rewriting 19. |
| 1.2 | Prepare manifest, release notes and exclusions, retaining accepted rename and MIT. | AC-003, AC-008, AC-011 | pubspec.yaml; CHANGELOG.md; .pubignore | No | SDK floor/version and intended payload match 21; optional URLs absent. |
| 1.3 | Document current contract and fill only missing focused contract evidence. | AC-004, AC-005 | README.md; wiki/product/README.md; wiki/product/webmcp-contract.md; test/registry_test.dart; test/webmcp_scope_test.dart; test/widget_layer_test.dart; test/transport_selection_test.dart | No | Every disclosure in 21 is source/test-supported and sample is ready for consumer compilation. |
| 1.4 | Add internal read-only detection observation and controlled real-browser tests with cleanup. | AC-006, AC-007 | lib/src/transport/transport_web.dart; new test/transport_web_browser_test.dart | No | Both property states exercise actual transport; no barrel change, bridge or fake transport. |

### Group 2 — Candidate verification

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 2.1 | Run complete-source suite/browser tests; create and hash payload from actual dry-run inventory; rerun payload dry-run; verify external consumer and deliberate missing-barrel failure. | AC-003 through AC-009, AC-011 | New 31-release-verification.md; disposable source/payload/consumer directories named in evidence | No | Full output proves all preupload technical gates; final payload bytes are unchanged. |
| 2.2 | Obtain blind implementation verdict; main agent records findings and dispositions through 1.1 owner; refresh final documentation evidence. | AC-010, AC-011 | New validation/impl-review-01.md; new 32-release-readiness.md | No | Prepublication criteria pass, every finding is resolved/disposed, hosted criteria explicitly await upload. |

### Group 3 — Separately authorized launch

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 3.1 | Recheck name/version, authority and payload hashes; obtain exact publication approval; publish interactively from verified payload; verify hosted consumer/presentation and apply recovery if needed. | AC-002, AC-009, AC-010, AC-011 | New 33-publication-result.md | No | Authorized upload and all postpublication results are recorded; failures remain open until resolved. |

## Serialised files

STATE.yaml stays with 1.1. Metadata stays with 1.2; consumer/product docs and focused contracts with 1.3; transport/browser test with 1.4. Verification and validation never patch these files independently. No task owns Git index mutation, staging, commits or pushes.

## Test tasks

| # | Covers | Positive case | Negative case |
|---|---|---|---|
| 1.1–1.2 | AC-001, AC-002, AC-003, AC-008, AC-011 | Complete decisions, exact identity/SDK, safe metadata | Unresolved gap, wrong name/version, private file or placeholder URL rejected |
| 1.3–1.4 | AC-004, AC-005, AC-006 | Public sample, documented contract, marker present | Missing marker false; false lifecycle/atomicity promises rejected |
| 2.1 | AC-007, AC-008, AC-009 | Whole-source suite and hash-identical payload/consumer | Removed barrel fails fresh consumer; extra path/hash mismatch blocks |
| 2.2–3.1 | AC-002, AC-009, AC-010, AC-011 | Approved unchanged candidate and successful hosted checks | No approval means no upload; unavailable name blocks; hosted defect invokes higher-version recovery |
