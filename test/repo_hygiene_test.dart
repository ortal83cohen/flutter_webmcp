import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Iterable<File> _dartFiles(String path) sync* {
  final Directory directory = Directory(path);
  if (!directory.existsSync()) {
    return;
  }
  yield* directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((File file) => file.path.endsWith('.dart'));
}

List<String> _matchingLines(File file, RegExp pattern) {
  final List<String> matches = <String>[];
  for (final String line in file.readAsLinesSync()) {
    if (pattern.hasMatch(line)) {
      matches.add('${file.path}: $line');
    }
  }
  return matches;
}

void main() {
  test('library and example sources avoid forbidden imports', () {
    final RegExp forbidden = RegExp(
      r'''^\s*import\s+['"](dart:html|dart:js|package:js(?:/[^'"]*)?|dart:io|package:http(?:/[^'"]*)?)['"]''',
    );
    final List<String> violations = <String>[];
    for (final String root in <String>['lib', 'example/lib']) {
      for (final File file in _dartFiles(root)) {
        violations.addAll(_matchingLines(file, forbidden));
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('Flutter imports stay inside the widget layer', () {
    final RegExp flutterImport = RegExp(
      r'''^\s*import\s+['"]package:flutter/''',
    );
    final List<String> violations = <String>[];
    for (final File file in _dartFiles('lib')) {
      if (!file.path.startsWith('lib/src/widgets/')) {
        violations.addAll(_matchingLines(file, flutterImport));
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('public and scope tests preserve their import boundaries', () {
    final String publicSource = File('test/webmcp_public_surface_test.dart')
        .readAsStringSync();
    final String scopeSource = File('test/webmcp_scope_test.dart')
        .readAsStringSync();
    expect(publicSource, isNot(contains('lib/src/')));
    expect(publicSource, isNot(contains('../lib/')));
    expect(publicSource, isNot(contains('package:webmcp_pilot/src/')));
    expect(scopeSource, isNot(contains('package:flutter_test/')));
    expect(scopeSource, isNot(contains('pumpWidget')));
  });

  test('implementation files contain no fixed secret markers', () async {
    final ProcessResult result = await Process.run(
      <String>[
        'git',
        'ls-files',
        '--cached',
        '--others',
        '--exclude-standard',
        '--',
        'lib',
        'example/lib',
        'tools',
        '.github',
      ].first,
      <String>[
        'ls-files',
        '--cached',
        '--others',
        '--exclude-standard',
        '--',
        'lib',
        'example/lib',
        'tools',
        '.github',
      ],
    );
    expect(result.exitCode, 0, reason: result.stderr.toString());
    final RegExp marker = RegExp(
      r'-----BEGIN PRIVATE KEY-----|AKIA[0-9A-Z]{16}|(?:application[_-]?key|app[_-]?key|password)\s*[:=]',
      caseSensitive: false,
    );
    final List<String> violations = <String>[];
    for (final String path
        in result.stdout
            .toString()
            .split('\n')
            .where((String path) => path.isNotEmpty)) {
      final File file = File(path);
      if (file.existsSync()) {
        violations.addAll(_matchingLines(file, marker));
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
