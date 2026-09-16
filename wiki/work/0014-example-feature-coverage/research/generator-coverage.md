# Research: generator/annotations coverage in the top-level example

## Question

What do `packages/webmcp_flutter_annotations` and `packages/webmcp_flutter_generator`
provide, does the top-level `example/` app currently use them, and is adding a
demonstration of generated domain actions to `example/` feasible and appropriate
under `wiki/product/webmcp-contract.md`?

## Answer

The top-level `example/` app does not depend on, import, or demonstrate
`webmcp_flutter_annotations` or `webmcp_flutter_generator` at all today — it only
uses manual `WebMcpTool` registration. Adding a minimal demonstration is
technically feasible (the generator package already ships a working fixture that
proves the pattern) but it requires new pubspec dependencies and dev_dependencies
plus a `build_runner` step, which is a dependency/build-process change to
`example/pubspec.yaml`, not a zero-dependency edit.

## Findings

### The example app has no reference to the annotation/generator packages

- Claim: `example/` never imports `webmcp_flutter_annotations`, never imports
  `webmcp_flutter_generator`, and never uses `@WebMcpDomainAction`.
- Evidence: a repo-wide grep for `webmcp_flutter_annotations|webmcp_flutter_generator|WebMcpDomainAction`
  scoped to `example/` returned no matches. `example/lib/example_tools.dart`
  registers tools imperatively via `WebMcp.instance.registerTool(...)` with a
  hand-written `WebMcpTool`, not a generated adapter.
- Source: repo-wide grep (session tool call, 2026-09-15); `example/lib/example_tools.dart:13-29`.

### The example app's current pubspec has no generator/build_runner dependencies

- Claim: `example/pubspec.yaml` depends only on `flutter` and `webmcp_flutter`
  (path dependency to the repo root), with `flutter_lints` and `flutter_test` as
  the only dev_dependencies.
- Evidence: full file contents, no `build_runner`, `webmcp_flutter_annotations`,
  or `webmcp_flutter_generator` entries.
- Source: `example/pubspec.yaml:1-22`.

### `webmcp_flutter_annotations` provides one compile-time annotation, nothing else

- Claim: the package exports a single `final class WebMcpDomainAction` with
  `description` (required), optional `name`, and three boolean hints
  (`readOnlyHint`, `untrustedContentHint`, `consequentialHint`). It is metadata
  only — it does not register tools, construct a service, or grant
  authorization.
- Evidence: full source of the annotation class and its doc comments.
- Source: `packages/webmcp_flutter_annotations/lib/webmcp_flutter_annotations.dart:1-33`;
  `packages/webmcp_flutter_annotations/README.md:1-18`.

### `webmcp_flutter_generator` is a `build_runner` `Builder` that emits `.webmcp.g.dart` adapters

- Claim: the package registers a `LibraryBuilder` (`webMcpDomainActionBuilder`)
  driven by `build.yaml`, which maps `.dart` inputs to `.webmcp.g.dart` outputs,
  `auto_apply: dependents`, `build_to: source`. It only generates code for
  public instance methods annotated with `@WebMcpDomainAction` on a class; the
  generated adapter class implements `WebMcpToolSource` and wraps a
  consumer-supplied live instance (constructor takes the instance directly — it
  never constructs the service itself).
- Evidence: builder wiring and generated-extension declaration; build.yaml
  config; the generated fixture file showing the adapter class
  `InventoryServiceWebMcpSource` taking `this.instance` in its constructor and
  exposing `getWebMcpTools()` built from the two annotated methods only (`update`,
  `read`); the unannotated `reset()` method is not present in the generated
  output.
- Source: `packages/webmcp_flutter_generator/lib/builder.dart:1-10`;
  `packages/webmcp_flutter_generator/build.yaml:1-7`;
  `packages/webmcp_flutter_generator/example/lib/inventory_service.webmcp.g.dart:1-177`;
  `packages/webmcp_flutter_generator/example/lib/inventory_service.dart:1-61` (note
  `reset()` at lines 58-60 has no annotation and is absent from the generated
  source).

### The generator supports scalar, enum, nullable, and recursive collection types with strict decoding and safe failure

- Claim: generated decoders handle `String`, safe-range JSON `int`
  (`-9007199254740991`..`9007199254740991`), `bool`, enums (matched by
  `.name`), and recursive `List`/`Map<String, T>`; unknown keys or invalid
  values throw `FormatException` internally and the generated handler converts
  that into a safe `{'ok': false, 'error': {'code': 'invalidArguments', ...}}`
  response before the domain method runs.
