# Research: Skip occupied package versions instead of failing the release bump

## Question

How can a GitHub Actions release job in this repository learn, without storing a pub.dev credential, whether a candidate `webmcp_flutter` version is already published or already tagged, and which of those signals is authoritative when they disagree?

## Answer

The job can read pub.dev occupancy from the public Hosted Pub Repository list at `https://pub.dev/api/packages/webmcp_flutter` by testing whether the candidate string appears in `versions[].version`. That request needs no token. It can read git occupancy with the tag check already in `release.yml`: `git ls-remote --tags origin refs/tags/v<version>`. Pub.dev is authoritative for whether the version number is permanently consumed, including after retraction. Git is authoritative for whether the tag name is currently taken. The two signals already disagree in this repository on both axes, so neither may be inferred from the other. A candidate is unsafe for a new bump-and-tag when either signal reports occupied. The pub.dev query must live outside `tools/bump_patch_version.sh` so the helper tests stay offline.

## Findings

### Official public list of `webmcp_flutter` versions

- Claim: The supported way to list hosted versions, with no credential, is `GET https://pub.dev/api/packages/webmcp_flutter` with `Accept: application/vnd.pub.v2+json`. Occupancy of a candidate is membership of that candidate in the `versions` array, field `version`.
- Evidence: pub.dev's official API help names the Hosted Pub Repository Specification V2 as the supported API. The specification's "List all versions of a package" endpoint is `GET <hosted-url>/api/packages/<package>`. A live fetch on 2026-09-16 returned HTTP 200, `Access-Control-Allow-Origin: *`, top-level keys `name`, `latest`, `versions`, and these `versions[].version` values: `0.1.0`, `0.1.1`, `0.1.4`, `0.1.5`, `0.1.6`. `latest.version` was `0.1.6` and is not a complete occupancy set. The same fetch used no `Authorization` header. Equivalent non-publishing command: `curl -sS -H 'Accept: application/vnd.pub.v2+json' https://pub.dev/api/packages/webmcp_flutter`.
- Source: https://pub.dev/help/api (consulted 2026-09-16); https://raw.githubusercontent.com/dart-lang/pub/master/doc/repository-spec-v2.md lines 217-254 (consulted 2026-09-16); live `GET https://pub.dev/api/packages/webmcp_flutter` (consulted 2026-09-16).

### Per-version URL is a secondary occupancy probe and is deprecated

- Claim: `GET https://pub.dev/api/packages/webmcp_flutter/versions/<version>` returns HTTP 200 when that version exists and HTTP 404 with `code` `NotFound` when it does not. The specification marks this endpoint deprecated as of Dart 2.8 and tells clients to use the list endpoint instead. Servers are still expected to keep it for old clients.
- Evidence: Live 2026-09-16: `.../versions/0.1.6` was HTTP 200 with `"version":"0.1.6"`. `.../versions/0.1.2` and `.../versions/0.1.3` were HTTP 404 with message `Could not find \`version "0.1.2"\`.` (and the same shape for `0.1.3`). Spec section "(Deprecated) Inspect a specific version of a package".
- Source: https://raw.githubusercontent.com/dart-lang/pub/master/doc/repository-spec-v2.md lines 443-465 (consulted 2026-09-16); live fetches of those three URLs (consulted 2026-09-16).

### No `dart pub` subcommand lists hosted versions of this package

- Claim: Dart SDK 3.13.0's `dart pub` help lists `add`, `bump`, `cache`, `deps`, `downgrade`, `global`, `get`, `publish`, `outdated`, `remove`, `unpack`, `upgrade`, `login`, `logout`, `token`, and `workspace`. None of those is a hosted version listing for an arbitrary package. `dart pub publish --dry-run` is documented as "Validate but do not publish the package." `dart pub bump` only increments the local pubspec. `dart pub outdated` analyses dependencies, not this package's own published versions.
- Evidence: `dart pub --help`, `dart pub publish --help` (`-n, --dry-run            Validate but do not publish the package.`), `dart pub bump --help`, `dart pub outdated --help`, all from Dart SDK 3.13.0 on 2026-09-16. The publish command page documents `--dry-run` and `--force` only as validation and confirmation flags.
- Source: Dart SDK 3.13.0 `dart pub --help` (consulted 2026-09-16); https://dart.dev/tools/pub/cmd/pub-lish (consulted 2026-09-16). [UNVERIFIED: whether `dart pub publish --dry-run` additionally reports that the local pubspec version already exists on pub.dev.]

### An undocumented `.json` listing exists and must not be the primary signal

