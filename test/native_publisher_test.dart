import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';

WebMcpTool _tool(
  String name, {
  String? description,
  Object? Function(Map<String, Object?> arguments)? handler,
}) => WebMcpTool(
  name: name,
  description: description ?? 'Tool $name',
  inputSchema: const <String, Object?>{
    'type': 'object',
    'additionalProperties': true,
  },
  handler: handler ?? (Map<String, Object?> arguments) => arguments,
);

final class _FakeRegistration implements WebMcpNativeRegistration {
  _FakeRegistration(this._boundary, this.name);

  final _FakeBoundary _boundary;
  final String name;
  var aborted = false;

  @override
  void abort() {
    if (aborted) {
      return;
    }
    aborted = true;
    if (identical(_boundary.registrations[name], this)) {
      _boundary.registrations.remove(name);
      _boundary.handlers.remove(name);
    }
  }
}

final class _FakeBoundary implements WebMcpNativeBoundary {
  _FakeBoundary({this.isDetected = true});

  @override
  final bool isDetected;

  final Map<String, _FakeRegistration> registrations =
      <String, _FakeRegistration>{};
  final Map<String, WebMcpNativeInvocationHandler> handlers =
      <String, WebMcpNativeInvocationHandler>{};
  final Map<String, WebMcpNativeReasonCode> failures =
      <String, WebMcpNativeReasonCode>{};
  final List<String> registrationAttempts = <String>[];
  final List<Map<String, Object?>> registrationObjects =
      <Map<String, Object?>>[];
  void Function(WebMcpNativeToolActivity activity)? activityListener;

  @override
  bool subscribeToolActivity(
    void Function(WebMcpNativeToolActivity activity) listener,
  ) {
    activityListener = listener;
    return true;
  }

  @override
  void unsubscribeToolActivity() {
    activityListener = null;
  }

  void emitActivity(WebMcpNativeToolActivity activity) {
    activityListener?.call(activity);
  }

  @override
  Future<WebMcpNativeRegistration> registerTool(
    WebMcpTool tool,
    WebMcpNativeInvocationHandler invoke,
  ) async {
    registrationAttempts.add(tool.name);
    registrationObjects.add(webMcpNativeRegistrationObject(tool));
    final WebMcpNativeReasonCode? failure = failures[tool.name];
    if (failure != null) {
      throw WebMcpNativeBoundaryException(failure);
    }
    if (registrations.containsKey(tool.name)) {
      throw const WebMcpNativeBoundaryException(
        WebMcpNativeReasonCode.duplicateNativeTool,
      );
    }
    final _FakeRegistration registration = _FakeRegistration(this, tool.name);
    registrations[tool.name] = registration;
    handlers[tool.name] = invoke;
    return registration;
  }

  Future<String> invoke(
    String name,
    Object? input, {
    bool cancelledBeforeDispatch = false,
    WebMcpExecutionSignal? executionSignal,
  }) => handlers[name]!(
    input,
    WebMcpNativeInvocationContext(
      cancelledBeforeDispatch: cancelledBeforeDispatch,
      executionSignal: executionSignal,
    ),
  );
}

final class _FakeSignal implements WebMcpExecutionSignal {
  @override
  bool aborted = false;

  final List<void Function()> _listeners = <void Function()>[];

  void abort() {
    aborted = true;
    for (final void Function() listener in _listeners.toList(growable: false)) {
      listener();
    }
  }

  @override
  void addAbortListener(void Function() listener) {
    _listeners.add(listener);
  }

  @override
  void removeAbortListener(void Function() listener) {
    _listeners.remove(listener);
  }
}

Map<String, Object?> _decode(String value) =>
    (jsonDecode(value) as Map<Object?, Object?>).cast<String, Object?>();

