---
id: generator-argument-errors
title: Generator argument errors — exception type, publisher mapping, agent visibility
status: active
owner: unassigned
last_verified: 2026-10-02
applies_to:
  - packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart
  - lib/src/transport/webmcp_native_publisher.dart
  - lib/src/webmcp_exceptions.dart
summary: >
  What generated decoders throw, how the native publisher classifies each path
  versus WebMcpInvalidArgumentsException, and which option surfaces
  invalidArguments to an agent.
---

# Research: Generator argument errors — exception type, publisher mapping, and agent visibility

## Question

What does a generated domain tool throw when arguments are invalid, what does
the native publisher return to the browser for that throw versus a thrown
`WebMcpInvalidArgumentsException`, and which change (if any) is required to
make a bad generated argument visible to an agent as `invalidArguments`?

## Answer

Generated decoders call `_$webMcpInvalid()`, which throws a
`FormatException`. The generated `_invoke` method catches `FormatException`
locally and **returns** a structured error map `{ok: false, error: {code:
"invalidArguments", retryable: false}}` — it does not rethrow. The native
publisher receives this map as a handler return value (success path), normalizes
and JSON-encodes it, and sends `{"ok":false,"error":{"code":"invalidArguments","retryable":false}}`
to the browser. An agent therefore already sees `invalidArguments` under the
current `FormatException` route. If the generator instead threw
`WebMcpInvalidArgumentsException` without a local catch, the publisher would
reach its `on WebMcpToolException` branch and call `_toolExceptionFailure`,
producing the **identical wire JSON**. No change to the wire output is required;
the current route already surfaces `invalidArguments`.

## Findings

### 1. `_$webMcpInvalid()` throws a `FormatException`

- Claim: The generator emits a top-level helper `_$webMcpInvalid()` whose sole
  body is `throw const FormatException('Invalid WebMCP arguments.')`.
- Evidence: Generator source writes `"Never _\$webMcpInvalid() => throw const FormatException('Invalid WebMCP arguments.');"`.
- Source: `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart` lines 74–76

### 2. Every decoder validation path calls `_$webMcpInvalid()`

- Claim: Null checks, type checks, integer range checks, double finiteness
  checks, enum name mismatches, unknown-key checks, and missing-required-key
  checks all call `_$webMcpInvalid()`, so every invalid-argument condition
  throws the same `FormatException`.
- Evidence: `_emitDecoder` and `_emitInvoker` emit `_$webMcpInvalid()` in
  every guard branch. Confirmed in generated output files.
- Source: `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart` lines 80–93, 397–449

### 3. Generated `_invoke` catches `FormatException` and returns a map — does not rethrow

- Claim: The generated invoker wraps everything in `try { … } on FormatException { return const <String, Object?>{'ok': false, 'error': <String, Object?>{'code': 'invalidArguments', 'retryable': false}}; }`. The exception never propagates to the publisher.
- Evidence: Both generated example files show identical catch-and-return blocks. Local invocation also returns this map (no throw propagation).
- Source: `example/lib/example_task_service.webmcp.g.dart` lines 87–95; `packages/webmcp_flutter_generator/example/lib/inventory_service.webmcp.g.dart` lines 152–159

### 4. Publisher treats the returned map as a successful handler invocation

- Claim: Because the generated handler returns (not throws), the publisher's
  `_invoke` reaches the result-normalization branch. It calls
  `_normalizeJson(result)`, `_enforceEncodedSize`, and `jsonEncode`, then settles
  the operation as **completed** and logs `WebMcpLogKind.invoked`.
- Evidence: Publisher `_invoke` success path at lines 384–391 handles the return
  value; the exception branches at lines 369–382 are never reached.
- Source: `lib/src/transport/webmcp_native_publisher.dart` lines 356–392

### 5. Browser wire output for the current `FormatException` route

- Claim: The browser receives `{"ok":false,"error":{"code":"invalidArguments","retryable":false}}` — the normalized form of the map the handler returned.
- Evidence: `example/test/example_task_service_test.dart` lines 86–98 invoke the local registry and assert `envelope['ok']` is false and `code == 'invalidArguments'`. `packages/webmcp_flutter_generator/example/test/live_instance_test.dart` lines 49–58 assert the same structure.
- Source: `example/test/example_task_service_test.dart` lines 86–98; `packages/webmcp_flutter_generator/example/test/live_instance_test.dart` lines 49–58

### 6. Browser wire output for a thrown `WebMcpInvalidArgumentsException`

- Claim: `WebMcpInvalidArgumentsException` extends `WebMcpToolException` with
  `code: 'invalidArguments'` and `retryable: false`. If thrown by the handler,
  the publisher's `on WebMcpToolException` branch catches it, validates the code
  against `^[A-Za-z0-9_.-]{1,64}$` (which `'invalidArguments'` satisfies), and
  returns `jsonEncode({'ok': false, 'error': {'code': 'invalidArguments',
  'retryable': false}})`. The **wire JSON is identical** to the current route.
