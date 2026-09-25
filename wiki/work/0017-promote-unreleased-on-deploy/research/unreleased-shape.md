# Research: Current Unreleased changelog shape

## Question

What is the current root `CHANGELOG.md` section order, especially the Unreleased section: where it sits relative to numbered versions, whether its bullets are single-line or wrapped, and whether any bump-patch fixture already contains an Unreleased heading? How can a helper tell "has recorded bullets" from an empty or missing Unreleased section, including wrapped multi-line bullets?

## Answer

The live changelog puts dated versions `0.1.8` through `0.1.2` first, then an undated `## Unreleased` block, then `0.1.1` and `0.1.0`. Unreleased holds three hyphen bullets whose text wraps onto a two-space continuation line; the dated patch sections above it are single-line. None of the nine bump-patch fixture changelogs contain an Unreleased heading, so promotion behaviour is not locked by an existing fixture.

## Findings

### Root section order places Unreleased between two numbered runs

- Claim: The file opens with `# Changelog`, then seven dated headings `## 0.1.8` through `## 0.1.2` in descending order, then `## Unreleased` with no date suffix, then `## 0.1.1` and `## 0.1.0`.
- Evidence: Title on line 1. Dated headings on lines 3, 7, 11, 15, 19, 23, 27. Undated `## Unreleased` on line 31. Older dated headings on lines 40 and 44.
- Source: `CHANGELOG.md:1`, `CHANGELOG.md:3`, `CHANGELOG.md:7`, `CHANGELOG.md:11`, `CHANGELOG.md:15`, `CHANGELOG.md:19`, `CHANGELOG.md:23`, `CHANGELOG.md:27`, `CHANGELOG.md:31`, `CHANGELOG.md:40`, `CHANGELOG.md:44`

- Claim: Unreleased is not the first section after the title. Seven numbered patch sections sit above it. Two older numbered sections sit below it.
- Evidence: The first `##` after the title is `## 0.1.8 - 2026-09-17`. The next heading after the Unreleased body is `## 0.1.1 - 2026-09-10`.
- Source: `CHANGELOG.md:3`, `CHANGELOG.md:31`, `CHANGELOG.md:40`

- Claim: Numbered headings use the shape two hashes, a space, a three-part version, a space, a hyphen, a space, and a `YYYY-MM-DD` date. The Unreleased heading is only `## Unreleased`.
- Evidence: Compare `## 0.1.8 - 2026-09-17` with `## Unreleased`.
- Source: `CHANGELOG.md:3`, `CHANGELOG.md:31`

### Unreleased bullets wrap; the numbered patch bullets above them do not

- Claim: Each of `0.1.8` through `0.1.2` has exactly one single-line bullet `- Automated patch release from main.`
- Evidence: That exact line appears once under each of those seven headings, with a blank line after the heading and a blank line after the bullet.
- Source: `CHANGELOG.md:5`, `CHANGELOG.md:9`, `CHANGELOG.md:13`, `CHANGELOG.md:17`, `CHANGELOG.md:21`, `CHANGELOG.md:25`, `CHANGELOG.md:29`

- Claim: The Unreleased section has three recorded bullets. Each starts with hyphen-space on its own line and continues on the next line indented by two spaces. There is no blank line between those three items.
- Evidence: First item starts on line 33 and wraps on line 34. Second item starts on line 35 and wraps on line 36. Third item starts on line 37 and wraps on line 38. Line 32 is blank after the heading. Line 39 is blank before the next heading.
- Source: `CHANGELOG.md:31-39`

- Claim: A wrap line is not itself a new bullet. The three continuation lines begin with two spaces and a lowercase word, not with hyphen-space.
- Evidence: Line 34 is `  observation, bounded application receipts, and native Chrome publication.` Line 36 is `  domain service instances.` Line 38 is `  behavior.`
- Source: `CHANGELOG.md:34`, `CHANGELOG.md:36`, `CHANGELOG.md:38`

- Claim: The two older numbered sections below Unreleased use single-line bullets only. `0.1.1` has one bullet. `0.1.0` has four consecutive single-line bullets with no wrap.
- Evidence: Line 42 is one hyphen-space sentence. Lines 46 through 49 are four hyphen-space sentences, each on one line.
- Source: `CHANGELOG.md:40-49`

### No bump-patch fixture changelog contains an Unreleased heading

