# Research: Skip occupied package versions instead of failing the release bump

## Question

Which repository component should skip occupied patch versions so a main-branch release chooses a later free patch in one successful run, instead of failing when the next patch is already taken?

## Answer

The bump helper should accept an occupied-version set and write the first free patch in one invocation; the release workflow should assemble that set and keep failing when a chosen version already has a git tag that is not on pub.dev. A workflow loop of the existing plus-one helper cannot advance past an occupied next patch unless it mutates files between attempts, and changing only the tag-collision step would treat an unpublished tag as skip-next instead of publish-retry.

## Findings

### Helper is plus-one only and has no occupancy input

- Claim: `tools/bump_patch_version.sh` reads the top-level `pubspec.yaml` version, requires exactly three numeric components, adds one to the patch, writes `pubspec.yaml` and `CHANGELOG.md`, and prints that single new version. It accepts an optional repository-root argument and optional `RELEASE_DATE`; it has no occupied-version parameter, no skip loop, and no increment cap.
- Evidence: Usage and `RELEASE_DATE` are documented at the top of the script. Version parsing, the `PATCH + 1` arithmetic, the changelog heading check against that computed version, the two file writes, and the stdout print occupy the rest of the script. There is no second positional argument and no environment variable for occupied versions.
- Source: `tools/bump_patch_version.sh:4-14`, `tools/bump_patch_version.sh:37-59`, `tools/bump_patch_version.sh:75-80`, `tools/bump_patch_version.sh:128-133`

### Helper is fixture-tested offline and is invoked as a check-suite stage

- Claim: The helper is tested by copying fixture directories and running the script against the copy with a pinned `RELEASE_DATE`. The suite covers one-step success, patch-only arithmetic, leading-blank changelog layout, several reject cases that leave files byte-identical, and a real-repository plus-one check. No fixture supplies an occupied-version set. `tools/check.sh` runs this suite as stage 7.
- Evidence: The test script sets `RELEASE_DATE=2026-01-02`, copies each named fixture, and asserts stdout and file contents. The case list is `valid-patch`, `valid-minor-untouched`, `valid-leading-blank`, `reject-prerelease`, `reject-two-components`, `reject-no-changelog-title`, `reject-missing-changelog`, `reject-missing-pubspec`, `reject-changelog-ahead`, plus `test_real_repo`. Stage 7 invokes that script.
- Source: `tools/test_bump_patch_version.sh:12-13`, `tools/test_bump_patch_version.sh:302-314`, `tools/check.sh:70-71`; helper offline contract in `wiki/work/0009-pubdev-publish-workflow/01-plan.md:17`, `wiki/work/0009-pubdev-publish-workflow/01-plan.md:55`

### Two consecutive helper runs advance a further patch and leave both changelog sections

- Claim: The helper is not idempotent on a successful tree. A second successful run starts from the already-bumped pubspec and computes the next patch, so a workflow that re-invokes it without reverting files would write a changelog section for the occupied version and then another for the later version.
- Evidence: The 0009 plan states that running the helper twice in a row succeeds twice because the first run advances the pubspec. The 0013 release research repeats that two consecutive successful calls create two versions rather than retrying one, and therefore same-version recovery cannot use the normal bump path.
- Source: `wiki/work/0009-pubdev-publish-workflow/01-plan.md:57-59`; `wiki/work/0013-request-changelog/research/release.md:52`

### Reverting files between plus-one attempts cannot skip by itself

- Claim: After a revert of `pubspec.yaml` and `CHANGELOG.md`, the helper again reads the original version and again computes the same next patch. A workflow loop of the existing helper therefore either repeats the occupied version, or it must change the starting pubspec (or rewrite the changelog) between attempts. That moves version arithmetic into the workflow and still requires discarding the occupied version's changelog section.
- Evidence: The new version is always `MAJOR.MINOR.(PATCH + 1)` from the files currently on disk. The only occupancy check inside the helper is a changelog heading for that computed version, after which both files are written. The release job today calls the helper once and then reads `steps.bump.outputs.version`.
- Source: `tools/bump_patch_version.sh:52-59`, `tools/bump_patch_version.sh:75-80`, `tools/bump_patch_version.sh:128-133`; `.github/workflows/release.yml:69-74`

