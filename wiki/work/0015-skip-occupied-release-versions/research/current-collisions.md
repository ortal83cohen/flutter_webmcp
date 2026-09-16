# Research: Current collision behaviour of the patch-bump helper and release workflow

## Question

What are the current failure and success behaviours of this repository's patch-bump helper and release workflow when the next computed version is already occupied, and which occupancy signals does the code actually check today?

## Answer

Today the next computed version is treated as occupied in exactly two places, and both treat occupancy as a hard failure rather than a skip. The helper rejects a changelog heading that already names that version and leaves both files untouched; the release job then, after a successful helper write on the runner, rejects a local or remote git tag named `v` plus that version and never commits. A second consecutive helper run is a success that advances to a further version; a release commit that lands without its tag is skipped by the loop guard and is not recovered; pub.dev occupancy is not checked before upload.

## Findings

### Occupancy signals the code checks today

- Claim: The repository checks three occupancy signals and no others: a `CHANGELOG.md` heading for the computed version, a local git tag `refs/tags/v<version>`, and the same tag name on `origin`. It does not inspect pub.dev, GitHub Releases, existing `chore(release):` commits, or the current `pubspec.yaml` value as an occupancy signal.
- Evidence: The helper's only pre-write occupancy test is the changelog heading grep. The release job's only occupancy test is the two-branch tag check after `git fetch --tags --force`. A repo-scoped search of `tools/` and `.github/` for occupancy-related commands finds those three sites and, in `publish.yml`, only `flutter pub publish --dry-run` then `flutter pub publish --force`.
- Source: `tools/bump_patch_version.sh:75-80`; `.github/workflows/release.yml:76-88`; `.github/workflows/publish.yml:41-44`.

### Helper duplicate detection is a changelog-heading consistency check

- Claim: After computing `NEW_VERSION` as the current top-level `pubspec.yaml` version with its third numeric component plus one, the helper fails if `CHANGELOG.md` already has a heading line that starts with `## ` plus that version, followed by whitespace or end-of-line. On that failure it prints `Error: Version <version> already exists in CHANGELOG.md` to standard error, exits non-zero, and writes neither file. The validated plan records this as a consistency check between the two files, not as an idempotent "already released" detector.
- Evidence: Version arithmetic is `PATCH + 1` with major and minor copied unchanged. The occupancy regex is `^## $NEW_VERSION([[:space:]]|$)`. Temp files are built only after that check; the real paths are replaced only after the temp contents validate. The helper contains no `git`, `curl`, or other network command.
- Source: `tools/bump_patch_version.sh:52-59`; `tools/bump_patch_version.sh:75-80`; `tools/bump_patch_version.sh:89-130`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:57-59`.

### The helper test covers heading disagreement, not a repeated successful run

- Claim: The fixture `reject-changelog-ahead` is the only automated case that exercises helper occupancy. It starts with `pubspec.yaml` at `0.1.1` and a changelog that already has `## 0.1.2 - 2026-01-01`, and it asserts a non-zero exit plus byte-identical files. The test script never runs the helper twice against the same tree. The success fixture `valid-patch` starts from the same pubspec version with no `0.1.2` heading and expects a clean bump to `0.1.2`.
- Evidence: The reject fixture files hold that disagreement. The test case copies them, runs the helper once, and compares before/after bytes. The case list is `valid-patch`, `valid-minor-untouched`, `valid-leading-blank`, five other rejects, and `reject-changelog-ahead`; there is no consecutive-run case. `valid-patch` asserts stdout `0.1.2` and a new heading on a changelog that previously topped at `0.1.1`.
- Source: `tools/fixtures/bump-patch-version/reject-changelog-ahead/pubspec.yaml:1-2`; `tools/fixtures/bump-patch-version/reject-changelog-ahead/CHANGELOG.md:1-9`; `tools/test_bump_patch_version.sh:242-262`; `tools/test_bump_patch_version.sh:302-309`; `tools/fixtures/bump-patch-version/valid-patch/pubspec.yaml:1-2`; `tools/fixtures/bump-patch-version/valid-patch/CHANGELOG.md:1-9`; `tools/test_bump_patch_version.sh:32-51`.

### A second consecutive helper run succeeds and occupies a further version

