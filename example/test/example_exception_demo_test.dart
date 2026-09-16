import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';
import 'package:webmcp_flutter_example/example_exception_demo.dart';

/// A minimal host that carries a [WebMcpScreen] scope for the lifetime of its
/// state, used to exercise the positive `maybeScopeOf` reading and the
/// scoped [WebMcpAction] case.
final class _ScopedHost extends StatefulWidget {
  const _ScopedHost({required this.child});

  final Widget child;

  @override
  State<_ScopedHost> createState() => _ScopedHostState();
}

final class _ScopedHostState extends State<_ScopedHost> with WebMcpScreen {
  @override
  Widget build(BuildContext context) => widget.child;
}

void main() {
  setUp(WebMcp.instance.reset);
  tearDown(WebMcp.instance.reset);

  group('triggerAndCatchExceptions', () {
    test(
      'catches an invalid tool name, a duplicate tool name and a missing '
      'tool invocation, naming the caught type and the offending tool name',
      () async {
        final List<String> transcript = await triggerAndCatchExceptions();

        expect(transcript, hasLength(3));
        expect(
          transcript[0],
          'Caught WebMcpInvalidToolNameException for tool '
          '"$invalidToolNameDemo".',
        );
        expect(
          transcript[1],
          'Caught WebMcpDuplicateToolException for tool '
          '"$duplicateToolNameDemo".',
        );
        expect(
          transcript[2],
          'Caught WebMcpToolNotFoundException for tool '
          '"$missingToolNameDemo".',
        );
      },
    );

    test(
      'cleans up the duplicate probe tool so a second call is stable',
      () async {
        final List<String> first = await triggerAndCatchExceptions();
        final List<String> second = await triggerAndCatchExceptions();

        expect(second, first);
        expect(
          WebMcp.instance.tools.any(
            (WebMcpTool tool) => tool.name == duplicateToolNameDemo,
          ),
          isFalse,
        );
      },
    );
  });

  group('describeUnscopedLookup', () {
    testWidgets('reports no scope from a context with no screen ancestor', (
      WidgetTester tester,
    ) async {
      String? line;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (BuildContext context) {
              line = describeUnscopedLookup(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(line, 'Scope lookup: no scope found.');
    });

    testWidgets('reports the enclosing scope name when one exists', (
      WidgetTester tester,
    ) async {
      String? line;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: _ScopedHost(
            child: Builder(
              builder: (BuildContext context) {
                line = describeUnscopedLookup(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(line, startsWith('Scope lookup: found scope'));
    });
  });

  group('WebMcpAction scope requirement', () {
    testWidgets(
      'raises the missing-scope exception when built with no enclosing '
      'WebMcpScreen scope',
      (WidgetTester tester) async {
        const String toolName = 'example.exception.demo.unscoped';

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: WebMcpAction(
              name: toolName,
              description: 'Unscoped demo action.',
              onInvoke: (Map<String, Object?> arguments) => null,
              child: const SizedBox(),
            ),
          ),
        );

        final Object? exception = tester.takeException();
        expect(exception, isA<WebMcpScopeMissingException>());
        expect((exception as WebMcpScopeMissingException).toolName, toolName);
        expect(
          WebMcp.instance.tools.any((WebMcpTool tool) => tool.name == toolName),
          isFalse,
        );
      },
    );

    testWidgets(
      'raises nothing and registers its tool when built inside a screen scope',
      (WidgetTester tester) async {
        const String toolName = 'example.exception.demo.scoped';

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: _ScopedHost(
              child: WebMcpAction(
                name: toolName,
                description: 'Scoped demo action.',
                onInvoke: (Map<String, Object?> arguments) => null,
                child: const SizedBox(),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(
          WebMcp.instance.tools.any((WebMcpTool tool) => tool.name == toolName),
          isTrue,
        );
      },
    );
  });
}
