import 'package:webmcp_flutter/webmcp_flutter.dart';

import 'example_counter_source.dart';
import 'example_recording_transport.dart';
import 'example_registry_log.dart';
import 'example_task_service.dart';
import 'example_task_service.webmcp.g.dart';
import 'example_tools.dart';

/// Owns every long-lived object the example's demonstrations need, and owns
/// the single fixed startup sequence that installs them into the
/// process-wide registry.
///
/// Both `example/lib/main.dart` and the widget-test harness in
/// `example/test/example_test_support.dart` drive the application through
/// this one class, so the startup order, the session attachment and the
/// Navigator adapter parameters have exactly one definition in the
/// repository.
final class ExampleRuntime {
  /// Creates a runtime holding fresh, uninstalled long-lived objects.
  ExampleRuntime()
    : counter = ExampleCounter(),
      taskService = ExampleTaskService(),
      transport = ExampleRecordingTransport(),
      registryLog = ExampleRegistryLog(),
      session = WebMcpAppSession(),
      publisher = WebMcpNativePublisher();

  /// The example's counter, backing both the imperative tools and the
  /// hand-written tool source.
  final ExampleCounter counter;

  /// The application-owned annotated task service, backing the generated
  /// domain-action adapter.
  final ExampleTaskService taskService;

  /// The recording transport installed as the first registry call of the
  /// process, before anything is registered.
  final ExampleRecordingTransport transport;

  /// The registry observer that transcribes registration and reset events.
  final ExampleRegistryLog registryLog;

  /// The process-wide application session this runtime attaches.
  final WebMcpAppSession session;

  /// The native publisher this runtime attaches after the session.
  final WebMcpNativePublisher publisher;

  WebMcpRegistrySubscription? _registryLogSubscription;
  bool _installed = false;

  /// Whether [install] has already completed on this instance.
  bool get isInstalled => _installed;

  /// Performs the fixed startup sequence, in this order and no other:
  ///
  /// 1. Reset the registry with the recording transport (must be first,
  ///    because a reset cancels observer subscriptions).
  /// 2. Add the registry log as a registry observer.
  /// 3. Register the hand-written counter source.
  /// 4. Register the generated task source.
  /// 5. Register the two imperative counter tools.
  /// 6. Attach the session with the application identifier `example`.
  /// 7. Await the publisher's attach.
  ///
  /// Calling this method a second time on the same instance raises a
  /// [StateError].
  Future<void> install() async {
    if (_installed) {
      throw StateError('ExampleRuntime.install() was already called.');
    }
    _installed = true;

    WebMcp.instance.reset(transport);
    _registryLogSubscription = WebMcp.instance.addRegistryObserver(registryLog);
    WebMcp.instance.registerSource(ExampleCounterSource(counter));
    WebMcp.instance.registerSource(ExampleTaskServiceWebMcpSource(taskService));
    registerExampleTools(counter);
    session.attach(appId: 'example');
    await publisher.attach();
  }

  /// Returns the root Navigator adapter with the fixed parameters: the
  /// identifier `root`, a root-modal relationship of true, no parent
  /// Navigator identifier, no persistent parallel branch and no selected
  /// branch.
  WebMcpNavigatorAdapter createRootNavigatorAdapter() {
    return WebMcpNavigatorAdapter(
      session: session,
      navigatorId: 'root',
      rootModalRelationship: true,
    );
  }

  /// Detaches the publisher, detaches the session, cancels the registry-log
  /// subscription and resets the registry, restoring the platform default
  /// transport.
  ///
  /// Callers under `testWidgets` must not defer this call to `addTearDown`
  /// as a bare async callback: the awaited [WebMcpNativePublisher.detach]
  /// future does not settle when invoked that way (confirmed empirically —
  /// `tester.runAsync` does not fix it either), even though it settles
  /// immediately when awaited directly inside the test body. Call
  /// `await runtime.dispose()` inside a `try`/`finally` in the test body
  /// instead.
  Future<void> dispose() async {
    await publisher.detach();
    session.detach();
    _registryLogSubscription?.cancel();
    _registryLogSubscription = null;
    WebMcp.instance.reset();
  }
}
