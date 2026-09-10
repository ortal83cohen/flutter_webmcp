import 'package:test/test.dart';
import 'package:webmcp_pilot/webmcp_pilot.dart';

WebMcpTool _tool(String name, Object? value) => WebMcpTool(
  name: name,
  description: 'Tool $name',
  handler: (Map<String, Object?> arguments) => value,
);

final class _Source implements WebMcpToolSource {
  _Source(this.tool);

  final WebMcpTool tool;

  @override
  List<WebMcpTool> getWebMcpTools() => <WebMcpTool>[tool];
}

void main() {
  setUp(WebMcp.instance.reset);

  test('adds direct and source tools, then closes', () {
    final WebMcpScope scope = WebMcpScope(scopeName: 'scope');
    expect(scope.addTool(_tool('direct', 1)), isTrue);
    scope.addSource(_Source(_tool('source', 2)));
    expect(WebMcp.instance.tools.map((WebMcpTool tool) => tool.name), <String>[
      'direct',
      'source',
    ]);
    expect(scope.ownedNames, <String>['direct', 'source']);

    scope.close();
    expect(WebMcp.instance.tools, isEmpty);
    expect(scope.ownedNames, isEmpty);
    expect(scope.skippedNames, isEmpty);
  });

  test('skips duplicates and never removes another owner', () async {
    WebMcp.instance.registerTool(_tool('shared', 'first'));
    final WebMcpScope scope = WebMcpScope(scopeName: 'second');

    expect(scope.addTool(_tool('shared', 'second')), isFalse);
    expect(scope.ownedNames, isEmpty);
    expect(scope.skippedNames, <String>['shared']);
    expect(await WebMcp.instance.invokeTool('shared', const {}), 'first');
    scope.close();
    expect(WebMcp.instance.tools.single.name, 'shared');
  });

  test('remove is limited to names owned by the scope', () {
    WebMcp.instance.registerTool(_tool('external', null));
    final WebMcpScope scope = WebMcpScope(scopeName: 'scope');
    scope.addTool(_tool('owned', null));

    expect(scope.removeTool('external'), isFalse);
    expect(scope.removeTool('owned'), isTrue);
    expect(WebMcp.instance.tools.single.name, 'external');
  });

  test('close is idempotent and closed scopes reject additions', () {
    final WebMcpScope scope = WebMcpScope(scopeName: 'closed');
    scope.close();
    expect(scope.close, returnsNormally);
    expect(scope.isClosed, isTrue);
    expect(
      () => scope.addTool(_tool('late', null)),
      throwsA(isA<StateError>()),
    );
    expect(
      () => scope.addSource(_Source(_tool('later', null))),
      throwsA(isA<StateError>()),
    );
    expect(WebMcp.instance.tools, isEmpty);
  });

  test('invalid names propagate without becoming owned or skipped', () {
    final WebMcpScope scope = WebMcpScope(scopeName: 'invalid');
    expect(
      () => scope.addTool(_tool('invalid name', null)),
      throwsA(isA<WebMcpInvalidToolNameException>()),
    );
    expect(scope.ownedNames, isEmpty);
    expect(scope.skippedNames, isEmpty);
    expect(WebMcp.instance.tools, isEmpty);
  });
}
