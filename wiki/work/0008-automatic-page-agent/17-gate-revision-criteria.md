# Acceptance criteria: Empirical gate revision

## Frozen

- Frozen at: 2026-09-10, after plan review round 03 and the closure of its blocker F-001.
- Frozen by: main agent (root), recorded in STATE.yaml under revision_3.
- The implementation yardstick is the combined contract in 02-criteria.md, 14-observation-criteria.md, and this file. Existing identifiers remain stable. Only the clauses expressly superseded below are replaced.
- Changing a criterion from this point requires a recorded validation round, not a silent edit.

## Existing identifier retention

| ID | Status in combined contract |
|---|---|
| AC-001 | Retained except its requirement to prove functional multiple-view support before implementation; that clause is superseded by AC-031. Owner-replacement proof timing is superseded by AC-032. |
| AC-002 | Retained except invocation cancellation after callback start and the implication that native-agent proof blocks development; those clauses are superseded by AC-029 and AC-030. |
| AC-003 | Retained as refined by AC-019. |
| AC-004 | Retained unchanged. |
| AC-005 | Retained as refined by AC-021 and AC-032. |
| AC-006 | Retained as refined by AC-019, AC-020, AC-031, and AC-033. |
| AC-007 | Retained; its cancellation negative case means cancel-before-dispatch only at the Chrome browser boundary. Post-dispatch behavior is governed by AC-029. |
| AC-008 | Retained unchanged. |
| AC-009 | Retained unchanged; its semantic traversal evidence remains separate from AC-027 component proof. |
| AC-010 | Retained unchanged. |
| AC-011 | Retained except the phrase requiring propagation of invocation cancellation after callback start. Cancel-before-dispatch remains required; post-dispatch capability and behavior are superseded by AC-029. |
| AC-012 | Retained unchanged; generator scope remains required for its delivered stage. |
| AC-013 | Retained unchanged; generator lifecycle and authorization remain required. |
| AC-014 | Retained, but its decisive trace and permitted proof source are superseded by AC-030 and AC-035. |
| AC-015 | Retained and extended by AC-029 through AC-033. |
| AC-016 | Retained as previously narrowed by AC-026. It does not require termination of already dispatched application work; AC-029 governs browser cancellation and bounded local tracking. |
| AC-017 | Retained unchanged. |
| AC-018 | Retained unchanged; neither generator nor provider scope is silently removed. |
| AC-019 | Retained unchanged. |
| AC-020 | Retained except that platform-back-gesture proof is not an MVP prerequisite when unknown gesture state fails closed; AC-033 supersedes that clause. |
| AC-021 | Retained except pre-implementation owner-replacement proof timing; AC-032 moves decisive proof to implementation verification and fixes revoke-before-rebind ordering. |
| AC-022 | Retained; immediate polling is the supported baseline and positive waits remain unsupported until separately proved. |
| AC-023 | Retained unchanged. |
| AC-024 | Retained unchanged. |
| AC-025 | Retained unchanged. |
| AC-026 | Retained unchanged and interpreted with AC-029: app-owned bounded receipt delivery may survive page disposal, but no browser or library cancellation claim terminates an already started callback. |
| AC-027 | Every numeric ceiling and fail-closed rule is retained unchanged. Its requirement that all component caps pass the feasibility spike is superseded by AC-034, which requires decisive exact-limit and one-over-limit proof during implementation verification. |
| AC-028 | Retained; its native support and completion evidence clause is strengthened and superseded by AC-030 and AC-035. |

## Clause-level supersession rules

AC-029 replaces only cancellation-propagation and in-flight-termination clauses in AC-002, AC-007, AC-011, AC-016, AC-022, AC-026, and the corresponding browser lifecycle text in the prior plans. It does not weaken cancel-before-dispatch, registration cleanup, scope revocation, local delivery cleanup, bounded resource use, safe errors, or no-post-disposal-dispatch requirements.

AC-030 replaces only the rule that absence of a native agent trace prevents publisher implementation. It continues to block every native support, delivery, publication-documentation, release, and completion claim until authenticated proof exists.

