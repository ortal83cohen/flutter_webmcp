import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_test/flutter_test.dart';

Iterable<File> _dartFiles(String directoryPath) sync* {
  final Directory directory = Directory(directoryPath);
  if (!directory.existsSync()) return;
  yield* directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((File file) => file.path.endsWith('.dart'));
}

List<String> _importUris(String source, {String path = 'fixture.dart'}) {
  final result = parseString(
    content: source,
    path: path,
    throwIfDiagnostics: false,
  );
  if (result.errors.isNotEmpty) {
    throw FormatException(
      'Unable to inspect imports in $path:\n${result.errors.join('\n')}',
    );
  }

  final List<String> uris = <String>[];
  for (final ImportDirective directive
      in result.unit.directives.whereType<ImportDirective>()) {
    _addUri(uris, directive.uri, path);
    for (final Configuration configuration in directive.configurations) {
      _addUri(uris, configuration.uri, path);
    }
  }
  return uris;
}

void _addUri(List<String> uris, StringLiteral literal, String path) {
  final String? value = literal.stringValue;
  if (value == null) {
    throw FormatException(
      'Unable to inspect import URI in $path at offset ${literal.offset}.',
    );
  }
  uris.add(value);
}

bool _isForbiddenImport(String uri) =>
    uri == 'dart:html' ||
    uri.startsWith('dart:html/') ||
    uri == 'dart:js' ||
    uri.startsWith('dart:js/') ||
    uri == 'package:js' ||
    uri.startsWith('package:js/') ||
    uri == 'dart:io' ||
    uri.startsWith('dart:io/') ||
    uri == 'package:http' ||
    uri.startsWith('package:http/');

List<String> _importViolations(File file, bool Function(String uri) rejects) =>
    _importUris(
      file.readAsStringSync(),
      path: file.path,
    ).where(rejects).map((String uri) => '${file.path}: import $uri').toList();

final RegExp _secretMarker = RegExp(
  r'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----|AKIA|(?:application_key|application-key|applicationkey|app_key|app-key|appkey|password)\s*[:=]',
  caseSensitive: false,
);

List<String> _secretViolations(File file) => _secretMarker
    .allMatches(file.readAsStringSync())
    .map((RegExpMatch match) => '${file.path}: ${match.group(0)}')
    .toList();

