# Research: Skip occupied package versions instead of failing the release bump

## Question

How can this repository permanently stop failing a main-branch release when the next patch version is already occupied, so a later free patch is chosen in one successful run?

## Answer

Today the next computed patch fails the release job when a changelog heading or a git tag already names it; pub.dev is not checked, and a later free patch is never chosen. Occupancy-signals says the job can read pub.dev occupancy from the public package list with no credential, read git occupancy with the existing tag check, and treat a candidate as unsafe for a new bump-and-tag when either signal reports occupied. Skip-strategy says the helper should accept a workflow-assembled occupied-version set and write the first free patch in one invocation, while an unpublished existing tag is publish-retry (fail the bump) rather than skip-next.

## Findings

### Today occupancy is a hard failure, not a skip

- Claim: The repository checks three occupancy signals and no others: a `CHANGELOG.md` heading for the computed version, a local git tag `refs/tags/v<version>`, and the same tag name on `origin`. Both implemented checks treat occupancy as a hard failure. The helper rejects a heading that already names that version and leaves both files untouched. After a successful helper write on the runner, the release job rejects a local or remote tag named `v` plus that version and never commits. It does not inspect pub.dev, GitHub Releases, existing `chore(release):` commits, or the current `pubspec.yaml` value as an occupancy signal, and it does not try a later patch. That fail-and-human-bump path is the 0009 accepted mitigation for two pushes computing the same patch; it does not permanently stop a main-branch release from failing when the next patch is occupied.
- Evidence: The helper's only pre-write occupancy test is the changelog heading grep `^## $NEW_VERSION([[:space:]]|$)`. The release job's only occupancy test is the two-branch tag check after `git fetch --tags --force`, using `git rev-parse --verify --quiet` and `git ls-remote --tags origin`. A repo-scoped search of `tools/` and `.github/` finds those three sites and, in `publish.yml`, only `flutter pub publish --dry-run` then `flutter pub publish --force`. AC-016 requires the collision step to fail the job. There is no later-patch search in `release.yml`.
- Source: `tools/bump_patch_version.sh:75-80`; `.github/workflows/release.yml:69-88`; `.github/workflows/publish.yml:41-44`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:73`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:88`; `wiki/work/0009-pubdev-publish-workflow/02-criteria.md:27` (AC-016). Cited by current-collisions and skip-strategy; occupancy-signals records the same tag guard and the absence of a pub.dev query.

### Occupied-for-skip and tag-collision are different predicates — skip-set membership is an explicit disagreement

- Claim: Occupancy-signals and skip-strategy agree that a candidate is unsafe for a new bump-and-tag when either pub.dev or git reports occupied, and that the two signals are not substitutes. They disagree on whether git-only occupancy belongs in the skip set that chooses a later free patch.
- Evidence: Occupancy-signals' chosen occupancy oracle: treat the candidate as occupied when it is in `versions[].version` or when `git ls-remote --tags origin refs/tags/v<version>` is non-empty. Occupancy-signals' constraint: a candidate is unsafe for a new bump-and-tag when either signal is occupied; pub.dev wins the version-number question when they disagree; git wins the tag-name question when they disagree. Occupancy-signals does not choose a skip-loop versus a skip-list control structure and leaves recovery of tag-present/pub-absent versions such as `0.1.2` or `0.1.3` unresolved. Skip-strategy: skip-next applies when a new release must not reuse the version, which includes any version already on pub.dev; if `vX.Y.Z` exists and `X.Y.Z` is not on pub.dev, `X.Y.Z` must not be placed in the skip set; the helper may still compute it as current-plus-one; the existing tag-collision step then fails, which is the current signal that this is not a new bump. Skip-strategy cites the 0013 recovery table: tag-without-publish is retry publication of the same version, not another bump. A skip set built only from tags would skip a tagged unpublished version and violate that recovery. Disagreement: occupancy-signals' chosen option treats tag existence as occupancy of the candidate; skip-strategy treats unpublished existing tags as publish-retry (fail the bump) rather than skip-next.
- Source: occupancy-signals Answer, Options considered (chosen row), and Constraints; skip-strategy Answer, Findings "An unpublished existing tag is publish-retry, not skip-next" and "Occupied-for-skip and tag-collision are different predicates"; `wiki/work/0013-request-changelog/research/release.md:33-35`; `wiki/work/0013-request-changelog/research/release.md:72`; `wiki/product/release-pipeline.md:50-55`; `.github/workflows/release.yml:76-88`.

### The helper is plus-one only and has no occupancy input

- Claim: `tools/bump_patch_version.sh` reads the top-level `pubspec.yaml` version, requires exactly three numeric components, adds one to the patch, copies major and minor unchanged, writes `pubspec.yaml` and `CHANGELOG.md`, and prints that single new version. It accepts an optional repository-root argument and optional `RELEASE_DATE`. It has no occupied-version parameter, no skip loop, and no increment cap. It performs no git operation and no network call.
- Evidence: Version arithmetic is `PATCH + 1`. Usage and `RELEASE_DATE` are at the top of the script. There is no second positional argument and no environment variable for occupied versions. Temp files are built only after the changelog heading check; the real paths are replaced only after the temp contents validate.
- Source: `tools/bump_patch_version.sh:4-14`; `tools/bump_patch_version.sh:22-59`; `tools/bump_patch_version.sh:75-80`; `tools/bump_patch_version.sh:89-133`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:17`. Cited by current-collisions, occupancy-signals, and skip-strategy.

### A second consecutive helper run succeeds and occupies a further version

- Claim: The helper is not idempotent on a successful tree. Running it twice in a row on the same tree is success twice. The first run advances `pubspec.yaml` and inserts a heading for the first new version; the second run computes the next patch, finds no heading for that further version, writes both files again, and prints the further version. Same-version retry cannot use the normal helper path. A workflow that re-invokes it without reverting files would write a changelog section for the occupied version and then another for the later version.
- Evidence: The helper always increments from the current pubspec line; it does not remember a prior run. The 0009 plan states that a second consecutive run succeeds for this reason and that the disagreement fixture, not a repeated run, is what exercises the heading rejection. The 0013 release research repeats the two-call, two-version observation.
- Source: `tools/bump_patch_version.sh:52-59`; `tools/bump_patch_version.sh:75-80`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:57-59`; `wiki/work/0013-request-changelog/research/release.md:51-52`. Cited by current-collisions and skip-strategy.

