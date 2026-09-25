# Impl review — round 01

- Work item: 0017-promote-unreleased-on-deploy
- Reviewed artifact: `tools/bump_patch_version.sh`, `tools/test_bump_patch_version.sh`, and new `tools/fixtures/bump-patch-version/unreleased-*` directories. The working tree had no uncommitted changes on those paths. The implementation is in commit `61cb94a56c0907773e535d329c2a4686ad8463c7` versus work-item base `bc1d786` (the revision recorded by the plan review while the work-item files were still untracked).
- Reviewer: impl-validator
- Date: 2026-09-25

## Verdict

**FAIL**

AC-001 through AC-015 and AC-017 through AC-019 are met with independent re-runs and failing negatives. AC-016 is unmet: the live `## Unreleased` list items in `CHANGELOG.md` are not byte-identical to the work-item base.

## Verification performed

Diff under review, computed by this review, not taken from the implementer:

```
$ git status --short -- tools/bump_patch_version.sh tools/test_bump_patch_version.sh tools/fixtures/bump-patch-version/
(no output)

$ git diff --stat bc1d786..HEAD -- tools/bump_patch_version.sh tools/test_bump_patch_version.sh tools/fixtures/bump-patch-version/
 tools/bump_patch_version.sh                        |  97 ++++-
 .../unreleased-duplicate-heading/CHANGELOG.md      |  13 +
 .../unreleased-duplicate-heading/pubspec.yaml      |   6 +
 .../unreleased-heading-only/CHANGELOG.md           |   7 +
 .../unreleased-heading-only/pubspec.yaml           |   6 +
 .../unreleased-lookalike-bracketed/CHANGELOG.md    |   9 +
 .../unreleased-lookalike-bracketed/pubspec.yaml    |   6 +
 .../unreleased-lookalike-dated/CHANGELOG.md        |   9 +
 .../unreleased-lookalike-dated/pubspec.yaml        |   6 +
 .../unreleased-lookalike-lowercase/CHANGELOG.md    |   9 +
 .../unreleased-lookalike-lowercase/pubspec.yaml    |   6 +
 .../unreleased-mid-file-wrapped/CHANGELOG.md       |  16 +
 .../unreleased-mid-file-wrapped/pubspec.yaml       |   6 +
 .../unreleased-occupied-populated/CHANGELOG.md     |  10 +
 .../unreleased-occupied-populated/pubspec.yaml     |   6 +
 .../unreleased-orphan-only/CHANGELOG.md            |   9 +
 .../unreleased-orphan-only/pubspec.yaml            |   6 +
 .../unreleased-subsection-only/CHANGELOG.md        |   9 +
 .../unreleased-subsection-only/pubspec.yaml        |   6 +
 tools/test_bump_patch_version.sh                   | 477 +++++++++++++++++++++
 20 files changed, 703 insertions(+), 16 deletions(-)
```

