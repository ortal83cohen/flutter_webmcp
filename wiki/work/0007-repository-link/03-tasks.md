# Tasks: Publish repository metadata link

## Legend

Tasks execute in order. Each task has exclusive ownership of its listed files. The main agent serializes STATE and publication decisions; validators own only their separate append-only reports.

## Groups

### Group 1 — Prepare and validate

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 1.1 | Record baseline, public destination/version observations, review dispositions and criteria freeze | AC-001, AC-005 | STATE.yaml and new numbered baseline/decision artifacts in this item | No | Blind planning review findings have dispositions and baseline is retained |

### Group 2 — Implement and verify

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 2.1 | Apply the two-file metadata release and run manifest and preservation assertions | AC-001, AC-005 | pubspec.yaml, CHANGELOG.md and new numbered source-verification artifact | No | Exact authorized diff and negative cases are evidenced |
| 2.2 | Prepare isolated payload, run canonical suite, consumer/example builds, final dry run and inventory checks | AC-002, AC-003 | Isolated temporary candidate and helpers; new numbered prepublication evidence and inventory artifacts | No | Zero-warning candidate and local checks are evidenced and prepublication review findings are resolved |

### Group 3 — Publish and document

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 3.1 | Publish exact candidate interactively, verify hosted archive/link and fresh consumer, and document outcome | AC-003, AC-004, AC-005 | Isolated hosted consumer/cache; new numbered publication and outcome artifacts | No | All hosted and negative checks are retained and final blind review passes |

## Serialised files

| File | Owning task |
|---|---|
| STATE.yaml | 1.1; later tasks request phase and disposition updates from its owner |
| pubspec.yaml and CHANGELOG.md | 2.1 |
| Isolated publication candidate and inventory | 2.2; task 3.1 reads the reviewed bytes |

## Test tasks

| # | Covers | Positive case | Negative case |
|---|---|---|---|
| 2.1 | AC-001 | Exact metadata and retained baseline | Wrong URL/version/dependency |
| 2.2 | AC-002 | Exact final selection and zero warnings | Extra/missing file, altered runtime hash, warning |
| 2.2 and 3.1 | AC-003 | Successful checks, payload/hosted builds and provenance | Failed status, missing artifact, incorrect provenance |
| 3.1 | AC-004 | Exact hosted API, archive and visible repository link | Wrong version, changed archive, absent/wrong anchor |
| 1.1 and 3.1 | AC-005 | Preserved unrelated state and complete review evidence | Unauthorized state mutation or incomplete closure |
