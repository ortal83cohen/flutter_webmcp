# Findings: Flutter semantics as an opt-in page surface

Sources were checked on 2026-09-10. The installed Flutter checkout is version 3.38.4 at commit `66dd93f9a27ffe2a9bfc8297506ce066ff51265f`. Current online Flutter API pages can describe a newer framework version, so the installed source links below are the compatibility baseline for this repository.

## Answer

An opt-in page wrapper can expose a useful live subset of a Flutter page with little consumer code by reading Flutter's public runtime semantics tree and dispatching only actions that the current node reports. It cannot promise all visible content or all app operations: semantics are an accessibility projection, lazy children may not exist, custom painting may contribute nothing, overlays may lie outside the wrapper's semantic subtree, and source generation cannot recover runtime state. The recommended shape is runtime semantic discovery plus optional explicitly annotated domain actions.

The critical feasibility gate is scope isolation in release mode. Flutter exposes the `SemanticsOwner` tree publicly, but `RenderObject.debugSemantics` is debug/profile only. A wrapper therefore needs to create a uniquely identifiable semantics boundary, locate that boundary in the correct `PipelineOwner`, and traverse only its descendants. This must be proven on supported Flutter versions before the public API is committed.

## Public runtime API feasibility

- `SemanticsBinding.instance.ensureSemantics()` is public and returns a `SemanticsHandle`. Holding it requests semantics collection; disposing the last outstanding handle permits collection to stop. The wrapper can acquire one while mounted and dispose it when unmounted. Source: [SemanticsBinding.ensureSemantics](https://api.flutter.dev/flutter/semantics/SemanticsBinding/ensureSemantics.html) and [installed source](https://github.com/flutter/flutter/blob/66dd93f9a27ffe2a9bfc8297506ce066ff51265f/packages/flutter/lib/src/semantics/binding.dart#L115-L130).
- The wrapper's `RenderObject.owner` publicly identifies its `PipelineOwner`, whose public `semanticsOwner` exposes `rootSemanticsNode`, `getSemanticsNode`, listener registration, and `performAction`. This avoids assuming a single render view. Source: [PipelineOwner.semanticsOwner](https://api.flutter.dev/flutter/rendering/PipelineOwner/semanticsOwner.html), [SemanticsOwner](https://api.flutter.dev/flutter/semantics/SemanticsOwner-class.html), and [RendererBinding multi-view model](https://api.flutter.dev/flutter/rendering/RendererBinding-mixin.html).
- `SemanticsNode.visitChildren` and `getSemanticsData()` are public in release builds. `SemanticsData` exposes label, value, hint, tooltip, role, identifier, bounds-related data, scroll metadata, flags, and an action bitmask with `hasAction`. Source: [SemanticsNode](https://api.flutter.dev/flutter/semantics/SemanticsNode-class.html) and [SemanticsData](https://api.flutter.dev/flutter/semantics/SemanticsData-class.html).
- `SemanticsOwner.performAction(nodeId, action, args)` is public. It invokes a handler only when the node currently advertises one; an unsupported action is ignored. The adapter should still re-resolve the current node and re-check `hasAction` immediately before dispatch, because node IDs are live-tree identifiers rather than a durable application identity. Source: [SemanticsOwner.performAction](https://api.flutter.dev/flutter/semantics/SemanticsOwner/performAction.html) and [installed source](https://github.com/flutter/flutter/blob/66dd93f9a27ffe2a9bfc8297506ce066ff51265f/packages/flutter/lib/src/semantics/semantics.dart#L4474-L4490).
- Standard actions include tap, long press, scrolling, increase/decrease, focus, dismiss, expand/collapse, `setText`, and `setSelection`. Argument-bearing actions need an explicit typed adapter and input validation; for example, `setText` accepts a string and `setSelection` accepts integer `base` and `extent` values. Source: [SemanticsAction](https://api.flutter.dev/flutter/dart-ui/SemanticsAction-class.html), [setText](https://api.flutter.dev/flutter/dart-ui/SemanticsAction/setText-constant.html), and [setSelection](https://api.flutter.dev/flutter/dart-ui/SemanticsAction/setSelection-constant.html).
- Semantics changes after paint/compositing during the semantics phase. `SemanticsOwner` notifies listeners after sending an update. Discovery should therefore publish immutable snapshots after an owner notification or a completed frame, never expose a mutable `SemanticsNode` as a long-lived handle. Source: [SemanticsNode lifecycle](https://api.flutter.dev/flutter/semantics/SemanticsNode-class.html) and [SemanticsOwner.sendSemanticsUpdate](https://api.flutter.dev/flutter/semantics/SemanticsOwner/sendSemanticsUpdate.html).

## Scope mapping and isolation gate

The most direct public-API candidate is a wrapper-created `Semantics` node with a collision-resistant internal `identifier`, `container: true`, and `explicitChildNodes: true`. An identifier implicitly forces a distinct semantics node and is present in `SemanticsData`; it is not announced to users, although it is exported to the native accessibility hierarchy and to a web DOM attribute. Source: [SemanticsProperties.identifier](https://api.flutter.dev/flutter/semantics/SemanticsProperties/identifier.html) and [Semantics.container](https://api.flutter.dev/flutter/widgets/Semantics/container.html).

At runtime, the wrapper can use its render object's owner to select the correct semantics tree, find exactly one node bearing its marker identifier, and recurse only below that node in traversal order. A random or monotonically unique per-mount marker prevents accidental consumer collisions. The marker must remain an internal implementation detail; externally returned handles should combine a snapshot revision with an opaque local ID and be rejected after the node disappears or the scope remounts.

`SemanticsTag`/`tagForChildren` is a secondary candidate, but its documented contract tags child nodes that pass through a render object while seeking a semantic parent; it is primarily a tree-assembly signal. It does not by itself provide a direct wrapper-to-node lookup. Source: [SemanticsProperties.tagForChildren](https://api.flutter.dev/flutter/semantics/SemanticsProperties/tagForChildren.html).

The scope design is `[UNVERIFIED]` until one spike proves all of the following in debug, profile, and release builds on the package's supported Flutter range:

1. One wrapper marker resolves to exactly one node after the first semantics flush and after rebuilds.
2. Two sibling wrappers never return each other's nodes; nested wrappers have a documented ownership rule, preferably nearest-wrapper ownership.
3. Merged semantics, `ExcludeSemantics`, `BlockSemantics`, route transitions, dialogs, menus, tooltips, and `OverlayPortal` cannot leak nodes from outside the selected scope.
4. Multiple `FlutterView`/`PipelineOwner` trees select the owner belonging to the wrapper.
5. A stale action handle cannot invoke a recycled or replacement node after rebuild, scrolling, navigation, or wrapper disposal.

Failure of any isolation case is a design failure, not a documentation caveat. The fallback is explicit registration for that content or operation.

## Proposed coverage matrix

| Surface | Automatic runtime coverage | Default exposure/action policy | Required proof or fallback |
|---|---|---|---|
| Standard text, labels, headings, images | Usually present when the widget contributes semantics | Return non-empty semantic label/value/hint/tooltip and role | Golden/widget tests against standard Material and Cupertino widgets |
| Buttons, links, toggles, sliders | Usually expose flags plus tap/increase/decrease actions | Offer only actions present in the current node; omit disabled actions | Verify disabled controls either omit the handler or report disabled and are never invoked |
| Editable text | Exposes text-field flags, current value, selection, and supported editing actions | Read non-sensitive values; allow `setText`/`setSelection` only through validated typed arguments | Focused/unfocused and read-only tests |
| Password/obscured fields | Flutter marks `isObscured`; `RenderEditable` constructs an obscured value | Never return the current value, selection-derived text, copy, or cut; text mutation requires an explicit product decision | Negative tests proving no secret appears in snapshots, errors, or logs; source: [installed RenderEditable](https://github.com/flutter/flutter/blob/66dd93f9a27ffe2a9bfc8297506ce066ff51265f/packages/flutter/lib/src/rendering/editable.dart#L1364-L1395) |
| Hidden or excluded content | Hidden flags may exist; `ExcludeSemantics` removes a subtree | Omit hidden, invisible, excluded, and blocked-behind-modal content | Test `Visibility`, `ExcludeSemantics`, and `BlockSemantics`; source: [ExcludeSemantics behavior](https://api.flutter.dev/flutter/widgets/Semantics/excludeSemantics.html) and [BlockSemantics](https://api.flutter.dev/flutter/widgets/BlockSemantics-class.html) |
| Lazy `ListView`/slivers | Only instantiated children can contribute full nodes; scroll nodes may expose counts and offsets | Return the current semantic window and scroll actions, with explicit partial-result metadata | Scroll-and-refresh protocol; never claim an unbuilt item is absent from domain data; source: [ListView child lifecycle](https://api.flutter.dev/flutter/widgets/ListView-class.html) |
| `CustomPaint` | No automatic meaning unless the painter supplies `semanticsBuilder` or is wrapped in `Semantics` | Return only supplied semantics | Consumer annotation or explicit domain action; source: [CustomPainter.semanticsBuilder](https://api.flutter.dev/flutter/rendering/CustomPainter/semanticsBuilder.html) |
| Merged semantics | Several widgets may collapse into one semantic node | Treat the merged node as one exposed target | Do not infer individual child actions or identities that Flutter merged away |
| Dialogs, menus, route overlays | May be represented elsewhere in the Navigator/Overlay semantic structure | Include only if the isolation spike proves the overlay is a descendant of this scope | Separate wrapper/route integration or explicit registration |
| Platform views | A semantics node may refer to a platform view whose native children replace Flutter children | Expose the Flutter boundary metadata only | No recursive native-tree claim; use a platform-specific bridge if later required |
| Domain operations without UI semantics | Not discoverable | Optional annotated action registry with explicit name, description, schema, enabled predicate, and handler | Consumer annotation is the source of truth |

## Runtime versus generator limits

Runtime semantics reflects the currently built and accessibility-exposed state, including current enabled flags, values, focus, scroll position, and installed handlers. This is the only credible automatic source for live page content and actions.

A source generator can reduce annotation boilerplate for explicitly declared domain actions, validate unique names and serializable schemas, and emit registry glue. It cannot reliably enumerate the live widget tree, evaluate runtime branches, recover closure intent, see unbuilt lazy children, determine current enabled state, or manufacture semantics for pixels drawn without annotations. These are consequences of the difference between Dart source structure and Flutter's post-layout semantics tree; they should be treated as design limits rather than generator backlog.

## Options

| Option | How it works | Benefits | Limits | Decision |
|---|---|---|---|---|
| Runtime semantics wrapper | Hold a semantics handle, locate a wrapper marker in its `PipelineOwner`, snapshot descendants, dispatch advertised actions | Minimal consumer code; live state; standard widgets participate automatically | Accessibility projection only; scope marker and update lifecycle need proof | Chosen foundation, contingent on isolation spike |
| Runtime semantics plus annotated domain actions | Add an optional scope-local registry for operations semantics cannot express | Covers domain commands and typed arguments without pretending they were discovered | More consumer code for non-UI operations; name and lifecycle rules needed | Chosen extension |
| Generator-first widget/action discovery | Analyze Dart source and generate page inventory | Compile-time diagnostics and boilerplate reduction | Cannot recover runtime tree/state or complete dynamic behavior | Rejected as discovery engine; retain only for annotation glue |
| Explicit registration only | Consumer registers every content field and action | Strongest identity and schema control | Fails the minimal-code goal for ordinary Flutter pages | Fallback for unsupported or security-sensitive surfaces |
| Read Flutter web semantics DOM | Query generated HTML accessibility nodes | Browser-visible representation | Web-specific, accessibility may be opt-in, and bypasses Flutter's cross-platform runtime API | Rejected; Flutter itself translates its semantics tree to the web DOM: [web accessibility](https://docs.flutter.dev/ui/accessibility/web-accessibility) |

## Unresolved proof spikes

- `[UNRESOLVED: Does an identifier-marked wrapper remain a stable, unique ancestor of all intended descendants across the oldest and newest supported Flutter versions in release mode?]`
- `[UNRESOLVED: What exact ownership rule should apply to nested wrappers, and can nearest-wrapper ownership be implemented without duplicate exposure?]`
- `[UNRESOLVED: Which overlay mechanisms remain logically inside the wrapper's semantics subtree, and which require independent registration?]`
- `[UNRESOLVED: What snapshot revision and opaque-handle scheme proves that a stale semantic node ID can never target a replacement node?]`
- `[UNRESOLVED: Which standard semantics actions are safe enough for the initial allowlist, especially focus, clipboard, text mutation, dismiss, and custom accessibility actions?]`
- `[UNRESOLVED: What Flutter SDK version range will the package support? Online documentation checked on 2026-09-10 may be newer than installed Flutter 3.38.4.]`

## Sources consulted

- Flutter API documentation pages linked inline, consulted 2026-09-10.
- Flutter accessibility documentation, [web accessibility](https://docs.flutter.dev/ui/accessibility/web-accessibility), consulted 2026-09-10.
- Installed Flutter 3.38.4 source at commit [`66dd93f9a27ffe2a9bfc8297506ce066ff51265f`](https://github.com/flutter/flutter/tree/66dd93f9a27ffe2a9bfc8297506ce066ff51265f), consulted 2026-09-10.
