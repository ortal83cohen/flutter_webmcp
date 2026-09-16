import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';

import 'package:webmcp_flutter_example/example_task_service.dart';
import 'package:webmcp_flutter_example/example_task_service.webmcp.g.dart';

void main() {
  setUp(WebMcp.instance.reset);
  tearDown(WebMcp.instance.reset);

  test('both generated tool names register and the unannotated method '
      'contributes no tool name', () {
    final ExampleTaskService service = ExampleTaskService();
    final WebMcpScope scope = WebMcpScope(scopeName: 'tasks');
    scope.addSource(ExampleTaskServiceWebMcpSource(service));

    final Iterable<String> names = WebMcp.instance.tools.map(
      (WebMcpTool tool) => tool.name,
    );
    expect(
      names,
      containsAll(<String>['example.tasks.create', 'example.tasks.list']),
    );
    expect(names, hasLength(2));
    expect(
      names.any((String name) => name.toLowerCase().contains('clear')),
      isFalse,
    );
  });

  test('the create schema requires title and carries the consequential hint; '
      'the list descriptor carries the read-only hint', () {
    final ExampleTaskService service = ExampleTaskService();
    final WebMcpScope scope = WebMcpScope(scopeName: 'tasks');
    scope.addSource(ExampleTaskServiceWebMcpSource(service));

    final WebMcpTool create = WebMcp.instance.tools.singleWhere(
      (WebMcpTool tool) => tool.name == 'example.tasks.create',
    );
    final WebMcpTool list = WebMcp.instance.tools.singleWhere(
      (WebMcpTool tool) => tool.name == 'example.tasks.list',
    );

    expect(create.inputSchema['required'], contains('title'));
    expect(create.annotations.consequentialHint, isTrue);
    expect(create.annotations.readOnlyHint, isFalse);
    expect(list.annotations.readOnlyHint, isTrue);
  });

  test('an authorized create grows the task list', () async {
    final ExampleTaskService service = ExampleTaskService(authorized: true);
    final WebMcpScope scope = WebMcpScope(scopeName: 'tasks');
    scope.addSource(ExampleTaskServiceWebMcpSource(service));

    expect(service.tasks, isEmpty);
    final Object? result = await WebMcp.instance.invokeTool(
      'example.tasks.create',
      <String, Object?>{'title': 'Write tests'},
    );
    expect(result, 1);
    expect(service.tasks, <String>['Write tests']);
  });

  test('an unauthorized create surfaces the service refusal and leaves the '
      'task list unchanged', () async {
    final ExampleTaskService service = ExampleTaskService(authorized: false);
    final WebMcpScope scope = WebMcpScope(scopeName: 'tasks');
    scope.addSource(ExampleTaskServiceWebMcpSource(service));

    await expectLater(
      WebMcp.instance.invokeTool('example.tasks.create', <String, Object?>{
        'title': 'Write tests',
      }),
      throwsA(isA<StateError>()),
    );
    expect(service.tasks, isEmpty);
  });

  test(
    'a create with no title returns an invalid-arguments failure envelope',
    () async {
      final ExampleTaskService service = ExampleTaskService(authorized: true);
      final WebMcpScope scope = WebMcpScope(scopeName: 'tasks');
      scope.addSource(ExampleTaskServiceWebMcpSource(service));

      final Object? result = await WebMcp.instance.invokeTool(
        'example.tasks.create',
        <String, Object?>{},
      );

      expect(result, isA<Map<String, Object?>>());
      final Map<String, Object?> envelope = result! as Map<String, Object?>;
      expect(envelope['ok'], isFalse);
      expect(
        (envelope['error']! as Map<String, Object?>)['code'],
        'invalidArguments',
      );
      expect(service.tasks, isEmpty);
    },
  );

  test('the list action reports the current task titles', () async {
    final ExampleTaskService service = ExampleTaskService(authorized: true);
    final WebMcpScope scope = WebMcpScope(scopeName: 'tasks');
    scope.addSource(ExampleTaskServiceWebMcpSource(service));

    await WebMcp.instance.invokeTool('example.tasks.create', <String, Object?>{
      'title': 'Write tests',
    });
    final Object? result = await WebMcp.instance.invokeTool(
      'example.tasks.list',
      const <String, Object?>{},
    );
    expect(result, <String>['Write tests']);
  });
}
