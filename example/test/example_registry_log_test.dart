import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';
import 'package:webmcp_flutter_example/example_registry_log.dart';

WebMcpTool _tool(String name) => WebMcpTool(
  name: name,
  description: 'A probe tool used to exercise the registry log.',
  handler: (Map<String, Object?> arguments) async => null,
);

void main() {
  tearDown(WebMcp.instance.reset);

  test('registering and unregistering a tool appends matching lines and '
      'notifies listeners', () {
    final ExampleRegistryLog log = ExampleRegistryLog();
    final WebMcpRegistrySubscription subscription = WebMcp.instance
        .addRegistryObserver(log);
    var notifyCount = 0;
    log.addListener(() => notifyCount++);

    WebMcp.instance.registerTool(_tool('example.log.probe'));
    expect(log.lines, <String>['registered example.log.probe']);
    expect(notifyCount, 1);

    WebMcp.instance.unregisterTool('example.log.probe');
    expect(log.lines, <String>[
      'registered example.log.probe',
      'unregistered example.log.probe',
    ]);
    expect(notifyCount, 2);

    subscription.cancel();
  });

  test(
    'sixty-four events retain the first line; the sixty-fifth evicts it',
    () {
      final ExampleRegistryLog log = ExampleRegistryLog();
      final WebMcpRegistrySubscription subscription = WebMcp.instance
          .addRegistryObserver(log);

      for (var i = 0; i < 64; i++) {
        WebMcp.instance.registerTool(_tool('example.log.tool$i'));
      }

      expect(log.lines.length, 64);
      expect(log.lines.first, 'registered example.log.tool0');
      expect(log.lines.last, 'registered example.log.tool63');

      WebMcp.instance.registerTool(_tool('example.log.tool64'));

      expect(log.lines.length, 64);
      expect(log.lines, isNot(contains('registered example.log.tool0')));
      expect(log.lines.last, 'registered example.log.tool64');

      subscription.cancel();
    },
  );

  test('a registry reset invokes the reset hook once, increments the reset '
      'counter, appends a reset line and deactivates the subscription', () {
    final ExampleRegistryLog log = ExampleRegistryLog();
    final WebMcpRegistrySubscription subscription = WebMcp.instance
        .addRegistryObserver(log);

    expect(log.resetCount, 0);
    expect(subscription.isActive, isTrue);

    WebMcp.instance.reset();

    expect(log.resetCount, 1);
    expect(subscription.isActive, isFalse);
    expect(log.lines.last, 'reset (count 1)');
  });

  test('a cancelled subscription receives no reset and a later registration '
      'produces no new line', () {
    final ExampleRegistryLog log = ExampleRegistryLog();
    final WebMcpRegistrySubscription subscription = WebMcp.instance
        .addRegistryObserver(log);

    subscription.cancel();
    expect(subscription.isActive, isFalse);

    WebMcp.instance.reset();
    expect(log.resetCount, 0);

    WebMcp.instance.registerTool(_tool('example.log.after-cancel'));
    expect(log.lines, isEmpty);
  });
}
