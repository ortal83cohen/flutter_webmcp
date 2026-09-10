# Plan: Empirical gate revision for automatic page agents

## Goal

Replace the failed all-or-nothing feasibility assumptions with an honest implementation contract grounded in 04-semantics-spike.md and corrected 05-transport-spike.md. After a fresh blind validation and criteria freeze, an implementer can build a single-Flutter-view automatic page surface and Chrome publisher without claiming invocation-time abort after dispatch or native-agent support before authentication-backed proof. Existing security, privacy, ownership, manual fallback, observation, generator, measurement, and fail-closed obligations remain in force.

## Approach

Treat the semantics and transport results according to what they establish. The six semantics runs establish the marker-based core on Flutter 3.47.0 and 3.47.3 in debug, profile, and release, so implementation can use that core for one Flutter view. Multiple views are a deliberately unsupported MVP configuration: detect them and disable automatic exposure. Owner replacement becomes an implementation lifecycle requirement with revoke-before-rebind verification. Unknown gesture or transition state remains inactive and creates no gesture-support claim.

Treat Chrome 152 page conformance as sufficient to implement registration, discovery compatibility, invocation, safe wire handling, registration cleanup, cancel-before-dispatch, immediate observation, cursor recovery, and navigation receipts for JavaScript and Wasm. Treat the corrected post-start cancellation result as a contract correction: Chrome supplied no invocation AbortSignal after callback start, so the publisher must expose that capability honestly, must not promise in-flight cancellation, and must never replay an admitted operation automatically. Library-owned tracking stays bounded even when application work cannot be terminated.

Separate implementation permission from support and delivery. Missing Gemini authentication in the isolated inspector profile is the sole blocker to native natural-language proof, not evidence that page publication cannot be implemented. Development may proceed after plan validation and criteria freeze, but native publication remains unsupported and undelivered until the authenticated Chrome-only discover-observe-read-act-navigate-receipt-observe-read trace succeeds. Direct in-page calls, automation-driven tool choice, manual execution, or simulated output cannot satisfy that gate.

Retain the AC-027 protective values. The semantic traversal subset already has evidence; broker, waiter, queued-capture, and operation components must prove exact-limit and one-over-limit behavior during implementation verification because they did not exist during the feasibility spike. This changes proof timing, not the limits or fail-closed behavior.

## Precise supersession of 01-plan.md

This plan supersedes the following clauses of 01-plan.md and no others:

1. In Approach, the sentence that release-mode isolation and real-browser transport spikes gate the public API freeze is narrowed. The completed marker and page-conformance evidence permits a single-view implementation contract to freeze after fresh plan validation. Native support and delivery, not implementation, remain gated by the authenticated native-agent trace.
2. In Steps 1 and 3, proof of functional multiple-view traversal before implementation is replaced by mandatory multiple-view detection and fail-closed rejection. The tested single-view marker core is the implementation basis. PipelineOwner and SemanticsOwner replacement moves from pre-implementation feasibility to mandatory implementation verification with revocation before rebinding.
3. In Steps 2 and 3, cancellation propagation after callback start is removed as a required browser capability. Cancel-before-dispatch and registration-signal cleanup remain required. The missing authenticated native trace blocks the support and delivery claim, while page-conformance evidence permits publisher development.
4. Step 6's single requirement to publish the minimal example only after a real agent trace is split into two distinct obligations, because it otherwise reads as a development gate and contradicts the implementation permission granted above. Landing the minimal example in the repository is development work: it may be integrated and merged once page conformance passes, provided its documented status is experimental and explicitly unsupported and undelivered. Publishing it as a supported capability is a claim: any README, product contract, example description, release note, support matrix, or completion statement that presents the example as natively usable requires the full Chrome-only discover-observe-read-act-navigate-receipt-observe-read sequence with authenticated model-selected calls. The strengthened sequence therefore governs the support claim, never the merge of unsupported example code. This clause also supersedes the corresponding done-when condition of task 2.3 in 03-tasks.md and of task O2.3 in 15-observation-tasks.md: those tasks close on page-conformance evidence plus an explicit unsupported marking, while the authenticated trace is tracked separately and remains mandatory before any support, delivery, release, or completion claim.
5. In Activity and lifecycle, unknown gesture or transition state remains inactive. Chrome web platform-back-gesture support is excluded until separately proved.
6. In Revision, action, and error protocol, cancel-before-dispatch remains a no-side-effect result. The post-dispatch clause is replaced by the observed rule that the browser may reject the caller while the callback continues without an invocation AbortSignal. The bridge preserves bounded local operation and receipt state when possible, prevents later dispatch and replay, and makes no callback-termination claim.
7. In Native publisher and compatibility, the requirement to use invocation cancellation is replaced by capability reporting. Registration-lifetime cancellation and listener cleanup remain required. For Chrome 152 JavaScript and Wasm, invocation-time cancellation after callback start is reported unavailable.
8. In Risks and Verification approach, missing native authentication is a claim blocker rather than a development blocker. No other privacy, ownership, wire-safety, measurement, documentation, generator, or fallback clause is relaxed.