### Release workflow fails the job when the computed version's tag exists

- Claim: After the single bump, `release.yml` fetches tags and exits non-zero if `v${version}` exists locally or on `origin`. It does not try a later patch. The commit is created only after that guard, then pushed to `main` before the annotated tag is created and pushed. No step deletes or force-pushes a tag or branch.
- Evidence: The collision step interpolates `steps.bump.outputs.version`, uses `git rev-parse` and `git ls-remote`, and exits 1 on a hit. The commit message is `chore(release): v` plus that version. The tag step uses `git tag -a` and `git push origin refs/tags/...` with no force flag.
- Source: `.github/workflows/release.yml:76-104`; collision-before-commit and no-delete/no-force-push in `wiki/work/0009-pubdev-publish-workflow/01-plan.md:73`; AC-016 in `wiki/work/0009-pubdev-publish-workflow/02-criteria.md:27`

### Loop guard and commit-then-tag are load-bearing

- Claim: The bump-and-tag job is skipped when the head commit message begins with `chore(release): v`, which is the same prefix the commit step writes. That is the only loop guard. Commit-then-tag is required so a rejected branch push leaves no tag and therefore starts no publish.
- Evidence: The job-level `if` uses `startsWith(github.event.head_commit.message, 'chore(release): v')`. Comments in the workflow forbid GitHub skip instructions because the annotated tag points at the release commit. The 0009 plan and the 0013 research both record commit-then-tag and the commit-without-tag recovery case.
- Source: `.github/workflows/release.yml:14-17`, `.github/workflows/release.yml:35-38`, `.github/workflows/release.yml:90-104`; `wiki/product/release-pipeline.md:26-32`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:13`, `wiki/work/0009-pubdev-publish-workflow/01-plan.md:47`; `wiki/work/0013-request-changelog/research/release.md:33`, `wiki/work/0013-request-changelog/research/release.md:39-41`

### Publish is tag-triggered only and has no second entry point

- Claim: `publish.yml` runs only on a push of tags matching `v` plus three numeric components. A version that already has a tag but failed dry-run, authentication, or upload cannot be recovered by bumping to a later patch; recovery is a same-version publish retry from that tag.
- Evidence: The trigger is `on.push.tags` with pattern `v[0-9]+.[0-9]+.[0-9]+`. The 0013 matrix row for "Tag exists, publish dry run/auth/upload fails" states that the collision guard rejects another bump and that the required recovery is retry publication from the existing tag after verifying pub.dev does not already contain it.
- Source: `.github/workflows/publish.yml:11-14`, `.github/workflows/publish.yml:36-44`; `wiki/work/0013-request-changelog/research/release.md:34`

### An unpublished existing tag is publish-retry, not skip-next

- Claim: If the next patch already has a git tag and that version is not on pub.dev, the correct action is to keep that version and retry publish, not to advance the patch. Skip-next applies when the next patch is occupied in the sense that a new release must not reuse it, which includes any version already on pub.dev.
- Evidence: The 0013 recovery table separates commit-without-tag (create the missing tag, do not run the bump helper) from tag-without-publish (retry publication of the same version). The product document states that a pub.dev version is permanent and must never be reused; 0.1.0 and 0.1.1 are already published.
- Source: `wiki/work/0013-request-changelog/research/release.md:33-35`, `wiki/work/0013-request-changelog/research/release.md:72`; `wiki/product/release-pipeline.md:50-55`; `wiki/work/0009-pubdev-publish-workflow/00-research.md:25-29`

### Occupied-for-skip and tag-collision are different predicates

- Claim: A skip set built only from tags would skip a tagged unpublished version, which violates same-version recovery. A skip set that includes every pub.dev version, with the existing tag-collision step left as a hard fail, distinguishes the two cases: pub.dev occupancy chooses a later free patch; a remaining tag on the chosen version means publish-retry and must still fail the bump.
- Evidence: The collision step keys only on `refs/tags/v${version}` (`.github/workflows/release.yml:76-88`). The 0013 row keys retry on "tag exists" plus "pub.dev does not already contain it". The product rule that forbids reuse is about published pub.dev versions, not about tags alone.
- Source: `.github/workflows/release.yml:76-88`; `wiki/work/0013-request-changelog/research/release.md:34`; `wiki/product/release-pipeline.md:50-55`

### Changing only the tag-collision step cannot satisfy skip-next and publish-retry together

- Claim: If the collision step were changed from fail to try-next, without changing the helper, the job would still have already written the occupied version's files. Try-next would then need either a helper re-entry (option 1) or an inline rewrite of pubspec and changelog in YAML. If try-next meant ignore the existing tag and continue, the later `git tag -a` would fail on a local tag after `git fetch --tags`, or the remote tag push would be rejected. If try-next meant treat every existing tag as occupied, an unpublished tag would be skipped, contradicting 0013.
- Evidence: File writes happen in the bump step before the collision step. Tag creation uses the same `steps.bump.outputs.version` and does not delete or move tags. 0013 forbids another bump when the tag already exists and publish failed.
- Source: `.github/workflows/release.yml:69-88`, `.github/workflows/release.yml:100-104`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:73`; `wiki/work/0013-request-changelog/research/release.md:34`, `wiki/work/0013-request-changelog/research/release.md:72`

