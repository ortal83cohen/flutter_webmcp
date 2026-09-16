# Plan review — round 01

- Work item: 0015-skip-occupied-release-versions
- Reviewed artifacts: `wiki/work/0015-skip-occupied-release-versions/01-plan.md`,
  `wiki/work/0015-skip-occupied-release-versions/03-tasks.md` against
  `wiki/work/0015-skip-occupied-release-versions/02-criteria.md`, at git revision
  87e3545 (work-item files untracked)
- Reviewer: plan validator (adversarial, blind)
- Date: 2026-09-16

## Verdict

**PASS**

Every numbered criterion is owned by a plan step and a task, the shared occupancy
contract is decided before the only parallel split, the plan contains no fenced
code, and the claims about the current helper and release job match the tree.
The findings below do not leave a criterion unmet or invalidate the approach.

## Verification performed

Structural coverage (plan, criteria, tasks):

```
$ python3 - <<'PY'
from pathlib import Path
import re
p = Path('wiki/work/0015-skip-occupied-release-versions')
plan = (p/'01-plan.md').read_text()
criteria = (p/'02-criteria.md').read_text()
tasks = (p/'03-tasks.md').read_text()
ids = sorted(set(re.findall(r'AC-\d{3}', criteria)))
print('criteria IDs:', ids, 'count', len(ids))
assert not re.search(r'^\s*(```|~~~)', plan, re.M)
print('PASS: plan has no fenced code blocks')
main, test = tasks.split('## Test tasks')
missing_task = []
missing_test = []
for ac in ids:
    if ac not in main:
        missing_task.append(ac)
    if ac not in test:
        missing_test.append(ac)
print('missing from task ownership:', missing_task or 'none')
print('missing from test tasks table:', missing_test or 'none')
print('AC-020 task mentions:', main.count('AC-020'))
print('--- [P] file owners ---')
for line in main.splitlines():
    if '[P]' in line and line.startswith('|'):
        cols = [c.strip() for c in line.split('|')]
        print(cols[1], 'files:', cols[4])
print('report exists?', (p/'validation/plan-review-01.md').exists())
print('vague matches', len(re.findall(r'correctly|properly|as expected', criteria, re.I)))
empty_neg = 0
for line in criteria.splitlines():
    if re.match(r'\| AC-\d{3} ', line):
        parts = [c.strip() for c in line.split('|')]
        if len(parts) >= 5 and parts[4] == '':
            empty_neg += 1
            print('empty neg', parts[1])
