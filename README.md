# webmcp_flutter

`webmcp_flutter` is a local WebMCP-style tool registry and optional Flutter
widget lifecycle layer for web applications. It lets an application declare,
invoke, and remove named asynchronous tools in Dart. The current release only
detects the browser's experimental WebMCP entry point; it does not publish
tools to the browser or accept browser-originated invocations.

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

Input schemas are descriptive only. The outer map is copied and exposed as
unmodifiable, while nested values remain shared. The package does not validate
arguments against the schema at runtime. Registering a source is sequential,
so tools registered before a later failure remain registered.

Local handler results and exceptions pass through unchanged. They are not
normalized into a browser-safe result or error envelope. With a custom
transport, registry mutations happen before registration and unregistration
notifications; a notification exception propagates without rolling the
mutation back. `reset` clears local tools and replaces the transport without
notifying, unregistering from, or disposing the previous transport. Callers
that provide stateful transports must clean up their external state.

## Browser and platform support

Version 0.1.0 supports Flutter web with a minimum of Flutter 3.47.0 and Dart
3.13.0. Other Flutter platforms are not supported by this release.

The built-in web transport checks whether `document.modelContext` is present
and logs registry changes. Detection and logs do not publish, invoke, discover,
or unregister browser tools. Browser interoperability and the experimental
WebMCP API remain outside the current package contract.
