---
id: webmcp-contract
title: WebMCP product contract
status: active
owner: unassigned
last_verified: 2026-09-25
applies_to: ["lib/**", "example/**", "README.md"]
summary: Product constraints for manual tools, declared-field decoding, automatic single-view pages, generated domain actions, and experimental native Chrome publication.
---

# WebMCP product contract

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
exceptions unchanged, including `WebMcpToolException`. A tool has exactly one
of `handler` and `callHandler`. Local invocation and page dispatch pass a null
execution signal. The optional native publisher adds its own JSON boundary.
It maps an accepted `WebMcpToolException` to an allowlisted error and omits
the exception message and stack. A code or details value outside the publisher
limits becomes the existing handler-failed object. Other handler exceptions
stay sanitized failures. That mapping does not change local invocation.

Descriptors make an unmodifiable shallow copy of the input schema map. Later
changes to the caller's outer map do not change the descriptor, but referenced
nested objects remain shared. The schema is descriptive; the registry performs
no runtime JSON Schema validation. Declared-field decoding is a separate check.
It runs only for a tool built from a field list, and it does not read the
schema map. The log hook records event kind and tool name only. A hook
exception does not change registration, invocation, or publication.

## Flutter lifecycle

An action is exposed because the developer explicitly declares it. Mounting a
`WebMcpAction` inside a `WebMcpScreen` scope registers it for that mounted
lifetime. Omitting or unmounting it removes the exposure. The wrapper renders
the identical child and does not inspect children, discover buttons, or infer
actions from the widget tree.

The registered descriptor's name, description, input schema, title,
annotations, and origin list are fixed at the initial mount. Rebuilding the
same action state with new descriptor values does not reconcile the
registration; unmount and mount a new action to change them. A
`WebMcpAction` has exactly one of `onInvoke` and `onCall`. Its handler calls
the newest callback of the kind chosen at the first mount.

A mounted wrapper remains directly invokable even when its child is visually
hidden or disabled. Child state neither disables the tool nor grants authority
to invoke it. Applications that need invocation to be unavailable must omit or
unmount the wrapper and apply their own authorization checks.

## Automatic page lifecycle

One application-owned `WebMcpAppSession` registers a stable
`<appId>.app.observe` endpoint. Each selected `WebMcpPage` registers bounded
read and act endpoints for its mounted lifetime. Every participating Navigator
has a distinct forwarding `WebMcpNavigatorAdapter`; adapters do not replace
consumer observers. Persistent branches require explicit selection evidence,
and root-modal relationships must be declared.

Page eligibility requires exactly one Flutter view, an unambiguous semantic
boundary owned through that view's `PipelineOwner`, a current route, complete
settled Navigator evidence, and any supplied explicit activity evidence.
Covered, inactive, ambiguous, unknown-transition, unwrapped-modal, and disposed
scopes are revoked. Owner replacement revokes before listener rebinding and
recaptures before exposure. Navigation signals prove activity only; they never
replace the semantic page boundary.

Reads return one immutable revision window with opaque mount-bound handles,
explicit coverage, and bounded pagination. Acts revalidate page, mount,
revision, handle identity, current semantic availability, enabled state,
action availability, and policy immediately before dispatch. Dispatch,
visible semantic change, domain Future completion, and explicit backend
confirmation are separate evidence kinds.

Obscured editable values and sensitive or excluded subtrees are omitted.
Bounds, editable value disclosure, `setText`, and long press require explicit
policy. Observation metadata excludes labels, values, route names, raw state,
arguments, results, exceptions, and stacks.

## Generated domain actions

`webmcp_flutter_generator` emits sources only for public instance methods
annotated with `@WebMcpDomainAction`. Generated adapters accept a
consumer-created live instance and remain owned by the consumer's
`WebMcpScope` or page source list. They do not construct services, intercept
arbitrary calls, or replace authorization.

Generated schemas and strict decoders support strings, booleans, safe JSON
integers, finite doubles, enums, nullable forms, and recursive lists and
string-keyed maps. Unknown fields, invalid values, unsupported signatures, and
duplicate generated names fail safely before the domain method runs.

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

WebMCP is an experimental browser surface and may change. Property detection
alone is not proof that the native API works.

`WebMcpNativePublisher` additively mirrors the local registry to the
same-origin native surface. It snapshots existing tools, observes later
registry changes, owns only registrations it created, cleans them through
registration abort signals, and preserves manual/custom transport behavior.
Browser input and output are bounded JSON. Handler errors and invalid payloads
become allowlisted safe failures without logging descriptors or payloads.

Chrome 152 page conformance establishes registration, discovery, direct
invocation, cleanup, cancel-before-dispatch, cursor recovery, and navigation
receipts for JavaScript and Wasm. The native publisher forwards the browser
execution AbortSignal to an author call handler. The library does not
terminate or replay that handler. A null title, debugging hint, or origin
list is omitted from the registration object. An omitted debugging hint is
not sent as false. Tool-start and tool-cancel events notify listeners and do
not invoke, abort, or replay a handler. `toolchange` is not application-state
delivery.

The integrated release JavaScript fixture additionally completes
discover-observe-read-act-navigate-receipt-observe-read and rejects the covered
page after application observation identifies only the destination scope. The
equivalent Wasm fixture currently fails because application observation retains
the covered home scope. Wasm automatic-page lifecycle support is therefore not
delivered, despite the lower-level Wasm publisher conformance results.

Native-agent support remains unproven. The isolated official Inspector profile
has no Gemini credential, and direct `executeTool` or WebDriver-selected calls
cannot substitute for the required authenticated natural-language,
model-selected trace.

## Deliberate omissions

Multiple-Flutter-view operation, positive observation waits, generated route
wrapping, generalized service proxies, framework-specific state adapters,
custom data providers, Chrome web platform-back-gesture support, in-flight
callback termination, deep schema immutability, transactional source
registration, notification rollback, and automatic cleanup of custom
transports are not delivered. Non-web hosts can register and invoke locally.
Native publication on those hosts reports the browser unavailable, and
`registerTool` on the non-browser boundary does not throw. That is not
support for automatic pages, browser agents, or multiple Flutter views.

Consumers must keep names unique across simultaneously mounted scopes, retain
application authorization, install every required Navigator adapter, and own
session, publisher, scope, generated adapter, and custom transport cleanup.

## References

- [Chrome WebMCP overview](https://developer.chrome.com/docs/ai/webmcp)
- [Chrome WebMCP origin trial announcement](https://developer.chrome.com/blog/ai-webmcp-origin-trial?hl=en)
- [Automatic page-agent work item](../work/0008-automatic-page-agent/STATE.yaml)
- [Work item 0004 plan](../work/0004-flutter-webmcp-skeleton/01-plan.md)
- [Work item 0004 frozen criteria](../work/0004-flutter-webmcp-skeleton/02-criteria.md)
- [Release decisions](../work/0005-pubdev-release-readiness/21-release-decisions.md)