## Precise supersession of 13-observation-plan.md

This plan supersedes the following clauses of 13-observation-plan.md and no others:

1. Steps 1 through 3 no longer require multiple-view support, platform-back-gesture proof, complete AC-027 component proofs, or post-start browser cancellation propagation before implementation. They require single-view detection, unknown-state inactivity, retained caps, and later implementation verification.
2. Eligibility, dirty state and settling continues to revoke synchronously on known navigation and gesture signals. Because Chrome web produced no platform back gesture evidence, a missing or unknown gesture/transition relationship cannot reactivate a scope and cannot be documented as supported gesture handling.
3. Semantics owner attachment now has a fixed ordering: revoke eligibility and invalidate handles first, detach the old owner and reject its late callbacks second, bind the replacement owner third, and recapture before exposure. No global owner or root search is a fallback.
4. One bounded observation protocol keeps immediate polling as the supported baseline. Positive waits stay disabled unless separately proved by a supported native environment. Missing post-start invocation cancellation cannot be used to promise waiter or application-work termination.
5. Commands, evidence and disposal retains AC-026's app-owned receipt path, but clarifies that browser caller cancellation after dispatch may coexist with continued callback execution and side effects. Tracking expiry stops library retention and delivery only; it does not free an outstanding-execution slot until actual settlement and does not authorize replay.
6. The AC-027 ceilings in One bounded observation protocol and Commands, evidence and disposal remain numerically unchanged. Their decisive component-level boundary tests move to implementation verification.
7. Step 6 and the optional-adapter section continue to preserve the baseline generated domain adapter. The generator is not removed, converted into an implicit follow-up, or treated as delivered by the MVP.

## Implementation sequence

1. Submit 06-gate-decision.md, this plan, 17-gate-revision-criteria.md, and 18-gate-revision-tasks.md to a fresh blind plan validation. Resolve findings through the established workflow, then freeze the combined criteria. No runtime implementation starts before that freeze.
2. Implement the additive Chrome publisher and capability model through the existing publisher owner. Preserve the registry as source of truth, manual/custom transports, first-live ownership, safe wire boundaries, registration cleanup, cancel-before-dispatch, and local invocation behavior. Record post-start invocation cancellation as unavailable for the tested Chrome matrix.
3. Implement the single-view page session, distinct Navigator adapters, marker boundary, page read/act, app observe, privacy projection, broker, command admission, and operation receipts through the existing page owner. Before any exposure, detect the Flutter view count and fail closed unless it is exactly one.
4. Implement owner-change handling in the page lifecycle. Revoke and invalidate before detaching the previous owner, reject late callbacks through owner and mount generations, then bind and recapture on the replacement. Keep unknown route, branch, overlay, gesture, and transition state inactive.
5. Write the positive and negative tests with each component. Include exact-limit and one-over-limit tests for every AC-027 component when it exists, safe capability diagnostics, no-replay behavior, continued-callback behavior after caller abort, owner replacement, multiple-view rejection, unknown transition rejection, and forbidden metadata scans.
6. Integrate the minimal example and Chrome-only native trace fixture without claiming support. Authentication is not a prerequisite for this integration; page-conformance regression runs plus an explicit unsupported marking are sufficient to land the example, consistent with clause 4 of the 01-plan.md supersession above. Before final verification, configure authentication in the isolated required inspector profile and execute the complete natural-language trace. If authentication is still unavailable or any step is missing, retain the blocker, keep the example marked unsupported, and do not publish a support, delivery, or completion claim.
7. Preserve the optional generator stage after the runtime MVP. Solve and test its dependencies, generated live-instance adapter, supported type policy, lifecycle replacement, authorization, and optional operation-linked evidence exactly as required by AC-012, AC-013, AC-024 through AC-026, and the existing task ownership. Runtime MVP verification does not silently complete generator scope.
8. Run independent implementation verification against the frozen combined criteria, including the supported Flutter and Chrome matrices, the exact native trace, all resource boundaries, privacy scans, full repository checks, and wiki lint. Documentation may state only the stage and support matrix established by that evidence.

