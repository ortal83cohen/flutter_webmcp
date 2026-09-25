# Research: Jobs a Flutter application author can already do

## Question

Which jobs can a Flutter application author already do with `webmcp_flutter`, which of those jobs still force that author to write manual glue because of an API gap or a deliberate omission, and how should the remaining glue jobs be ranked by how often the documented integration path hits them?

## Answer

The author can already register and invoke explicit tools, bind them to a screen or widget lifetime, generate typed tools for annotated service methods, expose one opted-in page as bounded read and act tools, poll application observation, and mirror the local registry to the experimental browser surface. The same jobs still require author-owned glue wherever the contract withholds runtime schema validation, authorization, route-visibility gating, generated route wrapping, positive waits, in-flight cancellation, generalized proxies, and automatic transport cleanup. Rank that glue by where it sits in the README typical setup and in the example startup, not by guessed popularity: handler authorization and manual argument checks come first, then page and navigator wiring, then widget-lifetime gaps, then optional publication, observation, generator, and transport work.

## Findings

### Jobs the public API already performs

- Claim: The author can declare an explicit tool, register and unregister it on one process-wide registry, list tools, and invoke a handler locally.
- Evidence: `WebMcpTool` carries name, description, input schema, annotations, and handler. `WebMcp.instance` exposes `registerTool`, `registerSource`, `unregisterTool`, `tools`, and `invokeTool`.
- Source: `lib/src/webmcp_tool.dart:32-57`, `lib/src/webmcp.dart:87-143`, `lib/webmcp_flutter.dart:1-11`

- Claim: The author can batch tools through `WebMcpToolSource`, group them in a `WebMcpScope` that skips duplicates and removes only names it owns, attach them to a `State` with `WebMcpScreen`, or attach one callback to a mounted child with `WebMcpAction`.
- Evidence: `registerSource` and `addSource` walk `getWebMcpTools()`. A scope records skipped duplicates and `close()` unregisters owned names. `WebMcpAction` registers only when `WebMcpScreen.maybeScopeOf` finds a scope, and removes the tool on dispose when it owns it.
- Source: `lib/src/webmcp_tool_source.dart:4-7`, `lib/src/webmcp_scope.dart:21-74`, `lib/src/widgets/webmcp_screen.dart:6-40`, `lib/src/widgets/webmcp_action.dart:10-80`

- Claim: The author can replace the transport, observe later registry mutations, and receive a reset hook. Reset clears tools and cancels observer subscriptions. It does not unregister or dispose the previous transport.
- Evidence: `reset` installs the supplied transport or the platform default after cancelling subscriptions. `addRegistryObserver` returns a cancellable `WebMcpRegistrySubscription`. `WebMcpRegistryResetObserver.onRegistryReset` runs during reset.
- Source: `lib/src/webmcp.dart:73-85`, `lib/src/webmcp.dart:145-171`, `lib/src/transport/webmcp_transport.dart:4-12`, `wiki/product/webmcp-contract.md:110-114`

- Claim: With one attached `WebMcpAppSession`, one `WebMcpNavigatorAdapter` per participating Navigator, and a `WebMcpPage`, the author gets `<appId>.app.observe`, `<pageId>.page.read`, and `<pageId>.page.act` for that page's mounted lifetime. Page policy can exclude subtrees and opt individual fields into value exposure, `setText`, long press, and bounds.
- Evidence: `attach` registers the observe tool. An eligible page registers read and act. `WebMcpPagePolicy` fields match that exposure list. README maps this job to those three types.
- Source: `lib/src/page/webmcp_app_session.dart:154-183`, `lib/src/page/webmcp_page.dart:569-589`, `lib/src/page/webmcp_page_protocol.dart:244-302`, `README.md:41-42`, `README.md:78-81`

- Claim: The author can attach page-scoped domain sources, record `confirmBackend` outcomes, and read `operationReceipt`. Evidence kinds are dispatch, visible change, domain future completion, and explicit backend confirmation.
- Evidence: `WebMcpPage.sources` are registered only while the page is eligible, and each handler is wrapped with operation tracking. `confirmBackend` accepts `succeeded`, `failed`, and `cancelled`.
- Source: `lib/src/page/webmcp_page.dart:44-45`, `lib/src/page/webmcp_page.dart:601-666`, `lib/src/page/webmcp_app_session.dart:14-25`, `lib/src/page/webmcp_app_session.dart:298-322`