Full helper suite, re-run by this review:

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
PASS: unreleased-missing
PASS: unreleased-missing-negative
PASS: unreleased-heading-only
PASS: unreleased-heading-only-negative
PASS: unreleased-subsection-only
PASS: unreleased-subsection-only-negative
PASS: unreleased-mid-file-wrapped
PASS: unreleased-second-run-empty
PASS: unreleased-numbered-scratch-diff
PASS: unreleased-wrapped-no-invented-wrap
PASS: unreleased-duplicate-heading
PASS: unreleased-checksum-scratch
PASS: unreleased-duplicate-negative-single
PASS: unreleased-heading-disagreement-untouched
PASS: unreleased-line-number-fail-on-wrapped
PASS: unreleased-lookalike-dated
PASS: unreleased-lookalike-bracketed
PASS: unreleased-lookalike-lowercase
PASS: unreleased-lookalike-negative-exact
PASS: unreleased-mid-file-negative-under-numbered
PASS: unreleased-occupied-populated
PASS: unreleased-occupied-populated-negative-unset
PASS: unreleased-orphan-only
PASS: unreleased-orphan-negative-as-wrap
All tests passed
BUMP_EXIT=0
```

Independent helper runs against temporary fixture copies, plus old-helper (`git show bc1d786:tools/bump_patch_version.sh`) runs that prove each promotion negative fails when the body is still the automated sentence. `RELEASE_DATE=2026-01-02`. `OCCUPIED_VERSIONS` unset unless named.

### AC-001

```
######## AC-001 positive: no Unreleased ########
exit=0 stdout='0.1.2' body='- Automated patch release from main.' unreleased=0
grep exact Unreleased: no match
######## AC-001 negative: add Unreleased + bullet ########
stdout='0.1.2' body='- Unique promoted bullet.'
AC-001-NEG: promotion happened (as required)
######## AC-001 negative-broken: old helper would keep automated ########
OLD helper stdout='0.1.2' body='- Automated patch release from main.'
AC-001-NEG-BROKEN: old helper writes automated (negative would fail) GOOD
```

### AC-002

```
######## AC-002 heading-only ########
stdout='0.1.2' body='- Automated patch release from main.' unreleased=1
######## AC-002 negative: insert hyphen-space ########
body='- Inserted heading-only bullet.'
######## AC-002 negative-broken: old helper ########
OLD body='- Automated patch release from main.' (automated means AC-002 negative would fail)
```

### AC-003

```
######## AC-003 subsection-only ########
stdout='0.1.2' body='- Automated patch release from main.' unreleased=1
span_has_added=yes
######## AC-003 negative: hyphen-space under ### ########
body='- Subsection bullet.'
automated absent as required
######## AC-003 negative-broken: old helper ########
OLD body='- Automated patch release from main.'
```

### AC-004 / AC-005 / AC-007 / AC-013

```
######## AC-004 wrapped mid-file ########
body_match=yes
body=[
- First promoted note that wraps
  onto a continuation line.
- Second promoted note that also wraps
  onto another continuation line.
]
automated absent as required
######## AC-005 leftover Unreleased empty ########
unreleased_count=1
span=[

]
span has no start lines
wrap1 absent from span
wrap2 absent from span
######## AC-005 negative: second run ########
second_stdout='0.1.3' second_body='- Automated patch release from main.'
######## AC-004 negative: single-line items no invented wrap ########
single_line_match=yes
no whitespace-prefixed invented line
######## AC-004/005 negative-broken: old helper on wrapped ########
OLD wrapped body='- Automated patch release from main.'
unreleased_count_old=1
OLD span still has start? yes
######## AC-007 numbered sections byte-identical ########
sec_0.1.1_identical=yes
sec_0.1.0_identical=yes
######## AC-007 negative: scratch change ########
scratch_differs=yes
after_still_equals_before=yes
######## AC-013 mid-file placement ########
first_two_hash='## 0.1.2 - 2026-01-02'
promoted_from_midfile=yes
numbered_identical=yes
######## AC-013 negative: remove Unreleased heading, leave bullets under numbered ########
body='- Automated patch release from main.'
numbered_keeps_first=yes
numbered_keeps_wrap=yes
```

### AC-006 / AC-008 / AC-009

```
######## AC-008 stdout missing + populated ########
missing_stdout='0.1.2' lines=1
populated_stdout='0.1.2' lines=1
######## AC-006 / AC-008 / AC-009 two-heading reject ########
status=1 stdout='' stderr='Error: More than one Unreleased heading was found.'
files_unchanged=yes
checksum_same=yes
######## AC-009 negative: one-byte edit ########
scratch_checksum_differs=yes
######## AC-006 negative: one heading + bullet writes both ########
status=0 pubspec_changed=yes changelog_changed=yes stdout='0.1.2'
######## AC-009 heading-disagreement untouched ########
status=1 unchanged=yes checksum_same=yes
```

### AC-010

```
######## AC-010 valid-patch and valid-leading-blank line checks ########
valid-patch line3='## 0.1.2 - 2026-01-02'
valid-patch line5='- Automated patch release from main.'
leading-blank line4='## 2.4.10 - 2026-01-02'
leading-blank line6='- Automated patch release from main.'
######## AC-010 negative: wrapped fails line-5 automated check ########
wrapped line5='- First promoted note that wraps'
line-5 automated check WOULD FAIL on wrapped (as required)
```

The suite also printed `PASS: valid-patch` and `PASS: valid-leading-blank`.

### AC-011

```
$ git diff bc1d786 -- wiki/work/0009-pubdev-publish-workflow/02-criteria.md
(empty)

