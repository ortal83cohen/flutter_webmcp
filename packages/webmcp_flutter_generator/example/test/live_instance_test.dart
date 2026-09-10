import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';

import '../lib/inventory_service.dart';
import '../lib/inventory_service.webmcp.g.dart';

void main() {
  setUp(WebMcp.instance.reset);
  tearDown(WebMcp.instance.reset);

  test(
    'generated source preserves authorization and uses the live instance',
    () async {
      final InventoryService service = InventoryService(authorized: false);
      final WebMcpScope scope = WebMcpScope(scopeName: 'inventory');
      scope.addSource(InventoryServiceWebMcpSource(service));

      await expectLater(
        WebMcp.instance.invokeTool('inventory.update', <String, Object?>{
          'sku': 'synthetic-sku',
          'amount': 3,
        }),
        throwsA(isA<StateError>()),
      );
      expect(service.calls, 0);

      service.authorized = true;
      expect(
        await WebMcp.instance.invokeTool('inventory.update', <String, Object?>{
          'sku': 'synthetic-sku',
          'amount': 3,
          'mode': 'commit',
          'checks': <Object?>[
            <String, Object?>{'stock': true},
          ],
        }),
        3,
      );
      expect(await WebMcp.instance.invokeTool('inventory.read', const {}), 3);
      expect(service.calls, 1);
    },
  );

  test('invalid arguments fail safely before invoking the instance', () async {
    final InventoryService service = InventoryService(authorized: true);
    final WebMcpScope scope = WebMcpScope(scopeName: 'inventory');
    scope.addSource(InventoryServiceWebMcpSource(service));

    final Object? result = await WebMcp.instance.invokeTool(
      'inventory.update',
      <String, Object?>{'sku': 'synthetic-sku', 'amount': 9007199254740992},
    );

    expect((result! as Map<String, Object?>)['error'], <String, Object?>{
      'code': 'invalidArguments',
      'retryable': false,
    });
    expect(service.calls, 0);
  });

  test(
    'scope replacement transfers lifecycle ownership to another instance',
    () async {
      final InventoryService first = InventoryService(authorized: true);
      final InventoryService second = InventoryService(authorized: true);
      final WebMcpScope firstScope = WebMcpScope(scopeName: 'first');
      firstScope.addSource(InventoryServiceWebMcpSource(first));
      firstScope.close();

      final WebMcpScope secondScope = WebMcpScope(scopeName: 'second');
      secondScope.addSource(InventoryServiceWebMcpSource(second));
      await WebMcp.instance.invokeTool('inventory.update', <String, Object?>{
        'sku': 'synthetic-sku',
        'amount': 4,
      });

      expect(first.quantity, 0);
      expect(second.quantity, 4);
    },
  );
}
