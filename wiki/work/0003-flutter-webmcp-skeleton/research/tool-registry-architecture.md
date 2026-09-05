# Research: Tool registry architecture for the Dart-side WebMCP API surface

## Question

For the Dart-side API surface of a WebMCP tool registry in a Flutter package, compare (A) a plain singleton / service-locator-style registration API (e.g. top-level `WebMcp.registerTool(...)`) versus (B) an `InheritedWidget`/`Provider`-style widget-tree-based registration mechanism (e.g. a `WebMcpTool` widget wrapping subtrees), on: minimum-integration ergonomics, testability without pumping a widget tree, fit for auto-generating navigation tools from `go_router` and from raw Navigator 2.0 `Router`/`RouteInformationParser`, and how cleanly each isolates the web-only JS-interop layer so that adding another platform/transport later is additive.

## Answer

A plain singleton/service-locator registry (Option A) is the better fit for this package's MVP scope: manual tool registration is a one-line call with no widget-tree dependency, it unit-tests with zero widget pumping, and it composes trivially with `go_router`'s own introspectable route table (`GoRouter.configuration.routes`, a plain `List<RouteBase>` — [pub.dev](https://pub.dev/documentation/go_router/latest/go_router/RouteConfiguration-class.html)) without needing a `BuildContext`. A pure widget-tree mechanism (Option B) is the wrong default because tool availability in WebMCP is a *capability* concern (what can the agent do right now) closer to a service registry than to visual state, and because raw Navigator 2.0's `Router`/`RouteInformationParser` exposes no framework-level static route table at all ([docs.flutter.dev](https://docs.flutter.dev/ui/navigation)), so nothing is gained by tying registration to widget lifecycle for that case. The recommended shape is Option A for the core registry, with an *optional* thin widget wrapper (`WebMcpToolScope`) layered on top purely for apps that want automatic un/registration tied to a subtree's lifecycle — i.e. Option C, a hybrid, not a third independent architecture.

## Findings

### go_router exposes a plain, non-widget route table

- Claim: `GoRouter` has a public `late final` getter `configuration` of type `RouteConfiguration`, and `RouteConfiguration` has a public getter `routes` of type `List<RouteBase>` ("The list of top level routes used by GoRouterDelegate"), reachable without a `BuildContext`.
- Evidence: fetched from the live pub.dev API docs for the `go_router` package, current published version 18.0.1.
- Source: https://pub.dev/documentation/go_router/latest/go_router/GoRouter-class.html, https://pub.dev/documentation/go_router/latest/go_router/RouteConfiguration-class.html, https://pub.dev/packages/go_router (version and publish date checked 2026-09-04).

### go_router does not offer a dedicated "enumerate all routes" convenience API beyond the raw tree

- Claim: There is no higher-level method that flattens `GoRoute`/`ShellRoute`/`StatefulShellRoute` into a single list of navigable paths+names; a consumer must recursively walk `RouteBase.routes` itself, and `StatefulShellRoute` branches are reached via `navigationShell.route.branches`.
- Evidence: pub.dev API documentation for the `go_router` topic pages and class docs contains no `flatten`/`allRoutes`/`enumerate` method; only the raw `routes` tree and per-branch access are documented.
- Source: https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html, https://pub.dev/documentation/go_router/latest/go_router/RouteConfiguration-class.html (checked 2026-09-04). `[UNVERIFIED: whether a future go_router release adds a flattening helper; not present as of 18.0.1]`.

### Raw Navigator 2.0 (`Router`/`RouteInformationParser`/`RouterDelegate`) has no framework-level static route table

- Claim: Flutter's own navigation documentation states that route information and the page stack are entirely app-defined and opaque to the `Router` widget; Flutter recommends using a declarative routing package (naming `go_router`) instead of hand-rolling `RouteInformationParser`/`RouterDelegate` precisely because there is no built-in declarative route registry to introspect.
- Evidence: "If you prefer not to use a routing package and would like full control over navigation and routing in your app, override `RouteInformationParser` and `RouterDelegate`." and "Flutter applications with advanced navigation and routing requirements... should use a routing package such as go_router."
- Source: https://docs.flutter.dev/ui/navigation (checked 2026-09-04). Consequence: for raw `Router` apps, auto-generating navigation tools requires the app itself to hand the package an explicit route table (there is nothing to introspect automatically); this is a constraint on scope, not something either Option A or B solves for raw Navigator 2.0.

### Widget-tree-based registration requires pumping a widget tree to unit-test

- Claim: Flutter's own testing documentation distinguishes plain (unit) tests, which instantiate a Dart object directly, from widget tests, which require `WidgetTester`/`pumpWidget` to provide "the appropriate widget lifecycle context" for anything depending on `build`, `didChangeDependencies`, or `InheritedWidget` resolution.
- Evidence: "Testing a widget involves multiple classes and requires a test environment that provides the appropriate widget lifecycle context... A widget test is therefore more comprehensive than a unit test."
- Source: https://docs.flutter.dev/testing/overview (checked 2026-09-04). Direct implication: if tool registration lives inside a `StatelessWidget`/`InheritedWidget`'s `build`/`initState`, testing "does registering a tool call the right JS-interop call with the right JSON schema" requires `tester.pumpWidget(...)` even though the thing under test (a schema + a callback) has nothing to do with rendering.

### `InheritedWidget` is the correct primitive for *tree-scoped* dependency propagation, not for a flat capability registry

- Claim: Flutter's widgets documentation describes `InheritedWidget` as the mechanism for propagating information efficiently down a widget subtree so descendants can depend on it and rebuild when it changes; Provider (built on `InheritedWidget`) is described as adding convenience and more scoped rebuilds on top of the same subtree-propagation model.
- Evidence: general Flutter state-management guidance frames both `InheritedWidget` and `Provider` around "data visible to descendants of a specific point in the tree," not around "a flat, tree-position-independent set of named capabilities."
- Source: https://docs.flutter.dev/data-and-backend/state-mgmt/simple (checked 2026-09-04, general framing); `[UNVERIFIED: exact wording varies by Flutter doc revision, but the subtree-scoping framing is consistent across the state-management pages]`.

### The framework's own precedent for "register a capability, invoked from outside, scoped to a subtree" is `Actions`/`Shortcuts`, and it is deliberately widget-tree-based

- Claim: `Actions` is "a widget that maps Intents to Actions to be used by its descendants when invoking an Action"; lookup is by `Actions.invoke()` finding "the Actions widget that most tightly encloses the given BuildContext" — i.e. nearest-ancestor-wins, tree-scoped registration, by design, so that different subtrees (e.g. a dialog vs. the page behind it) can offer different capabilities for the same named intent.
- Evidence: quoted from the live Flutter API docs for the `Actions` class.
- Source: https://api.flutter.dev/flutter/widgets/Actions-class.html (checked 2026-09-04). This is real ecosystem/framework precedent *for* Option B in cases where the same tool name must resolve differently depending on which screen is currently on top (e.g. "submit form" meaning something different per screen) — a scenario the MVP's manual-registration use case may eventually need, even though it is out of scope now.

### `get_it` is the ecosystem's dominant precedent for the plain singleton/service-locator pattern in Flutter

- Claim: `get_it` is a widely adopted service-locator package for Dart/Flutter (reported ~4.7K pub.dev likes, ~1.7M 30-day downloads, latest version 9.2.1 as of the source's February 2026 data point) that registers and resolves services with no `BuildContext` and no widget tree at all, and is commonly used specifically so that registration/resolution can be unit-tested without pumping any widget.
- Evidence: package metadata and community write-ups describing `get_it` as a "blazing-fast service locator" used to decouple service registration from the widget tree.
- Source: https://pub.dev/packages/get_it, https://github.com/flutter-it/get_it (numbers as reported by search-indexed pages checked 2026-09-04; treat the specific like/download counts as `[UNVERIFIED: exact current pub.dev counters, not re-fetched from the live pub.dev page directly]`). This is offered as ecosystem precedent for Option A's testability and integration-simplicity claims, not as a dependency recommendation — the package under research should not necessarily depend on `get_it` itself, only follow the same non-widget registration shape.

### `Provider`/`MultiProvider` precedent shows the widget-tree pattern is chosen when *lifecycle disposal scoping* is the actual requirement

- Claim: The Provider package's value proposition over a bare singleton is built specifically around tying a value's creation/disposal to a widget's lifetime (e.g. `ChangeNotifierProvider` disposing its `ChangeNotifier` when the providing widget is removed from the tree), not around making registration easier to reach.
- Evidence: general Flutter/Provider documentation and community guidance consistently frame `Provider`'s reason-to-exist as automatic disposal and scoped rebuilds tied to widget removal, distinct from a flat, app-lifetime service registry.
- Source: https://docs.flutter.dev/data-and-backend/state-mgmt/simple (checked 2026-09-04); `[UNVERIFIED: Provider package's own README wording was not independently re-fetched in this pass; the disposal-on-widget-removal behavior is treated here as well-established Flutter community consensus rather than a single quoted primary source]`.

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| A. Singleton / service-locator (`WebMcp.registerTool(...)`) | A top-level (or app-scoped instance) registry class holds a `Map<String, ToolDefinition>`; apps call `WebMcp.registerTool(name, schema, handler)` anywhere — `main()`, a controller, a `initState`, or a plain Dart class. Navigation tools are generated by handing the registry a `GoRouter` instance once (`registry.registerRoutesFrom(goRouter.configuration.routes)`), or a hand-built route table for raw Navigator 2.0. | Apps must remember to unregister manually if a tool's validity is tied to a screen being alive (no automatic disposal); the registry is effectively process-global state, so tests must reset it between cases. | **Chosen.** Zero widget-tree dependency to register a tool (1 call, 0 new widgets in the tree); unit-testable with a plain `test()` (no `pumpWidget`); composes directly with `go_router`'s non-widget `configuration.routes` getter and equally well with a raw Navigator 2.0 app that just hands over its own route list, since neither requires a `BuildContext`. |
| B. `InheritedWidget`/`Provider`-style (`WebMcpTool` wrapping a subtree) | A `WebMcpTool` widget registers a tool in `initState`/`didChangeDependencies` and unregisters in `dispose`, propagating an `InheritedWidget` so descendants (or a global lookup keyed by widget id) can find it. Navigation tools would need a `WebMcpTool`-per-route wrapper or a route-observer widget wired into the widget tree. | Every tool, including ones with no rendering purpose, needs a widget in the tree just to exist; testing tool registration requires `tester.pumpWidget(...)` per Flutter's own testing docs; auto-generating tools from `go_router`'s route table has to either duplicate go_router's own `RouteBase` tree as widgets or bolt a `NavigatorObserver`/route-change listener onto the tree, which is strictly more code than reading `configuration.routes` directly; raw Navigator 2.0 gains nothing from this shape since there's no framework route table to hook into via widgets either. | **Rejected as the primary mechanism.** Framework precedent (`Actions`/`Shortcuts`) shows this shape is right when a capability must resolve differently per-screen/per-subtree (nearest-ancestor wins) — not the MVP's requirement — and it fails the "unit-test without pumping a widget tree" bar outright per Flutter's testing docs. |
| C. Hybrid: singleton core + optional widget convenience wrapper | Registry from Option A is the source of truth; an *optional* `WebMcpToolScope` widget is a thin sugar layer that calls `WebMcp.registerTool` in `initState` and `WebMcp.unregisterTool` in `dispose`, for apps that want a tool's lifetime tied to a widget's lifetime (e.g. a screen-local action). Navigation-tool generation stays purely in the singleton, reading `go_router`'s `configuration.routes` or an app-supplied route table for raw Navigator 2.0. | Two ways to register a tool (API surface area, documentation burden); must clearly document that the widget wrapper is sugar over the singleton and not a separate source of truth, or apps will get confused about where a tool "lives." | **Chosen as the eventual full shape**, additive on top of A: the widget wrapper is optional, is built entirely on top of the singleton (no framework primitive underneath it besides `initState`/`dispose`), and its absence in the MVP costs nothing since Option A alone already satisfies the stated MVP scope (manual registration + router-derived navigation tools). |

## Constraints discovered

- `go_router`'s only public route-introspection surface is the raw `RouteConfiguration.routes` tree (`List<RouteBase>`); there is no built-in flattening/enumeration helper, so the package's route-to-tool generator must itself recurse through `GoRoute`, `ShellRoute`, and `StatefulShellRoute`/`navigationShell.route.branches` — this is implementation work regardless of which registration architecture (A or B) is chosen. Source: https://pub.dev/documentation/go_router/latest/go_router/RouteConfiguration-class.html.
- Raw Navigator 2.0 (`Router`/`RouteInformationParser`/`RouterDelegate`) has no framework-level declarative route table at all — Flutter's own docs point developers toward `go_router` for exactly this reason. Automatic "navigate to X" tool generation for a raw-`Router` app is only possible if that app supplies its own explicit route table to the package; it cannot be discovered generically. Source: https://docs.flutter.dev/ui/navigation.
- Flutter's testing model draws a hard line between unit tests (plain Dart objects) and widget tests (`WidgetTester`/`pumpWidget`); any registration API whose registration side-effect only fires inside widget lifecycle methods (`initState`, `build`, `didChangeDependencies`) inherits the widget-test cost for that code path. Source: https://docs.flutter.dev/testing/overview.
- `InheritedWidget`-based lookup is inherently tree-position-dependent ("nearest enclosing ancestor" per the `Actions` precedent); a flat, app-wide tool namespace (as WebMCP needs — one tool name maps to one JS-exposed capability, not "whichever screen is on top") does not need this property for the MVP, though it may become useful later if two different screens need to expose the same tool name with different behavior.
- Isolating the web-only JS-interop layer is orthogonal to the A/B choice: either shape can define a `WebMcpTransport`/`WebMcpPlatform` interface behind the registry (called only when a tool is registered/invoked), so a desktop MCP server transport is additive by implementing that interface. Option A makes this marginally cleaner because the registry itself has no widget/`BuildContext` dependency to strip out later — the same registry class is reusable unmodified on a platform with no widget tree at all (e.g. a headless Dart CLI/desktop process), whereas Option B's core registration mechanism is Flutter-`Widget`-specific by construction and could not run in a non-Flutter Dart context without a separate code path.

## Unresolved

- [UNRESOLVED: Whether the MVP needs per-screen tool shadowing (same tool name resolving differently depending on which screen is active) — if yes, the `Actions`/`Shortcuts` precedent becomes directly relevant and Option C's widget wrapper should gain resolution-order semantics, not just lifecycle sugar. Not something this research branch can settle; it is a product-scope question.]
- [UNRESOLVED: Exact current pub.dev like/download counts for `get_it` were sourced from search-indexed secondary pages, not a freshly fetched pub.dev page at write time — treat the specific numbers as indicative, not exact.]
- [UNRESOLVED: Whether a future `go_router` release (beyond 18.0.1, published 2026-09-02 per pub.dev) adds a dedicated flattened-route-enumeration API; if it does, the router-introspection implementation task should re-check before building a custom recursive walker.]
- [UNRESOLVED: The exact shape of the web-only JS-interop isolation boundary (interface name, method signatures) is explicitly out of this branch's scope per the delegation boundary — covered by a separate research stream on package:web/JS-interop mechanics.]

## Sources

- go_router package page (version 18.0.1, checked 2026-09-04): https://pub.dev/packages/go_router
- go_router `GoRouter` class API docs (checked 2026-09-04): https://pub.dev/documentation/go_router/latest/go_router/GoRouter-class.html
- go_router `RouteConfiguration` class API docs (checked 2026-09-04): https://pub.dev/documentation/go_router/latest/go_router/RouteConfiguration-class.html
- go_router Configuration topic docs (checked 2026-09-04): https://pub.dev/documentation/go_router/latest/topics/Configuration-topic.html
- Flutter navigation documentation (checked 2026-09-04): https://docs.flutter.dev/ui/navigation
- Flutter testing overview documentation (checked 2026-09-04): https://docs.flutter.dev/testing/overview
- Flutter simple state management documentation (checked 2026-09-04): https://docs.flutter.dev/data-and-backend/state-mgmt/simple
- Flutter `Actions` widget API docs (checked 2026-09-04): https://api.flutter.dev/flutter/widgets/Actions-class.html
- get_it package page (checked 2026-09-04, secondary/search-indexed data): https://pub.dev/packages/get_it
- get_it GitHub repository (checked 2026-09-04): https://github.com/flutter-it/get_it