######## AC-011 negative: append blank to scratch copy ########
AC-011-NEG: scratch vs tree is non-empty as required
```

### AC-012

```
######## AC-012 lookalikes ########
unreleased-lookalike-dated stdout='0.1.2' body='- Automated patch release from main.' heading_remains=yes note_remains=yes
unreleased-lookalike-bracketed stdout='0.1.2' body='- Automated patch release from main.' heading_remains=yes note_remains=yes
unreleased-lookalike-lowercase stdout='0.1.2' body='- Automated patch release from main.' heading_remains=yes note_remains=yes
######## AC-012 negative: dated lookalike becomes exact ########
exact_body='- Lookalike dated note.'
note absent from Unreleased span as required
######## AC-012 negative-broken: old helper on exact replacement ########
OLD exact-replacement body='- Automated patch release from main.'
```

### AC-014

```
######## AC-014 occupied plus populated ########
stdout='0.1.3' body_match=yes
has_0.1.2_heading=no
unreleased=1
span_has_start=no
######## AC-014 negative: unset occupied ########
stdout='0.1.2' body_under_0.1.2=yes
has_0.1.3_heading=no
```

### AC-015

```
$ git diff bc1d786 -- .github/workflows/release.yml
(empty)

$ grep -n "chore(release): v" .github/workflows/release.yml
38:    if: "${{ !startsWith(github.event.head_commit.message, 'chore(release): v') }}"
138:          git commit -m 'chore(release): v${{ steps.bump.outputs.version }}'

######## AC-015 negative: scratch blank line ########
AC-015-NEG-blank: scratch vs tree is non-empty as required
######## AC-015 negative: scratch changes commit prefix ########
AC-015-NEG-prefix: grep for chore(release): v found no matches as required
commit-step-only change grep:
38:    if: "${{ !startsWith(github.event.head_commit.message, 'chore(release): v') }}"
138:          git commit -m 'chore(release): x${{ steps.bump.outputs.version }}'
```

### AC-016

```
$ git diff bc1d786 -- pubspec.yaml
(description and platforms changed; version line unchanged)

$ grep '^version:' pubspec.yaml
version: 0.1.8
$ git show bc1d786:pubspec.yaml | grep '^version:'
version: 0.1.8

--- numbered sections ---
## 0.1.0 - 2026-09-10: identical=True
## 0.1.1 - 2026-09-10: identical=True
## 0.1.2 - 2026-09-11: identical=True
## 0.1.3 - 2026-09-11: identical=True
## 0.1.4 - 2026-09-11: identical=True
## 0.1.5 - 2026-09-11: identical=True
## 0.1.6 - 2026-09-16: identical=True
## 0.1.7 - 2026-09-16: identical=True
## 0.1.8 - 2026-09-17: identical=True
ALL_NUMBERED_IDENTICAL=True
UNRELEASED_IDENTICAL=False
BASE_UNRELEASED_BYTES 352
HEAD_UNRELEASED_BYTES 1211

$ git tag --list 'v[0-9]*.[0-9]*.[0-9]*' --merged bc1d786
v0.1.2
v0.1.3
v0.1.4
v0.1.5
v0.1.6
v0.1.7
v0.1.8
$ git tag --list 'v[0-9]*.[0-9]*.[0-9]*' --merged HEAD
v0.1.2
v0.1.3
v0.1.4
v0.1.5
v0.1.6
v0.1.7
v0.1.8
$ git tag --list 'v[0-9]*.[0-9]*.[0-9]*'
v0.1.2
v0.1.3
v0.1.4
v0.1.5
v0.1.6
v0.1.7
v0.1.8
v0.1.9

