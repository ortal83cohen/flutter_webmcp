# webmcp_flutter_generator

Build-runner generator for explicitly annotated WebMCP domain actions.

Add `webmcp_flutter_annotations` to dependencies and this package plus
`build_runner` to dev dependencies. Then run:

```sh
dart run build_runner build
```

Import the generated `.webmcp.g.dart` library and pass the application's live
instance to the generated source:

```dart
final service = InventoryService(authorization: policy);
final scope = WebMcpScope(scopeName: 'inventory');
scope.addSource(InventoryServiceWebMcpSource(service));
```

Only annotated public instance methods are generated. The adapter never creates
or caches another domain instance. Application authorization, instance
lifecycle, and scope cleanup remain consumer-owned.

Supported values are `String`, `bool`, safe JSON `int`, finite `double`, enums,
nullable forms, and recursive `List` or `Map<String, T>` collections.
Unsupported signatures and duplicate names fail generation. Invalid runtime
arguments return a safe error before the domain method runs.

See `example/` for generation, authorization, invalid-input, and live-instance
replacement tests.