- Evidence: `_toolExceptionFailure` builds the body from `error.code` and
  `error.retryable`; `WebMcpInvalidArgumentsException` supplies exactly those
  values.
- Source: `lib/src/webmcp_exceptions.dart` lines 70–74; `lib/src/transport/webmcp_native_publisher.dart` lines 413–435

### 7. The two routes differ only in operation-tracker outcome and log kind

- Claim: Current `FormatException` route: operation settles as **completed**,
  log is `WebMcpLogKind.invoked`. `WebMcpInvalidArgumentsException` route:
  operation settles with `handlerFailed` reason, log is
  `WebMcpLogKind.invocationFailed`.
- Evidence: Publisher `on WebMcpToolException` block at lines 370–375 calls
  `_operations.settle(operation, reason: WebMcpNativeReasonCode.handlerFailed)`
  and `webMcpRecordLog(WebMcpLogKind.invocationFailed, ...)`. The success branch
  at lines 388–390 calls `_operations.settle(operation)` and
  `webMcpRecordLog(WebMcpLogKind.invoked, ...)`.
- Source: `lib/src/transport/webmcp_native_publisher.dart` lines 367–391

### 8. `WebMcpToolException` with a different code changes the agent-visible code

- Claim: If the generated handler threw `WebMcpToolException(code: 'otherCode',
  retryable: false)`, the publisher would emit
  `{"ok":false,"error":{"code":"otherCode","retryable":false}}`. The agent
  would not see `invalidArguments`.
- Evidence: `_toolExceptionFailure` serializes `error.code` directly into the
  `'code'` field of the wire body.
- Source: `lib/src/transport/webmcp_native_publisher.dart` lines 418–420

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Keep `FormatException` (current) | `_$webMcpInvalid()` throws `FormatException`; generated `_invoke` catches it locally and returns the error map via the handler success path. Publisher normalizes the map. Browser sees `invalidArguments`. | Zero change cost. Operation logged as `invoked`, not `invocationFailed`. | **Chosen as baseline.** Already surfaces `invalidArguments` to the agent. Semantically inconsistent (a failed invocation is counted as completed) but wire-correct. |
| Throw `WebMcpInvalidArgumentsException`, remove local catch | `_$webMcpInvalid()` throws `WebMcpInvalidArgumentsException`; no local catch; publisher's `on WebMcpToolException` branch fires; `_toolExceptionFailure` encodes the same wire JSON. | Requires generator change and regeneration of all `.g.dart` files. Operation logged as `invocationFailed`. | Not rejected — produces identical wire output. Semantically correct (operation recorded as failed). Preferred if operational accuracy matters; not required for agent visibility. |
| Throw `WebMcpToolException` with a different code | Handler throws or returns with a non-`invalidArguments` code. Publisher encodes the different code. | Agent sees a different error code. | **Rejected.** Does not produce `invalidArguments`. Breaks agent contract for decode failures. |

## Constraints discovered

- The generator emits the `FormatException` catch inside every `_invoke` method.
  Any change to the exception type requires regenerating all `.g.dart` files;
  hand-edited generated files would diverge.
- The publisher's `_toolExceptionFailure` validates the code against
  `^[A-Za-z0-9_.-]{1,64}$`. `'invalidArguments'` satisfies this constraint.
- The publisher's `on WebMcpToolException` branch is only reached if the handler
  **throws** `WebMcpToolException`. A handler that **returns** a map never
  triggers it, regardless of map content.
- Local `WebMcp.instance.invokeTool` propagates the handler's return value
  unchanged. Tests assert on the returned map structure, not on a thrown
  exception, confirming the current return-not-throw contract.
- The contract states the publisher "omits the exception message and stack."
  The `FormatException` message `'Invalid WebMCP arguments.'` is never sent to
  the browser because the generator catches it locally before the publisher
  sees any exception.

## Unresolved

- [UNRESOLVED: Whether the operation-tracker semantic difference (completed vs handlerFailed) matters to any existing consumer or diagnostic surface. The research scope excludes this decision.]

## Sources

| Source | Consulted |
|---|---|
| `packages/webmcp_flutter_generator/lib/src/webmcp_domain_action_generator.dart` | 2026-10-02 |
| `lib/src/transport/webmcp_native_publisher.dart` | 2026-10-02 |
| `lib/src/webmcp_exceptions.dart` | 2026-10-02 |
| `example/lib/example_task_service.webmcp.g.dart` | 2026-10-02 |
| `packages/webmcp_flutter_generator/example/lib/inventory_service.webmcp.g.dart` | 2026-10-02 |
| `example/test/example_task_service_test.dart` | 2026-10-02 |
| `packages/webmcp_flutter_generator/example/test/live_instance_test.dart` | 2026-10-02 |
| `test/native_publisher_test.dart` | 2026-10-02 |
| `wiki/product/webmcp-contract.md` | 2026-10-02 |
| `wiki/templates/00-research.md` | 2026-10-02 |