### The helper test covers heading disagreement, not a repeated successful run or an occupied set

- Claim: The fixture `reject-changelog-ahead` is the only automated case that exercises helper occupancy. It starts with `pubspec.yaml` at `0.1.1` and a changelog that already has `## 0.1.2 - 2026-01-01`, and it asserts a non-zero exit plus byte-identical files. The test script never runs the helper twice against the same tree. No fixture supplies an occupied-version set. `tools/check.sh` runs this suite as stage 7.
- Evidence: The case list is `valid-patch`, `valid-minor-untouched`, `valid-leading-blank`, `reject-prerelease`, `reject-two-components`, `reject-no-changelog-title`, `reject-missing-changelog`, `reject-missing-pubspec`, `reject-changelog-ahead`, plus `test_real_repo`. `valid-patch` starts from the same pubspec version with no `0.1.2` heading and expects a clean bump to `0.1.2`. The test script sets `RELEASE_DATE=2026-01-02`.
- Source: `tools/fixtures/bump-patch-version/reject-changelog-ahead/`; `tools/fixtures/bump-patch-version/valid-patch/`; `tools/test_bump_patch_version.sh:12-13`; `tools/test_bump_patch_version.sh:32-51`; `tools/test_bump_patch_version.sh:242-262`; `tools/test_bump_patch_version.sh:302-314`; `tools/check.sh:70-71`. Cited by current-collisions and skip-strategy.

### A workflow loop of the existing plus-one helper cannot skip by itself

- Claim: After a revert of `pubspec.yaml` and `CHANGELOG.md`, the helper again reads the original version and again computes the same next patch. A workflow loop of the existing helper therefore either repeats the occupied version, or it must change the starting pubspec (or rewrite the changelog) between attempts. That moves version arithmetic into the workflow and still requires discarding the occupied version's changelog section. Skip-strategy rejected this option.
- Evidence: The new version is always `MAJOR.MINOR.(PATCH + 1)` from the files currently on disk. The release job today calls the helper once and then reads `steps.bump.outputs.version`.
- Source: `tools/bump_patch_version.sh:52-59`; `tools/bump_patch_version.sh:75-80`; `tools/bump_patch_version.sh:128-133`; `.github/workflows/release.yml:69-74`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:57-59`. Cited by skip-strategy.

### Changing only the tag-collision step cannot satisfy skip-next and publish-retry together

- Claim: If the collision step were changed from fail to try-next, without changing the helper, the job would still have already written the occupied version's files. Try-next would then need either a helper re-entry or an inline rewrite of pubspec and changelog in YAML. If try-next meant ignore the existing tag and continue, the later `git tag -a` would fail on a local tag after `git fetch --tags`, or the remote tag push would be rejected. If try-next meant treat every existing tag as occupied, an unpublished tag would be skipped, contradicting 0013. Skip-strategy rejected this option.
- Evidence: File writes happen in the bump step before the collision step. Tag creation uses the same `steps.bump.outputs.version` and does not delete or move tags. 0013 forbids another bump when the tag already exists and publish failed.
- Source: `.github/workflows/release.yml:69-88`; `.github/workflows/release.yml:100-104`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:73`; `wiki/work/0013-request-changelog/research/release.md:34`; `wiki/work/0013-request-changelog/research/release.md:72`. Cited by skip-strategy.

### Official public list of hosted versions plus the existing tag check need no stored credential

- Claim: The supported way to list hosted `webmcp_flutter` versions, with no credential, is `GET https://pub.dev/api/packages/webmcp_flutter` with `Accept: application/vnd.pub.v2+json`. Occupancy of a candidate is membership of that candidate in the `versions` array, field `version`. `latest.version` is not a complete occupancy set. Remote tag occupancy is the non-empty output of `git ls-remote --tags origin refs/tags/v<version>`. Annotated tags also yield a peeled `refs/tags/v<version>^{}` line, which is still non-empty occupancy. The public packages API is readable without a pub.dev token. Tag occupancy reuses the git remote already authenticated by `RELEASE_GITHUB_TOKEN`. `publish.yml` already rejects introducing a long-lived pub.dev credential.
- Evidence: pub.dev's official API help names the Hosted Pub Repository Specification V2 as the supported API. The specification's "List all versions of a package" endpoint is `GET <hosted-url>/api/packages/<package>`. A live fetch on 2026-09-16 returned HTTP 200, `Access-Control-Allow-Origin: *`, top-level keys `name`, `latest`, `versions`, and these `versions[].version` values: `0.1.0`, `0.1.1`, `0.1.4`, `0.1.5`, `0.1.6`. `latest.version` was `0.1.6`. The same fetch used no `Authorization` header. Official API help requires endpoints to be public and read-only. `release.yml:40-54` already requires `RELEASE_GITHUB_TOKEN` for checkout and later git writes. `publish.yml:3-5` and AC-023 allow only that GitHub secret as credential material. On 2026-09-16, `git ls-remote --tags origin refs/tags/v*` showed `v0.1.2` through `v0.1.6` each with a tag object and a peeled annotated-tag line; `v0.1.0`, `v0.1.1`, and `v0.1.7` were empty. Response `Cache-Control: public, max-age=120` on the live packages API. A version published in the previous two minutes may be absent from a cached read.
- Source: https://pub.dev/help/api (consulted 2026-09-16); https://raw.githubusercontent.com/dart-lang/pub/master/doc/repository-spec-v2.md lines 217-254 (consulted 2026-09-16); live `GET https://pub.dev/api/packages/webmcp_flutter` (consulted 2026-09-16); live `git ls-remote --tags origin` (consulted 2026-09-16); https://git-scm.com/docs/git-ls-remote (consulted 2026-09-16); `.github/workflows/release.yml:40-54`; `.github/workflows/publish.yml:3-5`; `wiki/work/0009-pubdev-publish-workflow/02-criteria.md:39` (AC-023). Cited by occupancy-signals. Skip-strategy assumed the workflow can collect occupied strings and treated the HTTP API shape as out of scope.

