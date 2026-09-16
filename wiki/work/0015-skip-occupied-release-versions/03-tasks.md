# Tasks: Skip occupied package versions instead of failing the release bump

## Legend

- `[P]` — may run in a parallel subagent. Only mark a task `[P]` if no other `[P]` task in the
  same group touches any of the same files.
- Every task cites the criteria it satisfies. A task satisfying no criterion does not belong here.
- Owned files are exclusive. Two tasks never list the same file.

## Groups

Groups run in sequence. Group 1 owns the two offline helpers and may split them across disjoint
files. Group 2 depends on the OCCUPIED_VERSIONS contract those helpers implement. Group 3 is
restraint evidence and owns no product file.

### Group 1 — Offline helpers and their tests

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 1.1 | Extend the POSIX bump helper so it reads OCCUPIED_VERSIONS, starts at current plus one, advances the patch while the candidate is in the set, stops at the first free patch or fails at a helper-constant cap of fifty increments, rejects a malformed occupied token, applies the changelog heading check only to the chosen version, writes both files once for that version only, and still writes nothing on any non-zero exit. Keep the optional repository-root argument and RELEASE_DATE. Perform no git operation and no network call. Extend the existing test script and fixture tree with the occupied-set cases, unset OCCUPIED_VERSIONS for every pre-existing case and for the real-repository plus-one copy, and keep every existing case passing. | AC-001, AC-002, AC-003, AC-004, AC-005, AC-006, AC-007, AC-008, AC-019, AC-021, AC-024 | tools/bump_patch_version.sh, tools/test_bump_patch_version.sh, tools/fixtures/bump-patch-version/** | `[P]` | The bump test script exits zero with no network; existing named cases still PASS; new occupied-set cases cover skip-next, consecutive skips, later-not-next, cap exceeded, malformed token, chosen-heading reject, and intermediate occupied heading |
| 1.2 | Add the JSON parser, its fixture JSON, and its test script: read JSON from a file path or standard input, print the space-separated three-component versions[].version list, include retracted entries, ignore latest as the complete set, omit a versions[].version that is not three numeric components without failing, exit non-zero on invalid JSON or a missing or non-array versions value, and perform no git operation and no network call. | AC-009, AC-010, AC-011, AC-012, AC-022 | tools/occupied_pubdev_versions.py, tools/test_occupied_pubdev_versions.sh, tools/fixtures/occupied-pubdev-versions/** | `[P]` | The parser test script exits zero with no network and reports PASS for the valid list, retracted inclusion, latest-not-complete, empty versions array, stdin, missing versions, invalid JSON, versions-is-object, and mixed prerelease omitted |
| 1.3 | Add the parser test script as the next numbered stage of the repository check suite, after the existing version-bump test stage, using the existing stage numbering, passed-line wording, and failure-reporting helper. | AC-013 | tools/check.sh | | The full check suite prints a passed line for the new stage, and a failing parser test stops the suite at that stage with a non-zero exit |

### Group 2 — Release workflow occupancy fetch

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 2.1 | Insert an occupancy-fetch step in the release workflow after the check-suite step and before the bump step: GET the official hosted package-list URL with the v2 JSON Accept header and no Authorization header and no query string, using the job's existing Python 3.12 standard-library HTTP client with a finite timeout of at most sixty seconds; fail the job on non-200 or a zero-length body; parse the body with the JSON parser; export OCCUPIED_VERSIONS from that parser output for the bump step; do not list git tags into that variable. Leave the existing tag fetch and tag-collision step after the bump, still a hard fail for the bump step's version output. Leave the loop guard, commit-then-tag order, annotated tag, and the ban on force-push, ref deletion, and skip instructions unchanged. Do not edit the publish workflow. | AC-014, AC-015, AC-016, AC-020, AC-023 | .github/workflows/release.yml | | The file parses as YAML; occupancy precedes bump; collision remains between bump and commit; occupancy builds the list only from the parser; GET failure cannot reach the bump helper |

### Group 3 — Restraint checks and evidence

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 3.1 | Prove the change did not overreach and did not release: the existing checks workflow is untouched, the publish workflow is untouched, the top-level pubspec version equals the work-item base, CHANGELOG.md gained no new version heading, and no new v-prefixed three-component tag was created. Run each of those checks against a deliberately spoiled scratch copy so the evidence shows the check can fail. Record each command and its output for the verify phase. | AC-017, AC-018, AC-020 | none | | Path-scoped diffs for checks.yml and publish.yml are empty; pubspec version matches the base; changelog and tag searches match the base; each check reports a difference on the spoiled copy |

## Serialised files

| File | Owning task |
|---|---|
| tools/bump_patch_version.sh | 1.1 |
| tools/test_bump_patch_version.sh | 1.1 |
| tools/fixtures/bump-patch-version/** | 1.1 |
| tools/occupied_pubdev_versions.py | 1.2 |
| tools/test_occupied_pubdev_versions.sh | 1.2 |
| tools/fixtures/occupied-pubdev-versions/** | 1.2 |
| tools/check.sh | 1.3 |
| .github/workflows/release.yml | 2.1 |

## Test tasks

Tests are written by the task that writes the code they cover. Task 1.1 owns the bump helper and
its fixture tests. Task 1.2 owns the parser and its fixture tests. Tasks 2.1 and 3.1 are verified
by parsing, reading, and diffing files, because a live main-branch release cannot be rehearsed.

| # | Covers | Positive case | Negative case |
|---|---|---|---|
| 1.1 | AC-001 | Unset and empty OCCUPIED_VERSIONS both plus-one 0.1.1 to 0.1.2 | Occupying 0.1.2 on the same fixture does not print 0.1.2 |
| 1.1 | AC-002 | Occupied 0.1.2 writes only a 0.1.3 heading | Unset occupied list on the same tree writes 0.1.2 |
| 1.1 | AC-003 | Occupied 0.1.2 and 0.1.3 writes 0.1.4 only | Occupying only 0.1.2 writes 0.1.3, not 0.1.4 |
| 1.1 | AC-004 | Occupied 0.1.3 still writes 0.1.2 | Also occupying 0.1.2 no longer writes 0.1.2 |
| 1.1 | AC-005 | Fifty-one consecutive occupied patches from plus-one: non-zero, files untouched, stderr contains 50 | Fifty consecutive occupied patches: exit zero on the free fifty-first candidate |
| 1.1 | AC-006 | Malformed token: non-zero, files untouched | Well-formed tokens that omit plus-one: plus-one succeeds |
| 1.1 | AC-007 | Chosen 0.1.3 already headed: non-zero, files untouched | Same skip without that heading: writes 0.1.3 |
| 1.1 | AC-008 | Pre-existing cases and real-repo plus-one still PASS with the variable unset | Parent-exported occupied list cannot change valid-patch |
| 1.1 | AC-019 | Heading for occupied 0.1.2 does not block writing 0.1.3 | Removing 0.1.2 from the list rejects on that heading |
| 1.1 | AC-021 | Test script exits zero with no network and no git in either script | A temporary host lookup or git call fails the offline run |
| 1.1 | AC-024 | Checksums match on cap, malformed-token, and chosen-heading rejects | A one-byte-modified copy reports a checksum difference |
| 1.2 | AC-009 | File and stdin both print the space-separated versions list; mixed fixture omits a prerelease token and still exits zero | Missing versions key: non-zero, empty stdout |
| 1.2 | AC-010 | Retracted three-component version appears in the printed list | Removing that versions entry drops the token |
| 1.2 | AC-011 | Invalid JSON and non-array versions: non-zero, empty stdout | Empty versions array: exit zero, empty line |
| 1.2 | AC-012 | Older versions besides latest.version appear | Versions array holding only latest.version prints that single token |
| 1.2 | AC-022 | Parser tests exit zero with no network and no git | A temporary URL fetch fails the offline run |
| 1.3 | AC-013 | Full suite prints a passed line for the new stage after the bump-helper stage | A failing parser test stops the suite at that stage |
| 2.1 | AC-014 | Occupancy step GETs the package-list URL, runs the parser, exports OCCUPIED_VERSIONS, precedes bump, and does not list git tags into the variable | A copy that concatenates git ls-remote tags into OCCUPIED_VERSIONS fails the reading |
| 2.1 | AC-015 | Occupancy step fails on non-200, empty body, or parser failure; bump has no always-run bypass | A scratch variant that calls the bump helper after a failed GET disagrees with the committed step |
| 2.1 | AC-016 | Collision step still between bump and commit; scratch repo with the matching tag exits non-zero | Scratch repo with no matching tag exits zero |
| 2.1 | AC-020 | publish.yml diff empty; loop guard, commit-then-tag, annotated tag remain; no force-push, delete, or skip instruction. git fetch --tags --force is allowed. | A scratch release.yml that force-pushes the tag fails the grep |
| 2.1 | AC-023 | Accept value is application/vnd.pub.v2+json; no Authorization; no query string; no pub.dev credential | A scratch copy with an Authorization header, or with Accept application/json, matches those greps |
| 3.1 | AC-017 | Path-scoped diff of checks.yml against the base is empty | A blank line on a scratch copy produces a non-empty diff |
| 3.1 | AC-018 | Pubspec version, changelog headings, and v-prefixed three-component tags match the base | A scratch bump, heading, and tag each report a difference |
