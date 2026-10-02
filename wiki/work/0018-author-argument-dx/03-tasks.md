# Tasks: Author argument schema, generated metadata, and agent-visible decode errors

## Legend

- `[P]` — may run in a parallel subagent. Only mark a task `[P]` if no other `[P]` task in the same group touches any of the same files.
- Every task cites the criteria it satisfies. A task satisfying no criterion does not belong here.
- Owned files are exclusive. Two tasks never list the same file.

## Groups

Groups 1 and 2 may run together. Group 3 starts only after group 1 is closed, because it calls the decoding factory group 1 changes.

### Group 1 — Derived schema and decode details

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 1.1 | Add webMcpSchemaFromFields and call it from the decoding factory only when the input schema is empty. | AC-001, AC-002, AC-003, AC-004, AC-005, AC-006, AC-007, AC-008, AC-009, AC-031 | lib/src/webmcp_typed_input.dart, lib/src/webmcp_tool.dart, test/registry_test.dart, test/webmcp_public_surface_test.dart | `[P]` | The registry suite passes and the public-surface list names the new function. |
| 1.2 | Add WebMcpDecodeFailureReason and WebMcpInvalidArgumentsException.withFailure, and thread the key and reason through every decode throw. | AC-016, AC-017, AC-018, AC-019, AC-020, AC-021, AC-022, AC-032, AC-034 | lib/src/webmcp_exceptions.dart, lib/src/webmcp_typed_input.dart, test/registry_test.dart, test/native_publisher_test.dart, test/webmcp_public_surface_test.dart | | The registry and native-publisher suites pass. |

Tasks 1.1 and 1.2 share files, so they are one implementer and are not parallel with each other. The group as a whole is parallel with group 2.

### Group 2 — Generator publication metadata

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 2.1 | Add optional title, debugging and exposedTo to the annotation and emit them only when non-null. Reject an empty or whitespace title through the builder log. | AC-010, AC-011, AC-012, AC-013, AC-014, AC-015 | packages/webmcp_flutter_annotations/lib/webmcp_flutter_annotations.dart, packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart, packages/webmcp_flutter_generator/test/generator_test.dart | `[P]` | The generator package tests pass. |
| 2.2 | Opt one generator-example method into the new metadata, regenerate its source, and lock the generated invalid-argument return. | AC-023, AC-024 | packages/webmcp_flutter_generator/example/lib/inventory_service.dart, packages/webmcp_flutter_generator/example/lib/inventory_service.webmcp.g.dart, packages/webmcp_flutter_generator/example/test/live_instance_test.dart | | The generator example tests pass. |

Tasks 2.1 and 2.2 are one implementer. They do not run parallel with each other.

### Group 3 — Widget field list

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 3.1 | Add an optional field list to WebMcpAction, reject it when paired with the one-argument callback, and decode before the newest call callback. | AC-025, AC-026, AC-027, AC-028, AC-029, AC-030 | lib/src/widgets/webmcp_action.dart, test/widget_layer_test.dart | | The widget suite passes. |

## Serialised files

| File | Owning task |
|---|---|
| lib/src/webmcp_typed_input.dart | 1.1 then 1.2, same implementer |
| test/registry_test.dart | 1.1 then 1.2, same implementer |
| test/webmcp_public_surface_test.dart | 1.1 then 1.2, same implementer |
| wiki/work/0018-author-argument-dx/03-tasks.md | parent only |

## Test tasks

Tests are written by the implementer who owns the code they cover. Each criterion in 02-criteria.md names its positive check and its negative case. AC-033 is the parent full-check gate after all three groups close.
