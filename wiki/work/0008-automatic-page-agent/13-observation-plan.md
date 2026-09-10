# Plan: Low-boilerplate page observation

## Goal

Let a consumer expose selected live Flutter pages with one application session, lightweight navigation adapters, and semantic page boundaries, then let an agent observe permitted changes across navigation without writing a tool for each control. This is a planning-only, append-only revision. Every new interface, path, limit and behavior is PROPOSED; runtime feasibility and performance are [UNVERIFIED] until the evidence gates run. Retain 01-plan.md and 02-criteria.md; the precise supersession mapping is in 14-observation-criteria.md.

## Approach

Choose one application-scoped session/hub and one bounded metadata broker. Each relevant Navigator receives its own forwarding observer adapter; the hub combines the navigator forest, explicit branch selection, root modality, opted-in semantics boundaries, and centrally admitted agent commands. Keep the registry authoritative and the native publisher additive. Preserve WebMcpScreen, WebMcpAction, manual tools, custom transports, existing consumer Navigator observers and existing Actions dispatchers.

Keep the page read/act endpoints as the only automatic content/action surface. Add one stable app observe tool backed by the same broker; it remains registered across individual page disposal and returns metadata plus eligible opted-in scope references. Immediate polling is universal; a short positive wait is an optional transport capability gated by a real native browser-agent experiment. Choose this interface now rather than maintaining competing page-wait and application-wait protocols.

The MVP combines navigation, semantics invalidation/reprojection, and own command tracking. Generic selected state signals are optional integration points. Router-specific helpers, Flutter Actions observation, Bloc/Riverpod adapters, generated route wrapping and generated service proxies are later optional work; none is necessary for ordinary semantic read/act. Native release/transport and boundary-isolation gates from the baseline remain mandatory.

## Why this approach

12-observation-research.md distinguishes navigation lifecycle, semantic content and action evidence; no cited observer covers all three. Its deferred pull-interface choice is resolved here in favor of the stable application tool, subject to positive-wait feasibility rather than an undecided architecture.

| Alternative | Decision and reason |
|---|---|
| Shared session, per-Navigator adapters, scoped semantics and app observe | Choose: one owner survives page turnover and separates activity, content and execution evidence. |
| Page read long-poll | Reject as a second observation API: its registration can disappear during the navigation it reports. |
| Navigation observer alone or universal route injection | Reject: route callbacks cannot establish semantic subtree ownership; arbitrary consumers retain routing ownership. |
| Global pointer/semantics-action or callback interception | Reject as core: input paths neither cover arbitrary callbacks nor prove outcomes; they increase volume and privacy exposure. |
| State framework or generated proxies as core | Reject: dependencies and bypassable paths add burden without replacing semantic coverage. |
| Tool catalog churn, custom DOM push, or quiet-frame success | Reject: no app-state push guarantee or business-completion evidence follows from these mechanisms. |

## Steps

1. Extend future baseline semantics/navigation spikes with a root/nested/branch forest, explicit selected branch, root/pageless modality, interrupted transitions, semantics-owner changes, and navigation initiated inside an agent action. Touch only proposed spike fixtures and new evidence artifacts; prove fail-closed scope ownership on the declared supported release matrix before implementing runtime APIs.
2. Extend the native transport spike with the stable observe tool, immediate polling, optional bounded waits, cancellation, app/page remounts, cursor gaps and navigation receipt delivery. Record exact browser/draft/build versions and actual agent evidence. If positive waits fail, ship immediate polling only; if native invocation or isolation fails, retain manual fallback and block the corresponding automatic/native release claim.
3. Review both spikes, measure overhead and resource behavior, and record a fresh blind validation round before freezing original plus additional criteria. Preserve any unavailable declared SDK or failed check as a blocker. Changed ceilings or narrowed support require an explicit recorded plan/criteria revision, not implementation improvisation.
4. Implement additive publisher/registry integration through the existing baseline owner. Implement proposed session, navigator adapters, broker, scope eligibility and page projection together through one page-module owner, with tests. No shared registry/export/configuration edits run concurrently.
5. Implement guarded agent admission and app-owned operation receipts in those same page modules, then add the native discover-observe-read-act-navigate-observe-read example and positive/negative race fixtures. Document limits, coverage and rollback alongside that future implementation.
6. Only after MVP proof, implement optional filtered signal/router/Actions/state adapters or generation as separately named stages, each with versioned dependencies, declared coverage and its own fixtures. Preserve the baseline optional domain generator and later custom-data-provider sequence; do not claim absent stages ship.