- Claim: The author can mirror the local registry with `WebMcpNativePublisher.attach` and `detach`, and read a diagnostic status. Local registration does not itself publish to the browser.
- Evidence: `attach` snapshots current tools and follows later mutations. `detach` aborts registrations it owns. README states that registering locally does not connect an agent.
- Source: `lib/src/transport/webmcp_native_publisher.dart:175-223`, `README.md:43-49`, `README.md:86-88`

- Claim: For annotated public instance methods, the author can generate a `WebMcpToolSource` that accepts a live service instance. The generator does not construct the service or grant authorization.
- Evidence: `@WebMcpDomainAction` documents that limit. The contract says generated adapters accept a consumer-created instance. README shows `scope.addSource` or `WebMcpPage.sources` as the wiring step. The example registers `ExampleTaskServiceWebMcpSource` from application startup.
- Source: `packages/webmcp_flutter_annotations/lib/webmcp_flutter_annotations.dart:4-7`, `wiki/product/webmcp-contract.md:90-96`, `README.md:419-424`, `README.md:487-495`, `example/lib/example_runtime.dart:69-81`

- Claim: Shipped work items record these jobs as already implemented in the README and the example, including manual tools, page read and act, observation, generation setup, and publisher diagnostics. Work item 0008 does not claim a completed native-agent trace.
- Evidence: The README feature-guide record lists those sections as written. The example coverage state says the example was extended in place and that custom view providers, custom limits, and nested or parallel adapters stayed undemonstrated. The 0008 state still lists the authenticated model-selected trace as an open blocker.
- Source: `wiki/work/0012-readme-feature-guide/RECORD.md:5-10`, `wiki/work/0014-example-feature-coverage/STATE.yaml:16-28`, `wiki/work/0008-automatic-page-agent/STATE.yaml:20-24`

### Glue the author still writes

- Claim: Every explicit tool still needs the author to enforce authorization inside the handler or the service. Annotations and the generator do not grant it.
- Evidence: Tool annotations "never grant authorization". The contract says consumers must "retain application authorization". README typical setup step 2 says to enforce authorization in each handler. The example task service throws when `authorized` is false, and its comment says the generated adapter never grants authorization.
- Source: `lib/src/webmcp_tool.dart:9-12`, `wiki/product/webmcp-contract.md:155-157`, `README.md:55-56`, `example/lib/example_task_service.dart:6-8`, `example/lib/example_task_service.dart:28-30`

- Claim: Manual tools still need a hand-written argument check and, in the example, a hand-written failure envelope. The registry does not validate `inputSchema` at runtime. This is the documented behavior for every manual registration, which is typical setup step 2, before any optional page or browser step.
- Evidence: The contract says the schema is descriptive and the registry performs no runtime JSON Schema validation. README repeats that manual schemas are descriptive only. The inventory fragment in the README checks `sku` inside the handler. `ExampleCounterSource._add` rejects a non-positive `amount` and returns an author-defined `{ok: false, error: {code: invalidArguments}}` map. `registerExampleTools` registers argument-free tools and does not show that check. Generated adapters do validate supported typed inputs before the domain method runs.
- Source: `wiki/product/webmcp-contract.md:40-41`, `README.md:159-185`, `README.md:567-569`, `README.md:497-499`, `example/lib/example_counter_source.dart:5-11`, `example/lib/example_counter_source.dart:55-67`, `example/lib/example_tools.dart:49-65`, `wiki/product/webmcp-contract.md:98-101`

- Claim: Exposing an approved page still requires the author to create the session, attach a distinct navigator adapter to every participating Navigator, wrap each approved page, and dispose those objects. Generated route wrapping is a deliberate omission, so this wiring is author-owned even though read, act, and observe then run without one descriptor per widget.
- Evidence: The contract lists "generated route wrapping" among omissions and says consumers must "install every required Navigator adapter" and own session cleanup. README typical setup step 3 states the same sequence, and step 5 adds cleanup. The example performs that sequence once in `ExampleRuntime.install` and `createRootNavigatorAdapter`, then wraps `example.home`, `example.details`, and `example.form` individually. ADR 0004 rejects inferring exposure from navigation alone.
- Source: `wiki/product/webmcp-contract.md:146-157`, `README.md:57-63`, `README.md:216-252`, `example/lib/example_runtime.dart:69-94`, `example/lib/example_runtime.dart:107-112`, `example/lib/example_screen.dart:160-162`, `example/lib/example_screen.dart:305-307`, `example/lib/example_form_screen.dart:109-111`, `wiki/adr/0004-use-semantic-page-boundaries-and-app-observation.md:64-67`

