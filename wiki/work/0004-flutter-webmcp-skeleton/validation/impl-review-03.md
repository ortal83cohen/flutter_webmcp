---
id: 0004-impl-review-03
title: Flutter WebMCP skeleton implementation review round 03
status: active
owner: validator
last_verified: 2026-09-10
applies_to: ["lib/**", "test/**", "example/**", "tools/check.sh"]
summary: Independent escape repair validation finds that valid triple-quoted import URIs with an initial newline still bypass hygiene boundaries.
---

# Implementation review — round 03

- Work item: 0004-flutter-webmcp-skeleton
- Reviewed artifact: current implementation, with only test/repo_hygiene_test.dart changed since independent round 02.
- Reviewer: independent escape_final_validator subagent
- Date: 2026-09-10
- Inputs: frozen 02-criteria.md, normative 06-plan-amendment.md, source artifact/diff, validation rubric/template, and prior independent impl-review-01.md/impl-review-02.md for unchanged evidence and recurrence. Author 04/05/07/08 notes and transcript were not read. STATE.yaml was read as required by the repository router; its assertions were not used as evidence.

## Verdict

**FAIL**

AC-018 and AC-044 remain unmet for valid triple-quoted import URIs whose opening delimiter is followed by a newline. Ordinary Unicode/hex escape decoding now works. Forty-four criteria pass; the permitted live CI portion of AC-026 remains pending. The real full suite passes, but the valid negative imports below also pass when they must fail.

## Verification performed

All new commands and probes below were independently executed. Flutter commands prepend /Users/ortalcohen/fvm/versions/3.47.0/bin to PATH. Source mutations occurred only in /private/tmp/webmcp-review03-vru1vqnw with an isolated Git index; each mutation was restored. No real source changes, staging, commit or push were performed by this validator. The exact supplied license holder is flutter_webmcp; live browser execution and GitHub Actions were not exercised.

### Real checkout full suite

Command: `PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH /usr/bin/time -p bash tools/check.sh`.

The initial sandbox attempt stopped at dependency resolution because SDK cache writes were denied. Output:

```text
Preflight: flutter and dart found
lint_wiki: clean (0 warning(s)).
Stage 1 passed: wiki lint
/Users/ortalcohen/fvm/versions/3.47.0/bin/internal/update_engine_version.sh: line 71: /Users/ortalcohen/fvm/versions/3.47.0/bin/cache/engine.stamp.tmp.94441: Operation not permitted
/Users/ortalcohen/fvm/versions/3.47.0/bin/internal/update_engine_version.sh: line 78: /Users/ortalcohen/fvm/versions/3.47.0/bin/cache/engine.realm: Operation not permitted
Stage 2 failed: dependencies
real 0.13
user 0.05
sys 0.03
```

The same command with approved SDK cache access exited 0. Exact output:

```text
Preflight: flutter and dart found
lint_wiki: clean (0 warning(s)).
Stage 1 passed: wiki lint
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 103.0.0 (107.0.0 available)
  analyzer 13.3.0 (14.3.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  package_config 2.2.0 (3.0.0 available)
  test 1.31.1 (1.32.0 available)
  test_api 0.7.12 (0.7.14 available)
  test_core 0.6.18 (0.6.20 available)
Got dependencies!
7 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Resolving dependencies in `./example`...
Downloading packages...
Got dependencies in `./example`.
Resolving dependencies...
Downloading packages...
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
Got dependencies!
2 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Stage 2 passed: dependencies
Formatted 23 files (0 changed) in 0.03 seconds.
Stage 3 passed: format
Analyzing flutter_webmcp...
No issues found!
Stage 4 passed: analysis
00:00 +0: loading /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart
00:00 +0: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: registers tools and lists them in ascending order
00:00 +1: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +2: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: registers sources through duplicate validation
00:00 +3: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: rejects duplicates without replacing the first handler
00:00 +4: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: validates empty, long, and unsupported names
00:00 +5: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: passes arguments through and awaits the handler
00:00 +6: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: throws for a missing tool without invoking another handler
00:00 +7: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: unregister is idempotent
00:00 +8: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +9: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action registers verbatim and unregisters independently
00:00 +10: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +11: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action forwards invocation to the latest callback
00:00 +12: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action keeps its mounted descriptor identity until replacement
00:00 +13: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action copies its input schema
00:00 +14: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
00:00 +15: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: duplicate actions preserve the first owner
00:00 +16: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: invalid action names fail loudly
00:00 +17: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: directive detector fixtures recognizes imports across whitespace and comments
00:00 +18: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: directive detector fixtures ignores exports, commented directives, and string contents
00:00 +19: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: directive detector fixtures classifies only the fixed forbidden import families
00:00 +20: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: directive detector fixtures decodes valid hex and Unicode escapes in import URIs
00:00 +21: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: selects noop on the Dart VM and resets transport
00:00 +22: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: selects noop on the Dart VM and resets transport
00:00 +23: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: selects noop on the Dart VM and resets transport
00:00 +24: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: selects noop on the Dart VM and resets transport
00:00 +25: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: selects noop on the Dart VM and resets transport
00:00 +26: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: selects noop on the Dart VM and resets transport
00:00 +27: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: selects noop on the Dart VM and resets transport
00:00 +28: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:00 +29: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:00 +30: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: Flutter imports stay inside the widget layer
00:00 +31: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: public and scope tests preserve their import boundaries
00:00 +32: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: implementation files contain no fixed secret markers
00:00 +33: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_public_surface_test.dart: exports the complete public API and seven registry operations
00:01 +34: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: adds direct and source tools, then closes
00:01 +35: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: skips duplicates and never removes another owner
00:01 +36: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: remove is limited to names owned by the scope
00:01 +37: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: close is idempotent and closed scopes reject additions
00:01 +38: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: invalid names propagate without becoming owned or skipped
00:01 +39: All tests passed!
00:00 +0: loading /Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/test/example_tools_test.dart
00:00 +0: registers two imperative tools and increments the counter
00:00 +1: All tests passed!
Stage 5 passed: tests
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 7736 bytes (99.5% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             17.2s
✓ Built build/web
Stage 6 passed: build
real 28.55
user 29.72
sys 4.38
```

### Unchanged independent evidence

Command: Python byte comparison of all 36 implementation/configuration files against /private/tmp/webmcp-final-validator-q4sry1vf, then substring byte comparisons of the marker recognizer and complete marker scan. The compared roots were lib, test, example/lib, example/test and .github/workflows; additional files were tools/check.sh, tools/lint_wiki.py, both manifests/options, example/web/index.html, .gitignore, AGENTS.md, README.md, CHANGELOG.md and LICENSE. Exit 0. Exact output:

```text
Files compared: 36
Changed since independent round 02: ['test/repo_hygiene_test.dart']
marker recognizer byte-identical: True
marker scan byte-identical: True
```

Unchanged criterion negatives are reused explicitly from independent round 01, with its exact command/output line citations in the table. Public export-removal negatives and the exhaustive 52-marker/208-path campaign are reused from independent round 02. The 400-second delay was not repeated. Source comparison establishes that the relevant unchanged code and tests remain the same; this report does not rely on the author's evidence.

### Escaped URI and regression matrix

Command: `python3 /private/tmp/webmcp_review03_probes.py`; each case runs `flutter test --reporter expanded test/repo_hygiene_test.dart` in the isolated snapshot. Exit 0. The script tests fixed-four-digit Unicode, braced Unicode and two-digit hex escapes in dart:io under both source roots and package:flutter/widgets.dart outside the widget layer. It also tests multiline, nested-comment and conditional directives; raw and doubled-backslash controls; the widget exception; non-directive text; tracked YAML and non-Dart secret markers; and escaped public/scope boundary imports. Every forbidden case checks the actual path and decoded URI or marker in reporter output. Raw escaped controls are text-scanner controls, not claims that those raw URI spellings resolve as libraries.

Exact matrix command output:

```text
baseline: exit=0, expected_failure=False, diagnostics_verified=True
u4-lib: exit=1, expected_failure=True, diagnostics_verified=True
  lib/validation_escape.dart: import dart:io
u4-example-lib: exit=1, expected_failure=True, diagnostics_verified=True
  example/lib/validation_escape.dart: import dart:io
ubraces-lib: exit=1, expected_failure=True, diagnostics_verified=True
  lib/validation_escape.dart: import dart:io
ubraces-example-lib: exit=1, expected_failure=True, diagnostics_verified=True
  example/lib/validation_escape.dart: import dart:io
x2-lib: exit=1, expected_failure=True, diagnostics_verified=True
  lib/validation_escape.dart: import dart:io
x2-example-lib: exit=1, expected_failure=True, diagnostics_verified=True
  example/lib/validation_escape.dart: import dart:io
flutter-u4: exit=1, expected_failure=True, diagnostics_verified=True
  lib/validation_escape.dart: import package:flutter/widgets.dart
flutter-ubraces: exit=1, expected_failure=True, diagnostics_verified=True
  lib/validation_escape.dart: import package:flutter/widgets.dart
flutter-x2: exit=1, expected_failure=True, diagnostics_verified=True
  lib/validation_escape.dart: import package:flutter/widgets.dart
multiline: exit=1, expected_failure=True, diagnostics_verified=True
  example/lib/validation_escape.dart: import dart:html
nested-comment: exit=1, expected_failure=True, diagnostics_verified=True
  example/lib/validation_escape.dart: import package:http/http.dart
conditional: exit=1, expected_failure=True, diagnostics_verified=True
  example/lib/validation_escape.dart: import dart:io
flutter-comment: exit=1, expected_failure=True, diagnostics_verified=True
  lib/validation_escape.dart: import package:flutter/widgets.dart
raw-control: exit=0, expected_failure=False, diagnostics_verified=True
double-backslash-control: exit=0, expected_failure=False, diagnostics_verified=True
widget-allowed: exit=0, expected_failure=False, diagnostics_verified=True
non-directives: exit=0, expected_failure=False, diagnostics_verified=True
aws: exit=1, expected_failure=True, diagnostics_verified=True
  .github/workflows/checks.yml
  AKIA
private-key: exit=1, expected_failure=True, diagnostics_verified=True
  lib/validation_marker.txt
  -----BEGIN
  OPENSSH
  PRIVATE
  KEY-----
assignment: exit=1, expected_failure=True, diagnostics_verified=True
  tools/validation_marker
  Application_Key
  :
private-test-import: exit=1, expected_failure=True, diagnostics_verified=True
  package:webmcp_pilot/src/webmcp.dart
scope-test-import: exit=1, expected_failure=True, diagnostics_verified=True
  package:flutter_test/flutter_test.dart
restored: exit=0, expected_failure=False, diagnostics_verified=True
Snapshot: /private/tmp/webmcp-review03-vru1vqnw
Cases: 24
All outcomes and diagnostics verified: True
```

Representative exact negative reporter output (fixed Unicode dart:io in lib):

```text
00:00 +0: loading /private/tmp/webmcp-review03-vru1vqnw/test/repo_hygiene_test.dart
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
00:00 +10 -1: library and example sources avoid forbidden imports [E]
  Expected: empty
    Actual: ['lib/validation_escape.dart: import dart:io']
  lib/validation_escape.dart: import dart:io
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 415:5                   main.<fn>
  
00:00 +10 -1: Flutter imports stay inside the widget layer
00:00 +11 -1: public and scope tests preserve their import boundaries
00:00 +12 -1: implementation files contain no fixed secret markers
00:00 +13 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-review03-vru1vqnw/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
```

Representative exact negative reporter output (hex Flutter URI):

```text
00:00 +0: loading /private/tmp/webmcp-review03-vru1vqnw/test/repo_hygiene_test.dart
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
00:00 +11 -1: Flutter imports stay inside the widget layer [E]
  Expected: empty
    Actual: ['lib/validation_escape.dart: import package:flutter/widgets.dart']
  lib/validation_escape.dart: import package:flutter/widgets.dart
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 430:5                   main.<fn>
  
00:00 +11 -1: public and scope tests preserve their import boundaries
00:00 +12 -1: implementation files contain no fixed secret markers
00:00 +13 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-review03-vru1vqnw/test/repo_hygiene_test.dart: Flutter imports stay inside the widget layer
```

### Independent Dart semantics and remaining initial-newline bypass

Command: `/Users/ortalcohen/fvm/versions/3.47.0/bin/cache/dart-sdk/bin/dart /private/tmp/webmcp-review03-dart-semantics.dart`. That standalone script imports dart:io three times using each escape form, compares their pid values, checks all three decoded strings equal dart:io and checks raw/doubled-backslash strings remain literal. Exit 0. Exact output:

```text
All three escaped imports compile and resolve to dart:io.
Nonraw string values: [dart:io, dart:io, dart:io]
Raw and doubled-backslash values remain literal: dart:\u0069o
```

The directly related multiline-string probe is valid Dart, rather than a scanner-only synthetic directive. This exact standalone source was executed:

```dart
import '''
dart:\u0069o''';
void main() { print(pid > 0); }
```

Command: `/Users/ortalcohen/fvm/versions/3.47.0/bin/cache/dart-sdk/bin/dart /private/tmp/webmcp-review03-triple-semantics.dart`. Exit 0. Exact output:

```text
true
```

The corresponding raw triple-string form was also independently compiled:

```dart
import r'''
dart:io''';
void main() { print(pid > 0); }
```

Command: `/Users/ortalcohen/fvm/versions/3.47.0/bin/cache/dart-sdk/bin/dart /private/tmp/webmcp-review03-raw-triple.dart`. Exit 0. Exact output:

```text
true
```

Command: `python3 /private/tmp/webmcp_review03_triple.py`. Exit 0. It separately prepends the first triple import to example/lib/example_tools.dart and runs all root tests plus the example test; prepends the following valid Flutter import to lib/src/webmcp.dart and runs all root tests; and scans the raw triple dart:io form in an isolated example file. The first two modified files participate in the corresponding compiled tests. Both test-stage guards fail to reject these imports because the scanner keeps the initial newline in its URI value. Mutation content for the Flutter case:

```dart
import '''
package:\u0066lutter/widgets.dart''';
```

Exact output, including every command, working directory and exit status:

```text
triple-io | /private/tmp/webmcp-review03-vru1vqnw | flutter test --reporter expanded | exit=0
00:00 +0: loading /private/tmp/webmcp-review03-vru1vqnw/test/registry_test.dart
00:00 +0: /private/tmp/webmcp-review03-vru1vqnw/test/registry_test.dart: registers tools and lists them in ascending order
00:00 +1: /private/tmp/webmcp-review03-vru1vqnw/test/registry_test.dart: registers sources through duplicate validation
00:00 +2: /private/tmp/webmcp-review03-vru1vqnw/test/registry_test.dart: rejects duplicates without replacing the first handler
00:00 +3: /private/tmp/webmcp-review03-vru1vqnw/test/registry_test.dart: validates empty, long, and unsupported names
00:00 +4: /private/tmp/webmcp-review03-vru1vqnw/test/registry_test.dart: passes arguments through and awaits the handler
00:00 +5: /private/tmp/webmcp-review03-vru1vqnw/test/registry_test.dart: throws for a missing tool without invoking another handler
00:00 +6: /private/tmp/webmcp-review03-vru1vqnw/test/registry_test.dart: unregister is idempotent
00:00 +7: /private/tmp/webmcp-review03-vru1vqnw/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +8: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +9: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: action registers verbatim and unregisters independently
00:00 +10: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +11: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +12: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +13: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +14: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +15: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +16: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +17: /private/tmp/webmcp-review03-vru1vqnw/test/repo_hygiene_test.dart: directive detector fixtures decodes standard Dart string escapes
00:00 +18: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: action forwards invocation to the latest callback
00:00 +19: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: action forwards invocation to the latest callback
00:00 +20: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: action forwards invocation to the latest callback
00:00 +21: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: action forwards invocation to the latest callback
00:00 +22: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: action forwards invocation to the latest callback
00:00 +23: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: action forwards invocation to the latest callback
00:00 +24: /private/tmp/webmcp-review03-vru1vqnw/test/webmcp_public_surface_test.dart: exports the complete public API and seven registry operations
00:00 +25: /private/tmp/webmcp-review03-vru1vqnw/test/webmcp_public_surface_test.dart: exports the complete public API and seven registry operations
00:00 +26: /private/tmp/webmcp-review03-vru1vqnw/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:00 +27: /private/tmp/webmcp-review03-vru1vqnw/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:01 +28: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
00:01 +29: /private/tmp/webmcp-review03-vru1vqnw/test/repo_hygiene_test.dart: Flutter imports stay inside the widget layer
00:01 +30: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: duplicate actions preserve the first owner
00:01 +31: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: duplicate actions preserve the first owner
00:01 +32: /private/tmp/webmcp-review03-vru1vqnw/test/repo_hygiene_test.dart: implementation files contain no fixed secret markers
00:01 +33: /private/tmp/webmcp-review03-vru1vqnw/test/repo_hygiene_test.dart: implementation files contain no fixed secret markers
00:01 +34: /private/tmp/webmcp-review03-vru1vqnw/test/webmcp_scope_test.dart: adds direct and source tools, then closes
00:01 +35: /private/tmp/webmcp-review03-vru1vqnw/test/webmcp_scope_test.dart: skips duplicates and never removes another owner
00:01 +36: /private/tmp/webmcp-review03-vru1vqnw/test/webmcp_scope_test.dart: remove is limited to names owned by the scope
00:01 +37: /private/tmp/webmcp-review03-vru1vqnw/test/webmcp_scope_test.dart: close is idempotent and closed scopes reject additions
00:01 +38: /private/tmp/webmcp-review03-vru1vqnw/test/webmcp_scope_test.dart: invalid names propagate without becoming owned or skipped
00:01 +39: All tests passed!

triple-io | /private/tmp/webmcp-review03-vru1vqnw/example | flutter test --reporter expanded | exit=0
00:00 +0: loading /private/tmp/webmcp-review03-vru1vqnw/example/test/example_tools_test.dart
00:00 +0: registers two imperative tools and increments the counter
00:00 +1: All tests passed!

triple-flutter | /private/tmp/webmcp-review03-vru1vqnw | flutter test --reporter expanded | exit=0
00:00 +0: loading /private/tmp/webmcp-review03-vru1vqnw/test/registry_test.dart
00:00 +0: /private/tmp/webmcp-review03-vru1vqnw/test/registry_test.dart: registers tools and lists them in ascending order
00:00 +1: /private/tmp/webmcp-review03-vru1vqnw/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +2: /private/tmp/webmcp-review03-vru1vqnw/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +3: /private/tmp/webmcp-review03-vru1vqnw/test/registry_test.dart: rejects duplicates without replacing the first handler
00:00 +4: /private/tmp/webmcp-review03-vru1vqnw/test/registry_test.dart: validates empty, long, and unsupported names
00:00 +5: /private/tmp/webmcp-review03-vru1vqnw/test/registry_test.dart: passes arguments through and awaits the handler
00:00 +6: /private/tmp/webmcp-review03-vru1vqnw/test/registry_test.dart: throws for a missing tool without invoking another handler
00:00 +7: /private/tmp/webmcp-review03-vru1vqnw/test/registry_test.dart: unregister is idempotent
00:00 +8: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +9: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +10: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +11: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +12: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +13: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +14: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +15: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +16: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +17: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +18: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +19: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +20: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +21: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +22: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +23: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +24: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +25: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +26: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: action registers verbatim and unregisters independently
00:00 +27: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +28: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: action forwards invocation to the latest callback
00:00 +29: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: action keeps its mounted descriptor identity until replacement
00:00 +30: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: action copies its input schema
00:00 +31: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
00:00 +32: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: duplicate actions preserve the first owner
00:00 +33: /private/tmp/webmcp-review03-vru1vqnw/test/widget_layer_test.dart: invalid action names fail loudly
00:00 +34: /private/tmp/webmcp-review03-vru1vqnw/test/webmcp_scope_test.dart: adds direct and source tools, then closes
00:00 +35: /private/tmp/webmcp-review03-vru1vqnw/test/webmcp_scope_test.dart: skips duplicates and never removes another owner
00:00 +36: /private/tmp/webmcp-review03-vru1vqnw/test/webmcp_scope_test.dart: remove is limited to names owned by the scope
00:00 +37: /private/tmp/webmcp-review03-vru1vqnw/test/webmcp_scope_test.dart: close is idempotent and closed scopes reject additions
00:00 +38: /private/tmp/webmcp-review03-vru1vqnw/test/webmcp_scope_test.dart: invalid names propagate without becoming owned or skipped
00:00 +39: All tests passed!

raw-triple-io | /private/tmp/webmcp-review03-vru1vqnw | flutter test --reporter expanded test/repo_hygiene_test.dart | exit=0
00:00 +0: loading /private/tmp/webmcp-review03-vru1vqnw/test/repo_hygiene_test.dart
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

### Restored snapshot

Command: `PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH flutter test --reporter expanded test/repo_hygiene_test.dart` from the restored isolated snapshot. Exit 0. Exact output:

```text
00:00 +0: loading /private/tmp/webmcp-review03-vru1vqnw/test/repo_hygiene_test.dart
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