## Interfaces and shared decisions

### Consumer setup and boundaries

The consumer enables the proposed application session and native publisher once, adds a distinct forwarding adapter alongside existing observers on every participating root/nested/branch Navigator, and wraps each selected page with its semantic boundary and safe developer page identifier. Ordinary supported ModalRoute pages derive route activity through the hub; parallel branches additionally supply the selected branch explicitly. Unsupported routing remains inactive until an explicit activity/modality source supplies the missing evidence. An owned route-builder helper may insert the wrapper; annotations may later generate those owned builders, but neither can retrofit arbitrary third-party routes. No per-control descriptors, inheritance, state framework or pointer listeners are required.

An adapter belongs to exactly one Navigator. Registration supplies opaque parent and navigator identities, root-modal relationships and, for persistent parallel branches, selected-branch activity. Missing or contradictory ancestry, selection or overlay evidence fails closed. The route signal narrows eligible scopes; the existing view/PipelineOwner-bound semantic marker proves node ownership and nearest-wrapper isolation. Never replace a failed boundary lookup with a root-tree search.

### Eligibility, dirty state and settling

Navigation, gesture start, branch selection and modality changes synchronously revoke affected eligibility and invalidate handles before scheduling a frame. Reconcile only when route/branch/overlay state agrees, the route transition or user gesture has demonstrably ended, the wrapper is mounted, and its semantics boundary is usable after a completed frame. Unknown transition state remains inactive. One frame, elapsed debounce or animation quietness cannot establish business completion. A root blocking modal suspends underlying branch scopes; a wrapped modal can expose its own proven boundary, while an unwrapped modal exposes nothing automatically.

Maintain separate content revision and eligibility generation. Reproject dirty scopes after a usable semantics frame, apply privacy and capture budgets, and compare immutable permitted projections before advancing content revision. Eligibility, privacy, source identity and action-policy changes invalidate admission immediately; the externally visible page revision also advances when these changes would invalidate a previous read, preserving AC-005. Unrelated rebuilds or unchanged filtered state do not invent semantic content events. Capture has a two-second deadline; no usable frame returns snapshotUnavailable. Late post-frame callbacks use mount/owner tokens and cannot revive disposed scopes.

Attach/detach semantics handles and SemanticsOwner listeners with owner lifetime, including semantics enable/disable and view/owner rebinding. Notifications mark affected scopes dirty; a global owner notification may dirty its bounded set of scopes, but only changed permitted projections emit content events. Coalesce at most one capture per scope per frame, not one projection per notification. Replaced subscriptions are removed before attachment to their replacement.

### One bounded observation protocol

The proposed version-one app observe tool belongs to a safe developer application identifier using existing name/collision rules and an observe suffix; one app session owns it. Collision leaves observation unavailable without removing the winner or changing manual/page ownership. Requests accept only an opaque app event cursor and bounded waitMs, plus an optional opaque scope reference filter. Responses contain protocol version, app mount, current cursor, eligible scope references, bounded safe events, unchanged/gap status, refreshRequired, partial-event metadata, and wait capability. Page read/act and pagination retain their existing contracts. Scope references use the page's opaque mount identity; agents correlate them with mountToken from page.read on discovered page endpoints, without exposing developer route names in observation metadata.

