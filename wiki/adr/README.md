---
id: adr-readme
title: Architecture decision records
status: active
owner: unassigned
last_verified: 2026-09-10
applies_to: ["**"]
summary: Why this project is shaped the way it is, one decision per file, never deleted.
---

# Architecture decision records

An ADR records a decision that was genuinely a choice between viable options, at the moment it was made, with the reasoning that was actually available then.

## When to write one

Write an ADR when a decision:

- forecloses an option that a future contributor would otherwise reasonably take;
- would be re-litigated by someone who does not know why it was settled;
- trades one property for another — speed for clarity, flexibility for simplicity, cost for control.

Do not write one for a decision with only one viable option. That is documentation, and it belongs in `wiki/product/`.

## Rules

- File name: `NNNN-kebab-title.md`. Four digits, sequential, never reused.
- Copy `../templates/adr.md`. Fill every section, including `## Confirmation`.
- An accepted ADR is never edited for content and never deleted. To change the decision, write a new ADR and set `superseded_by` on the old one and `supersedes` on the new one.
- Add the new file to `wiki/INDEX.md` in the same commit.

## The Confirmation section

Every ADR states how compliance is verified and how a violation would be detected — a lint rule, a test, a CI check, a specific review question. An ADR without an enforcement mechanism decays into a suggestion within a quarter. "By review" is not an enforcement mechanism.

## Index

| ADR | Decision | Status |
|---|---|---|
| [0001](0001-use-a-phased-agent-pipeline.md) | Every change goes through a six-phase pipeline with blind adversarial validation | accepted |
| [0002](0002-share-agent-config-between-claude-code-and-cursor.md) | Instructions, skills and subagents live in one shared location read by both tools | accepted |
| [0003](0003-webmcp-detection-first-registry.md) | The initial WebMCP package uses a singleton registry and detection-only browser boundary | accepted |
