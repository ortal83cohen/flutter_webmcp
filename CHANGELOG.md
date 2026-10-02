# Changelog

## 0.1.10 - 2026-09-26

- Automated patch release from main.

## 0.1.9 - 2026-09-25

- Add automatic single-view page semantics, guarded actions, navigation
  observation, bounded application receipts, and native Chrome publication.
- Add optional annotation and generator packages for consumer-owned live
  domain service instances.
- Preserve manual registry, scope, widget, transport, and custom transport
  behavior.
- Forward the browser execution signal to an author call handler. The library
  does not terminate or replay that handler.
- Send a tool title, debugging hint, and origin list only when the author sets
  them. An omitted debugging hint is not sent as false.
- Report browser tool-start and tool-cancel events without invoking or
  stopping a handler.
- Add declared-field decoding for manual tools. Free-form input schemas stay
  descriptive and are not validated at runtime.
- Map `WebMcpToolException` to an allowlisted agent error on the native
  publisher. Local invocation still throws that exception.
- Add a log hook that records the event kind and tool name, without arguments,
  results, schemas, messages, or stacks.
- Allow local registration and invocation on non-web Flutter platforms. Native
  publication there reports the browser unavailable.

## 0.1.8 - 2026-09-17

- Automated patch release from main.

## 0.1.7 - 2026-09-16

- Automated patch release from main.

## 0.1.6 - 2026-09-16

- Automated patch release from main.

## 0.1.5 - 2026-09-11

- Automated patch release from main.

## 0.1.4 - 2026-09-11

- Automated patch release from main.

## 0.1.3 - 2026-09-11

- Automated patch release from main.

## 0.1.2 - 2026-09-11

- Automated patch release from main.

## Unreleased

- Derive a descriptive input schema from a declared field list when the author
  leaves the schema empty on `WebMcpTool.withDecodedArguments` or
  `WebMcpAction` with fields. A non-empty author schema is kept unchanged.
- Report manual decode failures with a top-level field key and a closed reason
  of missing, unknown, or type. The native publisher forwards those two
  strings in the invalid-arguments details map without the rejected value,
  message, or stack.
- Let `WebMcpAction` decode declared fields through `onCall` only. Pairing a
  field list with `onInvoke` throws at construction.
- Extend `@WebMcpDomainAction` with optional title, debugging, and exposedTo.
  Emit each member only when set; an omitted debugging hint is not sent as
  false.

## 0.1.1 - 2026-09-10

- Add the public GitHub repository link to package metadata.

## 0.1.0 - 2026-09-10

- Add a local WebMCP tool registry with asynchronous invocation.
- Add explicit Flutter widget and scope lifecycle integration.
- Add detection-only browser transport for `document.modelContext`.
- Add a runnable web example, contract tests, and release checks.
