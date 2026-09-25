# Research: How the bump helper writes the new CHANGELOG section

## Question

How does `tools/bump_patch_version.sh` write the new CHANGELOG section today, and which tests and fixtures lock the sentence `Automated patch release from main.`? Where should logic that promotes Unreleased notes into that section live?

## Answer

The helper rebuilds CHANGELOG.md in memory: it keeps every line through the `# Changelog` title, then inserts one blank line, a dated `##` heading for the computed version, one blank line, the single fixed bullet `- Automated patch release from main.`, one blank line, and the previous remainder with its leading blanks dropped. It never reads, moves, or empties an Unreleased section. The sentence is locked by the helper itself, by two positive cases in `tools/test_bump_patch_version.sh`, and by frozen AC-004; no fixture file contains that sentence.

## Findings

### The helper inserts a fixed four-line section immediately after the title

- Claim: After validating that CHANGELOG.md exists, that its first non-blank line is `# Changelog`, and that no heading already names the computed new version, the helper writes both files from temporary copies and prints only the new version.
- Evidence: Existence check, title-line resolution, title-text check, duplicate-heading reject, in-memory rebuild, heading validation, atomic `mv`, and a final `echo` of `$NEW_VERSION`.
- Source: `tools/bump_patch_version.sh:33-37`, `tools/bump_patch_version.sh:92-111`, `tools/bump_patch_version.sh:120-164`

- Claim: The new section is always the same shape. The date comes from `RELEASE_DATE` when that variable is non-empty, otherwise from UTC `YYYY-MM-DD`. The heading is two hashes, a space, the new version, a space, a hyphen, a space, and that date. The only body line is the hardcoded echo of `- Automated patch release from main.`
- Evidence: Date branch, then the rebuild block that prints a blank line, the heading, a blank line, the fixed bullet, and another blank line.
- Source: `tools/bump_patch_version.sh:113-118`, `tools/bump_patch_version.sh:130-146`

- Claim: Existing changelog body is copied, not interpreted. Lines through the title stay as they are. Lines after the title have leading blank lines skipped so exactly one blank line separates the new section from the previously top-most heading. No step searches for `Unreleased`.
- Evidence: `sed` prints `1` through `TITLE_LINE_NUMBER`. The `awk` program skips `NR <= title_line`, then skips leading blanks, then prints the rest. The word Unreleased does not appear in the helper.
- Source: `tools/bump_patch_version.sh:130-146`

- Claim: Work item 0009 placed that changelog edit in this helper, not in workflow YAML, so the edit can be tested offline. The plan also forbids rewriting or reordering existing changelog content and freezes the bullet text so tests compare a known string rather than whatever the helper happens to emit.
- Evidence: Approach paragraph names the helper as the owner of version arithmetic and the changelog edit. Changelog-format paragraph requires insert-after-title, no Keep-a-Changelog vocabulary, unchanged existing content, and the exact English sentence.
- Source: `wiki/work/0009-pubdev-publish-workflow/01-plan.md:17`, `wiki/work/0009-pubdev-publish-workflow/01-plan.md:65-67`

### Two test cases and frozen AC-004 lock the sentence; fixtures do not

- Claim: The `valid-patch` case requires the fifth line of the written changelog to equal `- Automated patch release from main.` after a successful bump from `0.1.1` to `0.1.2` with `RELEASE_DATE=2026-01-02`.
- Evidence: The case reads line 5 with `sed` and compares it to that exact string, then also requires the previous heading `## 0.1.1 - 2026-08-01` to remain.
- Source: `tools/test_bump_patch_version.sh:13`, `tools/test_bump_patch_version.sh:33-51`

- Claim: The `valid-leading-blank` case requires the sixth line of the written changelog to equal the same bullet string, because the fixture's leading blank line leaves the title on line 2 and the new section starting on line 4.
- Evidence: The assertion is a conjunction that checks the heading on line 4, the bullet on line 6, a blank separator on line 7, and the previous heading on line 8.
- Source: `tools/test_bump_patch_version.sh:97-111`

- Claim: Frozen AC-004 requires exactly one bullet line equal to a hyphen, one space, and the sentence `Automated patch release from main.`, and requires the previously top-most heading and its body to remain later in the file. The criterion was frozen on 2026-09-10.
- Evidence: Criteria table row AC-004 and the Frozen block.
- Source: `wiki/work/0009-pubdev-publish-workflow/02-criteria.md:5-6`, `wiki/work/0009-pubdev-publish-workflow/02-criteria.md:15`

- Claim: No file under `tools/fixtures/bump-patch-version/` contains the sentence `Automated patch release from main.` or an `Unreleased` heading. The fixtures lock previous headings and reject paths, not the new bullet text.
- Evidence: A search of that fixture tree for both strings returns no matches. The `valid-patch` changelog holds `# Changelog`, then `## 0.1.1 - 2026-08-01` and `- Previous release notes.` The `valid-leading-blank` changelog holds a leading blank, the title, then `## 2.4.9 - 2026-08-01`. The `valid-minor-untouched` changelog holds `## 1.2.3 - 2026-08-15`.
- Source: `tools/fixtures/bump-patch-version/valid-patch/CHANGELOG.md:1-5`, `tools/fixtures/bump-patch-version/valid-leading-blank/CHANGELOG.md:1-5`, `tools/fixtures/bump-patch-version/valid-minor-untouched/CHANGELOG.md:1-5`

