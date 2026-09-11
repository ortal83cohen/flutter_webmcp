# Acceptance criteria: Request-based release changelog

## Frozen

- Frozen at: not yet
- Frozen by: not yet; planning only

## Criteria

| ID | Criterion | How it is checked | Negative case |
|---|---|---|---|
| AC-001 | When a new feature/change request enters any supported agent entry point, capture shall precede routing, clarification and implementation, including internal/docs requests. | Inspect instructions and exercise direct and forwarded entry-point fixtures. | Bypass capture or duplicate a forwarded UUID. |
| AC-002 | When records are created, UUID filename and ID shall match, immutable sanitized English summary and UTC creation time shall exist, and visibility, reason, category, work link, affected paths and lifecycle/evidence shall validate. | Schema fixtures and immutable-field diff checks. | Malformed JSON, duplicate keys/IDs, invalid time, raw-chat/secret fixtures or missing reason fail. |
| AC-003 | When a quick request is promoted, request and work identities shall remain unchanged; bookkeeping alone shall not disqualify a one-product-file quick change. | Route fixtures and instruction inspection. | Promotion mints duplicate request; two product files incorrectly remain quick. |
| AC-004 | When a request becomes ready, linked route completion artifacts and required successful check evidence shall exist; cancellation shall retain a reason and identity. | Quick/full readiness and cancellation fixtures. | Partial/failing work cannot become ready; cancelled record cannot be selected or deleted. |
| AC-005 | When lint checks post-cutover work, all new work IDs and requests shall have reciprocal links and changed non-bookkeeping paths shall have request coverage; explicit legacy baseline IDs remain exempt. | Base/head tree fixtures including direct source change without work item. | Orphan request, new unlinked work or uncovered source path fails; historical-only work is not backfilled. |
| AC-006 | When a batch contains no eligible public records, validation shall succeed without changing version, changelog, reservation or tag, including internal-only batches. | Empty, pending, cancelled, internal-only and confirmed fixtures. | Malformed input still fails instead of becoming a no-op; generic maintenance bullet is never emitted. |
| AC-007 | When public records are eligible, rendering shall include their exact meaningful notes once, grouped by fixed category and ordered by UTC then UUID, with the actual new version at the top. | Shuffled input, multiple categories and preservation fixtures. | Blank/multiline/injected heading notes fail; commit/PR prose cannot influence output. |
| AC-008 | When creating a candidate, version, changelog and immutable reservation shall describe one exact ID/text/hash/source snapshot, with no cross-version request reuse. | Candidate fixture checks canonical hashes, section digest and selected IDs. | Mismatched version, changed frozen record, duplicate heading or reused ID fails. |
| AC-009 | When preparation or any local write fails, recovery shall restore a consistent pre-candidate or complete-candidate state before proceeding. | Inject failure at each journal and multi-file write boundary. | Mixed pubspec/changelog/manifest state must not be committed. |
| AC-010 | When main changes before candidate push, automation shall use fast-forward-only writes and reacquire main, rerun checks and prefer any durable pending candidate. | Temporary Git remote race fixtures. | Force push, stale selection or unbounded retry fails the criterion. |
| AC-011 | When the candidate commit exists without a tag, recovery shall create only its missing same-version tag after integrity checks; existing matching tags are idempotent. | Commit-success/tag-failure recovery fixture. | Moved/conflicting tag, re-bump or later-ready selection is rejected. |
| AC-012 | When a reservation lacks confirmation, later version allocation shall remain blocked until the same candidate is reconciled. | Pending candidate plus newly-ready record fixture. | New record leaks into retry or triggers another version. |
| AC-013 | When publication is attempted or reconciled, exact package/version plus normalized archive content manifest and registry digest shall match the validated tagged payload before confirmation. | Simulated absent/present/wrong archive, unavailable registry and checksum cases. | Present version with different contents or ambiguous response cannot confirm or trigger a replacement release. |
| AC-014 | When publication succeeds but confirmation write fails, retry shall reconcile without upload or bump, persist only the immutable matching confirmation through fresh-main fast-forward writes, and accept an identical existing file. | Fault injection after upload, main race, identical/conflicting confirmation fixtures. | Lost confirmation causes upload, record reselection or overwritten conflicting proof. |
| AC-015 | When concurrent release, publish and reconciliation jobs run, one shared concurrency group shall serialize mutations without one job waiting for another in that group; confirmation-only changes shall not create releases. | Workflow inspection and state-machine scheduling fixtures. | Deadlock, cancellation of active mutation or confirmation-triggered bump. |
| AC-016 | When rollout activates, every legacy Unreleased bullet shall have preserved text and evidence-backed disposition; existing numbered history stays byte-identical and published changelog has no populated Unreleased section. | Migration fixtures with pending/published/unresolved bullets. | Unknown disposition blocks activation; heading-order inference, silent loss or reannouncement fails. |
| AC-017 | When building the root publication payload, all `.changes/` files shall be absent and generated CHANGELOG.md present; nested package release files shall remain unchanged. | Inspect exact dry-run archive/file manifest. | Metadata leak or independently bumped nested package fails. |
| AC-018 | Before enabling publication, documented evidence shall establish registry identity verification, same-tag workflow retry, confirmation permission and exact payload exclusion; implementation remains incomplete while required local checks or activation gates fail. | Full check output, independent per-criterion review and separate controlled integration evidence. | Simulations cannot be labelled hosted or live proof; planning cannot enable publishing. |

## Non-functional criteria

| ID | Criterion | How it is checked | Negative case |
|---|---|---|---|
| AC-019 | When tooling executes, request handling shall require no new third-party runtime dependency and output shall be deterministic for the same explicit inputs. | Dependency diff and repeat fixture runs. | Network note generation or differing output on shuffled filesystem enumeration. |
| AC-020 | When documenting enforcement and rollback, instructions shall state unseen conversations and semantic relevance cannot be proved by CI, and preserve irreversible publication evidence while disabling automation. | Documentation review and disabled-workflow rollback fixture. | Claim of complete conversational proof, deleted evidence, moved tag or resumed generic releases. |

## Explicitly not required

Live deployment during this planning task; historical work-item backfill; historical numbered changelog rewriting; nested-package release automation; semantic inference from chat, commits or PRs; atomic branch/tag pushes.

## Verdict log

| Round | Date | Verdict | Report |
|---|---|---|---|

## Pre-freeze scope amendment — 2026-09-11

Criteria are not frozen. The following rows supersede AC-006 and AC-007 above while preserving their IDs. For consistency, AC-002 now requires a sanitized meaningful release note for every request, and the phrase “public records” in any selection or note-validation criterion means all request classifications. Visibility must never act as an eligibility filter. All other criteria remain effective.

| ID | Criterion | How it is checked | Negative case |
|---|---|---|---|
| AC-006 | When there are no ready unreserved requests, validation shall succeed without changing version, changelog, reservation or tag; when internal/docs/maintenance requests are ready and unreserved, they shall be included in a release. | Empty, pending, cancelled, reserved and confirmed no-op fixtures plus internal-only and mixed ready batches. | Filtering out ready internal records, releasing an empty set, or treating malformed input as a no-op fails; generic maintenance bullets are never emitted. |
| AC-007 | When any request is ready and unreserved, rendering shall include its exact meaningful sanitized note once, grouped by category and ordered by UTC then UUID, with the actual new version at the top; classification affects presentation only. | Shuffled input, all-internal and mixed visibility/category fixtures, with exact note matching. | Missing, blank, multiline or injected-heading notes fail for every classification; commit/PR prose cannot influence output and no ready classification may be silently omitted. |
