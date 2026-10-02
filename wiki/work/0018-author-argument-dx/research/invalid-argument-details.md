# Research: decode-failure payload for manual declared fields

## Question

What does an agent learn today when declared-field decoding fails, what detail
payload can the native publisher carry, and can the failed field key and a
closed reason enum be added without leaking argument values, messages, or
stacks?

## Answer

Today an agent receives only `{"ok":false,"error":{"code":"invalidArguments","retryable":false}}` — no field name, no reason. The publisher will carry any `details` map that passes regex, normalization, and 64 KB limit, so a small structured object is accepted. Adding a field key and a closed reason enum (values: `missing`, `unknown`, `type`) is safe: neither surface leaks a value, a message, or a stack.

## Findings

### Finding 1 — Current decode throws a bare exception with no context

- Claim: Every decode failure in `webMcpDecodeArguments` and `_decodeValue` throws `const WebMcpInvalidArgumentsException()`, which carries no field key, no reason, and no value.
- Evidence: All `throw` sites in both functions use the no-argument const constructor. There is no overload or field on `WebMcpInvalidArgumentsException` that carries context.
- Source: `lib/src/webmcp_typed_input.dart` lines 77–154; `lib/src/webmcp_exceptions.dart` lines 69–73

### Finding 2 — WebMcpInvalidArgumentsException reaches the publisher as a WebMcpToolException

- Claim: `WebMcpInvalidArgumentsException` extends `WebMcpToolException`, so the publisher catches it at the `on WebMcpToolException` branch and calls `_toolExceptionFailure`.
- Evidence: Class declaration `final class WebMcpInvalidArgumentsException extends WebMcpToolException`. Publisher catch at line 369 routes to `_toolExceptionFailure`.
- Source: `lib/src/webmcp_exceptions.dart` lines 69–73; `lib/src/transport/webmcp_native_publisher.dart` lines 369–375

### Finding 3 — Agent-visible payload today is code + retryable only

- Claim: Because `WebMcpInvalidArgumentsException` passes `details: null` (inheriting the default), the agent receives `{"ok":false,"error":{"code":"invalidArguments","retryable":false}}` with no details field.
- Evidence: `_toolExceptionFailure` adds `body['details']` only when `error.details != null` (line 423). `WebMcpInvalidArgumentsException` does not set `details`, so the field is absent from the wire response.
- Source: `lib/src/transport/webmcp_native_publisher.dart` lines 413–436; `lib/src/webmcp_exceptions.dart` lines 70–73

### Finding 4 — Publisher accepts a details map when it passes code regex, normalization, and size limits

- Claim: `_toolExceptionFailure` normalizes `details` through `_normalizeJson` and `_enforceEncodedSize` (64 KB cap). A details value that fails either check downgrades the entire response to `_safeFailure(handlerFailed)`. A passing value is included verbatim under the `"details"` key.
- Evidence: Lines 422–433 in `_toolExceptionFailure`. `webMcpNativeMaxJsonBytes = 64 * 1024` at line 14.
- Source: `lib/src/transport/webmcp_native_publisher.dart` lines 14, 413–436

### Finding 5 — A field key + closed reason enum is small and cannot leak a value

- Claim: A details map of the form `{"field":"<key>","reason":"missing"|"unknown"|"type"}` is a fixed-size, enumerated object. It carries no decoded value, no free-form message, and no stack. It satisfies the normalization rules (string-keyed map, string values, no cycles, depth < 32, well under 64 KB).
- Evidence: `_normalizeJson` accepts a string-keyed map of strings unconditionally. The reason values are a closed set chosen by the library, not echoed from the caller input.
- Source: `lib/src/transport/webmcp_native_publisher.dart` lines 480–501 (normalization path)

### Finding 6 — The log hook records only event kind and tool name

- Claim: `webMcpRecordLog` is called with `WebMcpLogKind.invocationFailed` and `tool.name` only. No argument data, field name, or exception detail is passed to the hook.
- Evidence: Both failure call sites in `_invoke` call `webMcpRecordLog(WebMcpLogKind.invocationFailed, tool.name)` with no third argument.
- Source: `lib/src/transport/webmcp_native_publisher.dart` lines 374, 382; `wiki/product/webmcp-contract.md` line 40

### Finding 7 — Contract mandates that the publisher omits the exception message and stack

