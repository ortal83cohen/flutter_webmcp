import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';
import 'package:webmcp_flutter_example/example_exception_screen.dart';

void main() {
  setUp(WebMcp.instance.reset);
  tearDown(WebMcp.instance.reset);

  testWidgets('shows the three exception type names and the no-scope line, and '
      'raises no uncaught framework exception', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExampleExceptionScreen()));

    // Let the async demo run and the widget rebuild with its transcript.
    await tester.pumpAndSettle();

    expect(
      find.textContaining('WebMcpInvalidToolNameException'),
      findsOneWidget,
    );
    expect(find.textContaining('WebMcpDuplicateToolException'), findsOneWidget);
    expect(find.textContaining('WebMcpToolNotFoundException'), findsOneWidget);
    expect(
      find.textContaining('Scope lookup: no scope found.'),
      findsOneWidget,
    );

    expect(tester.takeException(), isNull);
  });
}
