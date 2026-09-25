# Impl review — round 01

- Work item: 0015-skip-occupied-release-versions
- Reviewed artifact: product paths `.github/workflows/release.yml`,
  `tools/bump_patch_version.sh`, `tools/check.sh`,
  `tools/test_bump_patch_version.sh`, `tools/occupied_pubdev_versions.py`,
  `tools/test_occupied_pubdev_versions.sh`, and the new bump-patch-version and
  occupied-pubdev-versions fixtures. Same tree as commit
  `615636afe758fb86dbf828cf626d6d3641517207`. Work-item wiki folder was not
  treated as product diff.
- Reviewer: impl-validator
- Date: 2026-09-16

## Verdict

**PASS**

Every numbered criterion AC-001 through AC-024 is met with an independent
re-run, a file-and-line citation, and an exercised negative case. No test
gaming, uncovered required path, or leftover debug output blocks the change.

## Verification performed

Helper and parser suites, re-run by this review:

```
$ sh tools/test_bump_patch_version.sh
Running bump_patch_version.sh tests...
PASS: valid-patch
PASS: valid-minor-untouched
PASS: valid-leading-blank
PASS: reject-prerelease
PASS: reject-two-components
PASS: reject-no-changelog-title
PASS: reject-missing-changelog
PASS: reject-missing-pubspec
PASS: reject-changelog-ahead
PASS: real-repo-test
PASS: occupied-empty-plus-one
PASS: occupied-skip-next
PASS: occupied-skip-next-negative-unset
PASS: occupied-consecutive
PASS: occupied-consecutive-negative-only-next
PASS: occupied-later-not-next
PASS: occupied-later-and-next
PASS: occupied-cap-exceeded
PASS: occupied-cap-boundary
PASS: occupied-malformed-two-component
PASS: occupied-malformed-prerelease
PASS: occupied-malformed-non-numeric
PASS: occupied-malformed-negative-well-formed
PASS: occupied-chosen-heading
PASS: occupied-chosen-heading-negative
PASS: occupied-intermediate-heading
PASS: occupied-intermediate-heading-negative
PASS: occupied-parent-env-unset
PASS: occupied-no-network-no-git
All tests passed
BUMP_EXIT=0

$ sh tools/test_occupied_pubdev_versions.sh
Running occupied_pubdev_versions.py tests...
PASS: valid-list
PASS: valid-list-stdin
PASS: retracted
PASS: retracted-removed
PASS: empty-versions
PASS: missing-versions
PASS: invalid-json
PASS: versions-object
PASS: latest-not-complete
PASS: latest-only
PASS: mixed-prerelease
PASS: no-network-no-git
All tests passed
PARSER_EXIT=0
```