print('empty negative columns', empty_neg)
PY
```

```
criteria IDs: ['AC-001', 'AC-002', 'AC-003', 'AC-004', 'AC-005', 'AC-006', 'AC-007', 'AC-008', 'AC-009', 'AC-010', 'AC-011', 'AC-012', 'AC-013', 'AC-014', 'AC-015', 'AC-016', 'AC-017', 'AC-018', 'AC-019', 'AC-020', 'AC-021', 'AC-022', 'AC-023', 'AC-024'] count 24
PASS: plan has no fenced code blocks
missing from task ownership: none
missing from test tasks table: none
AC-020 task mentions: 2
--- [P] file owners ---
1.1 files: tools/bump_patch_version.sh, tools/test_bump_patch_version.sh, tools/fixtures/bump-patch-version/**
1.2 files: tools/occupied_pubdev_versions.py, tools/test_occupied_pubdev_versions.sh, tools/fixtures/occupied-pubdev-versions/**
report exists? False
vague matches 0
empty negative columns 0
```

Artifact hygiene and named source claims:

```
$ grep -n '```' wiki/work/0015-skip-occupied-release-versions/01-plan.md
(no output — zero fenced code blocks)

$ grep -nEi "correctly|properly|as expected|appropriate|reasonabl|robust" \
    wiki/work/0015-skip-occupied-release-versions/02-criteria.md
(no output)

$ grep -c "^| AC-" wiki/work/0015-skip-occupied-release-versions/02-criteria.md
24

$ grep -n 'Stage .* passed' tools/check.sh
21:echo "Stage 1 passed: wiki lint"
31:echo "Stage 2 passed: dependencies"
41:echo "Stage 3 passed: format"
53:echo "Stage 4 passed: analysis"
61:echo "Stage 5 passed: tests"
68:echo "Stage 6 passed: build"
71:echo "Stage 7 passed: version bump test"

$ grep -n 'force' .github/workflows/release.yml
79:          git fetch --tags --force

$ git diff -- .github/workflows/publish.yml .github/workflows/checks.yml | wc -c
       0

$ grep '^version:' pubspec.yaml
version: 0.1.5

$ ls tools/occupied_pubdev_versions.py tools/test_occupied_pubdev_versions.sh \
    tools/fixtures/occupied-pubdev-versions
ls: tools/fixtures/occupied-pubdev-versions: No such file or directory
ls: tools/occupied_pubdev_versions.py: No such file or directory
ls: tools/test_occupied_pubdev_versions.sh: No such file or directory
```

Helper and workflow assumptions checked against the tree (true):

- `tools/bump_patch_version.sh` is POSIX `sh` with `set -eu`, optional repository-root
  argument, optional `RELEASE_DATE`, patch-only arithmetic at lines 52-59, heading
  check on `NEW_VERSION` before any write at lines 75-80, one stdout line on success,
  and no git or network command.
- `tools/test_bump_patch_version.sh` runs the nine named fixture cases plus
  `test_real_repo` (lines 302-314) and pins `RELEASE_DATE`.
- `.github/workflows/release.yml` installs Python 3.12 (lines 56-58) before the
  check suite (lines 66-67) and the bump step `id: bump` (lines 69-74); the tag
  collision step at lines 76-88 sits between bump and commit; the job-level loop
  guard is `chore(release): v` at line 38; commit is pushed before the annotated
  tag at lines 97-104; there is no `continue-on-error` on the bump step.
- `.github/workflows/publish.yml` and `.github/workflows/checks.yml` are currently
  unmodified relative to HEAD.

No helper tests, full check suite, or live pub.dev GET were run in this plan
review. Those belong to implement and verify.

## Per-criterion results

Plan review: coverage is mapped here rather than pass/fail of code.

| Criterion | Result | Evidence (file:line) | Negative case exercised |
|---|---|---|---|
| AC-001 | covered | `01-plan.md:9`, `:29-31`; task 1.1 | in criteria and test table |
| AC-002 | covered | `01-plan.md:29-31`; task 1.1 | in criteria and test table |
| AC-003 | covered | `01-plan.md:29-31`; task 1.1 | in criteria and test table |
| AC-004 | covered | `01-plan.md:29-31`; task 1.1 | in criteria and test table |
| AC-005 | covered | `01-plan.md:9`, `:43`; task 1.1 | in criteria and test table |
| AC-006 | covered | `01-plan.md:29`, `:41`; task 1.1 | in criteria and test table |
| AC-007 | covered | `01-plan.md:9`, `:45`; task 1.1 | in criteria and test table |
| AC-008 | covered | `01-plan.md:31`; task 1.1 | in criteria and test table |
| AC-009 | covered | `01-plan.md:25`, `:47`; task 1.2 | in criteria and test table |
| AC-010 | covered | `01-plan.md:25`, `:47`; task 1.2 | in criteria and test table |
| AC-011 | covered | `01-plan.md:47`; task 1.2 | in criteria and test table |
| AC-012 | covered | `01-plan.md:25`, `:47`; task 1.2 | in criteria and test table |
| AC-013 | covered | `01-plan.md:27`; task 1.3 | in criteria and test table |
| AC-014 | covered | `01-plan.md:33`, `:49`; task 2.1 | in criteria and test table |
| AC-015 | covered | `01-plan.md:33`, `:49`; task 2.1 | in criteria and test table |
| AC-016 | covered | `01-plan.md:33`, `:51`; task 2.1 | in criteria and test table |
| AC-017 | covered | `01-plan.md:35`; task 3.1 | in criteria and test table |
| AC-018 | covered | `01-plan.md:35`; task 3.1 | in criteria and test table |
| AC-019 | covered | `01-plan.md:45`; task 1.1 | in criteria and test table |
| AC-020 | covered | `01-plan.md:13`, `:33-35`; tasks 2.1 and 3.1 | in criteria and test table |
| AC-021 | covered | `01-plan.md:29`; task 1.1 | in criteria and test table |
| AC-022 | covered | `01-plan.md:25`; task 1.2 | in criteria and test table |
| AC-023 | covered | `01-plan.md:49`; task 2.1 | in criteria and test table |
| AC-024 | covered | `01-plan.md:29`; task 1.1 | in criteria and test table |

No step satisfies zero criteria. Parallel markers: tasks 1.1 and 1.2 own disjoint
file trees. Task 1.3 is not parallel and owns only `tools/check.sh`. Group 2 owns
only `release.yml`. Group 3 owns no product file.

## Findings

### F-001 — Parser omission of non-three-component hosted versions has no criterion and no test row

- Severity: IMPORTANT
- Location: `wiki/work/0015-skip-occupied-release-versions/01-plan.md:47`;
  `wiki/work/0015-skip-occupied-release-versions/03-tasks.md:21` and `:69-72`
- Criterion affected: none (interacts with AC-006)
- Observation: the interfaces section requires the parser to omit a
  `versions[].version` that is not exactly three numeric components, and states
  that emitting such a token would make the bump helper fail closed. That
  behaviour has no `AC-NNN`. Task 1.2's "Done when" list and the test-tasks rows
  for AC-009 through AC-012 cover a valid list, retracted inclusion,
  latest-not-complete, empty array, stdin, missing versions, invalid JSON, and
  non-array versions. They do not name a mixed fixture that contains a
  prerelease or other non-three-component hosted string. AC-006 rejects a
  malformed token in `OCCUPIED_VERSIONS` with a non-zero helper exit and
  untouched files.
- Why it matters: if the parser includes a hosted prerelease in the exported
  list, the bump helper takes the AC-006 path and every release run fails. The
  plan decided the omit rule; verify will not gate it.

### F-002 — Occupancy GET Accept value is described, not named, so AC-023's positive check is not pinned

- Severity: IMPORTANT
- Location: `wiki/work/0015-skip-occupied-release-versions/01-plan.md:11` and
  `:49`; `wiki/work/0015-skip-occupied-release-versions/02-criteria.md:39`
- Criterion affected: AC-023
- Observation: the plan requires "the Accept header for the hosted-repository v2
  JSON media type" and AC-023 requires "the hosted-repository v2 JSON Accept
  header". Neither artifact writes the media type token. Research names
  `application/vnd.pub.v2+json` in
  `wiki/work/0015-skip-occupied-release-versions/research/occupancy-signals.md:15`.
  AC-023's check method greps for Authorization, query-string markers, and
  credential vocabulary; it does not grep for an Accept value. Only task 2.1
  owns the occupancy step.
- Why it matters: an implementer or a later verifier can treat any JSON Accept
  header as satisfying AC-023, and the one string research already recorded is
  not a shared decision in the plan.

### F-003 — AC-020's "force flags" check matches the collision step the plan requires keeping

- Severity: IMPORTANT
- Location: `wiki/work/0015-skip-occupied-release-versions/02-criteria.md:31`;
  `.github/workflows/release.yml:79`
- Criterion affected: AC-020
- Observation: AC-020's criterion text forbids force-push. Its check method says
  "grep for force flags". The collision step the plan leaves unchanged already
  contains `git fetch --tags --force`. The negative case is a scratch copy that
  force-pushes the tag, which is the intended distinction, but the positive
  check as written is broader than that distinction.
- Why it matters: a verify reading that greps for `force` on the committed
  `release.yml` fails a correct implementation that kept today's tag fetch.

### F-004 — Plan step 1's completion list omits the non-array versions case AC-011 names

- Severity: NIT
- Location: `wiki/work/0015-skip-occupied-release-versions/01-plan.md:25`;
  `wiki/work/0015-skip-occupied-release-versions/03-tasks.md:21`
- Criterion affected: AC-011
- Observation: AC-011 and the test-tasks row require both invalid JSON and a
  versions value that is not an array. Task 1.2's body names the non-array
  failure. The plan step 1 "Complete when" list and the task 1.2 "Done when"
  list name missing versions and invalid JSON, not the object-valued versions
  fixture.
- Why it matters: a mechanical reading of "done when" can close task 1.2 without
  the versions-is-object fixture even though the criterion and the test table
  still require it.

## Recurrence check

- Previous round: none — first round.
  `wiki/work/0015-skip-occupied-release-versions/validation/` did not exist
  before this report.
- Recurring findings: none
- Oscillating: no

## Routing

No blockers. The important findings belong to plan if they are closed this round;
they are not implementation defects.

| Finding | Belongs to phase |
|---|---|
| F-001 | plan |
| F-002 | plan |
| F-003 | plan |
| F-004 | plan |
