# Release and publish integration research

## Question

How should explicit ready request records feed a patch release changelog while preserving exact candidate selection, safe retries, and correct behavior across concurrent pushes and partial release failures?

## Answer

The release must persist the exact request IDs selected for a version before any remote write, while keeping that reservation distinct from proof that pub.dev accepted the version. The current workflow has no request-record input, always writes a generic bullet, and has no recovery path when the release commit reaches `main` but its tag does not; a same-version recovery contract is therefore required before request-based changelog generation can be safely integrated.

## Findings

### Current release boundary and input

- Every non-release-prefixed push to `main` starts the bump job; neither a request-ready predicate nor a release manifest gates it (`.github/workflows/release.yml:19-22`, `.github/workflows/release.yml:35-38`).
- The full repository check runs before the helper and before all git writes (`.github/workflows/release.yml:60-74`, `.github/workflows/release.yml:90-104`). A check failure therefore reserves no requests and changes no remote release state.
- The helper reads only `pubspec.yaml` and `CHANGELOG.md` (`tools/bump_patch_version.sh:22-44`). It does not inspect commit messages or pull requests, which is compatible with the required explicit-record source of truth.
- The generated section contains exactly one generic bullet (`tools/bump_patch_version.sh:99-115`), and the workflow stages exactly `pubspec.yaml` and `CHANGELOG.md` (`.github/workflows/release.yml:90-95`). Exact request IDs and their selected state are therefore not durable in the current release commit.

### Reservation must be separate from publication confirmation

- Candidate reservation should snapshot the explicit IDs whose records are ready and eligible, associate that immutable set with the computed version, and render only those records into the version section. The reservation must land in the same release commit as the version and changelog so a retry can recover the exact set rather than reselecting from a changed branch.
- A reservation is not delivery proof. The publish workflow first checks out the tag, resolves dependencies, and performs a dry run; publication is only attempted in its final step (`.github/workflows/publish.yml:24-44`). Any earlier failure leaves a tag but no confirmed pub.dev version.
- Publication confirmation should transition the reserved records to delivered only after the exact package version is confirmed published. If that confirmation write fails after publication, reconciliation must retry confirmation only; it must not bump or republish.
- The repository currently provides no post-publish confirmation step and the publish job has only `contents: read` (`.github/workflows/publish.yml:16-22`). The plan must choose where delivered confirmation is stored and how it is written without accidentally initiating another release.

### Failure and same-version retry matrix

| Last durable state | Current behavior | Required recovery |
|---|---|---|
| Checks, selection, or helper fails before a push | The job stops; local edits disappear with the runner (`.github/workflows/release.yml:66-88`). | Start again from current `main`, rerun checks, and select eligible ready records anew because no reservation was durable. |
| Release commit push is rejected | The tag step is never reached because commit push precedes tag push (`.github/workflows/release.yml:97-104`). | Start again from current `main`; rerun checks and selection. Do not reuse a runner-local reservation. |
| Release commit reaches `main`, tag push fails | `main` contains the bumped version, but the release-prefix loop guard skips its follow-up run (`.github/workflows/release.yml:35-38`, `.github/workflows/release.yml:97-104`). | Detect the existing untagged release commit, verify its reserved IDs and changelog, and create the missing tag for that same version. Do not run the bump helper again. |
| Tag exists, publish dry run/auth/upload fails | The collision guard rejects another bump to that version (`.github/workflows/release.yml:76-88`), while the publish workflow has no retry entry point other than the tag-started run (`.github/workflows/publish.yml:11-14`). | Retry publication from the existing tag and same version after verifying pub.dev does not already contain it. Whether rerunning the existing GitHub run satisfies pub.dev's tag-trigger requirement is `[UNVERIFIED]` from local sources. |
| pub.dev accepts the version, delivered confirmation fails | No confirmation mechanism exists. | Confirm the exact published version, then idempotently mark only its reserved records delivered; never create a replacement version for bookkeeping failure. |

### Branch and tag atomicity options

- The current commit-then-tag order prevents publication when the branch push fails, but exposes a commit-without-tag state (`.github/workflows/release.yml:97-104`).
- Preferred if supported: push the release commit and annotated tag atomically, so both refs advance or neither does. GitHub remote support and whether one atomic push produces the required tag event are `[UNVERIFIED]` from local sources and must be validated before choosing this option.
- Safe fallback: retain commit-then-tag and add an explicit recovery operation that accepts an already-reserved version, verifies the release commit is on `main`, verifies the tag is absent, and pushes only that tag. It must refuse to bump, reselect requests, or move an existing tag.
- Tag-first ordering is unsafe: the tag triggers publication (`.github/workflows/publish.yml:11-14`) before the branch update is known to have succeeded.

### Concurrency does not eliminate stale-branch failures

