@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart';
import 'package:webmcp_flutter/src/transport/transport_web.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';

const String _propertyName = 'modelContext';

@JS('Object.getOwnPropertyDescriptor')
external JSObject? _getOwnPropertyDescriptor(JSObject object, String property);

@JS('Object.defineProperty')
external void _defineProperty(
  JSObject object,
  String property,
  JSObject descriptor,
);

void main() {
  late JSObject? originalDescriptor;

  setUp(() {
    originalDescriptor = _getOwnPropertyDescriptor(document, _propertyName);
    expect(
      document.delete(_propertyName.toJS).toDart,
      isTrue,
      reason: 'The browser fixture must allow modelContext to be controlled.',
    );
    expect(
      document.hasProperty(_propertyName.toJS).toDart,
      isFalse,
      reason: 'Run Chrome with the experimental WebMCP feature disabled.',
    );
  });

  tearDown(() {
    final JSObject? descriptor = originalDescriptor;
    if (descriptor == null) {
      expect(document.delete(_propertyName.toJS).toDart, isTrue);
    } else {
      _defineProperty(document, _propertyName, descriptor);
    }
  });

  test('reports modelContext absent when the marker is missing', () {
    final List<String> logs = <String>[];
    final WebDetectionTransport transport = WebDetectionTransport(
      logger: logs.add,
    );

    expect(transport.id, 'web-detection');
    expect(transport.isAvailable, isFalse);
    expect(document.hasProperty(_propertyName.toJS).toDart, isFalse);
    expect(logs, <String>['modelContext detected: false; tools not published']);
  });

  test('reports modelContext present without publishing registry changes', () {
    final JSObject marker = <String, JSAny?>{}.jsify()! as JSObject;
    _defineProperty(
      document,
      _propertyName,
      <String, JSAny?>{
            'value': marker,
            'configurable': true.toJS,
            'writable': true.toJS,
          }.jsify()!
          as JSObject,
    );

    final List<String> logs = <String>[];
    final WebDetectionTransport transport = WebDetectionTransport(
      logger: logs.add,
    );
    expect(transport.isAvailable, isTrue);

    transport.onToolRegistered(
      WebMcpTool(
        name: 'browser_fixture',
        description: 'Controlled browser fixture',
        handler: (Map<String, Object?> arguments) => null,
      ),
    );
    transport.onToolUnregistered('browser_fixture');

    expect(document.getProperty<JSObject>(_propertyName.toJS), same(marker));
    expect(marker.hasProperty('browser_fixture'.toJS).toDart, isFalse);
    expect(logs, <String>[
      'modelContext detected: true; tools not published',
      'registered browser_fixture; tools not published',
      'unregistered browser_fixture; tools not published',
    ]);
  });
}