### Human-only bump is the current failure mode and does not meet the outcome

- Claim: Today, an occupied next patch fails the release job at the tag-collision step, or later at tag push, and a human must change the version. That is the 0009 accepted mitigation for two pushes computing the same patch number. It does not permanently stop a main-branch release from failing when the next patch is occupied.
- Evidence: The 0009 risk table says the tag-collision guard fails the second run before it commits. AC-016 requires that step to fail the job. There is no later-patch search in `release.yml`.
- Source: `wiki/work/0009-pubdev-publish-workflow/01-plan.md:88`; `wiki/work/0009-pubdev-publish-workflow/02-criteria.md:27`; `.github/workflows/release.yml:76-88`

### No increment cap exists today

- Claim: The helper adds exactly one to the patch and stops. A skip loop over an occupied set could increment indefinitely unless a cap is added. The exact cap value is not set in this repository.
- Evidence: The only arithmetic is `NEW_PATCH=$((PATCH + 1))`. The test suite has no runaway or maximum-skip case. Parent constraint requires a cap; no source in this repository names the number.
- Source: `tools/bump_patch_version.sh:57-59`; `tools/test_bump_patch_version.sh:302-314`; [UNVERIFIED: a specific numeric cap that operators would accept]

### Changelog heading check applies only to the computed new version