- Claim: A mounted `WebMcpAction` or `WebMcpScreen` tool stays invokable when its child is disabled or when a later route covers the screen. The author must omit or unmount the wrapper to withdraw it. Descriptor name, description, and schema stay at the values from the first mount, and `WebMcpAction` has no annotations parameter.
- Evidence: The contract states both the disabled-child rule and the fixed-descriptor rule. README says mount lifetime is not route visibility. `didChangeDependencies` returns immediately once `_registered` is true. The action constructor takes name, description, input schema, `onInvoke`, and child only. Example state records that a push leaves screen-owned tool names registered because `MaterialPageRoute.maintainState` defaults to true.
- Source: `wiki/product/webmcp-contract.md:51-59`, `README.md:206-207`, `README.md:563-565`, `lib/src/widgets/webmcp_action.dart:13-21`, `lib/src/widgets/webmcp_action.dart:49-54`, `wiki/work/0014-example-feature-coverage/STATE.yaml:49-51`

- Claim: Text editing, long press, bounds, and sensitive or excluded content still require the author to assign Flutter semantic identifiers and list them on `WebMcpPagePolicy`. A page read does not echo those identifiers, so an author-written caller selects nodes by label, role, or handle.
- Evidence: Defaults omit obscured editable values and disable `setText` and long press. The form example builds a non-default policy and a `Semantics` node per behavior. The captured node wire includes handle, role, label, hint, value, states, actions, optional bounds, and parent handle, and does not include the semantics identifier. Example coverage state says page nodes are targeted by their fixed semantics label because the read response carries no identifier field.
- Source: `README.md:266-269`, `README.md:329-357`, `example/lib/example_form_screen.dart:47-62`, `example/lib/example_form_screen.dart:117-125`, `lib/src/page/webmcp_page.dart:522-546`, `wiki/work/0014-example-feature-coverage/STATE.yaml:42`

- Claim: Browser publication still requires an explicit attach after binding initialization and an explicit detach. Admitted handler work is not cancelled after the callback starts. Positive observation waits are omitted, so a caller must poll with `waitMs` 0. Backend success still requires an explicit `confirmBackend` call.
- Evidence: The omissions list names positive observation waits, in-flight callback termination, and Chrome web platform-back-gesture support. README says positive `waitMs` returns `unsupportedWait` and tells the client to choose a polling interval. The diagnostics screen calls observe with `waitMs: 250` and prints `waitCapability`. `WebMcpNativeCapabilities.chrome152` sets `invocationCancellationAfterCallbackStart` and `positiveWait` to false. The example application sources do not call `confirmBackend`. README still documents that call as application-owned.
- Source: `wiki/product/webmcp-contract.md:146-153`, `wiki/product/webmcp-contract.md:130-132`, `README.md:60-61`, `README.md:381-390`, `README.md:600-603`, `example/lib/example_diagnostics_screen.dart:46-49`, `lib/src/transport/webmcp_native_capabilities.dart:12-18`

- Claim: A service method that is not an annotated public instance method is not generated. Generalized service proxies, framework-specific state adapters, and custom data providers are deliberate omissions, so the author writes a `WebMcpTool` or `WebMcpToolSource` and keeps the live instance. Companion-package publication is not established in the README, which shows path dependencies and `build_runner`.
- Evidence: The contract omission sentence lists those three items and says generated adapters do not intercept arbitrary calls. `clearTasks` is intentionally unannotated. README says publication availability is not established in that document.
- Source: `wiki/product/webmcp-contract.md:146-153`, `wiki/product/webmcp-contract.md:95-96`, `example/lib/example_task_service.dart:45-48`, `README.md:440-441`, `README.md:432-436`

- Claim: A custom transport still requires the author to implement delivery and to clean up external state before `reset`. Registration is not transactional, notification failures do not roll back, and nested schema objects stay shared.
- Evidence: The omissions list names deep schema immutability, transactional source registration, notification rollback, and automatic cleanup of custom transports. The example installs `ExampleRecordingTransport` by calling `reset` before any registration, then resets again on dispose. README says callers that provide stateful transports must clean up external state.
- Source: `wiki/product/webmcp-contract.md:103-114`, `wiki/product/webmcp-contract.md:146-153`, `example/lib/example_runtime.dart:56-75`, `example/lib/example_runtime.dart:107-112`, `README.md:572-579`

- Claim: Multiple Flutter views and non-web platforms are not delivered. An author who needs them cannot get that behavior from this package and has to keep those hosts outside it. The documented web integration requires exactly one Flutter view.
- Evidence: The omissions list names "Multiple-Flutter-view operation" and "non-web product support". README says other Flutter platforms are not supported by this release and that automatic exposure requires exactly one Flutter view. ADR 0004 repeats the one-view limit.
- Source: `wiki/product/webmcp-contract.md:146-153`, `README.md:259-260`, `README.md:583-584`, `wiki/adr/0004-use-semantic-page-boundaries-and-app-observation.md:47-48`