######## AC-016 negative: scratch clone ########
deleted_unreleased_bullet True
scratch CHANGELOG unreleased vs original:
changelog differs as required
scratch pubspec version:
version: 0.1.9
HEAD pubspec version:
version: 0.1.8
scratch new tag present:
v9.9.9
```

`git diff bc1d786 -- CHANGELOG.md` adds seven hyphen-space items with wrap lines under the live `## Unreleased` heading. Numbered sections are unchanged. The HEAD-merged three-component tag list matches the base. Repo-wide `git tag -l` also lists `v0.1.9`, which points at `d3a3581` (`chore(release): v0.1.9` on `origin/main`) and is not an ancestor of HEAD.

### AC-017

Named pre-change cases from `bc1d786:tools/test_bump_patch_version.sh` all printed PASS in the suite re-run: `valid-patch`, `valid-leading-blank`, `valid-minor-untouched`, occupied-skip successes, and the current reject cases.

Negative: a copy of the test tree with the first `valid-patch` stdout expectation changed from `0.1.2` to `9.9.9`:

```
AC017_NEG_EXIT=1
FAIL: valid-patch - wrong output: '0.1.2'
PASS: valid-minor-untouched
...
```

### AC-018

```
$ grep -E 'https?://|[[:space:]]git[[:space:]]|^git[[:space:]]|[a-zA-Z0-9.-]+\.(com|org|io|dev|net)' tools/bump_patch_version.sh
HELPER_HAS_NET_OR_GIT=no

# test script has no host/URL. The only "git" hit is the defensive grep that forbids a git command.

$ sandbox-exec -p '(deny network*)' sh tools/test_bump_patch_version.sh
SUITE_EXIT=0
...
PASS: unreleased-orphan-negative-as-wrap
All tests passed

$ sandbox-exec -p '(deny network*)' python3 -c 'import socket; socket.getaddrinfo("example.com", 80)'
HOST_RESOLVE=failed err=gaierror: [Errno 8] nodename nor servname provided, or not known
HOST_RESOLVE_EXIT=1
```

A temporary case that only calls local `git rev-parse` still succeeds offline. A temporary case that resolves a host name fails offline, which is the negative that actually breaks when the forbidden behaviour is present.

### AC-019

```
######## AC-019 orphan-only ########
stdout='0.1.2' body='- Automated patch release from main.'
orphan_remains=yes
######## AC-019 negative: orphan immediately after start ########
body_match=yes
body=[
- Start item.
  orphan continuation without a start item
]
orphan_left_in_span=no
######## AC-019 negative-broken: old helper on wrap-after-start ########
OLD wrap-after-start body='- Automated patch release from main.'
```

Test-gaming hunt: no skipped or pending cases, no mocks, no widened assertions. New cases assert the criterion body, leftover heading, checksum, and line-number behaviour. Leftovers: no `TODO`, debug prints, or commented-out helper paths in the scoped diff.

## Per-criterion results

