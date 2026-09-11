# Plan: Automatic page content and actions

## Goal

Let a Flutter application opt a page into agent access with one wrapper, so an agent can read the currently available semantic content and operate supported controls without a handwritten tool per widget. Add optional generated adapters for explicitly selected domain methods after that foundation works. Deliver only the implementation plan in this work item; all APIs, package splits, paths marked proposed, limits, and behaviors below are design decisions for future implementation, not existing capabilities or measured results.

## Approach

Keep the existing webmcp_flutter registry as the source of truth. Add an opt-in publisher that synchronizes its tools with the browser's native WebMCP surface, and a runtime page wrapper that owns a semantics boundary and registers two generic page tools. The wrapper reads the runtime accessibility projection after layout; it never crawls Dart source or claims to recover all application data. The native bridge is publisher-only.

Prefer composition to inheritance: the proposed WebMcpPage wrapper accepts a stable developer page identifier and the page child. On ordinary ModalRoute pages it derives current-route activity automatically. It may accept an explicit activity source for other navigation architectures, plus privacy policy and optional live domain sources. The consumer enables the proposed native publisher once at application startup and wraps each chosen page. The default flow needs no base class, screen mixin, per-control schema, annotation, or runner command.

Retain WebMcpScreen and WebMcpAction for existing explicit consumers. Do not change their current visibility or descriptor lifecycle behavior as a side effect. Advanced consumers can compose a page controller into their own state; do not introduce a second inheritance-based API in the MVP. Domain source instances are supplied during build, after application dependencies have been initialized, rather than through the existing early registerWebMcpTools hook.

The sequence is native bridge plus generic page semantics first, optional annotation generation second, and a custom data provider interface later. Release-mode isolation and real-browser transport spikes gate the public API freeze. An unsuccessful isolation gate falls back to explicit tools; an unsuccessful browser gate retains the existing local registry and reports that native publication is unavailable.

## Why this approach

The research artifact identifies the external flutter_webmcp package as an explicit tool publisher. The proposed differentiator is the useful live page read/act experience with minimal integration, plus transparent coverage diagnostics. Publication by itself does not provide that differentiator.

Source generation is useful for domain descriptors and decoding, but cannot discover mounted widgets, enabled state, lazy rows, or authorization. A generator-first design therefore fails the main requirement. DOM crawling is renderer-specific and cannot establish reliable Flutter ownership or complete application meaning. Explicit registration alone remains a fallback but preserves the integration burden. Inheritance would force a page architecture change for a capability that composition can provide. See 00-research.md for evidence and rejected alternatives.

## Steps

1. Prove the semantics boundary in an isolated fixture before production implementation. Touch proposed spike fixtures and evidence reports only. Exercise identifier-marked boundaries through the wrapper's own PipelineOwner, siblings, nesting, merged/excluded/blocked semantics, ordinary and root-navigator overlays, route transitions, disposal, and multiple views. Run debug, profile, and release using Flutter 3.47.0 and a selected upper test version. Record actual SDK artifacts and versions; installed Flutter 3.38.4 is research evidence only. If the declared SDK cannot be obtained, the gate stays blocked rather than changing the baseline silently.

2. Prove the native publisher independently in a minimal real-browser fixture. Establish the exact supported draft, browser version, flags or trial requirements, secure-context and permissions conditions, annotation mapping, callback/result/error shape, cancellation, registration lifetime, and JavaScript/WebAssembly support. Record unsupported combinations explicitly. A merely present document.modelContext property cannot pass. If no native browser agent or native harness can complete invocation, stop the native-support claim and retain manual/local behavior until that evidence exists.

3. Review the spike evidence and freeze the implementation criteria and supported matrix in a new recorded validation round. Narrow unsupported cases with explicit diagnostics and fallback; never broaden the semantic root to make a failing isolation test pass. If ordinary page isolation or route/modal safety is not reliable on the declared baseline, do not ship the automatic wrapper. This gate is future work and cannot be marked passed by this document.

