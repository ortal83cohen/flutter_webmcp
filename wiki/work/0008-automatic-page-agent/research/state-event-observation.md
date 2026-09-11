# Research: State and event observation for an automatic page agent

## Question

What is the lowest-boilerplate way to expose page-content and navigation changes to an agent without treating rendering signals as business completion or assuming WebMCP delivers application events?

## Answer

Use Flutter semantics as the mandatory content invalidation source, route lifecycle as the mandatory activity/navigation source, and one revisioned pull broker behind the page tools. A semantics notification or completed frame means only that a fresh projection may be captured; completion of an action requires an explicit domain terminal signal or a later read that satisfies the caller's stated condition.

Do not use WebMCP `toolchange` for application state. It is fired when tool exposure changes, and the draft explicitly says its timing relative to other task sources cannot be relied on. The viable agent-facing fallback is a bounded `read` long-poll (or a thin `waitForChange` alias) carrying an opaque cursor, timeout, cancellation, and gap recovery.

## Findings

### Flutter has a public semantics-change signal

- `SemanticsOwner` is a `ChangeNotifier`; holding `SemanticsBinding.ensureSemantics()` creates/keeps the owner, and `addListener` observes changes. `sendSemanticsUpdate` calls `onSemanticsUpdate` and then `notifyListeners`, so the listener observes a flushed semantics update rather than an arbitrary widget rebuild. Sources: [SemanticsOwner](https://api.flutter.dev/flutter/semantics/SemanticsOwner-class.html), [sendSemanticsUpdate](https://api.flutter.dev/flutter/semantics/SemanticsOwner/sendSemanticsUpdate.html).
- PROPOSED: acquire one semantics handle per mounted wrapper, attach to that wrapper's current `PipelineOwner.semanticsOwner`, and rebind if owner creation/disposal changes. Each notification marks the scoped projection dirty; it does not serialize mutable `SemanticsNode` objects into an event.
- PROPOSED: coalesce repeated notifications and capture one immutable, privacy-filtered snapshot after the relevant frame. A notification is authoritative invalidation even if the filtered projection hashes equal; publishing may suppress a duplicate content event while still resolving a waiter as `unchanged`.

### Frame boundaries are capture boundaries, not completion signals

- `SchedulerBinding.endOfFrame` completes after the current/next frame and schedules a frame when called while idle; `addPostFrameCallback` runs once after the rendering pipeline flush and cannot be unregistered. `endOfFrame` may wait indefinitely when frames are not produced. Sources: [endOfFrame](https://api.flutter.dev/flutter/scheduler/SchedulerBinding/endOfFrame.html), [addPostFrameCallback](https://api.flutter.dev/flutter/scheduler/SchedulerBinding/addPostFrameCallback.html).
- PROPOSED: use a cancellable wrapper-owned deadline around `endOfFrame`, plus mounted/mount-token checks when it resumes. Disposal cannot cancel Flutter's callback, so the callback must become a no-op.
- A frame, a semantics notification, an unchanged projection, or a quiet interval proves neither network completion nor successful persistence. PROPOSED: an act receipt means dispatch only; business completion is established by an explicit application-supplied status stream/listenable with a terminal predicate, a terminal domain-tool result, or a subsequent read meeting an agent-specified observable condition.

### Navigation must invalidate exposure before content recapture

- `NavigatorObserver` reports top-route changes, pushes, pops, removals, replacements, and gestures. These callbacks describe Navigator history; custom routers, nested navigators, indexed stacks, and overlays still need an explicit activity adapter. Source: [NavigatorObserver](https://api.flutter.dev/flutter/widgets/NavigatorObserver-class.html).
- PROPOSED reconciliation order: (1) on a navigation/activity callback, synchronously mark any covered scope inactive and invalidate its handles; (2) append a sanitized `navigation` event; (3) schedule a scoped semantics capture; (4) only after the new scope is active and captured append `contentChanged`. The content event records `causedByCursor` for the navigation event when known.
- PROPOSED: navigation events contain route-safe application IDs and transition kind only. Route names, arguments, URLs, labels, and stack dumps require explicit policy because they can contain user data. An unprovable route relationship is `inactive/unknown`, never assumed visible.

### Generic Dart observers minimize integration burden

- `Listenable` supports add/remove listener and `ValueListenable` adds a synchronous current value. These are dependency-free adapter seams for activity, domain status, and application revision signals. Source: [Listenable](https://api.flutter.dev/flutter/foundation/Listenable-class.html).
- PROPOSED minimal adapter inputs: optional `Listenable changeSignal`, optional `ValueListenable<PageActivity> activity`, and optional `Stream<PageEvent>` for explicitly modeled events. Subscriptions are established outside `build`, replaced on identity change, and cancelled on disposal. Signals cause reconciliation; their values are never serialized automatically.
- PROPOSED: streams preserve source order but may emit faster than frames; the broker assigns its own cursor and applies bounds. Stream completion means only source closure unless the application marks it as a business terminal event.

### Bloc and Riverpod belong in optional, version-pinned adapters

- Bloc 9.1.1's `BlocObserver.onChange` and `onTransition` run before bloc state updates; `onDone` reports completion of an event handler, which still need not mean a business workflow completed. Source: [BlocObserver 9.1.1](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocObserver-class.html).
- Riverpod 3 uses `ProviderObserverContext` in `didUpdateProvider`; observers attach to `ProviderScope`/`ProviderContainer`, and mutable values can make previous/new references identical. This differs from Riverpod 2's callback signature. Source: [Riverpod ProviderObservers](https://riverpod.dev/docs/concepts2/observers).
- Neither dependency exists in this repository. PROPOSED: keep them out of core; later adapter packages must pin/test supported major versions, filter explicit bloc/provider identities, emit invalidations rather than values, chain any existing global observer, and document container/scope coverage. Global observation must never expose every state object by default.

### WebMCP has no application-event delivery guarantee

- The draft fires `toolchange` when exposed tool registrations change and warns that its timing relative to other task sources is unreliable. Chrome describes it as notification that the list of available tools changed. Sources: [WebMCP draft](https://webmachinelearning.github.io/webmcp/#notify-documents-of-a-tool-change), [Chrome imperative API](https://developer.chrome.com/docs/ai/webmcp/imperative-api#events).
- Therefore a content revision must not register/unregister tools merely to wake an agent, and the page must not assume a browser agent subscribes to any custom DOM event. WebMCP remains the invocation transport; application changes are returned through tools.

## Recommended protocol (PROPOSED)

### Minimal core

1. Retain the plan's stable `page.read` and `page.act` tools. Extend `page.read` with optional `afterCursor` and bounded `waitMs`; `waitMs = 0` is an immediate snapshot. A separate `page.waitForChange` may be a thin alias only if real-agent testing shows clearer discovery, not a second state system.
2. Maintain `mountToken`, monotonic page `revision`, and monotonic broker `cursor`. A response contains the current filtered snapshot plus zero or more sanitized event envelopes `{cursor, mountToken, revision, kind, causedByCursor}`.
3. Admit at most one long-poll per agent/session key and impose configured maximum waiters, timeout, event count, and response bytes. Timeout returns `changed: false`; cancellation removes the waiter. Neither condition dispatches actions or implies completion.
4. Keep a bounded ring buffer of metadata-only events. Content labels, values, action arguments/results, provider/bloc states, route arguments, errors, and stack traces are excluded. Coalesced `contentChanged` events carry counts/reasons and revision, requiring `read` for content.
5. If `afterCursor` predates the oldest retained event, belongs to another mount, or cannot be decoded, return `gap: true`, the current cursor/revision, and `refreshRequired: true`; never guess omitted events. The next full read re-establishes state.
6. Serialize broker publication so cursors are total-ordered locally. Source timestamps are advisory only. Navigation invalidation wins over a pending old-scope capture; mount-token checks discard late callbacks.

### Optional adapters

- Core `Listenable`/`ValueListenable` and `Stream` inputs need no state-management package. BlocObserver and Riverpod ProviderObserver adapters are separate opt-ins with explicit allowlists and major-version test matrices.
- An application may provide typed terminal events with a correlation/request ID and terminal status. The broker may surface that status after policy filtering, but never infer terminal success from UI calm, handler return, frame completion, or observer quietness.

## Options considered

| Option | Cost | Decision |
|---|---:|---|
| Poll every read | Repeated capture; delayed changes | Retain as universal immediate fallback. |
| Semantics/navigation invalidation plus bounded long-poll | Small broker and lifecycle work | Chosen minimal core. |
| Register/unregister on every state change | Tool churn and wrong `toolchange` semantics | Reject. |
| Global Bloc/Riverpod observation in core | Dependencies, privacy risk, version coupling | Reject; optional filtered adapters only. |
| Quiet-frame completion heuristic | False success for asynchronous work | Reject. |

## Unknown proof gates

- [UNRESOLVED: Does the supported Flutter 3.47+ matrix preserve listener timing and owner rebinding across multiple views, semantics disable/enable, and route transitions in release mode?]
- [UNRESOLVED: What long-poll duration, waiter count, event/byte caps, and ring depth remain responsive in real supported browsers? Proposed bounds are not benchmarks.]
- [UNRESOLVED: Does the selected native browser agent permit a tool call to remain pending, propagate AbortSignal cancellation, and reliably issue a fresh read after timeout/gap?]
- [UNRESOLVED: Can ordinary and root-navigator overlays be mapped safely without an application activity adapter?]
- [UNRESOLVED: Which Bloc and Riverpod major versions, if any, merit maintained adapters after consumer demand is measured?]

## Sources

Official Flutter API, WebMCP Community Group draft, Chrome WebMCP documentation, Bloc API, and Riverpod documentation above; consulted 2026-09-10. Repository `pubspec.yaml` was inspected to confirm there is no Bloc or Riverpod dependency.