- Claim: Running the helper twice in a row on the same tree is success twice. The first run advances `pubspec.yaml` and inserts a heading for the first new version; the second run therefore computes the next patch, finds no heading for that further version, writes both files again, and prints the further version. Same-version retry cannot use the normal helper path.
- Evidence: The helper always increments from the current pubspec line; it does not remember a prior run. The 0009 plan states that a second consecutive run succeeds for this reason and that the disagreement fixture, not a repeated run, is what exercises the heading rejection. The 0013 release research repeats the two-call, two-version observation.
- Source: `tools/bump_patch_version.sh:52-59`; `tools/bump_patch_version.sh:75-80`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:59`; `wiki/work/0013-request-changelog/research/release.md:51-52`.

### The release job fails on a local or remote tag for the bumped version

- Claim: After the helper prints the new version and before any commit, the `Reject an existing tag for this version` step fetches tags and exits non-zero if `refs/tags/v<version>` already exists in the runner clone or on `origin`. A hit prints `Tag <tag> already exists locally.` or `Tag <tag> already exists on the remote.` and stops the job. Because later steps are sequential, a collision here means the bump is never committed or pushed, so the runner-local helper writes disappear with the job.
- Evidence: The bump step writes `version` to `GITHUB_OUTPUT`. The next step sets `tag="v${{ steps.bump.outputs.version }}"`, runs `git fetch --tags --force`, then `git rev-parse --verify --quiet "refs/tags/${tag}"` and `git ls-remote --tags origin "refs/tags/${tag}"`. Commit and tag-push steps follow only after that guard. The 0009 plan places this guard after the helper and before the commit, and records a same-patch race as failing here or at the later tag push.
- Source: `.github/workflows/release.yml:69-88`; `.github/workflows/release.yml:90-104`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:73`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:88`.

### The loop guard is not an occupancy signal

- Claim: The job-level condition that skips a head commit message starting with `chore(release): v` prevents the release commit's own push from bumping again. It does not ask whether a version, tag, or pub.dev upload already exists.
- Evidence: The `if` tests only `github.event.head_commit.message`. The commit step writes that same prefix plus the bumped version. No version string is compared in the condition.
- Source: `.github/workflows/release.yml:35-38`; `.github/workflows/release.yml:90-95`.

### A release commit without a tag is not recovered and is not treated as occupying that version

- Claim: The commit is pushed to `main` before the annotated tag is created or pushed. If that commit lands and the tag step fails, `main` already holds the bumped `pubspec.yaml` and changelog heading, the follow-up workflow run is skipped by the release-prefix guard, and no later step retags that same version. The next non-release push to `main` runs the helper from the already-bumped pubspec and therefore computes a further version; the tag-collision step then checks only that further tag.
- Evidence: `Push the commit` precedes `Push the tag`. The 0013 matrix records this durable state and the required recovery that the current workflow does not implement: detect the untagged release commit and push only its missing tag, without running the helper again. The helper has no path that reuses a version already written in `pubspec.yaml`.
- Source: `.github/workflows/release.yml:97-104`; `.github/workflows/release.yml:35-38`; `wiki/work/0013-request-changelog/research/release.md:32-33`; `wiki/work/0013-request-changelog/research/release.md:51-52`; `tools/bump_patch_version.sh:52-59`.

### pub.dev occupancy is not checked before the publish upload

- Claim: `publish.yml` does not query whether the tag's version already exists on pub.dev. After checkout and dependency install it runs `flutter pub publish --dry-run` and then `flutter pub publish --force`. Those two commands are the entire publish path. The product document states that a published pub.dev version is permanent and cannot be reused, including the already-published `0.1.0` and `0.1.1`, but that permanence is an operator fact, not a repository check.
- Evidence: The workflow trigger is a tag matching `v` plus three numeric components. There is no step that lists hosted versions, calls a package-versions URL, or compares `pubspec.yaml` to a registry response. The 0009 version-bump research describes `--dry-run` as validation without upload and `--force` as skipping the interactive prompt; it does not describe either flag as an occupancy probe. Whether either command exits non-zero solely because that version is already hosted is `[UNVERIFIED]` from these local sources; this stream did not consult the pub.dev HTTP API.
- Source: `.github/workflows/publish.yml:11-14`; `.github/workflows/publish.yml:41-44`; `wiki/product/release-pipeline.md:50-55`; `wiki/work/0009-pubdev-publish-workflow/research/version-bump.md:48-55`.

### Failure versus success when the next computed version is already occupied

- Claim: Behaviour depends on which meaning of occupied is true. A changelog heading for the computed version fails the helper and therefore the release job's bump step, with no git write. A free changelog plus an existing `v<version>` tag lets the helper succeed on the runner and then fails the tag-collision step, still with no git write. A prior successful helper run, or a landed release commit without its tag, does not fail occupancy for that version; the next helper invocation succeeds on a further version. A version that exists only on pub.dev does not fail the helper or the tag-collision step; any failure would have to come from the later publish commands, which this stream does not treat as an occupancy check.
- Evidence: The helper returns before writing when the heading matches; the release bump step runs that helper and the tag guard runs only after it. The second-run and commit-without-tag paths follow from increment-from-pubspec plus commit-then-tag plus the loop guard, as cited above.
- Source: `tools/bump_patch_version.sh:75-80`; `.github/workflows/release.yml:69-88`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:59`; `wiki/work/0013-request-changelog/research/release.md:32-34`.

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Occupied means a changelog heading already names the computed version | The helper greps `CHANGELOG.md` for `## <version>` as a section heading and fails closed without writing files. | Local, no network; misses tags and pub.dev; a second run evades it because the pubspec has moved. | This is the only occupancy meaning the helper implements today (`tools/bump_patch_version.sh:75-80`). The 0009 plan chose it as a file-consistency check, not as full occupancy. |
| Occupied means a git tag `v<version>` already exists locally or on `origin` | After the helper write, the release job fetches tags and fails on `git rev-parse` or `git ls-remote` for that ref. | Catches a prior tagged release and some races; does not see pub.dev or an untagged release commit; runner-local helper writes are discarded. | This is the only occupancy meaning the release workflow implements today (`.github/workflows/release.yml:76-88`). |
| Occupied means the version is already published on pub.dev | A pre-upload registry check, or treating a publish-command rejection as occupancy. | Would match the product rule that a hosted version cannot be reused (`wiki/product/release-pipeline.md:50-55`). | Not implemented. `publish.yml` has no occupancy step (`.github/workflows/publish.yml:41-44`). This stream did not design a skip path and did not query the pub.dev HTTP API. |
| Occupied means a release commit for that version already exists on `main` | Inspect history or the current pubspec/changelog pair and refuse to bump further until the matching tag exists. | Would cover the commit-without-tag hole. | Not implemented. Current success behaviour is to skip the release-prefixed push and, on the next human push, bump again (`wiki/work/0013-request-changelog/research/release.md:32-33`). |

