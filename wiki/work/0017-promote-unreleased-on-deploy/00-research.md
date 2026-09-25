# Research: Promote Unreleased notes on deploy

## Question

How can a deploy attach the notes already written under Unreleased to the version being released, while a deploy with no such notes still records the existing automated sentence?

## Answer

The only production writer is `tools/bump_patch_version.sh`, called from `.github/workflows/release.yml`, which then commits `pubspec.yaml` and `CHANGELOG.md`. The helper always inserts `- Automated patch release from main.` and never reads Unreleased. The live Unreleased block sits below `0.1.8` through `0.1.2` and holds three wrapped bullets. Promotion belongs in that helper. Empty or missing Unreleased keeps the automated sentence. Populated Unreleased copies those bullets, including wrap lines, under the new dated heading and leaves the `## Unreleased` heading in place with no bullets. Numbered sections stay as they are. Work item 0013 is plan-only and is not the live source of notes.

## Findings

### The helper owns the new section and locks the automated sentence

- Claim: The helper rebuilds the changelog after the title, inserts a dated heading and the fixed bullet, and copies the previous remainder without searching for Unreleased.
- Evidence: Rebuild block and the absence of the word Unreleased in the helper.
- Source: `tools/bump_patch_version.sh:130-146`; `wiki/work/0017-promote-unreleased-on-deploy/research/bump-helper.md`

- Claim: Two positive tests and frozen AC-004 of work item 0009 require that exact bullet when the fixture has no Unreleased section.
- Evidence: `valid-patch` line 5 and `valid-leading-blank` line 6; AC-004.
- Source: `tools/test_bump_patch_version.sh:33-51`; `tools/test_bump_patch_version.sh:97-111`; `wiki/work/0009-pubdev-publish-workflow/02-criteria.md:15`

### The live Unreleased block is mid-file and wrapped

- Claim: `## Unreleased` is on line 31, after seven automated patch sections and before `0.1.1`. It has three hyphen-space bullets, each continued by a two-space wrap line.
- Evidence: Headings and body lines in the root changelog.
- Source: `CHANGELOG.md:3-38`; `wiki/work/0017-promote-unreleased-on-deploy/research/unreleased-shape.md`

- Claim: No fixture under `tools/fixtures/bump-patch-version/` contains an Unreleased heading.
- Evidence: Search of that tree.
- Source: `wiki/work/0017-promote-unreleased-on-deploy/research/unreleased-shape.md`

### The release job commits whatever the helper wrote

- Claim: The only production caller is the bump step in `release.yml`. It commits only `pubspec.yaml` and `CHANGELOG.md` with prefix `chore(release): v`, then tags. `publish.yml` does not edit the changelog.
- Evidence: Workflow steps.
- Source: `.github/workflows/release.yml:112-147`; `wiki/work/0017-promote-unreleased-on-deploy/research/release-callers.md`

- Claim: Work item 0013 has `implementation_status: not-started`. It planned a later exclusive owner for version notes and a disposition ledger. That code is not in the repository.
- Evidence: State and planning result.
- Source: `wiki/work/0013-request-changelog/STATE.yaml:11`; `wiki/work/0013-request-changelog/04-planning-result.md:27`

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Promote inside the bump helper | The existing command copies Unreleased bullets into the new section, or keeps the automated sentence when none exist. | Helper and fixture tests change. | Chosen. The workflow already commits the helper's changelog write, and 0009 put changelog edits in the helper so they are fixture-tested. |
| Separate pre-step or YAML edit | Another step rewrites the changelog around the helper. | A second writer, and the helper would still insert the automated sentence unless it also changes. | Rejected. The later helper write would replace or sit beside the pre-step unless the helper changes anyway. |
| Wait for work item 0013 | Request records become the notes. | No live renderer or ledger exists. | Rejected for this change. 0013 was planning only and would block release until a disposition ledger exists. |

## Constraints discovered

- Stdout of the helper remains only the new version. A non-zero exit writes neither file. No git and no network inside the helper. Source: `wiki/work/0009-pubdev-publish-workflow/01-plan.md:55-57`
- The release commit prefix stays `chore(release): v`. Source: `.github/workflows/release.yml:35-38`
- A published pub.dev version cannot be rewritten. This change affects the next bump only. Source: `wiki/product/release-pipeline.md:50-55`
- Frozen AC-004 of work item 0009 still describes fixtures that have no Unreleased section. Those fixtures keep the automated sentence. This work item does not edit 0009's criteria file.
- The user decided on 2026-09-25: when Unreleased has no bullets, keep `- Automated patch release from main.`

## Decisions that close the research gaps

These were open in the streams. They are closed here so planning does not invent them.

- A missing `## Unreleased` heading, or a heading whose span until the next `##` line contains no line that begins with hyphen then space, keeps the automated sentence and does not create an Unreleased section.
- A populated section copies each hyphen-space line and the immediately following wrap lines that begin with whitespace, unchanged, under the new dated heading. Numbered sections are not rewritten.
- After a successful copy, the bullet and wrap lines are removed from Unreleased. The exact heading `## Unreleased` stays where it was, with no bullets under it, so the next notes have a place.
- The matcher accepts only the exact line `## Unreleased`. A second such heading is an error and writes neither file.
- Subsection headings without hyphen-space bullets count as empty and keep the automated sentence.
- Work item 0013 remains plan-only. This work item does not implement request records and does not mark 0013 superseded.

## Unresolved

- [UNRESOLVED: When work item 0013 is later implemented, does Unreleased-at-deploy remain the live source of new-version bullets, or does a request-record renderer replace it?] This does not block 0017. 0013 has not started implementation.

## Sources

- `wiki/work/0017-promote-unreleased-on-deploy/research/bump-helper.md`, consulted 2026-09-25
- `wiki/work/0017-promote-unreleased-on-deploy/research/unreleased-shape.md`, consulted 2026-09-25
- `wiki/work/0017-promote-unreleased-on-deploy/research/release-callers.md`, consulted 2026-09-25
- `tools/bump_patch_version.sh`, consulted 2026-09-25
- `CHANGELOG.md`, consulted 2026-09-25
- `.github/workflows/release.yml`, consulted 2026-09-25
- `wiki/work/0013-request-changelog/STATE.yaml`, consulted 2026-09-25