## Per-criterion results

Reused R01 and R02 refer only to the previous independent reviewers' executed negative cases and pasted command outputs at the cited report lines. New refers to this report's independently executed matrix/full-suite evidence. An ordinary negative that now fails does not override a valid bypass of the same universal criterion.

| Criterion | Result | Evidence (file:line) | Negative case exercised |
|---|---|---|---|
| AC-001 | pass | `tools/check.sh:4,20` |Reused R01 — Stage deletion produced only stages 2–6; fixed order predicate rejected it. Actual command/output: `impl-review-01.md:2021–2084; 2218–2228`. |
| AC-002 | pass | `tools/check.sh:7` |Reused R01 — Minimal PATH failed before stages; deleting preflight reached dependencies after wiki. Actual command/output: `impl-review-01.md:1558–1581; 1928–1941`. |
| AC-003 | pass | `tools/check.sh:15,34` |Reused R01 — Inverted assertion stopped at stage 5; removing strict mode and the test guard ran build and returned zero. Actual command/output: `impl-review-01.md:1755–1815; 1942–2007`. |
| AC-004 | pass | `tools/check.sh:27` |Reused R01 — Malformed whitespace returned 1 and named lib/src/webmcp.dart. Actual command/output: `impl-review-01.md:1582–1592`. |
| AC-005 | pass | `tools/check.sh:31; analysis_options.yaml:17` |Reused R01 — Unused example variable and undocumented root public method produced warning plus info, exit 2. Actual command/output: `impl-review-01.md:1593–1607`. |
| AC-006 | pass | `analysis_options.yaml:4; example/analysis_options.yaml:4` |Reused R01 — Cold committed-snapshot checksums stayed equal; missing ios exclusion triggered migration and a diff. Actual command/output: `impl-review-01.md:240–333; 1608–1651`. |
| AC-007 | pass | `example/analysis_options.yaml:5` |Reused R01 — Excluded build probe passed; deleting nested build exclusion exposed undefined_function, exit 3. Actual command/output: `impl-review-01.md:1652–1676`. |
| AC-008 | pass | `example/pubspec.yaml:3` |Reused R01 — Removing publish_to produced invalid_dependency, exit 2. Actual command/output: `impl-review-01.md:1677–1690`. |
| AC-009 | pass | `lib/src/webmcp.dart:24,53; test/registry_test.dart:22` |Reused R01 — Deleting insertion failed listing assertions. Actual command/output: `impl-review-01.md:372–445`. |
| AC-010 | pass | `lib/src/webmcp.dart:36; test/registry_test.dart:35` |Reused R01 — Direct source insertion bypassed collision validation and failed the assertion. Actual command/output: `impl-review-01.md:446–475`. |
| AC-011 | pass | `lib/src/webmcp.dart:28; test/registry_test.dart:50` |Reused R01 — Removing duplicate guard failed exception assertions. Actual command/output: `impl-review-01.md:476–515`. |
| AC-012 | pass | `lib/src/webmcp.dart:18; test/registry_test.dart:65` |Reused R01 — Widened pattern failed invalid-name tests; independent invalid cases kept listing unchanged. Actual command/output: `impl-review-01.md:516–545; 2085–2096`. |
| AC-013 | pass | `lib/src/webmcp.dart:62; test/registry_test.dart:76` |Reused R01 — Empty argument map returned null instead of 42; independent identity/await check passed. Actual command/output: `impl-review-01.md:546–574; 2085–2096`. |
| AC-014 | pass | `lib/src/webmcp.dart:66; test/registry_test.dart:87` |Reused R01 — Fallback to first handler failed missing-tool expectations. Actual command/output: `impl-review-01.md:575–604`. |
| AC-015 | pass | `lib/src/webmcp.dart:43; test/registry_test.dart:109` |Reused R01 — Throwing for second unregister failed idempotence. Actual command/output: `impl-review-01.md:605–630`. |
| AC-016 | pass | `lib/src/webmcp.dart:74; test/transport_selection_test.dart:26` |Reused R01 — Retaining fake transport failed; independent populated reset returned noop and cleared listing. Actual command/output: `impl-review-01.md:631–659; 2085–2096`. |
| AC-017 | pass | `test/webmcp_public_surface_test.dart:1,25; test/repo_hygiene_test.dart:433` | Reused R02 export-removal/handler negatives (`impl-review-02.md:141–259`) on byte-identical public test; new escaped private import fails and names its decoded URI. |
| AC-018 | fail | `test/repo_hygiene_test.dart:127,152,408` | New: all three escape forms fail and name the decoded URI in both source roots; multiline/comments/conditional negatives fail. Valid triple-quoted initial-newline import passes all root and example tests (F-001). |
| AC-019 | pass | `lib/src/transport/transport_selector.dart:1; test/transport_selection_test.dart:26` |Reused R01 — Web-default mutation failed VM compilation. Actual command/output: `impl-review-01.md:836–882`. |
| AC-020 | pass | `lib/src/webmcp.dart:32,48; test/transport_selection_test.dart:36` |Reused R01 — Missing unregister notification failed two-event sequence assertion. Actual command/output: `impl-review-01.md:883–907`. |
| AC-021 | pass | `lib/src/transport/transport_web.dart:18,24; test/transport_web_source_test.dart:6` |Reused R01 — Renamed transport identifier failed source contract test. Actual command/output: `impl-review-01.md:908–970`. |
| AC-022 | pass | `example/lib/example_tools.dart:13; example/test/example_tools_test.dart:8` |Reused R01 — Renamed example read tool failed expected name list. Actual command/output: `impl-review-01.md:971–997`. |
| AC-023 | pass | `tools/check.sh:38; example/web/index.html:1` |Reused R01 — Deleting web entry returned 1: project not configured for web. Actual command/output: `impl-review-01.md:1691–1708`. |
| AC-024 | pass | `.github/workflows/checks.yml:9,29` |Reused R01 — Exactly wiki and package jobs; adding needs failed structural predicate. Actual command/output: `impl-review-01.md:2097–2107`. |
| AC-025 | pass | `.github/workflows/checks.yml:49; AGENTS.md:73` |Reused R01 — Changing documented full-suite command to sh failed literal comparison. Actual command/output: `impl-review-01.md:2108–2118`. |
| AC-026 | pass; CI log pending | `.github/workflows/checks.yml:43` |Reused R01 — Second version literal failed count predicate; local SDK reports 3.47.0. No push or live CI log. Actual command/output: `impl-review-01.md:2119–2129`. |
| AC-027 | pass | `README.md:1,11` |Reused R01 — Original HEAD README is unchanged suffix; third-party toggle rewording failed comparison. Actual command/output: `impl-review-01.md:2130–2140`. |
| AC-028 | pass | `CHANGELOG.md:1; LICENSE:1; pubspec.yaml:1` |Reused R01 — Actual disk and index include all required paths after author tracking step; renamed changelog failed existence check. Actual command/output: `impl-review-01.md:2141–2158`. |
| AC-029 | pass | `pubspec.yaml:20` |Reused R01 — Adding android failed web-only key predicate. Actual command/output: `impl-review-01.md:2159–2169`. |
| AC-030 | pass | `AGENTS.md:71` |Reused R01 — Checks heading deletion failed predicate; 76 lines, all four commands present, wiki lint clean. Actual command/output: `impl-review-01.md:2170–2180`. |
| AC-031 | pass | `tools/check.sh:20` | Reused R01 warm second run 27.27s and 400-second delay negative 429.54s (`impl-review-01.md:2229–2274`); unchanged script. New full suite: 28.55s. |
| AC-032 | pass | `test/repo_hygiene_test.dart:250,255,460; 06-plan-amendment.md:13` | Reused independent R02 exhaustive 52-marker/208-path matrix (`impl-review-02.md:562–691`) with byte-identical marker recognizer and scan. New tracked YAML bare AWS prefix, non-Dart private header, and newline assignment markers all fail with paths and markers. |
| AC-033 | pass | `.gitignore:30` |Reused R01 — All six paths matched; removal of example build pattern returned no match. Actual command/output: `impl-review-01.md:2181–2196`. |
| AC-034 | pass | `lib/src/webmcp_scope.dart:39,64; test/webmcp_scope_test.dart:22` |Reused R01 — Both close-without-unregister and source-bypasses-ownership mutations failed. Actual command/output: `impl-review-01.md:998–1050`. |
| AC-035 | pass | `lib/src/webmcp_scope.dart:28; test/webmcp_scope_test.dart:38` |Reused R01 — Marking duplicate name owned failed skip/ownership assertions. Actual command/output: `impl-review-01.md:1051–1076`. |
| AC-036 | pass | `lib/src/webmcp_scope.dart:23,64,76; test/webmcp_scope_test.dart:60` |Reused R01 — Removing closed guard failed StateError assertion. Actual command/output: `impl-review-01.md:1077–1103`. |
| AC-037 | pass | `lib/src/webmcp_scope.dart:28; test/webmcp_scope_test.dart:76` |Reused R01 — Catching all WebMcpException swallowed invalid name and failed assertion. Actual command/output: `impl-review-01.md:1104–1130`. |
| AC-038 | pass | `lib/src/widgets/webmcp_screen.dart:30,37; test/widget_layer_test.dart:65` |Reused R01 — Removing scope close on disposal left registration and failed. Actual command/output: `impl-review-01.md:1131–1177`. |
| AC-039 | pass | `lib/src/widgets/webmcp_action.dart:64,76; test/widget_layer_test.dart:75` |Reused R01 — Prefixing action name failed literal name expectation. Actual command/output: `impl-review-01.md:1178–1244`. |
| AC-040 | pass | `lib/src/widgets/webmcp_action.dart:73; test/widget_layer_test.dart:85` |Reused R01 — AbsorbPointer child wrapper failed identity/callback expectations. Actual command/output: `impl-review-01.md:1245–1291`. |
| AC-041 | pass | `lib/src/widgets/webmcp_action.dart:67; test/widget_layer_test.dart:109` |Reused R01 — Captured callback returned first value after rebuild and failed. Actual command/output: `impl-review-01.md:1292–1343`. |
| AC-042 | pass | `lib/src/widgets/webmcp_action.dart:56; test/widget_layer_test.dart:165` |Reused R01 — Fallback scope prevented missing-scope exception and failed. Actual command/output: `impl-review-01.md:1344–1391`. |
| AC-043 | pass | `lib/src/webmcp_scope.dart:28; test/widget_layer_test.dart:185` |Reused R01 — Rethrowing duplicate exception made duplicate-screen pump fail. Actual command/output: `impl-review-01.md:1392–1455`. |
| AC-044 | fail | `test/repo_hygiene_test.dart:127,152,418` | New: three escaped Flutter forms and ordinary comment-separated form fail with decoded diagnostics; widget-directory escaped import passes. Valid triple-quoted initial-newline Flutter import in lib/src/webmcp.dart compiles and passes all 39 root tests (F-001). |
| AC-045 | pass | `test/webmcp_scope_test.dart:1; test/repo_hygiene_test.dart:433` | Reused R02 comment-separated import negative (`impl-review-02.md:260–444`); new hex-escaped flutter_test import fails with decoded URI. Full suite executes unchanged scope tests; no pumpWidget call. |
| AC-046 | pass | `example/lib/example_screen.dart:15,59; example/lib/main.dart:3,16` |Reused R01 — Deleting example screen produced missing URI and undefined class errors. Actual command/output: `impl-review-01.md:1709–1724`. |

