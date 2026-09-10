# Tasks: Publish webmcp_flutter to pub.dev on every push to main with a patch bump

## Legend

- `[P]` — may run in a parallel subagent. Only mark a task `[P]` if no other `[P]` task in the
  same group touches any of the same files.
- Every task cites the criteria it satisfies. A task satisfying no criterion does not belong here.
- Owned files are exclusive. Two tasks never list the same file.

## Groups

Groups run in sequence. Group 2 depends on the helper contract that Group 1 implements, and
Group 3 depends on both. Within Group 2 the two tasks own disjoint files and may run together.

### Group 1 — Version bump helper and its offline test

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 1.1 | Write the patch-bump helper and the offline test that covers it: a POSIX shell script that reads pubspec.yaml and CHANGELOG.md from a repository root, validates both, increments only the third version component, prepends a dated changelog section in the repository's bracket-free heading style whose single bullet is the exact line fixed in the plan, writes both files, and prints only the new version; plus the fixture set and the test script that exercises every positive and negative case, including the fixture whose pubspec and changelog disagree. Interfaces are fixed in the plan: optional repository-root argument, `RELEASE_DATE` environment override, one standard-output line, diagnostics on standard error, nothing written on any rejected input. | AC-001, AC-002, AC-003, AC-004, AC-005, AC-006, AC-024, AC-025 | tools/bump_patch_version.sh, tools/test_bump_patch_version.sh, tools/fixtures/bump-patch-version/** | | ✓ Complete: Test script exits zero, negative cases verified, real repo test prints 0.1.2 |
| 1.2 | Add the helper test as the final numbered stage of the repository check script, following the existing stage numbering, echo wording and failure-reporting helper already used in that file. | AC-007 | tools/check.sh | | ✓ Complete: Stage 7 added, failing test stops suite at stage 7 |

### Group 2 — Workflow files

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 2.1 | Write the bump-and-tag workflow: push to the main branch only, non-cancelling concurrency group, job-level loop guard rejecting a head commit message that begins with the release prefix, a first step that fails when the `RELEASE_GITHUB_TOKEN` secret is empty, checkout using that secret, the Python and pinned Flutter setup the existing checks workflow uses, the repository check suite, the helper invocation publishing the new version as a named step output, a tag-collision guard, a commit staging only pubspec.yaml and CHANGELOG.md whose message is the release prefix plus the version and carries no skip instruction, an annotated v-prefixed tag, then the commit push followed by the tag push. Include a short English operator comment naming the secret and the branch-protection prerequisite. | AC-008, AC-009, AC-010, AC-011, AC-012, AC-013, AC-014, AC-015, AC-016, AC-021, AC-022 | .github/workflows/release.yml | `[P]` | The file parses as YAML, the secret gate is the first step, the setup steps precede the check step, the check step precedes every git-writing step, the guard prefix equals the prefix the commit step writes, and the extracted secret-gate body exits non-zero on an empty value and zero on a non-empty one |
| 2.2 | Write the publish workflow: triggered only by pushes of tags shaped as the letter v followed by three dot-separated numeric components, calling the official Dart reusable publish workflow at reference v1 with identity-token write and contents read, holding no secret and no publish command of its own. Include a short English operator comment naming the tag pattern that must be configured on the pub.dev admin tab for this repository. | AC-017, AC-018, AC-022 | .github/workflows/publish.yml | `[P]` | The file parses as YAML, the tag pattern matches v0.1.2 and rejects main, v1 and release-0.1.2, the operator comment names the tag pattern and the repository, and the file references no repository secret |

### Group 3 — Restraint checks and evidence

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 3.1 | Prove the change did not overreach and did not release anything: the existing checks workflow is untouched, the pubspec version is still 0.1.1, no changelog section or git tag names 0.1.2, and no credential material beyond the named secret lookup appears in any added or changed file. Each of those three checks is also run against a deliberately spoiled scratch copy, so the evidence shows the check can fail. Record each command and its output for the verify phase. | AC-019, AC-020, AC-023 | none | | A path-scoped git diff for the existing checks workflow is empty, the pubspec version line reads 0.1.1, searches for a 0.1.2 heading and a v0.1.2 tag return nothing, the credential search matches only the secret reference, and every one of those checks reports a match or a diff when run against the spoiled copy |

## Serialised files

| File | Owning task |
|---|---|
| tools/check.sh | 1.2 |
| tools/bump_patch_version.sh | 1.1 |
| tools/test_bump_patch_version.sh | 1.1 |
| tools/fixtures/bump-patch-version/** | 1.1 |
| .github/workflows/release.yml | 2.1 |
| .github/workflows/publish.yml | 2.2 |

## Test tasks

Tests are written by the task that writes the code they cover. Task 1.1 owns both the helper
and the offline test; tasks 2.1, 2.2 and 3.1 are verified by parsing and inspecting the files
they produce, because a live release cannot be rehearsed — a published version is permanent.

| # | Covers | Positive case | Negative case |
|---|---|---|---|
| 1.1 | AC-001 | Fixture at 0.1.1 yields exit zero and the single standard-output line 0.1.2 | Fixture at 0.1.1-dev.1 yields a non-zero exit and two byte-identical files |
| 1.1 | AC-002 | Fixture at 1.2.3 yields a written version line of 1.2.4 with no 1.3.0 or 2.0.0 line | Fixture at 0.1 (two components) yields a non-zero exit and two byte-identical files |
| 1.1 | AC-003 | With a pinned release date, the third line of the written changelog is the two-hash, version, hyphen, date heading and contains no square bracket | Fixture whose changelog lacks the single-hash title line yields a non-zero exit and two byte-identical files |
| 1.1 | AC-004 | The new section's bullet equals the fixed line from the plan byte-for-byte, and the previous section survives below it unchanged | A fixture whose pubspec reads 0.1.1 while the changelog already documents 0.1.2 yields a non-zero exit and two byte-identical files |
| 1.1 | AC-005 | Diagnostics for a missing pubspec go to standard error while standard output stays empty | A root holding a valid pubspec but no changelog yields a non-zero exit, empty standard output and a byte-identical pubspec |
| 1.1 | AC-024 | Checksums of both files match before and after every rejected run | The same comparison against a one-byte-modified copy reports a difference |
| 1.1 | AC-025 | The test script exits zero with no network reachable | A temporary case that resolves a host name fails the offline run |
| 1.2 | AC-007 | The full check suite prints a passed line for the new final stage | A failing helper test stops the suite at that stage with a non-zero exit |
| 2.1 | AC-011 | The extracted secret-gate shell body exits zero with a non-empty token value | The same body exits non-zero with an empty token value |
| 2.1 | AC-016 | The extracted tag-collision body exits zero in a scratch repository with no matching tag | The same body exits non-zero in a scratch repository that already holds the tag |
| 2.1 | AC-010 | The guard prefix parsed out of the job condition equals the prefix in the commit-message step, and an ordinary commit message is accepted | A message beginning with that prefix is rejected by the guard, and no skip-instruction string appears anywhere in the file |
| 2.1 | AC-021 | The Python and Flutter setup steps precede the check step and the pinned Flutter version equals the one in the existing checks workflow | Comparing against a different version string fails the equality check |
| 2.1, 2.2 | AC-022 | Each new workflow file carries the operator comment naming its prerequisite | The same grep finds nothing in the existing checks workflow |
| 2.2 | AC-017 | The tag pattern matches v0.1.2 and v10.20.30 | The pattern matches none of main, v1 or release-0.1.2 |
