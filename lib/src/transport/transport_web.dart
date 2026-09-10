import 'dart:developer' as developer;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart';

import '../webmcp_tool.dart';
import 'webmcp_transport.dart';

/// Creates the browser feature-detection transport.
WebMcpTransport createDefaultTransport() => WebDetectionTransport();

/// Detects browser WebMCP support and logs registry changes.
final class WebDetectionTransport implements WebMcpTransport {
  /// Creates a transport and records whether WebMCP appears available.
  WebDetectionTransport()
    : _isAvailable = document.hasProperty('modelContext'.toJS).toDart {
    _write('modelContext detected: $_isAvailable; tools not published');
  }

  final bool _isAvailable;

  @override
  String get id => 'web-detection';

  @override
  void onToolRegistered(WebMcpTool tool) {
    _write('registered ${tool.name}; tools not published');
  }

  @override
  void onToolUnregistered(String name) {
    _write('unregistered $name; tools not published');
  }

  void _write(String message) {
    developer.log(message, name: 'webmcp_pilot');
  }
}