- Claim: The product contract explicitly states that the publisher "maps an accepted WebMcpToolException to an allowlisted error and omits the exception message and stack."
- Evidence: Direct quote from the contract document.
- Source: `wiki/product/webmcp-contract.md` lines 30–33

### Finding 8 — A details value outside publisher limits becomes the existing handler-failed object

- Claim: If details normalization or size check throws, `_toolExceptionFailure` returns `_safeFailure(WebMcpNativeReasonCode.handlerFailed)`, which loses even the `invalidArguments` code.
- Evidence: `catch (Object)` block at line 431 calls `_safeFailure`.
- Source: `lib/src/transport/webmcp_native_publisher.dart` lines 430–433; `wiki/product/webmcp-contract.md` line 31

### Finding 9 — Tests confirm the exception is thrown but do not inspect its details

- Claim: Existing tests verify that `WebMcpInvalidArgumentsException` is thrown for unknown keys, missing required keys, and bad shapes. No test asserts on a `details` map or a field name.
- Evidence: `throwsA(isA<WebMcpInvalidArgumentsException>())` at line 310; `webmcp_public_surface_test.dart` line 64 checks the type exists only.
- Source: `test/registry_test.dart` lines 307–325; `test/webmcp_public_surface_test.dart` line 64

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Keep empty `invalidArguments` (status quo) | Throw `const WebMcpInvalidArgumentsException()` with `details: null`. Agent sees code + retryable only. | Zero implementation change | Rejected: agent cannot distinguish missing key from wrong type; retry guidance is generic. |
| Add field key + closed reason enum (no value) | Throw `WebMcpInvalidArgumentsException(field: '<key>', reason: DecodeFailureReason.missing\|unknown\|type)`. Publisher serializes `{"field":"…","reason":"…"}` into `details`. | Constructor becomes non-const; every throw site must thread the key; `_decodeValue` needs the field passed in; `WebMcpInvalidArgumentsException` gains two optional fields. | Chosen: gives the agent actionable repair information, leaks no value or message, passes publisher constraints (small fixed-schema map, all strings). |
| Add the rejected value in details | Include the caller-supplied raw value alongside the field key. | Same as option 2 plus value serialization. | Rejected by shared constraint: do not put the rejected value into the agent-visible error. |

## Constraints discovered

1. **Publisher code regex:** `error.code` must match `^[A-Za-z0-9_.-]{1,64}$` or the whole response downgrades to `handlerFailed`. The existing `"invalidArguments"` code passes. (`lib/src/transport/webmcp_native_publisher.dart` line 414)
2. **Publisher details size:** `details` must JSON-encode to ≤ 64 KB and pass `_normalizeJson`. A two-key string map is orders of magnitude below the limit. (`lib/src/transport/webmcp_native_publisher.dart` lines 14, 505–510)
3. **No value, message, or stack in details:** The product contract and the shared constraints forbid echoing the caller input, a free-form message, or a stack. Only a closed enum and an allowlisted key may appear.
4. **`const` constructors cannot carry dynamic data:** Making the constructor accept a field key forces it off `const`. All existing `throw const WebMcpInvalidArgumentsException()` call sites must be updated.
5. **`_decodeValue` does not receive the field key:** It currently receives only the `WebMcpInputField` (which carries `field.key`) and the raw value. Passing the key is straightforward via the `field.key` property already present.
6. **Unknown-key and missing-key detection sites have the key in scope:** `webMcpDecodeArguments` iterates `arguments.keys` (unknown) and `fields` (missing), so the key is available at both throw sites. (`lib/src/webmcp_typed_input.dart` lines 76–88)

## Unresolved

- [UNRESOLVED: What exact Dart identifier should the reason enum use? `DecodeFailureReason`, `WebMcpDecodeFailureReason`, or something else? The naming convention for package-public enums has not been checked for this work item.]
- [UNRESOLVED: Should the `field` property on the exception be surfaced as part of the public API contract documented in `webmcp-contract.md`, or only through the wire `details` map? This affects what must be frozen before implementation.]

## Sources

| Source | Consulted |
|---|---|
| `lib/src/webmcp_typed_input.dart` | 2026-10-02 |
| `lib/src/webmcp_exceptions.dart` | 2026-10-02 |
| `lib/src/transport/webmcp_native_publisher.dart` | 2026-10-02 |
| `wiki/product/webmcp-contract.md` | 2026-10-02 |
| `test/registry_test.dart` | 2026-10-02 |
| `test/webmcp_public_surface_test.dart` | 2026-10-02 |
