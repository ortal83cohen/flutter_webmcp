# Analyzer parser repair evidence

## Scope

This append-only artifact records the implementation of 09-parser-plan-amendment.md after its independent plan review passed. The source changes are limited to pubspec.yaml and test/repo_hygiene_test.dart. No file was staged, committed or pushed.

The root package now declares analyzer version ^13.3.0 directly as a development dependency. Import extraction uses the analyzer's public parseString, ImportDirective, Configuration and StringLiteral.stringValue APIs. The handwritten tokenization, comment traversal, quote scanning and escape decoding were removed completely. Parser diagnostics and unavailable string values surface as failures containing the source path. URI predicates, scan roots, the Flutter widget-directory exception and the full-text secret scanner remain unchanged.

## Dependency and focused verification

Commands: flutter pub get, dart format test/repo_hygiene_test.dart, dart analyze --fatal-infos --fatal-warnings, and flutter test test/repo_hygiene_test.dart, using Flutter 3.47.0.

Relevant verbatim output excerpts:

~~~text
Resolving dependencies...
  analyzer 13.3.0 (from transitive dependency to dev dependency) (14.3.0 available)
Changed 1 dependency!
Formatted test/repo_hygiene_test.dart
Formatted 1 file (1 changed) in 0.01 seconds.
Analyzing flutter_webmcp...
No issues found!
~~~

~~~text
00:00 +0: analyzer import extraction recognizes whitespace, comments, and conditional targets
00:00 +1: analyzer import extraction ignores exports, comments, strings, and conditional values
00:00 +2: analyzer import extraction uses compiler semantics for initial newlines in triple strings
00:00 +3: analyzer import extraction uses compiler semantics for encoded import URIs
00:00 +4: analyzer import extraction preserves raw ordinary literal content
00:00 +5: analyzer import extraction surfaces parser diagnostics with the source path
00:00 +6: analyzer import extraction classifies only the fixed forbidden import families
00:00 +7: secret detector fixtures matches every fixed header and the bare AWS prefix
00:00 +8: secret detector fixtures matches every assignment spelling and separator
00:00 +9: secret detector fixtures does not infer markers outside the exhaustive set
00:00 +10: library and example sources avoid forbidden imports
00:00 +11: Flutter imports stay inside the widget layer
00:00 +12: public and scope tests preserve their import boundaries
00:00 +13: implementation files contain no fixed secret markers
00:00 +14: All tests passed!
~~~

The fixtures cover ordinary and raw triple-quoted imports with an initial newline in both quote styles, fixed and braced Unicode escapes, hexadecimal escapes, whitespace, line/block/nested comments, conditional targets and raw ordinary strings. Controls establish that exports, commented directives, declaration strings and a conditional comparison value that happens to equal dart:io are not import targets. An invalid hexadecimal escape establishes that analyzer diagnostics fail with the supplied fixture path.

## Independent compilation of valid import syntax

The disposable snapshot /private/tmp/webmcp-parser-repair.GM7vgq was created from the stable implementation. A standalone Dart program imported dart:io through ordinary and raw initial-newline triple strings in both quote styles and through fixed Unicode, braced Unicode and hexadecimal encodings. The pinned SDK compiled and ran it:

~~~text
valid Dart import fixtures compiled
EXIT:0
~~~

A Flutter test imported package:flutter/widgets.dart through the same seven language representations. The pinned Flutter compiler accepted and ran the fixture:

~~~text
00:00 +0: loading /private/tmp/webmcp-parser-repair.GM7vgq/test/parser_flutter_compile_test.dart
00:00 +0: valid Flutter import fixtures compile
00:00 +1: All tests passed!
EXIT:0
~~~

These compilation checks were separate from the policy mutations. They prove the rejected representations were legal Dart and Flutter imports rather than parser-only malformed text.

## Isolated allowed controls

The disposable snapshot added a raw ordinary URI containing literal escape characters under example/lib/, a conditional import whose comparison value was dart:io but whose target was safe, an export and a declaration string lookalike. It also put a raw Flutter-like URI and text inside the permitted lib/src/widgets/ subtree. The focused hygiene test remained green:

~~~text
00:00 +10: library and example sources avoid forbidden imports
00:00 +11: Flutter imports stay inside the widget layer
00:00 +12: public and scope tests preserve their import boundaries
00:00 +13: implementation files contain no fixed secret markers
00:00 +14: All tests passed!
EXIT:0
~~~

## Isolated forbidden mutations

The same disposable snapshot then added legal imports under scanned, prohibited locations. Each probe file contained ordinary and raw initial-newline triple strings in both quote styles, fixed Unicode, braced Unicode, hexadecimal encoding, an intervening comment and a conditional target. The focused hygiene test exited 1 and reported the file path plus the analyzer-decoded URI for all nine Dart and all nine Flutter directives.

Relevant verbatim output excerpts:

~~~text
Actual: [
          'example/lib/parser_forbidden_dart_probe.dart: import dart:io',
          'example/lib/parser_forbidden_dart_probe.dart: import dart:io',
          'example/lib/parser_forbidden_dart_probe.dart: import dart:io',
          'example/lib/parser_forbidden_dart_probe.dart: import dart:io',
          'example/lib/parser_forbidden_dart_probe.dart: import dart:io',
          'example/lib/parser_forbidden_dart_probe.dart: import dart:io',
          'example/lib/parser_forbidden_dart_probe.dart: import dart:io',
          'example/lib/parser_forbidden_dart_probe.dart: import dart:io',
          'example/lib/parser_forbidden_dart_probe.dart: import dart:io'
        ]
example/lib/parser_forbidden_dart_probe.dart: import dart:io
~~~

~~~text
Actual: [
          'lib/src/parser_forbidden_flutter_probe.dart: import package:flutter/widgets.dart',
          'lib/src/parser_forbidden_flutter_probe.dart: import package:flutter/widgets.dart',
          'lib/src/parser_forbidden_flutter_probe.dart: import package:flutter/widgets.dart',
          'lib/src/parser_forbidden_flutter_probe.dart: import package:flutter/widgets.dart',
          'lib/src/parser_forbidden_flutter_probe.dart: import package:flutter/widgets.dart',
          'lib/src/parser_forbidden_flutter_probe.dart: import package:flutter/widgets.dart',
          'lib/src/parser_forbidden_flutter_probe.dart: import package:flutter/widgets.dart',
          'lib/src/parser_forbidden_flutter_probe.dart: import package:flutter/widgets.dart',
          'lib/src/parser_forbidden_flutter_probe.dart: import package:flutter/widgets.dart'
        ]
lib/src/parser_forbidden_flutter_probe.dart: import package:flutter/widgets.dart
00:00 +12 -2: Some tests failed.
EXPECTED_EXIT:1
~~~

The temporary fixtures were never copied into the working repository.

## Full verification

Command: PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH bash tools/check.sh. Exit status: 0.

Relevant verbatim output excerpts:

~~~text
Preflight: flutter and dart found
lint_wiki: clean (0 warning(s)).
Stage 1 passed: wiki lint
Stage 2 passed: dependencies
Formatted 23 files (0 changed) in 0.03 seconds.
Stage 3 passed: format
Analyzing flutter_webmcp...
No issues found!
Stage 4 passed: analysis
00:01 +39: All tests passed!
00:00 +1: All tests passed!
Stage 5 passed: tests
Compiling lib/main.dart for the Web...                             19.1s
✓ Built build/web
Stage 6 passed: build
EXIT:0
~~~

Remote GitHub Actions execution remains [UNVERIFIED] because no push was authorized. This parser repair changes no workflow or runtime behavior.