AC-031 replaces only functional multiple-view support and pre-implementation multiple-view proof. It requires detection and fail-closed behavior and does not permit a global, ancestor, or other-view fallback.

AC-032 replaces only the timing of PipelineOwner and SemanticsOwner replacement proof. It makes owner replacement an implementation requirement and verification gate, without allowing exposure before a replacement is safely rebound.

AC-033 replaces only the requirement to prove Chrome web platform-back gestures for the MVP. It preserves immediate revocation for known gestures and requires inactivity for unknown gesture or transition state.

AC-034 replaces only the phase in which the non-semantic AC-027 component limits receive decisive proof. It does not change a value, permit raising a ceiling, or convert a failure into a warning.

AC-035 replaces the shorter AC-014 and AC-022 trace descriptions with the complete required sequence and proof source. It does not reduce any unsupported-browser, stale-handle, privacy, lifecycle, or manual-fallback negative case.

## New criteria

| ID | Criterion | How it is checked | Negative case |
|---|---|---|---|
| AC-029 | When the Chrome publisher reports invocation capabilities, it shall distinguish registration-signal cleanup, cancel-before-dispatch, and invocation cancellation after callback start. For the tested Chrome 152 JavaScript and Wasm matrix, it shall report the first two as available and post-start invocation cancellation as unavailable. An admitted callback may continue after caller AbortError; the library shall prevent later dispatch and automatic replay, preserve only bounded local waiter/operation/receipt state, and never claim callback termination or side-effect prevention. | Re-run JavaScript and Wasm page conformance. One case aborts before executeTool dispatch and observes no callback or side effect. A start-aware case aborts only after synchronous callback start and observes no supplied invocation AbortSignal, continued callback settlement, honest capability output, bounded tracking, and no replay. Registration-controller abort removes the tool. | If diagnostics claim in-flight cancellation, if a cancelled caller causes automatic replay, if local tracking grows beyond its fixed caps, or if cleanup is described as terminating external work, the criterion fails even when the caller receives AbortError. |
| AC-030 | When page-conformance registration, invocation, cleanup, and observation pass but the isolated required inspector profile lacks Gemini authentication, implementation may proceed after plan validation and criteria freeze, while native publication remains marked unsupported and undelivered. Only an authenticated official-Chrome natural-language agent trace may promote that state to supported. | Inspect support-state tests and documentation, preserve the failed unauthenticated inspector attempt, then re-run the required isolated inspector profile with valid authentication before final verification. Confirm no support state changes before actual model-selected calls complete. | A disabled prompt, empty result, direct executeTool call, WebDriver/CDP-selected tool, manual execution, simulated transcript, or page-conformance-only run cannot produce a supported, delivered, released, or complete state. |
| AC-031 | When automatic semantics starts or the Flutter view set changes, the MVP shall expose page read/act only when exactly one Flutter view is present and the wrapper resolves through that view's owned PipelineOwner. Zero, multiple, ambiguous, or changed-unbound views shall revoke exposure and return a safe unsupported or boundary-unavailable capability reason without inspecting another view or a global root. | Single-view positive fixtures run on Flutter 3.47.0 and 3.47.3 in supported compiled modes. An implementation fixture supplies zero and more than one view, or an equivalent controllable view-provider seam, and verifies synchronous revocation, owned cleanup, and safe diagnostics. | With two candidate views, no page node, handle, action, or inactive-view identity is returned; no ancestor-wide, global-root, first-view, or other-view fallback is attempted. |
| AC-032 | When a page's PipelineOwner or SemanticsOwner identity changes, the runtime shall revoke eligibility and invalidate existing handles before detaching the prior owner, reject callbacks from the prior owner or mount generation, bind the replacement only after old listener removal, and recapture a valid single-view boundary before re-exposure. | An implementation-level owner-provider fixture changes PipelineOwner and SemanticsOwner identities during pending capture and after a read. It records ordering, listener counts, stale-handle rejection, late-callback suppression, successful replacement recapture, and repeated cleanup. | No read or act may use the old owner between change detection and replacement capture; an ambiguous/missing replacement stays unavailable; no global owner fallback or duplicate listener survives. |
| AC-033 | When Chrome web supplies no proved platform back gesture or when gesture/transition state is unknown, affected scopes shall remain inactive and stale handles shall be rejected. The product shall not advertise platform-back-gesture support until a separate real supported-environment trace proves start, interruption or completion, revocation, and safe reactivation. | Known observer gesture callbacks verify immediate revocation in controlled tests. Chrome integration verifies that absent gesture evidence does not create a support capability. Unknown, interrupted, and unresolved transition fixtures remain inactive until independently proved settled. | A completed frame, elapsed timeout, missing callback, animation quietness, or browser history change alone cannot turn unknown gesture/transition state active or support a gesture claim. |
| AC-034 | When the broker, Navigator adapter registry, waiter pool, queued capture scheduler, event ring, response encoder, operation tracker, and capture deadline exist, implementation verification shall retain and prove every AC-027 ceiling at the exact limit and one over it. Semantic returned/visited/depth/byte evidence from 04-semantics-spike.md supports only that subset. No unavailable pre-component feasibility result may be reported as a pass. | Component owners run exact-limit, one-over-limit, cancellation-removal, timeout, ring-eviction, whole-event encoding, operation-expiry, outstanding-execution-slot, and no-frame tests. Final verification archives raw outputs and confirms configuration can only lower each ceiling. | Any missing applicable boundary test, eviction of a live owner to admit excess, dispatch before busy/resourceLimit, freeing a never-settled execution slot on receipt expiry, raising a ceiling, or treating an unrun check as passed blocks the corresponding support and completion claim. |
| AC-035 | Before native publication support, delivery, release, or work-item completion is claimed, an authenticated natural-language agent in official Chrome using the required isolated inspector profile shall perform, in order, discover, observe, read, act, navigate, receive the app-owned dispatch receipt, observe the newly eligible page, and read that page. The trace shall preserve model-selected tool calls, visible permitted effect, mount/revision changes, and exact environment details. | Run the required inspector with valid Gemini authentication against the final JavaScript and, if claimed supported, Wasm build. Archive the prompt, Chrome and extension versions, capability state, ordered tool calls and bounded outputs, receipt, post-navigation observe, final read, and unsupported-browser manual fallback. | Missing authentication, a skipped sequence step, a simulated or manually selected call, direct in-page execution, stale/inactive handle acceptance, absent receipt, failure to observe/read the destination, or substitution of another browser leaves native support, delivery, release, and completion blocked. |

