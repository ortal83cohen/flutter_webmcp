# Research review — round 01

- Work item: 0017-promote-unreleased-on-deploy
- Reviewed artifact: `wiki/work/0017-promote-unreleased-on-deploy/00-research.md` (uncommitted; workspace HEAD `bc1d786b001ad160133e50dcbc88026c5021962b`)
- Reviewer: research-validator
- Date: 2026-09-25

## Verdict

**PASS**

Cited local files match the factual claims about the helper, the live Unreleased block, the release commit, and work item 0013; three options were compared; the operational gaps the streams left open are closed as decisions; the remaining 0013-ownership question is explicit and marked non-blocking. No blocker affects the answer the plan would consume.

## Verification performed

Read the artifact, `wiki/conventions/validation-rubrics.md`, and `wiki/templates/validation-report.md`. Opened every local citation as a source, including the three stream files named in the Sources list. Ignored author reasoning outside the artifact.

Command: `rg -n 'Unreleased|unreleased' tools/bump_patch_version.sh; echo exit:$?`

```text
exit:1
```

Command: `rg -n -i 'unreleased' tools/fixtures/bump-patch-version; echo fixtures_unreleased_exit:$?`

```text
fixtures_unreleased_exit:1
```

Command: `rg -n 'CHANGELOG' .github/workflows`

```text
.github/workflows/release.yml:137:          git add pubspec.yaml CHANGELOG.md
```

Command: `ls tools/request_changelog.py .changes 2>&1`

```text
ls: .changes: No such file or directory
ls: tools/request_changelog.py: No such file or directory
```

Command: `sed -n '35,38p;112,117p;133,147p' .github/workflows/release.yml`

```text
    # Loop guard: the push of the release commit re-enters this workflow, because it is made
    # with RELEASE_GITHUB_TOKEN. Skip the run when the head commit is one this job wrote.
    # The prefix here must stay identical to the one in the "Commit the bump" step below.
    if: "${{ !startsWith(github.event.head_commit.message, 'chore(release): v') }}"
      - name: Bump patch version
        id: bump
        run: |
          new_version=$(sh tools/bump_patch_version.sh)
          echo "version=${new_version}" >> "$GITHUB_OUTPUT"
          echo "Bumped to ${new_version}."
      - name: Commit the bump
        run: |
          git config user.name 'github-actions[bot]'
          git config user.email 'github-actions[bot]@users.noreply.github.com'
          git add pubspec.yaml CHANGELOG.md
          git commit -m 'chore(release): v${{ steps.bump.outputs.version }}'
      - name: Push the commit
        run: git push origin HEAD:main
      - name: Push the tag
        run: |
          tag="v${{ steps.bump.outputs.version }}"
          git tag -a "${tag}" -m "Release ${tag}"
          git push origin "refs/tags/${tag}"
```

`tools/bump_patch_version.sh:130-146` rebuilds after the title, inserts `## $NEW_VERSION - $DATE` and `- Automated patch release from main.`, then copies the remainder with leading blanks dropped. The word Unreleased does not appear in that file.

`tools/test_bump_patch_version.sh:47-49` requires written changelog line 5 to equal `- Automated patch release from main.` in `valid-patch`. `:109` requires written line 6 to equal that same string in `valid-leading-blank`.

`wiki/work/0009-pubdev-publish-workflow/02-criteria.md:15` (frozen AC-004) requires that exact bullet under the new heading. The criterion text is not conditioned on the absence of Unreleased; the 0009 fixtures in fact contain no such heading, which is what the artifact's "when the fixture has no Unreleased section" qualifier describes.

`CHANGELOG.md:31-38` is `## Unreleased` after the seven dated headings `0.1.8` through `0.1.2`, with three hyphen-space bullets and a two-space wrap line on each. `## 0.1.1` follows at line 40.

`wiki/work/0013-request-changelog/STATE.yaml:11` is `implementation_status: not-started`. `04-planning-result.md:27` lists implementation of `03-tasks.md` and legacy Unreleased disposition as remaining work, not as a live service. No `tools/request_changelog.py` or `.changes/` tree exists.

`wiki/work/0009-pubdev-publish-workflow/01-plan.md:55` states that standard output is only the version string and that a non-zero exit writes neither file. The sentence "It performs no git operation and touches no network" is on `:17`, not on `:55-57`.

`wiki/product/release-pipeline.md:50-55` states that a pub.dev version is permanent.

`.github/workflows/publish.yml` has no `CHANGELOG` string and no helper invocation.

## Per-criterion results

Not an implementation review. No frozen acceptance criteria were supplied for this research round.

| Research bar | Result | Evidence |
|---|---|---|
| Claims sourced or explicitly unverified | pass | Local line citations verified against the helper, tests, workflows, changelog, 0009 plan/criteria, 0013 state, and the three named streams. One constraint line range is slightly off; see F-001. |
| Alternatives considered | pass | Helper-internal promotion, a second workflow writer, and waiting for 0013 (`00-research.md:45-49`) |
| Unresolved matters explicit | pass | One item at `00-research.md:72`; later 0013 ownership is marked as not blocking 0017 |
| No fabrication of APIs, paths, or live numbers | pass | Helper path, workflow steps, changelog headings `0.1.8`–`0.1.0`, test case names, and 0013 status match the tree |

## Findings

### F-001 — "No git and no network" is cited to the wrong 0009 plan lines

- Severity: NIT
- Location: `wiki/work/0017-promote-unreleased-on-deploy/00-research.md:53`
- Criterion affected: none
- Observation: The constraint attributes stdout-only, non-zero-writes-neither, and "No git and no network inside the helper" to `wiki/work/0009-pubdev-publish-workflow/01-plan.md:55-57`. Those two paragraphs support the first two clauses. The no-git and no-network sentence is on `:17` of the same file.
- Why it matters: The constraint itself is true. A reader who opens only the cited lines will not find the git/network rule there.

## Recurrence check

- Previous round: none — first round
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | research |
