---
id: 0004-impl-review-04
title: Flutter WebMCP skeleton implementation review round 04
status: active
owner: validator
last_verified: 2026-09-10
applies_to: ["lib/**", "test/**", "example/**", "tools/check.sh", "pubspec.yaml"]
summary: Independent final validation confirms analyzer-based import semantics, unchanged marker coverage and all 46 frozen criteria.
---

# Implementation review — round 04

- Work item: 0004-flutter-webmcp-skeleton
- Reviewed artifact: current source and staged diff against dccbad724308ce93f75fb95580282b18292ad0df, with normative amendments 06 and 09.
- Reviewer: independent ast_final_validator subagent
- Date: 2026-09-10
- Inputs: frozen 02-criteria.md, normative 06-plan-amendment.md and 09-parser-plan-amendment.md, current source/diff, rubric/template, and previous independent impl-review-01/02/03 reports for unchanged evidence and recurrence. Author 04/05/07/08/10 artifacts, transcript and original plan rationale were not read. STATE.yaml was read as required by the repository router; its assertions are not verification evidence.

## Verdict

**PASS**

All 46 frozen criteria are met within their stated scope. The legal import forms that previously bypassed AC-018 and AC-044 now compile independently and fail the policy scan with the offending path and decoded URI. The full suite exits zero in 31.15 seconds. AC-026's explicitly optional live CI portion remains pending.

## Verification performed

This validator independently ran the commands below. Only this report was written in the real repository. Synthetic mutations were restricted to /private/tmp/webmcp-ast-review04-fgx4c5e7 with its own Git index. Each import mutation was restored and its hygiene baseline rerun before the next valid import case. No real source, index, HEAD, commit or push was changed by this validator. The authorized license holder is flutter_webmcp. Verification covers local VM execution, analysis and web compilation; it does not claim browser behavior or a live GitHub Actions run.

### Full suite

Command: `PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH /usr/bin/time -p bash tools/check.sh`.

The first sandbox attempt could not write the SDK cache and exited 1. This environmental failure was resolved by approved cache access for the same command; no source change was made. Exact initial output:

```text
Preflight: flutter and dart found
lint_wiki: clean (0 warning(s)).
Stage 1 passed: wiki lint
/Users/ortalcohen/fvm/versions/3.47.0/bin/internal/update_engine_version.sh: line 71: /Users/ortalcohen/fvm/versions/3.47.0/bin/cache/engine.stamp.tmp.48842: Operation not permitted
/Users/ortalcohen/fvm/versions/3.47.0/bin/internal/update_engine_version.sh: line 78: /Users/ortalcohen/fvm/versions/3.47.0/bin/cache/engine.realm: Operation not permitted
Stage 2 failed: dependencies
real 0.38
user 0.07
sys 0.07
```

