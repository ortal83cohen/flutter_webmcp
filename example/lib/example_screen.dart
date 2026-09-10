import 'package:flutter/material.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';

import 'example_tools.dart';

/// Displays registry state and demonstrates lifecycle-based tool exposure.
final class ExampleScreen extends StatefulWidget {
  /// Creates the example screen.
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

final class _ExampleScreenState extends State<ExampleScreen>
    with WebMcpScreen<ExampleScreen> {
  final ExampleCounter _counter = ExampleCounter();

  @override
  void initState() {
    super.initState();
    registerExampleTools(_counter);
  }

  @override
  void registerWebMcpTools() {
    mcpScope.addTool(
      WebMcpTool(
        name: 'example.screen.describe',
        description: 'Describes the active example screen.',
        handler: (Map<String, Object?> arguments) => 'ExampleScreen',
      ),
    );
  }

  void _increment() {
    setState(_counter.increment);
  }

  @override
  Widget build(BuildContext context) {
    final String names = WebMcp.instance.tools
        .map((WebMcpTool tool) => tool.name)
        .join('\n');
    return WebMcpPage(
      pageId: 'example.home',
      child: Scaffold(
        appBar: AppBar(title: const Text('WebMCP Flutter')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Counter: ${_counter.value}'),
              Text('Transport: ${WebMcp.instance.transportId}'),
              const SizedBox(height: 16),
              const Text('Registered tools:'),
              Text(names),
              const SizedBox(height: 16),
              WebMcpAction(
                name: 'example.screen.increment',
                description: 'Increments the visible example counter.',
                onInvoke: (Map<String, Object?> arguments) {
                  _increment();
                  return _counter.value;
                },
                child: ElevatedButton(
                  onPressed: _increment,
                  child: const Text('Increment'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          const _ExampleDetailsPage(),
                    ),
                  );
                },
                child: const Text('Open details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _ExampleDetailsPage extends StatelessWidget {
  const _ExampleDetailsPage();

  @override
  Widget build(BuildContext context) {
    return WebMcpPage(
      pageId: 'example.details',
      child: Scaffold(
        appBar: AppBar(title: const Text('Details')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Return home'),
          ),
        ),
      ),
    );
  }
}