## Positive and negative contract interpretation

Every retained criterion keeps its original positive and negative checks unless a row above explicitly replaces the affected clause. A positive result for a narrowed capability cannot satisfy a broader superseded claim. In particular, cancel-before-dispatch does not prove in-flight cancellation; one-view success does not prove multiple-view support; observer method compilation does not prove a platform gesture; page conformance does not prove native agent usability; and semantic traversal bounds do not prove broker or operation caps.

The optional generator remains a separately verifiable delivered stage under AC-012, AC-013, AC-018, AC-024 through AC-026, and the existing task plan. A runtime MVP can be reported as an MVP stage only when its applicable criteria pass; it cannot be reported as full work-item completion while generator criteria remain in declared scope and incomplete.

## Explicitly not required

Functional multiple-Flutter-view support in the MVP; Chrome web platform-back-gesture support without evidence; propagation of an invocation AbortSignal after a Chrome 152 callback starts; termination of already running application or external work; positive wait support without a later supported-environment proof; simulated native-agent proof; or changing any AC-027 value before measurement.

All original exclusions remain. This revision does not publish, deploy, release, or claim support. Implementation against this frozen contract is authorized; support and completion claims are not.

## Verdict log

No implementation review has occurred for this revised contract.

| Round | Date | Verdict | Report |
|---|---|---|---|
