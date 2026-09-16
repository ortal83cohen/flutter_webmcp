import 'package:flutter/widgets.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';

/// Tool name used to demonstrate [WebMcpInvalidToolNameException].
///
/// The trailing space and exclamation mark violate the registry's naming
/// rule, which accepts only ASCII letters, digits, underscores, hyphens and
/// periods.
const String invalidToolNameDemo = 'example exception invalid!';

/// Tool name used to demonstrate [WebMcpDuplicateToolException].
const String duplicateToolNameDemo = 'example.exception.duplicate';

/// Tool name used to demonstrate [WebMcpToolNotFoundException].
///
/// This name is never registered anywhere in the example.
const String missingToolNameDemo = 'example.exception.missing';

WebMcpTool _inertTool(String name, String description) => WebMcpTool(
  name: name,
  description: description,
  handler: (Map<String, Object?> arguments) => null,
);

/// Triggers and catches, in order, an invalid tool name registration, a
/// duplicate tool registration and an invocation of a tool name that was
/// never registered, returning one transcript line per caught exception that
/// names the caught exception's runtime type and the offending tool name.
///
/// This is a plain, context-free `Future`-returning function: none of these
/// three exceptions require a [BuildContext], so all three are demonstrated
/// here in one place. The invocation of a missing tool is asynchronous
/// because [WebMcp.invokeTool] is declared `async`, so the
/// [WebMcpToolNotFoundException] it raises only surfaces through the
/// returned `Future`, not as a synchronous throw — hence this function
/// itself is `async`.
///
/// The fourth line described in the plan — reporting the outcome of a
/// [WebMcpScreen.maybeScopeOf] lookup performed from a context with no
/// enclosing [WebMcpScreen] — genuinely needs a `BuildContext`, which a plain
/// Dart function cannot manufacture on its own. That half of the
/// demonstration is exposed separately as [describeUnscopedLookup], a small
/// pure function over a caller-supplied context, so a widget test (or the
/// exception screen's own `build` method, which is deliberately not wrapped
/// in the [WebMcpScreen] mixin) can drive it with a context of its choosing.
///
/// The duplicate-registration probe cleans up the tool it registers before
/// returning, so calling this function more than once against the shared
/// registry produces the same three lines every time.
Future<List<String>> triggerAndCatchExceptions() async {
  final List<String> transcript = <String>[];

  try {
    WebMcp.instance.registerTool(
      _inertTool(invalidToolNameDemo, 'Deliberately invalid tool name.'),
    );
  } on WebMcpException catch (error) {
    transcript.add(_transcriptLine(error));
  }

  WebMcp.instance.registerTool(
    _inertTool(duplicateToolNameDemo, 'Registered once, ahead of the demo.'),
  );
  try {
    WebMcp.instance.registerTool(
      _inertTool(duplicateToolNameDemo, 'Duplicate registration for the demo.'),
    );
  } on WebMcpException catch (error) {
    transcript.add(_transcriptLine(error));
  } finally {
    WebMcp.instance.unregisterTool(duplicateToolNameDemo);
  }

  try {
    await WebMcp.instance.invokeTool(
      missingToolNameDemo,
      const <String, Object?>{},
    );
  } on WebMcpException catch (error) {
    transcript.add(_transcriptLine(error));
  }

  return transcript;
}

String _transcriptLine(WebMcpException error) =>
    'Caught ${error.runtimeType} for tool "${error.toolName}".';

/// Reports the outcome of a [WebMcpScreen.maybeScopeOf] lookup made from
/// [context], as the fourth transcript line described in the plan.
///
/// Passing a context with no enclosing [WebMcpScreen] state produces the
/// "no scope" line; passing a context inside such a state's subtree reports
/// that state's scope name instead.
String describeUnscopedLookup(BuildContext context) {
  final WebMcpScope? scope = WebMcpScreen.maybeScopeOf(context);
  if (scope == null) {
    return 'Scope lookup: no scope found.';
  }
  return 'Scope lookup: found scope ${scope.scopeName}.';
}
