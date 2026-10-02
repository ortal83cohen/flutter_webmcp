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

    // The invoker must return the envelope instead of throwing; a thrown
    // error here fails the test.
    final Object? result = await WebMcp.instance.invokeTool(
      'inventory.update',
      <String, Object?>{'sku': 'synthetic-sku', 'amount': 9007199254740992},
    );

    final Map<String, Object?> envelope = result! as Map<String, Object?>;
    expect(envelope['ok'], isFalse);
    final Map<String, Object?> error =
        envelope['error']! as Map<String, Object?>;
    expect(error['code'], 'invalidArguments');
    expect(error['retryable'], isFalse);
    // The generated path deliberately carries no details entry.
    expect(error.containsKey('details'), isFalse);
    expect(error, <String, Object?>{
      'code': 'invalidArguments',
      'retryable': false,
    });
    expect(service.calls, 0);
  });

  test('generated metadata reaches the registered descriptor', () {
    final InventoryService service = InventoryService(authorized: true);
    final WebMcpScope scope = WebMcpScope(scopeName: 'inventory');
    scope.addSource(InventoryServiceWebMcpSource(service));

    final WebMcpTool read = WebMcp.instance.tools.firstWhere(
      (WebMcpTool tool) => tool.name == 'inventory.read',
    );
    expect(read.title, 'Read inventory');
    expect(read.exposedTo, <String>['https://agent.example']);
    expect(read.annotations.debugging, isTrue);
    expect(read.annotations.readOnlyHint, isTrue);

    // A method that sets none of the three keeps the omission signal.
    final WebMcpTool update = WebMcp.instance.tools.firstWhere(
      (WebMcpTool tool) => tool.name == 'inventory.update',
    );
    expect(update.title, isNull);
    expect(update.exposedTo, isNull);
    expect(update.annotations.debugging, isNull);
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
