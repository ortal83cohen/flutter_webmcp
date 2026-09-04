---
id: adr-0002-share-agent-config-between-claude-code-and-cursor
title: "ADR 0002: Share agent configuration between Claude Code and Cursor"
status: active
owner: unassigned
last_verified: 2026-09-04
applies_to: ["AGENTS.md", "CLAUDE.md", ".claude/**", ".cursor/**"]
summary: AGENTS.md is the single always-on instruction source; skills and subagents live in .claude/, which both tools read; only path-scoped rules are duplicated.
---

# ADR 0002: Share agent configuration between Claude Code and Cursor

- Status: accepted
- Date: 2026-09-04
- Deciders: project setup

## Context and problem statement

The project must be workable in both Claude Code and Cursor. The two tools overlap heavily but not completely in which configuration files they read. Where should each kind of instruction live so that a rule is written once and honoured by both, without the same text entering an agent's context twice?

## Decision drivers

1. One rule, one file. A rule written twice will diverge.
2. No content loaded twice into the same context.
3. Nothing critical may depend on a setting a user might have switched off.
4. Portable across operating systems, including Windows checkouts.

## Considered options

**A. Duplicate everything.** A full `.claude/` tree and a full `.cursor/` tree. Guaranteed to work in both, guaranteed to diverge within weeks.

**B. Generator script.** One source of truth, a script that emits the tool-specific files. Adds a build step and a stale-artifact failure mode: the generated file is what the tool actually reads, and it will at some point be out of date.

**C. Symlink `CLAUDE.md` to `AGENTS.md`.** Works on macOS and Linux. On a Windows checkout without developer mode the link is checked out as a text file containing a path, which silently loads nothing.

**D. Rely on each tool's native cross-reading, and duplicate only what has no shared location.** Chosen.

## Decision outcome

Option D. The layout:

| Content | Location | Read by |
|---|---|---|
| Always-on instructions | `AGENTS.md` | Cursor natively; Claude Code through the `@AGENTS.md` import in `CLAUDE.md` |
| Claude-only notes | `CLAUDE.md`, below the import | Claude Code |
| Skills | `.claude/skills/<name>/SKILL.md` | both tools natively |
| Subagents | `.claude/agents/<name>.md` | both tools natively |
| Path-scoped rules | `.claude/rules/*.md` and `.cursor/rules/*.mdc` | one each — this is the only duplication |
| Enforcement hooks | `.claude/settings.json` | Claude Code; Cursor can also read it, subject to a user setting |

Claude Code reads `CLAUDE.md`, not `AGENTS.md`; the documented bridge is an `@AGENTS.md` import, which also allows Claude-specific content to be appended below it. Cursor reads `AGENTS.md` and `CLAUDE.md` both, and both are always applied, so `CLAUDE.md` is kept to the import plus a handful of Claude-only lines — anything longer would enter a Cursor context twice.

Path-scoped rules are the one genuine duplication. Claude Code scopes rules by a `paths` frontmatter field in `.claude/rules/*.md`; Cursor scopes them by a `globs` field in `.cursor/rules/*.mdc` and does not read `.claude/rules/`. Neither tool reads the other's format. The pair must be changed together, which is stated in `CLAUDE.md` and checked by lint.

Two facts constrain what may be placed where. Cursor's reading of `.claude/` is gated behind a user setting for third-party configuration, so nothing whose absence would break the workflow lives only there — the pipeline is defined in `AGENTS.md` and the wiki, which Cursor reads regardless. And Cursor does not read `.claude/commands/`, so every invocable workflow is written as a skill, never as a command.

## Consequences

- Positive: no generator, no build step, no symlink, no Windows caveat. Every file is a real file that both tools read directly.
- Positive: a skill or subagent is authored once and available in both tools.
- Negative: path-scoped rules exist twice. Mitigated by keeping them few and short, and by a lint check that the two directories hold matching rule names.
- Negative: the layout depends on documented cross-reading behaviour that either vendor could change. Mitigated by the fact that the load-bearing content — `AGENTS.md` and the wiki — is read by both tools through their own primary mechanism, not through a compatibility path.
- Negative: a Cursor user with third-party configuration disabled loses the skills and subagents. They keep the instructions, the wiki and the workflow definition, so the process still holds; only the automation is lost.

## Confirmation

- `tools/lint_wiki.py` fails when `.claude/rules/` and `.cursor/rules/` hold different rule name sets, and when `CLAUDE.md` does not begin with the `@AGENTS.md` import.
- The linter also fails when a file exists under `.claude/commands/` or `.cursor/commands/`, since a command would be invisible to one of the two tools.
- Setup instructions in `README.md` name the Cursor setting that must be enabled, so a missing capability is diagnosable rather than mysterious.

## Pros and cons of the options

- A: works everywhere, diverges immediately.
- B: single source, adds a stale generated artifact between the source and the tool.
- C: elegant on Unix, silently broken on Windows.
- D: no build step, one duplication, depends on documented vendor behaviour.

## More information

- `README.md` — setup, including the Cursor setting.
- `AGENTS.md` — the instructions themselves.
