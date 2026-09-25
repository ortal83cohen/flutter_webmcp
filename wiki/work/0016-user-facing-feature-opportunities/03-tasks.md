# Tasks: Feature opportunities for application authors using webmcp_flutter

## Legend

- `[P]` — may run in a parallel subagent. Only mark a task `[P]` if no other `[P]` task in the same group touches any of the same files.
- Every task cites the criteria it satisfies. A task satisfying no criterion does not belong here.
- Owned files are exclusive. Two tasks never list the same file.

## Groups

Groups run in sequence. This work item has one group because the new call handler, signal, and publisher fields are one interface. No task is parallel.

### Group 1 — Author-facing call, browser metadata, decode, errors, log, and non-web no-op

| # | Task | Satisfies | Files owned | Parallel | Done when |
|---|---|---|---|---|---|
| 1.1 | Add the execution signal, tool call, optional call handler, title, exposedTo, and debugging annotation, and teach WebMcpAction to store exactly one of onInvoke or onCall. | AC-003, AC-006, AC-017 | lib/src/webmcp_tool.dart, lib/src/widgets/webmcp_action.dart, test/widget_layer_test.dart, test/registry_test.dart | | Closed. One-argument tools still construct. Both callbacks throw ArgumentError. The widget maps each callback to one tool field. |
| 1.2 | Prefer callHandler in local invoke and in the page source wrapper, with a null signal. Add the tool exception types and the payload-free log hook. | AC-003, AC-012, AC-013, AC-015, AC-016 | lib/src/webmcp.dart, lib/src/page/webmcp_page.dart, lib/src/webmcp_exceptions.dart, test/page/webmcp_page_test.dart | | Closed. A call-handler-only tool runs from invoke and from page dispatch. Local WebMcpToolException still throws. Hook failures do not undo registration. |
| 1.3 | Add declared-field decoding and the decoded-argument tool constructor. Export the new public members. | AC-009, AC-010 | lib/src/webmcp_typed_input.dart, lib/webmcp_flutter.dart, test/webmcp_public_surface_test.dart | | Closed. Bad declared input throws before the callback. A free-form schema map is still not validated. |
| 1.4 | Forward the browser execution signal without ending or replaying the handler. Send title, debugging, and exposedTo only when set. Deliver tool activity as notification. Map structured exceptions to the safe agent object. Make non-web registerTool a no-op registration and list the non-web platforms. | AC-001, AC-002, AC-004, AC-005, AC-006, AC-007, AC-008, AC-011, AC-014, AC-015 | lib/src/transport/native_publisher_boundary.dart, lib/src/transport/native_publisher_boundary_web.dart, lib/src/transport/native_publisher_boundary_noop.dart, lib/src/transport/webmcp_native_publisher.dart, pubspec.yaml, test/native_publisher_test.dart, test/transport_selection_test.dart | | Closed. Fake-boundary tests cover the signal, omitted members, activity, agent errors, and the no-op registration. The full check suite passes. |

## Serialised files

| File | Owning task |
|---|---|
| lib/src/webmcp_tool.dart | 1.1 |
| lib/src/widgets/webmcp_action.dart | 1.1 |
| lib/src/webmcp.dart | 1.2 |
| lib/src/page/webmcp_page.dart | 1.2 |
| lib/src/webmcp_exceptions.dart | 1.2 |
| lib/src/webmcp_typed_input.dart | 1.3 |
| lib/webmcp_flutter.dart | 1.3 |
| lib/src/transport/webmcp_native_publisher.dart | 1.4 |
| pubspec.yaml | 1.4 |
| wiki/work/0016-user-facing-feature-opportunities/03-tasks.md | 1.4 |

## Test tasks

| # | Covers | Positive case | Negative case |
|---|---|---|---|
| 1.1 | AC-003, AC-006, AC-017 | One-argument handler receives the map. exposedTo is copied. onCall and onInvoke each mount one callback. | Both tool callbacks throw. Both widget callbacks throw. Mutating the author list does not change the stored list. |
| 1.2 | AC-012, AC-013, AC-015, AC-016 | Local invoke throws the tool exception. The log record has kind and tool name. Page dispatch calls a call-handler-only tool once with a null signal. | A throwing hook leaves the tool registered. A handler-only page tool does not need a call handler. The log record omits the argument string. |
| 1.3 | AC-009, AC-010 | A valid declared string reaches the callback. The stored schema is a shallow copy. | Unknown key, missing key, double-for-integer, and an out-of-range integer throw before the callback. Arguments that miss the schema still run the handler. |
| 1.4 | AC-001, AC-002, AC-004, AC-005, AC-007, AC-008, AC-011, AC-014 | The fake signal's aborted flag is visible. Abort after start leaves the future pending. Title, debugging, and exposedTo match the author when set. Activity is delivered. A coded exception becomes the agent object. Non-web register and invoke complete. | A missing second argument yields a null signal. cancelledBeforeDispatch skips the handler. Unset title and debugging are absent. Detach drops later activity. toolcancel does not finish the handler. A StateError becomes handlerFailed. Aborting the no-op registration does not unregister the local tool. |
