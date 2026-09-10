import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';

final class _Source implements WebMcpToolSource {
  @override
  List<WebMcpTool> getWebMcpTools() => <WebMcpTool>[];
}

final class _Transport implements WebMcpTransport {
  @override
  String get id => 'public';

  @override
  void onToolRegistered(WebMcpTool tool) {}

  @override
  void onToolUnregistered(String name) {}
}

void main() {
  test(
    'exports the complete public API and seven registry operations',
    () async {
      Object? handler(Map<String, Object?> arguments) => arguments['value'];
      final WebMcpToolHandler typedHandler = handler;
      final WebMcpTool tool = WebMcpTool(
        name: 'public.tool',
        description: 'Public tool',
        handler: typedHandler,
      );
      final WebMcp registry = WebMcp.instance;
      registry.reset(_Transport());
      registry.registerTool(tool);
      registry.registerSource(_Source());
      expect(registry.tools.single, same(tool));
      expect(
        await registry.invokeTool('public.tool', const {'value': 'ok'}),
        'ok',
      );
      expect(registry.transportId, 'public');
      expect(registry.unregisterTool('public.tool'), isTrue);

      expect(WebMcpScope, isNotNull);
      expect(WebMcpScreen, isNotNull);
      expect(WebMcpAction, isNotNull);
      expect(WebMcpException, isNotNull);
      expect(WebMcpInvalidToolNameException, isNotNull);
      expect(WebMcpDuplicateToolException, isNotNull);
      expect(WebMcpToolNotFoundException, isNotNull);
      expect(WebMcpScopeMissingException, isNotNull);
    },
  );
}