4. Implement publisher ownership and wire safety around the existing registry and transport modules. Add an additive registry subscription mechanism for the bridge rather than replacing an application's custom transport. Mirror the initial registry snapshot and subsequent successful local mutations, preserve ordering and duplicate ownership, and expose attach/detach status. Add browser lifecycle, cancellation, failure, and existing-API regression tests with the implementation.

5. Implement the page controller, wrapper boundary, route activity, scoped semantics snapshot, privacy filter, revision management, and diagnostics in proposed page modules. Bind live semantics only after the relevant frame completes. Obtain and release the SemanticsHandle and listeners exactly once per mounted owner. Add scope, route, privacy, and release-isolation fixtures alongside the code.

6. Implement the versioned read/act protocol, bounded traversal/query/pagination, and guarded dispatch in those page modules. Register page tools through an owned WebMcpScope using the existing collision rules. Add stale-handle, disabled-node, duplicate-request, scroll-refresh, resource-limit, and action-race tests. Publish the minimal example only when the native discover-read-act-read acceptance trace succeeds.

7. Measure the MVP and document its tested matrix, omitted coverage, safe defaults, fallback, and lifecycle. Touch the example, README, product contract, and a new ADR together with the eventual implementation. Record full check and wiki lint output without turning unsupported environments or partial runs into passing evidence. Ship only the native bridge and generic semantic page surface at this stage.

8. After the MVP contract is stable, solve and prototype optional generator dependencies on the declared SDK/analyzer range. Add the proposed annotation and generator packages, generated live-instance adapters, positive/diagnostic fixtures, and consumer lifecycle examples. Stop this stage if dependency solving or analyzer compatibility fails; the runtime MVP must remain usable without it.

9. Evaluate a later explicit custom data provider design as a separate work item. It may expose server-side or unbuilt collection data with application authorization and independent pagination, but must never imply that semantics discovers that data. Do not add a placeholder provider protocol to the MVP.

## Interfaces and shared decisions

### Packaging and ownership

The existing webmcp_flutter package retains its manual API and gains the runtime wrapper plus conditional web publisher. Proposed internal areas are lib/src/page/ and additional modules under lib/src/transport/; these paths describe future files. Native imports remain conditional so unsupported platforms can keep local behavior.

The package names webmcp_flutter_annotations and webmcp_flutter_generator are PROPOSED, not existing packages. The annotations package contains metadata with minimal runtime dependencies; the generator is a development dependency using source_gen and build_runner after a successful dependency solve. Generated adapters import runtime WebMcpToolSource; the runtime package never depends on the builder. Build-time inputs do not select the active service instance.

Each page identifier must satisfy the existing tool-name alphabet and leave room for tool suffixes within 128 characters. Proposed tool names append .page.read and .page.act to that identifier. Identifiers must be unique across simultaneously mounted scopes. A conflicting tool follows first-live-registration-wins; diagnostics identify skipped names, and the page reports unusable automatic publication if either endpoint is skipped. The page withdraws only any companion endpoint it owns, without rolling back another scope's tools or changing general nontransactional source registration.

Sibling wrappers never share nodes. A parent stops at a nested wrapper's proven boundary and may report a child-scope reference without copying its contents; the nearest opted-in wrapper owns each node. A missing or ambiguous marker disables that scope with boundaryUnavailable. A scope always uses its own Flutter view and PipelineOwner; no global-root search may substitute for a failed boundary lookup.

### Activity and lifecycle

The wrapper defaults to its current ModalRoute only when the route relationship is provable. A covered route, unmounted wrapper, hidden page, or uncertain blocking overlay cannot expose content or actions. Outside a supported route context, activity must come from the explicit application activity source; the default is inactive. That source is responsible for router-specific overlays and indexed-stack selection and is documented as a trust boundary.

A wrapped modal is a distinct scope. An unwrapped blocking modal suspends the underlying page until it closes; it is not silently imported into the page subtree. The isolation spike must prove both ordinary and root-navigator modal coverage. Unsupported overlay arrangements fail closed for automatic exposure and require explicit application activity integration. No router-specific navigation tool generation is added.

The controller registers its two tools after acquiring a usable boundary and activity source. During temporary inactivity, discovery may retain those endpoint descriptors, but read and act return inactiveScope without page content; reactivation requires a new read. Disposal invalidates the mount immediately and removes owned endpoints, listeners, semantics handles, pending work, and domain sources. Mounting the same page identifier creates a fresh opaque mount token.

