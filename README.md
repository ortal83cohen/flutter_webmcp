# webmcp_flutter

[![Pub Version](https://img.shields.io/pub/v/webmcp_flutter.svg)](https://pub.dev/packages/webmcp_flutter)
[![Pub Points](https://img.shields.io/pub/points/webmcp_flutter.svg)](https://pub.dev/packages/webmcp_flutter/score)
[![Pub Popularity](https://img.shields.io/pub/popularity/webmcp_flutter.svg)](https://pub.dev/packages/webmcp_flutter/score)
[![Pub Likes](https://img.shields.io/pub/likes/webmcp_flutter.svg)](https://pub.dev/packages/webmcp_flutter)
[![CI](https://github.com/ortal83cohen/flutter_webmcp/actions/workflows/checks.yml/badge.svg)](https://github.com/ortal83cohen/flutter_webmcp/actions/workflows/checks.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

`webmcp_flutter` provides an application-owned tool registry, automatic
opt-in Flutter page semantics, and an experimental native Chrome WebMCP
publisher. A wrapped page can expose permitted visible content and supported
semantic actions without one descriptor per widget. Existing manual tools and
custom transports remain supported.

## What your application gets

| Feature | What you can expose or control | Main API |
| --- | --- | --- |
| Explicit tools | Synchronous or asynchronous application operations with descriptions, input schemas, and agent hints | `WebMcpTool`, `WebMcp.instance` |
| Lifetime ownership | Register a group of tools and remove it when its owner closes | `WebMcpScope` |
| Widget integration | Expose a callback while a widget is mounted, or register tools for a screen | `WebMcpAction`, `WebMcpScreen` |
| Automatic page reading | Read permitted Flutter semantics: labels, hints, roles, states, values, and optional bounds | `WebMcpPage`, `<pageId>.page.read` |
| Automatic page actions | Tap, scroll, adjust values, and explicitly permitted text editing or long press | `<pageId>.page.act` |
| App observation | Poll eligible page scopes, semantic changes, navigation, and operation evidence | `WebMcpAppSession`, `<appId>.app.observe` |
| Exposure policy | Exclude sensitive subtrees and opt individual fields into reading or editing | `WebMcpPagePolicy` |
| Generated service tools | Generate descriptors and typed argument decoding for annotated methods on an existing service | `@WebMcpDomainAction` |
| Experimental browser publication | Mirror tools into the browser's native WebMCP surface and inspect publication status | `WebMcpNativePublisher` |
| Custom integrations | Receive registry changes through a transport or additional observers | `WebMcpTransport`, `WebMcpRegistryObserver` |

Manual tools work independently of automatic pages. Browser publication is a
separate opt-in step: registering a tool locally does not itself connect an AI
agent. Automatic pages expose the materialized Flutter semantics inside opted-in
boundaries; they do not inspect arbitrary application state or unbuilt content.
See [Browser and platform support](#browser-and-platform-support) for the current
experimental support boundary.

## Installation

Add the package to a Flutter application:

```sh
flutter pub add webmcp_flutter
```

Import its public library as
`package:webmcp_flutter/webmcp_flutter.dart`.

## Minimal Flutter example

This complete `lib/main.dart` registers an action while `CounterPage` is
mounted. The button and tool call the same method because `WebMcpAction` keeps
its child unchanged and does not inspect the widget tree.

```dart
import 'package:flutter/material.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';

void main() {
  runApp(const MaterialApp(home: CounterPage()));
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage>
    with WebMcpScreen<CounterPage> {
  int _count = 0;

  int _increment() {
    setState(() => _count++);
    return _count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: WebMcpAction(
          name: 'counter.increment',
          description: 'Increments the visible counter.',
          onInvoke: (Map<String, Object?> arguments) => _increment(),
          child: ElevatedButton(
            onPressed: _increment,
            child: Text('Count: $_count'),
          ),
        ),
      ),
    );
  }
}
```

Imperative tools can instead be registered through
`WebMcp.instance.registerTool`. Local callers invoke either kind with
`await WebMcp.instance.invokeTool(name, arguments)`.

## Manual tools, scopes, and screen lifecycle

Use an explicit tool when an operation belongs to your application or service
rather than a semantic UI action. Validate inputs and enforce current application
authorization in the handler:

```dart
final scope = WebMcpScope(scopeName: 'inventory-session');
scope.addTool(WebMcpTool(
  name: 'inventory.lookup',
  description: 'Returns an item identifier for a supplied SKU.',
  inputSchema: {
    'type': 'object',
    'properties': {
      'sku': {'type': 'string'},
    },
    'required': ['sku'],
    'additionalProperties': false,
  },
  annotations: const WebMcpToolAnnotations(readOnlyHint: true),
  handler: (arguments) async {
    final sku = arguments['sku'];
    if (sku is! String || sku.isEmpty || arguments.length != 1) {
      throw ArgumentError('Expected a non-empty SKU.');
    }
    // Replace this synthetic result with your authorized application lookup.
    return <String, Object?>{'sku': sku};
  },
));

final result = await WebMcp.instance.invokeTool('inventory.lookup', {
  'sku': 'DEMO-001',
});
print(result);
scope.close(); // Remove this owner's tools when its lifetime ends.
```

`WebMcp.instance.tools` returns an immutable snapshot sorted by name.
`registerTool`/`unregisterTool` manage individual descriptors. Implement
`WebMcpToolSource.getWebMcpTools()` to supply a batch, then use `registerSource`
or `scope.addSource`. A scope exposes `ownedNames`, `skippedNames`, and `isClosed`;
`removeTool` removes only a name it owns. `scopeName` is diagnostic and does not
prefix tool names.

With `WebMcpScreen`, override `registerWebMcpTools()` and add descriptors or
sources through `mcpScope`; the hook runs during `initState` after scope creation.
Call `super.initState()` and `super.dispose()` if you override those lifecycle
methods. Descendant `WebMcpAction` widgets use the nearest screen scope, and
`WebMcpScreen.maybeScopeOf(context)` lets an integration find it explicitly.
Mount lifetime is different from route visibility: a covered but mounted screen's
manual tools are not automatically disabled by navigation.

`WebMcpToolAnnotations` also supports `untrustedContentHint` and
`consequentialHint`. These are descriptive hints, not authorization checks.
Registry failures have distinct types: `WebMcpInvalidToolNameException`,
`WebMcpDuplicateToolException`, `WebMcpToolNotFoundException`, and
`WebMcpScopeMissingException` (an action without a screen scope). All derive
from `WebMcpException`, which exposes `toolName` and `message`.

## Automatic page setup

Create one session for the application, attach the native publisher, install a
separate forwarding observer on every participating Navigator, and wrap only
pages that may be exposed:

```dart
WidgetsFlutterBinding.ensureInitialized();
final session = WebMcpAppSession();
session.attach(appId: 'shop');

final publisher = WebMcpNativePublisher();
await publisher.attach();

final rootObserver = WebMcpNavigatorAdapter(
  session: session,
  navigatorId: 'root',
  rootModalRelationship: true,
);

MaterialApp(
  navigatorObservers: <NavigatorObserver>[rootObserver],
  home: WebMcpPage(
    pageId: 'catalog',
    child: const CatalogPage(),
  ),
);
```

This setup fragment belongs in application initialization; `CatalogPage` is
an application-provided widget. Create these objects once, not on every build.
Keep existing Navigator observers and append the WebMCP adapter alongside them.
For a runnable application with lifecycle cleanup, see [example/lib/main.dart](example/lib/main.dart).

The application owns the observer, session, and publisher. During teardown call
`rootObserver.dispose()`, `session.detach()`, and `await publisher.detach()`
(use `unawaited` for the publisher in synchronous Flutter `dispose`). A
wrapped page registers `<pageId>.page.read` and `<pageId>.page.act`; the
session registers `<appId>.app.observe`. Observation is immediate polling:
pass the returned application cursor to receive later bounded metadata.
Navigation receipts are retained by the application session even if the
originating page is disposed.

Automatic exposure requires exactly one Flutter view and complete settled
Navigator evidence. Covered, background, ambiguous, disposed, unknown-
transition, and unwrapped modal scopes fail closed. Nested Navigators require
their own adapter. Persistent branches require an explicit `selectedBranch`;
unsupported arrangements may additionally provide page `activity` evidence.
Navigation evidence never replaces the `WebMcpPage` semantic boundary.

By default obscured editable values are omitted, `setText` and long press are
disabled, and bounds are hidden. Use `WebMcpPagePolicy` to opt into the minimum
additional fields or actions required. Excluded and sensitive semantic
identifiers remove complete subtrees.

### Read and act on a page

Call the page tools after its route and semantics have settled. The following
fragment reads tappable nodes, then invokes a node from that exact snapshot:

```dart
final registry = WebMcp.instance;
final snapshot = await registry.invokeTool('catalog.page.read', {
  'actions': ['tap'],
  'limit': 20,
}) as Map<String, Object?>;

if (snapshot['ok'] == true) {
  final nodes = snapshot['nodes']! as List;
  if (nodes.isNotEmpty) {
    final node = nodes.first as Map;
    // In a real client, select the node matching the user's intended action.
    final receipt = await registry.invokeTool('catalog.page.act', {
      'pageId': snapshot['pageId'],
      'mountToken': snapshot['mountToken'],
      'revision': snapshot['revision'],
      'handle': node['handle'],
      'action': 'tap',
      'requestId': 1, // Increase for each new request on this page mount.
      'arguments': <String, Object?>{},
    });
    print(receipt);
  }
}
```

`page.read` accepts optional `query`, `roles`, `actions`, `limit`, and `cursor`.
Use `nextCursor` from a response to page through the captured window. Returned
nodes include opaque handles, roles (`textField`, `button`, `link`, `header`,
`checkbox`, or `generic`), optional labels/hints/values, semantic states,
action names, and parent handles where available. `coverage` reports partial or
truncated results, budgets, and unknown coverage for unbuilt content. Scroll and
read again to discover newly materialized content; a snapshot is not the entire
logical dataset of a lazy list.

Only invoke actions advertised by the selected node:

| Action | Arguments and requirements |
| --- | --- |
| `tap` | Empty arguments; node must currently allow tapping |
| `increase`, `decrease` | Empty arguments; node must advertise the corresponding adjustment |
| `scrollLeft`, `scrollRight`, `scrollUp`, `scrollDown` | Empty arguments; read a fresh snapshot afterward |
| `longPress` | Empty arguments; requires `allowLongPress: true` |
| `setText` | `{'text': 'new value'}`; field identifier must be allowed for both value exposure and text editing |

Actions recheck mount, revision, activity, policy, and current semantic support.
Handles and cursors are opaque and must not be constructed or reused across page
mounts. Use increasing positive `requestId` values up to
`webMcpMaxSafeInteger`. A matching retry of the latest request can return its
cached receipt while the snapshot remains valid; this is not durable exactly-once
execution. A dispatch receipt does not prove that a backend operation succeeded.

### Control exposed content and text editing

Give a field a Flutter semantic identifier and explicitly permit the operations
you need. This fragment exposes a search field's value and permits `setText`:

```dart
WebMcpPage(
  pageId: 'search',
  policy: WebMcpPagePolicy(
    editableValueIdentifiers: {'search-query'},
    setTextIdentifiers: {'search-query'},
    sensitiveSemanticsIdentifiers: {'account-secret'},
    excludedSemanticsIdentifiers: {'internal-debug-panel'},
    maxTextLength: 200,
  ),
  child: Scaffold(
    body: Semantics(
      identifier: 'search-query',
      child: TextField(),
    ),
  ),
)
```

The identifier must belong to the editable semantic node captured by Flutter.
Inspect the resulting page read before relying on a custom widget's semantics.
Exclusion and sensitivity sets omit whole matching subtrees. Obscured fields are
omitted. Ordinary non-editable values are included by default; turn them off with
`includeNonEditableValues: false`. `includeBounds: true` adds bounds labeled in
Flutter-view coordinates. Long press is separately enabled with `allowLongPress`.

### Observe navigation and operation results

```dart
final first = await WebMcp.instance.invokeTool('shop.app.observe', {
  'waitMs': 0,
}) as Map<String, Object?>;

if (first['ok'] == true) {
  // Poll later, after the application has had an opportunity to change.
  final next = await WebMcp.instance.invokeTool('shop.app.observe', {
    'cursor': first['cursor'],
    'waitMs': 0,
  });
  print(next);
}
```

Observation returns `appMount`, `cursor`, `eligibleScopes`, `events`, `unchanged`,
`gap`, `refreshRequired`, `eventCoverage`, and `waitCapability`. An optional
`scopeReference` filters observation to a currently eligible scope. Scope
references are broker identifiers, distinct from page IDs and mount tokens.
If retained events are no longer available, use the reported gap/refresh state to
rediscover and reread current pages. Positive `waitMs` returns `unsupportedWait`;
choose a polling interval in your client rather than running a tight loop.

Operation evidence distinguishes `commandDispatched`, `visibleEffectObserved`,
`domainFutureCompleted`, and `backendConfirmed`. Future completion alone does not
prove success. An application that has an actual backend confirmation may call
`session.confirmBackend(operationId: operationId, outcome: 'succeeded')`;
`failed` and `cancelled` are also accepted outcomes. Retrieve retained evidence
with `session.operationReceipt(operationId)`. Receipts can survive source-page
navigation, subject to the session's retention and capacity limits.

For nested navigation, install a distinct `WebMcpNavigatorAdapter` with a unique
`navigatorId` and the appropriate `parentNavigatorId`. Persistent parallel
branches additionally need `persistentParallelBranch: true` and a
`ValueListenable<bool>` in `selectedBranch`. A page's optional `activity`
listenable supplies additional explicit evidence; it does not override missing
or unsafe navigation evidence. `markTransitionUnknown()` revokes eligibility
when an integration cannot prove a transition. Do not reuse an observer instance
across Navigators.

### Resource limits and error handling

Pass `limits: WebMcpPageLimits(...)` when constructing the session to lower
resource ceilings. Defaults include 128 live scopes, 32 Navigator adapters,
256 retained events, 32 events per observation, 200 returned nodes, 1,000 visited
nodes, depth 32, and 64 KiB per read. Up to 32 operation receipts are retained
for 30 seconds. Limits can be reduced, not raised above the built-in ceilings.
The exported `WebMcpViewProvider`, `WebMcpBindingViewProvider`, and
`WebMcpViewBinding` provide a view-discovery seam for integrations and testing;
automatic exposure still requires exactly one supported Flutter view.

Page and observation responses carry `protocolVersion` and `ok`. Errors include
`code`, a safe `message`, `retryable`, and `refreshRequired`. Handle
`staleSnapshot`, `invalidCursor`, or `unknownHandle` by obtaining fresh context;
handle `inactiveScope` or `scopeGone` by observing the currently eligible pages.
Respect `busy` and `resourceLimit` without automatically replaying consequential
work. The complete error vocabulary is exported as `WebMcpPageErrorCode`.

## Generated domain actions

The optional packages under `packages/` generate a `WebMcpToolSource` only for
methods annotated with `@WebMcpDomainAction`. The generated source accepts the
consumer's existing live service instance; it never constructs the service or
replaces application authorization.

Supported inputs and outputs are `String`, `bool`, JSON-safe `int`, finite
`double`, enums, nullable forms, and recursively bounded `List` or
`Map<String, T>` values. Unsupported signatures and duplicate names fail the
build. See
`packages/webmcp_flutter_generator/example/lib/inventory_service.dart`.

Run generation in the consumer package with:

```sh
dart run build_runner build
```

### Set up generation in a consumer application

The companion packages are included in this repository; publication availability
is not established here. For a local checkout beside your consumer app, add
these entries to the consumer's existing `pubspec.yaml`, adjusting the paths:

```yaml
dependencies:
  webmcp_flutter:
    path: ../flutter_webmcp
  webmcp_flutter_annotations:
    path: ../flutter_webmcp/packages/webmcp_flutter_annotations

dev_dependencies:
  build_runner: ^2.16.0
  webmcp_flutter_generator:
    path: ../flutter_webmcp/packages/webmcp_flutter_generator

dependency_overrides:
  webmcp_flutter_annotations:
    path: ../flutter_webmcp/packages/webmcp_flutter_annotations
```

Create `lib/stock_service.dart`:

```dart
import 'package:webmcp_flutter_annotations/webmcp_flutter_annotations.dart';

class StockService {
  int quantity = 0;

  @WebMcpDomainAction(
    name: 'stock.read',
    description: 'Reads the current stock quantity.',
    readOnlyHint: true,
  )
  int read() => quantity;
}
```

Run `flutter pub get`, then `dart run build_runner build`. The builder creates
`lib/stock_service.webmcp.g.dart` as a separate library, so import it rather than
adding a `part` directive. In your integration file:

```dart
import 'package:webmcp_flutter/webmcp_flutter.dart';
import 'stock_service.dart';
import 'stock_service.webmcp.g.dart';

void registerStock(WebMcpScope scope, StockService liveService) {
  scope.addSource(StockServiceWebMcpSource(liveService));
}
```

Keep the existing live service instance and close the owning scope at teardown.
Alternatively, supply `StockServiceWebMcpSource(liveService)` through
`WebMcpPage(sources: [...], pageId: 'stock', child: ...)` to bind its exposure
to page eligibility. Page-bound sources add operation tracking and bounded
asynchronous execution; plain registry registration does not add those guards.
Methods without the annotation remain unexposed. The generator emits schemas
and validates supported typed inputs/outputs; manual tools do not receive that
validation automatically. For enums, optional/default parameters, nested
collections, and asynchronous methods, see the
[complete generator fixture](packages/webmcp_flutter_generator/example/lib/inventory_service.dart).

## Browser publication and diagnostics

Attach a publisher once after Flutter binding initialization, whether your tools
are manual, generated, or automatic page tools:

```dart
final publisher = WebMcpNativePublisher();
final status = await publisher.attach();
print(status.toDiagnosticMap());
// At application teardown:
await publisher.detach();
```

The publisher mirrors existing tools and follows later registration changes.
`detach()` releases its browser registrations while leaving local tools intact.
Status reports `support`, published/skipped counts, retained operation and
outstanding execution counts, capabilities, and safe reason codes.
`localOnly` indicates the browser surface is unavailable; `browserDetected`
indicates detection; `conformanceUsable` reflects successful registration;
`failed` reports classified publication failures. None proves an authenticated
agent has completed a workflow. The capability report describes the recorded
Chrome 152 matrix, not a fresh browser feature test.

Browser invocation uses bounded JSON input/output (64 KiB, nesting depth 32),
with at most 128 owned registrations and 32 outstanding executions. Invalid
wire values and handler failures become safe error responses. Check diagnostic
reason codes and skipped counts when a locally registered tool is missing in
the browser. See the support section below for cancellation and native-agent
limitations.

## Custom transports and registry observers

Implement `WebMcpTransport` with `id`, `onToolRegistered(WebMcpTool)`, and
`onToolUnregistered(String)` to forward lifecycle changes to your integration.
Install it with `WebMcp.instance.reset(customTransport)` **before registering
tools**, because reset clears the registry. The default transport detects the
browser surface; explicit native publication is handled by the publisher.
Your custom transport supplies its own communication mechanism and can dispatch
incoming calls through `invokeTool`.

For additional listeners without replacing the transport, implement
`WebMcpRegistryObserver` and call `addRegistryObserver(observer)`. Keep the
returned `WebMcpRegistrySubscription` and call `cancel()` when finished;
`isActive` reports its state. Observers receive future mutations, so use `tools`
for the initial snapshot. They run after transport notifications, in subscription
order, and an observer exception is isolated from other observers. Integrations
that need reset cleanup can also implement `WebMcpRegistryResetObserver`.
The native publisher uses this additive observation mechanism.

## Current contract

Tool names must contain 1 to 128 ASCII letters, digits, underscores, hyphens,
or periods. Names share one process-wide namespace. The first live
registration owns a name; a later `WebMcpScope` records the duplicate as
skipped and cannot remove the first owner's tool. Closing a scope removes its
owned tools, is idempotent, and permanently prevents further additions.

`WebMcpAction` registers for its mounted lifetime. Its registered name,
description, and input schema remain the values from the initial mount until
the action is unmounted and mounted again. Its handler calls the latest
`onInvoke` callback. A disabled child does not disable the registered tool or
grant invocation authority; omit or unmount the wrapper when invocation should
be unavailable.

Manual input schemas are descriptive only. The schema's outer map is copied and exposed as
unmodifiable, while nested schema values remain shared. The package does not validate
arguments against the schema at runtime. Registering a source is sequential,
so tools registered before a later failure remain registered.

Local handler results and exceptions pass through unchanged. The native
publisher separately validates bounded JSON input/output and sanitizes browser
errors. With a custom
transport, registry mutations happen before registration and unregistration
notifications; a notification exception propagates without rolling the
mutation back. `reset` clears local tools and replaces the transport without
notifying, unregistering from, or disposing the previous transport. Callers
that provide stateful transports must clean up their external state.

## Browser and platform support

The implementation targets Flutter web with a minimum of Flutter 3.47.0 and Dart
3.13.0. Other Flutter platforms are not supported by this release.

`WebMcpNativePublisher` additively mirrors local tools to same-origin
`document.modelContext` without replacing the current transport. Chrome 152
JavaScript and Wasm page conformance proves registration, discovery, direct
native invocation, registration-signal cleanup, cancel-before-dispatch, safe
errors, immediate observation, cursor recovery, and navigation receipts.
The repository's [recorded implementation evidence](wiki/work/0008-automatic-page-agent/19-implementation-evidence.md)
includes JavaScript and Wasm direct native API sequences and a later Wasm
covered-page navigation fix. These are recorded local conformance results, not
an independently completed native-agent support gate.

This is still experimental and is not a native-agent support claim. The
required isolated official Chrome Inspector profile currently lacks Gemini
authentication, so no authenticated natural-language model-selected
discover → observe → read → act → navigate → receipt → observe → read trace
has passed. Chrome 152 also supplies no invocation `AbortSignal` after a
callback starts; admitted work may continue and is never automatically
replayed. Positive observation waits, multiple Flutter views, and Chrome web
platform-back gestures are not supported.


## Runnable examples and further reading

From this repository, launch the example application:

```sh
cd example
flutter pub get
flutter run -d chrome
```

The UI and local registry can be exercised independently of native browser
availability. Browser discovery requires an environment providing the experimental
native WebMCP surface.

- [Example application](example/lib/main.dart): app session, Navigator adapter, publisher lifecycle.
- [Example screen](example/lib/example_screen.dart): manual and automatic integration.
- [Generator consumer](packages/webmcp_flutter_generator/example): annotated service, generated adapter, and tests.
- [Public library exports](lib/webmcp_flutter.dart): available consumer APIs.
- [Detailed package contract](wiki/product/webmcp-contract.md): protocol and ownership rules.
