---
id: 0004-impl-review-02
title: Flutter WebMCP skeleton implementation review round 02
status: active
owner: validator
last_verified: 2026-09-10
applies_to: ["lib/**", "test/**", "example/**", "tools/check.sh"]
summary: Independent revalidation finds a remaining escaped import URI bypass after verifying the public API and fixed secret marker repairs.
---

# Implementation review — round 02

- Work item: 0004-flutter-webmcp-skeleton
- Reviewed artifact: current implementation working tree relative to `dccbad724308ce93f75fb95580282b18292ad0df`; frozen `02-criteria.md` and normative `06-plan-amendment.md`.
- Reviewer: independent final_validator subagent
- Date: 2026-09-10
- Inputs: frozen criteria, normative amendment, current implementation, validation rubric/template, and previous independent `impl-review-01.md`. No author notes, implementation evidence, plan reasoning or transcript was read.

## Verdict

**FAIL**

AC-018 and AC-044 still accept valid forbidden imports when a URI contains a Dart Unicode escape. AC-017 and AC-032 now meet their contracts. The unmodified full suite passes, but the escaped-import negative probes pass when both criteria require failure.

## Verification performed

All commands below were run by this validator. Flutter commands used `/Users/ortalcohen/fvm/versions/3.47.0/bin` prepended to PATH. Real source was not mutated. Synthetic mutations ran in `/private/tmp/webmcp-final-validator-q4sry1vf` and `/private/tmp/webmcp-final-extra-r7fxna6e`, each with an isolated Git index. Files were restored after each case. No real commit or push was performed.

The initial sandbox full run could not write the SDK cache and stopped at dependencies. Approved SDK cache access allowed the actual run below to complete. The first escaped-import example invocation used the root package working directory and failed to resolve `webmcp_pilot_example`; the completed invocation below uses the example working directory and exits zero. Those environment/harness failures are not implementation findings.

The marker diagnostic harness initially compared literal newline whitespace to a reporter-indented reason. Fourteen newline cases therefore had a false harness mismatch even though they correctly failed and printed their markers. The raw saved output was then checked with whitespace normalization: all four offending paths and every exact marker were present for every case. No implementation was changed to obtain that result.

### Actual checkout full suite

Command: `PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH /usr/bin/time -p bash tools/check.sh`