- Claim: Occupied-version cases and `valid-minor-untouched` do not lock the bullet sentence. They assert the chosen version heading or the pubspec version line only.
- Evidence: `assert_chosen_version` greps `version: $expected` and `## $expected - 2026-01-02`. The minor-untouched case greps only pubspec version lines.
- Source: `tools/test_bump_patch_version.sh:77-91`, `tools/test_bump_patch_version.sh:288-293`

### Today's live changelog shows why a later Unreleased block is never promoted

- Claim: The current repository changelog already has dated sections `0.1.8` through `0.1.2` above an `## Unreleased` block. Each of those dated sections uses the same automated bullet. The helper would insert the next dated section after the title and leave that Unreleased block where it sits.
- Evidence: Headings `## 0.1.8` through `## 0.1.2` occupy lines 3-29 with the automated bullet; `## Unreleased` begins at line 31.
- Source: `CHANGELOG.md:3-38`

- Claim: The release workflow calls the helper as a single shell command and then commits `pubspec.yaml` and `CHANGELOG.md`. It does not post-process the changelog.
- Evidence: The bump step assigns `new_version=$(sh tools/bump_patch_version.sh)`. The commit step stages those two paths.
- Source: `.github/workflows/release.yml:112-117`, `.github/workflows/release.yml:133-138`

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Extend `tools/bump_patch_version.sh` so the new section body is promoted Unreleased notes instead of the fixed sentence | The same in-memory rebuild would copy Unreleased bullets under the new dated heading, then drop or empty Unreleased, still writing both files before the single `mv`. | Must change the helper, rewrite `valid-patch` and `valid-leading-blank`, add Unreleased fixtures, and replace or supersede frozen AC-004. Also collides with the 0009 rule that existing changelog content is never rewritten or reordered. | Favoured if the new section body remains part of the changelog edit the helper already owns and tests offline. Not chosen in this stream. |
| Add a second helper and call it from `.github/workflows/release.yml` after the bump | `bump_patch_version.sh` keeps writing the fixed sentence so AC-004 still passes; a new script then rewrites the just-inserted section. | Two writers of CHANGELOG.md in one release. Occupied-skip and leading-blank layout would have to be re-proven after the second write. The workflow would stop being a thin sequence of named steps. | Weaker than extending the existing helper, because 0009 put the changelog edit in the helper specifically so it is fixture-tested and the workflow stays thin. Not chosen in this stream. |
| Inline promotion in the release workflow YAML | A workflow step would edit CHANGELOG.md with a stream editor after the bump. | No offline fixture test. 0009 already rejected inline bump arithmetic for that reason. | Rejected for the same testability reason recorded in the 0009 plan. |

## Constraints discovered

- The helper contract from 0009 still applies: optional repository-root argument, `RELEASE_DATE` override, stdout is only the version string, non-zero exit means neither file was written, no git and no network. Source: `wiki/work/0009-pubdev-publish-workflow/01-plan.md:17`, `wiki/work/0009-pubdev-publish-workflow/01-plan.md:55-57`
- AC-004 is frozen. Changing the required bullet after implementation started needs a recorded new validation round, not a silent edit of that file. Source: `wiki/work/0009-pubdev-publish-workflow/02-criteria.md:5-6`, `wiki/work/0009-pubdev-publish-workflow/02-criteria.md:15`
- The 0009 plan states that existing changelog content is never rewritten or reordered. Promoting Unreleased notes is a rewrite. Source: `wiki/work/0009-pubdev-publish-workflow/01-plan.md:65`
- Current fixtures have no Unreleased section, so they cannot lock promotion behaviour until new fixtures are added. Source: `tools/fixtures/bump-patch-version/valid-patch/CHANGELOG.md:1-9`
- The live Unreleased block is not the top-most section. Insert-after-title therefore cannot promote it without a search that today's helper does not do. Source: `CHANGELOG.md:3-38`, `tools/bump_patch_version.sh:130-146`
- Work item 0013 already warned that heading order alone does not prove those Unreleased bullets belong on a future version. Source: `wiki/work/0013-request-changelog/research/migration.md:7-9`, `wiki/work/0013-request-changelog/research/migration.md:16-22`

## Unresolved

- [UNRESOLVED: Should this work item supersede frozen AC-004, or must the helper keep emitting the automated sentence and promote Unreleased by some other means?]
- [UNRESOLVED: When Unreleased is missing or has no bullets, does the helper keep the automated sentence, write an empty dated section, or fail?]
- [UNRESOLVED: After a successful promotion, does the Unreleased heading remain as an empty section or disappear?]
- [UNRESOLVED: May the helper move the current live Unreleased block that already sits below 0.1.2 through 0.1.8, or only an Unreleased section that is the first section after the title?]
- [UNRESOLVED: Do occupied-skip success cases need a new bullet assertion, or is the heading-only `assert_chosen_version` check still enough?]
- [UNRESOLVED: Does the 0009 rule that existing changelog content is never rewritten still bind this work item, or does 0016 explicitly replace that rule for Unreleased notes only?]

## Sources

- `tools/bump_patch_version.sh`, consulted 2026-09-25
- `tools/test_bump_patch_version.sh`, consulted 2026-09-25
- `tools/fixtures/bump-patch-version/`, consulted 2026-09-25
- `wiki/work/0009-pubdev-publish-workflow/01-plan.md`, consulted 2026-09-25
- `wiki/work/0009-pubdev-publish-workflow/02-criteria.md`, consulted 2026-09-25
- `.github/workflows/release.yml`, consulted 2026-09-25
- `CHANGELOG.md`, consulted 2026-09-25
- `wiki/work/0013-request-changelog/research/migration.md`, consulted 2026-09-25
