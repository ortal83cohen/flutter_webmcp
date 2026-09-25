# Tasks: Promote Unreleased changelog notes into the deployed version

## Legend

- `[P]` — may run in a parallel subagent. Only mark a task `[P]` if no other `[P]` task in the same group touches any of the same files.
- Every task cites the criteria it satisfies. A task satisfying no criterion does not belong here.
- Owned files are exclusive. Two tasks never list the same file.

## Groups

### Group 1 — Helper, fixtures, and tests

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 1.1 | Add the fixtures named in plan step 2, including one directory per lookalike and an orphan-only span. | AC-001–AC-019 | `tools/fixtures/bump-patch-version/` new directories only | | ✓ Complete: nine new fixture directories; existing fixture files unchanged |
| 1.2 | Teach the bump helper to promote populated Unreleased notes and to keep the automated sentence otherwise, including the duplicate-heading failure. | AC-001–AC-019 | `tools/bump_patch_version.sh` | | ✓ Complete: helper matches the plan interfaces |
| 1.3 | Extend the bump test script for every new fixture while keeping existing cases. | AC-001–AC-019 | `tools/test_bump_patch_version.sh` | | ✓ Complete: `sh tools/test_bump_patch_version.sh` exits zero |

## Serialised files

| File | Owning task |
|---|---|
| `tools/bump_patch_version.sh` | 1.2 |
| `tools/test_bump_patch_version.sh` | 1.3 |

## Test tasks

Tests are written in task 1.3 by the same agent that writes the helper in task 1.2. One implementer owns the whole group because the helper and its tests describe one behavior.
