# Research review — round 01

- Work item: 0015-skip-occupied-release-versions
- Reviewed artifact: `wiki/work/0015-skip-occupied-release-versions/00-research.md` (uncommitted; workspace HEAD `87e3545d3203dd43f829cba562fc07a9b8b8a140`)
- Reviewer: research-validator
- Date: 2026-09-16

## Verdict

**PASS**

Cited local files, live pub.dev responses, origin tags, and the hosted-pub spec match the factual claims; honest `[UNVERIFIED]` / `[UNRESOLVED]` markers are retained; the skip-set disagreement is explicit rather than papered over. One non-blocking gap remains: the chosen occupancy GET has no stated behaviour when the request fails.

## Verification performed

Read the artifact, `wiki/conventions/validation-rubrics.md`, `wiki/templates/validation-report.md`, and the three stream files only as cited sources. Opened every local citation (`tools/bump_patch_version.sh`, `tools/test_bump_patch_version.sh`, both named fixtures, `tools/check.sh`, `.github/workflows/release.yml`, `.github/workflows/publish.yml`, `pubspec.yaml`, `CHANGELOG.md`, `wiki/product/release-pipeline.md`, 0009 plan/criteria/`00-research.md`/`research/version-bump.md`, 0013 `research/release.md`). Ignored author reasoning outside the artifact.

Independently fetched the cited URLs and live endpoints on 2026-09-16. WebFetch/WebSearch were unavailable in this validator context; `curl` and `git ls-remote` were used instead.

Command: `dart --version && dart pub --help && dart pub publish --help`

```text
Dart SDK version: 3.13.0 (stable) (Wed Aug 5 00:28:05 2026 -0700) on "macos_arm64"
Available subcommands:
  add, bump, cache, deps, downgrade, global, get, publish, outdated,
  remove, unpack, upgrade, login, logout, token, workspace
-n, --dry-run            Validate but do not publish the package.
```

`dart pub bump --help` lists only `major` / `minor` / `patch` / `breaking` against the local pubspec. No hosted version-listing subcommand exists.

Command: `git ls-remote --tags origin 'refs/tags/v*'`

```text
…	refs/tags/v0.1.2
…	refs/tags/v0.1.2^{}
…	refs/tags/v0.1.3
…	refs/tags/v0.1.3^{}
…	refs/tags/v0.1.4
…	refs/tags/v0.1.4^{}
…	refs/tags/v0.1.5
…	refs/tags/v0.1.5^{}
…	refs/tags/v0.1.6
…	refs/tags/v0.1.6^{}
```

Exact-ref probes: `v0.1.0`, `v0.1.1`, `v0.1.7` empty; `v0.1.2`–`v0.1.6` non-empty.

Command: `curl -sS -D - -H 'Accept: application/vnd.pub.v2+json' https://pub.dev/api/packages/webmcp_flutter`

```text
HTTP/2 200
cache-control: public, max-age=120
access-control-allow-origin: *
keys ['latest', 'name', 'versions']
latest.version 0.1.6
versions ['0.1.0', '0.1.1', '0.1.4', '0.1.5', '0.1.6']
retracted flags all omitted
```

No `Authorization` header was sent. Per-version `.../versions/0.1.6` HTTP 200 `"version": "0.1.6"`. `.../versions/0.1.2` and `.../0.1.3` HTTP 404 `{"code":"NotFound",...}`. `GET https://pub.dev/packages/webmcp_flutter.json` HTTP 200 `{"name":"webmcp_flutter","versions":["0.1.6","0.1.5","0.1.4","0.1.1","0.1.0"]}`. Live `analyzer` list: `5.3.0`, `5.7.0`, `14.2.0` have `"retracted": true`; `.../versions/5.3.0` HTTP 200 `"retracted": true`.

`https://raw.githubusercontent.com/dart-lang/pub/master/doc/repository-spec-v2.md` (482 lines): “List all versions of a package” at 217–254, `GET <hosted-url>/api/packages/<package>`, `Accept: application/vnd.pub.v2+json`, `versions[].retracted` optional/false if omitted at 242–245; deprecated per-version inspect at 443–465, “Deprecated as of Dart 2.8”.

`https://pub.dev/help/api`: names Hosted Pub Repository Specification V2 as the implemented API; undocumented endpoints “may change or remove them without notice”. The “data must be public / read-only / cacheable” sentences are the FAQ requirements for *new* official endpoints, not a description of `GET /api/packages/<package>`.

`https://dart.dev/tools/pub/publishing`: “a published package lasts forever”; “Retraction isn't deletion. A retracted package version appears in the version listing”. `https://pub.dev/policy`: “once a package has been published it typically cannot be unpublished or deleted… This applies to all versions”. `https://git-scm.com/docs/git-ls-remote`: displays remote refs; `--tags`; peeled tags shown unless `--refs`. `https://docs.github.com/en/get-started/using-git/pushing-commits-to-a-remote-repository`: heading “Deleting a remote branch or tag”; `git push REMOTE-NAME :BRANCH-NAME`.

