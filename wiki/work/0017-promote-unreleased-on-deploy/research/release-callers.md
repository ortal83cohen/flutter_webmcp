# Research: Release callers of the bump helper

## Question

Who calls `tools/bump_patch_version.sh`, what does that caller commit, has work item 0013-request-changelog already implemented a competing changelog path, and what constraint does that impose on promoting Unreleased text at bump time?

## Answer

The only production caller is the bump step in `.github/workflows/release.yml`. After the helper returns, that job commits exactly `pubspec.yaml` and `CHANGELOG.md` as `chore(release): v<version>`, then pushes the commit and an annotated tag. Work item 0013 is still plan-only, so promoting Unreleased at bump time must use the live changelog in that same two-file commit and cannot wait for request records, a disposition ledger, or a second changelog writer.

## Findings

### The release workflow is the only production caller

- Claim: Among the three workflow files, only `release.yml` invokes `tools/bump_patch_version.sh`. The bump step captures the helper's standard output as the new version, writes it to the step output, and passes no repository-root argument.
- Evidence: The invocation is `new_version=$(sh tools/bump_patch_version.sh)`. A search of `.github/workflows/` for that script path returns only this line.
- Source: `.github/workflows/release.yml:112-117`

- Claim: `publish.yml` publishes the already-tagged package and never calls the helper. `checks.yml` runs the package check suite and never calls the helper.
- Evidence: `publish.yml` checks out the tag, installs dependencies, dry-runs, then publishes. `checks.yml` runs `python3 tools/lint_wiki.py` and `bash tools/check.sh`.
- Source: `.github/workflows/publish.yml:11-14`; `.github/workflows/publish.yml:24-44`; `.github/workflows/checks.yml:22-23`; `.github/workflows/checks.yml:48-49`

### That caller commits two files, then tags

- Claim: The release job stages only `pubspec.yaml` and `CHANGELOG.md`, commits them with the prefix `chore(release): v`, pushes that commit to `main`, then creates and pushes an annotated tag `v<version>`. No other path is added in that commit.
- Evidence: The commit step runs `git add pubspec.yaml CHANGELOG.md` and `git commit -m 'chore(release): v${{ steps.bump.outputs.version }}'`. The next two steps push `HEAD:main` and `refs/tags/v<version>`.
- Source: `.github/workflows/release.yml:133-147`

- Claim: That prefix is also the loop guard. The job skips when the triggering commit message already starts with `chore(release): v`, so a follow-up run of the release commit itself does not bump again.
- Evidence: The job `if` uses `startsWith(github.event.head_commit.message, 'chore(release): v')` and the comment requires that prefix to stay identical to the commit step.
- Source: `.github/workflows/release.yml:35-38`; `.github/workflows/release.yml:133-138`

- Claim: The helper itself performs no git write. The commit, tag, push, and secret check belong to the workflow. A missing `RELEASE_GITHUB_TOKEN` fails before checkout, so a failed secret cannot leave a half-applied bump on `main`.
- Evidence: The product note says the helper lives beside the two workflow files and that git writes belong to the workflow. The first release step exits when the secret is empty, before checkout.
- Source: `wiki/product/release-pipeline.md:13-15`; `wiki/product/release-pipeline.md:21-22`; `wiki/product/release-pipeline.md:47-48`; `.github/workflows/release.yml:40-54`

- Claim: The check suite runs before the helper. Promotion that happens inside or after the bump is therefore not part of the same-run check gate.
- Evidence: `Run package check suite` is `bash tools/check.sh` at lines 66-67. Occupied-version loading is next. The bump step starts at line 112.
- Source: `.github/workflows/release.yml:66-67`; `.github/workflows/release.yml:72-117`

- Claim: Publication starts only from the tag push. `publish.yml` has `contents: read` and does not commit. Any Unreleased promotion that is not already in the tagged release commit never reaches pub.dev.
- Evidence: The workflow triggers on tags matching `v[0-9]+.[0-9]+.[0-9]+`. The publish job permission block is `id-token: write` and `contents: read`. There is no `git add` or `git commit` step.
- Source: `.github/workflows/publish.yml:11-22`; `.github/workflows/publish.yml:24-44`; `wiki/product/release-pipeline.md:19-24`

### Test and check scripts invoke the helper off the release path

