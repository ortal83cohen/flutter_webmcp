import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';

import 'example_runtime.dart';
import 'example_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ExampleRuntime runtime = ExampleRuntime();
  await runtime.install();
  runApp(WebMcpPilotExample(runtime: runtime));
}

/// The example application.
final class WebMcpPilotExample extends StatefulWidget {
  /// Creates the example application over an already-installed [runtime].
  const WebMcpPilotExample({required this.runtime, super.key});

  /// The runtime this application drives. Constructed and installed once,
  /// in [main], so the startup order, the session attachment and the
  /// Navigator adapter parameters have exactly one definition.
  final ExampleRuntime runtime;

  @override
  State<WebMcpPilotExample> createState() => _WebMcpPilotExampleState();
}

final class _WebMcpPilotExampleState extends State<WebMcpPilotExample> {
  late final WebMcpNavigatorAdapter _rootNavigator;

  @override
  void initState() {
    super.initState();
    _rootNavigator = widget.runtime.createRootNavigatorAdapter();
  }

  @override
  void dispose() {
    _rootNavigator.dispose();
    // There is no natural "app teardown" in a real Flutter app's `main()`;
    // this call exists for symmetry with the test harness's disposal and
    // documents the intended lifecycle rather than running in practice.
    unawaited(widget.runtime.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: <NavigatorObserver>[_rootNavigator],
      home: ExampleScreen(runtime: widget.runtime),
    );
  }
}
