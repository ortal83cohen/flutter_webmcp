# Prepublication verification

Only pubspec.yaml and CHANGELOG.md differ from the published0.1.0 candidate. Full raw outputs below show the canonical suite, both payload builds, preservation, synthetic rejection gates and ordinary zero-warning final publisher selection after generated example files exist. The excluded .pubignore is retained in the candidate. The prior runtime/browser evidence remains applicable to identical runtime bytes; no browser test is newly claimed. Hosted checks remain postpublication gates.

## source-checks

Command arguments: `["python3", "/private/tmp/webmcp-release-011-run/source_checks.py"]`

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

```text
PASS: parsed manifest changes only version and exact repository; changelog adds only the metadata release.
Expected rejection: missing repository
Expected rejection: wrong repository
Expected rejection: wrong version
Expected rejection: changed dependency
PASS: all unrelated source/config bytes and prior0005 STATE unchanged.
Index entries equal baseline: True
Current index entries SHA-256: 2485f324580eb7636e2a735f9a496a78e3360bea6b556e82c4d72abcd4942434

Exit: 0
```

## candidate-create

Command arguments: `["python3", "/private/tmp/webmcp-release-011-run/candidate.py", "create"]`

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

```text
Candidate22 files:20 unchanged from published0.1.0; only pubspec.yaml and CHANGELOG.md differ.
Excluded .pubignore copied unchanged from reviewed source.
Inventory SHA-256: 2b693d47cf8b6162287ccf66fe680565628fa13811e4de7b340354b0d3a6fe8b

Exit: 0
```

## consumer-create

Command arguments: `["python3", "/private/tmp/webmcp-release-011-run/consumer.py", "create"]`

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

```text
Created fresh consumer with README sample and only payload dependency: /private/tmp/webmcp-release-011-run/payload

Exit: 0
```

## full-suite