## Findings

### F-001 — Initial newline in a valid triple-quoted import URI bypasses both source boundaries

- Severity: BLOCKER
- Location: `test/repo_hygiene_test.dart:127` and `test/repo_hygiene_test.dart:152`; comparison consumers at lines 237 and 425.
- Criteria affected: AC-018, AC-044.
- Observation: `_readString` starts reading immediately after the triple delimiter and appends its initial newline to the URI. Dart discards that newline. A valid triple-quoted import whose content begins on the following line therefore resolves to dart:io or package:flutter/widgets.dart at compilation, but the scanner compares a string beginning with a newline. The independently compiled dart:io example and the Flutter import in lib/src/webmcp.dart pass the whole corresponding VM test stage with no forbidden-import diagnostic. The raw triple-string form has the same initial-newline behavior and also passes the hygiene scan. All ordinary fixed/braced Unicode and hex import probes are now correctly rejected.
- Why it matters: Both criteria apply to valid import directives. The test stage accepts these valid forbidden imports and does not name the offending path and resolved URI. The successful baseline build does not establish the import boundary.

## Recurrence check

- Previous round: [implementation review 02](impl-review-02.md).
- Recurring findings: the material AC-018/AC-044 boundary failure from round 02 F-001 remains as this round's F-001, in the distinct initial-newline rule for triple-quoted Dart strings. The previously demonstrated ordinary Unicode/hex escape bypass is resolved by the new matrix.
- Round 01 F-001: not recurring; the explicit handler reference and public API file are unchanged from the independently verified round 02 repair.
- Round 01 F-003: not recurring; normative marker definitions and the byte-identical exhaustive-marker implementation remain supported by the round 02 matrix plus fresh representative negatives.
- Oscillating: no. No fixed behavior was observed to revert; a different valid Dart string form still bypasses the same import boundary.

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | implement |

## Evidence location correction

The precise F-001 initialization/append locations are `test/repo_hygiene_test.dart:123` and `test/repo_hygiene_test.dart:144`. References to lines 127 and 152 in the AC-018/AC-044 table and finding above point into the surrounding string-reader code; this correction supersedes those two location references without changing the observation or verdict. The criterion consumers remain the forbidden-import predicate and the Flutter prefix comparison at line 425.

## Report lint

Command: `python3 tools/lint_wiki.py`. Exit 0. Exact output:

```text
lint_wiki: clean (0 warning(s)).
```