An app mount and event sequence define the observation cursor; a page mount/revision defines action freshness; a page pagination cursor addresses its immutable captured window. These identities are not interchangeable. No cursor starts at a guessed sequence: an initial observe returns the current cursor and eligible references. A malformed, foreign-app or evicted cursor returns gap, current cursor and eligible references with refreshRequired; the consumer rediscovers tools and performs fresh page reads. Page remount creates a new page identity without resetting the app cursor. App remount invalidates all old app cursors.

Store only bounded fixed event kinds, opaque identities, page revisions, safe codes/counts and explicit correlation metadata. For events whose page is no longer eligible, redact page identity/correlation and retain only a generic scope-change or gap indication; never disclose historical inactive scope references. Reserve response capacity for all currently eligible opaque references and mandatory metadata; add only whole events that fit, set partial metadata and advance the returned cursor only through the represented or explicitly redacted range. Never skip omitted retained events silently. Public tool names remain available through ordinary tool discovery, not event history.

These conservative hard DESIGN ceilings are not measured performance claims: 128 mounted scopes, 32 Navigator adapters, 256 ring events and 64 KiB total encoded ring storage, 32 events and 16 KiB per observe response including metadata, 8 pending waits per app and 2 per filtered scope, waitMs from zero to 1,000 milliseconds, one queued capture per scope, and 32 tracked operations retained no longer than 30 seconds. Generate opaque scope/mount identifiers with at most 32 ASCII characters so all active references and mandatory metadata fit the response ceiling; reduce event count to the remaining byte budget. Configuration can lower but not raise these ceilings. Keep baseline snapshot budgets. Reject excess live registrations with resourceLimit without evicting existing owners; reject excess waiters/operations with busy before side effects. Bound scope filters to one known reference and reject unknown request fields.

Unfiltered waits consume the app cap; filtered waits consume both app and referenced-scope caps. App changes wake unfiltered waits; filtered waits also wake on that scope's loss of eligibility. Cancellation removes the waiter without dispatch, timeout returns unchanged, and app detach terminates all waits. Unsupported positive waits return unsupportedAction with wait capability zero; clients use immediate polling. Browser cancellation propagation is [UNVERIFIED] until tested. Caller tokens and request identifiers are untrusted correlation, never authenticated native sessions, authorization or reserved quotas. No custom DOM event, toolchange notification or tool re-registration on semantic changes provides app-state delivery.

### Commands, evidence and disposal

Central admission covers agent semantic actions and explicitly registered/generated domain calls only. It preserves baseline request deduplication, synchronous final revalidation and application authorization. Human UI changes can dirty/revoke scopes without comprehensive input telemetry. Optional Flutter Actions adapters preserve the existing dispatcher/delegation result, publish coverage limits for nearer dispatchers, and do not claim that plain callbacks, direct services or original references pass through them.

Distinguish commandDispatched, visibleEffectObserved, domainFutureCompleted and backendConfirmed. A projection change following a command is temporal unless an explicit operation-linked application signal establishes causality. An ordinary Future completing is method completion, not backend confirmation. Backend confirmation requires an opted-in typed signal carrying the opaque operation identity and an allowlisted terminal outcome; never serialize domain payloads. Failed or timed-out operations cannot be promoted to success by a subsequent unrelated change.

The app session owns bounded operation tracking before dispatch, so a synchronous navigation callback may dispose its page while the invocation still returns its dispatch receipt. Page disposal immediately rejects queued or new dispatch, invalidates handles, removes tools and detaches sources/listeners; it does not destroy an already dispatched operation's sanitized receipt channel. An already-running domain Future may finish with allowed existing invocation output while the app remains attached; the event broker retains only safe status, never raw results or old page content. Operation retention ends on delivery/expiry and at most 30 seconds; timeout reports outcome unknown without replay, detaches observable subscriptions and discards late result delivery. Independently cap outstanding asynchronous domain executions at 32 per app session: receipt expiry/cancellation does not free an execution slot, only actual Future settlement does. Expired work retains an anonymous occupied slot, not page/result/operation history, so repeated timeouts cannot admit unlimited never-settling commands. Underlying uncancellable application work may continue even after app detach; these session-local caps do not bound externally launched work across app restarts. No termination claim is made. App detach invalidates delivery and clears session tracking. This explicitly supersedes baseline page-disposal cancellation of all pending delivery, not its ban on post-disposal dispatch.