Independent helper and parser runs against temporary fixture copies (not the
suite's own PASS lines):

```
AC-001 unset:     rc=0 stdout='0.1.2\n' version=0.1.2 headings include '## 0.1.2 - 2026-01-02'
AC-001 empty:     rc=0 stdout='0.1.2\n' version=0.1.2
AC-001 negative:  rc=0 stdout='0.1.3\n' (does not print 0.1.2)
AC-002 skip:      rc=0 stdout='0.1.3\n' no '## 0.1.2' heading
AC-002 negative:  unset → stdout='0.1.2\n'
AC-003 consec:    rc=0 stdout='0.1.4\n' headings=['## 0.1.4 - 2026-01-02', '## 0.1.1 - 2026-08-01', '## 0.1.0 - 2026-07-01']
AC-003 negative:  occupy only 0.1.2 → stdout='0.1.3\n'
AC-004 later:     rc=0 stdout='0.1.2\n' version=0.1.2
AC-004 negative:  occupy 0.1.2 and 0.1.3 → stdout='0.1.4\n'
AC-005 cap 51:    rc=1 stdout='' stderr='Error: Occupied-version skip cap of 50 exceeded.\n' unchanged=True has50=True
AC-005 negative:  50 occupied → rc=0 stdout='0.1.52\n'
AC-006 malformed: token 0.1 / 0.1.2-beta / abc → rc=1 unchanged=True
AC-006 negative:  occupy 0.1.9 → rc=0 stdout='0.1.2\n'
AC-007 heading:   rc=1 unchanged=True stderr='Error: Version 0.1.3 already exists in CHANGELOG.md'
AC-007 negative:  no 0.1.3 heading → rc=0 stdout='0.1.3\n'
AC-019 inter:     rc=0 stdout='0.1.3\n' headings keep '## 0.1.2 - 2026-01-01'
AC-019 negative:  occupy empty on same files → rc=1 unchanged, heading 0.1.2 rejects
AC-024 checksums: malformed/cap/heading all unchanged=True; one-byte spoil differs=True
parser file:      0 0.1.0 0.1.1 0.1.4 0.1.5 0.1.6
parser stdin:     0 0.1.0 0.1.1 0.1.4 0.1.5 0.1.6
mixed:            0 0.1.0 0.1.6 has-prerelease False
missing:          rc=1 stdout=''
retracted:        0 0.1.5 0.1.6
retracted-removed:0 0.1.5 has 0.1.6 False
invalid/object:   rc=1 stdout=''
empty-versions:   rc=0 stdout='\n'
latest-only:      0 0.1.6
```

AC-008 unset effectiveness, existing-case names, and parent-env contrast:

```
after-unset stdout='0.1.2'
without-unset stdout='0.1.3'
unset sites: tools/test_bump_patch_version.sh:16,361,470,491
existing cases in the runner still printed PASS, including valid-patch,
valid-minor-untouched, valid-leading-blank, reject-changelog-ahead, real-repo-test
```

Full check suite, re-run by this review (`bash tools/check.sh`):

```
Stage 1 passed: wiki lint
Stage 2 passed: dependencies
Stage 3 passed: format
Stage 4 passed: analysis
Stage 5 passed: tests
Stage 6 passed: build
Stage 7 passed: version bump test
Stage 8 passed: occupied pub.dev versions test
CHECK_EXIT=0
```

AC-013 negative, same `stage_failed` helper and numbering, planted parser
failure after a real stage 7:

```
Stage 7 passed: version bump test
FAIL: planted parser failure
Stage 8 failed: occupied pub.dev versions test
ac013-neg-exit=1
```

Workflow parse of `.github/workflows/release.yml` (step indices from `- name:` /
`- uses:`):

```
[0] Require the release token
[1] actions/checkout@v4
[2] actions/setup-python@v5
[3] Set up Flutter
[4] Run package check suite
[5] Load occupied pub.dev versions
[6] Bump patch version
[7] Reject an existing tag for this version
[8] Commit the bump
[9] Push the commit
[10] Push the tag
occ after check and before bump: True
tag between bump and commit: True
commit push before tag push: True
OCCUPANCY URL: https://pub.dev/api/packages/webmcp_flutter
OCCUPANCY parser: tools/occupied_pubdev_versions.py
OCCUPANCY export: OCCUPIED_VERSIONS=${occupied} >> GITHUB_ENV
OCCUPANCY git ls-remote / git tag: False
OCCUPANCY status != 200 / if not body / Accept v2: True
OCCUPANCY Authorization / query string / password|credentials: False
BUMP continue-on-error / always(): False
TAG fetch --tags --force, local and remote reject, exit 1: True
WORKFLOW push --force / tag -d / skip-instruction: False
WORKFLOW loop guard chore(release): v + startsWith: True
WORKFLOW git tag -a: True
scratch 404-as-success differs: True
scratch git-tags-into-occupied contains git ls-remote: True
scratch force-push / [skip ci] differ and match those greps: True
planted Authorization matches; planted Accept v2 missing; planted query matches
```

AC-016 local simulation of the committed step body (rev-parse branch):

```
Tag v0.1.99 is free.
positive-local-exit=0
Tag v0.1.99 already exists locally.
negative-local-exit=1
```

Restraint diffs against the work-item parent `cd5d8b8` (chore(release): v0.1.6):

```
git diff cd5d8b8 615636a -- .github/workflows/checks.yml   bytes=0
git diff cd5d8b8 615636a -- .github/workflows/publish.yml  bytes=0
git diff cd5d8b8 615636a -- pubspec.yaml CHANGELOG.md      bytes=0
pubspec.yaml:3 version: 0.1.6
no new ## heading in that diff
repo tags of shape vN.N.N: v0.1.2 v0.1.3 v0.1.4 v0.1.5 v0.1.6 v0.1.7
(v0.1.7 is a pre-existing annotated release tag, not created by this change)
AC-017 negative: spoiled checks.yml copy differs
AC-018 negative: spoiled pubspec version: 0.1.7; spoiled heading ## 0.1.7 present
```

Offline / no-git reads and planted negatives:

```
helper host/url/git: (none)
parser host/url/git: (none)
test scripts mention "git" only in the no-network fail strings
offline-bump-exit=0 / offline-parser-exit=0
planted helper URL detected (expected)
planted parser URL detected (expected)
```

Test-gaming hunt: no mocks, no skipped or pending cases, no widened
"accept any output" assertions. Occupied and parser cases assert the required
version tokens and reject exits. `latest-not-complete` reuses `valid-list.json`
with the same expected line; that line includes older versions, so a
latest-only parser would fail it. No leftover TODO, FIXME, or debug prints in
the product paths.

## Per-criterion results

| Criterion | Result | Evidence (file:line) | Negative case exercised |
|---|---|---|---|
| AC-001 | pass | `tools/bump_patch_version.sh:65`; `tools/test_bump_patch_version.sh:342`; independent unset/empty runs print `0.1.2` | yes — occupy `0.1.2` prints `0.1.3`, not `0.1.2` |
| AC-002 | pass | `tools/bump_patch_version.sh:72`; `tools/test_bump_patch_version.sh:348` | yes — same tree with the variable unset chooses `0.1.2` |
| AC-003 | pass | `tools/test_bump_patch_version.sh:372`; independent headings are only the new `0.1.4` plus the fixture's old sections | yes — occupy only `0.1.2` chooses `0.1.3`, not `0.1.4` |
| AC-004 | pass | `tools/test_bump_patch_version.sh:388`; independent stdout and written version `0.1.2` | yes — also occupying `0.1.2` chooses `0.1.4` |
| AC-005 | pass | `tools/bump_patch_version.sh:83`; `tools/test_bump_patch_version.sh:408` | yes — fifty occupied patches write `0.1.52` |
| AC-006 | pass | `tools/bump_patch_version.sh:66`; `tools/test_bump_patch_version.sh:429` | yes — well-formed `0.1.9` writes plus-one `0.1.2` |
| AC-007 | pass | `tools/bump_patch_version.sh:108`; `tools/fixtures/bump-patch-version/occupied-chosen-heading/CHANGELOG.md:3`; `tools/test_bump_patch_version.sh:442` | yes — same occupy list on `valid-patch` writes `0.1.3` |
| AC-008 | pass | `tools/test_bump_patch_version.sh:16`; `:519`; existing named cases printed PASS | yes — parent `OCCUPIED_VERSIONS=0.1.2` then unset still plus-ones; without unset chooses `0.1.3` |
| AC-009 | pass | `tools/occupied_pubdev_versions.py:13`; `tools/test_occupied_pubdev_versions.sh:61`; `:67`; `:124` | yes — missing `versions` exits non-zero with empty stdout |
| AC-010 | pass | `tools/occupied_pubdev_versions.py:24`; `tools/fixtures/occupied-pubdev-versions/retracted.json:1`; `tools/test_occupied_pubdev_versions.sh:75` | yes — copy with the retracted entry removed prints `0.1.5` only |
| AC-011 | pass | `tools/occupied_pubdev_versions.py:43`; `:17`; `tools/test_occupied_pubdev_versions.sh:102`; `:107` | yes — empty `versions` array exits 0 and prints an empty line |
| AC-012 | pass | `tools/fixtures/occupied-pubdev-versions/valid-list.json:1`; `tools/test_occupied_pubdev_versions.sh:112` | yes — `latest-only.json` prints the single token `0.1.6` |
| AC-013 | pass | `tools/check.sh:70`; `:73`; full suite `Stage 8 passed: occupied pub.dev versions test` | yes — planted parser failure stops at `Stage 8 failed` with exit 1 |
| AC-014 | pass | `.github/workflows/release.yml:72`; `:79`; `:109`; `:110`; step index 5 between check 4 and bump 6 | yes — planted `git ls-remote` into a scratch occupancy body is detected; committed body has none |
| AC-015 | pass | `.github/workflows/release.yml:97`; `:103`; `:109`; bump step `:112` has no `continue-on-error` or `always()` | yes — scratch that treats 404 as success differs from the committed body |
| AC-016 | pass | `.github/workflows/release.yml:119`; `:122`; `:123`; `:127`; step index 7 between bump 6 and commit 8 | yes — matching local tag exits 1; free tag exits 0 |
| AC-017 | pass | `git diff cd5d8b8 615636a -- .github/workflows/checks.yml` is empty | yes — spoiled copy with a trailing blank line diffs non-empty |
| AC-018 | pass | `pubspec.yaml:3` still `0.1.6`; empty diff of `pubspec.yaml` and `CHANGELOG.md` vs `cd5d8b8`; this change adds no `vN.N.N` tag | yes — spoiled pubspec `0.1.7` and heading `## 0.1.7` are detected |
| AC-019 | pass | `tools/bump_patch_version.sh:108`; `tools/fixtures/bump-patch-version/occupied-intermediate-heading/CHANGELOG.md:3`; `tools/test_bump_patch_version.sh:451` | yes — empty occupy list on the same files rejects because `0.1.2` already has a heading |
| AC-020 | pass | empty `publish.yml` diff vs `cd5d8b8`; `.github/workflows/release.yml:38`; `:140`; `:146`; no force-push, ref deletion, or skip instruction | yes — scratch force-push and `[skip ci]` fail those greps; `git fetch --tags --force` is not treated as force-push |
| AC-021 | pass | `tools/bump_patch_version.sh` has no URL or git invocation; `tools/test_bump_patch_version.sh` suite exit 0 | yes — planted `https://example.com` on a helper copy is detected by the same grep |
| AC-022 | pass | `tools/occupied_pubdev_versions.py` has no URL or git invocation; parser suite exit 0 | yes — planted URL on a parser copy is detected |
| AC-023 | pass | `.github/workflows/release.yml:82`; occupancy body has no `Authorization`, no query string, no pub.dev credential vocabulary | yes — planted `Authorization`, `?cache=1`, and `Accept: application/json` match those greps |
| AC-024 | pass | `tools/bump_patch_version.sh:66`; `:83`; `:108` all return before the writes at `:160`; independent SHA-256 comparisons | yes — one extra byte after checksumming reports a difference |

## Findings

None.

## Recurrence check

- Previous round: none — first round
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| (none) | — |
