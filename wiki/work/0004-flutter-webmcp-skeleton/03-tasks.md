# Tasks: Flutter WebMCP package skeleton

## Legend

- `[P]` — may run in a parallel subagent. Only mark a task `[P]` if no other `[P]` task in the
  same group touches any of the same files.
- Every task cites the criteria it satisfies. A task satisfying no criterion does not belong here.
- Owned files are exclusive. Two tasks never list the same file.

This work item's eleven plan steps are strictly sequential: each later step's files depend on
an earlier step's output (the public library on the transport seam, the check script on the
package existing, CI on the check script). No task here is marked `[P]`.

## Groups

### Group 1 — Toolchain and manifests

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 1.1 | Record the toolchain, pin the Flutter version, extend `.gitignore` | AC-033 | `.gitignore` | | Plan step 1's completion condition holds |
| 1.2 | Author the root manifest and pre-migrated analyzer configuration | AC-005, AC-006, AC-029 | `pubspec.yaml`, `analysis_options.yaml` | | Plan step 2's completion condition holds |

### Group 2 — Core library

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 2.1 | Write the registry and its public library | AC-009–AC-017, AC-020 (the notification call sites live in `lib/src/webmcp.dart`, owned here) | `lib/webmcp_pilot.dart`, `lib/src/webmcp.dart`, `lib/src/webmcp_tool.dart`, `lib/src/webmcp_tool_source.dart`, `lib/src/webmcp_exceptions.dart` | | Plan step 3's completion condition holds |
| 2.2 | Write the transport seam | AC-019, AC-021 | `lib/src/transport/webmcp_transport.dart`, `lib/src/transport/transport_noop.dart`, `lib/src/transport/transport_web.dart`, `lib/src/transport/transport_selector.dart` | | Plan step 4's completion condition holds |

### Group 3 — Root test suite

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 3.1 | Write the root test suite (five files) | AC-009–AC-021, AC-018, AC-032 | `test/webmcp_public_surface_test.dart`, `test/registry_test.dart`, `test/transport_selection_test.dart`, `test/repo_hygiene_test.dart`, `test/transport_web_source_test.dart` | | Plan step 5's completion condition holds |

### Group 4 — Example package

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 4.1 | Create and trim the example package | AC-001 (example half), AC-006 (example half), AC-007, AC-008, AC-022, AC-023 | `example/pubspec.yaml`, `example/analysis_options.yaml`, `example/web/`, `example/lib/main.dart`, `example/lib/example_tools.dart`, `example/test/example_tools_test.dart` | | Plan step 6's completion condition holds |

### Group 5 — Check script, failure proof, CI

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 5.1 | Write `tools/check.sh` | AC-001, AC-002, AC-003, AC-004 | `tools/check.sh` | | Plan step 7's completion condition holds |
| 5.2 | Prove the suite reports failure | AC-003 (evidence) | none (transient) | | Plan step 8's completion condition holds |

### Group 6 — Documentation and CI

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 6.1 | Write the documentation set (README/AGENTS.md/CHANGELOG unconditional; LICENSE gated on the human-supplied copyright holder) | AC-025 (AGENTS.md half), AC-027, AC-030 | `README.md`, `AGENTS.md`, `CHANGELOG.md`, `LICENSE` | | Plan step 9's completion condition holds |
| 6.2 | Add the CI job | AC-024, AC-025 (workflow half), AC-026 (first half unconditionally; second half only if a human authorizes the push) | `.github/workflows/checks.yml` | | Plan step 10's completion condition holds |

### Group 7 — Final verification

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 7.1 | Run the suite from a clean checkout, cold and warm | AC-001, AC-028 (cross-cutting: checked once against the whole tree rather than owned by any single content task), AC-031 | none | | Plan step 11's completion condition holds |

## Serialised files

No file is touched by more than one task; each plan step owns a disjoint file set, per the plan's
own "Touches" clause for each step.

| File | Owning task |
|---|---|
| — | — |

## Test tasks

| # | Covers | Positive case | Negative case |
|---|---|---|---|
| T1 | AC-005 | Clean tree, `dart analyze` reports zero issues | Unused local in `example/lib/main.dart` + undocumented public member in `lib/` |
| T2 | AC-006 | Committed-vs-after-first-run checksum equal | Remove one required `analyzer.exclude` entry, checksum differs |
| T3 | AC-007 | Bad file under `example/build/` not reported | Remove `example/build/**` from `example/analysis_options.yaml` |
| T4 | AC-008 | No invalid-dependency issue | Remove `publish_to: none` from `example/pubspec.yaml` |
| T5 | AC-009–AC-016 | Each registry operation's happy path | Each operation's stated mutation (see `02-criteria.md`) |
| T6 | AC-017 | Public-surface test compiles and passes | (a) delete an export — compile fails; (b) add a `lib/src/` import to the test — hygiene scan fails |
| T7 | AC-018 | Hygiene scan reports zero offending files | Add `dart:html` import to `example/lib/example_tools.dart` |
| T8 | AC-019 | VM selects the non-web transport | Swap conditional-export branches |
| T9 | AC-020 | Two ordered notifications | Delete the unregister notification call |
| T10 | AC-021 | Source text contains the fixed identifier/wording | Change the identifier string literal |
| T11 | AC-022 | Example registers its two tools, counter increments | Rename one tool without updating the test |
| T12 | AC-032 | Zero secret-marker matches | Add a synthetic AWS-key-prefix string to a workflow file |
| T13 | AC-003 (failure proof) | Suite exits zero | Invert one assertion in `test/registry_test.dart` |
