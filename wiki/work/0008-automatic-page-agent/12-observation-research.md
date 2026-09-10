# Research: Low-boilerplate page observation

## Question

How should the automatic page agent observe navigation, semantic content, actions, and state changes with low application boilerplate while preserving honest coverage and completion semantics?

## Answer

PROPOSED: retain the original opt-in semantic page boundary and add a scope-aware navigator forest, semantic invalidation/reprojection, and one page broker that dispatches only agent semantic actions and explicit domain tools. Navigator events identify candidate activity but cannot locate a page's semantics subtree; semantics remains the readable/actionable projection, and no public Flutter hook observes every `onPressed` or arbitrary method call.

PROPOSED alternatives share one broker: either `page.read` accepts an opaque `afterCursor` and bounded `waitMs`, or one stable application-scoped observe tool survives page disposal and reports the next opted-in active page. The plan must choose after agent/browser testing; it must not create two state systems. WebMCP `toolchange` concerns the tool catalog, not application state; a frame, quiet period, observer callback, dispatched command, or completed handler cannot be promoted to business success without matching evidence.

## Findings

### Navigation is a scope-activity signal, not the content source

- VERIFIED API: `NavigatorObserver` exposes top-route, push, pop, replace, remove, and gesture callbacks for the one Navigator it observes. The API does not claim that these callbacks identify a render/semantics subtree or transition completion. Sources: [NavigatorObserver](https://api.flutter.dev/flutter/widgets/NavigatorObserver-class.html), [didChangeTop](https://api.flutter.dev/flutter/widgets/NavigatorObserver/didChangeTop.html).
- PROPOSED: an application-level hub models a forest of Navigator identities; each root, shell, branch, or nested Navigator has its own forwarding observer. A parallel shell also supplies explicit active-branch state because a branch switch can restore an already-mounted Navigator without a push/pop. go_router exposes root, shell, and branch observer hooks and `StatefulNavigationShell.currentIndex`; implementation must pin/test the supported go_router version. Sources: [GoRouter](https://pub.dev/documentation/go_router/latest/go_router/GoRouter-class.html), [ShellRoute](https://pub.dev/documentation/go_router/latest/go_router/ShellRoute-class.html), [StatefulShellRoute](https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class.html).
- PROPOSED: navigation immediately marks affected scopes unsettled/inactive and invalidates handles, then schedules reconciliation after a frame. Read/act resumes only after route, branch, overlay, mount, and semantics-boundary evidence agree; missing or conflicting evidence fails closed.
- A Navigator observer alone cannot recover page content or ownership. `Route`/observer APIs expose navigation lifecycle, while the semantic boundary must still be installed around each opted-in page, directly or through an opt-in route-builder helper. Source: [Route](https://api.flutter.dev/flutter/widgets/Route-class.html).

### Semantics notifications trigger reprojection, not causal conclusions

- VERIFIED API: `SemanticsOwner` is a `ChangeNotifier`; `sendSemanticsUpdate` sends the update and then notifies listeners. This is a public invalidation hook after a semantics flush. Sources: [SemanticsOwner](https://api.flutter.dev/flutter/semantics/SemanticsOwner-class.html), [sendSemanticsUpdate](https://api.flutter.dev/flutter/semantics/SemanticsOwner/sendSemanticsUpdate.html).
- A notification does not prove that the privacy-filtered page projection changed, identify its cause, or establish an action/backend outcome. PROPOSED: coalesce notifications, recapture the owned boundary after the relevant frame, apply privacy/budget policy, compare immutable projections, and increment the content revision only for an observable permitted change.
- VERIFIED API: `endOfFrame` completes after a frame and may wait a long time when frames are not produced; post-frame callbacks run once and cannot be unregistered. PROPOSED: wrap capture waits in a deadline and discard late callbacks using mount tokens. Sources: [endOfFrame](https://api.flutter.dev/flutter/scheduler/SchedulerBinding/endOfFrame.html), [addPostFrameCallback](https://api.flutter.dev/flutter/scheduler/SchedulerBinding/addPostFrameCallback.html).

### There is no universal Flutter action observer

- VERIFIED API: `Actions` routes `Intent` objects through an `ActionDispatcher`, but descendant scopes can install nearer dispatchers. Plain button callbacks, gesture callbacks, direct methods, and service calls need not traverse this system. Sources: [Actions](https://api.flutter.dev/flutter/widgets/Actions-class.html), [ActionDispatcher](https://api.flutter.dev/flutter/widgets/ActionDispatcher-class.html).
- VERIFIED API: `SemanticsBinding.addSemanticsActionListener` receives platform semantics requests before dispatch; direct bridge calls through `SemanticsOwner.performAction` do not originate there. It is not an outcome listener. Source: [addSemanticsActionListener](https://api.flutter.dev/flutter/semantics/SemanticsBinding/addSemanticsActionListener.html).
- PROPOSED core: one page dispatcher records admission and dispatch receipts only for agent-originated semantic actions and explicitly registered/generated domain calls. It re-resolves current scope, revision, handle, policy, and advertised action immediately before dispatch. It does not claim to observe ordinary user callbacks.
- OPTIONAL: a page-scoped `ActionDispatcher`, selected notifications/controllers, or a generated proxy can add named coverage. Each adapter publishes its coverage limits; original service references and callbacks outside the adapter remain unobserved.

### Event delivery is bounded pull with explicit evidence levels

- VERIFIED API: the WebMCP draft fires `toolchange` when exposed tool registrations change and warns that its task timing relative to other sources is unreliable. Chrome describes it as a tool-list change. No cited browser contract streams custom page events to an agent. Sources: [WebMCP draft](https://webmachinelearning.github.io/webmcp/#notify-documents-of-a-tool-change), [Chrome imperative API](https://developer.chrome.com/docs/ai/webmcp/imperative-api#events).
- PROPOSED shared broker: a page-scoped long-poll keeps discovery local but disappears when navigation disposes that scope; an application-scoped stable observe tool can report the next opted-in active page across that gap but adds a global descriptor and cross-page privacy/ownership policy. Whichever interface is chosen reads the same revision/event broker; no duplicate queue or revision model is allowed.
- PROPOSED: `waitMs = 0` always provides immediate polling. A positive bounded wait is optional capability because native agents/browsers may not preserve pending tool calls. Cancellation removes a waiter, timeout returns unchanged, and neither causes side effects.
- PROPOSED: use a per-scope cap on total waiters and deadlines. WebMCP supplies no authenticated agent/session identity in the cited contract, so a caller token is untrusted correlation data only and cannot reserve capacity or authorize access.
- PROPOSED: a bounded ring buffer stores only cursor, mount token, revision, event kind, and safe causal cursor/counts. It excludes labels, values, route arguments/URLs, action arguments/results, state objects, errors, and stack traces. A cursor older than retained history, malformed, or from another mount returns `gap`, current revision/cursor, and `refreshRequired`; a full read reconciles state.
- PROPOSED evidence levels remain distinct: `inputObserved`, `commandDispatched`, `visibleEffectObserved`, `domainFutureCompleted`, and `backendConfirmed`. Only an explicit domain terminal result/signal or a later read satisfying a caller-declared observable condition establishes its corresponding completion level.

### Generic and toolkit adapters remain optional

- VERIFIED API: `Listenable` provides add/remove listener, and `ValueListenable` adds a current value. These can invalidate a snapshot without a state-management dependency; their notifications do not prove cause or success. Source: [Listenable](https://api.flutter.dev/flutter/foundation/Listenable-class.html).
- PROPOSED: core accepts optional, explicitly selected `Listenable`, `ValueListenable<PageActivity>`, or typed stream sources. Values are not serialized automatically; identity changes replace subscriptions and disposal cancels them.
- OPTIONAL/version-specific: Bloc observers run change/transition hooks before state update, while Riverpod 3 observers use `ProviderObserverContext` and container/scope attachment. Keep adapters outside core, pin/test major versions, filter explicit instances/providers, chain existing observers, and emit invalidation rather than raw state. Sources: [BlocObserver](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocObserver-class.html), [Riverpod ProviderObservers](https://riverpod.dev/docs/concepts2/observers).

## Options considered

| Option | Decision | Reason |
|---|---|---|
| Navigator forest + scoped semantics + central agent dispatcher + one bounded-pull interface | Choose, contingent on spikes | Covers navigation, content, and agent actions with explicit evidence boundaries. |
| Page long-poll versus stable application observe tool | Defer interface choice to spike | Page scope is simpler; application scope survives navigation. Both must use the same broker and immediate-read fallback. |
| Observer-only automatic page discovery | Reject | Navigation cannot identify the semantic subtree; action hooks are incomplete. |
| Global pointer/semantics/action interception | Reject | It reports input or selected framework paths, not arbitrary callbacks or outcomes, and expands privacy/volume risk. |
| Framework-specific state manager in core | Reject | Adds dependencies/version coupling and still cannot prove business completion. |
| Register/unregister tools on every state change | Reject | Misuses catalog lifecycle and creates tool churn. |
| Quiet-frame or debounce completion | Reject | Rendering calm is not application/backend completion. |

## Constraints discovered

- The original `00-research.md` remains the baseline and is not superseded; this is an append-only observation refinement.
- PROPOSED lowest common setup is one observer adapter per relevant Navigator, one opted-in boundary per exposed page (possibly inserted by an owned route builder), and no state adapter unless the application wants non-semantic/domain evidence.
- Route IDs, event metadata, sources, cursors, waits, buffers, snapshots, and logs require allowlists and hard bounds. Application authorization stays inside handlers.
- All Flutter/go_router behavior on the declared Flutter 3.47+ matrix, release mode, and supported router/browser versions is `[UNVERIFIED]` until the specified spikes run.

## Unresolved

- [UNRESOLVED: Can the navigator forest reconcile root/branch/nested observers, active branches, pageless/root overlays, redirects, browser history, and interrupted transitions without exposing a covered scope?]
- [UNRESOLVED: Does release-mode boundary isolation and owner rebinding work across semantics enable/disable, multiple views, navigation, overlays, and disposal on the supported Flutter matrix?]
- [UNRESOLVED: Which framework controls traverse an outer `ActionDispatcher`, and is that optional coverage valuable enough to maintain?]
- [UNRESOLVED: Does real-agent navigation favor a page-bound long-poll or one stable application observe tool, and can pending native calls survive navigation/cancellation?]
- [UNRESOLVED: What measured waiter, timeout, event, byte, and ring limits remain responsive, and does the supported browser agent propagate cancellation and recover from cursor gaps?]
- [UNRESOLVED: What smallest typed domain confirmation contract distinguishes Future completion from backend acknowledgment without exposing sensitive payloads?]

## Sources

- `research/navigation-observation.md`, `research/action-observation.md`, and `research/state-event-observation.md`, consulted 2026-09-10; each carries the primary Flutter, Dart, go_router, Bloc, Riverpod, WebMCP, and Chrome citations used above.
- `00-research.md`, retained baseline, consulted 2026-09-10.
