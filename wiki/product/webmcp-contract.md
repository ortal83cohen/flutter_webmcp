---
id: webmcp-contract
title: WebMCP product contract
status: active
owner: unassigned
last_verified: 2026-09-10
applies_to: ["lib/**", "example/**", "README.md"]
summary: Product constraints for explicit Flutter WebMCP actions, local registry semantics, lifetime ownership, and detection-only browser integration.
---

# WebMCP product contract

`webmcp_flutter` is a local Dart registry for explicitly declared Flutter web
actions that may later be exposed as WebMCP tools. The process-wide
`WebMcp.instance` registry is the source of truth. `WebMcpScope`,
`WebMcpScreen`, and `WebMcpAction` add ownership and Flutter lifecycle behavior
over that registry; they do not create a separate registry.

## Product boundary

Tool names are used exactly as declared and must contain 1 to 128 ASCII
letters, digits, underscores, hyphens, or periods. They form one global
namespace across live screens. A duplicate is deterministic: the first live
registration remains active, while a later scope records the name as skipped
and does not acquire ownership. A scope can remove only names it owns. Closing
a scope removes its owned tools, clears its skipped-name diagnostics, is
idempotent, and permanently prevents new tools or sources from being added.

Registration and invocation are local. Sources register their descriptors in
the order returned. Registration is not transactional: tools successfully
registered before a later invalid or duplicate descriptor remain registered.
Local invocation returns or awaits the handler's value and propagates handler
exceptions unchanged. The package does not create a browser-safe result
envelope, normalize values, filter errors, or define an invocation logging and
privacy boundary for a browser bridge.

Descriptors make an unmodifiable shallow copy of the input schema map. Later
changes to the caller's outer map do not change the descriptor, but referenced
nested objects remain shared. The schema is descriptive; the registry performs
no runtime JSON Schema validation.

## Flutter lifecycle

An action is exposed because the developer explicitly declares it. Mounting a
`WebMcpAction` inside a `WebMcpScreen` scope registers it for that mounted
lifetime. Omitting or unmounting it removes the exposure. The wrapper renders
the identical child and does not inspect children, discover buttons, or infer
actions from the widget tree.

The registered descriptor's name, description, and input schema are fixed at
the initial mount. Rebuilding the same action state with new descriptor values
does not reconcile the registration; unmount and mount a new action to change
them. Its handler does call the newest widget `onInvoke` callback.

A mounted wrapper remains directly invokable even when its child is visually
hidden or disabled. Child state neither disables the tool nor grants authority
to invoke it. Applications that need invocation to be unavailable must omit or
unmount the wrapper and apply their own authorization checks.

## Custom transports and reset

Registry mutations precede custom transport notifications. If
`onToolRegistered` throws, the tool remains registered. If
`onToolUnregistered` throws, the tool remains removed. The notification
exception propagates to the caller and no rollback occurs.

`WebMcp.instance.reset()` clears local registry state and installs the supplied
transport or a new platform default. It does not send unregistration
notifications to, detach, or dispose the previous transport. The transport
interface has no disposal hook. A consumer that supplies an externally
stateful transport owns cleanup of that external state before reset.

## Browser boundary

WebMCP is an experimental browser surface and may change. The built-in web
transport observes only whether the browser document has a `modelContext`
property. Property presence is a capability hint, not proof that the native API
works.

The current package does not publish Dart tools to the browser, receive
browser-originated invocations, discover or execute browser tools, subscribe to
browser tool changes, or perform browser-side unregistration. Its detection
and registry-change logs do not constitute publication. Attach-time
synchronization, repeated adapter attachment, cancellation, pending handles,
origin exposure, titles, typed decoders, annotations, advanced support status,
wire validation, safe errors, and browser invocation logging and privacy rules
remain deferred with the browser bridge.

## Deliberate omissions

Navigation-tool generation and router composition are deferred to a future
adapter. Automatic widget discovery, per-screen shadowing, dynamic descriptor
or enabled-state reconciliation, deep schema immutability, runtime schema
validation, transactional source registration, notification rollback,
automatic cleanup of custom transports, output schemas, development-time
transports, and non-web product support are outside version 0.1.0.

Consumers must keep names unique across simultaneously mounted screens and
manage authorization, wire safety, error disclosure, and custom transport
cleanup at their integration boundary. A future publishing implementation must
preserve the ownership and collision rules documented here or revise the
contract through a separately validated change.

## References

- [Chrome WebMCP overview](https://developer.chrome.com/docs/ai/webmcp)
- [Chrome WebMCP origin trial announcement](https://developer.chrome.com/blog/ai-webmcp-origin-trial?hl=en)
- [Work item 0004 plan](../work/0004-flutter-webmcp-skeleton/01-plan.md)
- [Work item 0004 frozen criteria](../work/0004-flutter-webmcp-skeleton/02-criteria.md)
- [Release decisions](../work/0005-pubdev-release-readiness/21-release-decisions.md)
