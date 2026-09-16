import 'package:flutter/material.dart';
import 'package:webmcp_flutter/webmcp_flutter.dart';

import 'example_diagnostics_screen.dart';
import 'example_exception_screen.dart';
import 'example_form_screen.dart';
import 'example_runtime.dart';

/// The application's home screen.
///
/// Displays the unfiltered tool list with the tool-line-format markers, the
/// screen scope's owned and skipped names, a positive
/// [WebMcpScreen.maybeScopeOf] lookup made from a [Builder] inside this
/// subtree, the most recent registry-observer log lines, the live task
/// list, buttons that invoke individual tools by name, a button that
/// invokes this page's own read endpoint, navigation to the three other
/// demonstration screens, and the pre-existing details route.
///
/// Takes the runtime as its single required argument. It no longer
/// registers the two imperative counter tools from `initState`: the
/// runtime's `install()` already registered them at application level, so
/// registering them again here would only be a second, duplicate attempt.
final class ExampleScreen extends StatefulWidget {
  /// Creates the home screen over [runtime].
  const ExampleScreen({required this.runtime, super.key});

  /// The runtime this screen reads and drives.
  final ExampleRuntime runtime;

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

final class _ExampleScreenState extends State<ExampleScreen>
    with WebMcpScreen<ExampleScreen> {
  String? _homeReadResult;
  String? _lastInvocationResult;

  @override
  void initState() {
    super.initState();
    // The registry log notifies on every registration and unregistration,
    // including the ones this screen cannot observe synchronously from its
    // own build — the home page's `.page.read`/`.page.act` endpoints, which
    // register asynchronously once the page's first capture completes, and
    // any registration or unregistration caused by navigating to another
    // page. Rebuilding on every log change keeps the rendered tool list,
    // and the owned/skipped lists derived from it, in sync with the
    // registry rather than frozen at the widget's first build.
    widget.runtime.registryLog.addListener(_onRegistryChanged);
  }

  @override
  void dispose() {
    widget.runtime.registryLog.removeListener(_onRegistryChanged);
    super.dispose();
  }

  void _onRegistryChanged() {
    if (!mounted) {
      return;
    }
    // The registry can notify synchronously while a widget further down
    // this very subtree is still building (for example, `WebMcpAction`'s
    // first registration, made from its own `didChangeDependencies` during
    // the initial mount). Calling `setState` right then would hit "setState
    // called during build", so the rebuild is deferred to the next frame.
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void registerWebMcpTools() {
    mcpScope.addTool(
      WebMcpTool(
        name: 'example.screen.describe',
        description: 'Describes the active example screen.',
        handler: (Map<String, Object?> arguments) => 'ExampleScreen',
      ),
    );
    // Deliberate duplicate: `example.counter.read` is already owned by the
    // application (registered by `registerExampleTools` during
    // `ExampleRuntime.install()`), so this second attempt is skipped by the
    // scope rather than raising, which is what populates the skipped-name
    // list this screen renders below.
    mcpScope.addTool(
      WebMcpTool(
        name: 'example.counter.read',
        description: 'Deliberate duplicate demonstrating skip-on-duplicate.',
        handler: (Map<String, Object?> arguments) =>
            widget.runtime.counter.value,
      ),
    );
  }

  void _increment() {
    setState(widget.runtime.counter.increment);
  }

  Future<void> _invoke(String name, Map<String, Object?> arguments) async {
    final Object? result = await WebMcp.instance.invokeTool(name, arguments);
    if (!mounted) {
      return;
    }
    setState(() {
      _lastInvocationResult = '$name -> $result';
    });
  }

  Future<void> _readHomePage() async {
    final Object? result = await WebMcp.instance.invokeTool(
      'example.home.page.read',
      const <String, Object?>{},
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _homeReadResult = _formatReadResult(result as Map<String, Object?>);
    });
  }

  static String _formatReadResult(Map<String, Object?> response) {
    final List<String> lines = <String>['ok: ${response['ok']}'];
    if (response.containsKey('code')) {
      lines.add('code: ${response['code']}');
    }
    final Object? nodes = response['nodes'];
    if (nodes is List) {
      lines.add('nodes: ${nodes.length}');
    }
    return lines.join('\n');
  }

  static String _toolLine(WebMcpTool tool) {
    final List<String> markers = <String>[
      if (tool.annotations.readOnlyHint) 'ro',
      if (tool.annotations.untrustedContentHint) 'uc',
      if (tool.annotations.consequentialHint) 'cq',
      if (tool.inputSchema.isNotEmpty) 'schema',
    ];
    if (markers.isEmpty) {
      return tool.name;
    }
    return '${tool.name} ${markers.map((String marker) => '[$marker]').join()}';
  }

  List<Widget> _toolRows() {
    return <Widget>[
      for (final WebMcpTool tool in WebMcp.instance.tools)
        Text(_toolLine(tool), key: ValueKey<String>('tool.${tool.name}')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WebMcpPage(
      pageId: 'example.home',
      child: Scaffold(
        appBar: AppBar(title: const Text('WebMCP Flutter')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Counter: ${widget.runtime.counter.value}'),
              Text('Transport: ${WebMcp.instance.transportId}'),
              const SizedBox(height: 16),
              const Text('Registered tools:'),
              ..._toolRows(),
              const SizedBox(height: 16),
              Text(
                'Owned: ${mcpScope.ownedNames.join(', ')}',
                key: const ValueKey<String>('ownedNames'),
              ),
              Text(
                'Skipped: ${mcpScope.skippedNames.join(', ')}',
                key: const ValueKey<String>('skippedNames'),
              ),
              const SizedBox(height: 16),
              Builder(
                builder: (BuildContext innerContext) {
                  final WebMcpScope? scope = WebMcpScreen.maybeScopeOf(
                    innerContext,
                  );
                  return Text(
                    'Scope lookup: ${scope?.scopeName ?? 'no scope'}',
                    key: const ValueKey<String>('scopeLookup'),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text('Recent registry log:'),
              Text(
                widget.runtime.registryLog.lines.join('\n'),
                key: const ValueKey<String>('registryLog'),
              ),
              const SizedBox(height: 16),
              const Text('Tasks:'),
              Text(
                widget.runtime.taskService.tasks.join(', '),
                key: const ValueKey<String>('taskList'),
              ),
              const SizedBox(height: 16),
              WebMcpAction(
                name: 'example.screen.increment',
                description: 'Increments the visible example counter.',
                onInvoke: (Map<String, Object?> arguments) {
                  _increment();
                  return widget.runtime.counter.value;
                },
                child: ElevatedButton(
                  onPressed: _increment,
                  child: const Text('Increment'),
                ),
              ),
              ElevatedButton(
                onPressed: () => _invoke(
                  'example.source.counter.add',
                  const <String, Object?>{'amount': 1},
                ),
                child: const Text('Invoke source add'),
              ),
              ElevatedButton(
                onPressed: () =>
                    _invoke('example.tasks.list', const <String, Object?>{}),
                child: const Text('Invoke tasks list'),
              ),
              if (_lastInvocationResult != null)
                Text(
                  _lastInvocationResult!,
                  key: const ValueKey<String>('lastInvocationResult'),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _readHomePage,
                child: const Text('Read home page'),
              ),
              if (_homeReadResult != null)
                Text(
                  _homeReadResult!,
                  key: const ValueKey<String>('homeReadResult'),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          const _ExampleDetailsPage(),
                    ),
                  );
                },
                child: const Text('Open details'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          const ExampleFormScreen(),
                    ),
                  );
                },
                child: const Text('Open form'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          ExampleDiagnosticsScreen(runtime: widget.runtime),
                    ),
                  );
                },
                child: const Text('Open diagnostics'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          const ExampleExceptionScreen(),
                    ),
                  );
                },
                child: const Text('Open exceptions'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _ExampleDetailsPage extends StatelessWidget {
  const _ExampleDetailsPage();

  @override
  Widget build(BuildContext context) {
    return WebMcpPage(
      pageId: 'example.details',
      child: Scaffold(
        appBar: AppBar(title: const Text('Details')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Return home'),
          ),
        ),
      ),
    );
  }
}
