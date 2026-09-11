# Plan review — round 01

- Work item: 0009-pubdev-publish-workflow
- Reviewed artifact: `wiki/work/0009-pubdev-publish-workflow/01-plan.md`, `02-criteria.md`, `03-tasks.md` (working tree, uncommitted; repository head `git rev-parse HEAD` recorded below)
- Reviewer: plan-validator
- Date: 2026-09-10

## Verdict

**FAIL**

Three blockers: the plan's own loop guard is the same string that the documented skip mechanism applies to the tag push the release depends on, the actor guard the plan and AC-010 rely on cannot fire for a token-authenticated push, and AC-004's negative case describes an outcome the helper contract in the plan cannot produce.

## Verification performed

Repository state under review:

```
$ git rev-parse HEAD
a8e46a5ea3fbf484b393384ef412e7bc76729302
```

The three artifacts are untracked working-tree files at that head.

Plan is prose only (no fenced code blocks):

```
$ grep -n '```' wiki/work/0009-pubdev-publish-workflow/01-plan.md; echo "(exit $?)"
(exit 1)
```

Repository facts the plan asserts:

```
$ cat pubspec.yaml
name: webmcp_flutter
description: A detection-first WebMCP tool registry and widget lifecycle layer for Flutter web applications.
version: 0.1.1
repository: https://github.com/ortal83cohen/flutter_webmcp
...
environment:
  sdk: ^3.13.0
  flutter: ">=3.47.0"

$ cat CHANGELOG.md
# Changelog

## 0.1.1 - 2026-09-10

- Add the public GitHub repository link to package metadata.

## 0.1.0 - 2026-09-10
...

$ git tag -l
(empty)
```

Confirmed true, and therefore not findings: the version line is a single unindented top-level key (plan line 21); the first non-blank changelog line is the single-hash title and both existing sections use the bracket-free `## X.Y.Z - DATE` form (plan line 57); no tag exists yet, so the tag-collision guard has a clean starting state (plan line 63).

Existing check script and workflow, for the stage-numbering and toolchain claims:

```
$ cat -n tools/check.sh
     1  #!/bin/sh
     2  set -eu
...
     7  for binary in flutter dart; do
     8    if ! command -v "$binary" >/dev/null 2>&1; then
     9      echo "Preflight failed: missing required binary: $binary" >&2
    10      exit 1
...
    20  python3 tools/lint_wiki.py || stage_failed 1 "wiki lint"
...
    38  (cd example && flutter build web) || stage_failed 6 "build"
    40  echo "Stage 6 passed: build"

$ cat -n .github/workflows/checks.yml
...
    39      - name: Set up Flutter
    40        uses: subosito/flutter-action@v2
    41        with:
    42          channel: stable
    43          flutter-version: 3.47.0
```

Stage 6 is the last stage, so the plan's "new final stage" is stage 7 — consistent. The preflight at lines 7–12 and the wiki lint at line 20 mean `tools/check.sh` cannot run on a runner without `flutter`, `dart` and `python3`; this backs F-005.

The reusable publish workflow the plan delegates to:

```
$ curl -sSL https://raw.githubusercontent.com/dart-lang/setup-dart/v1/.github/workflows/publish.yml
on:
  workflow_call:
    inputs:
      environment: ...
      working-directory: ...
jobs:
  publish:
    permissions:
      id-token: write
    steps:
      - uses: actions/checkout@3d3c42e...
      - uses: dart-lang/setup-dart@7654d45...
      - uses: flutter-actions/setup-flutter@6e2468f...
      - run: dart pub get
      - run: dart pub publish --dry-run
      - run: dart pub publish -f
```

The reference at `v1` exists, installs a Flutter SDK, and takes no secret — the plan's claims at lines 65 and 15 hold. Its Flutter version is unpinned:

```
$ curl -sSL https://raw.githubusercontent.com/flutter-actions/setup-flutter/main/action.yml | head -12
inputs:
  version:
    description: "The version to install: Default: latest"
    default: "latest"
```

