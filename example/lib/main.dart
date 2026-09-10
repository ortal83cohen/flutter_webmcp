import 'package:flutter/material.dart';

import 'example_screen.dart';

void main() {
  runApp(const WebMcpPilotExample());
}

/// The example application.
final class WebMcpPilotExample extends StatelessWidget {
  /// Creates the example application.
  const WebMcpPilotExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ExampleScreen());
  }
}
