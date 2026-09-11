# Research: Local API shape and optional code generation

## Question

How can the package reduce consumer boilerplate for page-bound and domain actions while preserving explicit opt-in, existing scope ownership, and compatibility with the current Dart/Flutter package?

## Answer

Keep page presence and widget lifetime as runtime concerns, using the existing `WebMcpScreen` scope and `WebMcpAction` wrapper. Add optional generation only for explicitly annotated domain methods: generated code should adapt an instance supplied by the consumer into a `WebMcpToolSource`; it must not construct runtime instances or expose unannotated methods. `source_gen` plus `build_runner` is compatible in principle with the repository's Dart 3.13/analyzer 13 line, but the exact dependency solve and generated API remain implementation-time validation items.

## Findings

### Current consumer burden has three distinct paths

- Claim: A page-level tool currently requires a `State` to mix in `WebMcpScreen`, override `registerWebMcpTools`, and manually construct each `WebMcpTool`. The hook runs from the mixin's `initState` immediately after scope creation.
- Evidence: `lib/src/widgets/webmcp_screen.dart:5-40`; `example/lib/example_screen.dart:15-34`.
- Source: repository source, inspected 2026-09-10.

- Claim: A control-level action currently requires a `WebMcpAction` wrapper with name, description, optional schema, raw-map handler, and child. It locates the nearest screen scope at runtime, registers once, and removes only its owned tool on disposal.
- Evidence: `lib/src/widgets/webmcp_action.dart:10-81`; `test/widget_layer_test.dart`.
- Source: repository source and tests, inspected 2026-09-10.

- Claim: Imperative/domain tools currently require explicit registry or scope calls and hand-written descriptors. The existing `WebMcpToolSource` interface is already the narrow adapter seam a generator can target.
- Evidence: `example/lib/example_tools.dart`; `lib/src/webmcp_tool_source.dart:3-6`; `lib/src/webmcp_scope.dart`.
- Source: repository source, inspected 2026-09-10.

### Generation can remove descriptor and argument-decoding repetition, not runtime ownership

- Claim: `source_gen` supports generators over Dart libraries and annotated elements, and its builders can emit a shared `.g.dart` part, a package-specific part, or an importable standalone library.
- Evidence: The official guide describes `Generator`, `GeneratorForAnnotation`, `SharedPartBuilder`, `PartBuilder`, and `LibraryBuilder`, including their output conventions.
- Source: https://pub.dev/packages/source_gen, consulted 2026-09-10.

- Claim: A generated `WebMcpToolSource` that accepts a consumer-created service/controller instance can construct descriptors, decode supported parameters, call only annotated methods, and return their values through the existing `FutureOr<Object?>` handler contract. This is a proposed design inferred from the existing interfaces, not current behavior.
- Evidence: `WebMcpToolSource.getWebMcpTools` returns descriptors, and handlers accept a raw argument map and return `FutureOr<Object?>`.
- Source: `lib/src/webmcp_tool_source.dart:3-6`; `lib/src/webmcp_tool.dart:4-31`; [UNVERIFIED: generated adapter shape has not been prototyped].

- Claim: Source generation cannot discover the currently mounted page, visible content, hidden/lazy widget state, authorization state, or service instance at build time. Those values exist only at runtime; therefore the consumer must supply the live instance and the runtime scope must continue to own registration.
- Evidence: Dart documents `build_runner` as builders that generate files from source inputs; the current page scope is created and discovered through Flutter `State`/`BuildContext` at runtime.
- Source: https://dart.dev/tools/build_runner; `lib/src/widgets/webmcp_screen.dart:5-40`; `lib/src/widgets/webmcp_action.dart:49-80`, consulted 2026-09-10.

### Optional generator packaging is feasible but adds consumer workflow

- Claim: A published builder is configured in `build.yaml`; `auto_apply: dependents` applies it to direct dependents, and a `SharedPartBuilder` conventionally writes an intermediate cache part which `source_gen:combining_builder` merges into `.g.dart`.
- Evidence: Official builder configuration and `source_gen` output guidance.
- Source: https://github.com/dart-lang/build/blob/master/build_config/README.md#defining-builders-to-apply-to-dependents; https://pub.dev/packages/source_gen, consulted 2026-09-10.