### Per-version URL, undocumented `.json` listing, and `dart pub` are not the primary occupancy signal

- Claim: `GET https://pub.dev/api/packages/webmcp_flutter/versions/<version>` returns HTTP 200 when that version exists and HTTP 404 with `code` `NotFound` when it does not. The specification marks this endpoint deprecated as of Dart 2.8 and tells clients to use the list endpoint instead. `GET https://pub.dev/packages/webmcp_flutter.json` returned `{"name":"webmcp_flutter","versions":["0.1.6","0.1.5","0.1.4","0.1.1","0.1.0"]}` on 2026-09-16; that page is not listed on the official API help, and help text says undocumented endpoints may change or disappear without notice; the payload has no `retracted` field. Dart SDK 3.13.0's `dart pub` help lists no hosted version listing for an arbitrary package. `dart pub publish --dry-run` is documented as "Validate but do not publish the package." `dart pub bump` only increments the local pubspec. Occupancy-signals rejected the deprecated per-version URL as the primary signal, rejected the undocumented `.json` listing, and rejected learning occupancy from `dart pub publish --dry-run` or a real publish failure because that runs after the tag exists and is too late for the bump-and-tag job. [UNVERIFIED: whether `dart pub publish --dry-run` additionally reports that the local pubspec version already exists on pub.dev.] Current-collisions independently marks [UNVERIFIED] whether `flutter pub publish --dry-run` or `flutter pub publish --force` exits non-zero solely because that version is already hosted; that stream did not consult the pub.dev HTTP API.
- Evidence: Live 2026-09-16: `.../versions/0.1.6` was HTTP 200 with `"version":"0.1.6"`. `.../versions/0.1.2` and `.../versions/0.1.3` were HTTP 404. Live `.json` fetch HTTP 200. `dart pub --help`, `dart pub publish --help`, `dart pub bump --help`, `dart pub outdated --help` from Dart SDK 3.13.0 on 2026-09-16. `publish.yml` runs dry-run then force after checkout; there is no step that lists hosted versions.
- Source: https://raw.githubusercontent.com/dart-lang/pub/master/doc/repository-spec-v2.md lines 443-465 (consulted 2026-09-16); live fetches of those URLs (consulted 2026-09-16); https://pub.dev/help/api (consulted 2026-09-16); Dart SDK 3.13.0 help (consulted 2026-09-16); https://dart.dev/tools/pub/cmd/pub-lish (consulted 2026-09-16); `.github/workflows/publish.yml:11-14`; `.github/workflows/publish.yml:41-44`; `wiki/work/0009-pubdev-publish-workflow/research/version-bump.md:48-55`. Cited by occupancy-signals; the dry-run/force [UNVERIFIED] also appears in current-collisions.

### The two signals already disagree in this repository

- Claim: Tag-absent/pub-present and tag-present/pub-absent both exist today. Pub.dev occupancy cannot be inferred from tags, and tag occupancy cannot be inferred from pub.dev. Current-collisions leaves [UNRESOLVED] whether a tag without a matching changelog heading has actually been observed, or is only a theoretical split between the two occupancy signals the code checks today.
- Evidence: Compared on 2026-09-16.

  | Version | In `versions[].version` on pub.dev | `git ls-remote` tag `v<version>` on origin |
  |---|---|---|
  | 0.1.0 | present | absent |
  | 0.1.1 | present | absent |
  | 0.1.2 | absent (per-version HTTP 404) | present |
  | 0.1.3 | absent (per-version HTTP 404) | present |
  | 0.1.4 | present | present |
  | 0.1.5 | present | present |
  | 0.1.6 | present | present |
  | 0.1.7 | absent | absent |

  Tag-absent/pub-present: tagging `v0.1.0` or `v0.1.1` would start `publish.yml`, which would attempt to upload a version number that pub.dev already holds. Tag-present/pub-absent: the current tag guard would reject another bump to 0.1.2 or 0.1.3, while those numbers are still missing from the hosted list. Deleting those tags is not a recommended repair. Occupancy-signals records `pubspec.yaml` version `0.1.5` on 2026-09-16.
- Source: live `GET https://pub.dev/api/packages/webmcp_flutter` and `.../versions/0.1.2`, `.../versions/0.1.3` (consulted 2026-09-16); live `git ls-remote --tags origin` (consulted 2026-09-16); `.github/workflows/publish.yml:11-14` and `:43-44`; `.github/workflows/release.yml:76-88`; `pubspec.yaml:1-3`. Cited by occupancy-signals. Current-collisions records the theoretical heading/tag split as unresolved.

### Helper unit tests must stay offline, so any pub.dev query lives outside the helper