The approved execution exited 0. Exact output:

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
00:00 +0: loading /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart
00:00 +0: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: registers tools and lists them in ascending order
00:00 +1: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: registers sources through duplicate validation
00:00 +2: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: rejects duplicates without replacing the first handler
00:00 +3: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: validates empty, long, and unsupported names
00:00 +4: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: passes arguments through and awaits the handler
00:00 +5: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: throws for a missing tool without invoking another handler
00:00 +6: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: unregister is idempotent
00:00 +7: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +8: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +9: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action registers verbatim and unregisters independently
00:00 +10: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +11: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action forwards invocation to the latest callback
00:00 +12: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action keeps its mounted descriptor identity until replacement
00:00 +13: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action copies its input schema
00:00 +14: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
00:00 +15: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: duplicate actions preserve the first owner
00:00 +16: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: invalid action names fail loudly
00:01 +17: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: selects noop on the Dart VM and resets transport
00:01 +18: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: notifies registration and unregistration in order
00:01 +19: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_public_surface_test.dart: exports the complete public API and seven registry operations
00:01 +20: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction recognizes whitespace, comments, and conditional targets
00:01 +21: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction recognizes whitespace, comments, and conditional targets
00:01 +22: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction recognizes whitespace, comments, and conditional targets
00:01 +23: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction recognizes whitespace, comments, and conditional targets
00:01 +24: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction recognizes whitespace, comments, and conditional targets
00:01 +25: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction recognizes whitespace, comments, and conditional targets
00:01 +26: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction ignores exports, comments, strings, and conditional values
00:01 +27: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction uses compiler semantics for initial newlines in triple strings
00:01 +28: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction uses compiler semantics for encoded import URIs
00:01 +29: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction preserves raw ordinary literal content
00:01 +30: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction surfaces parser diagnostics with the source path
00:01 +31: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction classifies only the fixed forbidden import families
00:01 +32: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: secret detector fixtures matches every fixed header and the bare AWS prefix
00:01 +33: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: secret detector fixtures matches every assignment spelling and separator
00:01 +34: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: secret detector fixtures does not infer markers outside the exhaustive set
00:01 +35: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:01 +36: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: Flutter imports stay inside the widget layer
00:01 +37: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: public and scope tests preserve their import boundaries
00:01 +38: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: implementation files contain no fixed secret markers
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
Compiling lib/main.dart for the Web...                             18.8s
✓ Built build/web
Stage 6 passed: build
real 31.15
user 33.45
sys 5.83
```

The existing font-family diagnostic is unchanged from prior independent runs and did not fail compilation. The generated example/build/web/index.html exists. The suite runs 39 root tests and one example test.

### Source comparison and independent evidence reuse

Command: Python byte comparison against `git -C /private/tmp/webmcp-validator-xeh_qiad show aad36edce1467895c17d7b2248970c74502ff197:<path>` for implementation/configuration/documentation paths; comparison of runtime/public-surface files with the independent R03 snapshot; filesystem check for the generated entry. Exit 0. Exact output:

```text
Changed compared with independent R01 committed snapshot: ['pubspec.yaml', 'test/repo_hygiene_test.dart', 'test/webmcp_public_surface_test.dart']
R03 runtime/public-surface files byte-identical: True
example/build/web/index.html exists: True
```

The complete original snapshot comparison governs reuse. The first line of the probe harness's inventory below also labels absent files in the intentionally partial R03 snapshot as changed; those absent auxiliary files are not additional implementation changes. The explicit runtime/public-surface and secret-segment comparisons are byte comparisons of files present in both snapshots.

The manifest adds analyzer ^13.3.0 only under dev_dependencies at pubspec.yaml:14; dependency resolution above confirms analyzer 13.3.0. Runtime lib/ contains no analyzer imports. The detector imports the two public analyzer libraries at test/repo_hygiene_test.dart:3–4, visits ImportDirective and each Configuration URI at lines 29–33, and uses StringLiteral.stringValue at line 40. Parser diagnostics at line 22 and unavailable values at line 41 fail closed with source-path context. There is no manual tokenizer or escape decoder left. Secret matching and file enumeration are unchanged.

R01/R02 in the per-criterion table mean previously executed independent negatives and pasted command outputs, with exact report line references. They are reused only for byte-identical behavior. The changed parser is exercised afresh below. The unchanged 400-second timing mutation and exhaustive 52-marker campaign were not needlessly repeated.

### Bounded compiler and hygiene probes

Command: `python3 /tmp/ast-final-probes.py`, using the pinned Flutter bin directory on PATH. For each legal forbidden directive the script writes an isolated source file, then independently compiles the same directive: `dart run validator_compile.dart` for dart:io, or `flutter test --no-pub --reporter expanded test/validator_compile_test.dart` for Flutter imports. The VM script references Platform; the Flutter fixture constructs SizedBox and verifies Widget. Compilation is distinct from `flutter test --no-pub --reporter expanded test/repo_hygiene_test.dart`, whose nonzero exit and offending path plus decoded URI are asserted. Both source roots are represented. Exit 0. Exact harness output:

```text
Snapshot: /private/tmp/webmcp-ast-review04-fgx4c5e7
Changed implementation versus independent R03 snapshot: ['.claude/agents/doc-keeper.md', '.claude/agents/impl-validator.md', '.claude/agents/implementer.md', '.claude/agents/plan-validator.md', '.claude/agents/planner.md', '.claude/agents/research-validator.md', '.claude/agents/researcher.md', '.claude/agents/synthesizer.md', '.claude/hooks/lint_on_stop.py', '.claude/hooks/lint_on_write.py', '.claude/rules/agent-config.md', '.claude/rules/wiki-artifacts.md', '.claude/settings.json', '.claude/skills/bootstrap-product/SKILL.md', '.claude/skills/build/SKILL.md', '.claude/skills/document/SKILL.md', '.claude/skills/feature/SKILL.md', '.claude/skills/implement/SKILL.md', '.claude/skills/plan/SKILL.md', '.claude/skills/quick-change/SKILL.md', '.claude/skills/research/SKILL.md', '.claude/skills/validate/SKILL.md', '.claude/skills/verify/SKILL.md', '.cursor/hooks.json', '.cursor/hooks/lint_on_write.sh', '.cursor/rules/agent-config.mdc', '.cursor/rules/wiki-artifacts.mdc', 'AGENTS.md', 'CHANGELOG.md', 'CLAUDE.md', 'LICENSE', 'README.md', 'pubspec.yaml', 'test/repo_hygiene_test.dart']
Unchanged secret segment final RegExp _secretMarker : True
Unchanged secret segment   test('implementation files contain no fixed secret markers' : True
Runtime analyzer imports: []
Analyzer declared only under dev_dependencies: True
baseline exit= 0
triple-ordinary-0-io: compiler=0; hygiene=1; path+decoded-URI=True
triple-ordinary-0-io: restored=0
triple-ordinary-1-flutter: compiler=0; hygiene=1; path+decoded-URI=True
triple-ordinary-1-flutter: restored=0
triple-ordinary-2-io: compiler=0; hygiene=1; path+decoded-URI=True
triple-ordinary-2-io: restored=0
triple-ordinary-3-flutter: compiler=0; hygiene=1; path+decoded-URI=True
triple-ordinary-3-flutter: restored=0
triple-r-4-io: compiler=0; hygiene=1; path+decoded-URI=True
triple-r-4-io: restored=0
triple-r-5-flutter: compiler=0; hygiene=1; path+decoded-URI=True
triple-r-5-flutter: restored=0
triple-r-6-io: compiler=0; hygiene=1; path+decoded-URI=True
triple-r-6-io: restored=0
triple-r-7-flutter: compiler=0; hygiene=1; path+decoded-URI=True
triple-r-7-flutter: restored=0
unicode-fixed-io: compiler=0; hygiene=1; path+decoded-URI=True
unicode-fixed-io: restored=0
unicode-braced-io: compiler=0; hygiene=1; path+decoded-URI=True
unicode-braced-io: restored=0
hex-io: compiler=0; hygiene=1; path+decoded-URI=True
hex-io: restored=0
unicode-fixed-flutter: compiler=0; hygiene=1; path+decoded-URI=True
unicode-fixed-flutter: restored=0
unicode-braced-flutter: compiler=0; hygiene=1; path+decoded-URI=True
unicode-braced-flutter: restored=0
hex-flutter: compiler=0; hygiene=1; path+decoded-URI=True
hex-flutter: restored=0
nested-comment: compiler=0; hygiene=1; path+decoded-URI=True
nested-comment: restored=0
conditional-target: compiler=0; hygiene=1; path+decoded-URI=True
conditional-target: restored=0
raw-ordinary: compiler=0; hygiene=1; path+decoded-URI=True
raw-ordinary: restored=0
comparison-value: hygiene=0
lookalikes: hygiene=0
allowed-import: hygiene=0
widget-exception: hygiene= 0
invalid-escape: hygiene=1; fail-closed+path=True
unavailable-value: hygiene=1; fail-closed+path=True
unclosed-comment: hygiene=1; fail-closed+path=True
aws: hygiene=1; path+marker=True
key: hygiene=1; path+marker=True
assignment: hygiene=1; path+marker=True
final restored: hygiene= 0
ALL BOUNDED PROBES MATCHED EXPECTED RESULTS
```

Controls cover conditional comparison values, exports, comment/string lookalikes, allowed dart:async imports and the widget-directory exception. Invalid escape, interpolation/unavailable URI, and unfinished-comment fixtures are diagnostic tests, not valid-import evidence. Three fresh marker probes cover tracked YAML, non-Dart text and mixed-case assignment whitespace across a newline.

Command: `python3 /tmp/ast-final-extra.py`. It applies a triple-quoted private import to the public-surface test and a raw triple-quoted Flutter test import to the scope test, exercising the changed parser at both remaining policy consumers; restoration is checked after each. It also independently compiles the conditional comparison-value control with `dart run validator_control.dart`. Exit 0. Exact output:

```text
public-private: hygiene=1; decoded-URI=True
public-private restored: hygiene=0
scope-flutter: hygiene=1; decoded-URI=True
scope-flutter restored: hygiene=0
comparison-value compiler: exit= 0 output= comparison control compiled
ALL ADDITIONAL BOUNDARY PROBES MATCHED EXPECTED RESULTS
```

### Representative raw probe output

The following unabridged records retain the actual compiler and hygiene command output for prior-bypass forms, controls and diagnostic rejection. All other bounded cases and expected exits are shown in the harness output above.

Command (triple-ordinary-0-io compiler): `dart run /private/tmp/webmcp-ast-review04-fgx4c5e7/validator_compile.dart`. Exit 0. Exact output:

```text
macos
```

Command (triple-ordinary-0-io): `flutter test --no-pub --reporter expanded test/repo_hygiene_test.dart`. Exit 1. Exact output:

```text
00:00 +0: loading /private/tmp/webmcp-ast-review04-fgx4c5e7/test/repo_hygiene_test.dart
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
00:00 +10 -1: library and example sources avoid forbidden imports [E]
  Expected: empty
    Actual: ['example/lib/validator_probe.dart: import dart:io']
  example/lib/validator_probe.dart: import dart:io
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 232:5                   main.<fn>
  
00:00 +10 -1: Flutter imports stay inside the widget layer
00:00 +11 -1: public and scope tests preserve their import boundaries
00:00 +12 -1: implementation files contain no fixed secret markers
00:00 +13 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-ast-review04-fgx4c5e7/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
```

Command (triple-r-5-flutter compiler): `flutter test --no-pub --reporter expanded /private/tmp/webmcp-ast-review04-fgx4c5e7/test/validator_compile_test.dart`. Exit 0. Exact output:

```text
00:00 +0: loading /private/tmp/webmcp-ast-review04-fgx4c5e7/test/validator_compile_test.dart
00:00 +0: compiler fixture
00:00 +1: All tests passed!
```

Command (triple-r-5-flutter): `flutter test --no-pub --reporter expanded test/repo_hygiene_test.dart`. Exit 1. Exact output:

```text
00:00 +0: loading /private/tmp/webmcp-ast-review04-fgx4c5e7/test/repo_hygiene_test.dart
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
00:00 +11 -1: Flutter imports stay inside the widget layer [E]
  Expected: empty
    Actual: ['lib/validator_probe.dart: import package:flutter/widgets.dart']
  lib/validator_probe.dart: import package:flutter/widgets.dart
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 247:5                   main.<fn>
  
00:00 +11 -1: public and scope tests preserve their import boundaries
00:00 +12 -1: implementation files contain no fixed secret markers
00:00 +13 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-ast-review04-fgx4c5e7/test/repo_hygiene_test.dart: Flutter imports stay inside the widget layer
```

Command (conditional-target): `flutter test --no-pub --reporter expanded test/repo_hygiene_test.dart`. Exit 1. Exact output:

```text
00:00 +0: loading /private/tmp/webmcp-ast-review04-fgx4c5e7/test/repo_hygiene_test.dart
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
00:00 +10 -1: library and example sources avoid forbidden imports [E]
  Expected: empty
    Actual: ['lib/validator_probe.dart: import dart:io']
  lib/validator_probe.dart: import dart:io
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 232:5                   main.<fn>
  
00:00 +10 -1: Flutter imports stay inside the widget layer
00:00 +11 -1: public and scope tests preserve their import boundaries
00:00 +12 -1: implementation files contain no fixed secret markers
00:00 +13 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-ast-review04-fgx4c5e7/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
```

Command (comparison-value): `flutter test --no-pub --reporter expanded test/repo_hygiene_test.dart`. Exit 0. Exact output:

```text
00:00 +0: loading /private/tmp/webmcp-ast-review04-fgx4c5e7/test/repo_hygiene_test.dart
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
```

Command (invalid-escape): `flutter test --no-pub --reporter expanded test/repo_hygiene_test.dart`. Exit 1. Exact output:

```text
00:00 +0: loading /private/tmp/webmcp-ast-review04-fgx4c5e7/test/repo_hygiene_test.dart
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
00:00 +10 -1: library and example sources avoid forbidden imports [E]
  FormatException: Unable to inspect imports in lib/validator_probe.dart:
  lib/validator_probe.dart(13..14): An escape sequence starting with '\x' must be followed by 2 hexadecimal digits.
  test/repo_hygiene_test.dart 23:5    _importUris
  test/repo_hygiene_test.dart 62:5    _importViolations
  test/repo_hygiene_test.dart 229:27  main.<fn>
  
00:00 +10 -1: Flutter imports stay inside the widget layer
00:00 +10 -2: Flutter imports stay inside the widget layer [E]
  FormatException: Unable to inspect imports in lib/validator_probe.dart:
  lib/validator_probe.dart(13..14): An escape sequence starting with '\x' must be followed by 2 hexadecimal digits.
  test/repo_hygiene_test.dart 23:5    _importUris
  test/repo_hygiene_test.dart 62:5    _importViolations
  test/repo_hygiene_test.dart 240:11  main.<fn>
  
00:00 +10 -2: public and scope tests preserve their import boundaries
00:00 +11 -2: implementation files contain no fixed secret markers
00:00 +12 -2: Some tests failed.

Failing tests:
  /private/tmp/webmcp-ast-review04-fgx4c5e7/test/repo_hygiene_test.dart: Flutter imports stay inside the widget layer
  /private/tmp/webmcp-ast-review04-fgx4c5e7/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
```

Command (unavailable-value): `flutter test --no-pub --reporter expanded test/repo_hygiene_test.dart`. Exit 1. Exact output:

```text
00:00 +0: loading /private/tmp/webmcp-ast-review04-fgx4c5e7/test/repo_hygiene_test.dart
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
00:00 +10 -1: library and example sources avoid forbidden imports [E]
  FormatException: Unable to inspect import URI in lib/validator_probe.dart at offset 7.
  test/repo_hygiene_test.dart 42:5    _addUri
  test/repo_hygiene_test.dart 31:5    _importUris
  test/repo_hygiene_test.dart 62:5    _importViolations
  test/repo_hygiene_test.dart 229:27  main.<fn>
  
00:00 +10 -1: Flutter imports stay inside the widget layer
00:00 +10 -2: Flutter imports stay inside the widget layer [E]
  FormatException: Unable to inspect import URI in lib/validator_probe.dart at offset 7.
  test/repo_hygiene_test.dart 42:5    _addUri
  test/repo_hygiene_test.dart 31:5    _importUris
  test/repo_hygiene_test.dart 62:5    _importViolations
  test/repo_hygiene_test.dart 240:11  main.<fn>
  
00:00 +10 -2: public and scope tests preserve their import boundaries
00:00 +11 -2: implementation files contain no fixed secret markers
00:00 +12 -2: Some tests failed.

Failing tests:
  /private/tmp/webmcp-ast-review04-fgx4c5e7/test/repo_hygiene_test.dart: Flutter imports stay inside the widget layer
  /private/tmp/webmcp-ast-review04-fgx4c5e7/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
```

Command (assignment): `flutter test --no-pub --reporter expanded test/repo_hygiene_test.dart`. Exit 1. Exact output:

```text
00:00 +0: loading /private/tmp/webmcp-ast-review04-fgx4c5e7/test/repo_hygiene_test.dart
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
00:00 +13 -1: implementation files contain no fixed secret markers [E]
  Expected: empty
    Actual: [
              'example/lib/validator-marker.txt: ApPlIcAtIoN_KeY\n'
                ' ='
            ]
  example/lib/validator-marker.txt: ApPlIcAtIoN_KeY
   =
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test/repo_hygiene_test.dart 303:5                   main.<fn>
  
00:00 +13 -1: Some tests failed.

Failing tests:
  /private/tmp/webmcp-ast-review04-fgx4c5e7/test/repo_hygiene_test.dart: implementation files contain no fixed secret markers
```

Command (final restored): `flutter test --no-pub --reporter expanded test/repo_hygiene_test.dart`. Exit 0. Exact output:

```text
00:00 +0: loading /private/tmp/webmcp-ast-review04-fgx4c5e7/test/repo_hygiene_test.dart
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
```

## Per-criterion results

Each row records a verdict, current file-and-line evidence, and new or explicitly reused independent negative evidence. Live CI is pending only where the frozen criterion expressly permits it.

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
| AC-017 | pass | `test/webmcp_public_surface_test.dart:1,25; test/repo_hygiene_test.dart:250` | Reused R02 export-removal and handler evidence (`impl-review-02.md:141–259`) on byte-identical public test; new triple-quoted private import fails with decoded URI. |
| AC-018 | pass | `test/repo_hygiene_test.dart:16,29,49,225` | New: 17 independently compiler-accepted import probes, spanning raw/ordinary triples, both quote styles, fixed/braced Unicode, hex, nested comments, conditional URI and raw ordinary import. All fail with offending path and decoded URI; root and example source roots are exercised. |
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
| AC-029 | pass | `pubspec.yaml:20` | Reused R01 web-only map and added-android negative (`impl-review-01.md:2159–2169`); the current map is byte-identical and only analyzer was added under development dependencies. |
| AC-030 | pass | `AGENTS.md:71` |Reused R01 — Checks heading deletion failed predicate; 76 lines, all four commands present, wiki lint clean. Actual command/output: `impl-review-01.md:2170–2180`. |
| AC-031 | pass | `tools/check.sh:20` | Reused R01 warm second run 27.27s and 400-second delay negative 429.54s (`impl-review-01.md:2229–2274`), with unchanged script. New independently timed full suite: 31.15s. |
| AC-032 | pass | `test/repo_hygiene_test.dart:67,73,279; 06-plan-amendment.md:13` | Reused independent R02 exhaustive 52-marker/208-path matrix (`impl-review-02.md:562–691`); recognizer and file scan remain byte-identical. New tracked YAML bare AWS prefix, non-Dart OpenSSH header and mixed-case newline assignment all fail with path and marker. |
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
| AC-044 | pass | `test/repo_hygiene_test.dart:16,29,235,242` | New compiler-accepted Flutter imports in every raw/ordinary initial-newline triple form and fixed/braced Unicode/hex form fail with path and decoded URI; widget-directory raw triple import passes. |
| AC-045 | pass | `test/webmcp_scope_test.dart:1; test/repo_hygiene_test.dart:250,269` | Reused R02 comment-separated import/pump negative (`impl-review-02.md:260–444`); new raw triple-quoted flutter_test import fails with decoded URI. Full suite executes unchanged add/skip/remove/close tests. |
| AC-046 | pass | `example/lib/example_screen.dart:15,59; example/lib/main.dart:3,16` |Reused R01 — Deleting example screen produced missing URI and undefined class errors. Actual command/output: `impl-review-01.md:1709–1724`. |

## Findings

None.

## Recurrence check

- Previous round: [implementation review 03](impl-review-03.md).
- Recurring findings: none. Round 03 F-001's initial-newline triple forms now independently compile and produce the required rejection for ordinary/raw strings and both quote styles. Round 02's Unicode/hex forms retain rejection. Round 01's explicit handler reference and exhaustive marker contract remain satisfied.
- Oscillating: no. No previously fixed behavior was observed to revert.

## Routing

| Finding | Belongs to phase |
|---|---|
| None | Not applicable |

## Report lint

Command: `python3 tools/lint_wiki.py`. Exit 0. Exact output after writing this report:

```text
lint_wiki: clean (0 warning(s)).
```