- Claim: `GET https://pub.dev/packages/webmcp_flutter.json` returned `{"name":"webmcp_flutter","versions":["0.1.6","0.1.5","0.1.4","0.1.1","0.1.0"]}` on 2026-09-16. That page is not listed on the official API help. Help text says undocumented pub.dev endpoints may change or disappear without notice. The payload has no `retracted` field.
- Evidence: Live fetch HTTP 200 (consulted 2026-09-16). https://pub.dev/help/api states that only endpoints documented there are officially supported.
- Source: live `GET https://pub.dev/packages/webmcp_flutter.json` (consulted 2026-09-16); https://pub.dev/help/api (consulted 2026-09-16).

### Current release job detects tags only, after the bump, and fails the run

- Claim: `release.yml` computes the next version from the local pubspec, then fails if `v<version>` exists locally or on `origin`. It never asks pub.dev whether that version is published. Publishing happens later, in a different workflow, from the tag push, using a short-lived OIDC token rather than a stored pub.dev credential.
- Evidence: The bump step runs `sh tools/bump_patch_version.sh` and records `steps.bump.outputs.version` (`.github/workflows/release.yml:69-74`). The next step fetches tags and exits non-zero on `git rev-parse --verify --quiet refs/tags/${tag}` or a non-empty `git ls-remote --tags origin refs/tags/${tag}` (`.github/workflows/release.yml:76-88`). Checkout uses `RELEASE_GITHUB_TOKEN` and `fetch-depth: 0` (`.github/workflows/release.yml:51-54`). The helper increments the third numeric component of `pubspec.yaml` and does not talk to git or the network (`tools/bump_patch_version.sh:37-59`). `publish.yml` comments that authentication is OIDC and that no pub.dev credential is stored (`.github/workflows/publish.yml:3-5`, `:16-22`, `:36-44`). The tag filter is `v[0-9]+.[0-9]+.[0-9]+` (`.github/workflows/publish.yml:11-14`).
- Source: `.github/workflows/release.yml:51-88`; `.github/workflows/publish.yml:1-44`; `tools/bump_patch_version.sh:37-59`; `pubspec.yaml:1-3` (name `webmcp_flutter`, version `0.1.5` on 2026-09-16).

### Git tag occupancy is readable without a new secret; tags can be deleted

- Claim: Remote tag occupancy is the non-empty output of `git ls-remote --tags origin refs/tags/v<version>`. Annotated tags also yield a peeled `refs/tags/v<version>^{}` line, which is still non-empty occupancy. GitHub documents deleting a remote branch or tag with `git push REMOTE-NAME :BRANCH-NAME`. This repository's release workflow does not delete or force-push tags, and this research does not recommend deleting them.
- Evidence: On 2026-09-16, `git ls-remote --tags origin refs/tags/v*` showed `v0.1.2` through `v0.1.6` each with a tag object and a peeled annotated-tag line; `v0.1.0`, `v0.1.1`, and `v0.1.7` were empty. `git ls-remote` is documented as displaying references available in a remote repository, optionally filtered by patterns, including `--tags`. GitHub's `git push` page has the heading "Deleting a remote branch or tag" and the colon-ref syntax. Work item 0009 required that neither push step force-push or delete a ref (AC-014). `release.yml:100-104` pushes `refs/tags/${tag}` with no delete and no `--force`.
- Source: live `git ls-remote --tags origin` in this clone (consulted 2026-09-16); https://git-scm.com/docs/git-ls-remote (consulted 2026-09-16); https://docs.github.com/en/get-started/using-git/pushing-commits-to-a-remote-repository (consulted 2026-09-16); `.github/workflows/release.yml:76-88` and `:100-104`; `wiki/work/0009-pubdev-publish-workflow/02-criteria.md:25` (AC-014).

### Pub.dev version numbers cannot be reused; retraction is not a free slot

- Claim: A published version remains in the version listing after retraction. Retraction is not deletion. Retracted versions still answer HTTP 200 on the per-version URL and still carry `"retracted": true` on the list endpoint. Pub.dev policy says a published package typically cannot be unpublished or deleted, and that this applies to all versions. Dart's publishing guide says a published package lasts forever. This repository already records that 0.1.0 and 0.1.1 can never be reused and that it builds no retraction path.
- Evidence: Spec field `versions[].retracted` is optional and false if omitted (repository-spec-v2.md:242-245). Live `webmcp_flutter` version objects omit `retracted` (treat as false). Live `analyzer` 5.3.0, 5.7.0, and 14.2.0 have `"retracted": true` on the list endpoint; `GET https://pub.dev/api/packages/analyzer/versions/5.3.0` was HTTP 200 with `"retracted": true`. Dart publishing: "Retraction isn't deletion. A retracted package version appears in the version listing of the package on pub.dev". Policy: "once a package has been published it typically cannot be unpublished or deleted". `wiki/product/release-pipeline.md:50-55`.
- Source: https://raw.githubusercontent.com/dart-lang/pub/master/doc/repository-spec-v2.md lines 233-246 (consulted 2026-09-16); https://dart.dev/tools/pub/publishing (consulted 2026-09-16); https://pub.dev/policy (consulted 2026-09-16); live analyzer fetches (consulted 2026-09-16); `wiki/product/release-pipeline.md:50-55`.

