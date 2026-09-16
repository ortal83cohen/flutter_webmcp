import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';

/// A [ChangeNotifier] that records registry activity as a human-readable
/// transcript.
///
/// Implements both [WebMcpRegistryObserver], to append one line per
/// registration and per unregistration, and [WebMcpRegistryResetObserver],
/// to append a line and increment a counter each time [WebMcp.instance.reset]
/// cancels its subscription. Only the most recent sixty-four lines are
/// retained; the oldest line is evicted once a sixty-fifth line arrives. This
/// bound is deliberately larger than the twelve startup registrations plus
/// the handful of events a full walkthrough produces, so a startup line
/// naming a screen-owned tool can still be found later.
class ExampleRegistryLog extends ChangeNotifier
    implements WebMcpRegistryObserver, WebMcpRegistryResetObserver {
  /// The maximum number of lines retained by this log.
  static const int retentionBound = 64;

  final List<String> _lines = <String>[];
  int _resetCount = 0;

  /// The retained log lines, oldest first, capped at [retentionBound].
  List<String> get lines => UnmodifiableListView<String>(_lines);

  /// The number of times [onRegistryReset] has been invoked.
  int get resetCount => _resetCount;

  @override
  void onToolRegistered(WebMcpTool tool) {
    _append('registered ${tool.name}');
  }

  @override
  void onToolUnregistered(String name) {
    _append('unregistered $name');
  }

  @override
  void onRegistryReset() {
    _resetCount++;
    _append('reset (count $_resetCount)');
  }

  void _append(String line) {
    _lines.add(line);
    if (_lines.length > retentionBound) {
      _lines.removeAt(0);
    }
    notifyListeners();
  }
}