### Optional adapters and privacy

Generic Listenable, ValueListenable and typed Stream bindings select explicit instances and convert notifications to dirty signals or separately allowlisted domain evidence. Never serialize values automatically. Keep go_router branch/root integration, Bloc and Riverpod observers in optional versioned adapters; chain existing observers, filter selected provider/container instances, account for notification-before-state-update timing and remove subscriptions on identity replacement. Generated proxies cover calls made through the proxy only. Baseline generator method/authorization restrictions remain unchanged.

Observation uses opaque aliases rather than unchecked developer identifiers and forbids labels, values, route names/URLs/arguments, action arguments/results, state objects, exception text and stacks in ring, observe metadata and default diagnostics. Scope visibility and page privacy rules apply again at response time. Domain result delivery stays in its authorized original invocation and uses existing bounded wire policy; it is never copied to observer logs. Current application authorization and explicit confirmation remain the handler's responsibility.

## Risks

| Risk | Likelihood | Impact | Mitigation | Trigger that means it happened |
|---|---|---|---|---|
| Incomplete forest/modal/transition evidence | [UNVERIFIED] | Covered-page exposure | Release matrix, explicit activity trust boundary and fail-closed eligibility | Background read/action succeeds or one frame restores eligibility mid-transition |
| Native pending calls do not survive navigation | [UNVERIFIED] | Lost receipt or observation | App-owned operation lifetime, real agent spike and immediate polling fallback | Navigation trace loses an admitted receipt or cannot rediscover active page |
| Notification storms or hung work | Unmeasured | Frame/memory pressure | Fixed caps, dirty coalescing, deadlines and late-result suppression | Resource one-over-limit or never-completing fixture exceeds its bound |
| Temporal change presented as success | Application-dependent | Incorrect agent decisions | Separate evidence kinds and explicit operation-linked confirmation | Human/UI change or method return is reported as backendConfirmed |
| Metadata leaks private history | Application-dependent | Cross-scope disclosure | Opaque identifiers, response-time eligibility filtering and synthetic-secret tests | Forbidden payload or inactive historical identifier appears on any path |

## Rollback

Disable the session's automatic feature, revoke eligibility, detach all adapters/listeners, clear broker/waits/operations and remove only owned observe/page endpoints. Remove route-builder wrapping or optional state/proxy adapters independently. Detach native publication before registry reset, preserving existing manual tools, transports, app routing and business data. Retain all planning/evidence artifacts and record supersession; no destructive rollback or publication is authorized here.

## Out of scope

No runtime edits, deployment or release in this request. No universal callback interception, automatic hidden navigator discovery, arbitrary third-party route wrapping, mandatory pointer listeners, business-completion inference, authenticated native agent sessions, custom browser state push, required state-management framework, or benchmark claims. Baseline exclusions and optional-stage boundaries remain.

## Verification approach

Use original AC-001 through AC-018 plus AC-019 through AC-028 and the positive/negative matrix in 15-observation-tasks.md. Preserve real release isolation and native discover-read-act-read proof, adding navigation during dispatch, subsequent app observation, cancellation, zero-wait fallback, cursor gap recovery, source replacement, root modals, gesture interruption, no-frame/hung-Future bounds and synthetic-secret inspection. Run the baseline full suite and wiki lint with exact output on the actual supported SDK and record measured overhead before release claims. Planning review cannot satisfy runtime gates.
