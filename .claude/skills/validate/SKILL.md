---
name: validate
description: Runs a validation round - spawns blind adversarial validators against an artifact and its criteria, then the main agent decides what happens next.
when_to_use: Use to validate research, a plan, or an implementation for an existing work item, or when the user asks to review or check a phase before proceeding. Invoked automatically by the feature pipeline.
argument-hint: "[work-item-id] [research|plan|impl]"
arguments: [item, phase]
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Agent, AskUserQuestion
---

# Validation round

Work item: `$item` — phase: `$phase`

Read `wiki/conventions/validation-rubrics.md`. It is the authority on verdicts, severities and evidence; this skill is the procedure for running a round.

## Before spawning

Read `STATE.yaml`. This phase gets one validation round. If a round has already run for `$phase`, do not spawn another validator — read its report and act on it instead of re-validating.

## Spawn

For `$phase` of `research` or `plan`, spawn `research-validator` and `plan-validator` in a single message so they run concurrently. For `impl`, spawn one `impl-validator`.

Each prompt passes only: the artifact or diff, the acceptance criteria, and the output path for its report.

It must not pass the author's summary, reasoning, transcript, self-assessment, or any claim that a previous finding was fixed. A validator that can see the argument reviews the argument instead of the artifact, and that is precisely the failure this blindness prevents.

## Read the verdict, then decide

A validator reports findings; it does not decide what happens next. That call belongs to the main agent, using the report as evidence, not as a verdict to execute mechanically:

- `PASS` — proceed to the next phase.
- `CONDITIONAL` or `FAIL` — for each finding, decide: fix it directly, accept it as pre-existing or out of scope, or send it back to the phase that owns it (a research defect to the research phase, a plan defect to the plan phase, an implementation defect to the implement phase). Never close a plan-level finding by changing code; that buries the defect rather than fixing it.

Do not accept a claim that a finding was fixed without re-running the check that found it. If several findings together put the whole artifact in doubt, judge whether targeted fixes are enough or the phase needs a genuine rewrite — that is the main agent's call to make, not a rule that fires automatically.

## Decide and record

For each finding, record the decision in `STATE.yaml` under `decisions`: the verdict, the action taken, and the reason.

Set `verdict`. Move any finding you chose not to fix into `blockers`, with its source report and severity, so it stays visible.

## Report

Two or three lines: the verdict, the finding count, and what you decided to do about them. Name the report path; do not paste it.
