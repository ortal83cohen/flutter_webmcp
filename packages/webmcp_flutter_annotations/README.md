# webmcp_flutter_annotations

Compile-time annotations for the optional `webmcp_flutter_generator`.

Annotate only public instance methods that the application intends to expose:

```dart
@WebMcpDomainAction(
  name: 'inventory.update',
  description: 'Updates authorized inventory.',
  consequentialHint: true,
)
Future<int> update(String sku, {required int amount}) async => amount;
```

The annotation is metadata only. It does not register tools, construct a
service, or grant authorization.
