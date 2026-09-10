import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart';

import '../webmcp_tool.dart';
import 'native_publisher_boundary.dart';

/// Creates the browser native-publication boundary.
WebMcpNativeBoundary createPlatformWebMcpNativeBoundary() =>
    const BrowserWebMcpNativeBoundary();

extension type _ModelContext(JSObject _) implements JSObject {
  external JSPromise<JSAny?> registerTool(
    JSObject definition,
    JSObject options,
  );
}

/// Publishes tools to Chrome's same-origin `document.modelContext` surface.
final class BrowserWebMcpNativeBoundary implements WebMcpNativeBoundary {
  /// Creates a browser boundary.
  const BrowserWebMcpNativeBoundary();

  JSObject? get _modelContext {
    if (!document.hasProperty('modelContext'.toJS).toDart) {
      return null;
    }
    return document.getProperty<JSObject?>('modelContext'.toJS);
  }

  @override
  bool get isDetected => _modelContext != null;

  @override
  Future<WebMcpNativeRegistration> registerTool(
    WebMcpTool tool,
    WebMcpNativeInvocationHandler invoke,
  ) async {
    final JSObject? rawModelContext = _modelContext;
    final JSAny? registerTool = rawModelContext?.getProperty<JSAny?>(
      'registerTool'.toJS,
    );
    if (rawModelContext == null ||
        registerTool == null ||
        !registerTool.isA<JSFunction>()) {
      throw const WebMcpNativeBoundaryException(
        WebMcpNativeReasonCode.browserUnavailable,
      );
    }

    final AbortController controller = AbortController();
    final JSFunction execute = ((JSAny? input, JSAny? executionContext) {
      return _executeSafely(input, invoke).toJS;
    }).toJS;
    final JSObject definition =
        <String, JSAny?>{
              'name': tool.name.toJS,
              'description': tool.description.toJS,
              'inputSchema': tool.inputSchema.jsify(),
              'annotations': <String, JSAny?>{
                'readOnlyHint': tool.annotations.readOnlyHint.toJS,
                'untrustedContentHint':
                    tool.annotations.untrustedContentHint.toJS,
                'consequentialHint': tool.annotations.consequentialHint.toJS,
              }.jsify(),
              'execute': execute,
            }.jsify()!
            as JSObject;
    final JSObject options =
        <String, JSAny?>{'signal': controller.signal}.jsify()! as JSObject;

    try {
      await _ModelContext(rawModelContext)
          .registerTool(definition, options)
          .toDart;
    } on Object {
      controller.abort();
      throw const WebMcpNativeBoundaryException(
        WebMcpNativeReasonCode.registrationFailed,
      );
    }
    return _BrowserWebMcpNativeRegistration(controller);
  }

  Future<JSAny?> _executeSafely(
    JSAny? input,
    WebMcpNativeInvocationHandler invoke,
  ) async {
    try {
      final Object? dartInput = input?.dartify();
      final String value = await invoke(
        dartInput,
        const WebMcpNativeInvocationContext(cancelledBeforeDispatch: false),
      );
      return value.toJS;
    } on Object {
      return jsonEncode(<String, Object?>{
        'ok': false,
        'error': <String, Object?>{
          'code': WebMcpNativeReasonCode.invalidInput.name,
          'retryable': false,
        },
      }).toJS;
    }
  }
}

final class _BrowserWebMcpNativeRegistration
    implements WebMcpNativeRegistration {
  _BrowserWebMcpNativeRegistration(this._controller);

  AbortController? _controller;

  @override
  void abort() {
    _controller?.abort();
    _controller = null;
  }
}