- Evidence: the decoder helper functions (`_$decodeInventoryService0P0`..`P3`)
  and the `_invoke0`/`_invoke1` try/catch blocks in the generated fixture;
  corroborated by the generator's own README claim and by
  `wiki/product/webmcp-contract.md`'s "Generated domain actions" section, which
  states the same supported-type list and safe-failure behavior.
- Source: `packages/webmcp_flutter_generator/example/lib/inventory_service.webmcp.g.dart:28-176`;
  `packages/webmcp_flutter_generator/README.md:25-28`;
  `wiki/product/webmcp-contract.md:90-101`.

### The generator package ships its own runnable example/fixture that already demonstrates the whole flow

- Claim: `packages/webmcp_flutter_generator/example/` is a self-contained Flutter
  package (`webmcp_generator_consumer_fixture`) with its own `pubspec.yaml`
  depending on `webmcp_flutter` (path `../../..`), `webmcp_flutter_annotations`
  (path `../../webmcp_flutter_annotations`), and dev-depending on `build_runner`
  and `webmcp_flutter_generator` (path `..`). Its `test/live_instance_test.dart`
  exercises generation, authorization-denied failure, invalid-argument safe
  failure, and live-instance replacement across scope close/reopen — this is
  the "example/README reference" the generator's own README points to
  ("See `example/` for generation, authorization, invalid-input, and
  live-instance replacement tests.").
- Evidence: full pubspec and test file contents.
- Source: `packages/webmcp_flutter_generator/example/pubspec.yaml:1-27`;
  `packages/webmcp_flutter_generator/example/test/live_instance_test.dart:1-81`;
  `packages/webmcp_flutter_generator/README.md:30-31`.

### Adding the demonstration to the top-level example would require new pubspec dependencies and a build step

- Claim: to demonstrate generated domain actions inside the top-level
  `example/` app, `example/pubspec.yaml` would need a new runtime dependency
  (`webmcp_flutter_annotations`) and new dev_dependencies (`build_runner`,
  `webmcp_flutter_generator`), plus a generated `.webmcp.g.dart` file produced
  by running `dart run build_runner build` (or an equivalent build_runner
  invocation), consistent with the generator's own README instructions.
  Whether this specific change is in-scope for `/quick-change` versus
  `/feature` routing is a project-workflow decision, not one this research
  makes — `AGENTS.md`'s routing table treats "no new dependency" as the
  `/quick-change` boundary, and this change adds new dependencies, so by that
  table's own text it falls outside the `/quick-change` row. That routing
  decision belongs to whoever plans the change, not to this research file.
- Evidence: generator README's stated setup steps; current top-level
  `example/pubspec.yaml` lacking those entries; `AGENTS.md` routing table text.
- Source: `packages/webmcp_flutter_generator/README.md:5-10`;
  `example/pubspec.yaml:1-22`; `AGENTS.md` (routing table, "Route by change
  size").

### `webmcp-contract.md` constraints that bear directly on any such demonstration

- Claim: the contract's "Generated domain actions" section states the
  generator "emits sources only for public instance methods annotated with
  `@WebMcpDomainAction`," that "Generated adapters accept a consumer-created
  live instance and remain owned by the consumer's `WebMcpScope` or page source
  list," and that adapters "do not construct services, intercept arbitrary
  calls, or replace authorization." Any example demonstration would need to
  construct its own service instance, own a `WebMcpScope`, and add the
  generated `...WebMcpSource` to that scope explicitly — mirroring the pattern
  already shown in the generator's own fixture test — rather than expecting the
  generated code to create or authorize anything.
- Evidence: direct quote from the contract; corroborated by the fixture code
  pattern (`WebMcpScope(...); scope.addSource(InventoryServiceWebMcpSource(service));`).
- Source: `wiki/product/webmcp-contract.md:90-96`;
  `packages/webmcp_flutter_generator/example/test/live_instance_test.dart:15-16`.
- Constraint: the contract also states the "Deliberate omissions" section
  excludes "generalized service proxies" and "framework-specific state
  adapters," and that consumers must "own... generated adapter... cleanup" —
  an example demonstration must show explicit scope/instance ownership and
  cleanup rather than any automatic wiring.
- Source: `wiki/product/webmcp-contract.md:146-157`.

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Add a new demo service + generated adapter directly inside top-level `example/` | Add `@WebMcpDomainAction`-annotated methods on a new example service class in `example/lib/`, add `webmcp_flutter_annotations` dependency, add `build_runner` + `webmcp_flutter_generator` dev_dependencies, run `build_runner build` to produce `.webmcp.g.dart`, wire the generated source into a `WebMcpScope` alongside the existing manual tools | New runtime dependency, new dev_dependencies, one build step, one new generated file checked in (or built at CI time) | Feasible; matches the pattern already proven in `packages/webmcp_flutter_generator/example/`; this is the option this research supports if the parent decides to route it as `/feature` given the new dependency |
| Point the top-level example's docs/README at the generator's own `example/` fixture instead of adding code to `example/` | No pubspec change to top-level `example/`; add a doc reference | No new dependency, no build step | Does not "demonstrate" the feature inside the app users actually run in Chrome (per this work item's title, which also mentions "verified in Chrome"); leaves the top-level example's feature coverage gap unresolved |
| Do nothing | Leave `example/` as-is | None | Leaves the gap identified by the work item title unresolved; not evaluated further since resolving the gap is the stated objective of the parent work item |

## Constraints discovered

- The top-level `example/pubspec.yaml` currently has zero dev_dependencies
  related to code generation; adding this feature requires both a new runtime
  dependency (`webmcp_flutter_annotations`) and new dev_dependencies
  (`build_runner`, `webmcp_flutter_generator`). `example/pubspec.yaml:1-22`.
- Per `AGENTS.md`'s routing table, "no new dependency" is a condition for the
  `/quick-change` path; this change adds dependencies, so — as a factual
  reading of that table's text, not a decision this research makes — it does
  not meet the `/quick-change` row's stated condition. `AGENTS.md` ("Route by
  change size").
- The generator only emits adapters for annotated public instance methods; it
  never constructs the underlying service and never grants authorization —
  any example demo must supply its own instance, scope, and authorization
  logic explicitly. `wiki/product/webmcp-contract.md:90-96`;
  `packages/webmcp_flutter_generator/README.md:21-23`.
- Duplicate generated tool names and unsupported method signatures fail
  generation (a build-time failure, not a runtime one).
  `packages/webmcp_flutter_generator/README.md:27-28`;
  `wiki/product/webmcp-contract.md:100-101`.
- A working, tested reference implementation of the exact pattern already
  exists in-repo at `packages/webmcp_flutter_generator/example/`, so a
  top-level demonstration would not need to invent the pattern, only relocate
  and simplify it into `example/`.

## Unresolved

- [UNRESOLVED: whether adding this dependency change to `example/` should be
  routed as `/feature` (per the routing table's plain reading in "Constraints
  discovered") or handled some other way — this is a scope/routing decision
  for the planning phase, not something this research resolves.]
- [UNRESOLVED: whether the generated `.webmcp.g.dart` file for any new example
  service should be checked into version control or produced only at build/CI
  time — the generator's own `example/` fixture has its generated file checked
  in (`packages/webmcp_flutter_generator/example/lib/inventory_service.webmcp.g.dart`
  exists in the working tree), but no repo-wide policy on this was found in
  the files read for this research.]
- [UNRESOLVED: whether the top-level example's Chrome-verification step
  (mentioned in the work item title `STATE.yaml`) would need to also exercise
  a generated domain action end-to-end in-browser, or whether a widget-level
  test analogous to `live_instance_test.dart` would satisfy the work item's
  intent — this was outside the boundary of this research task.]

## Sources

- `packages/webmcp_flutter_annotations/lib/webmcp_flutter_annotations.dart` (read 2026-09-15)
- `packages/webmcp_flutter_annotations/README.md` (read 2026-09-15)
- `packages/webmcp_flutter_generator/README.md` (read 2026-09-15)
- `packages/webmcp_flutter_generator/pubspec.yaml` (read 2026-09-15)
- `packages/webmcp_flutter_generator/build.yaml` (read 2026-09-15)
- `packages/webmcp_flutter_generator/lib/builder.dart` (read 2026-09-15)
- `packages/webmcp_flutter_generator/example/pubspec.yaml` (read 2026-09-15)
- `packages/webmcp_flutter_generator/example/lib/inventory_service.dart` (read 2026-09-15)
- `packages/webmcp_flutter_generator/example/lib/inventory_service.webmcp.g.dart` (read 2026-09-15)
- `packages/webmcp_flutter_generator/example/test/live_instance_test.dart` (read 2026-09-15)
- `example/pubspec.yaml` (read 2026-09-15)
- `example/lib/example_tools.dart` (read 2026-09-15)
- repo-wide grep for `webmcp_flutter_annotations|webmcp_flutter_generator|WebMcpDomainAction` scoped to `example/` (run 2026-09-15, no matches)
- `wiki/product/webmcp-contract.md` (read 2026-09-15)
- `AGENTS.md` (read 2026-09-15)
- `wiki/work/0014-example-feature-coverage/STATE.yaml` (read 2026-09-15)
