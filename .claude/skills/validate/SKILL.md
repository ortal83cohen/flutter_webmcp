---
name: validate
description: Runs a validation round - spawns blind adversarial validators against an artifact and its criteria, then routes the verdict back to the phase the defect belongs to.
when_to_use: Use to validate research, a plan, or an implementation for an existing work item, or when the user asks to review or check a phase before proceeding. Invoked automatically by the feature pipeline.
argument-hint: "[work-item-id] [research|plan|impl]"
arguments: [item, phase]
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Agent, AskUserQuestion
---

# Validation round

Work item: `$item` — phase: `$phase`

Read `wiki/conventions/validation-rubrics.md`. It is the authority on verdicts, severities and evidence; this skill is the procedure for running a round.

## Before spawning

Read `STATE.yaml`. Note the current `round`. The report you are about to create is round `round + 1`, and it is a new numbered file — never an overwrite.

If `round` is already 3, do not run another round. For a plan phase, discard the plan and restart it from scratch. For an implementation phase, return to the plan phase. Three failed reviews mean the artifact is wrong in a way a fourth review will not locate.

## Spawn

For `$phase` of `research` or `plan`, spawn `research-validator` and `plan-validator` in a single message so they run concurrently. For `impl`, spawn one `impl-validator`.

Each prompt passes only: the artifact or diff, the acceptance criteria, and the output path for its report.

It must not pass the author's summary, reasoning, transcript, self-assessment, or any claim that a previous finding was fixed. A validator that can see the argument reviews the argument instead of the artifact, and that is precisely the failure this blindness prevents.

## Read the verdict

- `PASS` — proceed to the next phase.
- `CONDITIONAL` — close every blocker, then run the next numbered round. Do not proceed on the strength of the blockers being closed; the next round confirms it.
- `FAIL` — act on the report's routing table. A research defect goes to the research phase, a plan defect to the plan phase, an implementation defect to the implement phase. Never close a plan-level finding by changing code; that buries the defect rather than fixing it.

Do not accept a claim that a finding was fixed. Re-run the check that found it.

## Decide and record

For each finding, decide whether it changes the plan or merely annotates it. Both are decisions. Record each in `STATE.yaml` under `decisions` with the round, the verdict, the action taken, and the reason.

Increment `round`. Set `verdict`. Move open blockers into `blockers` with their source report and severity.

## Oscillation

Read the report's recurrence check. If a finding is materially identical to one from the previous round, the loop is not converging — it is oscillating. Stop. Escalate to the user with the specific question the loop cannot settle, and record the escalation in `STATE.yaml`. Do not open another round.

## Report

Two or three lines: the verdict, the blocker count, and the phase you are routing to next. Name the report path; do not paste it.