void main() {
  late _FakeBoundary boundary;
  late DateTime now;

  setUp(() {
    WebMcp.logHook = null;
    WebMcp.instance.reset();
    boundary = _FakeBoundary();
    now = DateTime.utc(2026, 9, 10);
    webMcpNativeBoundaryFactory = () => boundary;
    webMcpNativeClock = () => now;
  });

  tearDown(() {
    WebMcp.logHook = null;
    WebMcp.instance.reset();
    webMcpNativeBoundaryFactory = createWebMcpNativeBoundary;
    webMcpNativeClock = DateTime.now;
  });

  test(
    'absent browser remains local-only without registration attempts',
    () async {
      boundary = _FakeBoundary(isDetected: false);
      webMcpNativeBoundaryFactory = () => boundary;
      WebMcp.instance.registerTool(_tool('local.only'));

      final WebMcpNativePublisherStatus status = await WebMcpNativePublisher()
          .attach();

      expect(status.support, WebMcpNativeSupport.localOnly);
      expect(
        status.reasonCodes,
        contains(WebMcpNativeReasonCode.browserUnavailable.name),
      );
      expect(boundary.registrationAttempts, isEmpty);
      expect(WebMcp.instance.tools.single.name, 'local.only');
    },
  );

  test(
    'attach mirrors snapshot and later mutations without duplication',
    () async {
      WebMcp.instance.registerTool(_tool('snapshot'));
      final WebMcpNativePublisher publisher = WebMcpNativePublisher();

      final WebMcpNativePublisherStatus first = await publisher.attach();
      expect(first.support, WebMcpNativeSupport.conformanceUsable);
      expect(boundary.registrations.keys, <String>{'snapshot'});

      final WebMcpNativePublisherStatus second = await publisher.attach();
      expect(second.publishedToolCount, 1);
      expect(boundary.registrationAttempts, <String>['snapshot']);

      WebMcp.instance.registerTool(_tool('later'));
      await Future<void>.delayed(Duration.zero);
      expect(boundary.registrations.keys, <String>{'snapshot', 'later'});

      WebMcp.instance.unregisterTool('snapshot');
      await Future<void>.delayed(Duration.zero);
      expect(boundary.registrations.keys, <String>{'later'});
    },
  );

  test('detach is idempotent and reset is a cleanup safety net', () async {
    WebMcp.instance.registerTool(_tool('owned'));
    final WebMcpNativePublisher publisher = WebMcpNativePublisher();
    await publisher.attach();

    await publisher.detach();
    await publisher.detach();
    expect(boundary.registrations, isEmpty);

    await publisher.attach();
    expect(boundary.registrations.keys, <String>{'owned'});
    WebMcp.instance.reset();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(boundary.registrations, isEmpty);
    expect(publisher.status.publishedToolCount, 0);
  });

  test('browser failure leaves the local tool registered and usable', () async {
    boundary.failures['local'] = WebMcpNativeReasonCode.registrationFailed;
    WebMcp.instance.registerTool(
      _tool('local', handler: (Map<String, Object?> arguments) => 'raw'),
    );
    final WebMcpNativePublisher publisher = WebMcpNativePublisher();

    final WebMcpNativePublisherStatus status = await publisher.attach();
    expect(status.support, WebMcpNativeSupport.failed);
    expect(status.publishedToolCount, 0);
    expect(status.skippedToolCount, 1);
    expect(await WebMcp.instance.invokeTool('local', const {}), 'raw');
  });

  test('skipped duplicate never unregisters the live browser owner', () async {
    WebMcp.instance.registerTool(
      _tool('winner', handler: (Map<String, Object?> arguments) => 'winner'),
    );
    final WebMcpNativePublisher first = WebMcpNativePublisher();
    final WebMcpNativePublisher second = WebMcpNativePublisher();
    await first.attach();
    final WebMcpNativePublisherStatus skipped = await second.attach();
    expect(
      skipped.reasonCodes,
      contains(WebMcpNativeReasonCode.duplicateNativeTool.name),
    );

    await second.detach();
    expect(boundary.registrations.keys, <String>{'winner'});
    expect(
      jsonDecode(await boundary.invoke('winner', <String, Object?>{})),
      'winner',
    );
  });

  test('registration limit rejects one over without evicting owners', () async {
    for (var index = 0; index <= webMcpNativeMaxRegistrations; index++) {
      WebMcp.instance.registerTool(_tool('tool.$index'));
    }
    final WebMcpNativePublisher publisher = WebMcpNativePublisher();

    final WebMcpNativePublisherStatus status = await publisher.attach();
    expect(status.publishedToolCount, webMcpNativeMaxRegistrations);
    expect(status.skippedToolCount, 1);
    expect(
      status.reasonCodes,
      contains(WebMcpNativeReasonCode.resourceLimit.name),
    );
    expect(boundary.registrations, hasLength(webMcpNativeMaxRegistrations));
  });

  test(
    'wire boundary round trips bounded JSON and rejects invalid input',
    () async {
      var calls = 0;
      WebMcp.instance.registerTool(
        _tool(
          'wire',
          handler: (Map<String, Object?> arguments) {
            calls++;
            return <String, Object?>{'received': arguments};
          },
        ),
      );
      await WebMcpNativePublisher().attach();

      final Map<String, Object?> valid = _decode(
        await boundary.invoke('wire', <String, Object?>{
          'nested': <Object?>[1, true, null, 'value'],
        }),
      );
      expect(valid['received'], isA<Map<Object?, Object?>>());
      expect(calls, 1);

      final Map<Object?, Object?> cyclic = <Object?, Object?>{};
      cyclic['self'] = cyclic;
      final List<Object?> deep = <Object?>[];
      List<Object?> cursor = deep;
      for (var index = 0; index <= webMcpNativeMaxJsonDepth; index++) {
        final List<Object?> next = <Object?>[];
        cursor.add(next);
        cursor = next;
      }
      final String oversized = 'x' * webMcpNativeMaxJsonBytes;
      final List<Object?> invalidInputs = <Object?>[
        cyclic,
        <Object?, Object?>{1: 'bad'},
        <String, Object?>{'number': double.nan},
        <String, Object?>{'deep': deep},
        <String, Object?>{'large': oversized},
        <Object?>[],
        Object(),
      ];
      for (final Object? input in invalidInputs) {
        final Map<String, Object?> failure = _decode(
          await boundary.invoke('wire', input),
        );
        expect(
          (failure['error'] as Map<Object?, Object?>)['code'],
          WebMcpNativeReasonCode.invalidInput.name,
        );
      }
      expect(calls, 1);
    },
  );

  test(
    'browser sanitizes handler errors while local invocation stays raw',
    () async {
      final StateError secretFailure = StateError('synthetic-secret');
      WebMcp.instance.registerTool(
        _tool(
          'failure',
          handler: (Map<String, Object?> arguments) => throw secretFailure,
        ),
      );
      await WebMcpNativePublisher().attach();

      final String browserResult = await boundary.invoke(
        'failure',
        <String, Object?>{'secret': 'synthetic-secret'},
      );
      expect(browserResult, isNot(contains('synthetic-secret')));
      expect(
        (_decode(browserResult)['error'] as Map<Object?, Object?>)['code'],
        WebMcpNativeReasonCode.handlerFailed.name,
      );
      await expectLater(
        WebMcp.instance.invokeTool('failure', const {}),
        throwsA(same(secretFailure)),
      );
    },
  );

  test(
    'rejects invalid output without retaining result or exception text',
    () async {
      WebMcp.instance.registerTool(
        _tool(
          'invalid.output',
          handler: (Map<String, Object?> arguments) => <String, Object?>{
            'value': double.infinity,
          },
        ),
      );
      await WebMcpNativePublisher().attach();

      final String result = await boundary.invoke(
        'invalid.output',
        <String, Object?>{},
      );
      expect(
        (_decode(result)['error'] as Map<Object?, Object?>)['code'],
        WebMcpNativeReasonCode.invalidOutput.name,
      );
      expect(result, isNot(contains('Infinity')));
    },
  );

  test('cancel before dispatch has no handler call and no replay', () async {
    var sideEffects = 0;
    WebMcp.instance.registerTool(
      _tool(
        'cancel',
        handler: (Map<String, Object?> arguments) => ++sideEffects,
      ),
    );
    final WebMcpNativePublisher publisher = WebMcpNativePublisher();
    await publisher.attach();

    final String result = await boundary.invoke(
      'cancel',
      <String, Object?>{},
      cancelledBeforeDispatch: true,
    );
    expect(
      (_decode(result)['error'] as Map<Object?, Object?>)['code'],
      WebMcpNativeReasonCode.cancelled.name,
    );
    expect(sideEffects, 0);
    await Future<void>.delayed(Duration.zero);
    expect(sideEffects, 0);
    expect(
      publisher.status.capabilities.invocationCancellationAfterCallbackStart,
      isFalse,
    );
  });

  test('operation exact limit and one over fail before side effects', () async {
    var sideEffects = 0;
    WebMcp.instance.registerTool(
      _tool(
        'completed',
        handler: (Map<String, Object?> arguments) => ++sideEffects,
      ),
    );
    final WebMcpNativePublisher publisher = WebMcpNativePublisher();
    await publisher.attach();

    for (var index = 0; index < webMcpNativeMaxOperations; index++) {
      await boundary.invoke('completed', <String, Object?>{});
    }
    final String busy = await boundary.invoke('completed', <String, Object?>{});
    expect(
      (_decode(busy)['error'] as Map<Object?, Object?>)['code'],
      WebMcpNativeReasonCode.busy.name,
    );
    expect(sideEffects, webMcpNativeMaxOperations);
    expect(publisher.status.retainedOperationCount, webMcpNativeMaxOperations);

    now = now.add(webMcpNativeOperationRetention);
    await boundary.invoke('completed', <String, Object?>{});
    expect(sideEffects, webMcpNativeMaxOperations + 1);
  });

  test('receipt expiry does not free outstanding execution slots', () async {
    final List<Completer<Object?>> executions = <Completer<Object?>>[];
    var sideEffects = 0;
    WebMcp.instance.registerTool(
      _tool(
        'pending',
        handler: (Map<String, Object?> arguments) {
          sideEffects++;
          final Completer<Object?> completer = Completer<Object?>();
          executions.add(completer);
          return completer.future;
        },
      ),
    );
    final WebMcpNativePublisher publisher = WebMcpNativePublisher();
    await publisher.attach();

    final List<Future<String>> pending = <Future<String>>[];
    for (var index = 0; index < webMcpNativeMaxOutstandingExecutions; index++) {
      pending.add(boundary.invoke('pending', <String, Object?>{}));
    }
    expect(sideEffects, webMcpNativeMaxOutstandingExecutions);
    now = now.add(webMcpNativeOperationRetention);
    expect(publisher.status.retainedOperationCount, 0);
    expect(
      publisher.status.outstandingExecutionCount,
      webMcpNativeMaxOutstandingExecutions,
    );

    final String busy = await boundary.invoke('pending', <String, Object?>{});
    expect(
      (_decode(busy)['error'] as Map<Object?, Object?>)['code'],
      WebMcpNativeReasonCode.busy.name,
    );
    expect(sideEffects, webMcpNativeMaxOutstandingExecutions);

    for (final Completer<Object?> execution in executions) {
      execution.complete(<String, Object?>{'ok': true});
    }
    await Future.wait(pending);
    expect(publisher.status.outstandingExecutionCount, 0);
  });

  test(
    'capabilities and diagnostics contain allowlisted safe metadata only',
    () async {
      const String secret = 'synthetic-secret-never-diagnose';
      WebMcp.instance.registerTool(
        _tool(
          'diagnostics',
          description: secret,
          handler: (Map<String, Object?> arguments) => <String, Object?>{
            'secret': secret,
          },
        ),
      );
      final WebMcpNativePublisher publisher = WebMcpNativePublisher();
      await publisher.attach();
      await boundary.invoke('diagnostics', <String, Object?>{'secret': secret});

      final WebMcpNativeCapabilities capabilities =
          publisher.status.capabilities;
      expect(capabilities, WebMcpNativeCapabilities.chrome152);
      expect(capabilities.registrationSignalCleanup, isTrue);
      expect(capabilities.cancelBeforeDispatch, isTrue);
      expect(capabilities.invocationCancellationAfterCallbackStart, isFalse);
      expect(capabilities.positiveWait, isFalse);
      expect(capabilities.toDiagnosticMap().keys, <String>{
        'registrationSignalCleanup',
        'cancelBeforeDispatch',
        'invocationCancellationAfterCallbackStart',
        'positiveWait',
      });
      final String diagnostics = jsonEncode(publisher.status.toDiagnosticMap());
      expect(diagnostics, isNot(contains(secret)));
      expect(diagnostics, isNot(contains('description')));
      expect(diagnostics, isNot(contains('arguments')));
      expect(diagnostics, isNot(contains('result')));
    },
  );

  test('call handler sees the execution signal once', () async {
    final _FakeSignal signal = _FakeSignal();
    var handlerCalls = 0;
    var callCalls = 0;
    bool? observed;
    WebMcp.instance.registerTool(
      WebMcpTool(
        name: 'signaled',
        description: 'Reads the execution signal',
        callHandler: (WebMcpToolCall call) {
          callCalls++;
          observed = call.executionSignal?.aborted;
          return observed;
        },
      ),
    );
    WebMcp.instance.registerTool(
      WebMcpTool(
        name: 'plain',
        description: 'One argument handler',
        handler: (Map<String, Object?> arguments) {
          handlerCalls++;
          return arguments;
        },
      ),
    );
    await WebMcpNativePublisher().attach();

    expect(
      jsonDecode(
        await boundary.invoke('signaled', const {}, executionSignal: signal),
      ),
      isFalse,
    );
    expect(callCalls, 1);
    expect(handlerCalls, 0);
    expect(observed, isFalse);

    expect(
      jsonDecode(await boundary.invoke('signaled', const <String, Object?>{})),
      isNull,
    );
    expect(callCalls, 2);
  });

  test('abort after start leaves the handler future pending', () async {
    final _FakeSignal signal = _FakeSignal();
    final Completer<void> started = Completer<void>();
    final Completer<Object?> release = Completer<Object?>();
    var calls = 0;
    WebMcp.instance.registerTool(
      WebMcpTool(
        name: 'inflight',
        description: 'Waits for the test',
        callHandler: (WebMcpToolCall call) {
          calls++;
          started.complete();
          return release.future;
        },
      ),
    );
    await WebMcpNativePublisher().attach();

    final Future<String> pending = boundary.invoke(
      'inflight',
      const <String, Object?>{},
      executionSignal: signal,
    );
    await started.future;
    signal.abort();
    await Future<void>.delayed(Duration.zero);
    expect(calls, 1);
    await expectLater(
      pending.timeout(Duration.zero),
      throwsA(isA<TimeoutException>()),
    );

    release.complete(<String, Object?>{'done': true});
    expect(jsonDecode(await pending), <String, Object?>{'done': true});
  });

  test('cancel before dispatch skips the call handler', () async {
    var calls = 0;
    WebMcp.instance.registerTool(
      WebMcpTool(
        name: 'skipped',
        description: 'Must not run',
        callHandler: (WebMcpToolCall call) {
          calls++;
          return 'ran';
        },
      ),
    );
    await WebMcpNativePublisher().attach();

    final Map<String, Object?> failure = _decode(
      await boundary.invoke(
        'skipped',
        const <String, Object?>{},
        cancelledBeforeDispatch: true,
      ),
    );
    expect((failure['error'] as Map<Object?, Object?>)['code'], 'cancelled');
    expect(calls, 0);
  });

  test(
    'registration object omits unset title debugging and exposedTo',
    () async {
      WebMcp.instance.registerTool(
        WebMcpTool(
          name: 'bare',
          description: 'No optional members',
          handler: (Map<String, Object?> arguments) => null,
        ),
      );
      WebMcp.instance.registerTool(
        WebMcpTool(
          name: 'titled',
          description: 'Has a title',
          title: 'Author title',
          annotations: const WebMcpToolAnnotations(debugging: true),
          exposedTo: const <String>['https://a.example', 'https://b.example'],
          handler: (Map<String, Object?> arguments) => null,
        ),
      );
      WebMcp.instance.registerTool(
        WebMcpTool(
          name: 'debug.false',
          description: 'Debugging false',
          annotations: const WebMcpToolAnnotations(debugging: false),
          exposedTo: const <String>[],
          handler: (Map<String, Object?> arguments) => null,
        ),
      );
      await WebMcpNativePublisher().attach();

      Map<String, Object?> objectNamed(String name) => boundary
          .registrationObjects
          .firstWhere((Map<String, Object?> object) => object['name'] == name);
      final Map<String, Object?> bare = objectNamed('bare');
      final Map<String, Object?> titled = objectNamed('titled');
      final Map<String, Object?> debugFalse = objectNamed('debug.false');
      expect(bare.containsKey('title'), isFalse);
      expect(titled['title'], 'Author title');
      final Map<Object?, Object?> bareAnnotations =
          bare['annotations']! as Map<Object?, Object?>;
      final Map<Object?, Object?> titledAnnotations =
          titled['annotations']! as Map<Object?, Object?>;
      final Map<Object?, Object?> falseAnnotations =
          debugFalse['annotations']! as Map<Object?, Object?>;
      expect(bareAnnotations.containsKey('debugging'), isFalse);
      expect(titledAnnotations['debugging'], isTrue);
      expect(falseAnnotations['debugging'], isFalse);
      expect(bare.containsKey('exposedTo'), isFalse);
      expect(debugFalse['exposedTo'], isEmpty);
      expect(titled['exposedTo'], <String>[
        'https://a.example',
        'https://b.example',
      ]);
    },
  );

  test('tool activity is delivered and dropped after detach', () async {
    var calls = 0;
    WebMcp.instance.registerTool(
      WebMcpTool(
        name: 'quiet',
        description: 'Not invoked by activity',
        handler: (Map<String, Object?> arguments) => calls++,
      ),
    );
    final WebMcpNativePublisher publisher = WebMcpNativePublisher();
    await publisher.attach();
    final List<WebMcpNativeToolActivity> seen = <WebMcpNativeToolActivity>[];
    final List<WebMcpLogRecord> records = <WebMcpLogRecord>[];
    WebMcp.logHook = records.add;
    publisher.addToolActivityListener(seen.add);

    boundary.emitActivity(
      const WebMcpNativeToolActivity(
        kind: WebMcpNativeToolActivityKind.started,
        toolName: 'quiet',
      ),
    );
    expect(seen, hasLength(1));
    expect(seen.single.kind, WebMcpNativeToolActivityKind.started);
    expect(seen.single.toolName, 'quiet');
    expect(records.single.kind, WebMcpLogKind.nativeActivity);
    expect(records.single.toolName, 'quiet');
    expect(calls, 0);

    await publisher.detach();
    boundary.emitActivity(
      const WebMcpNativeToolActivity(
        kind: WebMcpNativeToolActivityKind.started,
        toolName: 'quiet',
      ),
    );
    expect(seen, hasLength(1));
  });

  test('toolcancel does not finish the running call handler', () async {
    final Completer<void> started = Completer<void>();
    final Completer<Object?> release = Completer<Object?>();
    var calls = 0;
    WebMcp.instance.registerTool(
      WebMcpTool(
        name: 'cancel.live',
        description: 'Overlaps toolcancel',
        callHandler: (WebMcpToolCall call) {
          calls++;
          if (calls == 1) {
            started.complete();
            return release.future;
          }
          return 'again';
        },
      ),
    );
    final WebMcpNativePublisher publisher = WebMcpNativePublisher();
    await publisher.attach();
    final List<String> names = <String>[];
    publisher.addToolActivityListener(
      (WebMcpNativeToolActivity activity) => names.add(activity.toolName),
    );

    final Future<String> pending = boundary.invoke(
      'cancel.live',
      const <String, Object?>{},
    );
    await started.future;
    boundary.emitActivity(
      const WebMcpNativeToolActivity(
        kind: WebMcpNativeToolActivityKind.cancelled,
        toolName: 'cancel.live',
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(names, <String>['cancel.live']);
    expect(calls, 1);
    await expectLater(
      pending.timeout(Duration.zero),
      throwsA(isA<TimeoutException>()),
    );
    release.complete('finished');
    expect(jsonDecode(await pending), 'finished');

    expect(await WebMcp.instance.invokeTool('cancel.live', const {}), 'again');
    expect(calls, 2);
  });

  test('structured tool exceptions become agent errors', () async {
    const String secret = 'distinctive-argument-secret';
    const String message = 'distinctive-exception-message';
    WebMcp.instance.registerTool(
      WebMcpTool(
        name: 'coded',
        description: 'Throws a structured failure',
        handler: (Map<String, Object?> arguments) {
          throw const WebMcpToolException(
            code: 'author.code',
            retryable: true,
            details: <String, Object?>{'note': 'visible-detail'},
          );
        },
      ),
    );
    WebMcp.instance.registerTool(
      WebMcpTool(
        name: 'coded.bare',
        description: 'Throws without details',
        handler: (Map<String, Object?> arguments) {
          throw const WebMcpToolException(code: 'bare.code', retryable: false);
        },
      ),
    );
    WebMcp.instance.registerTool(
      WebMcpTool(
        name: 'state',
        description: 'Throws StateError',
        handler: (Map<String, Object?> arguments) => throw StateError(message),
      ),
    );
    WebMcp.instance.registerTool(
      WebMcpTool(
        name: 'oversized',
        description: 'Details exceed the encoded size',
        handler: (Map<String, Object?> arguments) {
          throw WebMcpToolException(
            code: 'too.big',
            retryable: false,
            details: <String, Object?>{'blob': 'y' * webMcpNativeMaxJsonBytes},
          );
        },
      ),
    );
    final List<String> logs = <String>[];
    WebMcp.logHook = (WebMcpLogRecord record) => logs.add(record.toString());
    await WebMcpNativePublisher().attach();

    final Map<String, Object?> withDetails = _decode(
      await boundary.invoke('coded', <String, Object?>{'value': secret}),
    );
    final Map<Object?, Object?> withError =
        withDetails['error']! as Map<Object?, Object?>;
    expect(withDetails['ok'], isFalse);
    expect(withError['code'], 'author.code');
    expect(withError['retryable'], isTrue);
    expect(withError['details'], <String, Object?>{'note': 'visible-detail'});

    final Map<String, Object?> withoutDetails = _decode(
      await boundary.invoke('coded.bare', const <String, Object?>{}),
    );
    expect(
      (withoutDetails['error']! as Map<Object?, Object?>).containsKey(
        'details',
      ),
      isFalse,
    );

    final String stateResult = await boundary.invoke('state', <String, Object?>{
      'value': secret,
    });
    expect(
      (_decode(stateResult)['error'] as Map<Object?, Object?>)['code'],
      'handlerFailed',
    );
    expect(stateResult, isNot(contains(message)));
    expect(stateResult, isNot(contains(secret)));

    final String oversized = await boundary.invoke(
      'oversized',
      const <String, Object?>{},
    );
    expect(
      (_decode(oversized)['error'] as Map<Object?, Object?>)['code'],
      'handlerFailed',
    );
    expect(oversized, isNot(contains('yyy')));
    expect(logs.join('\n'), isNot(contains(secret)));
    expect(logs.join('\n'), isNot(contains(message)));
    expect(logs.join('\n'), isNot(contains('visible-detail')));
  });
}
