# Plan: Promote Unreleased changelog notes into the deployed version

## Goal

The next successful main-branch bump writes the notes that already sit under the Unreleased heading into the new dated version section, then leaves that heading in place with no list items. A bump whose changelog has no exact Unreleased heading, or whose Unreleased span has no hyphen-space list item, still records the same automated patch sentence the helper writes today. Numbered version sections are not rewritten. This work item does not itself perform that bump on the live changelog.

## Approach

The only writer is the existing POSIX bump helper at tools/bump_patch_version.sh. The release workflow already commits whatever that helper writes in CHANGELOG.md beside pubspec.yaml. Promotion therefore happens inside the helper's in-memory changelog rebuild, before the existing atomic move of both files. No new workflow step is added. The release workflow file is not edited.

The helper keeps today's insert-after-title shape: lines through the Changelog title stay, then one blank line, then the dated heading for the chosen version, then one blank line, then the new section body, then one blank line, then the previous remainder with its leading blank lines dropped. The change is how the body is chosen and how the remainder is derived.

Before the rebuild, the helper searches the current changelog for the exact Unreleased heading defined in the interfaces section. Zero matches means the body is the automated sentence and the remainder is today's remainder: the file after the title, with no Unreleased heading created. One match means the helper inspects the span from the line after that heading to the next exactly-two-hash heading, or to the end of the file if none follows. If that span contains no line that begins with hyphen then space, the body is the automated sentence, the Unreleased heading stays where it was, and nothing under it is removed. If the span contains one or more such lines, the body is those lines plus each immediately following wrap line, copied unchanged and in document order, and those same lines are omitted from the remainder so the heading remains with no list items. Two or more exact Unreleased headings is an error: non-zero exit, neither file written.

Existing bump fixtures have no Unreleased heading. Their tests keep requiring the automated sentence. New fixtures lock the empty, subsection-only, wrapped, mid-file, lookalike, and duplicate-heading branches. Frozen criteria of work item 0009 are not edited. Work item 0013 is not implemented.

## Why this approach

The research artifact chose promotion inside the bump helper because that helper already owns the new dated section and the release job already commits its changelog write. Work item 0009 put that edit in the helper so it is fixture-tested and the workflow stays a thin sequence of named steps.

A separate pre-step or a YAML stream-editor step was rejected: it would be a second writer on the same file, and the helper would still insert the automated sentence unless it also changed. Waiting for work item 0013 was rejected: that item is plan-only, has no renderer and no disposition ledger, and would block releases until those exist. This work item does not mark 0013 superseded and does not implement request records.

The 0009 plan said existing changelog content is never rewritten. This work item replaces that rule only for Unreleased list items and their wrap lines. Numbered version sections stay byte-for-byte. Published pub.dev versions are not rewritten; the live Unreleased block is promoted by the next real bump, not by this implementation.

## Steps

1. Extend tools/bump_patch_version.sh so the changelog rebuild applies the heading matcher, span, emptiness test, copy unit, leftover heading, and duplicate-heading error in the interfaces section, while keeping the existing helper contract for arguments, date, occupied-version skip, stdout, and fail-closed writes. The script remains POSIX shell and still performs no git operation and no network call. Complete when a reading of the script shows a single writer for the new section body, no Unreleased heading invented on the missing-heading path, and neither file written on a second exact Unreleased heading.

2. Add fixtures under tools/fixtures/bump-patch-version for a heading-only Unreleased span, a subsection-only Unreleased span, a mid-file Unreleased span with wrapped list items and numbered sections above and below, three separate lookalike headings that are not the exact Unreleased line (a dated suffix, a bracketed Keep-a-Changelog form, and a lower-case spelling), a changelog whose Unreleased span contains only an orphan whitespace-prefixed line, a changelog with two exact Unreleased headings, and a populated Unreleased span combined with an occupied plus-one version. Do not change the existing fixtures that have no Unreleased heading. Complete when each new directory holds a pubspec and a changelog that set up only that branch.

3. Extend tools/test_bump_patch_version.sh with cases for every new fixture, keeping every existing case, including valid-patch, valid-leading-blank, valid-minor-untouched, occupied-skip successes, and the current reject cases. Existing cases still unset the occupied-versions variable as they do today. Complete when the test script exits zero and reports PASS for every existing case and every new positive and negative case named in the criteria file.

