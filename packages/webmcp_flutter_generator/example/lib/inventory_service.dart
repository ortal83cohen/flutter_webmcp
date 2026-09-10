import 'package:webmcp_flutter_annotations/webmcp_flutter_annotations.dart';

/// Supported fulfillment modes.
enum FulfillmentMode {
  /// Validate without committing.
  preview,

  /// Commit the requested operation.
  commit,
}

/// Consumer-owned service used by the generated adapter fixture.
final class InventoryService {
  /// Creates a live service with application-owned authorization.
  InventoryService({required this.authorized});

  /// Current application authorization decision.
  bool authorized;

  /// Number of successful calls received by this instance.
  int calls = 0;

  /// Last committed quantity.
  int quantity = 0;

  /// Applies an authorized quantity update.
  @WebMcpDomainAction(
    name: 'inventory.update',
    description: 'Updates inventory when application policy allows it.',
    consequentialHint: true,
  )
  Future<int> update(
    String sku, {
    required int amount,
    FulfillmentMode mode = FulfillmentMode.commit,
    List<Map<String, bool>> checks = const <Map<String, bool>>[],
  }) async {
    if (!authorized) {
      throw StateError('Application authorization denied the operation.');
    }
    calls++;
    if (mode == FulfillmentMode.commit &&
        checks.every((Map<String, bool> item) => !item.containsValue(false))) {
      quantity += amount;
    }
    return quantity;
  }

  /// Reads the current live quantity.
  @WebMcpDomainAction(
    name: 'inventory.read',
    description: 'Reads the current live inventory quantity.',
    readOnlyHint: true,
  )
  int read() => quantity;

  /// Remains private to the application because it is not annotated.
  void reset() {
    quantity = 0;
  }
}
