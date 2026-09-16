import 'package:flutter/material.dart';

import 'example_exception_demo.dart';

/// Demonstrates the registry exception family plus a genuinely unscoped
/// [describeUnscopedLookup] reading.
///
/// This widget deliberately does **not** mix in `WebMcpScreen`. Its `build`
/// method's own [BuildContext] therefore has no enclosing screen scope, so
/// the fourth transcript line it renders is a real "no scope" reading rather
/// than one manufactured for the demo.
class ExampleExceptionScreen extends StatefulWidget {
  const ExampleExceptionScreen({super.key});

  @override
  State<ExampleExceptionScreen> createState() => _ExampleExceptionScreenState();
}

class _ExampleExceptionScreenState extends State<ExampleExceptionScreen> {
  List<String>? _transcript;

  @override
  void initState() {
    super.initState();
    _runDemo();
  }

  Future<void> _runDemo() async {
    final List<String> lines = await triggerAndCatchExceptions();
    if (!mounted) {
      return;
    }
    setState(() {
      _transcript = lines;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String>? transcript = _transcript;
    final List<String> lines = <String>[
      ...(transcript ?? const <String>[]),
      if (transcript != null) describeUnscopedLookup(context),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Exception demonstration')),
      body: transcript == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[for (final String line in lines) Text(line)],
            ),
    );
  }
}