4. Verify restraint without releasing. Confirm the live root changelog's numbered sections and its current Unreleased block are untouched, the top-level pubspec version equals the work-item base, no new three-component v-prefixed tag was created, the 0009 criteria file is byte-identical to the base, the release workflow file is byte-identical to the base, and no request-record tree from work item 0013 was added. Complete when those comparisons are recorded for the verify phase.

## Interfaces and shared decisions

Writer. tools/bump_patch_version.sh is the only production writer of the new version section. Do not add a workflow pre-step. Do not edit .github/workflows/release.yml. The commit prefix remains the word chore, then release in parentheses, then a colon, then a space, then the letter v. publish.yml and checks.yml are not edited.

Heading matcher. An Unreleased heading is a line whose entire content is two hashes, one space, and the word Unreleased, with no other characters, no trailing whitespace, and no date or bracket form. The match is case-sensitive. A line that adds a date suffix, wraps the word in brackets, uses a different capitalisation, or has trailing whitespace is not an Unreleased heading. The helper does not create an Unreleased heading when none exists.

Duplicate heading. Two or more lines that each equal that exact heading is an error. The helper exits non-zero, prints an English message to standard error that names Unreleased and states that more than one heading was found, prints nothing on standard output, and writes neither pubspec.yaml nor CHANGELOG.md.

Span. After exactly one Unreleased heading, the span is every following line until the next heading that uses exactly two hashes followed by a space, or until the end of the file. A heading that uses three or more hashes does not end the span. That next two-hash heading is not part of the span.

Emptiness. The span is empty when no line in it begins with hyphen then space. Missing Unreleased heading, heading with only blank lines, heading with only three-hash subsection headings, and heading with only whitespace-prefixed lines that are not hyphen-space list items, are all empty. Empty keeps the automated sentence: a hyphen, one space, and the sentence Automated patch release from main, closed with a full stop. Empty does not create an Unreleased heading. An existing Unreleased heading on an empty span stays on its original line.

Copy unit. When the span is populated, each line that begins with hyphen then space is a start line. A wrap line is a non-blank line that begins with whitespace, does not begin with hyphen then space, and follows immediately after that start line or after another wrap line of the same item. A blank line is not a wrap line and ends wrap attachment. A whitespace-prefixed line that has no immediately preceding start or wrap in the span is an orphan: it does not populate the section, is not copied, and is not removed. Copied lines are written under the new dated heading in document order, unchanged, including their leading whitespace. Blank lines that sat between items are not copied. The automated sentence is not written when any start line was copied.

Leftover Unreleased. After a successful copy, the helper omits those start lines and their wrap lines from the remainder. The exact Unreleased heading stays on its original line. Blank lines that were not start or wrap lines stay. The helper does not move the heading, does not delete it, and does not insert a replacement heading.

New section placement. The dated heading is still inserted immediately after the title, with the same heading shape and date rule as today, including the occupied-version skip choosing the version. Promotion does not depend on Unreleased being the first section. Numbered version sections, meaning each heading that names a three-component version and a date together with the lines until the next exactly-two-hash heading, stay byte-for-byte.

Helper contract unchanged except for the changelog body and remainder. Optional repository-root argument, RELEASE_DATE, OCCUPIED_VERSIONS, stdout on success is only the new version with no v prefix, any non-zero exit writes neither file, no git, no network. Existing reject paths remain.

Tests and frozen 0009 criteria. Existing fixtures with no Unreleased heading still receive the automated sentence. Do not edit wiki/work/0009-pubdev-publish-workflow/02-criteria.md. Occupied-skip fixtures that have no Unreleased heading keep their current heading assertions and still receive the automated sentence. New fixtures lock promotion.

Live tree restraint. Implementation does not rewrite already published numbered sections in the repository CHANGELOG.md, does not empty the live Unreleased block, does not bump the top-level pubspec version, and does not create a release tag. The next real main-branch bump promotes the live Unreleased block.

Work item 0013. Not implemented. No request-record module, no .changes tree, no disposition ledger, and no supersession of 0013.

## Risks

