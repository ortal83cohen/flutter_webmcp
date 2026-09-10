import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_pilot/webmcp_pilot.dart';

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
}
