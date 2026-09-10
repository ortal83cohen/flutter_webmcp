# Tasks: Rename package to webmcp_flutter

## Legend

All tasks run serially; each file has one owner. Criteria freeze before implementation.

## Groups

### Group 1 — Mechanical rename

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 1.1 | Rename identities and consumers; resolve both packages | AC-001, AC-002, AC-003, AC-004 | Root and example manifests, public barrel, source logger files, root and example tests, example source and web metadata, README, ignored dependency metadata | No | Active identities agree and existing behavior is preserved |

### Group 2 — Documentation and verification

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 2.1 | Update active product knowledge and record checks and negative probes | AC-001, AC-002, AC-003, AC-004 | wiki/product/webmcp-contract.md and new verification evidence in this work item | No | Full check and lint output recorded; positive and negative checks evidenced |

## Serialised files

Every implementation file belongs to task 1.1; documentation and verification evidence belong to task 2.1. Validators write only their separately assigned append-only reports.

## Test tasks

| # | Covers | Positive case | Negative case |
|---|---|---|---|
| 2.1 | AC-001 | Existing public-import tests | Old public barrel import fails |
| 2.1 | AC-002 | Resolved example identity and example tests | Old example import fails |
| 2.1 | AC-003 | Active identity scan and label inspection | Injected old identity detected |
| 2.1 | AC-004 | Baseline comparison, full suite, wiki lint | Injected version change rejected |