### The two signals already disagree in this repository

- Claim: Tag-absent/pub-present and tag-present/pub-absent both exist today. Pub.dev occupancy cannot be inferred from tags, and tag occupancy cannot be inferred from pub.dev.
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

  Tag-absent/pub-present: tagging `v0.1.0` or `v0.1.1` would start `publish.yml`, which would attempt to upload a version number that pub.dev already holds. Tag-present/pub-absent: the current tag guard would reject another bump to 0.1.2 or 0.1.3, while those numbers are still missing from the hosted list. Deleting those tags is not a recommended repair.
- Source: live `GET https://pub.dev/api/packages/webmcp_flutter` and `.../versions/0.1.2`, `.../versions/0.1.3` (consulted 2026-09-16); live `git ls-remote --tags origin` (consulted 2026-09-16); `.github/workflows/publish.yml:11-14` and `:43-44`; `.github/workflows/release.yml:76-88`.

### Helper unit tests must stay offline, so any pub.dev query lives outside the helper

- Claim: `tools/test_bump_patch_version.sh` must pass with no network. The helper is specified to perform no git operation and touch no network. If the release job queries pub.dev, that query belongs in the workflow (or in a script that the helper tests do not invoke). A pure predicate that accepts a version list as input can still be tested offline with fixtures.
- Evidence: Frozen AC-006 requires `tools/test_bump_patch_version.sh` to exit zero with no network access and to reference no host name, URL, or network command (`wiki/work/0009-pubdev-publish-workflow/02-criteria.md:17`). The 0009 plan states the helper performs no git operation and touches no network (`wiki/work/0009-pubdev-publish-workflow/01-plan.md:17`). `tools/check.sh:70` runs that test script as suite stage 7. The helper itself only reads `pubspec.yaml` and `CHANGELOG.md` (`tools/bump_patch_version.sh:22-44`).
- Source: `wiki/work/0009-pubdev-publish-workflow/02-criteria.md:17`; `wiki/work/0009-pubdev-publish-workflow/01-plan.md:17`; `tools/bump_patch_version.sh:22-44`; `tools/test_bump_patch_version.sh:1-13`; `tools/check.sh:70`.

### No new secret is required for occupancy

- Claim: The public packages API is readable without a pub.dev token. Tag occupancy reuses the git remote already authenticated by `RELEASE_GITHUB_TOKEN`. `publish.yml` already rejects introducing a long-lived pub.dev credential.
- Evidence: Live packages API succeeded without credentials (consulted 2026-09-16). Official API help requires endpoints to be public and read-only. `release.yml:40-54` already requires `RELEASE_GITHUB_TOKEN` for checkout and later git writes. `publish.yml:3-5` and AC-023 allow only that GitHub secret as credential material.
- Source: https://pub.dev/help/api (consulted 2026-09-16); `.github/workflows/release.yml:40-54`; `.github/workflows/publish.yml:3-5`; `wiki/work/0009-pubdev-publish-workflow/02-criteria.md:39` (AC-023).

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Official hosted list `GET https://pub.dev/api/packages/webmcp_flutter`, field `versions[].version`, plus existing `git ls-remote --tags origin refs/tags/v<version>` | One unauthenticated HTTP GET in the release job (not in the helper). Treat the candidate as occupied when it is in `versions[]` or when the tag exists. Read `versions[].retracted` only as status, never as a free slot. | One public HTTP call; no new secret; helper tests unchanged if the fetch stays outside `tools/bump_patch_version.sh`. | **Chosen.** It is the documented listing API, it includes retracted versions, and it does not pretend git and pub.dev are the same set. |
| Git tags only (current `release.yml` guard) | Fail when `v<version>` exists locally or on origin. | Already implemented. | Rejected as an occupancy oracle. It misses pub-present/tag-absent (`0.1.0`, `0.1.1`) and treats tag-present/pub-absent (`0.1.2`, `0.1.3`) as a hard failure of the whole job rather than as a distinct git signal. |
| Deprecated per-version `GET .../versions/<candidate>` | HTTP 200 means occupied, 404 means absent. | One request per candidate; deprecated since Dart 2.8. | Rejected as the primary signal. It works today for a yes/no probe, including retracted `analyzer` 5.3.0, but the spec tells clients to use the list endpoint, and a skip-over-several-candidates design would multiply round trips. |
| Undocumented `GET https://pub.dev/packages/webmcp_flutter.json` | Compare the candidate to the `versions` string array. | Smaller payload; no `retracted` field; not on the official API help page. | Rejected. Help text says undocumented endpoints may change or be removed without notice. |
| `dart pub publish --dry-run` or a real publish failure | Rely on the publish command to notice a collision. | Runs after the tag exists (`publish.yml:41-44`); needs the package tree; `login`/`token` are credential commands and are not required for listing. | Rejected. There is no listing subcommand, dry-run is documented as validation not upload, and learning occupancy in the publish job is too late for the bump-and-tag job. |