- Claim: Consumers still need a generator package and `build_runner` as development dependencies, a `part` directive when shared parts are used, explicit annotations, and a build/watch command. Generated files required by a published package must be published with that package.
- Evidence: The official `build_runner` guide documents dependency setup, `part` wiring, build/watch commands, and publication of generated source.
- Source: https://pub.dev/packages/build_runner; https://dart.dev/tools/build_runner, consulted 2026-09-10.

- Claim: The repository requires Dart `^3.13.0` and analyzer `^13.3.0`. Current `source_gen` mainline permits Dart `^3.9.0` and analyzer `>=8.1.1 <15.0.0`; current `build_runner` mainline permits analyzer `>=13.3.0 <15.0.0`. These ranges overlap, so there is no visible version-range blocker, but a real `pub get` is still required before claiming compatibility.
- Evidence: `pubspec.yaml:6-20`; upstream package manifests.
- Source: https://github.com/dart-lang/source_gen/blob/master/source_gen/pubspec.yaml; https://github.com/dart-lang/build/blob/master/build_runner/pubspec.yaml, consulted 2026-09-10; [UNVERIFIED: no dependency solve was run because this stream is planning-only].

### Existing lifecycle timing constrains generated sources

- Claim: `WebMcpScreen.initState` invokes `registerWebMcpTools` before control returns to the consumer state's `initState` body. A generated source can therefore use fields initialized at declaration/construction, but a service assigned only after `super.initState()` is unavailable to that hook without a lifecycle/API adjustment or a later explicit `mcpScope.addSource` call.
- Evidence: `lib/src/widgets/webmcp_screen.dart:29-34`; `example/lib/example_screen.dart:19-34`.
- Source: repository source, inspected 2026-09-10.

- Claim: Generated registration must preserve the existing non-transactional ordering and first-live-registration-wins behavior unless the product contract is deliberately revised.
- Evidence: Source registration iterates descriptors in returned order; scope registration records duplicates as skipped, and the product contract fixes those semantics.
- Source: `lib/src/webmcp.dart`; `lib/src/webmcp_scope.dart`; `wiki/product/webmcp-contract.md`, inspected 2026-09-10.

### Generation does not close the browser transport gap

- Claim: The web transport only checks for `document.modelContext` and logs that tools are not published. More generated local descriptors would remain locally invokable but unavailable to browser-originated agents.
- Evidence: Registration and unregistration callbacks only log `tools not published`; browser tests assert that contract.
- Source: `lib/src/transport/transport_web.dart:10-47`; `test/transport_web_browser_test.dart`; `wiki/product/webmcp-contract.md`, inspected 2026-09-10.

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| State inheritance | Consumer extends a package base `State` class that owns discovery and registration | Consumes Dart's single superclass slot and still needs a declaration mechanism | Reject. It is less composable than the existing mixin and does not reduce domain descriptor/decoder boilerplate. |
| Runtime mixin only | Extend `WebMcpScreen` with more overridable getters/methods | Smallest package change; consumer still writes descriptors and raw-map handlers | Retain for page lifetime, but insufficient alone for minimal domain-action code. Dart mixins are intended to reuse implementations across class hierarchies: https://dart.dev/language/mixins. |
| Widget wrapper only | Continue wrapping every actionable control with `WebMcpAction` | Explicit and lifecycle-correct, but repetitive and unsuitable for non-widget domain methods | Retain for UI-bound actions; do not make it the domain-action declaration path. |
| Generated instance adapter | Annotations opt individual domain methods in; generated code accepts the consumer's live instance and implements `WebMcpToolSource` | Adds dev dependencies, generated files, build latency, diagnostics, and a supported-type policy | Preferred optional path. It reduces repetitive descriptors/decoders while preserving explicit opt-in and runtime ownership. |
| Generated mixin on consumer class | Generator emits a mixin that registers annotated methods from `this` | Requires consumer `with` ordering, can collide with the existing lifecycle mixin, and makes init ordering harder to reason about | Reject as the primary output. A generated source object has a smaller coupling surface. |
| Runtime reflection or widget scanning | Discover methods/widgets automatically | Dart's supported build workflow presents generation as the alternative to reflection; widget scanning also violates the existing explicit-action contract | Reject. Source: https://dart.dev/tools/build_runner; `wiki/product/webmcp-contract.md`. |

