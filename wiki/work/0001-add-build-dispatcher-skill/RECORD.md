---
id: work-0001-add-build-dispatcher-skill
title: "Add /build dispatcher skill that auto-routes to quick-change or feature"
status: active
owner: ortal.cohen@enpal.de
last_verified: 2026-09-04
applies_to: [".claude/skills/build/**"]
summary: Quick-change record for adding the /build entry-point skill.
---

# Add /build dispatcher skill

## What changed and why

The project already has `/quick-change` and `/feature` as the two execution routes, but a user still had to decide which one to invoke. Added `.claude/skills/build/SKILL.md`: a thin dispatcher that takes a goal, feature request, or pointer to more information, applies the existing five quick-route qualifiers from `wiki/conventions/workflow.md` itself, and invokes `quick-change` or `feature` accordingly. It duplicates no pipeline logic - it only makes the existing routing decision on the user's behalf and hands off.

## File touched

`.claude/skills/build/SKILL.md` (new file).

## Five qualifying conditions

1. One file changed - yes, only the new skill file.
2. No new dependency - yes, it only invokes the two existing skills via the `Skill` tool.
3. No change to a public interface, exported symbol, route, or schema - yes, it adds a new optional entry point without changing `quick-change` or `feature` themselves.
4. No change to a data model, migration, or stored data - yes, no data model involved.
5. No security, privacy, authentication, authorisation, or payment surface touched - yes, none touched.

## Test that covers it

No automated test suite exists yet for skill routing behavior (agent-driven, not code). Verification instead: read `.claude/skills/build/SKILL.md` back and confirmed its qualifiers text matches `wiki/conventions/workflow.md` verbatim, and that its Step 3 names both target skills (`quick-change`, `feature`) correctly by their registered names.

## Check output

```
$ python3 tools/lint_wiki.py
warning: wiki/work/0001-add-build-dispatcher-skill: no 01-plan.md yet.
lint_wiki: clean (1 warning(s)).
```

The warning is expected for the quick route, which has no plan artifact.
