@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart';
import 'package:webmcp_flutter/src/transport/native_publisher_boundary.dart';
import 'package:webmcp_flutter/src/transport/native_publisher_boundary_web.dart';
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

  test('native boundary registers Chrome shape with lifetime signal', () async {
    JSObject? capturedDefinition;
    JSObject? capturedOptions;
    final JSFunction registerTool = ((JSObject definition, JSObject options) {
      capturedDefinition = definition;
      capturedOptions = options;
      return Future<JSAny?>.value(null).toJS;
    }).toJS;
    final JSObject marker = <String, JSAny?>{}.jsify()! as JSObject;
    marker.setProperty('registerTool'.toJS, registerTool);
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
    final BrowserWebMcpNativeBoundary boundary = BrowserWebMcpNativeBoundary();

    final WebMcpNativeRegistration registration = await boundary.registerTool(
      WebMcpTool(
        name: 'native.fixture',
        description: 'Native fixture',
        inputSchema: const <String, Object?>{'type': 'object'},
        annotations: const WebMcpToolAnnotations(
          readOnlyHint: true,
          untrustedContentHint: true,
          consequentialHint: true,
        ),
        handler: (Map<String, Object?> arguments) => null,
      ),
      (Object? input, WebMcpNativeInvocationContext context) async => '{}',
    );

    final JSObject definition = capturedDefinition!;
    expect(
      definition.getProperty<JSString>('name'.toJS).toDart,
      'native.fixture',
    );
    expect(
      definition.getProperty<JSString>('description'.toJS).toDart,
      'Native fixture',
    );
    expect(definition.getProperty<JSAny?>('inputSchema'.toJS), isNotNull);
    final JSObject annotations = definition.getProperty<JSObject>(
      'annotations'.toJS,
    );
    expect(
      annotations.getProperty<JSBoolean>('readOnlyHint'.toJS).toDart,
      isTrue,
    );
    expect(
      annotations.getProperty<JSBoolean>('untrustedContentHint'.toJS).toDart,
      isTrue,
    );
    expect(
      annotations.getProperty<JSBoolean>('consequentialHint'.toJS).toDart,
      isTrue,
    );
    final JSFunction execute = definition.getProperty<JSFunction>(
      'execute'.toJS,
    );
    final JSPromise<JSAny?> invocation =
        execute.callAsFunction(null, <String, JSAny?>{'value': 1.toJS}.jsify())!
            as JSPromise<JSAny?>;
    expect(((await invocation.toDart)! as JSString).toDart, '{}');

    final AbortSignal signal = capturedOptions!.getProperty<AbortSignal>(
      'signal'.toJS,
    );
    expect(signal.aborted, isFalse);
    registration.abort();
    expect(signal.aborted, isTrue);
  });
}