| Criterion | Result | Evidence (file:line) | Negative case exercised |
|---|---|---|---|
| AC-001 | pass | `tools/bump_patch_version.sh:194-196`, `tools/test_bump_patch_version.sh:538-577` | yes |
| AC-002 | pass | `tools/bump_patch_version.sh:186-196`, `tools/fixtures/bump-patch-version/unreleased-heading-only/CHANGELOG.md:3`, `tools/test_bump_patch_version.sh:580-611` | yes |
| AC-003 | pass | `tools/bump_patch_version.sh:158-162`, `tools/fixtures/bump-patch-version/unreleased-subsection-only/CHANGELOG.md:5`, `tools/test_bump_patch_version.sh:614-647` | yes |
| AC-004 | pass | `tools/bump_patch_version.sh:164-174`, `tools/fixtures/bump-patch-version/unreleased-mid-file-wrapped/CHANGELOG.md:9-12`, `tools/test_bump_patch_version.sh:650-723` | yes |
| AC-005 | pass | `tools/bump_patch_version.sh:199-209`, `tools/test_bump_patch_version.sh:664-690` | yes |
| AC-006 | pass | `tools/bump_patch_version.sh:114-117`, `tools/fixtures/bump-patch-version/unreleased-duplicate-heading/CHANGELOG.md:3`, `tools/test_bump_patch_version.sh:726-779` | yes |
| AC-007 | pass | `tools/bump_patch_version.sh:199-209`, `tools/test_bump_patch_version.sh:658-700` | yes |
| AC-008 | pass | `tools/bump_patch_version.sh:229`, `tools/test_bump_patch_version.sh:545-547` and `:735-737` | yes |
| AC-009 | pass | `tools/bump_patch_version.sh:114-117`, `tools/test_bump_patch_version.sh:726-798` | yes |
| AC-010 | pass | `tools/test_bump_patch_version.sh:49`, `:109`, `:801-811` | yes |
| AC-011 | pass | `wiki/work/0009-pubdev-publish-workflow/02-criteria.md:1` (empty `git diff bc1d786`) | yes |
| AC-012 | pass | `tools/bump_patch_version.sh:150-154`, `tools/fixtures/bump-patch-version/unreleased-lookalike-dated/CHANGELOG.md:3`, `unreleased-lookalike-bracketed/CHANGELOG.md:3`, `unreleased-lookalike-lowercase/CHANGELOG.md:3`, `tools/test_bump_patch_version.sh:814-854` | yes |
| AC-013 | pass | `tools/bump_patch_version.sh:178-182`, `tools/fixtures/bump-patch-version/unreleased-mid-file-wrapped/CHANGELOG.md:7`, `tools/test_bump_patch_version.sh:665-876` | yes |
| AC-014 | pass | `tools/bump_patch_version.sh:59-90`, `tools/fixtures/bump-patch-version/unreleased-occupied-populated/pubspec.yaml:2`, `tools/test_bump_patch_version.sh:879-913` | yes |
| AC-015 | pass | `.github/workflows/release.yml:38`, `:138` (empty `git diff bc1d786`) | yes |
| AC-016 | fail | `CHANGELOG.md:39-52` versus `bc1d786:CHANGELOG.md` Unreleased span | yes |
| AC-017 | pass | `tools/test_bump_patch_version.sh:992-995` and occupied cases `:336-476` | yes |
| AC-018 | pass | `tools/bump_patch_version.sh:1-229` (no host, URL, or git), `tools/test_bump_patch_version.sh:479-484` | yes |
| AC-019 | pass | `tools/bump_patch_version.sh:170-174`, `tools/fixtures/bump-patch-version/unreleased-orphan-only/CHANGELOG.md:5`, `tools/test_bump_patch_version.sh:916-956` | yes |

## Findings

### F-001 — Live Unreleased list items are not byte-identical to the work-item base

- Severity: BLOCKER
- Location: `CHANGELOG.md:39`
- Criterion affected: AC-016
- Observation: AC-016 requires the live `## Unreleased` heading and its current list items to be byte-identical to the work-item base. Numbered sections and the pubspec `version:` line do match `bc1d786`. The Unreleased span does not: HEAD is 1211 bytes and base is 352 bytes. The extra lines begin at `CHANGELOG.md:39` (`- Forward the browser execution signal...`) and continue through `:52`. Those lines were added in the same commit that landed the helper (`61cb94a`). The HEAD-merged three-component tag list still matches the base. A scratch clone that deleted one Unreleased bullet, bumped the pubspec patch, and created `v9.9.9` made each of those checks report a difference.
- Why it matters: the frozen restraint is byte-identity of the live Unreleased items, not merely “do not empty the block” or “do not rewrite numbered sections”. Until that span matches the base, AC-016 is unmet even though the helper, tests, and new fixtures satisfy the other criteria.

## Recurrence check

- Previous round: none — first round
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | implement |
