# webmcp_flutter

`webmcp_flutter` provides an application-owned tool registry, automatic
opt-in Flutter page semantics, and an experimental native Chrome WebMCP
publisher. A wrapped page can expose permitted visible content and supported
semantic actions without one descriptor per widget. Existing manual tools and
custom transports remain supported.

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

## Automatic page setup

Create one session for the application, attach the native publisher, install a
separate forwarding observer on every participating Navigator, and wrap only
pages that may be exposed:

```dart
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

The application owns and disposes the observer, session, and publisher. A
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

Manual input schemas are descriptive only. The outer map is copied and exposed as
unmodifiable, while nested values remain shared. The package does not validate
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

This is still experimental and is not a native-agent support claim. The
required isolated official Chrome Inspector profile currently lacks Gemini
authentication, so no authenticated natural-language model-selected
discover → observe → read → act → navigate → receipt → observe → read trace
has passed. Chrome 152 also supplies no invocation `AbortSignal` after a
callback starts; admitted work may continue and is never automatically
replayed. Positive observation waits, multiple Flutter views, and Chrome web
platform-back gestures are not supported.
