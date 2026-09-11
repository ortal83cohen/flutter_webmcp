# Research: Low-code action and effect observation

## Question

Which public Flutter mechanisms can observe page activity with low consumer boilerplate, and what can each mechanism truthfully prove to a page-agent bridge?

## Recommendation

Use layered, opt-in evidence rather than one claimed universal listener. The page wrapper should own semantic reads and agent-originated semantic dispatch receipts. It may install a page-scoped `ActionDispatcher` for applications that route commands through `Actions`, and accept explicit `Listenable`/controller/notification sources to trigger fresh reads. Generated adapters remain the only low-boilerplate path that can await selected domain methods. Backend-confirmed success must come from an application-provided domain signal.

Do not describe any layer as intercepting arbitrary `onPressed` callbacks or instance-method calls. Record five separate milestones: `inputObserved`, `commandDispatched`, `visibleEffectObserved`, `domainFutureCompleted`, and `backendConfirmed`. Only emit a milestone when its own evidence exists; never infer a later milestone from an earlier one.

## Evidence boundaries

- `Actions` maps `Intent` types to `Action` objects. `Shortcuts` and `Actions.invoke` can reach the enclosing `ActionDispatcher`; therefore a custom dispatcher supplied to the page's `Actions` scope can observe invocation and its immediate return value. Descendants may introduce a nearer dispatcher, and `GestureDetector`, button `onPressed`, direct callbacks, and service method calls do not have to use this path. Sources: [Action](https://api.flutter.dev/flutter/widgets/Action-class.html) and [ActionDispatcher](https://api.flutter.dev/flutter/widgets/ActionDispatcher-class.html), consulted 2026-09-10.
- `ActionListener`/`Action.addActionListener` reports changes to an `Action` object's state when the action calls `notifyActionListeners`; it is a lifecycle helper, not an invocation listener. It cannot establish that an action ran or succeeded. Source: [Action](https://api.flutter.dev/flutter/widgets/Action-class.html), consulted 2026-09-10.
- `SemanticsBinding.addSemanticsActionListener` is genuinely binding-wide, but only for each `SemanticsActionEvent` received from the platform. Listeners run before `performSemanticsAction`. It can observe accessibility-originated requests, not their outcome, and a direct `SemanticsOwner.performAction` call does not create such an event. Agent-originated dispatch must be recorded in the page bridge's own call path. Source: [addSemanticsActionListener](https://api.flutter.dev/flutter/semantics/SemanticsBinding/addSemanticsActionListener.html), consulted 2026-09-10.
- A `SemanticsOwner` is a `ChangeNotifier` for semantic-tree updates and exposes `performAction`. An owner notification proves that the semantics projection changed, not which input caused it, whether an async operation completed, or whether a backend accepted anything. Source: [SemanticsOwner](https://api.flutter.dev/flutter/semantics/SemanticsOwner-class.html), consulted 2026-09-10.
- `GestureBinding.pointerRouter` routes engine pointer events after hit testing, including global routes. It observes low-level input coordinates/buttons before gesture-arena meaning is settled; it cannot prove which recognizer won, which callback ran, or whether a semantic/keyboard/programmatic action occurred. A subtree `Listener` has the same raw-input limitation with narrower hit-test scope. Source: [GestureBinding](https://api.flutter.dev/flutter/gestures/GestureBinding-mixin.html), consulted 2026-09-10.
- `NotificationListener<T>` sees only descendant `Notification` objects of the selected type. `ScrollNotification` gives scroll lifecycle/metrics and bubbles with depth; it is emitted after build/layout and does not itself establish the initiating command or business result. Custom notifications require application cooperation. Source: [ScrollNotification](https://api.flutter.dev/flutter/widgets/ScrollNotification-class.html), consulted 2026-09-10.
- `TextEditingController` notifies listeners after user edits and also after programmatic value/text changes. Generic `Listenable` sources similarly announce only that their owner chose to notify. They are useful invalidation signals for a fresh semantic read, but provenance and success require separate evidence. Source: [TextEditingController](https://api.flutter.dev/flutter/widgets/TextEditingController-class.html), consulted 2026-09-10.

## Coverage matrix

| Mechanism | Catches | Misses / cannot prove | Integration cost |
|---|---|---|---|
| Page semantic snapshot + owner listener | Current permitted semantic projection; later visible semantic changes | Non-semantic state, cause, Future completion, backend success | One page wrapper; isolation spike remains mandatory |
| Bridge-owned semantic dispatch | Exact agent request admitted and handed to current semantics handler | Completion or effect after synchronous dispatch | No extra consumer code after wrapper |
| Binding semantics-action listener | Platform/accessibility semantics requests, before dispatch | Direct owner dispatch; callback completion; effect/success; page ownership without node resolution | One global registration plus view/node-to-scope filtering |
| Page-scoped custom `ActionDispatcher` | `Actions`/`Shortcuts` commands routed through that dispatcher; immediate return object | Plain callbacks, nearer dispatchers, direct methods, async result unless explicitly awaited | Wrapper insertion; app gains coverage by adopting `Intent`/`Action` |
| `ActionListener` | Action availability/state notifications emitted by that action | Invocation and result | Per action instance; poor general telemetry choice |
| Pointer router / `Listener` | Raw pointer input globally / within hit-tested subtree | Gesture winner, callback, keyboard, semantics, programmatic work, success | Low code, high ambiguity and privacy volume |
| `NotificationListener<ScrollNotification>` | Descendant scroll lifecycle and metrics | Arbitrary taps/actions; reliable causality; domain result | One wrapper for scroll visibility only |
| Controller or supplied `Listenable` | Declared state/text notifications, including programmatic changes | Cause unless source models it; unregistered state; backend truth | Consumer supplies selected sources and lifecycle |
| Generated instance adapter | Agent invocation of annotated method; returned value/Future completion | Calls made directly on original instance; unannotated methods; backend truth beyond method contract | Annotation, generator dependency, generated source registration |
| Opt-in generated proxy | Calls made through the proxy's forwarding interface; can await/log each wrapper | Existing references to original instance, self-calls on original, static/top-level calls | Highest adoption cost: callers must receive proxy/interface |

## Generated wrappers and direct calls

Annotations and builders can generate descriptors, decoders, forwarding methods, and Future-aware receipts. They do not alter an already-created service object or automatically reroute call sites to a generated wrapper. Dart's `noSuchMethod` is invoked for nonexistent/unimplemented members, not as a hook around concrete methods. Consequently, interception requires an explicit generated proxy/decorator and dependency injection of that proxy everywhere coverage is required; any retained original reference bypasses it. Source: [Object.noSuchMethod](https://api.dart.dev/dart-core/Object/noSuchMethod.html), consulted 2026-09-10.

The current repository already confirms the opt-in boundary: `WebMcpAction` registers only its own explicit handler while mounted, and `WebMcpScreen` only owns scope lifetime. Neither wraps a child's callback nor observes service calls. Evidence: `lib/src/widgets/webmcp_action.dart:11-80` and `lib/src/widgets/webmcp_screen.dart:5-40`, inspected 2026-09-10.

## Proposed low-code contract

1. The wrapper publishes semantic content and actions and logs only agent dispatch admission/receipt by default.
2. An optional page `ActionDispatcher` observer reports framework commands that traverse it, with source marked `frameworkAction`; it never claims total page-action coverage.
3. Optional declared observation sources (`Listenable`, text/scroll controllers, or typed notifications) invalidate the current snapshot and may supply application-defined effect metadata. Identity and disposal remain explicit.
4. Generated adapters expose selected domain methods and await returned Futures. A completed Future means only that method's contract completed; errors remain method failures.
5. A separate domain confirmation source reports backend-confirmed state using application-defined identifiers. Correlation to a request must be explicit, bounded, and privacy-filtered.
6. Diagnostics publish a coverage manifest naming active observers and known gaps so an agent can distinguish unavailable evidence from failure.

## Unresolved spikes

- Verify on Flutter 3.47.0 and the selected upper version whether an outer page `Actions(dispatcher: ...)` observes Material controls that use internal intents, and enumerate controls that bypass it or install nearer dispatchers. `[UNVERIFIED]`
- Verify ordering and node/view correlation for binding semantics-action listeners versus owner notifications and bridge-owned direct dispatch, including multiple views and disposal. `[UNVERIFIED]`
- Measure pointer/global listener overhead and privacy exposure before offering diagnostics; it should not be enabled by default. `[UNVERIFIED]`
- Prototype one generated interface proxy and prove direct-original calls and self-calls bypass it; decide whether that adoption cost justifies a public proxy API. `[UNVERIFIED]`
- Define the smallest typed confirmation interface that can distinguish domain Future completion from backend acknowledgment without logging sensitive payloads. `[UNVERIFIED]`