## Constraints discovered

- The helper performs no git operation and no network call; any occupancy signal that is not present in `pubspec.yaml` or `CHANGELOG.md` is invisible to it (`tools/bump_patch_version.sh:1-133`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:17`).
- A non-zero helper exit is specified to leave both files unwritten (`wiki/work/0009-pubdev-publish-workflow/01-plan.md:55-57`; `tools/bump_patch_version.sh:75-80` before the temp-file writes at `tools/bump_patch_version.sh:89-130`).
- The release job never deletes or force-pushes a tag or branch (`.github/workflows/release.yml:73` in `wiki/work/0009-pubdev-publish-workflow/01-plan.md:73`; the workflow steps at `.github/workflows/release.yml:90-104` are create-and-push only).
- Commit-then-tag is required so a rejected branch push publishes nothing; the cost is the commit-without-tag state (`.github/workflows/release.yml:97-104`; `wiki/product/release-pipeline.md:47-48`).
- A pub.dev version, once uploaded, is recorded as permanent in this repository's product contract (`wiki/product/release-pipeline.md:50-55`).
- Automated publish is accepted only from a tag-triggered run, which is why occupancy on pub.dev cannot be resolved by retrying `release.yml` (`wiki/product/release-pipeline.md:19-24`; `.github/workflows/publish.yml:11-14`).
- This research stream does not design a skip-occupied implementation and does not consult the pub.dev HTTP API.

## Unresolved

- [UNRESOLVED: Does `flutter pub publish --dry-run` or `flutter pub publish --force` exit non-zero when the exact version is already hosted on pub.dev, and if so with what message?]
- [UNRESOLVED: Does `git rev-parse --verify --quiet refs/tags/v<version>` treat a lightweight tag the same as the annotated tag this workflow creates, in every clone state the checkout-plus-fetch sequence can produce?]
- [UNRESOLVED: If a tag exists for the computed version but `CHANGELOG.md` has no matching heading, is that a state this repository has actually observed, or only a theoretical split between the two occupancy signals?]
- [UNRESOLVED: After a release commit lands without its tag, is the intended future behaviour still "bump further on the next human push", or a same-version tag-only recovery as required by `wiki/work/0013-request-changelog/research/release.md`?]
- [UNRESOLVED: When two serialized release runs both checked out the same pre-bump `main`, does the second run always fail at the tag-collision step, or can it also fail later at `git push origin refs/tags/v<version>` if the first tag lands after the second guard?]

## Sources

- `tools/bump_patch_version.sh` (consulted 2026-09-16)
- `tools/test_bump_patch_version.sh` (consulted 2026-09-16)
- `tools/fixtures/bump-patch-version/reject-changelog-ahead/` (consulted 2026-09-16)
- `tools/fixtures/bump-patch-version/valid-patch/` (consulted 2026-09-16)
- `.github/workflows/release.yml` (consulted 2026-09-16)
- `.github/workflows/publish.yml` (consulted 2026-09-16)
- `wiki/product/release-pipeline.md` (consulted 2026-09-16)
- `wiki/work/0009-pubdev-publish-workflow/01-plan.md` (consulted 2026-09-16)
- `wiki/work/0009-pubdev-publish-workflow/research/version-bump.md` (consulted 2026-09-16)
- `wiki/work/0013-request-changelog/research/release.md` (consulted 2026-09-16)