On rebuild, the child and handlers stay live; unchanged input identity does not re-register descriptors. A supplied source-list identity change releases that wrapper's previous source registrations and adds the new source instances in declared order. Skipped duplicate ownership is never inherited or removed. Avoid a source initialized after super.initState being consumed by WebMcpScreen.registerWebMcpTools; the build-supplied wrapper is the recommended generated-source integration.

### Read protocol

The proposed version-one read request accepts an optional query, allowed role/action filters, bounded limit, and opaque continuation cursor. A new read waits for an available completed semantics frame within a configurable deadline, then snapshots the owned materialized tree. If no usable frame arrives it returns snapshotUnavailable; it does not expose a partial frame. Cursor requests read the retained immutable snapshot and fail if its mount or revision changed.

The response contains protocolVersion, pageId, mountToken, revision, active, coverage, nodes, and nextCursor when present. Coverage names the materialized semantic window, partial/truncated flags, applied budgets, omission reason counts when known, and unknown coverage categories. It never claims the total logical row count from traversal. Activity failures return the safe error envelope instead of stale nodes.

Each node contains an opaque handle, optional parent handle, semantic role, permitted label and hint, permitted value, selected state flags, and an allowlisted action list. Selected flags include enabled, checked, selected, expanded, editable, and obscured when supplied by semantics. Bounds are opt-in view-relative geometry with the coordinate space identified. Flutter's numeric node IDs and internal marker values never become public handles.

Merged semantics produce one node, not reconstructed fictional children. Nodes omitted by filtering do not leave dangling parent handles; returned descendants refer to the nearest returned ancestor or no parent. Custom-painted content, platform views, excluded semantics, and unknown coverage produce diagnostics rather than inferred labels or actions.

Proposed default ceilings are 200 returned nodes per response, 1,000 visited nodes per captured window, depth 32, and 64 KiB UTF-8 serialized response size. Metadata counts toward the byte budget; no single oversized field may bypass it. A field can be omitted with a diagnostic rather than silently cut into a misleading value. Configuration may lower limits; raising them requires explicit application configuration within tested hard ceilings fixed by the resource spike.

Traversal stops at its capture budget. Query and filtering operate only on permitted fields in that captured window; they cannot search unbuilt or skipped rows. Pagination uses a snapshot-bound cursor over that same retained window, never a claim to enumerate the full tree or backing data. Retain only the current snapshot per scope. A query is literal normalized text matching, not an expression language or regular expression.

Scroll dispatch returns a receipt. The agent performs a fresh read after the next semantics update to discover newly materialized rows; old cursors and handles expire on revision change. If a scroll produces no semantic change, the next read explicitly reflects the unchanged revision and current window.

### Revision, action, and error protocol

Revision is a monotonic counter within a mount. Increment it when the permitted semantic projection, activity, privacy policy, domain-source identity, or action eligibility changes; unrelated Flutter rebuilds need not increment it. Before dispatch, compare the requested revision and re-resolve the handle within the current boundary, activity, privacy, and allowed action state. Never trust a node object captured by an earlier snapshot.

The act request carries pageId, mountToken, revision, handle, action, requestId, and the action-specific arguments. requestId is a positive monotonically increasing safe integer within the mount, supplied by the caller. Serialize admission within the mount and track the highest admitted identifier; lower or repeated identifiers are rejected without dispatch, except that the latest completed receipt may be returned for an exact repeat with identical arguments. Out-of-order clients refresh and select a higher identifier; overflow requires remounting. This bounds duplicate protection without retaining an unbounded identifier set.

The initial semantic action allowlist is tap, longPress, increase, decrease, and advertised directional scrolling. Toggle uses the node's advertised tap action rather than an invented toggle primitive. LongPress requires explicit page policy opt-in because its effect is often less apparent. Do not infer business safety from labels. Input mutation is a separate field-level opt-in and supports only advertised setText on a non-obscured editable node with bounded text; focus, clipboard, custom actions, selection, dismissal, and navigation synthesis are excluded from the MVP.