- Claim: A search of `tools/fixtures/bump-patch-version/` for `Unreleased` or `unreleased` returns no matches.
- Evidence: Repository search over that tree for both strings is empty.
- Source: `tools/fixtures/bump-patch-version/` (search consulted 2026-09-25)

- Claim: Every fixture changelog under that tree starts with a title or a reject title, then one or two dated `##` version headings, and never an Unreleased heading.
- Evidence: `valid-patch` has `# Changelog` then `## 0.1.1` and `## 0.1.0`. `valid-leading-blank` has a leading blank, `# Changelog`, then `## 2.4.9`. `valid-minor-untouched` has `# Changelog` then `## 1.2.3`. `occupied-chosen-heading` has `## 0.1.3` then `## 0.1.1`. `occupied-intermediate-heading` has `## 0.1.2` then `## 0.1.1`. `reject-changelog-ahead` has `## 0.1.2` then `## 0.1.1`. `reject-prerelease` has `## 0.1.1-dev.1`. `reject-two-components` has `## 0.1`. `reject-no-changelog-title` has `## Release Notes` then `## 0.1.1`.
- Source: `tools/fixtures/bump-patch-version/valid-patch/CHANGELOG.md:1-9`, `tools/fixtures/bump-patch-version/valid-leading-blank/CHANGELOG.md:1-5`, `tools/fixtures/bump-patch-version/valid-minor-untouched/CHANGELOG.md:1-5`, `tools/fixtures/bump-patch-version/occupied-chosen-heading/CHANGELOG.md:1-9`, `tools/fixtures/bump-patch-version/occupied-intermediate-heading/CHANGELOG.md:1-9`, `tools/fixtures/bump-patch-version/reject-changelog-ahead/CHANGELOG.md:1-9`, `tools/fixtures/bump-patch-version/reject-prerelease/CHANGELOG.md:1-5`, `tools/fixtures/bump-patch-version/reject-two-components/CHANGELOG.md:1-5`, `tools/fixtures/bump-patch-version/reject-no-changelog-title/CHANGELOG.md:1-5`

- Claim: Fixture bullets under those version headings are single-line. None wrap onto a continuation line.
- Evidence: Each fixture body line that is not a heading or blank starts with hyphen-space and ends on that same line.
- Source: `tools/fixtures/bump-patch-version/valid-patch/CHANGELOG.md:5`, `tools/fixtures/bump-patch-version/valid-patch/CHANGELOG.md:9`, `tools/fixtures/bump-patch-version/valid-leading-blank/CHANGELOG.md:5`, `tools/fixtures/bump-patch-version/valid-minor-untouched/CHANGELOG.md:5`, `tools/fixtures/bump-patch-version/occupied-chosen-heading/CHANGELOG.md:5`, `tools/fixtures/bump-patch-version/occupied-chosen-heading/CHANGELOG.md:9`, `tools/fixtures/bump-patch-version/occupied-intermediate-heading/CHANGELOG.md:5`, `tools/fixtures/bump-patch-version/occupied-intermediate-heading/CHANGELOG.md:9`, `tools/fixtures/bump-patch-version/reject-changelog-ahead/CHANGELOG.md:5`, `tools/fixtures/bump-patch-version/reject-changelog-ahead/CHANGELOG.md:9`, `tools/fixtures/bump-patch-version/reject-prerelease/CHANGELOG.md:5`, `tools/fixtures/bump-patch-version/reject-two-components/CHANGELOG.md:5`, `tools/fixtures/bump-patch-version/reject-no-changelog-title/CHANGELOG.md:5`

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Hyphen-start scan between `## Unreleased` and the next `##` heading | Missing heading means no Unreleased. A recorded bullet is any line whose first two characters are hyphen then space. Continuation lines that start with spaces do not count as extra bullets. Zero hyphen-start lines means empty. | Cheap. Matches the live three-item Unreleased block: lines 33, 35, and 37 count; lines 34, 36, and 38 do not. | Chosen for the emptiness test. It treats the live wrapped notes as three bullets, and it treats a heading-only or blank-only Unreleased as empty. |
| Any-non-blank-line scan between `## Unreleased` and the next `##` heading | Missing heading means no Unreleased. Any non-blank line in that span means "has content", including wrap lines and prose that is not a list item. | Same cheap scan. On today's file it also reports content, because wrap lines 34, 36, and 38 are non-blank. | Rejected as the sole test. A leftover indented sentence with no hyphen-start would look like recorded notes. It also cannot count bullets: the live section would look like six content lines, not three items. |
| Group each hyphen-start line with the indented wrap lines that follow it | Same interval as the hyphen-start scan, but each item is the start line plus following lines that begin with whitespace and do not begin a new hyphen-space item or a new heading. | Slightly more logic. Needed if promotion must copy wrap text intact rather than flatten it. | Chosen as the copy-unit once "has bullets" is true. The live notes are three wrapped items, not six independent lines. Not chosen as the emptiness test, because emptiness only needs the hyphen-start count. |