- The release group prevents cancellation of the running job (`.github/workflows/release.yml:27-29`), but the prior validated plan records that GitHub retains only one running and one pending member and may replace an older pending run (`wiki/work/0009-pubdev-publish-workflow/01-plan.md:49`). A request record must therefore be included because it is eligible in the surviving branch snapshot, never because its individual push produced a workflow run.
- A concurrency group serializes release jobs, not human or bot pushes to `main`. If `main` advances after checkout, the release commit push can be rejected as non-fast-forward; recovery must reacquire current `main`, rerun checks, and recompute the candidate set unless a release commit already landed.
- Selection and changelog rendering must happen after the release job has the branch state it will attempt to release. A queued run must not rely on IDs calculated in the triggering event before it starts.

### Helper and test gaps

- The helper increments from the current pubspec every time; two consecutive successful calls create two versions rather than retrying one (`tools/bump_patch_version.sh:52-59`). Same-version recovery therefore cannot invoke the existing normal bump path.
- The helper writes the two output files with two sequential moves (`tools/bump_patch_version.sh:128-130`). This is not transactionally atomic across the pair: failure of the second move can leave only `pubspec.yaml` updated. Existing negative tests cover validation failures before writing, not an injected second-write failure (`tools/test_bump_patch_version.sh:124-262`).
- Positive fixtures assert only the fixed generic bullet and preservation of the previous section (`tools/test_bump_patch_version.sh:32-74`, `tools/test_bump_patch_version.sh:96-122`). New fixtures need to cover zero eligible records, one and multiple eligible records, deterministic ordering, malformed or duplicate IDs, records already reserved or delivered, an exact same-version retry, and refusal to mix newly-ready records into an existing reservation.
- The current fixture set models pubspec/changelog disagreement through an already-present next-version heading (`tools/fixtures/bump-patch-version/reject-changelog-ahead/CHANGELOG.md:1-9`), but it has no record-state disagreement fixture.

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Generate notes from commit or pull-request text | Infer release contents from git history. | Low implementation cost, ambiguous provenance. | Rejected by the shared design; it cannot express explicit ready/delivered state reliably. |
| Select ready records during every retry | Re-read all ready records and regenerate the section. | Simple happy path. | Rejected because a retry can absorb later records or omit changed records, so the same version is not reproducible. |
| Persist version plus selected request IDs in the release commit | Reserve an immutable candidate set, render its record text, then confirm delivery after publication. | Requires a record schema, recovery path, and confirmation mechanism. | Chosen because it makes changelog contents auditable and enables same-version recovery. |
| Atomic branch-and-tag push | Advance both refs together. | Requires remote/event validation. | Preferred pending verification because it removes the commit/tag split state. |
| Commit then tag with recovery | Keep current ordering and add a verified tag-only repair for an existing release commit. | More states and operator logic. | Chosen fallback if atomic push cannot be proved compatible. |

## Constraints discovered

- No implementation, tag, push, or publication belongs to this work item's research phase.
- A normal release can include only explicit records that are ready at selection time. Delivered is set only after publication confirmation; reservation alone must never be reported as delivered.
- A retry must preserve the reserved version and request-ID set. New ready records wait for the next version.
- Existing tags must never be moved or force-pushed; the current workflow already rejects collisions (`.github/workflows/release.yml:76-88`).
- The published package version is irreversible according to the repository's release contract (`wiki/product/release-pipeline.md:50-55`).

## Unresolved

- [UNRESOLVED: What file format and repository path define each explicit request record, its stable ID, ready state, reserved version, changelog text, and delivered confirmation?]
- [UNRESOLVED: Should a no-eligible-request push exit successfully without a version bump, or fail as a configuration/state error?]
- [UNRESOLVED: Can GitHub atomically update `main` and the annotated tag while still emitting a tag push event accepted by pub.dev automated publishing?]
- [UNRESOLVED: Does rerunning the original failed tag-triggered workflow preserve the pub.dev automated-publishing trust context, or is a new same-tag event required and supported?]
- [UNRESOLVED: How will the workflow verify that an exact version is present on pub.dev before recording delivered state?]
- [UNRESOLVED: Where will post-publish delivery confirmation be stored, and how will its write avoid triggering an unrelated patch release?]
- [UNRESOLVED: What deterministic ordering and text-normalization rules apply when multiple ready records enter one changelog section?]

## Sources

- `.github/workflows/release.yml` (consulted 2026-09-11)
- `.github/workflows/publish.yml` (consulted 2026-09-11)
- `tools/bump_patch_version.sh` (consulted 2026-09-11)
- `tools/test_bump_patch_version.sh` (consulted 2026-09-11)
- `tools/fixtures/bump-patch-version/**` (consulted 2026-09-11)
- `wiki/product/release-pipeline.md` (consulted 2026-09-11)
- `wiki/work/0009-pubdev-publish-workflow/01-plan.md` (consulted 2026-09-11)