Immediately before dispatch, reject disabled, hidden, blocked, detached, out-of-scope, unadvertised, or unauthorized-by-policy actions. Run the final validation and dispatch synchronously relative to Flutter's event loop. A success receipt contains requestId, dispatched, and the observed revision; it means the semantic callback was dispatched, not that asynchronous business work succeeded. The next read establishes observable effects. Existing application confirmations remain in the UI and are never bypassed.

Page results use one versioned success or safe-error envelope. Error fields are code, safe message, retryable, and refreshRequired. Defined outcomes are invalidArguments, scopeGone, inactiveScope, boundaryUnavailable, snapshotUnavailable, staleSnapshot, invalidCursor, unknownHandle, unsupportedAction, actionUnavailable, policyDenied, duplicateRequest, busy, cancelled, resourceLimit, and internalError. Report scope and revision errors before node lookup to avoid leaking cross-scope identity; retryable never authorizes automatic action replay.

Cancelled-before-dispatch requests produce cancelled without side effects. Cancellation after semantic dispatch cannot undo the callback; preserve an accepted receipt when delivery is possible and require a fresh read rather than replay. Domain cancellation is cooperative only when the explicit application adapter supports it; generation does not promise to abort an arbitrary Future. Detach and disposal invalidate pending delivery and prevent any later dispatch owned by that scope.

### Privacy and diagnostics

Opting a page in permits its ordinary semantic labels and hints, so documentation must explain that applications remain responsible for marking sensitive text. Never claim that semantics can recognize every secret. Provide subtree exclusion and value/action policies at the wrapper boundary before serialization or search. Obscured or explicitly sensitive nodes are omitted by default; their values cannot be opted back in through generic discovery.

Editable values and input mutation are off by default. Explicit field-level allowlisting may expose a non-obscured editable value and allow setText separately. Noneditable semantic values follow the page disclosure policy. Errors and default logs contain reason codes, counts, tool identifiers, and support status, not labels, values, arguments, results, or stack traces. Unknown omissions remain unknown rather than invented counts.

Developer diagnostics enumerate unsupported browser/draft/build, inactive or ambiguous scope, collision, disabled action, privacy omission, unsupported semantic surface, traversal truncation, and unavailable semantics. A developer inspector may show sanitized structural metadata without enabling content logging. Diagnostics are available locally even when native publication fails.

### Native publisher and compatibility

The publisher subscribes additively to successful registry mutations and snapshots already registered tools at attachment. Registry remains authoritative; custom transport notifications and their existing exceptions remain unchanged. Subscription callbacks cannot roll back registry mutations or throw into existing registration callers. Browser-side failure leaves the local tool usable and marks publication failed with a safe reason.

Only one library publisher owns native registration for a registry instance. Repeated attachment returns the existing ownership state without duplicate browser registration; explicit detach is idempotent. Track browser ownership per tool so failed and skipped registrations cannot unregister another publisher's tool. Callers must detach the publisher before the existing reset operation; expose a convenience bridge-owned cleanup operation, and retain the documented custom-transport cleanup responsibility.

Map descriptors and JSON-safe invocations through conditional web interop. Input must be a bounded JSON object; page and generated tools enforce their own schemas at this boundary. Manual tools retain application-defined semantic validation, while the bridge enforces wire validity, depth, and size. Reject cyclic objects, unsupported runtime objects, non-string map keys, and non-finite numbers on output. Sanitize uncaught exceptions only for browser calls; local invokeTool keeps raw results and exceptions.

Use registration-lifetime cancellation and invocation cancellation separately, with per-call state and guaranteed listener release. Same-origin exposure is the default; cross-origin exposure is out of this stage. Advertise annotations only when the selected browser matrix supports their exact semantics; they are hints, never authorization. Mark support as detected, verified usable, unavailable, or failed with reasons. Do not implement getTools, executeTool, toolchange, or an agent loop in the publisher.

### Optional generated domain adapter

Consumers annotate chosen public instance methods, run the standard Dart builder, construct their service/controller normally, and supply the generated adapter bound to that instance to the page wrapper during build. Generated method names and explicit tool-name overrides must satisfy existing global naming rules. A missing description is a generation error. Public but unannotated methods remain private to the application surface.