### Rank of the remaining glue

- Claim: The remaining glue jobs, ordered by how early and how unconditionally the README typical setup, the contract's consumer duties, and the example startup hit them, are: (1) authorization inside every handler or service; (2) hand-written argument checks and failure envelopes for manual tools; (3) hand-written session, per-navigator adapter, page wrap, and teardown for every automatic page; (4) unmounting widget tools that must disappear when disabled or covered, and remounting them to change descriptors or add annotations; (5) semantic identifiers, policy sets, and label-based node selection when the page exposes or hides specific content; (6) publisher attach and detach, plus handlers that tolerate non-cancelled in-flight work, when browser publication is used; (7) client polling and an explicit `confirmBackend` call when observation or backend evidence is required; (8) a hand-written tool or source for anything the generator will not annotate, including build-runner wiring; (9) custom-transport cleanup and partial-registration handling when a transport or fallible source is used; (10) extra adapters, `selectedBranch`, or `activity` only for nested, parallel, or otherwise unsupported navigation; (11) no in-library substitute for multiple views or non-web hosts.
- Evidence: README typical setup orders unconditional tool registration and handler checks first, page wiring second, publisher attach third, and ownership of transports last. The integrations table lists explicit tools before page tools, generated tools, browser publication, and custom transports, and says the integrations are independent. The example always runs authorization-bearing services, a hand-written validating source, session attach, one root adapter, and a page wrap per demonstrated screen. It does not demonstrate nested adapters, custom limits, or `confirmBackend`. Contract omissions are what leave steps 3 through 11 on the author. This order is the documented hit order. It is not a popularity estimate.
- Source: `README.md:33-49`, `README.md:51-63`, `wiki/product/webmcp-contract.md:146-157`, `example/lib/example_runtime.dart:69-81`, `wiki/work/0014-example-feature-coverage/STATE.yaml:26-28`

### Disagreement between the contract and later shipped notes

- Claim: The product contract says the integrated Wasm automatic-page fixture still fails and that Wasm automatic-page lifecycle support is not delivered. README and the 0008 state say a later Chrome 152 Wasm run observes only the destination scope after navigation. Both statements are in the repository. This research does not pick one.
- Evidence: Contract browser-boundary paragraph dated by frontmatter `last_verified: 2026-09-15`. README browser section, which work item 0012 says was corrected from the 0008 evidence. 0008 blocker V-001 is closed with the opposite Wasm result. Native-agent support remains unclaimed in all three.
- Source: `wiki/product/webmcp-contract.md:134-144`, `README.md:587-603`, `wiki/work/0012-readme-feature-guide/RECORD.md:8-10`, `wiki/work/0008-automatic-page-agent/STATE.yaml:15-24`

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Author-owned workaround on the current API | The author validates and authorizes inside handlers, wraps each page and Navigator by hand, unmounts widget tools to withdraw them, polls `app.observe` with `waitMs` 0, calls `confirmBackend` when a backend result exists, uses the generator only for annotated methods, and disposes transports before `reset`. | Repeated glue at every integration step the README already assigns to the application. No new package behavior. | Chosen. These are the jobs the public API, README, example, and contract already show an author can finish. The contract lists the missing automation as deliberate omissions, so an author cannot get that automation from the library today. |
| Library feature that absorbs the glue | The package would validate manual schemas, tie manual tools to route visibility, generate route and Navigator wrapping, wait inside observe, cancel in-flight calls, proxy arbitrary services, and clean up transports. | Not delivered. Several of those behaviors are named omissions, and ADR 0004 rejected global inspection and generalized proxies for the current design. | Rejected as a description of what the author can do now. It would change the contract, which this research does not reopen. |
| Infer tools from the widget tree or from navigation alone | The author would wrap the app once and the library would discover buttons and pages. | ADR 0004 records this as unable to prove ownership, activity, or privacy. `WebMcpAction` renders the child and does not inspect it. | Rejected. The contract and ADR keep exposure opt-in, so this is not an available way to avoid the glue. |

## Constraints discovered