| Risk | Likelihood | Impact | Mitigation | Trigger that means it happened |
|---|---|---|---|---|
| Implementation rewrites the live changelog or empties live Unreleased during this work item | Medium | Published numbered text changes without a release, or notes are dropped before the next bump | Restraint step and criteria forbid editing the live numbered sections and the live Unreleased block | git diff of CHANGELOG.md against the work-item base is non-empty |
| Implementation edits the 0009 criteria file to relax the automated sentence | Medium | Frozen 0009 acceptance is silently changed | Criteria require that file to stay byte-identical to the base | git diff of that path against the base is non-empty |
| Implementation adds a workflow pre-step or edits release.yml | Medium | A second writer appears and the helper may still insert the automated sentence | This plan names the helper as the only writer and forbids a workflow edit | git diff of .github/workflows/release.yml against the base is non-empty |
| Wrap lines are flattened or dropped | Medium | Live three-item wrapped notes would lose their continuation text on the next bump | Fixtures include wrap lines and criteria require those lines unchanged in the new body | A populated wrap fixture's new section lacks a whitespace-prefixed continuation line that the fixture supplied |
| A three-hash subsection is treated as the end of the Unreleased span | Medium | Notes under a subsection would be left behind or the span would look empty | Span ends only at the next exactly-two-hash heading; a subsection-only fixture locks emptiness, and a hyphen-space line under a subsection locks promotion | A fixture with a three-hash heading and a hyphen-space line under it keeps the automated sentence |
| A second Unreleased heading is ignored and one file is written | Low | A malformed changelog would publish a half-applied bump | Duplicate heading fails closed before either move | A two-heading fixture exits zero or its checksums change |
| Work item 0013 later replaces this body source | Low for this change | Future collision on the same helper | Accepted and listed as unresolved in research; 0013 stays plan-only here | 0013 implementation starts and changes the helper's body source |

## Rollback

Revert the edits to tools/bump_patch_version.sh and tools/test_bump_patch_version.sh, and delete any fixtures added under tools/fixtures/bump-patch-version for this work item. That restores the helper that always writes the automated sentence and never reads Unreleased. No workflow rollback is required if release.yml was not edited. No data migration is required.

Any version a later bump publishes remains permanent on pub.dev. Rolling back this helper does not unpublish and does not restore Unreleased bullets already copied into a published section. Implementation of this work item must not itself publish, so rollback during implement-and-verify is a git revert of the helper, tests, and fixtures only.

## Out of scope

A workflow pre-step or any edit of release.yml, publish.yml, or checks.yml. Editing the frozen 0009 criteria file. Implementing work item 0013, request records, a disposition ledger, or superseding 0013. Rewriting already published numbered sections in the live CHANGELOG.md. Emptying or moving the live Unreleased block during this work item. Bumping the real package version or creating a release tag. Changing the release commit prefix. Keep-a-Changelog bracket headings, dated Unreleased headings, or case-insensitive heading match. Flattening wrap lines. Minor or major bumps. Conventional-commit interpretation.

## Verification approach

The helper is checked by running tools/test_bump_patch_version.sh with no network. Existing cases must still pass, including valid-patch and valid-leading-blank requiring the automated sentence, occupied-skip heading assertions, and current reject paths that leave both files byte-identical. New cases cover: no Unreleased heading, so the automated sentence is written and no Unreleased heading appears; an exact Unreleased heading with no hyphen-space line, so the automated sentence is written and the heading remains; a three-hash subsection with no hyphen-space line, so the span is empty; a mid-file Unreleased span with hyphen-space lines and wrap lines, so the new body equals those lines and the heading remains without them; each of the three lookalike headings, so the automated sentence is written and lines under that lookalike stay; an orphan-only Unreleased span, so the automated sentence is written and the orphan line stays under the heading; two exact Unreleased headings, so a non-zero exit and byte-identical files; and a populated Unreleased span with the plus-one version occupied, so the promoted body sits under the free version.

Restraint is checked with path-scoped diffs against the work-item base for the live CHANGELOG.md, the top-level pubspec version line, the 0009 criteria file, and .github/workflows/release.yml, and by listing three-component v-prefixed tags. The full check suite and the wiki lint are run. Each criterion's negative case is a run or a scratch comparison that must fail the positive assertion.
