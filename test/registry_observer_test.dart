import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';

WebMcpTool _tool(String name) => WebMcpTool(
  name: name,
  description: 'Tool $name',
  handler: (Map<String, Object?> arguments) => null,
);

final class _RecordingTransport implements WebMcpTransport {
  _RecordingTransport(this.events);

  final List<String> events;

  @override
  String get id => 'recording';

  @override
  void onToolRegistered(WebMcpTool tool) {
    events.add('transport:registered:${tool.name}');
  }

  @override
  void onToolUnregistered(String name) {
    events.add('transport:unregistered:$name');
  }
}

final class _RecordingObserver implements WebMcpRegistryObserver {
  _RecordingObserver(
    this.label,
    this.events, {
    this.throwOnNotification = false,
  });

  final String label;
  final List<String> events;
  final bool throwOnNotification;

  @override
  void onToolRegistered(WebMcpTool tool) {
    events.add('$label:registered:${tool.name}');
    if (throwOnNotification) {
      throw StateError('observer failure');
    }
  }

  @override
  void onToolUnregistered(String name) {
    events.add('$label:unregistered:$name');
    if (throwOnNotification) {
      throw StateError('observer failure');
    }
  }
}

void main() {
  tearDown(WebMcp.instance.reset);

  test('notifies after successful mutation in subscription order', () {
    final List<String> events = <String>[];
    WebMcp.instance.reset(_RecordingTransport(events));
    WebMcp.instance
      ..addRegistryObserver(_RecordingObserver('first', events))
      ..addRegistryObserver(_RecordingObserver('second', events))
      ..registerTool(_tool('ordered'))
      ..unregisterTool('ordered');

    expect(events, <String>[
      'transport:registered:ordered',
      'first:registered:ordered',
      'second:registered:ordered',
      'transport:unregistered:ordered',
      'first:unregistered:ordered',
      'second:unregistered:ordered',
    ]);
  });

  test('does not notify for rejected or absent mutations', () {
    final List<String> events = <String>[];
    WebMcp.instance.addRegistryObserver(_RecordingObserver('observer', events));
    WebMcp.instance.registerTool(_tool('first'));
    events.clear();

    expect(
      () => WebMcp.instance.registerTool(_tool('first')),
      throwsA(isA<WebMcpDuplicateToolException>()),
    );
    expect(
      () => WebMcp.instance.registerTool(_tool('has space')),
      throwsA(isA<WebMcpInvalidToolNameException>()),
    );
    expect(WebMcp.instance.unregisterTool('absent'), isFalse);
    expect(events, isEmpty);
  });

  test('guards throwing observers and continues notification', () {
    final List<String> events = <String>[];
    WebMcp.instance
      ..addRegistryObserver(
        _RecordingObserver('throwing', events, throwOnNotification: true),
      )
      ..addRegistryObserver(_RecordingObserver('later', events));

    expect(() => WebMcp.instance.registerTool(_tool('safe')), returnsNormally);
    expect(() => WebMcp.instance.unregisterTool('safe'), returnsNormally);
    expect(events, <String>[
      'throwing:registered:safe',
      'later:registered:safe',
      'throwing:unregistered:safe',
      'later:unregistered:safe',
    ]);
  });

  test('cancel is idempotent and reset cancels subscriptions', () {
    final List<String> events = <String>[];
    final WebMcpRegistrySubscription cancelled = WebMcp.instance
        .addRegistryObserver(_RecordingObserver('cancelled', events));
    cancelled.cancel();
    cancelled.cancel();
    expect(cancelled.isActive, isFalse);

    final WebMcpRegistrySubscription reset = WebMcp.instance
        .addRegistryObserver(_RecordingObserver('reset', events));
    expect(reset.isActive, isTrue);
    WebMcp.instance.reset();
    expect(reset.isActive, isFalse);

    WebMcp.instance.registerTool(_tool('later'));
    expect(events, isEmpty);
  });
}
