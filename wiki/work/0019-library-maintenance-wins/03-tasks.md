# Tasks: Tighten package publishing, tests, and onboarding docs

## Legend

- `[P]` — may run in a parallel subagent. Only mark a task `[P]` if no other `[P]` task in the same group touches any of the same files.
- Every task cites the criteria it satisfies. A task satisfying no criterion does not belong here.
- Owned files are exclusive. Two tasks never list the same file.

## Groups

### Group 1 — disjoint product edits

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 1.1 | Exclude the companion packages and spikes from the published archive, and gate publish.yml on tools/check.sh | AC-001, AC-002, AC-003, AC-004, AC-005, AC-006, AC-007, NF-001, NF-002 | `.pubignore`, `.github/workflows/publish.yml` | `[P]` | ✅ Done — dry-run clean, YAML verified |
| 1.2 | Extend the public-surface test and add the four requestId boundary cases | AC-008, AC-009, AC-010, AC-011, AC-012, AC-013 | `test/webmcp_public_surface_test.dart`, `test/page/webmcp_page_test.dart` | `[P]` | ✅ Done — both test files pass (surface: 1/1, page: 26/26) |
| 1.3 | Add the issue tracker, library doc comment, and example README | AC-014, AC-015, AC-016, AC-017, AC-018 | `pubspec.yaml`, `lib/webmcp_flutter.dart`, `example/README.md` | `[P]` | The three files match the frozen criteria and the root README is untouched |

### Group 2 — integrated verification

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 2.1 | Format, analyze, dry-run, and run the full check script on the merged tree | AC-019, AC-020, NF-003 | none; reads the merged tree | | `bash tools/check.sh` exits zero |

## Serialised files

| File | Owning task |
|---|---|

No file is shared. The root README, `release.yml`, `tools/check.sh`, and everything under `lib/src/`, `packages/`, and `spikes/` have no owner because they must not change.

## Test tasks

| # | Covers | Positive case | Negative case |
|---|---|---|---|
| 1.2 | AC-008, AC-009 | The surface test names the ten inventory symbols and asserts the four integer values and two error codes | A scratch copy that expects protocol version 2 fails |
| 1.2 | AC-010, AC-011, AC-012, AC-013 | One widget test checks requestId zero, one above the maximum, a longPress reuse, and the maximum itself | The callback counter stays unchanged on the two rejections and the duplicate |