- Claim: `tools/test_bump_patch_version.sh` must pass with no network. The helper is specified to perform no git operation and touch no network. If the release job queries pub.dev, that query belongs in the workflow (or in a script that the helper tests do not invoke). A pure predicate that accepts a version list as input can still be tested offline with fixtures. Frozen AC-006 requires the test script to exit zero with no network access and to reference no host name, URL, or network command.
- Evidence: The 0009 plan states the helper performs no git operation and touches no network. `tools/check.sh:70` runs that test script as suite stage 7. The helper itself only reads `pubspec.yaml` and `CHANGELOG.md`.
- Source: `wiki/work/0009-pubdev-publish-workflow/02-criteria.md:17` (AC-006); `wiki/work/0009-pubdev-publish-workflow/01-plan.md:17`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:55`; `tools/bump_patch_version.sh:22-44`; `tools/test_bump_patch_version.sh:1-13`; `tools/check.sh:70-71`. Cited by occupancy-signals and skip-strategy; current-collisions records that the helper contains no `git`, `curl`, or other network command.

### Loop guard and commit-then-tag are load-bearing

- Claim: The job-level condition that skips a head commit message starting with `chore(release): v` prevents the release commit's own push from bumping again. It does not ask whether a version, tag, or pub.dev upload already exists. Commit-then-tag is required so a rejected branch push publishes nothing. Comments in the workflow forbid GitHub skip instructions because the annotated tag points at the release commit.
- Evidence: The `if` tests only `github.event.head_commit.message` via `startsWith(..., 'chore(release): v')`. The commit step writes that same prefix plus the bumped version. No version string is compared in the condition. `Push the commit` precedes `Push the tag`.
- Source: `.github/workflows/release.yml:14-17`; `.github/workflows/release.yml:35-38`; `.github/workflows/release.yml:90-104`; `wiki/product/release-pipeline.md:26-32`; `wiki/product/release-pipeline.md:47-48`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:13`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:47`; `wiki/work/0013-request-changelog/research/release.md:33`; `wiki/work/0013-request-changelog/research/release.md:39-41`. Cited by current-collisions and skip-strategy.

### A release commit without a tag is not recovered and is not treated as occupying that version

- Claim: The commit is pushed to `main` before the annotated tag is created or pushed. If that commit lands and the tag step fails, `main` already holds the bumped `pubspec.yaml` and changelog heading, the follow-up workflow run is skipped by the release-prefix guard, and no later step retags that same version. The next non-release push to `main` runs the helper from the already-bumped pubspec and therefore computes a further version; the tag-collision step then checks only that further tag. The helper has no path that reuses a version already written in `pubspec.yaml`. The 0013 matrix records this durable state and the required recovery that the current workflow does not implement: detect the untagged release commit and push only its missing tag, without running the helper again. Skip-strategy: if the release commit for that version is already on `main`, the loop guard skips the bump job entirely, so skip logic must not run and must not invent a later patch. Same-version recovery itself is 0013's work and is not designed here; skip-strategy only requires that skip-occupied not consume that case. Current-collisions leaves [UNRESOLVED] whether the intended future behaviour is still "bump further on the next human push" or a same-version tag-only recovery as required by 0013.
- Evidence: `Push the commit` precedes `Push the tag`. The 0013 recovery table separates commit-without-tag (create the missing tag, do not run the bump helper) from tag-without-publish.
- Source: `.github/workflows/release.yml:35-38`; `.github/workflows/release.yml:97-104`; `wiki/work/0013-request-changelog/research/release.md:32-35`; `wiki/work/0013-request-changelog/research/release.md:51-52`; `tools/bump_patch_version.sh:52-59`. Cited by current-collisions and skip-strategy.

### Publish is tag-triggered only and has no second entry point

- Claim: `publish.yml` runs only on a push of tags matching `v` plus three numeric components. Automated publish is accepted only from a tag-triggered run, which is why occupancy on pub.dev cannot be resolved by retrying `release.yml`. A version that already has a tag but failed dry-run, authentication, or upload cannot be recovered by bumping to a later patch; recovery is a same-version publish retry from that tag. Publishing uses a short-lived OIDC token rather than a stored pub.dev credential. [UNVERIFIED: whether rerunning the original failed tag-triggered `publish.yml` run satisfies pub.dev's tag-trigger rule, already marked unverified in `wiki/work/0013-request-changelog/research/release.md:34`.]
- Evidence: The trigger is `on.push.tags` with pattern `v[0-9]+.[0-9]+.[0-9]+`. The 0013 matrix row for "Tag exists, publish dry run/auth/upload fails" states that the collision guard rejects another bump and that the required recovery is retry publication from the existing tag after verifying pub.dev does not already contain it.
- Source: `.github/workflows/publish.yml:3-5`; `.github/workflows/publish.yml:11-14`; `.github/workflows/publish.yml:16-22`; `.github/workflows/publish.yml:36-44`; `wiki/product/release-pipeline.md:19-24`; `wiki/work/0013-request-changelog/research/release.md:34`. Cited by current-collisions, occupancy-signals, and skip-strategy. The rerun [UNVERIFIED] is from skip-strategy.

### Pub.dev version numbers cannot be reused; retraction is not a free slot

- Claim: A published version remains in the version listing after retraction. Retraction is not deletion. Retracted versions still answer HTTP 200 on the per-version URL and still carry `"retracted": true` on the list endpoint. Pub.dev policy says a published package typically cannot be unpublished or deleted, and that this applies to all versions. Dart's publishing guide says a published package lasts forever. This repository already records that 0.1.0 and 0.1.1 can never be reused and that it builds no retraction path. That permanence is an operator fact and a product contract, not a repository check in `publish.yml`. Tags can be deleted (`git push origin :refs/tags/vX.Y.Z` as documented by GitHub); this repository's release workflow does not delete or force-push tags, and occupancy-signals does not recommend deleting them. Work item 0009 required that neither push step force-push or delete a ref (AC-014).
- Evidence: Spec field `versions[].retracted` is optional and false if omitted. Live `webmcp_flutter` version objects omit `retracted` (treat as false). Live `analyzer` 5.3.0, 5.7.0, and 14.2.0 have `"retracted": true` on the list endpoint; `GET https://pub.dev/api/packages/analyzer/versions/5.3.0` was HTTP 200 with `"retracted": true`. Dart publishing: "Retraction isn't deletion. A retracted package version appears in the version listing of the package on pub.dev".
- Source: https://raw.githubusercontent.com/dart-lang/pub/master/doc/repository-spec-v2.md lines 233-246 (consulted 2026-09-16); https://dart.dev/tools/pub/publishing (consulted 2026-09-16); https://pub.dev/policy (consulted 2026-09-16); live analyzer fetches (consulted 2026-09-16); `wiki/product/release-pipeline.md:50-55`; https://docs.github.com/en/get-started/using-git/pushing-commits-to-a-remote-repository (consulted 2026-09-16); `.github/workflows/release.yml:100-104`; `wiki/work/0009-pubdev-publish-workflow/02-criteria.md:25` (AC-014). Cited by occupancy-signals; permanence and 0.1.0/0.1.1 also in current-collisions and skip-strategy.