Repo-scoped occupancy search of `tools/` and `.github/`: helper changelog grep at `tools/bump_patch_version.sh:77`; `git rev-parse` / `git ls-remote` at `.github/workflows/release.yml:80-86`; `flutter pub publish --dry-run` then `--force` at `.github/workflows/publish.yml:42-44`. No `curl`/`wget`/`git` in `tools/*.sh`. `tools/check.sh:70-71` is stage 7. Fixtures match: `reject-changelog-ahead` is pubspec `0.1.1` plus `## 0.1.2 - 2026-01-01`; `valid-patch` has no `0.1.2` heading. Test case list and `RELEASE_DATE=2026-01-02` match `tools/test_bump_patch_version.sh:12-13` and `:302-314`. Root `pubspec.yaml` version is `0.1.5`. Root `CHANGELOG.md` has headings `0.1.5` through `0.1.0` and no `## 0.1.6`.

0009 `01-plan.md:17` (helper: no git, no network), `:55-59` (non-zero leaves files unwritten; second consecutive run succeeds), `:69` (patch-only arithmetic), `:73` (collision before commit; no delete/force-push), `:88` (same-patch race fails at collision or tag push) match the citations. AC-006 is `02-criteria.md:17`; AC-014 `:25`; AC-016 `:27`; AC-023 `:39`. 0013 `research/release.md:32-35` recovery matrix and `:72` (tags never moved) match. `wiki/product/release-pipeline.md:19-24`, `:26-32`, `:47-48`, `:50-55` match. `version-bump.md:48-55` describes dry-run as validation without upload and `--force` as skipping confirmation.

## Per-criterion results

Not an implementation review. No frozen acceptance criteria were supplied for this research round.

| Research bar | Result | Evidence |
|---|---|---|
| Claims sourced or explicitly unverified | pass | Local line citations verified; live HTTP/git/Dart outputs match; dry-run occupancy, cap value, and publish-rerun remain `[UNVERIFIED]` |
| Alternatives considered | pass | Helper occupied-set, workflow plus-one loop, collision-step-only, human bump, git-only oracle, per-version GET, undocumented `.json`, dry-run (`00-research.md:140-155`) |
| Unresolved matters explicit | pass | Sixteen items at `00-research.md:177-195`, including the skip-set disagreement |
| No fabrication of APIs, paths, or live numbers | pass | Package list, tags, Cache-Control, analyzer retraction, spec line numbers, and Dart 3.13.0 help match independent fetches |

## Findings

### F-001 — Chosen occupancy GET has no failure behaviour

- Severity: IMPORTANT
- Location: `wiki/work/0015-skip-occupied-release-versions/00-research.md:145`
- Criterion affected: none
- Observation: The chosen oracle is one unauthenticated `GET https://pub.dev/api/packages/webmcp_flutter` whose occupancy set is `versions[].version`. Options, constraints, and Unresolved discuss stale CDN cache (`max-age=120`) and curl-versus-Python, but not what the release job does when that GET returns a non-200, times out, or yields a body without `versions`.
- Why it matters: Fail-open would let the helper write a version that is already hosted; fail-closed would still fail a main-branch release. The plan that consumes this research has to pick one, and the artifact does not record the choice as open.

### F-002 — Heading/tag split listed unresolved is visible in the current tree

- Severity: NIT
- Location: `wiki/work/0015-skip-occupied-release-versions/00-research.md:182`
- Criterion affected: none
- Observation: Unresolved asks whether a tag without a matching changelog heading has been observed. Origin has `refs/tags/v0.1.6`; root `CHANGELOG.md` has no `## 0.1.6` heading; `pubspec.yaml` is `0.1.5`. The occupancy table at `:72-81` compares pub.dev to git only and never reads the live changelog.
- Why it matters: The current next computed patch is already the helper-success-then-collision-fail path described at `:136`, plus pub.dev occupancy of `0.1.6`. Treating that split as theoretical understates a fact the cited tag listing already made checkable.

### F-003 — “Public and read-only” cites the new-endpoint FAQ, not the packages API

- Severity: NIT
- Location: `wiki/work/0015-skip-occupied-release-versions/00-research.md:57`
- Criterion affected: none
- Observation: `https://pub.dev/help/api` does name Hosted Pub Repository Specification V2 and does warn that undocumented endpoints may disappear. The sentence that official endpoints “must be public” and “read-only” is the FAQ bar for *adding* a new official API, not a property of `GET /api/packages/webmcp_flutter`. Unauthenticated occupancy is independently supported by the live 200 with no `Authorization` header.
- Why it matters: The no-credential conclusion stands; the help-page characterisation does not.

## Recurrence check

- Previous round: none — first round
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | research |
| F-002 | research |
| F-003 | research |
