# Impl review — round 01

- Work item: 0009-pubdev-publish-workflow
- Reviewed artifact: working tree at base revision a8e46a5, added `.github/workflows/release.yml`, `.github/workflows/publish.yml`, `tools/bump_patch_version.sh`, `tools/test_bump_patch_version.sh`, `tools/fixtures/bump-patch-version/**`, and one added final stage in `tools/check.sh`
- Reviewer: cursor-main (main agent; the impl-validator subagent was not used because the two round-1 validator subagents had to be interrupted after roughly fifty minutes each)
- Date: 2026-09-10

## Verdict

**CONDITIONAL**

Every criterion except AC-007's full-suite form is established with pasted evidence, including negative cases; the check suite cannot reach the new stage 7 locally because stage 4 fails on pre-existing `spikes/` code from work item 0008, so stage 7 was exercised in isolation instead.

## Verification performed

Offline helper suite, ten cases:

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
All tests passed
EXIT=0
```

Workflow structure, parsed with PyYAML and asserted field by field:

```
AC-008 branches: ['main'] | push keys: ['branches'] | triggers: ['push']
AC-009 concurrency: {'group': 'release-main', 'cancel-in-progress': False}
AC-010 if: ${{ !startsWith(github.event.head_commit.message, 'chore(release): v') }}
AC-010 skip-instruction strings in release.yml: none
AC-011 first step: Require the release token | names secret: True
order python:2 flutter:3 check:4 bump:5 tagguard:6 commit:7 push-commit:8 push-tag:9
AC-012 check before all git writes: True
AC-016 guard between bump and commit: True
AC-014 commit push before tag push: True
AC-021 flutter pin equal: 3.47.0 == 3.47.0 -> True
AC-013 git add line: ['git add pubspec.yaml CHANGELOG.md']
AC-013 commit msg: ['chore(release): v${{ steps.bump.outputs.version }}']
AC-010 guard prefix: 'chore(release): v' | commit msg starts with it: True
AC-010 release-style message rejected: True | ordinary message accepted: True
AC-014 annotated tag: True | no force/delete anywhere: True
AC-015 checkout token: ${{ secrets.RELEASE_GITHUB_TOKEN }} | permissions: {'contents': 'read'} | contents write absent: True
AC-017 matching: {'v0.1.2': True, 'v10.20.30': True, 'main': False, 'v1': False, 'release-0.1.2': False}
AC-018 uses: dart-lang/setup-dart/.github/workflows/publish.yml@v1 {'id-token': 'write', 'contents': 'read'}
AC-018 no own run step: True | no secret reference: True
AC-022 release comment: True
AC-022 publish comment: True
AC-022 negative, same patterns absent from checks.yml: True
```

Secret gate body, both directions:

```
--- AC-011 empty secret ---
Missing repository secret RELEASE_GITHUB_TOKEN.
exit=1
--- AC-011 non-empty secret ---
RELEASE_GITHUB_TOKEN is present.
exit=0
```

Tag-collision guard body, in a scratch clone:

```
--- AC-016 positive ---
Tag v0.1.2 is free.
exit=0
--- AC-016 negative ---
Tag v0.1.2 already exists locally.
exit=1
```

Stage 7, in isolation, positive then negative:

```
$ sh -c 'stage_failed() { echo "Stage $1 failed: $2" >&2; exit 1; }
         sh tools/test_bump_patch_version.sh || stage_failed 7 "version bump test"
         echo "Stage 7 passed: version bump test"'
All tests passed
Stage 7 passed: version bump test
exit=0

# with one fixture expectation broken:
FAIL: valid-patch - wrong output: '3.3.4'
1 test(s) failed
Stage 7 failed: version bump test

$ grep -n 'Stage [0-9] passed' tools/check.sh | tail -2
40:echo "Stage 6 passed: build"
43:echo "Stage 7 passed: version bump test"
```

Full suite and wiki lint:

```
$ python3 tools/lint_wiki.py
lint_wiki: clean (0 warning(s)).

$ bash tools/check.sh
...
142 issues found.
Stage 4 failed: analysis
```

Attribution of that failure:

```
$ dart analyze --fatal-infos --fatal-warnings | ... | cut -d/ -f1 | sort | uniq -c
 142 spikes

$ dart analyze --fatal-infos --fatal-warnings | grep -E 'tools/|\.github/'
none of the added files appear in analysis output
```

Restraint checks and their negative cases:

```
=== AC-019 checks.yml untouched ===
(no output from git status --porcelain or git diff --stat for that path)
=== AC-019 negative: same detector on a spoiled copy ===
 {.github/workflows => .verify-scratch}/checks.yml | 1 +
diff-exit=1 (1 = change detected)

=== AC-020 no release performed ===
3:version: 0.1.1
no 0.1.2 changelog heading
no v0.1.2 tag
=== AC-020 negative: searches fire on a spoiled copy ===
3:version: 0.1.2
3:## 0.1.2 - 2026-01-01