- Tool names are one process-wide namespace of 1 to 128 ASCII letters, digits, underscores, hyphens, or periods. The first live registration owns a duplicate. A later scope skips it and cannot remove the first owner's tool. Source: `wiki/product/webmcp-contract.md:23-29`, `lib/src/webmcp.dart:58-94`, `lib/src/webmcp_scope.dart:28-34`.
- Automatic pages require exactly one Flutter view, settled Navigator evidence, and an opted-in semantic boundary. Navigation evidence does not replace that boundary. Source: `wiki/product/webmcp-contract.md:70-76`, `README.md:259-264`.
- The quoted omissions are constraints, not backlog: "Multiple-Flutter-view operation, positive observation waits, generated route wrapping, generalized service proxies, framework-specific state adapters, custom data providers, Chrome web platform-back-gesture support, in-flight callback termination, deep schema immutability, transactional source registration, notification rollback, automatic cleanup of custom transports, and non-web product support are not delivered." Source: `wiki/product/webmcp-contract.md:146-153`.
- Consumers must keep names unique, retain authorization, install every required Navigator adapter, and own session, publisher, scope, generated adapter, and custom transport cleanup. Source: `wiki/product/webmcp-contract.md:155-157`.
- Local handler results and exceptions pass through unchanged. Browser publication separately bounds JSON and sanitizes errors. A dispatch receipt does not prove backend success. Source: `README.md:326-327`, `README.md:572-574`, `wiki/product/webmcp-contract.md:81-83`.
- Browser publication is experimental. `WebMcpNativeSupport` has no native-agent-supported value. Source: `lib/src/transport/webmcp_native_capabilities.dart:60-75`, `README.md:596-599`.
- ADR 0003 is superseded by ADR 0004. Its detection-only publishing decision is not the current contract. Source: `wiki/adr/0003-webmcp-detection-first-registry.md:1-6`, `wiki/adr/0004-use-semantic-page-boundaries-and-app-observation.md:40-55`.

## Unresolved

- [UNRESOLVED: which Wasm automatic-page statement is current, the contract's "not delivered" paragraph or the README and 0008 closed-blocker note]
- [UNRESOLVED: whether `webmcp_flutter_annotations` and `webmcp_flutter_generator` are published for an author outside this repository; README says publication availability is not established here]
- [UNRESOLVED: how often a real application has more than one Navigator; the example ships one root adapter and records nested adapters as undemonstrated, so this research cannot rank that glue above the single-adapter case from repository evidence]

## Sources

- `lib/webmcp_flutter.dart`, consulted 2026-09-25
- `lib/src/webmcp.dart`, consulted 2026-09-25
- `lib/src/webmcp_tool.dart`, consulted 2026-09-25
- `lib/src/webmcp_scope.dart`, consulted 2026-09-25
- `lib/src/webmcp_tool_source.dart`, consulted 2026-09-25
- `lib/src/widgets/webmcp_action.dart`, consulted 2026-09-25
- `lib/src/widgets/webmcp_screen.dart`, consulted 2026-09-25
- `lib/src/page/webmcp_page.dart`, consulted 2026-09-25
- `lib/src/page/webmcp_page_protocol.dart`, consulted 2026-09-25
- `lib/src/page/webmcp_app_session.dart`, consulted 2026-09-25
- `lib/src/transport/webmcp_transport.dart`, consulted 2026-09-25
- `lib/src/transport/webmcp_native_publisher.dart`, consulted 2026-09-25
- `lib/src/transport/webmcp_native_capabilities.dart`, consulted 2026-09-25
- `packages/webmcp_flutter_annotations/lib/webmcp_flutter_annotations.dart`, consulted 2026-09-25
- `example/lib/main.dart`, consulted 2026-09-25
- `example/lib/example_runtime.dart`, consulted 2026-09-25
- `example/lib/example_screen.dart`, consulted 2026-09-25
- `example/lib/example_tools.dart`, consulted 2026-09-25
- `example/lib/example_counter_source.dart`, consulted 2026-09-25
- `example/lib/example_task_service.dart`, consulted 2026-09-25
- `example/lib/example_form_screen.dart`, consulted 2026-09-25
- `example/lib/example_diagnostics_screen.dart`, consulted 2026-09-25
- `README.md`, consulted 2026-09-25
- `wiki/product/webmcp-contract.md`, consulted 2026-09-25
- `wiki/adr/0003-webmcp-detection-first-registry.md`, consulted 2026-09-25
- `wiki/adr/0004-use-semantic-page-boundaries-and-app-observation.md`, consulted 2026-09-25
- `wiki/work/0008-automatic-page-agent/STATE.yaml`, consulted 2026-09-25, as a shipped-status record only
- `wiki/work/0012-readme-feature-guide/RECORD.md`, consulted 2026-09-25, as a shipped-status record only
- `wiki/work/0014-example-feature-coverage/STATE.yaml`, consulted 2026-09-25, as a shipped-status record only