- Claim: The helper rejects a tree whose changelog already has a heading for the version it is about to write. If skip chooses a later free patch, that check still applies to the chosen version, not to intermediate occupied versions that will not receive a new section.
- Evidence: The grep is `^## $NEW_VERSION([[:space:]]|$)`. The 0009 plan describes this as a consistency check between the two files, not as an occupancy check against git tags or pub.dev.
- Source: `tools/bump_patch_version.sh:75-80`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:57-59`

### Workflow can be assumed to supply occupied strings; the HTTP shape is out of scope

- Claim: This research assumes the release workflow can collect occupied version strings from tags and/or pub.dev before invoking the helper. How those strings are fetched from pub.dev is not researched here.
- Evidence: Parent instruction for this stream. Local sources already show tag listing via `git fetch --tags` and `git ls-remote --tags`. They do not show a pub.dev client in `release.yml` or the helper.
- Source: `.github/workflows/release.yml:76-88`; this work item's parent constraints. Pub.dev API shape is deliberately not consulted.

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| 1. Workflow loops the existing plus-one helper and reverts files between attempts | After each helper write, the job checks occupancy, reverts `pubspec.yaml` and `CHANGELOG.md` if occupied, and calls the helper again. | YAML owns a revert-and-retry loop. Because the helper always adds one to the files on disk, revert alone repeats the same version; the job must also mutate the starting version. An unreverted loop writes changelog sections for skipped versions. Loop logic is not covered by the current fixture suite. | Rejected. It fights the helper contract (`tools/bump_patch_version.sh:57-59`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:57-59`) and moves skip arithmetic into an untested workflow. |
| 2. Helper accepts an occupied-version set and writes the first free patch in one shot; workflow supplies the set | The workflow builds the occupied set (pub.dev versions that must never be reused, plus any other strings it is told to treat as taken). The helper starts at current-plus-one, advances the patch while the candidate is in the set, stops at the first free patch or at a cap, and writes both files once. The existing tag-collision step stays a hard fail for the chosen version. | Helper and fixture tests gain an occupied-set input and new cases. Workflow gains a set-assembly step before the helper. Existing empty-set behaviour stays plus-one. | Chosen. One successful run writes one changelog section for the free patch. The helper remains fixture-testable offline if the set is injected as data. Tag-exists-but-unpublished stays publish-retry because that version is omitted from the skip set and the collision step still fails (`wiki/work/0013-request-changelog/research/release.md:34`; `.github/workflows/release.yml:76-88`). |
| 3. Change only the tag-collision step from fail to try-next, without changing the helper | The collision step no longer exits 1 when `v${version}` exists; it somehow continues or selects another version. | Small YAML edit if "continue" means ignore the tag. No helper or fixture change in that reading. | Rejected. The helper has already written the occupied version (`.github/workflows/release.yml:69-74`). Ignore-and-continue then fails at `git tag -a` or remote tag push, and would skip an unpublished tag, which 0013 classifies as publish-retry, not skip-next. Real try-next collapses into option 1. |
| 4. Keep failing and require a human bump | Leave `release.yml` and the helper unchanged. An occupied next patch fails AC-016's collision step; an operator edits the version. | Zero implementation cost. Main-branch releases keep failing in the collision case the 0009 plan already accepted. | Rejected. It does not meet the question's outcome. It remains the current behaviour (`.github/workflows/release.yml:76-88`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:88`). |

### Test impact of the chosen option

- Absent or empty occupied set must keep every current fixture and `test_real_repo` passing, because those cases expect plus-one and no network (`tools/test_bump_patch_version.sh:32-74`, `tools/test_bump_patch_version.sh:273-294`, `tools/test_bump_patch_version.sh:302-314`).
- New fixtures are required for: next patch occupied and the following patch free; several consecutive occupied patches with one free patch written and only that heading added; an occupied later patch that is not the next patch, so plus-one is still chosen; cap exceeded with non-zero exit and byte-identical files, matching the existing reject pattern (`tools/test_bump_patch_version.sh:124-262`); changelog already heading the chosen free version, extending `reject-changelog-ahead`.
- The helper must still perform no git and no network so stage 7 stays offline (`wiki/work/0009-pubdev-publish-workflow/01-plan.md:17`, `tools/check.sh:70-71`).
- Assembling the occupied set from tags and pub.dev stays in the workflow and is not covered by the helper fixtures. [UNVERIFIED: whether a later workflow-level test will assert set membership rules.]

### Tag-exists-but-unpublished under the chosen option

- If `vX.Y.Z` exists and `X.Y.Z` is not on pub.dev, `X.Y.Z` must not be placed in the skip set. The helper may still compute it as current-plus-one. The existing collision step then fails, which is the current signal that this is not a new bump (`wiki/work/0013-request-changelog/research/release.md:34`; `.github/workflows/release.yml:76-88`).
- If the release commit for that version is already on `main`, the `chore(release): v` loop guard skips the bump job entirely, so skip logic must not run and must not invent a later patch (`wiki/work/0013-request-changelog/research/release.md:33`; `.github/workflows/release.yml:35-38`).
- Same-version recovery itself is 0013's work and is not designed here. This stream only requires that skip-occupied not consume that case.
- [UNVERIFIED: whether rerunning the original failed tag-triggered `publish.yml` run satisfies pub.dev's tag-trigger rule, already marked unverified in `wiki/work/0013-request-changelog/research/release.md:34`.]

## Constraints discovered

- If the next patch is occupied, advance by one patch until a free patch is found in the same run (parent constraint).
- The helper stays fixture-testable offline: no git, no network (`wiki/work/0009-pubdev-publish-workflow/01-plan.md:17`, `wiki/work/0009-pubdev-publish-workflow/01-plan.md:55`).
- Arithmetic is patch-only; major and minor stay copied (`tools/bump_patch_version.sh:52-59`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:69`).
- No tag delete or force-push (`.github/workflows/release.yml:100-104`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:73`; `wiki/work/0013-request-changelog/research/release.md:72`).
- Never reuse a pub.dev version (`wiki/product/release-pipeline.md:50-55`).
- Keep the `chore(release): v` loop guard and commit-then-tag (`.github/workflows/release.yml:35-38`, `.github/workflows/release.yml:90-104`).
- A tag that exists for a version that is not on pub.dev is publish-retry, not skip-next, unless a later source says otherwise (`wiki/work/0013-request-changelog/research/release.md:34`).
- Cap runaway incrementing (parent constraint; no repository source names the number).
- Do not implement 0013 request-changelog behaviour in this work item (parent constraint).
- Do not research the pub.dev HTTP API shape (parent constraint).

## Unresolved

- [UNRESOLVED: What exact helper input carries the occupied-version set (environment variable, file path, or extra arguments) while remaining fixture-injectable and POSIX-shell simple?]
- [UNRESOLVED: What numeric cap stops runaway patch incrementing, and is the cap a helper constant or a workflow-supplied value?]
- [UNRESOLVED: Which exact strings does the workflow put in the skip set besides published pub.dev versions? Parent allows tags and/or pub.dev, but including unpublished tags would violate 0013.]
- [UNRESOLVED: How will the workflow obtain the pub.dev occupied list? The HTTP API shape is out of scope for this stream.]
- [UNRESOLVED: Should the existing tag-collision step remain mandatory after the helper chooses a free version, as this research recommends, or be replaced by a different publish-retry probe?]
- [UNRESOLVED: Does a changelog heading for an intermediate occupied version, without that version being in the skip set, count as occupied or only as the existing files-disagree reject?]
- [UNRESOLVED: Whether a later workflow-level test will assert skip-set membership, or only the helper fixtures will lock the skip behaviour.]

## Sources

- `tools/bump_patch_version.sh` (consulted 2026-09-16)
- `tools/test_bump_patch_version.sh` (consulted 2026-09-16)
- `tools/check.sh` (consulted 2026-09-16)
- `.github/workflows/release.yml` (consulted 2026-09-16)
- `.github/workflows/publish.yml` (consulted 2026-09-16)
- `wiki/product/release-pipeline.md` (consulted 2026-09-16)
- `wiki/work/0009-pubdev-publish-workflow/01-plan.md` (consulted 2026-09-16)
- `wiki/work/0009-pubdev-publish-workflow/02-criteria.md` (consulted 2026-09-16)
- `wiki/work/0009-pubdev-publish-workflow/00-research.md` (consulted 2026-09-16)
- `wiki/work/0013-request-changelog/research/release.md` (consulted 2026-09-16; same-version recovery cited, not implemented)
