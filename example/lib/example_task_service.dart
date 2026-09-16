import 'package:flutter/foundation.dart';
import 'package:webmcp_flutter_annotations/webmcp_flutter_annotations.dart';

/// Application-owned task service exposing two domain actions to WebMCP.
///
/// The generated adapter never grants authorization; the service enforces
/// its own `authorized` decision and refuses with a [StateError] when it is
/// false, which is a deliberate throw per the example's error-handling
/// convention.
final class ExampleTaskService extends ChangeNotifier {
  /// Creates a task service with an application-owned authorization flag.
  ExampleTaskService({this.authorized = false});

  /// Whether the application currently authorizes task creation.
  bool authorized;

  final List<String> _tasks = <String>[];

  /// The current task titles, in creation order.
  List<String> get tasks => List<String>.unmodifiable(_tasks);

  /// Creates a task when the application authorizes it.
  @WebMcpDomainAction(
    name: 'example.tasks.create',
    description: 'Creates a task when the application authorizes it.',
    consequentialHint: true,
  )
  int create({required String title}) {
    if (!authorized) {
      throw StateError('Application authorization denied creating a task.');
    }
    _tasks.add(title);
    notifyListeners();
    return _tasks.length;
  }

  /// Lists the current task titles.
  @WebMcpDomainAction(
    name: 'example.tasks.list',
    description: 'Lists the current task titles.',
    readOnlyHint: true,
  )
  List<String> list() => List<String>.unmodifiable(_tasks);

  /// Clears every task. Not annotated, so it is never exposed to WebMCP.
  void clearTasks() {
    _tasks.clear();
    notifyListeners();
  }
}
