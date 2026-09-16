import 'package:webmcp_flutter/webmcp_flutter.dart';

/// A [WebMcpTransport] that records registry activity instead of publishing
/// tools to any platform surface.
///
/// It reports the fixed identifier `example-recording` and keeps a running
/// count of registrations and unregistrations, plus the name of the most
/// recently registered tool. This demonstrates the transport seam without
/// depending on any platform integration.
class ExampleRecordingTransport implements WebMcpTransport {
  int _registrationCount = 0;
  int _unregistrationCount = 0;
  String? _lastRegisteredName;

  @override
  String get id => 'example-recording';

  /// The number of times [onToolRegistered] has been called.
  int get registrationCount => _registrationCount;

  /// The number of times [onToolUnregistered] has been called.
  int get unregistrationCount => _unregistrationCount;

  /// The name of the most recently registered tool, or `null` until the
  /// first registration.
  String? get lastRegisteredName => _lastRegisteredName;

  @override
  void onToolRegistered(WebMcpTool tool) {
    _registrationCount++;
    _lastRegisteredName = tool.name;
  }

  @override
  void onToolUnregistered(String name) {
    _unregistrationCount++;
  }
}
