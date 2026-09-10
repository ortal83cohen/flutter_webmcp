import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';

final class _RecordingTransport implements WebMcpTransport {
  _RecordingTransport(this.id);

  @override
  final String id;

  final List<String> events = <String>[];

  @override
  void onToolRegistered(WebMcpTool tool) {
    events.add('registered:${tool.name}');
  }

  @override
  void onToolUnregistered(String name) {
    events.add('unregistered:$name');
  }
}

final class _ThrowingTransport implements WebMcpTransport {
  _ThrowingTransport({
    this.throwOnRegistration = false,
    this.throwOnUnregistration = false,
  });

  final bool throwOnRegistration;
  final bool throwOnUnregistration;

  @override
  String get id => 'throwing';

  @override
  void onToolRegistered(WebMcpTool tool) {
    if (throwOnRegistration) {
      throw StateError('registration notification failed');
    }
  }

  @override
  void onToolUnregistered(String name) {
    if (throwOnUnregistration) {
      throw StateError('unregistration notification failed');
    }
  }
}

WebMcpTool _tool(String name) => WebMcpTool(
  name: name,
  description: 'Tool $name',
  handler: (Map<String, Object?> arguments) => null,
);

void main() {
  tearDown(WebMcp.instance.reset);

  test('selects noop on the Dart VM and resets transport', () {
    final _RecordingTransport fake = _RecordingTransport('fake');
    WebMcp.instance.reset(fake);
    expect(WebMcp.instance.transportId, 'fake');

    WebMcp.instance.reset();
    expect(WebMcp.instance.transportId, 'noop');
    expect(WebMcp.instance.tools, isEmpty);
  });

  test('notifies registration and unregistration in order', () {
    final _RecordingTransport fake = _RecordingTransport('recording');
    WebMcp.instance.reset(fake);
    WebMcp.instance.registerTool(
      WebMcpTool(
        name: 'observed',
        description: 'Observed tool',
        handler: (Map<String, Object?> arguments) => null,
      ),
    );
    WebMcp.instance.unregisterTool('observed');

    expect(fake.events, <String>[
      'registered:observed',
      'unregistered:observed',
    ]);
  });

  test('registration notification failure propagates after mutation', () {
    WebMcp.instance.reset(_ThrowingTransport(throwOnRegistration: true));

    expect(
      () => WebMcp.instance.registerTool(_tool('retained')),
      throwsA(isA<StateError>()),
    );
    expect(WebMcp.instance.tools.single.name, 'retained');
  });

  test('unregistration notification failure propagates after mutation', () {
    WebMcp.instance.reset(_ThrowingTransport(throwOnUnregistration: true));
    WebMcp.instance.registerTool(_tool('removed'));

    expect(
      () => WebMcp.instance.unregisterTool('removed'),
      throwsA(isA<StateError>()),
    );
    expect(WebMcp.instance.tools, isEmpty);
  });

  test('reset clears tools and replaces transport without notifications', () {
    final _RecordingTransport previous = _RecordingTransport('previous');
    final _RecordingTransport replacement = _RecordingTransport('replacement');
    WebMcp.instance.reset(previous);
    WebMcp.instance.registerTool(_tool('existing'));

    WebMcp.instance.reset(replacement);

    expect(WebMcp.instance.tools, isEmpty);
    expect(WebMcp.instance.transportId, 'replacement');
    expect(previous.events, <String>['registered:existing']);
    expect(replacement.events, isEmpty);
  });
}
