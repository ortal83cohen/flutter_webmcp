import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart';

import '../webmcp_tool.dart';
import 'native_publisher_boundary.dart';

/// Creates the browser native-publication boundary.
WebMcpNativeBoundary createPlatformWebMcpNativeBoundary() =>
    const BrowserWebMcpNativeBoundary();

extension type _ModelContext(JSObject _) implements JSObject, EventTarget {
  external JSPromise<JSAny?> registerTool(
    JSObject definition,
    JSObject options,
  );
}

final class _BrowserActivityBinding {
  void Function(WebMcpNativeToolActivity activity)? listener;
  EventTarget? target;
  JSFunction? activated;
  JSFunction? cancelled;
}

final _BrowserActivityBinding _activity = _BrowserActivityBinding();

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
    final JSFunction execute = ((JSAny? input, JSAny? options) {
      return _executeSafely(input, options, invoke).toJS;
    }).toJS;
    final JSObject definition =
        webMcpNativeRegistrationObject(tool).jsify()! as JSObject;
    definition.setProperty('execute'.toJS, execute);
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

  @override
  bool subscribeToolActivity(
    void Function(WebMcpNativeToolActivity activity) listener,
  ) {
    unsubscribeToolActivity();
    final JSObject? context = _modelContext;
    if (context == null || !context.isA<EventTarget>()) {
      return false;
    }
    final EventTarget target = context as EventTarget;
    _activity
      ..listener = listener
      ..target = target
      ..activated = ((Event event) {
        _reportActivity(event, WebMcpNativeToolActivityKind.started);
      }).toJS
      ..cancelled = ((Event event) {
        _reportActivity(event, WebMcpNativeToolActivityKind.cancelled);
      }).toJS;
    target.addEventListener('toolactivated', _activity.activated!);
    target.addEventListener('toolcancel', _activity.cancelled!);
    return true;
  }

  @override
  void unsubscribeToolActivity() {
    final EventTarget? target = _activity.target;
    final JSFunction? activated = _activity.activated;
    final JSFunction? cancelled = _activity.cancelled;
    if (target != null && activated != null) {
      target.removeEventListener('toolactivated', activated);
    }
    if (target != null && cancelled != null) {
      target.removeEventListener('toolcancel', cancelled);
    }
    _activity
      ..listener = null
      ..target = null
      ..activated = null
      ..cancelled = null;
  }

  Future<JSAny?> _executeSafely(
    JSAny? input,
    JSAny? options,
    WebMcpNativeInvocationHandler invoke,
  ) async {
    try {
      final Object? dartInput = input?.dartify();
      final String value = await invoke(
        dartInput,
        WebMcpNativeInvocationContext(
          cancelledBeforeDispatch: false,
          executionSignal: _adaptSignal(options),
        ),
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

  WebMcpExecutionSignal? _adaptSignal(JSAny? options) {
    if (options == null || !options.isA<JSObject>()) {
      return null;
    }
    final JSObject object = options as JSObject;
    if (!object.hasProperty('signal'.toJS).toDart) {
      return null;
    }
    final JSAny? signal = object.getProperty<JSAny?>('signal'.toJS);
    if (signal == null || !signal.isA<AbortSignal>()) {
      return null;
    }
    return _BrowserExecutionSignal(signal as AbortSignal);
  }
}

void _reportActivity(Event event, WebMcpNativeToolActivityKind kind) {
  final void Function(WebMcpNativeToolActivity activity)? listener =
      _activity.listener;
  if (listener == null) {
    return;
  }
  final JSObject raw = event as JSObject;
  if (!raw.hasProperty('toolName'.toJS).toDart) {
    return;
  }
  final JSAny? name = raw.getProperty<JSAny?>('toolName'.toJS);
  if (name == null || !name.isA<JSString>()) {
    return;
  }
  listener(
    WebMcpNativeToolActivity(kind: kind, toolName: (name as JSString).toDart),
  );
}

final class _BrowserExecutionSignal implements WebMcpExecutionSignal {
  _BrowserExecutionSignal(this._signal);

  final AbortSignal _signal;
  final Map<void Function(), EventListener> _listeners =
      <void Function(), EventListener>{};

  @override
  bool get aborted => _signal.aborted;

  @override
  void addAbortListener(void Function() listener) {
    final EventListener wrapped = ((Event event) {
      listener();
    }).toJS;
    _listeners[listener] = wrapped;
    _signal.addEventListener('abort', wrapped);
  }

  @override
  void removeAbortListener(void Function() listener) {
    final EventListener? wrapped = _listeners.remove(listener);
    if (wrapped == null) {
      return;
    }
    _signal.removeEventListener('abort', wrapped);
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
