# Hygiene scanner repair evidence

## Scope

This append-only artifact records the implementation and verification of `06-plan-amendment.md` and implementation-review findings F-001 through F-003. The only repair source file changed in this pass is `test/repo_hygiene_test.dart`. F-001 was already repaired in `test/webmcp_public_surface_test.dart`, which now explicitly names `WebMcpToolHandler`.

The repair tokenizes Dart source sufficiently to distinguish identifiers, string literals and semicolons while skipping line comments, nested block comments and string contents. It collects every URI in an import directive, including configured URIs in conditional imports. Export directives are not imports. The secret scan applies the amendment's exhaustive case-insensitive marker expression to each complete file rather than to individual lines.

No source file was staged, committed or pushed during this repair. All mutation probes ran in synthetic repositories under `/private/tmp`.

## Focused positive verification

Commands: `dart format test/repo_hygiene_test.dart`, `dart analyze --fatal-infos --fatal-warnings`, and `flutter test test/repo_hygiene_test.dart`.

Relevant verbatim output excerpt:

```text
Formatted 1 file (1 changed) in 0.01 seconds.
Analyzing flutter_webmcp...
No issues found!
00:00 +0: directive detector fixtures recognizes imports across whitespace and comments
00:00 +1: directive detector fixtures ignores exports, commented directives, and string contents
00:00 +2: directive detector fixtures classifies only the fixed forbidden import families
00:00 +3: secret detector fixtures matches every fixed header and the bare AWS prefix
00:00 +4: secret detector fixtures matches every assignment spelling and separator
00:00 +5: secret detector fixtures does not infer markers outside the exhaustive set
00:00 +6: library and example sources avoid forbidden imports
00:00 +7: Flutter imports stay inside the widget layer
00:00 +8: public and scope tests preserve their import boundaries
00:00 +9: implementation files contain no fixed secret markers
00:00 +10: All tests passed!
```

## Multiline import mutation

In `/private/tmp/webmcp-repair.IoVV0d`, nonignored Dart files placed a forbidden URI after a line comment, after a block comment, and placed a Flutter URI after an intervening block comment outside `lib/src/widgets/`. The focused test exited 1 and named each file and import.

Relevant verbatim output excerpt:

```text
Expected: empty
  Actual: [
            'example/lib/import_probe.dart: import dart:io',
            'example/lib/import_probe.dart: import package:http/http.dart'
          ]
example/lib/import_probe.dart: import dart:io
example/lib/import_probe.dart: import package:http/http.dart
Expected: empty
  Actual: ['lib/src/import_probe.dart: import package:flutter/widgets.dart']
lib/src/import_probe.dart: import package:flutter/widgets.dart
00:00 +8 -2: Some tests failed.
```

## Conditional import mutation

In `/private/tmp/webmcp-repair-conditional.IpPxXd`, `example/lib/conditional_probe.dart` used an allowed primary URI followed by a forbidden configured URI split across lines and an intervening comment. The focused test exited 1 and named the configured URI.

Relevant verbatim output excerpt:

```text
Expected: empty
  Actual: ['example/lib/conditional_probe.dart: import dart:io']
example/lib/conditional_probe.dart: import dart:io
00:00 +9 -1: Some tests failed.
```

## Allowed-directive probe

In `/private/tmp/webmcp-repair-allowed.sCn8aF`, the scan read a multiline Flutter import under `lib/src/widgets/`, a multiline `dart:async` import, an export of `dart:io`, and commented-out imports of `dart:io` and `package:http/http.dart`. The focused test exited 0.

Verbatim final output:

```text
00:00 +10: All tests passed!
```

## Exhaustive secret-marker mutation

In `/private/tmp/webmcp-repair.IoVV0d`, tracked non-Dart probes covered `lib/`, `example/lib/` and `tools/`; a nonignored untracked YAML probe covered `.github/`. The test read the complete files and exited 1. It reported all four key headers, the bare AWS prefix, every one of the seven assignment spellings with both separators, and mixed-case markers whose whitespace crossed a newline.

Relevant verbatim output excerpt:

```text
.github/secret_probe.yml: PaSsWoRd
  :
example/lib/secret_probe.yaml: AKIA
lib/secret_probe.txt: -----BEGIN PRIVATE KEY-----
lib/secret_probe.txt: -----BEGIN RSA PRIVATE KEY-----
lib/secret_probe.txt: -----BEGIN EC PRIVATE KEY-----
lib/secret_probe.txt: -----BEGIN OPENSSH PRIVATE KEY-----
tools/secret_probe.txt: application_key:
tools/secret_probe.txt: application_key=
tools/secret_probe.txt: application-key:
tools/secret_probe.txt: application-key=
tools/secret_probe.txt: applicationkey:
tools/secret_probe.txt: applicationkey=
tools/secret_probe.txt: app_key:
tools/secret_probe.txt: app_key=
tools/secret_probe.txt: app-key:
tools/secret_probe.txt: app-key=
tools/secret_probe.txt: appkey:
tools/secret_probe.txt: appkey=
tools/secret_probe.txt: password:
tools/secret_probe.txt: password=
tools/secret_probe.txt: ApPlIcAtIoN_KeY
  =
00:00 +9 -1: Some tests failed.
```

The in-file focused fixture separately asserted mixed-case matching and every spelling/separator combination. It also asserted that `application key`, `api_key` and `pass_word` remain outside the exhaustive set.

## Final full suite

Command: `bash tools/check.sh`, with Flutter 3.47.0 first on `PATH`. Exit status: 0.

Relevant verbatim output excerpt:

```text
Preflight: flutter and dart found
lint_wiki: clean (0 warning(s)).
Stage 1 passed: wiki lint
Stage 2 passed: dependencies
Formatted 23 files (0 changed) in 0.04 seconds.
Stage 3 passed: format
Analyzing flutter_webmcp...
No issues found!
Stage 4 passed: analysis
00:01 +35: All tests passed!
00:00 +1: All tests passed!
Stage 5 passed: tests
Compiling lib/main.dart for the Web... 16.3s
✓ Built build/web
Stage 6 passed: build
```

Final repository checks:

```text
lint_wiki: clean (0 warning(s)).
git diff --check: no output
test/webmcp_public_surface_test.dart:25: final WebMcpToolHandler typedHandler = handler;
```

The live GitHub Actions run remains `[UNVERIFIED]` because no push was authorized; this repair changes no CI behavior.
