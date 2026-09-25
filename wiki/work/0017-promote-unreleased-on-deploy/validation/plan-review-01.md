# Plan review — round 01

- Work item: 0017-promote-unreleased-on-deploy
- Reviewed artifact: `wiki/work/0017-promote-unreleased-on-deploy/01-plan.md` against `wiki/work/0017-promote-unreleased-on-deploy/02-criteria.md`, at git revision bc1d786 (work-item files untracked)
- Reviewer: plan-validator
- Date: 2026-09-25

## Verdict

**PASS**

Every numbered criterion is owned by a plan step or a named interface rule, the matcher/span/copy/leftover/duplicate decisions are closed, the plan contains no fenced code, and the claims about the current helper, fixtures, release job, and work item 0013 match the tree. `03-tasks.md` is absent; that is not a blocker because the four steps are sequential and do not mark parallel file owners. The findings below do not leave a criterion unmet or invalidate the approach.

## Verification performed

Structural coverage (plan and criteria). No `03-tasks.md` is present, so task-ownership checks were not run.

```
$ python3 - <<'PY'
from pathlib import Path
import re
p = Path('wiki/work/0017-promote-unreleased-on-deploy')
plan = (p/'01-plan.md').read_text()
criteria = (p/'02-criteria.md').read_text()
ids = sorted(set(re.findall(r'AC-\d{3}', criteria)))
print('criteria IDs:', ids, 'count', len(ids))
assert not re.search(r'^\s*(```|~~~)', plan, re.M)
print('PASS: plan has no fenced code blocks')
print('vague matches', len(re.findall(r'correctly|properly|as expected', criteria, re.I)))
empty_neg = 0
for line in criteria.splitlines():
    if re.match(r'\| AC-\d{3} ', line):
        parts = [c.strip() for c in line.split('|')]
        if len(parts) >= 5 and parts[4] == '':
            empty_neg += 1
            print('empty neg', parts[1])
print('empty negative columns', empty_neg)
print('03-tasks.md exists', (p/'03-tasks.md').exists())
print('prior plan-review exists', (p/'validation/plan-review-01.md').exists())
print('orphan in steps section:', 'orphan' in plan.split('## Steps')[1].split('## Interfaces')[0])
print('orphan in verification:', 'orphan' in plan.split('## Verification approach')[1])
print('orphan in interfaces:', 'orphan' in plan.split('## Interfaces')[1].split('## Risks')[0])
PY
```

```
criteria IDs: ['AC-001', 'AC-002', 'AC-003', 'AC-004', 'AC-005', 'AC-006', 'AC-007', 'AC-008', 'AC-009', 'AC-010', 'AC-011', 'AC-012', 'AC-013', 'AC-014', 'AC-015', 'AC-016', 'AC-017', 'AC-018', 'AC-019'] count 19
PASS: plan has no fenced code blocks
vague matches 0
empty negative columns 0
03-tasks.md exists False
prior plan-review exists False
orphan in steps section: False
orphan in verification: False
orphan in interfaces: True
```

```
$ git rev-parse --short HEAD
bc1d786

$ rg -n '```' wiki/work/0017-promote-unreleased-on-deploy/01-plan.md
(no output)

$ rg -n -i 'correctly|properly|as expected' wiki/work/0017-promote-unreleased-on-deploy/02-criteria.md
(no output)

$ rg -n 'Unreleased' tools/bump_patch_version.sh
(no output)

$ rg -n 'Unreleased' tools/fixtures/bump-patch-version
(no output)

$ rg -n 'https?://|git' tools/bump_patch_version.sh
(no output)

$ rg -n 'chore\(release\): v' .github/workflows/release.yml
38:    if: "${{ !startsWith(github.event.head_commit.message, 'chore(release): v') }}"
138:          git commit -m 'chore(release): v${{ steps.bump.outputs.version }}'

$ rg -n '^version:' pubspec.yaml
3:version: 0.1.8

$ ls wiki/work/0017-promote-unreleased-on-deploy/03-tasks.md
ls: wiki/work/0017-promote-unreleased-on-deploy/03-tasks.md: No such file or directory

$ rg -n 'implementation_status' wiki/work/0013-request-changelog/STATE.yaml
11:implementation_status: not-started

$ rg -n 'echo "\$NEW_VERSION"|Automated patch release from main|unset OCCUPIED_VERSIONS' \
    tools/bump_patch_version.sh tools/test_bump_patch_version.sh
tools/bump_patch_version.sh:137:    echo "- Automated patch release from main."
tools/bump_patch_version.sh:164:echo "$NEW_VERSION"
tools/test_bump_patch_version.sh:16:    unset OCCUPIED_VERSIONS || true