- Claim: `tools/test_bump_patch_version.sh` is a second caller. It sets `HELPER_SCRIPT` to `tools/bump_patch_version.sh` and runs that script against temporary fixture copies.
- Evidence: The assignment is at line 9. The first successful-case invocation is `sh "$HELPER_SCRIPT" "$temp_dir"`.
- Source: `tools/test_bump_patch_version.sh:9`; `tools/test_bump_patch_version.sh:36`

- Claim: `tools/check.sh` stage 7 runs that test script, not the helper as a production writer. Both `checks.yml` and the release job run `bash tools/check.sh`, so every package-check run exercises the helper only through tests.
- Evidence: Stage 7 is `sh tools/test_bump_patch_version.sh`. The two workflow jobs that run the suite are the `package` job and the release job's check step.
- Source: `tools/check.sh:70-71`; `.github/workflows/checks.yml:48-49`; `.github/workflows/release.yml:66-67`

### Work item 0013 is plan-only

- Claim: 0013 finished planning and validation. Implementation has not started. Criteria are not frozen. Every implementation task is unchecked.
- Evidence: `STATE.yaml` has `phase: validate`, `planning_status: complete`, `implementation_status: not-started`, and `criteria_frozen: false`. The follow-up says implementation remains unstarted because the user requested planning only.
- Source: `wiki/work/0013-request-changelog/STATE.yaml:4`; `wiki/work/0013-request-changelog/STATE.yaml:10-12`; `wiki/work/0013-request-changelog/STATE.yaml:14-16`

- Claim: The planning-result document repeats that no implementation, commit, push, tag, or deployment was performed, and that the work item stays in validate because implementation has not begun.
- Evidence: Outcome paragraph and the sentence that the work item remains in validate with all implementation tasks unchecked.
- Source: `wiki/work/0013-request-changelog/04-planning-result.md:5`; `wiki/work/0013-request-changelog/04-planning-result.md:13`

- Claim: No `tools/request_changelog.py` or `.changes/` request, reservation, or confirmation tree exists in the repository today. [UNVERIFIED] from the sources this stream was told to treat as primary; the planning-result names those as remaining work, not as shipped files.
- Evidence: Remaining work is to implement `03-tasks.md`. Task 1.2 lists `tools/request_changelog.py` and related paths as planned targets. The task legend says new paths are proposed implementation targets, not claims those files already exist.
- Source: `wiki/work/0013-request-changelog/04-planning-result.md:27`; `wiki/work/0013-request-changelog/03-tasks.md:4`; `wiki/work/0013-request-changelog/03-tasks.md:14`

### 0013 planned a competing owner for the new-version body

- Claim: The 0013 plan would make versioned changelog text come exclusively from verified, undelivered request records, and would replace generic note rendering in the bump helper while keeping its shell entry point.
- Evidence: Goal sentence and step 5.
- Source: `wiki/work/0013-request-changelog/01-plan.md:5`; `wiki/work/0013-request-changelog/01-plan.md:25`

- Claim: The same plan would keep legacy Unreleased text in a disposition ledger, keep numbered sections byte-for-byte, and remove Unreleased from the active changelog only after every disposition is established. Unresolved bullets would block activation. That is the opposite of moving populated Unreleased bullets into the new version at deploy.
- Evidence: Step 4. The planning-result still lists legacy Unreleased disposition as a future verification gate, not a live service assertion.
- Source: `wiki/work/0013-request-changelog/01-plan.md:24`; `wiki/work/0013-request-changelog/04-planning-result.md:27`

- Claim: 0013 already reserved the helper and the release workflow as implementation files. Task 1.2 owns `tools/bump_patch_version.sh`. Task 2.1 owns `release.yml` and `publish.yml`. Task 2.2 owns `CHANGELOG.md` during migration.
- Evidence: Unchecked task rows name those files.
- Source: `wiki/work/0013-request-changelog/03-tasks.md:14`; `wiki/work/0013-request-changelog/03-tasks.md:20-21`

