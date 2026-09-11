import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';

import 'example_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final WebMcpAppSession session = WebMcpAppSession();
  session.attach(appId: 'example');
  final WebMcpNativePublisher publisher = WebMcpNativePublisher();
  await publisher.attach();
  runApp(WebMcpPilotExample(session: session, publisher: publisher));
}

/// The example application.
final class WebMcpPilotExample extends StatefulWidget {
  /// Creates the example application.
  const WebMcpPilotExample({
    required this.session,
    required this.publisher,
    super.key,
  });

  /// Application-owned page observation session.
  final WebMcpAppSession session;

  /// Native browser publisher attached to the manual registry.
  final WebMcpNativePublisher publisher;

  @override
  State<WebMcpPilotExample> createState() => _WebMcpPilotExampleState();
}

final class _WebMcpPilotExampleState extends State<WebMcpPilotExample> {
  late final WebMcpNavigatorAdapter _rootNavigator;

  @override
  void initState() {
    super.initState();
    _rootNavigator = WebMcpNavigatorAdapter(
      session: widget.session,
      navigatorId: 'root',
      rootModalRelationship: true,
    );
  }

  @override
  void dispose() {
    _rootNavigator.dispose();
    widget.session.detach();
    unawaited(widget.publisher.detach());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: <NavigatorObserver>[_rootNavigator],
      home: ExampleScreen(publisher: widget.publisher),
    );
  }
}