$ rg -n '## Unreleased' CHANGELOG.md
31:## Unreleased
```

Codebase claims in the plan, checked against the tree (true):

- `tools/bump_patch_version.sh` rebuilds after the title, inserts the dated heading and the fixed automated sentence, then copies the remainder with leading blanks dropped (`tools/bump_patch_version.sh:130-146`). It does not contain the word Unreleased.
- The helper is POSIX `sh` with `set -eu`, optional repository-root argument, optional `RELEASE_DATE` and `OCCUPIED_VERSIONS`, occupied-version skip (`:59-90`), fail-closed validation before the two `mv` writes (`:159-161`), one stdout line that is the new version with no `v` prefix (`:164`), and no git or network command.
- No fixture under `tools/fixtures/bump-patch-version/` contains an Unreleased heading. `valid-patch` asserts the automated sentence on line 5 (`tools/test_bump_patch_version.sh:47-49`). `valid-leading-blank` asserts it on line 6 (`:109`). `test_case` unsets `OCCUPIED_VERSIONS` at line 16. Occupied-skip and reject cases exist as the plan names them. `test_real_repo` (`:490-511`) copies the live changelog, which already has a mid-file Unreleased block (`CHANGELOG.md:31-38`); that existing case only asserts stdout equals the plus-one version.
- `.github/workflows/release.yml` is the production caller: bump step at `:112-117`, then commit of only `pubspec.yaml` and `CHANGELOG.md` with prefix `chore(release): v` at `:133-138`.
- Work item 0013 remains `implementation_status: not-started`.
- Frozen 0009 AC-004 still requires the automated sentence on a fixture root (`wiki/work/0009-pubdev-publish-workflow/02-criteria.md:15`). The 0009 plan said existing changelog content is never rewritten (`wiki/work/0009-pubdev-publish-workflow/01-plan.md:65`). This plan replaces that rule only for Unreleased list items and does not edit the 0009 criteria file.

Criterion coverage (plan review, not a code pass/fail):

- AC-001: step 3 keeps existing no-Unreleased fixtures; interfaces zero-match path; verification names the missing-heading case.
- AC-002: step 2 heading-only fixture; emptiness and leftover rules.
- AC-003: step 2 subsection-only fixture; span ends only at the next exactly-two-hash heading.
- AC-004: step 2 mid-file wrapped fixture; copy unit.
- AC-005: leftover Unreleased rule; step 3 completion requires every criteria case, including the second-run negative.
- AC-006: step 2 two-heading fixture; duplicate-heading error.
- AC-007: numbered-section byte-identity rule; mid-file fixture.
- AC-008: helper-contract stdout rule; verification covers missing-Unreleased and populated runs.
- AC-009: fail-closed writes; two-heading fixture plus existing heading-disagreement reject (`reject-changelog-ahead`).
- AC-010: step 3 keeps `valid-patch` and `valid-leading-blank` line-number checks.
- AC-011: step 4 and the frozen-0009 rule.
- AC-012: heading matcher names date suffix, brackets, and different capitalisation; step 2 and verification name one lookalike fixture. See F-001.
- AC-013: mid-file fixture plus new-section placement.
- AC-014: step 2 occupied-plus-populated fixture; occupied-skip contract kept.
- AC-015: writer forbids editing `release.yml`; step 4 diffs that path; prefix already present at workflow lines 38 and 138.
- AC-016: step 4 restraint on live changelog, pubspec version, and tags.
- AC-017: step 3 keeps every existing case.
- AC-018: step 1 forbids git and network; helper currently has neither.
- AC-019: copy unit defines orphan lines; step 2 and verification do not name an orphan fixture. See F-002.

No step satisfies zero criteria. Rollback names the helper, the test script, and the new fixtures, and states that a later published version stays on pub.dev. Each risk row has a mitigation and a trigger. Shared choices for the heading matcher, span, emptiness, copy unit, leftover heading, duplicate error, writer, and helper contract are decided in the interfaces section.

No helper suite, full check suite, or live bump was run in this plan review. Those belong to implement and verify.

## Per-criterion results

Plan review: coverage is recorded in Verification performed. This table is for implementation reviews.

## Findings

### F-001 — Step 2 and verification name one lookalike fixture; AC-012 requires one fixture per lookalike

- Severity: IMPORTANT
- Location: `wiki/work/0017-promote-unreleased-on-deploy/01-plan.md:29` and `:85`
- Criterion affected: AC-012
- Observation: AC-012's check method says to run one fixture per lookalike and names three lines: `## Unreleased - 2026-01-02`, `## [Unreleased]`, and `## unreleased`. Step 2 adds "a lookalike heading that is not the exact Unreleased line". The verification approach repeats the singular "a lookalike heading". The heading matcher at line 39 already treats a date suffix, brackets, and different capitalisation as non-matches. Step 3's completion line requires every new case named in the criteria file, which is the only place the plan asks for all three.
- Why it matters: an implementer who treats the step 2 fixture list as the inventory can land one lookalike case and leave two of AC-012's required fixtures unbuilt.

### F-002 — Step 2 and verification omit the orphan fixture AC-019 names

- Severity: IMPORTANT
- Location: `wiki/work/0017-promote-unreleased-on-deploy/01-plan.md:29` and `:85`
- Criterion affected: AC-019
- Observation: AC-019's check method runs a fixture whose Unreleased span has only an orphan whitespace-prefixed line, or a whitespace-prefixed line after a blank line and no hyphen-space line. The copy unit at line 47 defines that orphan. Step 2's fixture list is heading-only, subsection-only, mid-file wrapped, one lookalike, two exact headings, and occupied-plus-populated. It does not name an orphan-only span. The verification approach's new-case list also omits it. Step 3's completion line is again the only backstop.
- Why it matters: a mechanical reading of step 2 can close the fixture work without the AC-019 tree, so an orphan line could populate the new section or be dropped from Unreleased without a named case failing.

## Recurrence check

- Previous round: none — first round. `wiki/work/0017-promote-unreleased-on-deploy/validation/plan-review-01.md` did not exist before this report.
- Recurring findings: none
- Oscillating: no

## Routing

No blockers. The important findings belong to the plan phase if they are closed this round; they are not implementation defects. Absence of `03-tasks.md` is not routed.

| Finding | Belongs to phase |
|---|---|
| F-001 | plan |
| F-002 | plan |