### Changelog heading check applies only to the computed new version

- Claim: After computing `NEW_VERSION`, the helper fails if `CHANGELOG.md` already has a heading line that starts with `## ` plus that version, followed by whitespace or end-of-line. On that failure it prints `Error: Version <version> already exists in CHANGELOG.md` to standard error, exits non-zero, and writes neither file. The validated 0009 plan records this as a consistency check between the two files, not as an idempotent "already released" detector and not as an occupancy check against git tags or pub.dev. If skip chooses a later free patch, that check still applies to the chosen version, not to intermediate occupied versions that will not receive a new section.
- Evidence: The occupancy regex is `^## $NEW_VERSION([[:space:]]|$)`. Temp files are built only after that check.
- Source: `tools/bump_patch_version.sh:75-80`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:55-59`. Cited by current-collisions and skip-strategy.

### No increment cap exists today

- Claim: The helper adds exactly one to the patch and stops. A skip loop over an occupied set could increment indefinitely unless a cap is added. The exact cap value is not set in this repository. Parent constraint requires a cap; no source in this repository names the number. [UNVERIFIED: a specific numeric cap that operators would accept]
- Evidence: The only arithmetic is `NEW_PATCH=$((PATCH + 1))`. The test suite has no runaway or maximum-skip case.
- Source: `tools/bump_patch_version.sh:57-59`; `tools/test_bump_patch_version.sh:302-314`. Cited by skip-strategy.

### Skip-strategy's chosen control structure and its test impact

- Claim: Skip-strategy chose: the workflow builds the occupied set (pub.dev versions that must never be reused, plus any other strings it is told to treat as taken); the helper starts at current-plus-one, advances the patch while the candidate is in the set, stops at the first free patch or at a cap, and writes both files once; the existing tag-collision step stays a hard fail for the chosen version. Absent or empty occupied set must keep every current fixture and `test_real_repo` passing. New fixtures are required for: next patch occupied and the following patch free; several consecutive occupied patches with one free patch written and only that heading added; an occupied later patch that is not the next patch, so plus-one is still chosen; cap exceeded with non-zero exit and byte-identical files, matching the existing reject pattern; changelog already heading the chosen free version, extending `reject-changelog-ahead`. Assembling the occupied set from tags and pub.dev stays in the workflow and is not covered by the helper fixtures. [UNVERIFIED: whether a later workflow-level test will assert set membership rules.] Occupancy-signals did not choose this control structure.
- Evidence: Skip-strategy Options considered, chosen row, and "Test impact of the chosen option". Helper offline contract as cited above.
- Source: skip-strategy Options considered and Test impact; `tools/test_bump_patch_version.sh:32-74`; `tools/test_bump_patch_version.sh:124-262`; `tools/test_bump_patch_version.sh:273-294`; `tools/test_bump_patch_version.sh:302-314`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:17`; `tools/check.sh:70-71`; `wiki/work/0013-request-changelog/research/release.md:34`; `.github/workflows/release.yml:76-88`.

### Failure versus success when the next computed version is already occupied, by current meaning

