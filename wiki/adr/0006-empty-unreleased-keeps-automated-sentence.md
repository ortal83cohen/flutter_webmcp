---
id: adr-0006-empty-unreleased-keeps-automated-sentence
title: "ADR 0006: Keep the automated patch sentence when Unreleased is empty"
status: active
owner: unassigned
last_verified: 2026-09-25
applies_to: ["tools/bump_patch_version.sh", "CHANGELOG.md"]
summary: A deploy with no hyphen-space Unreleased bullets still writes the automated patch sentence rather than failing or waiting for work item 0013.
---

# ADR 0006: Keep the automated patch sentence when Unreleased is empty

- Status: accepted
- Date: 2026-09-25
- Deciders: ortal.cohen@enpal.de

## Context and problem statement

When a main-branch deploy writes a new dated changelog section, should a missing or empty Unreleased span fail the bump, wait for another note source, or still record a version note?

## Decision drivers

1. A deploy with no written notes must still produce a version.
2. Frozen work-item 0009 fixtures that have no Unreleased heading must keep the automated sentence.
3. Numbered changelog sections already in the file must stay byte-identical.
4. Work item 0013 must not become a release gate before it has a renderer.

## Considered options

**A. Fail the bump when Unreleased is missing or has no hyphen-space bullet.** Forces notes on every release. Blocks every main-branch deploy that has no Unreleased items, including the 0009 fixtures that still require the automated sentence.

**B. Wait for work item 0013 request records to become the note source.** 0013 is plan-only and has no renderer and no disposition ledger. Waiting would stop releases until that work exists.

**C. Promote populated Unreleased bullets; keep the automated sentence when the heading is missing or the span has no hyphen-space bullet.** Chosen. Releases never block on missing notes. A populated span still publishes those notes.

## Decision outcome

A missing `## Unreleased` heading, or a single such heading whose span has no hyphen-space bullet, still writes `- Automated patch release from main.` under the new dated heading. A populated span is copied instead. Two exact Unreleased headings fail and write neither file. Work item 0013 stays plan-only and is not the live note source.

## Consequences

- Positive: Main-branch deploys keep shipping when nobody wrote Unreleased notes.
- Positive: The 0009 no-Unreleased fixtures stay valid without editing that frozen criteria file.
- Negative: A note-less deploy still publishes the generic sentence, so empty Unreleased cannot be used as a release brake.
- Negative: When 0013 is later implemented, the live note source may need a new decision.

## Confirmation

`sh tools/test_bump_patch_version.sh` must exit zero. Cases with no Unreleased heading or an empty Unreleased span must still write the automated sentence. Populated fixtures must write those bullets instead. A two-heading fixture must fail and leave both files unwritten. A FAIL from that script is a violation of this decision.

## Pros and cons of the options

### Fail when Unreleased is empty

- Pros: Every published version would carry author-written notes.
- Cons: Blocks deploys that have no notes; breaks the 0009 fixtures that require the automated sentence.

### Wait for work item 0013

- Pros: One later owner for version notes.
- Cons: No renderer exists; releases would wait on unimplemented work.

### Promote when populated, keep the automated sentence when empty

- Pros: Releases continue; populated notes ship; 0009 fixtures stay green.
- Cons: Empty Unreleased still publishes a generic sentence; 0013 may later replace this source.

## More information

- [Work item 0017](../work/0017-promote-unreleased-on-deploy/00-research.md)
- [Release pipeline](../product/release-pipeline.md)
- [Work item 0013 state](../work/0013-request-changelog/STATE.yaml)
