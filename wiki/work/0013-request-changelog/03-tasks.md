# Tasks: Request-based release changelog

## Legend

All implementation tasks are unchecked: the current authorization is planning only. Each row has one exclusive owner; shared-file changes go through that owner. New paths below are proposed implementation targets, not claims that those files already exist. Groups execute sequentially; no parallel editing is planned.

## Groups

### Group 1 — Contracts and capture

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 1.1 | [ ] Workflow owner: define capture, route, cutover and readiness contracts; capture this implementation request at implementation start | AC-001–005, AC-020 | AGENTS.md; wiki/conventions/workflow.md; wiki/conventions/definition-of-done.md; wiki/templates/STATE.yaml; .claude/skills/build/SKILL.md; .claude/skills/feature/SKILL.md; .claude/skills/quick-change/SKILL.md; .changes/policy.json; implementation request JSON and linked state | No | Entry points and explicit legacy baseline agree; no historical backfill required. |
| 1.2 | [ ] Tooling owner: implement schema, capture/lifecycle, lint, renderer, candidate journal and recovery primitives with tests | AC-002–014, AC-019 | tools/request_changelog.py; tools/test_request_changelog.py; tools/fixtures/request-changelog/; tools/lint_wiki.py; tools/bump_patch_version.sh; tools/test_bump_patch_version.sh; tools/fixtures/bump-patch-version/ | No | Positive and negative fixtures cover every local boundary and full-record immutability. |

### Group 2 — Release integration and migration

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 2.1 | [ ] Release owner: wire candidate/recovery/publication/confirmation state transitions and invoke tests | AC-006–015, AC-017–019 | .github/workflows/release.yml; .github/workflows/publish.yml; tools/check.sh; .pubignore; tools/test_request_release_integration.py | No | Temporary remotes and simulated registry prove retries and races; activation remains disabled pending external gates. |
| 2.2 | [ ] Migration owner: preserve legacy text, collect dispositions, inspect root payload | AC-016–018 | .changes/legacy-disposition.json; CHANGELOG.md; wiki/work/0013-request-changelog/migration-evidence.md | No | Unresolved facts remain explicit blockers; no numbered history edits or unauthorized publication. |

### Group 3 — Verify and document

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 3.1 | [ ] Verification owner: run full suite and obtain blind implementation verdict; record external activation proof separately | AC-001–020 | wiki/work/0013-request-changelog/verification.md; wiki/work/0013-request-changelog/activation-evidence.md; next append-only implementation validation report | No | Actual command outputs and criterion results exist; no failed or partial gate is labelled complete. |
| 3.2 | [ ] Documentation owner: publish operator recovery, capture and rollback guidance and ADR | AC-001, AC-003–005, AC-011–018, AC-020 | wiki/product/release-pipeline.md; wiki/INDEX.md; next available numbered ADR | No | Instructions match implemented behavior and distinguish reservation, confirmation, simulations and live proof. |

## Serialised files

| File | Owning task |
|---|---|
| tools/request_changelog.py and tools/lint_wiki.py | 1.2; integration requests changes from that owner |
| .github/workflows/release.yml and .github/workflows/publish.yml | 2.1 |
| CHANGELOG.md | 2.2 during migration; generated release edits only after activation |
| wiki/INDEX.md | 3.2 |

## Test tasks

| # | Covers | Positive case | Negative case |
|---|---|---|---|
| 1.1 | AC-001, AC-003–005 | Direct/forwarded capture, quick promotion, legacy exemption | Missing capture, duplicate ID, new unlinked work |
| 1.2 | AC-002–014, AC-019 | Valid records, deterministic candidate and same-version recovery | Malformed/orphan/empty notes, immutable mutation, every injected write failure |
| 2.1 | AC-006–015, AC-017–019 | No-op, branch/tag repair, remote proof reconciliation | Stale push, conflicting tag/archive, lost confirmation, metadata leak |
| 2.2 | AC-016–018 | Evidence-backed legacy dispositions and clean payload | Unknown history, populated Unreleased, nested version mutation |
| 3.1 | AC-001–020 | Full suite and independent evidence | Failed check or unproved external gate prevents completion |
| 3.2 | AC-020 | Evidence-preserving disabled automation | Generic release fallback or overstated CI coverage |

## Scope amendment — 2026-09-11

All tasks remain unchecked. Task 1.1 must document that internal/docs/maintenance requests contribute release notes once ready. Task 1.2 must require a sanitized meaningful note for every request and select all ready unreserved records without a visibility filter. Task 2.1 must test internal-only releases, mixed batches and true empty-eligible-set no-ops against the superseding AC-006 and AC-007 rows. Tasks 3.1 and 3.2 must verify and document this final contract. Ownership and all other criteria remain unchanged.