- Claim: Behaviour depends on which meaning of occupied is true. A changelog heading for the computed version fails the helper and therefore the release job's bump step, with no git write. A free changelog plus an existing `v<version>` tag lets the helper succeed on the runner and then fails the tag-collision step, still with no git write. A prior successful helper run, or a landed release commit without its tag, does not fail occupancy for that version; the next helper invocation succeeds on a further version. A version that exists only on pub.dev does not fail the helper or the tag-collision step; any failure would have to come from the later publish commands, which current-collisions does not treat as an occupancy check.
- Evidence: The helper returns before writing when the heading matches; the release bump step runs that helper and the tag guard runs only after it. The second-run and commit-without-tag paths follow from increment-from-pubspec plus commit-then-tag plus the loop guard.
- Source: `tools/bump_patch_version.sh:75-80`; `.github/workflows/release.yml:69-88`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:59`; `wiki/work/0013-request-changelog/research/release.md:32-34`. Cited by current-collisions.

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Helper accepts an occupied-version set and writes the first free patch in one shot; workflow supplies the set | The workflow builds the occupied set. The helper starts at current-plus-one, advances while the candidate is in the set, stops at the first free patch or at a cap, and writes both files once. The existing tag-collision step stays a hard fail for the chosen version. | Helper and fixture tests gain an occupied-set input and new cases. Workflow gains a set-assembly step before the helper. Existing empty-set behaviour stays plus-one. | Chosen by skip-strategy. One successful run writes one changelog section for the free patch. The helper remains fixture-testable offline if the set is injected as data. Tag-exists-but-unpublished stays publish-retry because that version is omitted from the skip set and the collision step still fails. Occupancy-signals did not choose a skip-loop versus skip-list control structure. |
| Official hosted list `GET https://pub.dev/api/packages/webmcp_flutter`, field `versions[].version`, plus existing `git ls-remote --tags origin refs/tags/v<version>` | One unauthenticated HTTP GET in the release job (not in the helper). Occupancy-signals: treat the candidate as occupied when it is in `versions[]` or when the tag exists. Read `versions[].retracted` only as status, never as a free slot. | One public HTTP call; no new secret; helper tests unchanged if the fetch stays outside `tools/bump_patch_version.sh`. | Chosen by occupancy-signals as the occupancy oracle. It is the documented listing API, it includes retracted versions, and it does not pretend git and pub.dev are the same set. Skip-strategy treated the HTTP shape as out of scope and assumed the workflow can collect occupied strings. See the skip-set disagreement in Findings. |
| Occupied means a changelog heading already names the computed version | The helper greps `CHANGELOG.md` for `## <version>` as a section heading and fails closed without writing files. | Local, no network; misses tags and pub.dev; a second run evades it because the pubspec has moved. | This is the only occupancy meaning the helper implements today. The 0009 plan chose it as a file-consistency check, not as full occupancy. Recorded by current-collisions. |
| Occupied means a git tag `v<version>` already exists locally or on `origin` (current `release.yml` guard) | After the helper write, the release job fetches tags and fails on `git rev-parse` or `git ls-remote` for that ref. | Already implemented. Catches a prior tagged release and some races; does not see pub.dev or an untagged release commit; runner-local helper writes are discarded. | This is the only occupancy meaning the release workflow implements today (current-collisions). Occupancy-signals rejected it as an occupancy oracle: it misses pub-present/tag-absent (`0.1.0`, `0.1.1`) and treats tag-present/pub-absent (`0.1.2`, `0.1.3`) as a hard failure of the whole job rather than as a distinct git signal. Skip-strategy keeps this step as a hard fail for publish-retry after a free version is chosen. |
| Occupied means the version is already published on pub.dev | A pre-upload registry check, or treating a publish-command rejection as occupancy. | Would match the product rule that a hosted version cannot be reused. | Not implemented today (current-collisions). Occupancy-signals implements this check via the official list, not via the publish command. |
| Occupied means a release commit for that version already exists on `main` | Inspect history or the current pubspec/changelog pair and refuse to bump further until the matching tag exists. | Would cover the commit-without-tag hole. | Not implemented (current-collisions). Current success behaviour is to skip the release-prefixed push and, on the next human push, bump again. Skip-strategy requires that new skip logic not invent a later patch when the loop guard already skipped. |
| Workflow loops the existing plus-one helper and reverts files between attempts | After each helper write, the job checks occupancy, reverts `pubspec.yaml` and `CHANGELOG.md` if occupied, and calls the helper again. | YAML owns a revert-and-retry loop. Revert alone repeats the same version; the job must also mutate the starting version. An unreverted loop writes changelog sections for skipped versions. Loop logic is not covered by the current fixture suite. | Rejected by skip-strategy. It fights the helper contract and moves skip arithmetic into an untested workflow. |
| Change only the tag-collision step from fail to try-next, without changing the helper | The collision step no longer exits 1 when `v${version}` exists; it somehow continues or selects another version. | Small YAML edit if "continue" means ignore the tag. No helper or fixture change in that reading. | Rejected by skip-strategy. The helper has already written the occupied version. Ignore-and-continue then fails at `git tag -a` or remote tag push, and would skip an unpublished tag, which 0013 classifies as publish-retry, not skip-next. Real try-next collapses into the workflow-loop option. |
| Keep failing and require a human bump | Leave `release.yml` and the helper unchanged. An occupied next patch fails AC-016's collision step; an operator edits the version. | Zero implementation cost. Main-branch releases keep failing in the collision case the 0009 plan already accepted. | Rejected by skip-strategy. It does not meet the question's outcome. It remains the current behaviour. |
| Deprecated per-version `GET .../versions/<candidate>` | HTTP 200 means occupied, 404 means absent. | One request per candidate; deprecated since Dart 2.8. | Rejected by occupancy-signals as the primary signal. It works today for a yes/no probe, including retracted `analyzer` 5.3.0, but the spec tells clients to use the list endpoint, and a skip-over-several-candidates design would multiply round trips. |
| Undocumented `GET https://pub.dev/packages/webmcp_flutter.json` | Compare the candidate to the `versions` string array. | Smaller payload; no `retracted` field; not on the official API help page. | Rejected by occupancy-signals. Help text says undocumented endpoints may change or be removed without notice. |
| `dart pub publish --dry-run` or a real publish failure | Rely on the publish command to notice a collision. | Runs after the tag exists; needs the package tree; `login`/`token` are credential commands and are not required for listing. | Rejected by occupancy-signals. There is no listing subcommand, dry-run is documented as validation not upload, and learning occupancy in the publish job is too late for the bump-and-tag job. |

## Constraints discovered