void main() {
  group('analyzer import extraction', () {
    test('recognizes whitespace, comments, and conditional targets', () {
      const String source = '''
import
  // line comment
  'dart:io';
import /* block comment */ 'package:flutter/widgets.dart';
import /* outer /* nested */ comment */
  'package:http/http.dart';
import 'dart:async'
  if (dart.library.io) 'dart:io';
''';
      expect(_importUris(source), <String>[
        'dart:io',
        'package:flutter/widgets.dart',
        'package:http/http.dart',
        'dart:async',
        'dart:io',
      ]);
    });

    test('ignores exports, comments, strings, and conditional values', () {
      const String source = '''
export 'dart:io';
import 'dart:async'
  if (dart.library.io == 'dart:io') 'package:safe/safe.dart';
// import 'dart:html';
/* import 'package:http/http.dart'; */
const text = "import 'dart:js';";
''';
      expect(_importUris(source), <String>[
        'dart:async',
        'package:safe/safe.dart',
      ]);
    });

    test('uses compiler semantics for initial newlines in triple strings', () {
      final String source =
          "import '''\ndart:io''';\n"
          'import """\npackage:flutter/widgets.dart""";\n'
          "import r'''\ndart:io''';\n"
          'import r"""\npackage:flutter/widgets.dart""";\n';
      expect(_importUris(source), <String>[
        'dart:io',
        'package:flutter/widgets.dart',
        'dart:io',
        'package:flutter/widgets.dart',
      ]);
    });

    test('uses compiler semantics for encoded import URIs', () {
      const String source = r'''
import 'dart:\u0069o';
import 'dart:\u{69}o';
import 'dart:\x69o';
import 'package:\u0066lutter/widgets.dart';
import 'package:\u{66}lutter/widgets.dart';
import 'package:\x66lutter/widgets.dart';
''';
      expect(_importUris(source), <String>[
        'dart:io',
        'dart:io',
        'dart:io',
        'package:flutter/widgets.dart',
        'package:flutter/widgets.dart',
        'package:flutter/widgets.dart',
      ]);
    });

    test('preserves raw ordinary literal content', () {
      const String source = r'''
import r'dart:\u0069o';
import r"package:\x66lutter/widgets.dart";
''';
      expect(_importUris(source), <String>[
        r'dart:\u0069o',
        r'package:\x66lutter/widgets.dart',
      ]);
    });

    test('surfaces parser diagnostics with the source path', () {
      expect(
        () => _importUris(
          r"import 'dart:\xG1o';",
          path: 'invalid-import-fixture.dart',
        ),
        throwsA(
          isA<FormatException>().having(
            (FormatException error) => error.message,
            'message',
            contains('invalid-import-fixture.dart'),
          ),
        ),
      );
    });

    test('classifies only the fixed forbidden import families', () {
      expect(_isForbiddenImport('dart:io'), isTrue);
      expect(_isForbiddenImport('package:http/http.dart'), isTrue);
      expect(_isForbiddenImport('dart:async'), isFalse);
      expect(_isForbiddenImport('package:flutter/widgets.dart'), isFalse);
    });
  });

  group('secret detector fixtures', () {
    test('matches every fixed header and the bare AWS prefix', () {
      const List<String> markers = <String>[
        '-----BEGIN PRIVATE KEY-----',
        '-----BEGIN RSA PRIVATE KEY-----',
        '-----BEGIN EC PRIVATE KEY-----',
        '-----BEGIN OPENSSH PRIVATE KEY-----',
        'AKIA',
      ];
      for (final String marker in markers) {
        expect(_secretMarker.hasMatch(marker), isTrue, reason: marker);
      }
    });

    test('matches every assignment spelling and separator', () {
      const List<String> names = <String>[
        'application_key',
        'application-key',
        'applicationkey',
        'app_key',
        'app-key',
        'appkey',
        'password',
      ];
      for (final String name in names) {
        for (final String separator in <String>[':', '=']) {
          expect(
            _secretMarker.hasMatch('$name\n  $separator'),
            isTrue,
            reason: '$name $separator',
          );
        }
      }
      expect(_secretMarker.hasMatch('ApPlIcAtIoN_KeY ='), isTrue);
    });

    test('does not infer markers outside the exhaustive set', () {
      expect(_secretMarker.hasMatch('application key ='), isFalse);
      expect(_secretMarker.hasMatch('api_key ='), isFalse);
      expect(_secretMarker.hasMatch('pass_word ='), isFalse);
    });
  });

  test('library and example sources avoid forbidden imports', () {
    final List<String> violations = <String>[];
    for (final String root in <String>['lib', 'example/lib']) {
      for (final File file in _dartFiles(root)) {
        violations.addAll(_importViolations(file, _isForbiddenImport));
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('Flutter imports stay inside Flutter-facing layers', () {
    final List<String> violations = <String>[];
    for (final File file in _dartFiles('lib')) {
      if (!file.path.startsWith('lib/src/widgets/') &&
          !file.path.startsWith('lib/src/page/')) {
        violations.addAll(
          _importViolations(
            file,
            (String uri) => uri.startsWith('package:flutter/'),
          ),
        );
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('public and scope tests preserve their import boundaries', () {
    final List<String> publicImports = _importUris(
      File('test/webmcp_public_surface_test.dart').readAsStringSync(),
      path: 'test/webmcp_public_surface_test.dart',
    );
    final List<String> scopeImports = _importUris(
      File('test/webmcp_scope_test.dart').readAsStringSync(),
      path: 'test/webmcp_scope_test.dart',
    );
    expect(
      publicImports.where(
        (String uri) =>
            uri.startsWith('package:webmcp_flutter/src/') ||
            uri.contains('lib/src/'),
      ),
      isEmpty,
    );
    expect(
      scopeImports.where(
        (String uri) => uri.startsWith('package:flutter_test/'),
      ),
      isEmpty,
    );
    expect(
      File('test/webmcp_scope_test.dart').readAsStringSync(),
      isNot(contains('pumpWidget')),
    );
  });

  test('implementation files contain no fixed secret markers', () async {
    final ProcessResult result = await Process.run('git', <String>[
      'ls-files',
      '--cached',
      '--others',
      '--exclude-standard',
      '--',
      'lib',
      'example/lib',
      'packages',
      'tools',
      '.github',
    ]);
    expect(result.exitCode, 0, reason: result.stderr.toString());
    final List<String> violations = <String>[];
    for (final String filePath
        in result.stdout
            .toString()
            .split('\n')
            .where((String path) => path.isNotEmpty)) {
      final File file = File(filePath);
      if (file.existsSync()) {
        violations.addAll(_secretViolations(file));
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