## Constraints discovered

- Product decision already made: if Unreleased has recorded bullets, those bullets become the new version's notes and leave Unreleased; if Unreleased is missing or has no bullets, the helper keeps the exact bullet `- Automated patch release from main.`; already numbered version sections are not rewritten. Source: user direction for this work item, recorded 2026-09-25.
- Unreleased is not the top-most section. A detector that only inspects the first `##` after the title would miss the live block. Source: `CHANGELOG.md:3`, `CHANGELOG.md:31`
- Numbered headings carry a date suffix; Unreleased does not. A matcher that requires `## <token> - <date>` would miss Unreleased. Source: `CHANGELOG.md:3`, `CHANGELOG.md:31`
- Live Unreleased bullets wrap with a two-space indent. A detector that requires the whole item on one line, or that treats every non-blank line as a new bullet, mis-counts the live section. Source: `CHANGELOG.md:33-38`
- No current bump-patch fixture has an Unreleased heading, an empty Unreleased section, or a wrapped bullet. New fixtures are required before a test can lock promotion, emptiness, or wrap-preserving copy. Source: `tools/fixtures/bump-patch-version/valid-patch/CHANGELOG.md:1-9` and the empty search under `tools/fixtures/bump-patch-version/`
- The live file has no example of a missing Unreleased section and no example of an Unreleased heading with zero bullets. Those shapes exist only as absences in fixtures and as [UNVERIFIED] future inputs. Source: `CHANGELOG.md:31-39`, `tools/fixtures/bump-patch-version/valid-patch/CHANGELOG.md:1-9`

## Unresolved

- [UNRESOLVED: After bullets leave Unreleased, does the `## Unreleased` heading stay in its current mid-file position as an empty section, get deleted, or move above the numbered versions?]
- [UNRESOLVED: Does the heading matcher accept only the exact line `## Unreleased`, or also a dated form such as `## Unreleased - 2026-09-25`, or a Keep-a-Changelog bracket form such as `## [Unreleased]`? No such variants exist in the consulted files.]
- [UNRESOLVED: If Unreleased contains only `###` subsection headings and no hyphen-space bullets, is that "has bullets" or empty? The live file has no `###` headings.]
- [UNRESOLVED: If a line under Unreleased is indented but has no preceding hyphen-space start in that section, does it count as a recorded bullet? The live wrap lines all belong to a preceding hyphen-space start.]
- [UNRESOLVED: Must promotion copy wrap lines and their two-space indent unchanged, or may it flatten each item onto one line?]
- [UNRESOLVED: Which new fixture shapes are required to lock the decided branches: Unreleased with wrapped bullets, Unreleased heading with no bullets, and changelog with no Unreleased heading?]

## Sources

- `CHANGELOG.md`, consulted 2026-09-25
- `tools/fixtures/bump-patch-version/valid-patch/CHANGELOG.md`, consulted 2026-09-25
- `tools/fixtures/bump-patch-version/valid-leading-blank/CHANGELOG.md`, consulted 2026-09-25
- `tools/fixtures/bump-patch-version/valid-minor-untouched/CHANGELOG.md`, consulted 2026-09-25
- `tools/fixtures/bump-patch-version/occupied-chosen-heading/CHANGELOG.md`, consulted 2026-09-25
- `tools/fixtures/bump-patch-version/occupied-intermediate-heading/CHANGELOG.md`, consulted 2026-09-25
- `tools/fixtures/bump-patch-version/reject-changelog-ahead/CHANGELOG.md`, consulted 2026-09-25
- `tools/fixtures/bump-patch-version/reject-prerelease/CHANGELOG.md`, consulted 2026-09-25
- `tools/fixtures/bump-patch-version/reject-two-components/CHANGELOG.md`, consulted 2026-09-25
- `tools/fixtures/bump-patch-version/reject-no-changelog-title/CHANGELOG.md`, consulted 2026-09-25
