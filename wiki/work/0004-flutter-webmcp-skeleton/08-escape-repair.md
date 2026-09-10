# Escaped import URI repair evidence

## Scope

This append-only artifact records the implementation repair for F-001 in `validation/impl-review-02.md`. The only source file changed is `test/repo_hygiene_test.dart`. No source file was staged, committed or pushed.

The Dart string reader now distinguishes ordinary strings from `r` and `R` raw strings. Ordinary strings decode Dart's fixed four-digit Unicode escapes, braced Unicode scalar escapes, two-digit hexadecimal escapes, standard control escapes, escaped quotes, escaped backslashes and escaped dollar signs. Raw strings preserve backslashes. Invalid hexadecimal, Unicode and unknown escape forms remain undecoded, so the scanner does not reinterpret invalid Dart syntax as a forbidden URI.

## Focused verification

Commands: `dart format test/repo_hygiene_test.dart`, `dart analyze --fatal-infos --fatal-warnings`, and `flutter test test/repo_hygiene_test.dart`.

Relevant verbatim output excerpt:

```text
Formatted 1 file (1 changed) in 0.01 seconds.
Analyzing flutter_webmcp...
No issues found!
00:00 +0: directive detector fixtures recognizes imports across whitespace and comments
00:00 +1: directive detector fixtures ignores exports, commented directives, and string contents
00:00 +2: directive detector fixtures classifies only the fixed forbidden import families
00:00 +3: directive detector fixtures decodes valid hex and Unicode escapes in import URIs
00:00 +4: directive detector fixtures decodes standard Dart string escapes
00:00 +5: directive detector fixtures preserves escapes in raw import strings
00:00 +6: directive detector fixtures does not decode invalid Dart escapes as forbidden URIs
00:00 +7: secret detector fixtures matches every fixed header and the bare AWS prefix
00:00 +8: secret detector fixtures matches every assignment spelling and separator
00:00 +9: secret detector fixtures does not infer markers outside the exhaustive set
00:00 +10: library and example sources avoid forbidden imports
00:00 +11: Flutter imports stay inside the widget layer
00:00 +12: public and scope tests preserve their import boundaries
00:00 +13: implementation files contain no fixed secret markers
00:00 +14: All tests passed!
```

The focused fixtures assert that each of `\u0069`, `\u{69}` and `\x69` resolves to the `i` in `dart:io`, and each of `\u0066`, `\u{66}` and `\x66` resolves to the `f` in `package:flutter/widgets.dart`. Separate fixtures cover standard escapes, both quote forms, backslashes and dollar signs. Raw `r` and `R` import strings retain their literal escape sequences. Short Unicode, out-of-range Unicode, invalid hexadecimal and unknown escapes do not become forbidden URIs.

## Isolated real-directive mutation

The disposable repository `/private/tmp/webmcp-escape-repair.rCnfAF` contained six valid escaped import directives: three equivalent forms of `dart:io` under `example/lib/` and three equivalent forms of `package:flutter/widgets.dart` under `lib/src/`. The focused hygiene test exited 1 and reported the decoded URI and offending path for every directive.

Relevant verbatim output excerpt:

```text
Expected: empty
  Actual: [
            'example/lib/escaped_import_probe.dart: import dart:io',
            'example/lib/escaped_import_probe.dart: import dart:io',
            'example/lib/escaped_import_probe.dart: import dart:io'
          ]
example/lib/escaped_import_probe.dart: import dart:io
example/lib/escaped_import_probe.dart: import dart:io
example/lib/escaped_import_probe.dart: import dart:io
Expected: empty
  Actual: [
            'lib/src/escaped_flutter_probe.dart: import package:flutter/widgets.dart',
            'lib/src/escaped_flutter_probe.dart: import package:flutter/widgets.dart',
            'lib/src/escaped_flutter_probe.dart: import package:flutter/widgets.dart'
          ]
lib/src/escaped_flutter_probe.dart: import package:flutter/widgets.dart
lib/src/escaped_flutter_probe.dart: import package:flutter/widgets.dart
lib/src/escaped_flutter_probe.dart: import package:flutter/widgets.dart
00:00 +12 -2: Some tests failed.
```

The isolated files were never copied back to the working repository.

## Final full suite

Command: `bash tools/check.sh`, with Flutter 3.47.0 first on `PATH`. Exit status: 0.

Relevant verbatim output excerpt:

```text
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
Compiling lib/main.dart for the Web... 17.7s
Built build/web
Stage 6 passed: build
```

The GitHub Actions run remains `[UNVERIFIED]` because no push was authorized. This repair changes no workflow behavior.

## Dart parser confirmation

A disposable Dart file containing every decoded standard, hexadecimal and Unicode escape was checked with the pinned SDK's analyzer. This confirms the focused fixture's accepted escape set reflects valid Dart syntax rather than invented forms.

```text
Analyzing dart_escape_valid.dart...
No issues found!
```