## Interfaces and shared decisions

The support state distinguishes local availability, browser capability detection, page-conformance usability, and authenticated native-agent support. A positive page-conformance result cannot be rendered or documented as native-agent support. Failure reasons are safe and contain no labels, values, arguments, results, route data, exception text, or stack traces.

The publisher capability model distinguishes registration-lifetime AbortSignal cleanup, cancel-before-dispatch, and invocation-time cancellation after callback start. Chrome 152 JavaScript and Wasm support the first two and did not supply the third. An already admitted callback can continue after the caller observes AbortError. The library may stop future dispatch and bounded delivery, but it does not claim to stop application work or prevent its external side effects.

The semantic MVP supports exactly one Flutter view. More than one view, no view, a changed unbound owner, a missing or duplicate marker, an unknown Navigator relationship, an unknown selected branch, an ambiguous modal, or unknown gesture/transition state disables automatic read and act. Explicit application-owned tools remain available according to their existing contract. No ancestor-wide, global-root, other-view, or stale-owner lookup is allowed.

The existing app cursor, page mount/revision, pagination cursor, request identifier, operation identity, evidence levels, response redaction, and ownership decisions remain as specified in 01-plan.md and 13-observation-plan.md unless explicitly superseded above. AC-027 values remain fixed design ceilings, not performance claims.

## Risks

The main lifecycle risk is exposing a stale semantics owner during replacement. Revoke-before-rebind ordering, owner-generation checks, listener cleanup, and negative tests mitigate it; any stale read or dispatch blocks support.

The main transport risk is presenting caller cancellation as application cancellation. Capability separation, continued-callback fixtures, bounded tracking, no replay, and receipt wording mitigate it; any in-flight termination claim fails verification.

The main product risk is treating conformance as native usability. A distinct support state and the authenticated Chrome-only natural-language gate mitigate it; an absent credential or incomplete sequence remains an explicit blocker.

The main resource risk is postponing component limits until implementation. Values are frozen before implementation, each component owner writes exact-limit and one-over-limit tests with the component, and final verification reruns them; any missing applicable proof blocks the corresponding support or completion claim.

## Rollback

Disable automatic page exposure, synchronously revoke eligibility, remove only owned page and observe endpoints, detach current semantics and Navigator listeners, clear bounded broker and delivery state, and detach browser registrations through their registration controllers. Retain existing explicit local tools, custom transports, application routing, and business data.

If publisher conformance regresses, mark native publication unavailable while preserving the local registry and manual application behavior. If semantics owner replacement or single-view safety fails, disable the automatic semantics surface rather than widening lookup. If the authenticated trace fails, leave the implementation experimental or unsupported and make no delivery claim. If generator work fails, retain handwritten WebMcpToolSource support and report the generator stage incomplete; do not erase its criteria or tasks.

All rollback decisions remain append-only in work-item evidence and validation records. No existing artifact is deleted or rewritten.

## Out of scope

Multiple-Flutter-view support, Chrome web platform-back-gesture support, in-flight termination of an already started browser callback, authenticated caller identity inferred from WebMCP, browser push events, automatic replay, universal callback interception, hidden or server-only data discovery, global semantics fallback, simulated native proof, and performance claims without measurement are outside the MVP.

This revision does not implement code, change dependencies, freeze criteria, alter STATE.yaml, publish packages, deploy, or release. It does not remove the optional generator or later custom-data-provider stage.

## Verification approach

Validate this revised plan and criteria blindly before freezing them. During implementation, run all existing AC-001 through AC-028 checks as narrowed only by the clause-level supersessions in 17-gate-revision-criteria.md, then run every new positive and negative check. Preserve exact commands, versions, and raw outputs.

Final native verification requires official Chrome only, the required isolated inspector extension profile, valid Gemini authentication, a natural-language prompt, model-selected tool calls, and the complete discover-observe-read-act-navigate-receipt-observe-read sequence. Page calls made directly by JavaScript, WebDriver, CDP, or a human remain useful conformance diagnostics but cannot satisfy native support.