## Constraints discovered

- No stored pub.dev credential. Listing is a public GET. Publishing already uses GitHub OIDC in `publish.yml`.
- Tags can be deleted (`git push origin :refs/tags/vX.Y.Z` as documented by GitHub). Pub.dev versions cannot be reused; retraction leaves the number occupied. This research does not recommend deleting tags.
- A candidate is unsafe for a new bump-and-tag when either signal is occupied. Pub.dev wins the version-number question when they disagree. Git wins the tag-name question when they disagree. They are not substitutes.
- `latest.version` is not occupancy. `webmcp_flutter` latest is `0.1.6` while `0.1.0`, `0.1.1`, `0.1.4`, and `0.1.5` are also published.
- Response `Cache-Control: public, max-age=120` on the live packages API. A version published in the previous two minutes may be absent from a cached read.
- Helper tests stay offline (AC-006). The pub.dev query, if any, lives outside `tools/bump_patch_version.sh` / `tools/test_bump_patch_version.sh`.
- The current tag guard runs after the helper has already rewritten `pubspec.yaml` and `CHANGELOG.md` on the runner (`.github/workflows/release.yml:69-88`). Occupancy that should skip a candidate needs to be known before a commit is created; those local writes are discarded if the job exits before the push.
- This finding does not choose a skip-loop versus a skip-list control structure for walking past several occupied patch numbers.

## Unresolved

- [UNRESOLVED: whether `dart pub publish --dry-run` reports that the local pubspec version already exists on pub.dev.]
- [UNRESOLVED: whether a rare pub.dev unpublish, granted under policy exceptions, frees that exact version number for a later upload.]
- [UNRESOLVED: how a two-minute CDN cache on `GET /api/packages/webmcp_flutter` should be treated if a publish from `publish.yml` races the next `release.yml` run.]
- [UNRESOLVED: how the release job should recover a tag-present/pub-absent version such as `0.1.2` or `0.1.3` without deleting the tag. This research records the disagreement; it does not choose a recovery or skip strategy.]
- [UNRESOLVED: whether GitHub-hosted `ubuntu-latest` remaining without `curl` would force the already-present Python 3.12 step to perform the GET. Both are available on the current `release.yml` job as written, but the image inventory was not re-fetched.]

## Sources

- https://pub.dev/help/api — consulted 2026-09-16
- https://raw.githubusercontent.com/dart-lang/pub/master/doc/repository-spec-v2.md — consulted 2026-09-16
- https://dart.dev/tools/pub/publishing — consulted 2026-09-16
- https://dart.dev/tools/pub/cmd/pub-lish — consulted 2026-09-16
- https://pub.dev/policy — consulted 2026-09-16
- live `GET https://pub.dev/api/packages/webmcp_flutter` — consulted 2026-09-16
- live `GET https://pub.dev/api/packages/webmcp_flutter/versions/0.1.6`, `.../0.1.2`, `.../0.1.3` — consulted 2026-09-16
- live `GET https://pub.dev/packages/webmcp_flutter.json` — consulted 2026-09-16
- live `GET https://pub.dev/api/packages/analyzer` and `.../versions/5.3.0` — consulted 2026-09-16
- https://git-scm.com/docs/git-ls-remote — consulted 2026-09-16
- https://docs.github.com/en/get-started/using-git/pushing-commits-to-a-remote-repository — consulted 2026-09-16
- Dart SDK 3.13.0 `dart pub --help`, `dart pub publish --help`, `dart pub bump --help`, `dart pub outdated --help` — consulted 2026-09-16
- `.github/workflows/release.yml` — consulted 2026-09-16
- `.github/workflows/publish.yml` — consulted 2026-09-16
- `wiki/product/release-pipeline.md` — consulted 2026-09-16
- `pubspec.yaml` — consulted 2026-09-16
- `tools/bump_patch_version.sh` — consulted 2026-09-16
- `tools/test_bump_patch_version.sh` — consulted 2026-09-16
- `wiki/work/0009-pubdev-publish-workflow/02-criteria.md` — consulted 2026-09-16
- `wiki/work/0009-pubdev-publish-workflow/01-plan.md` — consulted 2026-09-16
- live `git ls-remote --tags origin` in this repository — consulted 2026-09-16
