import 'dart:js_interop';

import 'package:flutter/material.dart';

@JS('installWebMcpFixture')
external void installWebMcpFixture(
  JSFunction increment,
  JSFunction navigate,
  JSFunction remount,
);

void main() {
  runApp(const FixtureApp());
}

class FixtureApp extends StatefulWidget {
  const FixtureApp({super.key});

  @override
  State<FixtureApp> createState() => _FixtureAppState();
}

class _FixtureAppState extends State<FixtureApp> {
  int _counter = 0;
  int _mount = 1;
  String _page = 'home';

  @override
  void initState() {
    super.initState();
    installWebMcpFixture(_increment.toJS, _navigate.toJS, _remount.toJS);
  }

  JSNumber _increment() {
    setState(() {
      _counter++;
    });
    return _counter.toJS;
  }

  JSString _navigate(JSString destination) {
    setState(() {
      _page = destination.toDart;
      _mount++;
    });
    return _page.toJS;
  }

  JSNumber _remount() {
    setState(() {
      _mount++;
    });
    return _mount.toJS;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chrome WebMCP transport gate',
      home: Scaffold(
        appBar: AppBar(title: const Text('Chrome WebMCP transport gate')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('page=$_page', key: const ValueKey('page')),
              Text('mount=$_mount', key: const ValueKey('mount')),
              Text('counter=$_counter', key: const ValueKey('counter')),
              const SizedBox(height: 16),
              const SelectableText(
                'Fixture results are available in the browser evidence panel.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