## Proposed consumer workflow

1. Use `WebMcpScreen` for runtime page lifetime and page discovery; use `WebMcpAction` where an action is specifically bound to a mounted control.
2. Add the annotation/runtime API as a normal dependency and the generator plus `build_runner` as development dependencies. Package split and names are still a planner decision.
3. Add a part directive to the consumer library if the shared-part convention is chosen.
4. Annotate only domain methods intended for exposure, supplying stable tool metadata. Unannotated methods remain absent.
5. Run `dart run build_runner build` or watch mode.
6. Construct the domain service/controller normally. Pass that live instance to the generated source and add the source to the active `WebMcpScope`; generated code never creates the service.
7. Keep authorization and availability checks inside the invoked application path. Omit/unmount page- or control-bound registration when invocation must be unavailable.

## Migration gaps

- No annotation types, builder entry point, `build.yaml`, generator package boundary, generated-output convention, or builder tests exist. Source: `pubspec.yaml`; repository file inventory, inspected 2026-09-10.
- No typed argument decoder, required/optional/default parameter policy, JSON-safe type matrix, schema generator, output schema, or diagnostic wording exists. Source: `lib/src/webmcp_tool.dart`; `wiki/product/webmcp-contract.md`.
- The current schema is descriptive only and the registry performs no validation; generated decoders would introduce new failure behavior that must be specified and negatively tested. Source: `test/registry_test.dart`; `wiki/product/webmcp-contract.md`.
- The current early registration hook cannot consume dependencies initialized after `super.initState()` without an API/lifecycle choice. Source: `lib/src/widgets/webmcp_screen.dart:29-34`.
- Names remain globally unique across mounted scopes and collisions are first-wins; a naming convention or compile-time local duplicate diagnostic cannot prevent cross-page runtime collisions. Source: `lib/src/webmcp.dart`; `lib/src/webmcp_scope.dart`; `wiki/product/webmcp-contract.md`.
- Browser publication, browser invocation, result/error wire safety, logging/privacy, and unregistration remain absent and require a separate transport design. Source: `lib/src/transport/transport_web.dart`; `wiki/product/webmcp-contract.md`.
- Runtime page content discovery must define what counts as currently available content; neither code generation nor the current widget wrapper can guarantee discovery of hidden or lazily unbuilt content. Source: `lib/src/widgets/webmcp_action.dart`; [UNVERIFIED: page-content contract has not yet been designed].

## Unresolved

- [UNRESOLVED: Should annotations and generator ship in this package or in separate runtime-annotation and generator packages?]
- [UNRESOLVED: What exact Dart parameter and return types are supported, and what compile-time diagnostic is emitted for unsupported signatures?]
- [UNRESOLVED: Does generated metadata derive JSON Schema from Dart types, require explicit schema overrides, or use a hybrid?]
- [UNRESOLVED: How does a page register a generated source whose live dependency is initialized only after `super.initState()`?]
- [UNRESOLVED: Are generated parts committed in consumer applications, and what CI freshness check is required?]
- [UNRESOLVED: What runtime page-content representation and visibility boundary will page discovery expose?]
- [UNRESOLVED: Which browser WebMCP wire contract, availability rules, error envelope, and privacy policy will close the transport gap?]

## Sources

- Repository: `lib/`, `test/`, `example/`, `pubspec.yaml`, and `wiki/product/webmcp-contract.md`, inspected 2026-09-10.
- Dart mixins: https://dart.dev/language/mixins, consulted 2026-09-10.
- Dart build runner guide: https://dart.dev/tools/build_runner, consulted 2026-09-10.
- `build_runner` package: https://pub.dev/packages/build_runner, consulted 2026-09-10.
- `source_gen` package: https://pub.dev/packages/source_gen, consulted 2026-09-10.
- Build configuration: https://github.com/dart-lang/build/blob/master/build_config/README.md, consulted 2026-09-10.
- Upstream `source_gen` manifest: https://github.com/dart-lang/source_gen/blob/master/source_gen/pubspec.yaml, consulted 2026-09-10.
- Upstream `build_runner` manifest: https://github.com/dart-lang/build/blob/master/build_runner/pubspec.yaml, consulted 2026-09-10.