That backs F-010.

Skip-instruction semantics, the source of F-002:

```
$ curl -sSL https://raw.githubusercontent.com/github/docs/main/content/actions/how-tos/manage-workflow-runs/skip-workflow-runs.md
Workflows that would otherwise be triggered using `on: push` or `on: pull_request` won't be
triggered if you add any of the following strings to the commit message in a push:
* `[skip ci]` ...
Skip instructions only apply to the `push` and `pull_request` events.
Skip instructions only apply to the workflow run(s) that would be triggered by the commit
that contains the skip instructions.
```

Actor semantics, the source of F-003:

```
$ curl -sSL https://raw.githubusercontent.com/github/docs/main/content/actions/reference/workflows-and-actions/contexts.md | grep -n 'github.actor`'
181:| `github.actor` | `string` | The username of the user that triggered the initial workflow run. ...
```

Research coverage of the skip marker:

```
$ grep -rn -i "skip ci" wiki/work/0009-pubdev-publish-workflow/
00-research.md:45: Claim: A commit message containing skip ci, ci skip, no ci, skip actions, or actions skip
                   prevents push and pull-request workflows from running.
research/version-bump.md:79: | **[skip ci] in commit message** | ... | **CHOSEN** |
```

The research records the general claim and never examines the tag-push case, which is why F-002 routes to research.

Packaging exposure of the new files (checked, not a finding):

```
$ cat .pubignore
/tools/
...
/.github/
```

The helper, its fixtures and both workflow files are excluded from the published archive, so a fixture `pubspec.yaml` cannot enter the uploaded package. Nested package directories already exist under `spikes/`, so adding `tools/fixtures/bump-patch-version/*/pubspec.yaml` introduces no new analyzer context class.

## Per-criterion results

Plan review: each criterion is checked for a step and a task that satisfies it, not for an implementation.

| Criterion | Result | Evidence (file:line) | Negative case exercised |
|---|---|---|---|
| AC-001 | covered | 01-plan.md:25 (step 1); 03-tasks.md:19 (task 1.1) | yes |
| AC-002 | covered | 01-plan.md:25; 03-tasks.md:19 | yes |
| AC-003 | covered | 01-plan.md:57; 03-tasks.md:19 | yes |
| AC-004 | contradicted | 01-plan.md:25, 01-plan.md:57; 02-criteria.md:15 | no — see F-001, F-004 |
| AC-005 | covered, weak negative | 01-plan.md:55; 03-tasks.md:19 | no — see F-006 |
| AC-006 | covered | 01-plan.md:27 (step 2); 03-tasks.md:19 | yes |
| AC-007 | covered | 01-plan.md:29 (step 3); 03-tasks.md:20 (task 1.2) | yes |
| AC-008 | covered | 01-plan.md:41; 03-tasks.md:25 (task 2.1) | yes |
| AC-009 | covered | 01-plan.md:47; 03-tasks.md:25 | yes |
| AC-010 | covered but inert | 01-plan.md:45; 03-tasks.md:25 | no — see F-003 |
| AC-011 | covered | 01-plan.md:51; 03-tasks.md:25 | yes |
| AC-012 | covered | 01-plan.md:11; 03-tasks.md:25 | yes |
| AC-013 | covered | 01-plan.md:61; 03-tasks.md:25 | yes |
| AC-014 | covered | 01-plan.md:61, 01-plan.md:63; 03-tasks.md:25 | yes |
| AC-015 | covered | 01-plan.md:49, 01-plan.md:51 | yes |
| AC-016 | covered | 01-plan.md:63; 03-tasks.md:25 | yes |
| AC-017 | covered | 01-plan.md:43; 03-tasks.md:26 (task 2.2) | yes |
| AC-018 | covered | 01-plan.md:65; 03-tasks.md:26 | yes |
| AC-019 | covered, tautological negative | 01-plan.md:69, 01-plan.md:35; 03-tasks.md:33 | no — see F-006 |
| AC-020 | covered, tautological negative | 01-plan.md:69, 01-plan.md:35; 03-tasks.md:33 | no — see F-006 |
| AC-021 | covered, tautological negative | 01-plan.md:97; 03-tasks.md:33 | no — see F-006 |
| AC-022 | covered, tautological negative | 01-plan.md:55; 03-tasks.md:19 | no — see F-006 |
| AC-023 | covered | 01-plan.md:27, 01-plan.md:95; 03-tasks.md:19 | yes |

No step in `01-plan.md` is entirely uncovered by a criterion, but two step requirements are — see F-005.

## Findings

### F-001 — AC-004's negative case cannot happen under the helper contract the plan defines

- Severity: BLOCKER
- Location: `wiki/work/0009-pubdev-publish-workflow/02-criteria.md:15`, with the contract at `01-plan.md:25` and the restatement at `03-tasks.md:55`
- Criterion affected: AC-004
- Observation: AC-004's negative case is "Run the helper twice against the same copy: the second run shall exit non-zero, because a section for the computed version already exists." The plan at line 25 says the helper reads the version from `pubspec.yaml`, computes the new version by incrementing the third component, and rejects only when "no existing section heading in the file names **the computed new version**". The first run rewrites `pubspec.yaml` to `0.1.2` and inserts a `## 0.1.2` heading. The second run therefore reads `0.1.2`, computes `0.1.3`, finds no `0.1.3` heading, and exits **zero**, writing a third version. The duplicate-heading check can only fire when the changelog and the pubspec disagree, which the helper itself never produces.
- Why it matters: the criterion is frozen at implementation start and will be handed to an implementer and later to an impl-validator as a required test case. It is unsatisfiable without changing the helper's rejection rule, so the implementer will either invent a different rule than the one at plan line 25 — a silent interface change — or write a test that asserts something the plan forbids. The plan and the criteria disagree about the helper's core validation rule.

### F-002 — the skip marker the plan puts in the release commit is on the head commit of the tag push that must start the publish workflow

- Severity: BLOCKER
- Location: `wiki/work/0009-pubdev-publish-workflow/01-plan.md:61` (the commit message), `01-plan.md:45` (loop guard), `01-plan.md:43` (publish trigger), `01-plan.md:63` (push ordering)
- Criterion affected: none directly; AC-013 mandates the marker and AC-017 mandates the tag trigger, so the two criteria encode the conflict
- Observation: the plan requires the bump commit message to carry `[skip ci]` (line 61) and requires the publish workflow to be started by a push of the annotated tag pointing at that same commit (lines 43 and 63). GitHub's documentation, fetched above, states that skip instructions apply to workflows triggered by `on: push` and to "the workflow run(s) that would be triggered by the commit that contains the skip instructions". A tag push is an `on: push` event and its head commit is the bump commit. The plan never analyses this interaction; it asserts at line 45 only that the marker suppresses "push and pull-request workflow runs", which is the property that would also suppress the publish run. Whether GitHub applies the skip to a tag-ref push specifically is `[UNVERIFIED]` — I could not find an authoritative statement either way — but the plan takes the favourable outcome for granted and the risk table at line 81 does not list it.
- Why it matters: the entire deliverable is the publish. If the skip applies, every run bumps, commits and tags, and nothing is ever published — and no criterion catches it, because the verification approach (line 97) is static YAML parsing and the "Explicitly not required" list at `02-criteria.md:49` rules out an end-to-end run. The failure would first appear on the first real release, after a permanent tag has landed on main. The two mechanisms the plan needs — suppress the branch-push re-trigger, start the tag-push publish — are the same mechanism pointed at the same commit, and the plan never says why one applies and the other does not.

### F-003 — the actor guard cannot fire, because the push is made with a personal or App token, not the Actions bot token

- Severity: BLOCKER
- Location: `wiki/work/0009-pubdev-publish-workflow/01-plan.md:45` and the risk mitigation at `01-plan.md:81`; frozen as `02-criteria.md:21` (AC-010)
- Criterion affected: AC-010
- Observation: the plan requires a job-level condition "that the triggering actor is not github-actions[bot]" (line 45) and lists it as a mitigation for the runaway-bump risk (line 81). But line 11 and line 51 require the pushes to use `RELEASE_GITHUB_TOKEN`, "a personal access token or GitHub App installation token", precisely so that the resulting events do start workflow runs. Per the contexts documentation fetched above, `github.actor` is "the username of the user that triggered the initial workflow run" — for a push, the account whose token pushed. A PAT-authenticated push reports the token owner (a human account) or the App's bot account, never `github-actions[bot]`. The commit *author* the plan sets at line 61 is `github-actions[bot]`, but the author is not the actor. AC-010 asserts only that the string comparison appears in the YAML, so the criterion passes while the control is inert.
- Why it matters: it is the second of two loop guards, and F-002 puts the first one in question. If the marker is removed or weakened to make the tag push start the publish workflow, the only remaining defence against an infinite bump loop is a condition that structurally never matches. AC-010 as frozen is an uncheckable criterion in the sense that matters: it passes regardless of whether the protection works.

### F-004 — the exact changelog bullet text is left to the implementer while AC-004 asserts an "expected English text"

- Severity: IMPORTANT
- Location: `wiki/work/0009-pubdev-publish-workflow/01-plan.md:57`; `02-criteria.md:15`
- Criterion affected: AC-004
- Observation: the plan fixes the heading byte-for-byte (two hashes, space, version, space, hyphen, space, date) but describes the bullet only as "one bullet reading that this version is an automated patch release from main, in English". AC-004's check is "assert the bullet line matches the expected English text" — a string neither artifact defines. The interfaces section, which is where the plan says shared decisions live, does not name it.
- Why it matters: the implementer writes both the helper and its test (task 1.1), so whatever string is chosen will pass its own test, and an impl-validator has nothing to compare against. It is a shared-decision gap in the section whose purpose is to close them, and the resulting criterion cannot fail.

### F-005 — two requirements the plan states have no criterion, and one of them is required for `tools/check.sh` to run at all

- Severity: IMPORTANT
- Location: `wiki/work/0009-pubdev-publish-workflow/01-plan.md:11` and `01-plan.md:31` (toolchain setup and release-workflow operator comment), `01-plan.md:33` (publish-workflow operator comment)
- Criterion affected: none — that is the finding
- Observation: plan line 11 requires the release job to install Python and the pinned Flutter version before running `tools/check.sh`; no criterion mentions it. `tools/check.sh` lines 7–12 abort when `flutter` or `dart` is missing and line 20 invokes `python3`, so an omitted setup step fails the job on its first real run. AC-012 constrains only the *order* of the check step relative to the git-writing steps, not the presence of the toolchain steps before it. Likewise, plan lines 31 and 33 require a short English operator comment in each workflow file naming the human prerequisites, and the operator-gates paragraph at line 67 treats those comments as the record of the gates; no criterion asserts either comment exists.
- Why it matters: verification for this work item is static file inspection only (line 97). A requirement with no criterion in a work item whose verification is entirely criterion-driven is a requirement that will not be checked, and in the toolchain case the miss surfaces only during a live release attempt.

### F-006 — five criteria have a restatement of failure where a negative case belongs

- Severity: IMPORTANT
- Location: `wiki/work/0009-pubdev-publish-workflow/02-criteria.md:16` (AC-005), `:30` (AC-019), `:31` (AC-020), `:37` (AC-021), `:38` (AC-022)
- Criterion affected: AC-005, AC-019, AC-020, AC-021, AC-022
- Observation: AC-019's negative case reads "A non-empty diff for that path is a failure of this criterion"; AC-020, AC-021 and AC-022 use the same construction. That is the definition of failing the positive check, not an independent case. AC-005's negative-case cell is a further assertion about the same single run ("assert that standard output is empty in that run"), not a second scenario. By contrast AC-001 through AC-004 each name a distinct input that must be rejected.
- Why it matters: the negative column exists so a criterion cannot pass vacuously. For AC-021 in particular — the credential-leak criterion — the check is a grep whose pattern list is not specified, and no case establishes that the grep would actually catch a planted credential. A criterion whose only failure mode is "the check failed" tells the implementer nothing about what the check must be sensitive to.

### F-007 — how the new version travels from the helper step to the guard, tag and message steps is not decided

- Severity: NIT
- Location: `wiki/work/0009-pubdev-publish-workflow/01-plan.md:55` (helper contract) and `01-plan.md:63` (ordering); `02-criteria.md:25` (AC-014), `:27` (AC-016)
- Criterion affected: AC-014, AC-016
- Observation: the plan fixes the helper's standard-output contract but never names the mechanism by which the workflow carries that value to the later steps (a named step output, an environment file, a shell variable within one step). AC-014 and AC-016 both refer to "the version the helper printed" without naming it either.
- Why it matters: only one task owns `release.yml`, so there is no collision risk, but the tag-collision guard, the commit message and the tag name all depend on the same value and an inconsistent capture would be caught by no criterion.

### F-008 — the serialised-files table omits two of task 1.1's owned paths

- Severity: NIT
- Location: `wiki/work/0009-pubdev-publish-workflow/03-tasks.md:35`–`:42`
- Criterion affected: none
- Observation: task 1.1 (line 19) owns `tools/bump_patch_version.sh`, `tools/test_bump_patch_version.sh` and `tools/fixtures/bump-patch-version/**`. The serialised-files table lists only the first of the three, alongside `tools/check.sh`, `release.yml` and `publish.yml`.
- Why it matters: the table is the artifact a parallel dispatcher reads. It is currently incomplete, though no collision follows because tasks 1.1 and 1.2 are not marked parallel and 2.1 and 2.2 own genuinely disjoint files.

### F-009 — "serialise instead of racing" overstates what a non-cancelling concurrency group does

- Severity: NIT
- Location: `wiki/work/0009-pubdev-publish-workflow/01-plan.md:47`; `02-criteria.md:20` (AC-009)
- Criterion affected: AC-009
- Observation: with `cancel-in-progress: false`, a concurrency group holds one running and one pending run; a third trigger replaces the pending one. So three pushes landing together produce two releases, not three, and the middle commit's bump is skipped. `[UNVERIFIED]` — I could not fetch the concurrency documentation page to paste the exact wording.
- Why it matters: harmless in outcome (the surviving run includes the skipped commit's changes), but the plan states a stronger property than the mechanism provides, and the risk row at line 79 rests on it.

### F-010 — the publish job's SDK is whatever the reusable workflow installs, not the version that gated the tag

- Severity: NIT
- Location: `wiki/work/0009-pubdev-publish-workflow/01-plan.md:65`
- Criterion affected: none
- Observation: `checks.yml:43` pins Flutter 3.47.0 and `pubspec.yaml` requires `flutter: ">=3.47.0"` and `sdk: ^3.13.0`. The delegated workflow installs `flutter-actions/setup-flutter` with its default `version: latest` on the stable channel, as shown above. The plan notes only that "the Dart-maintained workflow owns the SDK installation".
- Why it matters: `dart pub get` and `dart pub publish --dry-run` run on an SDK the repository never pins, so the archive is validated on a different toolchain than the one that gated the tag. Latest stable satisfies the constraint today, so this is a note, not a defect.

## Recurrence check

- Previous round: none — first round
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | plan (helper rejection rule and AC-004 disagree; criteria are not yet frozen) |
| F-002 | research first, then plan (the skip-marker research claim at 00-research.md:45 was never tested against a tag-ref push; the design decision that rests on it is the plan's) |
| F-003 | plan (the actor-guard decision at 01-plan.md:45 and AC-010) |
| F-004 | plan |
| F-005 | plan |
| F-006 | plan |
| F-007 | plan |
| F-008 | plan |
| F-009 | plan |
| F-010 | plan |