- The helper performs no git operation and no network call; any occupancy signal that is not present in `pubspec.yaml` or `CHANGELOG.md` is invisible to it (`tools/bump_patch_version.sh`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:17`).
- A non-zero helper exit is specified to leave both files unwritten (`wiki/work/0009-pubdev-publish-workflow/01-plan.md:55-57`; `tools/bump_patch_version.sh:75-80` before the temp-file writes).
- Helper tests stay offline (AC-006). The pub.dev query, if any, lives outside `tools/bump_patch_version.sh` / `tools/test_bump_patch_version.sh`.
- Arithmetic is patch-only; major and minor stay copied (`tools/bump_patch_version.sh:52-59`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:69`).
- If the next patch is occupied, advance by one patch until a free patch is found in the same run (skip-strategy parent constraint).
- Cap runaway incrementing (skip-strategy parent constraint; no repository source names the number).
- No stored pub.dev credential. Listing is a public GET. Publishing already uses GitHub OIDC in `publish.yml`.
- No tag delete or force-push (`.github/workflows/release.yml:100-104`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:73`; AC-014; `wiki/work/0013-request-changelog/research/release.md:72`). Tags can be deleted as documented by GitHub; occupancy-signals does not recommend deleting them. Pub.dev versions cannot be reused; retraction leaves the number occupied.
- Never reuse a pub.dev version (`wiki/product/release-pipeline.md:50-55`).
- Keep the `chore(release): v` loop guard and commit-then-tag (`.github/workflows/release.yml:35-38`, `.github/workflows/release.yml:90-104`). Commit-then-tag is required so a rejected branch push publishes nothing; the cost is the commit-without-tag state (`wiki/product/release-pipeline.md:47-48`).
- Automated publish is accepted only from a tag-triggered run (`.github/workflows/publish.yml:11-14`; `wiki/product/release-pipeline.md:19-24`).
- A tag that exists for a version that is not on pub.dev is publish-retry, not skip-next, unless a later source says otherwise (skip-strategy, citing `wiki/work/0013-request-changelog/research/release.md:34`). Occupancy-signals states the same pair is unsafe for a new bump-and-tag and does not choose a recovery or skip strategy.
- `latest.version` is not occupancy. `webmcp_flutter` latest is `0.1.6` while `0.1.0`, `0.1.1`, `0.1.4`, and `0.1.5` are also published.
- Response `Cache-Control: public, max-age=120` on the live packages API. A version published in the previous two minutes may be absent from a cached read.
- The current tag guard runs after the helper has already rewritten `pubspec.yaml` and `CHANGELOG.md` on the runner. Occupancy that should skip a candidate needs to be known before a commit is created; those local writes are discarded if the job exits before the push.
- Do not implement 0013 request-changelog behaviour in this work item (skip-strategy parent constraint).
- Current-collisions does not design a skip-occupied implementation and does not consult the pub.dev HTTP API. Skip-strategy does not research the pub.dev HTTP API shape. Occupancy-signals does not choose a skip-loop versus a skip-list control structure.

## Unresolved

- [UNRESOLVED: Does `flutter pub publish --dry-run` or `flutter pub publish --force` exit non-zero when the exact version is already hosted on pub.dev, and if so with what message?] (current-collisions)
- [UNRESOLVED: whether `dart pub publish --dry-run` reports that the local pubspec version already exists on pub.dev.] (occupancy-signals; same unknown as the flutter-pub form above; both [UNVERIFIED] markers retained)
- [UNRESOLVED: Does `git rev-parse --verify --quiet refs/tags/v<version>` treat a lightweight tag the same as the annotated tag this workflow creates, in every clone state the checkout-plus-fetch sequence can produce?] (current-collisions)
- [UNRESOLVED: If a tag exists for the computed version but `CHANGELOG.md` has no matching heading, is that a state this repository has actually observed, or only a theoretical split between the two occupancy signals?] (current-collisions)
- [UNRESOLVED: After a release commit lands without its tag, is the intended future behaviour still "bump further on the next human push", or a same-version tag-only recovery as required by `wiki/work/0013-request-changelog/research/release.md`?] (current-collisions; skip-strategy requires that skip-occupied not consume that case and does not design the recovery)
- [UNRESOLVED: When two serialized release runs both checked out the same pre-bump `main`, does the second run always fail at the tag-collision step, or can it also fail later at `git push origin refs/tags/v<version>` if the first tag lands after the second guard?] (current-collisions)
- [UNRESOLVED: whether a rare pub.dev unpublish, granted under policy exceptions, frees that exact version number for a later upload.] (occupancy-signals)
- [UNRESOLVED: how a two-minute CDN cache on `GET /api/packages/webmcp_flutter` should be treated if a publish from `publish.yml` races the next `release.yml` run.] (occupancy-signals)
- [UNRESOLVED: how the release job should recover a tag-present/pub-absent version such as `0.1.2` or `0.1.3` without deleting the tag. Occupancy-signals records the signal disagreement and does not choose a recovery or skip strategy.] (occupancy-signals)
- [UNRESOLVED: whether GitHub-hosted `ubuntu-latest` remaining without `curl` would force the already-present Python 3.12 step to perform the GET. Both are available on the current `release.yml` job as written, but the image inventory was not re-fetched.] (occupancy-signals)
- [UNRESOLVED: What exact helper input carries the occupied-version set (environment variable, file path, or extra arguments) while remaining fixture-injectable and POSIX-shell simple?] (skip-strategy)
- [UNRESOLVED: What numeric cap stops runaway patch incrementing, and is the cap a helper constant or a workflow-supplied value?] (skip-strategy)
- [UNRESOLVED: Which exact strings does the workflow put in the skip set besides published pub.dev versions? Parent allows tags and/or pub.dev, but including unpublished tags would violate 0013.] (skip-strategy; this is the skip-set side of the disagreement with occupancy-signals)
- [UNRESOLVED: How will the workflow obtain the pub.dev occupied list?] (skip-strategy left the HTTP API shape out of scope; occupancy-signals answered the listing URL and still leaves curl-versus-Python unresolved)
- [UNRESOLVED: Should the existing tag-collision step remain mandatory after the helper chooses a free version, as skip-strategy recommends, or be replaced by a different publish-retry probe?] (skip-strategy)
- [UNRESOLVED: Does a changelog heading for an intermediate occupied version, without that version being in the skip set, count as occupied or only as the existing files-disagree reject?] (skip-strategy)
- [UNRESOLVED: Whether a later workflow-level test will assert skip-set membership, or only the helper fixtures will lock the skip behaviour.] (skip-strategy; also [UNVERIFIED] in that stream)

## Sources

- `tools/bump_patch_version.sh` (consulted 2026-09-16)
- `tools/test_bump_patch_version.sh` (consulted 2026-09-16)
- `tools/fixtures/bump-patch-version/reject-changelog-ahead/` (consulted 2026-09-16)
- `tools/fixtures/bump-patch-version/valid-patch/` (consulted 2026-09-16)
- `tools/check.sh` (consulted 2026-09-16)
- `.github/workflows/release.yml` (consulted 2026-09-16)
- `.github/workflows/publish.yml` (consulted 2026-09-16)
- `pubspec.yaml` (consulted 2026-09-16)
- `wiki/product/release-pipeline.md` (consulted 2026-09-16)
- `wiki/work/0009-pubdev-publish-workflow/01-plan.md` (consulted 2026-09-16)
- `wiki/work/0009-pubdev-publish-workflow/02-criteria.md` (consulted 2026-09-16)
- `wiki/work/0009-pubdev-publish-workflow/00-research.md` (consulted 2026-09-16)
- `wiki/work/0009-pubdev-publish-workflow/research/version-bump.md` (consulted 2026-09-16)
- `wiki/work/0013-request-changelog/research/release.md` (consulted 2026-09-16)
- https://pub.dev/help/api (consulted 2026-09-16)
- https://raw.githubusercontent.com/dart-lang/pub/master/doc/repository-spec-v2.md (consulted 2026-09-16)
- https://dart.dev/tools/pub/publishing (consulted 2026-09-16)
- https://dart.dev/tools/pub/cmd/pub-lish (consulted 2026-09-16)
- https://pub.dev/policy (consulted 2026-09-16)
- live `GET https://pub.dev/api/packages/webmcp_flutter` (consulted 2026-09-16)
- live `GET https://pub.dev/api/packages/webmcp_flutter/versions/0.1.6`, `.../0.1.2`, `.../0.1.3` (consulted 2026-09-16)
- live `GET https://pub.dev/packages/webmcp_flutter.json` (consulted 2026-09-16)
- live `GET https://pub.dev/api/packages/analyzer` and `.../versions/5.3.0` (consulted 2026-09-16)
- live `git ls-remote --tags origin` in this repository (consulted 2026-09-16)
- https://git-scm.com/docs/git-ls-remote (consulted 2026-09-16)
- https://docs.github.com/en/get-started/using-git/pushing-commits-to-a-remote-repository (consulted 2026-09-16)
- Dart SDK 3.13.0 `dart pub --help`, `dart pub publish --help`, `dart pub bump --help`, `dart pub outdated --help` (consulted 2026-09-16)

## Provenance

- Question: parent overall question (not any single stream's wording).
- Answer: current-collisions (today is hard-fail); occupancy-signals (public list plus tag check; unsafe when either occupied); skip-strategy (helper accepts a set; unpublished tag is publish-retry).
- Finding "Today occupancy is a hard failure, not a skip": current-collisions and skip-strategy; occupancy-signals for the tag guard and missing pub.dev query.
- Finding "Occupied-for-skip and tag-collision… explicit disagreement": occupancy-signals and skip-strategy.
- Finding "The helper is plus-one only…": current-collisions, occupancy-signals, skip-strategy.
- Finding "A second consecutive helper run…": current-collisions and skip-strategy.
- Finding "The helper test covers heading disagreement…": current-collisions and skip-strategy.
- Finding "A workflow loop of the existing plus-one helper…": skip-strategy.
- Finding "Changing only the tag-collision step…": skip-strategy.
- Finding "Official public list…": occupancy-signals; skip-strategy contributed the out-of-scope note.
- Finding "Per-version URL, undocumented `.json` listing, and `dart pub`…": occupancy-signals; dry-run [UNVERIFIED] also from current-collisions.
- Finding "The two signals already disagree…": occupancy-signals; heading/tag observed-or-theoretical [UNRESOLVED] from current-collisions.
- Finding "Helper unit tests must stay offline…": occupancy-signals and skip-strategy; current-collisions for no network commands in the helper.
- Finding "Loop guard and commit-then-tag…": current-collisions and skip-strategy.
- Finding "A release commit without a tag…": current-collisions and skip-strategy.
- Finding "Publish is tag-triggered only…": all three inputs; rerun [UNVERIFIED] from skip-strategy.
- Finding "Pub.dev version numbers cannot be reused…": occupancy-signals; permanence and 0.1.0/0.1.1 also current-collisions and skip-strategy.
- Finding "Changelog heading check applies only…": current-collisions and skip-strategy.
- Finding "No increment cap exists today": skip-strategy.
- Finding "Skip-strategy's chosen control structure…": skip-strategy.
- Finding "Failure versus success when the next computed version…": current-collisions.
- Options considered: skip-strategy (helper set, workflow loop, change-only-collision, human bump); occupancy-signals (official list, git-only oracle, per-version GET, undocumented JSON, dry-run); current-collisions (changelog heading, git tag, pub.dev, release commit).
- Constraints discovered: union of all three inputs.
- Unresolved: union of all three inputs; no marker dropped.
- Sources: union of all three inputs.