=== AC-023 credential search ===
no credential material found
--- only secret reference: ---
release.yml:42:  RELEASE_GITHUB_TOKEN: ${{ secrets.RELEASE_GITHUB_TOKEN }}
release.yml:53:  token: ${{ secrets.RELEASE_GITHUB_TOKEN }}
=== AC-023 negative: planted credential material is detected ===
105:  PUB_TOKEN: ghp_abcdefghijklmnopqrstuvwxyz012345
106:  credentials: /root/.config/dart/pub-credentials.json
grep-exit=0 (0 = detected)
```

## Per-criterion results

| Criterion | Result | Evidence (file:line) | Negative case exercised |
|---|---|---|---|
| AC-001 | pass | tools/test_bump_patch_version.sh case valid-patch | yes |
| AC-002 | pass | tools/test_bump_patch_version.sh case valid-minor-untouched | yes |
| AC-003 | pass | tools/bump_patch_version.sh:95; test case valid-patch | yes |
| AC-004 | pass | tools/bump_patch_version.sh:97; test case reject-changelog-ahead | yes |
| AC-005 | pass | tools/bump_patch_version.sh:27; test cases reject-missing-pubspec, reject-missing-changelog | yes |
| AC-006 | pass | tools/test_bump_patch_version.sh; broken fixture named `valid-patch` | yes |
| AC-007 | partial | tools/check.sh:42 | yes, in isolation |
| AC-008 | pass | .github/workflows/release.yml:19 | yes |
| AC-009 | pass | .github/workflows/release.yml:26 | yes |
| AC-010 | pass | .github/workflows/release.yml:37 and :90 | yes |
| AC-011 | pass | .github/workflows/release.yml:39 | yes |
| AC-012 | pass | .github/workflows/release.yml:65 | yes |
| AC-013 | pass | .github/workflows/release.yml:86 | yes |
| AC-014 | pass | .github/workflows/release.yml:96 | yes |
| AC-015 | pass | .github/workflows/release.yml:23 and :53 | yes |
| AC-016 | pass | .github/workflows/release.yml:73 | yes |
| AC-017 | pass | .github/workflows/publish.yml:14 | yes |
| AC-018 | pass | .github/workflows/publish.yml:21 | yes |
| AC-019 | pass | git status and git diff for that path are empty | yes |
| AC-020 | pass | pubspec.yaml:3 reads 0.1.1; no 0.1.2 heading; no v0.1.2 tag | yes |
| AC-021 | pass | .github/workflows/release.yml:54 and :58 versus checks.yml:43 | yes |
| AC-022 | pass | .github/workflows/release.yml:7 and publish.yml:7 | yes |
| AC-023 | pass | only two secret references, both the named lookup | yes |
| AC-024 | pass | every reject case compares both files before and after | yes |
| AC-025 | pass | no URL, host name or network command in either script | yes |

## Findings

### F-001 — the full check suite cannot reach stage 7 in this working tree

- Severity: PRE_EXISTING
- Location: `spikes/page-semantics/**`, `spikes/native-publisher/**`
- Criterion affected: AC-007, partially
- Observation: `bash tools/check.sh` stops at stage 4 with 142 analyzer issues, every one of them under `spikes/`, which work item 0008 added to this working tree before this work item began. None of the files this work item adds appears in the analyzer output. Stage 7 was therefore exercised with the same invocation and the same failure-reporting helper that `tools/check.sh` uses, positive and negative, rather than through a full suite run.
- Why it matters: on CI, and on any tree where stage 4 passes, stage 7 runs as written. Until the spike analysis failures are resolved by work item 0008, the release workflow's own check step would also stop at stage 4, which means no release can be cut from this tree. That is the check suite gating the release exactly as intended, but it is a live prerequisite rather than a defect in this change.

### F-002 — the changelog rebuild assumed the title was on line 1

- Severity: IMPORTANT, fixed during implementation
- Location: `tools/bump_patch_version.sh:60` and `:92`
- Criterion affected: AC-003, AC-004
- Observation: the first implementation validated the title as the first non-blank line but rebuilt the file with a hardcoded title line and `tail -n +2`, so a changelog whose title was preceded by a blank line would have been written with two title lines. The helper now resolves the title's line number once and reuses it, and a new fixture, `valid-leading-blank`, fails if the title is duplicated or the blank separator is lost.
- Why it matters: the corruption would have been committed and published, and no criterion as frozen would have caught it.

### F-003 — the loop-guard expression made the workflow file invalid YAML

- Severity: BLOCKER, fixed during implementation
- Location: `.github/workflows/release.yml:37`
- Criterion affected: AC-008 through AC-016, all of which require the file to parse
- Observation: the job condition contains `chore(release): v`, whose colon-space sequence made the unquoted `if` value unparseable; PyYAML rejected the file with `mapping values are not allowed here`. The value is now quoted. Parsing the file is what caught it.
- Why it matters: GitHub would have refused the workflow, so no release would have run at all.

## Recurrence check

- Previous round: `wiki/work/0009-pubdev-publish-workflow/validation/plan-review-01.md`
- Recurring findings: none. The three plan-level blockers from round 1 are addressed in the implementation: no skip instruction appears in `release.yml`, the loop guard is the commit-message prefix cross-checked against the commit step, and the duplicate-heading rule is exercised by a disagreement fixture rather than a repeated run.
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | pre-existing, work item 0008; not routed into this work item |
| F-002 | implement, already closed in this round |
| F-003 | implement, already closed in this round |
