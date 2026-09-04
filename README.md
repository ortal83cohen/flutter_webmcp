# Agent workflow scaffold

An empty repository preconfigured to take a product idea from research to shipped code through a repeatable agent pipeline. Works in both Claude Code and Cursor. No product code yet — that is the first thing you build.

## Start here

```
/bootstrap-product a tool that does X for Y
```

This runs once, on the empty repository. It picks a stack through the normal research-and-validation pipeline, sets up the toolchain and the check suite, wires the linter into CI, and records the founding decisions as ADRs.

After that, every change goes through one of two routes:

```
/feature       add or change anything non-trivial — the full six-phase pipeline
/quick-change  one file, no interface, dependency or data-model impact
```

Individual phases can be run on their own to resume an interrupted work item: `/research`, `/plan`, `/validate`, `/implement`, `/verify`, `/document`.

## The pipeline

Research → plan → validate → implement → verify → document.

Each phase writes one numbered artifact into `wiki/work/NNNN-slug/` and hands off through a gate. Validation is adversarial and blind: the validator sees the acceptance criteria and the artifact, never the author's reasoning. Acceptance criteria freeze before any code exists, which is what makes verification independent.

Loops are capped at three rounds with an oscillation check, because a fourth review does not find what three missed.

`wiki/conventions/workflow.md` is the full definition. `wiki/INDEX.md` is the router for everything else.

## Setup

**Claude Code** works with no configuration. `CLAUDE.md` imports `AGENTS.md`; skills, subagents, rules and hooks are read from `.claude/`.

**Cursor** reads `AGENTS.md` natively. To also pick up the skills and subagents in `.claude/`, enable **Cursor Settings → Rules, Skills, Subagents → include third-party plugins, skills and other configs**. Without it you keep the instructions, the wiki and the workflow definition — only the automation is lost.

**Python 3** is required for `tools/lint_wiki.py`, which enforces the conventions in-session and in CI. Nothing else is needed until a stack is chosen.

Verify the setup:

```
python3 tools/lint_wiki.py
```

## Layout

| Path | What it is |
|---|---|
| `AGENTS.md` | The single source of always-on agent instructions |
| `CLAUDE.md` | Imports `AGENTS.md`, plus a few Claude-only notes |
| `.claude/skills/` | The invocable workflow. Read by both tools |
| `.claude/agents/` | Subagent definitions with their model tiers. Read by both tools |
| `.claude/rules/`, `.cursor/rules/` | Path-scoped rules. The only content duplicated between the tools |
| `.claude/hooks/`, `.cursor/hooks/` | Enforcement that runs whether or not the agent remembers the rule |
| `wiki/conventions/` | Workflow, naming, validation rubrics, model routing, parallelism, definition of done |
| `wiki/templates/` | The artifact templates. Copy them; do not improvise |
| `wiki/adr/` | Architecture decision records. Never deleted, only superseded |
| `wiki/product/` | Product knowledge. Empty until the first feature ships |
| `wiki/work/` | One folder per change |
| `tools/lint_wiki.py` | Enforces all of the above |

## Why it is shaped this way

Three findings drove the design, and two of them are counter-intuitive:

**Prose overviews of a repository make agents worse.** They do not improve task success and they raise cost by more than a fifth — the agent reads the summary, then reads the source anyway. So `wiki/product/` explicitly excludes directory layouts, dependency lists and architecture narratives. Knowledge that triggers when relevant — a skill, a path-scoped rule — is where documentation pays.

**Instruction file structure barely matters; enforcement does.** Size, position and file count have no measurable effect on compliance. What does have an effect is decay across a long session. That is why the conventions are backed by a linter, a write hook, a stop hook and a CI job rather than by more carefully arranged prose.

**Self-review is worth roughly nothing, and a weak reviewer is worth less than none.** Hence blind validators on the strongest model tier, criteria frozen before implementation, and evidence rules that require pasted command output instead of a claim.

`wiki/adr/0001` and `wiki/adr/0002` record the decisions in full.