Command arguments: `["bash", "tools/check.sh"]`

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

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
Formatted 24 files (0 changed) in 0.05 seconds.
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
00:00 +1: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +2: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: registers sources through duplicate validation
00:00 +3: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: source registration retains tools added before a later failure
00:00 +4: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: rejects duplicates without replacing the first handler
00:00 +5: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: validates empty, long, and unsupported names
00:00 +6: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: passes arguments through and awaits the handler
00:00 +7: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: passes handler result and exception objects through unchanged
00:00 +8: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: input schema is shallow copied and is not runtime validation
00:00 +9: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: throws for a missing tool without invoking another handler
00:00 +10: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: unregister is idempotent
00:00 +11: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: screen mixin registers while mounted and closes on dispose
00:00 +12: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action registers verbatim and unregisters independently
00:00 +13: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action returns the identical tappable child
00:00 +14: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action forwards invocation to the latest callback
00:00 +15: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: disabled child does not disable direct tool invocation
00:00 +16: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action keeps its mounted descriptor identity until replacement
00:00 +17: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action copies its input schema
00:00 +18: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
00:00 +19: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: duplicate actions preserve the first owner
00:00 +20: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: invalid action names fail loudly
00:02 +21: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction recognizes whitespace, comments, and conditional targets
00:02 +22: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction ignores exports, comments, strings, and conditional values
00:02 +23: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction uses compiler semantics for initial newlines in triple strings
00:02 +24: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction uses compiler semantics for encoded import URIs
00:02 +25: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction preserves raw ordinary literal content
00:02 +26: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction surfaces parser diagnostics with the source path
00:02 +27: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction classifies only the fixed forbidden import families
00:02 +28: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: secret detector fixtures matches every fixed header and the bare AWS prefix
00:02 +29: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: secret detector fixtures matches every assignment spelling and separator
00:02 +30: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: secret detector fixtures does not infer markers outside the exhaustive set
00:02 +31: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:03 +32: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: Flutter imports stay inside the widget layer
00:03 +33: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: public and scope tests preserve their import boundaries
00:03 +34: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: implementation files contain no fixed secret markers
00:03 +35: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: selects noop on the Dart VM and resets transport
00:03 +36: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: notifies registration and unregistration in order
00:03 +37: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: registration notification failure propagates after mutation
00:03 +38: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: unregistration notification failure propagates after mutation
00:03 +39: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: reset clears tools and replaces transport without notifications
00:03 +40: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_public_surface_test.dart: exports the complete public API and seven registry operations
00:04 +41: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: adds direct and source tools, then closes
00:04 +42: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: skips duplicates and never removes another owner
00:04 +43: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: remove is limited to names owned by the scope
00:04 +44: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: close is idempotent and closed scopes reject additions
00:04 +45: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: invalid names propagate without becoming owned or skipped
00:04 +46: All tests passed!
Waiting for another flutter command to release the startup lock...
00:00 +0: loading /Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/test/example_tools_test.dart
00:00 +0: registers two imperative tools and increments the counter
00:00 +1: All tests passed!
Stage 5 passed: tests
Waiting for another flutter command to release the startup lock...
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 7736 bytes (99.5% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             25.0s
✓ Built build/web
Stage 6 passed: build

Exit: 0
```

## consumer-build

Command arguments: `["flutter", "build", "web"]`

Working directory: `/private/tmp/webmcp-release-011-run/consumer`

```text
Resolving dependencies...
Downloading packages...
+ characters 1.4.1
+ collection 1.19.1
+ flutter 0.0.0 from sdk flutter
+ material_color_utilities 0.13.0 (0.13.1 available)
+ meta 1.19.0
+ sky_engine 0.0.0 from sdk flutter
+ vector_math 2.4.2
+ web 1.1.1
+ webmcp_flutter 0.1.1 from path /private/tmp/webmcp-release-011-run/payload
Changed 9 dependencies!
1 package has newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 7736 bytes (99.5% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             23.8s
✓ Built build/web

Exit: 0
```

## example-build

Command arguments: `["flutter", "build", "web"]`

Working directory: `/private/tmp/webmcp-release-011-run/payload/example`

```text
Resolving dependencies...
Downloading packages...
+ async 2.13.1
+ boolean_selector 2.1.2
+ characters 1.4.1
+ clock 1.1.3
+ collection 1.19.1
+ fake_async 1.3.3
+ flutter 0.0.0 from sdk flutter
+ flutter_lints 6.0.0
+ flutter_test 0.0.0 from sdk flutter
+ leak_tracker 11.0.2
+ leak_tracker_flutter_testing 3.0.10
+ leak_tracker_testing 3.0.2
+ lints 6.1.0
+ matcher 0.12.20
+ material_color_utilities 0.13.0 (0.13.1 available)
+ meta 1.19.0
+ path 1.9.1
+ sky_engine 0.0.0 from sdk flutter
+ source_span 1.10.2
+ stack_trace 1.12.2
+ stream_channel 2.1.4
+ string_scanner 1.4.1
+ term_glyph 1.2.2
+ test_api 0.7.12 (0.7.14 available)
+ vector_math 2.4.2
+ vm_service 15.3.0
+ web 1.1.1
+ webmcp_flutter 0.1.1 from path ..
Changed 28 dependencies!
2 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 7736 bytes (99.5% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             24.3s
✓ Built build/web

Exit: 0
```

## provenance

Command arguments: `["python3", "/private/tmp/webmcp-release-011-run/consumer.py", "provenance"]`

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

```text
consumer: webmcp_flutter resolves ONLY to /private/tmp/webmcp-release-011-run/payload
web build index: True
payload/example: webmcp_flutter resolves ONLY to /private/tmp/webmcp-release-011-run/payload
web build index: True

Exit: 0
```

## final-dry

Command arguments: `["dart", "pub", "publish", "--dry-run"]`

Working directory: `/private/tmp/webmcp-release-011-run/payload`

```text
Resolving dependencies...
Downloading packages...
+ _fe_analyzer_shared 103.0.0 (107.0.0 available)
+ analyzer 13.3.0 (14.3.0 available)
+ args 2.7.0
+ async 2.13.1
+ boolean_selector 2.1.2
+ characters 1.4.1
+ cli_config 0.2.0
+ clock 1.1.3
+ collection 1.19.1
+ convert 3.1.2
+ coverage 1.15.1
+ crypto 3.0.7
+ fake_async 1.3.3
+ file 7.0.1
+ flutter 0.0.0 from sdk flutter
+ flutter_lints 6.0.0
+ flutter_test 0.0.0 from sdk flutter
+ frontend_server_client 4.0.0
+ glob 2.2.0
+ http_multi_server 3.2.2
+ http_parser 4.1.2
+ io 1.1.0
+ leak_tracker 11.0.2
+ leak_tracker_flutter_testing 3.0.10
+ leak_tracker_testing 3.0.2
+ lints 6.1.0
+ logging 1.3.0
+ matcher 0.12.20
+ material_color_utilities 0.13.0 (0.13.1 available)
+ meta 1.19.0
+ mime 2.1.0
+ node_preamble 2.0.2
+ package_config 2.2.0 (3.0.0 available)
+ path 1.9.1
+ pool 1.5.3
+ pub_semver 2.2.1
+ shelf 1.4.2
+ shelf_packages_handler 3.0.2
+ shelf_static 1.1.3
+ shelf_web_socket 3.0.0
+ sky_engine 0.0.0 from sdk flutter
+ source_map_stack_trace 2.1.2
+ source_maps 0.10.14
+ source_span 1.10.2
+ stack_trace 1.12.2
+ stream_channel 2.1.4
+ string_scanner 1.4.1
+ term_glyph 1.2.2
+ test 1.31.1 (1.32.0 available)
+ test_api 0.7.12 (0.7.14 available)
+ test_core 0.6.18 (0.6.20 available)
+ typed_data 1.4.0
+ vector_math 2.4.2
+ vm_service 15.3.0
+ watcher 1.2.1
+ web 1.1.1
+ web_socket 1.0.1
+ web_socket_channel 3.0.3
+ webkit_inspection_protocol 1.2.1
+ yaml 3.1.4
Changed 60 dependencies!
7 packages have newer versions incompatible with dependency constraints.
Try `dart pub outdated` for more information.
Publishing webmcp_flutter 0.1.1 to https://pub.dev:
├── CHANGELOG.md (<1 KB)
├── LICENSE (1 KB)
├── README.md (3 KB)
├── example
│   ├── analysis_options.yaml (<1 KB)
│   ├── lib
│   │   ├── example_screen.dart (2 KB)
│   │   ├── example_tools.dart (<1 KB)
│   │   └── main.dart (<1 KB)
│   ├── pubspec.yaml (<1 KB)
│   └── web
│       └── index.html (<1 KB)
├── lib
│   ├── src
│   │   ├── transport
│   │   │   ├── transport_noop.dart (<1 KB)
│   │   │   ├── transport_selector.dart (<1 KB)
│   │   │   ├── transport_web.dart (1 KB)
│   │   │   └── webmcp_transport.dart (<1 KB)
│   │   ├── webmcp.dart (2 KB)
│   │   ├── webmcp_exceptions.dart (1 KB)
│   │   ├── webmcp_scope.dart (2 KB)
│   │   ├── webmcp_tool.dart (<1 KB)
│   │   ├── webmcp_tool_source.dart (<1 KB)
│   │   └── widgets
│   │       ├── webmcp_action.dart (2 KB)
│   │       └── webmcp_screen.dart (1 KB)
│   └── webmcp_flutter.dart (<1 KB)
└── pubspec.yaml (<1 KB)

Total compressed archive size: 8 KB.
Validating package...
The server may enforce additional checks.

Package has 0 warnings.

Exit: 0
```

## candidate-check

Command arguments: `["python3", "/private/tmp/webmcp-release-011-run/candidate.py", "check", "final-dry"]`

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

```text
final-dry: actual CLI inventory matches22 reviewed files; zero warnings.
All approved source and payload paths, sizes and SHA-256 unchanged.

Exit: 0
```

## gate-negatives

Command arguments: `["python3", "/private/tmp/webmcp-release-011-run/gates.py"]`

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

```text
Expected rejection: extra generated file
Expected rejection: missing approved file
Expected rejection: altered included content
Expected rejection: unexpected package warning
Expected rejection: nonzero status
Expected rejection: missing artifact
Expected rejection: wrong provenance/version
Expected rejection: wrong hosted version
Expected rejection: missing hosted repository
Expected rejection: altered archive bytes
Expected rejection: absent repo anchor
Expected rejection: wrong repo anchor
Expected rejection: unauthorized source change
Expected rejection: unauthorized index change
Expected rejection: unauthorized prior STATE change
Expected rejection: pending criterion closure
PASS: actual local selection/build gates and all synthetic negative boundary checks.

Exit: 0
```


## Targeted runtime negative

A second inventory rejection probe changes the SHA-256 of the first lib/ entry (rather than the earlier generic included-file probe), then calls the same gates.inventory comparison.

```python
rows = json.loads(Path('/private/tmp/webmcp-release-011-run/inventory.json').read_text())
changed = copy.deepcopy(rows)
next(r for r in changed if r['path'].startswith('lib/'))['sha256'] = 'changed'
reject('altered runtime library hash', lambda: inventory(changed, rows))
```

```text
Expected rejection: altered runtime library hash
Exit: 0
```
