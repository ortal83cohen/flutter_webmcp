import 'package:flutter/material.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';

import 'example_runtime.dart';

/// Renders the native publisher and application-session diagnostic surfaces,
/// the recording transport's identifier and counters, the page protocol
/// version, and two buttons that invoke the application observe endpoint.
///
/// The publisher status diagnostic map is rendered once, one row per key in
/// its own iteration order, labelled with the `publisher.` prefix; the
/// capability diagnostic map is not rendered separately, because the
/// publisher map already spreads all four capability keys into itself. The
/// nine named application-session diagnostic getters are rendered with the
/// `session.` prefix, and the transport's identifier and counters with the
/// `transport.` prefix. An empty-list diagnostic value renders as the
/// literal text `none`, which counts as a shown value rather than a missing
/// one.
final class ExampleDiagnosticsScreen extends StatefulWidget {
  /// Creates the diagnostics screen over [runtime].
  const ExampleDiagnosticsScreen({required this.runtime, super.key});

  /// The runtime whose publisher, session and transport are diagnosed.
  final ExampleRuntime runtime;

  @override
  State<ExampleDiagnosticsScreen> createState() =>
      _ExampleDiagnosticsScreenState();
}

final class _ExampleDiagnosticsScreenState
    extends State<ExampleDiagnosticsScreen> {
  String? _observeResult;
  String? _observeWaitResult;

  Future<void> _observe() async {
    final Object? result = await WebMcp.instance.invokeTool(
      'example.app.observe',
      const <String, Object?>{},
    );
    setState(() {
      _observeResult = _formatResponse(result as Map<String, Object?>);
    });
  }

  Future<void> _observeWithWait() async {
    final Object? result = await WebMcp.instance.invokeTool(
      'example.app.observe',
      const <String, Object?>{'waitMs': 250},
    );
    setState(() {
      _observeWaitResult = _formatResponse(result as Map<String, Object?>);
    });
  }

  static String _formatResponse(Map<String, Object?> response) {
    final List<String> lines = <String>['ok: ${response['ok']}'];
    if (response.containsKey('code')) {
      lines.add('code: ${response['code']}');
    }
    if (response.containsKey('cursor')) {
      lines.add('cursor: ${response['cursor']}');
    }
    final Object? waitCapability = response['waitCapability'];
    if (waitCapability is Map<String, Object?>) {
      lines.add(
        'waitCapability.positiveWaitSupported: '
        '${waitCapability['positiveWaitSupported']}',
      );
      lines.add('waitCapability.maxWaitMs: ${waitCapability['maxWaitMs']}');
    }
    return lines.join('\n');
  }

  static String _formatValue(Object? value) {
    if (value is List) {
      return value.isEmpty ? 'none' : value.join(', ');
    }
    return value.toString();
  }

  List<Widget> _publisherRows() {
    final Map<String, Object> map = widget.runtime.publisher.status
        .toDiagnosticMap();
    return <Widget>[
      for (final MapEntry<String, Object> entry in map.entries)
        Text(
          'publisher.${entry.key}: ${_formatValue(entry.value)}',
          key: ValueKey<String>('publisher.${entry.key}'),
        ),
    ];
  }

  List<Widget> _sessionRows() {
    final WebMcpAppSession session = widget.runtime.session;
    final Map<String, Object?> values = <String, Object?>{
      'isAttached': session.isAttached,
      'ownsObserveTool': session.ownsObserveTool,
      'appMount': session.appMount,
      'liveScopeCount': session.liveScopeCount,
      'navigatorAdapterCount': session.navigatorAdapterCount,
      'routeEvidenceReady': session.routeEvidenceReady,
      'retainedEventCount': session.retainedEventCount,
      'retainedOperationCount': session.retainedOperationCount,
      'outstandingExecutionCount': session.outstandingExecutionCount,
    };
    return <Widget>[
      for (final MapEntry<String, Object?> entry in values.entries)
        Text(
          'session.${entry.key}: ${_formatValue(entry.value)}',
          key: ValueKey<String>('session.${entry.key}'),
        ),
    ];
  }

  List<Widget> _transportRows() {
    final Map<String, Object?> values = <String, Object?>{
      'id': widget.runtime.transport.id,
      'registrationCount': widget.runtime.transport.registrationCount,
      'unregistrationCount': widget.runtime.transport.unregistrationCount,
    };
    return <Widget>[
      for (final MapEntry<String, Object?> entry in values.entries)
        Text(
          'transport.${entry.key}: ${_formatValue(entry.value)}',
          key: ValueKey<String>('transport.${entry.key}'),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'The four capability keys below originate in the embedded '
              'capability matrix and are already spread into the publisher '
              'map, so they are shown once.',
            ),
            const SizedBox(height: 8),
            const Text('Publisher diagnostics:'),
            ..._publisherRows(),
            const SizedBox(height: 16),
            const Text('Session diagnostics:'),
            ..._sessionRows(),
            const SizedBox(height: 16),
            const Text('Transport diagnostics:'),
            ..._transportRows(),
            const SizedBox(height: 16),
            Text(
              'protocolVersion: $webMcpPageProtocolVersion',
              key: const ValueKey<String>('protocolVersion'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _observe, child: const Text('Observe')),
            if (_observeResult != null)
              Text(
                _observeResult!,
                key: const ValueKey<String>('observeResult'),
              ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _observeWithWait,
              child: const Text('Observe with wait'),
            ),
            if (_observeWaitResult != null)
              Text(
                _observeWaitResult!,
                key: const ValueKey<String>('observeWaitResult'),
              ),
          ],
        ),
      ),
    );
  }
}