- Claim: Because none of that work shipped, there is no live competing writer today. The constraint is sequencing, not a present merge conflict: 0016 must promote Unreleased through the existing helper-and-two-file commit, and 0013 cannot be treated as the current source of release notes.
- Evidence: `implementation_status: not-started` plus the planning-result remaining-work paragraph.
- Source: `wiki/work/0013-request-changelog/STATE.yaml:11`; `wiki/work/0013-request-changelog/04-planning-result.md:27`

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Put promotion inside `tools/bump_patch_version.sh` | The same command the release job already runs writes the new version section. Populated Unreleased bullets become that section body; empty or absent Unreleased keeps the automated sentence. Numbered sections stay as they are. The existing commit step then records the result in `CHANGELOG.md` beside `pubspec.yaml`. | Change the helper and the test script that already calls it. | Favoured when the new-version body remains part of the write the helper already owns and the workflow already commits. Not chosen in this stream. |
| Separate pre-step in `release.yml` before the helper | A new workflow step or script edits `CHANGELOG.md`, then `sh tools/bump_patch_version.sh` runs. The later commit still stages the same two paths. | Second writer on the same file in one job. Occupied-version loading and the check suite would still see the pre-promotion tree unless the step is moved earlier, which would also change what `tools/check.sh` validates. | Weaker from the allowed sources: the workflow has no changelog writer other than the helper, and a pre-edit cannot be shown to become the new version section without also changing the helper. 0013 also planned to change that same helper later. Not chosen in this stream. |

## Constraints discovered

- Product decision, already made and not reopened here: populated Unreleased bullets move into the new version at deploy; empty or absent Unreleased keeps `- Automated patch release from main.`; published numbered sections are not rewritten.
- Promotion must already be in `CHANGELOG.md` when the release job commits. That commit is the only durable changelog write before the tag that starts `publish.yml` (`.github/workflows/release.yml:133-147`; `.github/workflows/publish.yml:11-14`).
- The commit message prefix must remain `chore(release): v`. No GitHub bracketed workflow-skip instruction may appear on that commit (`wiki/product/release-pipeline.md:26-32`; `.github/workflows/release.yml:35-38`).
- The check suite runs before the bump, so same-run checks do not see the promoted text (`.github/workflows/release.yml:66-67`; `.github/workflows/release.yml:112-117`).
- 0013 shipped no request records, renderer, or disposition ledger. Promotion at bump time cannot require those files (`wiki/work/0013-request-changelog/STATE.yaml:11`; `wiki/work/0013-request-changelog/04-planning-result.md:5`; `wiki/work/0013-request-changelog/04-planning-result.md:27`).
- 0013's plan would later take exclusive ownership of the new-version body and would refuse to move Unreleased until a disposition ledger exists. That plan is not live code, but it is a future collision on `tools/bump_patch_version.sh`, `release.yml`, and `CHANGELOG.md` (`wiki/work/0013-request-changelog/01-plan.md:5`; `wiki/work/0013-request-changelog/01-plan.md:24-25`; `wiki/work/0013-request-changelog/03-tasks.md:14`).
- A published pub.dev version is permanent (`wiki/product/release-pipeline.md:50-55`).

## Unresolved

- [UNRESOLVED: Can a pre-step edit to CHANGELOG.md survive the helper's subsequent write, or must the helper change for promoted bullets to appear under the new version?]
- [UNRESOLVED: When 0013 is later implemented, does Unreleased-at-deploy remain the live source of new-version bullets, or does the request-record renderer replace it?]
- [UNRESOLVED: Should 0013's Unreleased-disposition gate and exclusive request-record rule be recorded as superseded for the live release path now, or only when 0013 starts implementation?]
- [UNRESOLVED: After a successful promotion, does the Unreleased heading remain empty, disappear, or wait for a later 0013 ledger?]

## Sources

- `.github/workflows/release.yml`, consulted 2026-09-25
- `.github/workflows/publish.yml`, consulted 2026-09-25
- `.github/workflows/checks.yml`, consulted 2026-09-25
- `wiki/product/release-pipeline.md`, consulted 2026-09-25
- `wiki/work/0013-request-changelog/STATE.yaml`, consulted 2026-09-25
- `wiki/work/0013-request-changelog/04-planning-result.md`, consulted 2026-09-25
- `wiki/work/0013-request-changelog/01-plan.md`, consulted 2026-09-25
- `wiki/work/0013-request-changelog/03-tasks.md`, consulted 2026-09-25
- `tools/test_bump_patch_version.sh`, consulted 2026-09-25 for caller sites only
- `tools/check.sh`, consulted 2026-09-25 for caller sites only
