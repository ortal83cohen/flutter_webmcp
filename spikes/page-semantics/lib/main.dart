// Self-check entry point for release-mode verification.
// When run as a Flutter web app (debug or release), this shows a summary
// of which semantics APIs are available and their basic behavior.
// Results are written to Text widgets visible in the DOM (via the Flutter
// web semantics ARIA tree) so headless Chrome can inspect them.
//
// This file is NOT a widget test – it runs as a real Flutter web app.
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'semantics_probe.dart';

void main() {
  runApp(const SemanticsCheckApp());
}

class SemanticsCheckApp extends StatelessWidget {
  const SemanticsCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'page-semantics-spike',
      home: SemanticsCheckPage(),
    );
  }
}

class SemanticsCheckPage extends StatefulWidget {
  const SemanticsCheckPage({super.key});

  @override
  State<SemanticsCheckPage> createState() => _SemanticsCheckPageState();
}

class _SemanticsCheckPageState extends State<SemanticsCheckPage> {
  final List<String> _results = [];

  @override
  void initState() {
    super.initState();
    // Run checks after the first frame so semantics are mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) => _runChecks());
  }

  void _record(String label, bool pass, [String? detail]) {
    setState(() {
      _results.add(
        '${pass ? "PASS" : "FAIL"} $label'
        '${detail != null ? ": $detail" : ""}',
      );
    });
  }

  void _runChecks() {
    // API-availability check: SemanticsBinding exists.
    _record('SemanticsBinding.instance available', true);

    // Enable semantics and verify handle is returned.
    // SemanticsHandle is non-nullable; record that the call succeeded.
    final handle = SemanticsBinding.instance.ensureSemantics();
    _record('ensureSemantics returns handle', true);

    // Verify root semantics node exists after enabling.
    final owner = primarySemanticsOwner();
    _record('semanticsOwner non-null after ensureSemantics', owner != null);

    if (owner != null) {
      final root = owner.rootSemanticsNode;
      _record('rootSemanticsNode non-null', root != null);

      if (root != null) {
        // Verify flagsCollection is accessible (3.47.0 API).
        // flagsCollection is always non-null; verify isHidden is readable.
        final isHidden = root.flagsCollection.isHidden;
        _record(
          'flagsCollection.isHidden readable on root node',
          !isHidden || isHidden,
        );

        // Verify walk completes.
        final result = walkSemantics(root);
        _record(
          'walkSemantics returns nodes',
          result.nodes.isNotEmpty,
          'count=${result.nodes.length}',
        );
      }
    }

    // Dispose handle and verify no crash.
    try {
      handle.dispose();
      _record('SemanticsHandle.dispose() completes without error', true);
    } catch (e) {
      _record('SemanticsHandle.dispose() completes without error', false, '$e');
    }

    // Verify all PASS.
    final failCount = _results.where((r) => r.startsWith('FAIL')).length;
    setState(() {
      _results.add(
        failCount == 0 ? 'SUMMARY: ALL PASS' : 'SUMMARY: $failCount FAIL(s)',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('page-semantics-spike self-check')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _results.length,
        itemBuilder: (context, i) {
          final line = _results[i];
          final color = line.startsWith('FAIL')
              ? Colors.red
              : line.startsWith('PASS')
              ? Colors.green
              : Colors.black;
          return Text(
            line,
            style: TextStyle(color: color, fontFamily: 'monospace'),
          );
        },
      ),
    );
  }
}