The initial supported parameter and result shapes are String, bool, int within JSON safe-integer bounds, finite double, enum names, nullable variants, and recursively bounded lists or maps with String keys containing supported values. Methods may return these values, void, or Future of a supported result. Required and optional named arguments and positional arguments are represented by their declared parameter names; unknown arguments are rejected, and declared constant defaults are preserved. Void serializes to a successful null result.

Reject static/private methods, method type parameters, callbacks, arbitrary object types, streams, unsupported defaults, and custom serialization in the first generator version. Generation errors name the annotated method and unsupported type; runtime decoders reject missing required, wrong-type, excess, and out-of-range arguments before calling the live instance. Package dependency solving and output build compatibility remain unverified until the generator spike passes.

The generated adapter calls the live application method; it does not cache authorization or interpret read-only/destructive annotations as permission. Applications enforce current user authorization and confirmation inside domain handlers. A changed user role must affect the next invocation. A disposed or replaced source must be removed before its service is destroyed; asynchronous completion after disposal cannot revive registrations.

## Risks

| Risk | Likelihood | Impact | Mitigation | Trigger that means it happened |
|---|---|---|---|---|
| Public semantics cannot prove scope isolation on the declared SDK | Unverified | Cross-page disclosure | Mandatory release-mode isolation gate; explicit tools fallback | Ambiguous marker, overlapping ownership, or unsupported baseline |
| Overlay activity is incomplete | Unverified | Background data or action exposure | Fail-closed route policy and explicit activity source | Root modal or inactive indexed page remains invokable |
| Native draft/browser mismatch | Unverified | Tools appear available but cannot run | Real-browser spike, versioned matrix, safe unavailable status | Registration/invocation/cancellation differs from tested contract |
| Semantic labels contain sensitive text | Application-dependent | Unwanted disclosure | Explicit opt-in, exclusions, restricted editable values, safe logs | Synthetic sensitive fixture appears in any forbidden output |
| Large trees consume excessive resources | Unmeasured | Frame and memory pressure | Traversal/depth/byte budgets and measured release fixtures | Resource ceiling exceeded or uncapped traversal observed |
| Generated adapters outlive dependencies | Application-dependent | Invalid or unauthorized calls | Build-supplied instance sources, disposal tests, handler authorization | Old source executes after replacement or denied role change |

## Rollback

Ship automatic discovery and native publication as separately opt-in features. Disable the page wrapper to remove page endpoints and release semantics resources; detach the publisher to cancel native registrations and pending delivery, then use existing explicit local tools. Before registry reset, explicitly clean up the bridge and any application-owned stateful transport. Remove generator use without changing the handwritten WebMcpToolSource option. Retain existing artifacts and record supersession if a design is abandoned. No rollback requires removing application data or changing existing first-wins ownership.

## Out of scope

This request does not authorize runtime implementation, publication, a release, or product-contract changes. Later implementation does not promise all hidden/lazy/server content, arbitrary widget callbacks, DOM completeness, automatic business authorization, an in-page agent SDK, network MCP transport, custom provider delivery in the MVP, router navigation generation, arbitrary Dart serialization, or non-web native publication.

## Verification approach

Treat 02-criteria.md as a future observable contract and keep it unfrozen during planning. In implementation, pair every criterion with its positive and negative fixture, archive exact commands and output, and run an independent implementation validator against the frozen criteria and diff. Run the repository full check suite and wiki linter, plus the actual supported-SDK release/browser matrix. A registry-only mock or debug-only widget test cannot establish native agent usability or release isolation.

The decisive product trace is real agent discovery, page read, selection of a labeled supported control, guarded act, and a fresh read showing the effect. Also run unsupported-browser manual use, stale/foreign handles, disabled controls, covering modals, private inputs, scroll-refresh, source replacement, authorization revocation, duplicate attach, cancellation, and teardown. Measure latency, traversal cost, memory, and build overhead with environment and fixture sizes before making performance claims; proposed budgets are protective design limits, not benchmark results.