Exit: 0. Pasted output:

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
00:00 +0: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +1: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: registers tools and lists them in ascending order
00:00 +2: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: registers sources through duplicate validation
00:00 +3: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: rejects duplicates without replacing the first handler
00:00 +4: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: validates empty, long, and unsupported names
00:00 +5: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: passes arguments through and awaits the handler
00:00 +6: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: throws for a missing tool without invoking another handler
00:00 +7: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: unregister is idempotent
00:00 +8: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +9: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +10: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +11: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +12: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +13: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +14: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +15: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +16: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +17: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +18: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +19: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +20: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +21: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +22: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action registers verbatim and unregisters independently
00:00 +23: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +24: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: adds direct and source tools, then closes
00:00 +25: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action forwards invocation to the latest callback
00:00 +26: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: skips duplicates and never removes another owner
00:00 +27: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: remove is limited to names owned by the scope
00:00 +28: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action keeps its mounted descriptor identity until replacement
00:00 +29: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: close is idempotent and closed scopes reject additions
00:00 +30: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action copies its input schema
00:00 +31: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action copies its input schema
00:00 +32: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
00:00 +33: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: duplicate actions preserve the first owner
00:01 +34: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: invalid action names fail loudly
00:01 +35: All tests passed!
00:00 +0: loading /Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/test/example_tools_test.dart
00:00 +0: registers two imperative tools and increments the counter
00:00 +1: All tests passed!
Stage 5 passed: tests
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 7736 bytes (99.5% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             16.3s
✓ Built build/web
Stage 6 passed: build
real 25.47
user 28.56
sys 4.07
```

This is VM and web-build verification, not browser execution or live GitHub Actions evidence. AC-026 permits the unrequested live CI portion to remain pending. The successful full run took 25.47 seconds. The previous independent warm second run and 400-second negative timing probe remain applicable because `tools/check.sh` is byte-identical.

### Source comparison and reuse of independent negative evidence

Command: a Python byte comparison of current implementation files against `git -C /private/tmp/webmcp-validator-xeh_qiad show aad36edce1467895c17d7b2248970c74502ff197:<path>`.

Exit: 0. Pasted output:

```text
Changed implementation files versus independent round 01 snapshot:
test/repo_hygiene_test.dart
test/webmcp_public_surface_test.dart
```

Only those two tests differ. For unaffected criteria, this report explicitly reuses the previous independent validator's executed negative probes and pasted outputs, with exact report line references in the table. It does not treat author evidence as independent evidence. The changed public and hygiene tests were exercised anew, including the prescribed export/import negatives. The original temporary commit is in the original validator snapshot repository, not the actual checkout object database.

### Public surface

Command: Python whole-word type search and registry-operation reference search in `test/webmcp_public_surface_test.dart`.

Exit: 0. Pasted output:

```text
WebMcpScope: True
WebMcpScreen: True
WebMcpAction: True
WebMcpTool: True
WebMcpToolHandler: True
WebMcpToolSource: True
WebMcpTransport: True
WebMcpException: True
WebMcpInvalidToolNameException: True
WebMcpDuplicateToolException: True
WebMcpToolNotFoundException: True
WebMcpScopeMissingException: True
registry.registerTool: True
registry.registerSource: True
registry.unregisterTool: True
registry.tools: True
registry.invokeTool: True
registry.reset: True
registry.transportId: True
```

The only imports are the public package library and Flutter test framework. The handler now has an explicit `WebMcpToolHandler` declaration at line 25.

Case: missing-handler. Command: `flutter test --reporter expanded test/webmcp_public_surface_test.dart`. Exit: 1. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_public_surface_test.dart
00:00 +0 -1: loading /private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_public_surface_test.dart [E]
  Failed to load "/private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_public_surface_test.dart":
  Compilation failed for testPath=/private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_public_surface_test.dart: test/webmcp_public_surface_test.dart:25:13: Error: 'WebMcpToolHandler' isn't a type.
        final WebMcpToolHandler typedHandler = handler;
              ^^^^^^^^^^^^^^^^^
  .
00:00 +0 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_public_surface_test.dart: loading /private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_public_surface_test.dart
test/webmcp_public_surface_test.dart:25:13: Error: 'WebMcpToolHandler' isn't a type.
      final WebMcpToolHandler typedHandler = handler;
            ^^^^^^^^^^^^^^^^^
```

Case: missing-exceptions. Command: `flutter test --reporter expanded test/webmcp_public_surface_test.dart`. Exit: 1. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_public_surface_test.dart
00:00 +0 -1: loading /private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_public_surface_test.dart [E]
  Failed to load "/private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_public_surface_test.dart":
  Compilation failed for testPath=/private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_public_surface_test.dart: test/webmcp_public_surface_test.dart:46:14: Error: Undefined name 'WebMcpException'.
        expect(WebMcpException, isNotNull);
               ^^^^^^^^^^^^^^^
  test/webmcp_public_surface_test.dart:47:14: Error: Undefined name 'WebMcpInvalidToolNameException'.
        expect(WebMcpInvalidToolNameException, isNotNull);
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  test/webmcp_public_surface_test.dart:48:14: Error: Undefined name 'WebMcpDuplicateToolException'.
        expect(WebMcpDuplicateToolException, isNotNull);
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  test/webmcp_public_surface_test.dart:49:14: Error: Undefined name 'WebMcpToolNotFoundException'.
        expect(WebMcpToolNotFoundException, isNotNull);
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^
  test/webmcp_public_surface_test.dart:50:14: Error: Undefined name 'WebMcpScopeMissingException'.
        expect(WebMcpScopeMissingException, isNotNull);
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^
  .
00:00 +0 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_public_surface_test.dart: loading /private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_public_surface_test.dart
test/webmcp_public_surface_test.dart:46:14: Error: Undefined name 'WebMcpException'.
      expect(WebMcpException, isNotNull);
             ^^^^^^^^^^^^^^^
test/webmcp_public_surface_test.dart:47:14: Error: Undefined name 'WebMcpInvalidToolNameException'.
      expect(WebMcpInvalidToolNameException, isNotNull);
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
test/webmcp_public_surface_test.dart:48:14: Error: Undefined name 'WebMcpDuplicateToolException'.
      expect(WebMcpDuplicateToolException, isNotNull);
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
test/webmcp_public_surface_test.dart:49:14: Error: Undefined name 'WebMcpToolNotFoundException'.
      expect(WebMcpToolNotFoundException, isNotNull);
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^
test/webmcp_public_surface_test.dart:50:14: Error: Undefined name 'WebMcpScopeMissingException'.
      expect(WebMcpScopeMissingException, isNotNull);
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^
```

Case: missing-action. Command: `flutter test --reporter expanded test/webmcp_public_surface_test.dart`. Exit: 1. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_public_surface_test.dart
00:00 +0 -1: loading /private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_public_surface_test.dart [E]
  Failed to load "/private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_public_surface_test.dart":
  Compilation failed for testPath=/private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_public_surface_test.dart: test/webmcp_public_surface_test.dart:45:14: Error: Undefined name 'WebMcpAction'.
        expect(WebMcpAction, isNotNull);
               ^^^^^^^^^^^^
  .
00:00 +0 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_public_surface_test.dart: loading /private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_public_surface_test.dart
test/webmcp_public_surface_test.dart:45:14: Error: Undefined name 'WebMcpAction'.
      expect(WebMcpAction, isNotNull);
             ^^^^^^^^^^^^
```

Case: public-restored. Command: `flutter test --reporter expanded test/webmcp_public_surface_test.dart`. Exit: 0. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_public_surface_test.dart
00:00 +0: exports the complete public API and seven registry operations
00:00 +1: All tests passed!
```

### Ordinary import directive probes

Command for each case: `flutter test --reporter expanded test/repo_hygiene_test.dart` in the first isolated snapshot. Each forbidden directive was introduced independently. The known multiline forms, nested/intervening comments, all five forbidden families, conditional imports, outside-widget Flutter imports, and public/scope test import boundaries were exercised. Comments, string contents, exports and widget-directory Flutter imports were accepted.

Pasted harness output:

```text
baseline: exit=0 expected=pass diagnostic_check=True
forbidden-newline: exit=1 expected=fail diagnostic_check=True
forbidden-line-comment: exit=1 expected=fail diagnostic_check=True
forbidden-nested-comment: exit=1 expected=fail diagnostic_check=True
forbidden-conditional: exit=1 expected=fail diagnostic_check=True
forbidden-http-path: exit=1 expected=fail diagnostic_check=True
forbidden-dart-js: exit=1 expected=fail diagnostic_check=True
forbidden-escaped-uri: exit=0 expected=fail diagnostic_check=False
flutter-newline: exit=1 expected=fail diagnostic_check=True
flutter-comment: exit=1 expected=fail diagnostic_check=True
flutter-conditional: exit=1 expected=fail diagnostic_check=True
allowed-comments-strings-exports: exit=0 expected=pass diagnostic_check=True
public-private: exit=1 expected=fail diagnostic_check=True
scope-widget: exit=1 expected=fail diagnostic_check=True
nonmarkers: exit=0 expected=pass diagnostic_check=True
restored: exit=0 expected=pass diagnostic_check=True
```

Case: forbidden-line-comment. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-final-validator-q4sry1vf/test/repo_hygiene_test.dart
00:00 +0: directive detector fixtures recognizes imports across whitespace and comments
00:00 +1: directive detector fixtures ignores exports, commented directives, and string contents
00:00 +2: directive detector fixtures classifies only the fixed forbidden import families
00:00 +3: secret detector fixtures matches every fixed header and the bare AWS prefix
00:00 +4: secret detector fixtures matches every assignment spelling and separator
00:00 +5: secret detector fixtures does not infer markers outside the exhaustive set
00:00 +6: library and example sources avoid forbidden imports
00:00 +6 -1: library and example sources avoid forbidden imports [E]
  Expected: empty
    Actual: ['example/lib/validation_probe.dart: import dart:html']
  example/lib/validation_probe.dart: import dart:html
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 268:5                   main.<fn>
  
00:00 +6 -1: Flutter imports stay inside the widget layer
00:00 +7 -1: public and scope tests preserve their import boundaries
00:00 +8 -1: implementation files contain no fixed secret markers
00:00 +9 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-final-validator-q4sry1vf/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
```

Case: forbidden-conditional. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-final-validator-q4sry1vf/test/repo_hygiene_test.dart
00:00 +0: directive detector fixtures recognizes imports across whitespace and comments
00:00 +1: directive detector fixtures ignores exports, commented directives, and string contents
00:00 +2: directive detector fixtures classifies only the fixed forbidden import families
00:00 +3: secret detector fixtures matches every fixed header and the bare AWS prefix
00:00 +4: secret detector fixtures matches every assignment spelling and separator
00:00 +5: secret detector fixtures does not infer markers outside the exhaustive set
00:00 +6: library and example sources avoid forbidden imports
00:00 +6 -1: library and example sources avoid forbidden imports [E]
  Expected: empty
    Actual: ['example/lib/validation_probe.dart: import dart:io']
  example/lib/validation_probe.dart: import dart:io
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 268:5                   main.<fn>
  
00:00 +6 -1: Flutter imports stay inside the widget layer
00:00 +7 -1: public and scope tests preserve their import boundaries
00:00 +8 -1: implementation files contain no fixed secret markers
00:00 +9 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-final-validator-q4sry1vf/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
```

Case: flutter-comment. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-final-validator-q4sry1vf/test/repo_hygiene_test.dart
00:00 +0: directive detector fixtures recognizes imports across whitespace and comments
00:00 +1: directive detector fixtures ignores exports, commented directives, and string contents
00:00 +2: directive detector fixtures classifies only the fixed forbidden import families
00:00 +3: secret detector fixtures matches every fixed header and the bare AWS prefix
00:00 +4: secret detector fixtures matches every assignment spelling and separator
00:00 +5: secret detector fixtures does not infer markers outside the exhaustive set
00:00 +6: library and example sources avoid forbidden imports
00:00 +7: Flutter imports stay inside the widget layer
00:00 +7 -1: Flutter imports stay inside the widget layer [E]
  Expected: empty
    Actual: ['lib/validation_probe.dart: import package:flutter/widgets.dart']
  lib/validation_probe.dart: import package:flutter/widgets.dart
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 283:5                   main.<fn>
  
00:00 +7 -1: public and scope tests preserve their import boundaries
00:00 +8 -1: implementation files contain no fixed secret markers
00:00 +9 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-final-validator-q4sry1vf/test/repo_hygiene_test.dart: Flutter imports stay inside the widget layer
```

Case: allowed-comments-strings-exports. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-final-validator-q4sry1vf/test/repo_hygiene_test.dart
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

Case: public-private. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-final-validator-q4sry1vf/test/repo_hygiene_test.dart
00:00 +0: directive detector fixtures recognizes imports across whitespace and comments
00:00 +1: directive detector fixtures ignores exports, commented directives, and string contents
00:00 +2: directive detector fixtures classifies only the fixed forbidden import families
00:00 +3: secret detector fixtures matches every fixed header and the bare AWS prefix
00:00 +4: secret detector fixtures matches every assignment spelling and separator
00:00 +5: secret detector fixtures does not infer markers outside the exhaustive set
00:00 +6: library and example sources avoid forbidden imports
00:00 +7: Flutter imports stay inside the widget layer
00:00 +8: public and scope tests preserve their import boundaries
00:00 +8 -1: public and scope tests preserve their import boundaries [E]
  Expected: empty
    Actual: WhereIterable<String>:['package:webmcp_pilot/src/webmcp.dart']
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 293:5                   main.<fn>
  
00:00 +8 -1: implementation files contain no fixed secret markers
00:00 +9 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-final-validator-q4sry1vf/test/repo_hygiene_test.dart: public and scope tests preserve their import boundaries
```

Case: scope-widget. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-final-validator-q4sry1vf/test/repo_hygiene_test.dart
00:00 +0: directive detector fixtures recognizes imports across whitespace and comments
00:00 +1: directive detector fixtures ignores exports, commented directives, and string contents
00:00 +2: directive detector fixtures classifies only the fixed forbidden import families
00:00 +3: secret detector fixtures matches every fixed header and the bare AWS prefix
00:00 +4: secret detector fixtures matches every assignment spelling and separator
00:00 +5: secret detector fixtures does not infer markers outside the exhaustive set
00:00 +6: library and example sources avoid forbidden imports
00:00 +7: Flutter imports stay inside the widget layer
00:00 +8: public and scope tests preserve their import boundaries
00:00 +8 -1: public and scope tests preserve their import boundaries [E]
  Expected: empty
    Actual: WhereIterable<String>:['package:flutter_test/flutter_test.dart']
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 301:5                   main.<fn>
  
00:00 +8 -1: implementation files contain no fixed secret markers
00:00 +9 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-final-validator-q4sry1vf/test/repo_hygiene_test.dart: public and scope tests preserve their import boundaries
```

### Escaped URI negative probes

A standalone valid Dart program contained `import 'dart:\u0069o';` and printed `Platform.version.isNotEmpty`.

Command: `/Users/ortalcohen/fvm/versions/3.47.0/bin/cache/dart-sdk/bin/dart /private/tmp/final-validator-escaped.dart`

Exit: 0. Pasted output:

```text
true
```

Thus the URI is decoded by Dart to `dart:io`; it is not malformed syntax or merely a string containing import-like text.

Independently prepending that directive to `example/lib/example_tools.dart` allowed the entire root and example test stage to pass. The following are the completed runs from the proper working directories, not the earlier harness invocation from the wrong package:

Working directory: `/private/tmp/webmcp-final-extra-r7fxna6e`. Command: `flutter test --reporter expanded`. Exit: 0. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-final-extra-r7fxna6e/test/registry_test.dart
00:00 +0: /private/tmp/webmcp-final-extra-r7fxna6e/test/registry_test.dart: registers tools and lists them in ascending order
00:00 +1: /private/tmp/webmcp-final-extra-r7fxna6e/test/registry_test.dart: registers sources through duplicate validation
00:00 +2: /private/tmp/webmcp-final-extra-r7fxna6e/test/registry_test.dart: rejects duplicates without replacing the first handler
00:00 +3: /private/tmp/webmcp-final-extra-r7fxna6e/test/registry_test.dart: validates empty, long, and unsupported names
00:00 +4: /private/tmp/webmcp-final-extra-r7fxna6e/test/registry_test.dart: passes arguments through and awaits the handler
00:00 +5: /private/tmp/webmcp-final-extra-r7fxna6e/test/registry_test.dart: throws for a missing tool without invoking another handler
00:00 +6: /private/tmp/webmcp-final-extra-r7fxna6e/test/registry_test.dart: unregister is idempotent
00:00 +7: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +8: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +9: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: action registers verbatim and unregisters independently
00:00 +10: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +11: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: action forwards invocation to the latest callback
00:00 +12: /private/tmp/webmcp-final-extra-r7fxna6e/test/repo_hygiene_test.dart: directive detector fixtures recognizes imports across whitespace and comments
00:00 +13: /private/tmp/webmcp-final-extra-r7fxna6e/test/repo_hygiene_test.dart: directive detector fixtures recognizes imports across whitespace and comments
00:00 +14: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: action copies its input schema
00:00 +15: /private/tmp/webmcp-final-extra-r7fxna6e/test/repo_hygiene_test.dart: directive detector fixtures ignores exports, commented directives, and string contents
00:00 +16: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
00:00 +17: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
00:00 +18: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
00:00 +19: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
00:00 +20: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
00:00 +21: /private/tmp/webmcp-final-extra-r7fxna6e/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:00 +22: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: duplicate actions preserve the first owner
00:00 +23: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: duplicate actions preserve the first owner
00:00 +24: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: duplicate actions preserve the first owner
00:00 +25: /private/tmp/webmcp-final-extra-r7fxna6e/test/repo_hygiene_test.dart: implementation files contain no fixed secret markers
00:00 +26: /private/tmp/webmcp-final-extra-r7fxna6e/test/repo_hygiene_test.dart: implementation files contain no fixed secret markers
00:00 +27: /private/tmp/webmcp-final-extra-r7fxna6e/test/repo_hygiene_test.dart: implementation files contain no fixed secret markers
00:00 +28: /private/tmp/webmcp-final-extra-r7fxna6e/test/repo_hygiene_test.dart: implementation files contain no fixed secret markers
00:00 +29: /private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_public_surface_test.dart: exports the complete public API and seven registry operations
00:00 +30: /private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_scope_test.dart: adds direct and source tools, then closes
00:00 +31: /private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_scope_test.dart: skips duplicates and never removes another owner
00:00 +32: /private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_scope_test.dart: remove is limited to names owned by the scope
00:00 +33: /private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_scope_test.dart: close is idempotent and closed scopes reject additions
00:00 +34: /private/tmp/webmcp-final-extra-r7fxna6e/test/webmcp_scope_test.dart: invalid names propagate without becoming owned or skipped
00:00 +35: All tests passed!
```

Working directory: `/private/tmp/webmcp-final-extra-r7fxna6e/example`. Command: `flutter test --reporter expanded`. Exit: 0. Pasted output:

```text
Resolving dependencies...
Downloading packages...
  material_color_utilities 0.13.0 (0.13.1 available)
  test_api 0.7.12 (0.7.14 available)
Got dependencies!
2 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
00:00 +0: loading /private/tmp/webmcp-final-extra-r7fxna6e/example/test/example_tools_test.dart
00:00 +0: registers two imperative tools and increments the counter
00:00 +1: All tests passed!
```

Prepending `import 'package:\u0066lutter/widgets.dart';` to `lib/src/webmcp.dart` also compiled successfully and escaped the Flutter boundary check. This resolves to a Flutter import outside the widget directory.

Command: `flutter test --reporter expanded`. Exit: 0. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-final-extra-r7fxna6e/test/registry_test.dart
00:00 +0: /private/tmp/webmcp-final-extra-r7fxna6e/test/registry_test.dart: registers tools and lists them in ascending order
00:00 +1: /private/tmp/webmcp-final-extra-r7fxna6e/test/registry_test.dart: registers sources through duplicate validation
00:00 +2: /private/tmp/webmcp-final-extra-r7fxna6e/test/registry_test.dart: rejects duplicates without replacing the first handler
00:00 +3: /private/tmp/webmcp-final-extra-r7fxna6e/test/registry_test.dart: validates empty, long, and unsupported names
00:00 +4: /private/tmp/webmcp-final-extra-r7fxna6e/test/registry_test.dart: passes arguments through and awaits the handler
00:00 +5: /private/tmp/webmcp-final-extra-r7fxna6e/test/registry_test.dart: throws for a missing tool without invoking another handler
00:00 +6: /private/tmp/webmcp-final-extra-r7fxna6e/test/registry_test.dart: unregister is idempotent
00:00 +7: /private/tmp/webmcp-final-extra-r7fxna6e/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +8: /private/tmp/webmcp-final-extra-r7fxna6e/test/transport_selection_test.dart: selects noop on the Dart VM and resets transport
00:00 +9: /private/tmp/webmcp-final-extra-r7fxna6e/test/transport_selection_test.dart: notifies registration and unregistration in order
00:00 +10: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +11: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +12: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +13: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +14: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +15: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +16: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +17: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +18: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +19: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +20: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +21: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +22: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: action registers verbatim and unregisters independently
00:00 +23: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +24: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +25: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +26: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +27: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +28: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +29: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: action forwards invocation to the latest callback
00:00 +30: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: action keeps its mounted descriptor identity until replacement
00:00 +31: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: action copies its input schema
00:00 +32: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
00:00 +33: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: duplicate actions preserve the first owner
00:01 +34: /private/tmp/webmcp-final-extra-r7fxna6e/test/widget_layer_test.dart: invalid action names fail loudly
00:01 +35: All tests passed!
```

### Fixed marker matrix

Command: `python3 /private/tmp/final-validator-probes.py`; each case invokes `flutter test --reporter expanded test/repo_hygiene_test.dart`. The postprocessing comparison uses the saved raw output from `/private/tmp/final-validator-probes.json` and normalizes whitespace added by the expanded reporter.

There are 52 marker cases and 208 path/marker combinations. Every case put the same synthetic marker in all four roots: `lib/`, `example/lib/`, `tools/`, `.github/`. File suffixes rotate through `.txt`, `.yaml`, `.json`, `.dart`, and no extension. Cases alternate tracked and nonignored new files. The four exact private-key headers and bare AWS prefix each have uppercase and lowercase variants. Every one of the seven assignment names has both separators and three variants: no whitespace, uppercase with spaces/tab, and mixed case with newline/tab. All have no assigned value. Matching elsewhere in text is tested by wrapping each marker in a synthetic comment.

The scanner iterates the Git file list without an extension filter at `test/repo_hygiene_test.dart:313`; this confirms extension-independent scope beyond the representative extensions exercised. The matrix includes YAML in the workflow root. Nonmarkers include the excluded `api_key`, `pass_word`, `application key`, a DSA header, and a name without a separator.

Pasted assessed output:

```text
marker -----BEGIN PRIVATE KEY-----: exit=1; four paths and marker present=True
marker -----BEGIN PRIVATE KEY----- lower: exit=1; four paths and marker present=True
marker -----BEGIN RSA PRIVATE KEY-----: exit=1; four paths and marker present=True
marker -----BEGIN RSA PRIVATE KEY----- lower: exit=1; four paths and marker present=True
marker -----BEGIN EC PRIVATE KEY-----: exit=1; four paths and marker present=True
marker -----BEGIN EC PRIVATE KEY----- lower: exit=1; four paths and marker present=True
marker -----BEGIN OPENSSH PRIVATE KEY-----: exit=1; four paths and marker present=True
marker -----BEGIN OPENSSH PRIVATE KEY----- lower: exit=1; four paths and marker present=True
marker AKIA: exit=1; four paths and marker present=True
marker AKIA lower: exit=1; four paths and marker present=True
marker application_key: bare: exit=1; four paths and marker present=True
marker application_key: spaced: exit=1; four paths and marker present=True
marker application_key: newline: exit=1; four paths and marker present=True
marker application_key= bare: exit=1; four paths and marker present=True
marker application_key= spaced: exit=1; four paths and marker present=True
marker application_key= newline: exit=1; four paths and marker present=True
marker application-key: bare: exit=1; four paths and marker present=True
marker application-key: spaced: exit=1; four paths and marker present=True
marker application-key: newline: exit=1; four paths and marker present=True
marker application-key= bare: exit=1; four paths and marker present=True
marker application-key= spaced: exit=1; four paths and marker present=True
marker application-key= newline: exit=1; four paths and marker present=True
marker applicationkey: bare: exit=1; four paths and marker present=True
marker applicationkey: spaced: exit=1; four paths and marker present=True
marker applicationkey: newline: exit=1; four paths and marker present=True
marker applicationkey= bare: exit=1; four paths and marker present=True
marker applicationkey= spaced: exit=1; four paths and marker present=True
marker applicationkey= newline: exit=1; four paths and marker present=True
marker app_key: bare: exit=1; four paths and marker present=True
marker app_key: spaced: exit=1; four paths and marker present=True
marker app_key: newline: exit=1; four paths and marker present=True
marker app_key= bare: exit=1; four paths and marker present=True
marker app_key= spaced: exit=1; four paths and marker present=True
marker app_key= newline: exit=1; four paths and marker present=True
marker app-key: bare: exit=1; four paths and marker present=True
marker app-key: spaced: exit=1; four paths and marker present=True
marker app-key: newline: exit=1; four paths and marker present=True
marker app-key= bare: exit=1; four paths and marker present=True
marker app-key= spaced: exit=1; four paths and marker present=True
marker app-key= newline: exit=1; four paths and marker present=True
marker appkey: bare: exit=1; four paths and marker present=True
marker appkey: spaced: exit=1; four paths and marker present=True
marker appkey: newline: exit=1; four paths and marker present=True
marker appkey= bare: exit=1; four paths and marker present=True
marker appkey= spaced: exit=1; four paths and marker present=True
marker appkey= newline: exit=1; four paths and marker present=True
marker password: bare: exit=1; four paths and marker present=True
marker password: spaced: exit=1; four paths and marker present=True
marker password: newline: exit=1; four paths and marker present=True
marker password= bare: exit=1; four paths and marker present=True
marker password= spaced: exit=1; four paths and marker present=True
marker password= newline: exit=1; four paths and marker present=True
Marker cases: 52; path-marker combinations: 208
Unrelated guard scans did not fail in any marker probe: True
nonmarkers: exit=0 expected=pass diagnostic_check=True
restored: exit=0 expected=pass diagnostic_check=True
```

Representative raw output for a multiline marker, retaining the reporter's actual formatting:

```text
00:00 +0: loading /private/tmp/webmcp-final-validator-q4sry1vf/test/repo_hygiene_test.dart
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
00:00 +9 -1: implementation files contain no fixed secret markers [E]
  Expected: empty
    Actual: [
              '.github/validation_marker.txt: Application_Key\n'
                ' \t :',
              'example/lib/validation_marker.dart: Application_Key\n'
                ' \t :',
              'lib/validation_marker.json: Application_Key\n'
                ' \t :',
              'tools/validation_marker: Application_Key\n'
                ' \t :'
            ]
  .github/validation_marker.txt: Application_Key
   	 :
  example/lib/validation_marker.dart: Application_Key
   	 :
  lib/validation_marker.json: Application_Key
   	 :
  tools/validation_marker: Application_Key
   	 :
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 337:5                   main.<fn>
  
00:00 +9 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-final-validator-q4sry1vf/test/repo_hygiene_test.dart: implementation files contain no fixed secret markers
```

Final restored hygiene command: `flutter test --reporter expanded test/repo_hygiene_test.dart (restored)`. Exit: 0. Pasted output:

```text
00:00 +0: loading /private/tmp/webmcp-final-extra-r7fxna6e/test/repo_hygiene_test.dart
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

### Actual filesystem and tracking

Command: Python filesystem existence checks plus `git ls-files -- <path>` in the actual checkout. Exit: 0. Pasted output:

```text
lib: exists=True tracked=True
example: exists=True tracked=True
test: exists=True tracked=True
README.md: exists=True tracked=True
CHANGELOG.md: exists=True tracked=True
analysis_options.yaml: exists=True tracked=True
pubspec.yaml: exists=True tracked=True
LICENSE: exists=True tracked=True
```

The MIT holder authorization supplied for this round is `flutter_webmcp`; the existing license uses that literal. No live CI or push is inferred.

## Per-criterion results

“Reused R01” means the previous independent validator actually ran the negative and pasted the output at the cited lines. The implementation and relevant unchanged checks were byte-compared as above. “New” refers to independently executed evidence in this report. A passing prescribed simple negative does not override a valid bypass that violates the universal criterion.

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
| AC-017 | pass | `test/webmcp_public_surface_test.dart:1,25; test/repo_hygiene_test.dart:286` | New — all 12 required names/seven operations present; handler hiding and exception/action export removal fail compilation; private comment-separated import fails hygiene. |
| AC-018 | fail | `test/repo_hygiene_test.dart:117,149,261` | New — multiline/comment/conditional directives fail and diagnose correctly; valid escaped dart:io URI passes full root/example tests (F-001). |
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
| AC-031 | pass | `tools/check.sh:20` | Reused R01 — Warm second run 27.27s; inserted 400-second delay measured 429.54s (`impl-review-01.md:2229–2274`). New full run: 25.47s. |
| AC-032 | pass | `test/repo_hygiene_test.dart:167,172,313; 06-plan-amendment.md:13` | New — all 52 marker variants fail across 208 path/marker combinations, all four roots, tracked/new files, and extension variants; each offending path/marker is diagnosed. |
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
| AC-044 | fail | `test/repo_hygiene_test.dart:117,271` | New — ordinary outside-widget multiline/comment/conditional Flutter imports fail; escaped Flutter URI compiles and passes all root tests (F-001). |
| AC-045 | pass | `test/webmcp_scope_test.dart:1; test/repo_hygiene_test.dart:286` | New — comment-separated flutter_test import fails hygiene and names URI; full suite runs the unchanged VM scope tests. No pumpWidget in scope test. |
| AC-046 | pass | `example/lib/example_screen.dart:15,59; example/lib/main.dart:3,16` |Reused R01 — Deleting example screen produced missing URI and undefined class errors. Actual command/output: `impl-review-01.md:1709–1724`. |

## Findings

### F-001 — Dart Unicode escapes bypass the import boundaries

- Severity: BLOCKER
- Location: `test/repo_hygiene_test.dart:117` (comparison consumers at lines 149 and 278)
- Criteria affected: AC-018, AC-044
- Observation: `_readString` handles a backslash by appending only the next source character. It therefore tokenizes `dart:\u0069o` as `dart:u0069o` instead of the resolved `dart:io`. A valid `import 'dart:\u0069o';` in `example/lib/example_tools.dart` passes all 35 root tests and the example test. Likewise, `import 'package:\u0066lutter/widgets.dart';` in `lib/src/webmcp.dart` compiles and passes all 35 root tests despite importing Flutter outside the widget directory. The standalone Dart execution above independently confirms the first URI's resolution.
- Why it matters: The criteria apply to any matching import directive, not only URIs without valid Dart string escapes. The test stage fails to reject or name these offending imports. The unmodified full-suite success does not establish that boundary.

## Recurrence check

- Previous round: [implementation review 01](impl-review-01.md).
- Recurring findings: previous F-002's material contract failure remains as this round's F-001: valid forbidden directives can pass the test stage. The previously demonstrated whitespace/comment forms now fail correctly; the remaining case is Dart URI escape decoding, a different lexical form with the same violated import boundary.
- Previous F-001: not recurring; the explicit public handler type reference is present and export-removal probes reject it.
- Previous F-003: not recurring; the normative amendment defines the complete marker set, and the exhaustive independent matrix conforms.
- Oscillating: no. No fixed behavior was observed to revert; a residual case remains in the import recognizer.

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | implement |
