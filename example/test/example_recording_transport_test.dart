import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';
import 'package:webmcp_flutter_example/example_recording_transport.dart';

void main() {
  tearDown(WebMcp.instance.reset);

  test('installing the transport reports the fixed identifier and tracks '
      'registrations and unregistrations', () async {
    final ExampleRecordingTransport transport = ExampleRecordingTransport();
    WebMcp.instance.reset(transport);

    expect(WebMcp.instance.transportId, 'example-recording');
    expect(transport.registrationCount, 0);
    expect(transport.unregistrationCount, 0);
    expect(transport.lastRegisteredName, isNull);

    WebMcp.instance.registerTool(
      WebMcpTool(
        name: 'example.recording.probe',
        description: 'A probe tool used to exercise the recording transport.',
        handler: (Map<String, Object?> arguments) async => null,
      ),
    );

    expect(transport.registrationCount, 1);
    expect(transport.unregistrationCount, 0);
    expect(transport.lastRegisteredName, 'example.recording.probe');

    final bool unregistered = WebMcp.instance.unregisterTool(
      'example.recording.probe',
    );

    expect(unregistered, isTrue);
    expect(transport.registrationCount, 1);
    expect(transport.unregistrationCount, 1);
    expect(transport.lastRegisteredName, 'example.recording.probe');
  });

  test(
    'a plain reset with no transport argument restores the default identifier',
    () {
      WebMcp.instance.reset(ExampleRecordingTransport());
      expect(WebMcp.instance.transportId, 'example-recording');

      WebMcp.instance.reset();

      expect(WebMcp.instance.transportId, 'noop');
      expect(WebMcp.instance.transportId, isNot('example-recording'));
    },
  );
}
