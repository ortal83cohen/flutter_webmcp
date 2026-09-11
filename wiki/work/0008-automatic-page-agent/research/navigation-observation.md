# Navigation observation for automatic page discovery

Research date: 2026-09-10. Scope: planning evidence only; no runtime behavior was tested. Flutter API pages identify no reliable SDK release in their rendered footer, so SDK applicability is `[UNVERIFIED]` until matrix tests. go_router API pages reported 18.0.1 when accessed.

## Recommendation

Use navigation observation as a cheap invalidation and candidate-activity signal, not as the page-content source. Keep the live, scoped semantics projection authoritative for readable content and advertised actions. A route event can say that a Navigator's history changed; it cannot identify a semantics subtree, prove pixels are visible, expose callbacks, or establish business success.

Provide one application-level `NavigationObservationHub` (proposed) and create one forwarding `NavigatorObserver` adapter for every Navigator that must be covered. The hub records route identity, navigator identity, top-route changes, and transition state as evidence. It combines that evidence with an explicit active-branch source for parallel navigation, then asks the page scope to re-evaluate after a frame. Any conflict or missing signal keeps the scope inactive.

For the lowest-boilerplate common case, offer router-specific setup helpers:

1. `MaterialApp.navigatorObservers` or the equivalent root `Navigator.observers` receives one adapter.
2. `GoRouter(observers: ...)` receives the root adapter. `ShellRoute(observers: ...)` and each `StatefulShellBranch(observers: ...)` can receive adapters for their own Navigators. go_router 17.0.0 also began forwarding shell navigation to root observers by default through `notifyRootObserver`; direct per-Navigator adapters remain preferable when navigator identity and duplicate-free evidence matter. [GoRouter source](https://github.com/flutter/packages/blob/main/packages/go_router/lib/src/router.dart) [go_router route source](https://github.com/flutter/packages/blob/main/packages/go_router/lib/src/route.dart) [go_router changelog](https://github.com/flutter/packages/blob/main/packages/go_router/CHANGELOG.md)
3. A `StatefulShellRoute` integration supplies `StatefulNavigationShell.currentIndex` as explicit branch activity. A branch switch restores another persistent Navigator and need not push or pop a route; the default indexed-stack container keeps all branches mounted. [StatefulShellRoute API](https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class.html)
4. Root-level dialogs or pages must be observed on the root Navigator; branch observers cannot establish that a root modal covers them. Conversely, observing only the root is insufficient as a generic Flutter rule because apps may contain nested Navigators.

Do not claim inherited or automatic observer injection. `Navigator` accepts an explicit observer list, and a `NavigatorObserver` exposes the one `NavigatorState` it observes. A package that does not construct or configure a Navigator has no public API for silently inserting itself into that Navigator's observer list. [Navigator API](https://api.flutter.dev/flutter/widgets/Navigator-class.html) [NavigatorObserver API](https://api.flutter.dev/flutter/widgets/NavigatorObserver-class.html)

## Coverage and limits

| Signal | What it covers | What it does not prove | Design use |
|---|---|---|---|
| `didChangeTop(topRoute, previousTopRoute)` | The observed Navigator's top history route changed, including push and reveal-after-pop | Transition completion, global top across nested Navigators, branch visibility, semantics | Preferred top-route invalidation |
| `didPush` / `didPop` | A route was pushed or popped and the adjacent route supplied by Navigator | Pixels settled or asynchronous effect succeeded | Maintain diagnostic history and invalidate |
| `didReplace` / `didRemove` | Declarative or imperative replacement/removal | That the removed route was top; use `didChangeTop` for top | Repair route identity/history |
| `RouteObserver` + `RouteAware` | Per-route callbacks for push, pop, cover, and reveal after explicit `subscribe(routeAware, route)` | Automatic subscription, nested/root modal coverage, branch selection | Optional per-page compatibility adapter, not default |
| `RouterDelegate` `Listenable` / `currentConfiguration` | Router configuration changes and URL-reportable state | Pageless routes, overlays, visual top, or a page boundary | Supplemental router evidence only |
| `RouteInformationProvider` | Initial and platform/browser route information; Router listens and reparses | That navigation completed or the same URI maps to the same visible state | Deep-link/back-forward invalidation |
| Shell active index | Which persistent branch the shell selected | Root overlay/modal coverage or route transition completion | Required activity input for parallel branches |
| Semantics/listener update | Current materialized labels, values, flags, and advertised semantic actions inside the proven boundary | Hidden/lazy/server data or business completion | Runtime source of truth |

The observer callbacks and their exact signatures are current public API: `didChangeTop`, `didPush`, `didPop`, `didReplace`, and `didRemove`. The API describes `didChangeTop` as a top-most route change; it does not describe it as animation completion. [NavigatorObserver API](https://api.flutter.dev/flutter/widgets/NavigatorObserver-class.html)

`RouteObserver` requires a concrete `Route` subscription and `RouteAware`; `didPushNext` means covered and `didPopNext` means revealed. This moves lifecycle boilerplate into every participating widget unless a central builder wraps it. [RouteObserver.subscribe](https://api.flutter.dev/flutter/widgets/RouteObserver/subscribe.html) [RouteAware API](https://api.flutter.dev/flutter/widgets/RouteAware-class.html)

## Browser back, deep links, and settling

Flutter's Router sends platform route information through parsing to `RouterDelegate.setInitialRoutePath` or `setNewRoutePath`; operating-system back reaches `popRoute`. A non-null `currentConfiguration` is used to update browser history. Listening to the delegate/provider therefore catches URL/configuration intent, while Navigator observers catch resulting stack mutations. Neither alone proves active content. [RouterDelegate API](https://api.flutter.dev/flutter/widgets/RouterDelegate-class.html) [currentConfiguration](https://api.flutter.dev/flutter/widgets/RouterDelegate/currentConfiguration.html)

After any navigation signal, mark the candidate scope unsettled, wait for at least the next completed frame, and re-check route, branch, overlay, mount, and semantics boundary before permitting read or act. This is a proposed safety rule, not an API guarantee.

Do not use `Route.popped` as a visual-settled signal. It completes when the route is popped; Flutter documents that `TransitionRoute.completed` finishes later, after the exit transition and removal of overlay entries. `TransitionRoute.completed` is useful when the route has that type, but a generic observer receives `Route`, so completion handling needs type checks plus a frame/activity fallback. [Route.popped](https://api.flutter.dev/flutter/widgets/Route/popped.html) [TransitionRoute.completed](https://api.flutter.dev/flutter/widgets/TransitionRoute/completed.html)

## Can observation replace the per-page wrapper?

No. `Route` and `NavigatorObserver` expose navigation lifecycle, not the render, element, or semantics root owned by a page. App-level observation can remove per-page route lifecycle wiring, but a runtime boundary is still required somewhere to scope content and actions.

An application that owns all route definitions can centralize that boundary in each `GoRoute.builder` or `pageBuilder`: builders receive `BuildContext` and `GoRouterState`, and go_router wraps a builder result in a `Page` on the selected root, shell, or `parentNavigatorKey` Navigator. A helper or generated route annotation could wrap the returned child and provide a stable page identifier. Existing custom `Page` keys, restoration IDs, transitions, and result types must be preserved. [GoRoute API](https://pub.dev/documentation/go_router/latest/go_router/GoRoute-class.html)

That adapter is opt-in route-table integration, not universal interception. Without ownership of the router configuration, the package cannot rewrite arbitrary builders, custom `Page.createRoute`, imperative pushes, third-party routers, or nested Navigators. The portable fallback remains one page boundary plus either automatic `ModalRoute` evidence or an explicit activity source.

## Exact setup burden

| App shape | Required application work | Expected burden |
|---|---|---|
| Single root Navigator | Add one observer adapter at app construction; retain one boundary per opted-in page | One startup list entry plus page opt-ins |
| go_router, root routes only | Add one adapter to `GoRouter.observers`; wrap/annotate opted-in route builders | One router argument plus route opt-ins |
| `ShellRoute` | Root adapter plus shell adapter, or validate forwarded root observation; wrap selected routes | One adapter per shell Navigator when exact identity is required |
| `StatefulShellRoute` | Root adapter, branch adapters, and active-index feed; wrap selected routes | One adapter per branch plus one shell hook |
| Router not owned by app | Ask its owner/plugin for observer and activity hooks; otherwise explicit page activity | No zero-touch safe integration |

One adapter instance should not be reused directly across unrelated Navigators; create lightweight adapters that forward into the shared hub. This avoids treating `NavigatorObserver.navigator` as a global stack and makes root-versus-branch evidence explicit.

## Unresolved empirical gates

- Verify callback order and duplication for go_router 18.0.1 root observers, `ShellRoute.notifyRootObserver`, direct shell/branch observers, redirects, `go`, `push`, replace, browser back/forward, and initial deep links.
- Verify whether branch switching emits any observer event in default and custom `StatefulShellRoute` containers; the design must rely on active-index evidence regardless.
- Verify root and branch dialogs, popup routes, pageless routes, nested Navigators, non-opaque routes, predictive-back gestures, aborted gestures, and route removal during declarative page updates.
- Verify the settle algorithm across zero-duration, custom, interrupted, and interactive transitions. Record callback, animation, frame, overlay, and semantics timing in debug/profile/release.
- Verify central `builder`/`pageBuilder` wrapping preserves keys, restoration, transitions, page results, typed routes, and state under browser restoration.
- Verify the declared Flutter SDK floor actually contains `didChangeTop` with the expected behavior. Until then, support and fallback are `[UNVERIFIED]`.

## Source record

All sources were accessed 2026-09-10. Flutter sources are the current official API pages at access time, with release version `[UNVERIFIED]`. go_router API pages reported 18.0.1; GitHub `main` is moving source and must be pinned to the implemented dependency revision during validation. Primary pages used: Flutter `Navigator`, `NavigatorObserver`, `RouteObserver.subscribe`, `RouteAware`, `RouterDelegate/currentConfiguration`, `Route.popped`, `TransitionRoute.completed`; go_router `GoRoute`, `StatefulShellRoute`, official package source, and changelog.
