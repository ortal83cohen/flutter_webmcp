---
id: adr-0001-use-a-phased-agent-pipeline
title: "ADR 0001: Use a six-phase pipeline with blind adversarial validation"
status: active
owner: unassigned
last_verified: 2026-09-04
applies_to: ["**"]
summary: Changes flow through research, plan, validate, implement, verify, document, with validators that never see the author's reasoning.
---

# ADR 0001: Use a six-phase pipeline with blind adversarial validation

- Status: accepted
- Date: 2026-09-04
- Deciders: project setup

## Context and problem statement

An agent asked to build a feature end to end in one pass produces work whose defects are discovered late, when they are expensive, and whose correctness rests on the agent's own assessment of it. How should work be structured so that defects surface early and correctness is established by something other than the author's opinion?

## Decision drivers

1. Defects must surface at the cheapest possible phase.
2. Correctness must be established by evidence a third party can check, not by the author's claim.
3. Ceremony must scale down for small changes, or it will be bypassed for all changes.
4. Documentation must not lag the code.
5. Token cost must be proportionate to the leverage of each phase.

## Considered options

**A. One agent, one pass, self-review at the end.** Cheapest. Measured lift from self-review is close to zero for strong models and negative when the reviewer is weaker than the author. Defects surface at the end, where they are most expensive.

**B. Role-split pipeline with a separate agent per phase and full context handoff.** Each phase gets a specialist. Reported failure mode: agents spend more tokens coordinating than working, and handing the author's reasoning to the reviewer causes the reviewer to review the argument rather than the artifact.

**C. Phased pipeline with blind validation and frozen criteria.** Phases separate research from planning from implementation. Acceptance criteria are frozen before code exists, and validators see only the criteria and the artifact. Chosen.

**D. Heavyweight spec-driven framework with mandatory gates for every change.** Every framework in this family that shipped without a small-change escape hatch was later forced to add one, and several removed their own gate commands entirely once the host tool's planning mode matured.

## Decision outcome

Option C, with two amendments learned from option D's history:

- A `quick-change` route exists from day one for single-file changes with no interface, dependency or data-model impact. The escape hatch is not retrofitted after the first complaint.
- The independence boundary is placed between the criteria and the implementation, not between the code and its tests. One agent writes code and tests together; what makes the verification independent is that the criteria were frozen before any code existed.

## Consequences

- Positive: defects that would surface during implementation surface during plan validation, where the fix is a paragraph. Verification rests on pasted command output and per-criterion verdicts. Documentation ships in the same commit as the code.
- Positive: token spend concentrates where leverage is highest — planning and reviewing get the strongest model, mechanical work gets the cheapest.
- Negative: a full-route change costs several times a single-pass change in tokens and wall-clock time. Mitigated by the quick route, and by the fact that a defect found in phase 5 costs more than the whole of phase 3.
- Negative: the pipeline can be gamed by an agent that files artifacts without doing the thinking. Mitigated by the evidence rules — pasted output, file-and-line citations, per-criterion verdicts — and by lint.
- Negative: a validation loop can oscillate. Mitigated by a three-round cap, a recurrence check, and escalation instead of a fourth round.

## Confirmation

- `tools/lint_wiki.py` fails when `01-plan.md` contains a fenced code block, when a validation round overwrites an earlier one, when a work item's `STATE.yaml` is missing or malformed, and when a wiki document is unreachable from `wiki/INDEX.md`.
- A `.claude/settings.json` hook runs the linter after any write under `wiki/work/`, so the rule is enforced during the session rather than remembered across it.
- The `definition-of-done.md` checklist is a required section of the implementation review; a review missing per-criterion verdicts is itself invalid.

## Pros and cons of the options

- A: cheapest, least reliable, defects surface last.
- B: strong separation, poor economics, reviewer reviews the reasoning.
- C: good economics, real independence, needs discipline enforced by lint.
- D: strongest process, worst fit for small changes, historically retreated from.

## More information

- `wiki/conventions/workflow.md` — the pipeline itself.
- `wiki/conventions/validation-rubrics.md` — the validator contract.
- `wiki/conventions/model-routing.md` — where the token budget goes.
