# Release verification

## Scope and identity

Complete-source checks use the original Git checkout and pinned Flutter 3.47.0/Dart 3.13.0. The Git-free packaging source is `/private/tmp/webmcp-release-010-run/packaging-source`; the reproduced payload is `/private/tmp/webmcp-release-010-run/payload`. This is a byte-for-byte reproduction of the CLI-selected files, not a CLI-exported archive.

Full source inventory: 26-source-inventory.json. Payload inventory: 27-payload-inventory.json. Each row gives full relative path, exact size and SHA-256. The 22-file payload inventory SHA-256 is `d73593ced4a5b3b75e9fc77674bf25eabd51e1eadff347e18c50e180932c9f0e`. Four actual dry-run inventories agree. Tests/tools/wiki and local/generated files are absent from the inclusion inventory. The MIT LICENSE is unchanged.

The initial source snapshot was refreshed only for the corrected widget test and its implementation evidence before the final suite; these paths are excluded from the payload. Later wiki evidence additions do not change the release bytes. Final source inventory records the files present at capture time; subsequent append-only release records are outside the package.

## Failure dispositions

The first full suite found an undefined ElevatedButton in the new widget test. The implementer corrected the fixture to GestureDetector with no onTap; the complete pinned suite was rerun successfully. The default SDK attempt recorded in 24 used an older Dart and is superseded by the exact pinned run below. Initial sandbox cache writes and DNS were denied; scoped SDK/network execution resolved them. A temporary helper initially named warnings.py shadowed Python standard-library warnings; renaming it to check_diagnostics.py resolved this harness-only error before payload creation.

Ordinary publish dry-runs exit 65 solely for the exact optional homepage/repository warning allowed in 21/23. The unchanged candidates with --ignore-warnings exit 0, with all validation retained. Dependency-update notices and the SDK font/tree-shaking/Wasm informational output are retained verbatim. No CupertinoIcons are declared by the package/example/README sample; the font notice is nonblocking SDK build output, and all positive web builds exit 0.

The negative consumer is deliberately broken in a separate payload copy: removal of lib/webmcp_flutter.dart fails compilation with that missing path. The release payload is unmodified. Hosted installation and presentation checks await actual publication. Account/redistribution authority and launch confirmation remain launch gates.

## Commands and complete output

All runner calls prepend `/Users/ortalcohen/fvm/versions/3.47.0/bin` to PATH and set CI=true. Helpers are preserved in 28.

### versions

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

Command arguments: `["/Users/ortalcohen/fvm/versions/3.47.0/bin/flutter", "--version"]`

```text
Flutter 3.47.0 • channel [user-branch] • https://github.com/flutter/flutter.git
Framework • revision 4cf2416426 (4 weeks ago) • 2026-08-11 11:53:49 -0700
Engine • hash 59d54a2b2896a6bbf356c94b7fac7b9e235bdacd (revision 5f77625673) (29 days ago) • 2026-08-11 16:38:36.000Z
Tools • Dart 3.13.0 • DevTools 2.60.0

Exit: 0
```

### dart-version

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

Command arguments: `["/Users/ortalcohen/fvm/versions/3.47.0/bin/dart", "--version"]`

```text
Dart SDK version: 3.13.0 (stable) (Wed Aug 5 00:28:05 2026 -0700) on "macos_arm64"

Exit: 0
```

### browser

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

Command arguments: `["env", "CHROME_EXECUTABLE=/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", "/Users/ortalcohen/fvm/versions/3.47.0/bin/flutter", "test", "--platform", "chrome", "test/transport_web_browser_test.dart", "--reporter", "expanded"]`

```text
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
00:00 +0: loading /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_web_browser_test.dart
00:00 +0: reports modelContext absent when the marker is missing
00:00 +1: reports modelContext present without publishing registry changes
00:00 +2: All tests passed!

Exit: 0
```

### full-suite

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

Command arguments: `["bash", "tools/check.sh"]`

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

  error - test/widget_layer_test.dart:133:18 - Invalid constant value. - invalid_constant
  error - test/widget_layer_test.dart:133:18 - The function 'ElevatedButton' isn't defined. Try importing the library that defines 'ElevatedButton', correcting the name to the name of an existing function, or defining a function named 'ElevatedButton'. - undefined_function

2 issues found.
Stage 4 failed: analysis

Exit: 1
```

### full-suite-final

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

Command arguments: `["bash", "tools/check.sh"]`

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
Formatted 24 files (0 changed) in 0.04 seconds.
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
00:00 +0: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_web_source_test.dart: web transport retains its detection-only contract
00:00 +1: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: registers tools and lists them in ascending order
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
00:01 +21: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction recognizes whitespace, comments, and conditional targets
00:01 +22: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction ignores exports, comments, strings, and conditional values
00:01 +23: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction uses compiler semantics for initial newlines in triple strings
00:01 +24: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction uses compiler semantics for encoded import URIs
00:01 +25: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction preserves raw ordinary literal content
00:01 +26: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction surfaces parser diagnostics with the source path
00:01 +27: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: analyzer import extraction classifies only the fixed forbidden import families
00:01 +28: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: secret detector fixtures matches every fixed header and the bare AWS prefix
00:01 +29: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: secret detector fixtures matches every assignment spelling and separator
00:01 +30: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: secret detector fixtures does not infer markers outside the exhaustive set
00:01 +31: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:01 +32: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:01 +33: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:01 +34: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:01 +35: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:01 +36: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: library and example sources avoid forbidden imports
00:01 +37: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: Flutter imports stay inside the widget layer
00:01 +38: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: public and scope tests preserve their import boundaries
00:01 +39: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/repo_hygiene_test.dart: implementation files contain no fixed secret markers
00:01 +40: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_public_surface_test.dart: exports the complete public API and seven registry operations
00:02 +41: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: adds direct and source tools, then closes
00:02 +42: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: skips duplicates and never removes another owner
00:02 +43: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: remove is limited to names owned by the scope
00:02 +44: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: close is idempotent and closed scopes reject additions
00:02 +45: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_scope_test.dart: invalid names propagate without becoming owned or skipped
00:02 +46: All tests passed!
00:00 +0: loading /Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/test/example_tools_test.dart
00:00 +0: registers two imperative tools and increments the counter
00:00 +1: All tests passed!
Stage 5 passed: tests
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 7736 bytes (99.5% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             24.8s
✓ Built build/web
Stage 6 passed: build

Exit: 0
```

### initial-name

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

Command arguments: `["python3", "/private/tmp/webmcp-release-010-run/name_check.py"]`

```text
Checked UTC: 2026-09-10T13:18:25.435180+00:00
Traceback (most recent call last):
  File "/opt/homebrew/Cellar/python@3.14/3.14.7/Frameworks/Python.framework/Versions/3.14/lib/python3.14/urllib/request.py", line 1320, in do_open
    h.request(req.get_method(), req.selector, req.data, headers,
    ~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
              encode_chunked=req.has_header('Transfer-encoding'))
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/opt/homebrew/Cellar/python@3.14/3.14.7/Frameworks/Python.framework/Versions/3.14/lib/python3.14/http/client.py", line 1386, in request
    self._send_request(method, url, body, headers, encode_chunked)
    ~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/opt/homebrew/Cellar/python@3.14/3.14.7/Frameworks/Python.framework/Versions/3.14/lib/python3.14/http/client.py", line 1432, in _send_request
    self.endheaders(body, encode_chunked=encode_chunked)
    ~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/opt/homebrew/Cellar/python@3.14/3.14.7/Frameworks/Python.framework/Versions/3.14/lib/python3.14/http/client.py", line 1381, in endheaders
    self._send_output(message_body, encode_chunked=encode_chunked)
    ~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/opt/homebrew/Cellar/python@3.14/3.14.7/Frameworks/Python.framework/Versions/3.14/lib/python3.14/http/client.py", line 1141, in _send_output
    self.send(msg)
    ~~~~~~~~~^^^^^
  File "/opt/homebrew/Cellar/python@3.14/3.14.7/Frameworks/Python.framework/Versions/3.14/lib/python3.14/http/client.py", line 1085, in send
    self.connect()
    ~~~~~~~~~~~~^^
  File "/opt/homebrew/Cellar/python@3.14/3.14.7/Frameworks/Python.framework/Versions/3.14/lib/python3.14/http/client.py", line 1520, in connect
    super().connect()
    ~~~~~~~~~~~~~~~^^
  File "/opt/homebrew/Cellar/python@3.14/3.14.7/Frameworks/Python.framework/Versions/3.14/lib/python3.14/http/client.py", line 1051, in connect
    self.sock = self._create_connection(
                ~~~~~~~~~~~~~~~~~~~~~~~^
        (self.host,self.port), self.timeout, self.source_address)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/opt/homebrew/Cellar/python@3.14/3.14.7/Frameworks/Python.framework/Versions/3.14/lib/python3.14/socket.py", line 850, in create_connection
    for res in getaddrinfo(host, port, 0, SOCK_STREAM):
               ~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/opt/homebrew/Cellar/python@3.14/3.14.7/Frameworks/Python.framework/Versions/3.14/lib/python3.14/socket.py", line 989, in getaddrinfo
    for res in _socket.getaddrinfo(host, port, family, type, proto, flags):
               ~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
socket.gaierror: [Errno 8] nodename nor servname provided, or not known

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "/private/tmp/webmcp-release-010-run/name_check.py", line 5, in <module>
    with urllib.request.urlopen(url) as response:print(url,'HTTP',response.status)
         ~~~~~~~~~~~~~~~~~~~~~~^^^^^
  File "/opt/homebrew/Cellar/python@3.14/3.14.7/Frameworks/Python.framework/Versions/3.14/lib/python3.14/urllib/request.py", line 187, in urlopen
    return opener.open(url, data, timeout)
           ~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^
  File "/opt/homebrew/Cellar/python@3.14/3.14.7/Frameworks/Python.framework/Versions/3.14/lib/python3.14/urllib/request.py", line 487, in open
    response = self._open(req, data)
  File "/opt/homebrew/Cellar/python@3.14/3.14.7/Frameworks/Python.framework/Versions/3.14/lib/python3.14/urllib/request.py", line 504, in _open
    result = self._call_chain(self.handle_open, protocol, protocol +
                              '_open', req)
  File "/opt/homebrew/Cellar/python@3.14/3.14.7/Frameworks/Python.framework/Versions/3.14/lib/python3.14/urllib/request.py", line 464, in _call_chain
    result = func(*args)
  File "/opt/homebrew/Cellar/python@3.14/3.14.7/Frameworks/Python.framework/Versions/3.14/lib/python3.14/urllib/request.py", line 1368, in https_open
    return self.do_open(http.client.HTTPSConnection, req,
           ~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                        context=self._context)
                        ^^^^^^^^^^^^^^^^^^^^^^
  File "/opt/homebrew/Cellar/python@3.14/3.14.7/Frameworks/Python.framework/Versions/3.14/lib/python3.14/urllib/request.py", line 1323, in do_open
    raise URLError(err)
urllib.error.URLError: <urlopen error [Errno 8] nodename nor servname provided, or not known>

Exit: 1
```

### initial-name-network

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

Command arguments: `["python3", "/private/tmp/webmcp-release-010-run/name_check.py"]`

```text
Checked UTC: 2026-09-10T13:18:40.234797+00:00
https://pub.dev/api/packages/webmcp_flutter HTTP 404
https://pub.dev/api/packages/webmcp_flutter/versions/0.1.0 HTTP 404

Exit: 0
```

### source-copy

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

Command arguments: `["python3", "/private/tmp/webmcp-release-010-run/payload.py", "copy"]`

```text
Complete source snapshot and Git-free copy: 190 files; identical paths, sizes and SHA-256

Exit: 0
```

### source-dry

Working directory: `/private/tmp/webmcp-release-010-run/packaging-source`

Command arguments: `["dart", "pub", "publish", "--dry-run"]`

```text
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
Try `dart pub outdated` for more information.
Publishing webmcp_flutter 0.1.0 to https://pub.dev:
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

Total compressed archive size: 7 KB.
Validating package...
Package validation found the following potential issue:
* It's strongly recommended to include a "homepage" or "repository" field in your pubspec.yaml
The server may enforce additional checks.

Package has 1 warning.

Exit: 65
```

### source-waived

Working directory: `/private/tmp/webmcp-release-010-run/packaging-source`

Command arguments: `["dart", "pub", "publish", "--dry-run", "--ignore-warnings"]`

```text
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
Try `dart pub outdated` for more information.
Publishing webmcp_flutter 0.1.0 to https://pub.dev:
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

Total compressed archive size: 7 KB.
Validating package...
Package validation found the following potential issue:
* It's strongly recommended to include a "homepage" or "repository" field in your pubspec.yaml
The server may enforce additional checks.

Package has 1 warning.

Exit: 0
```

### payload-create

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

Command arguments: `["python3", "/private/tmp/webmcp-release-010-run/payload.py", "payload"]`

```text
Payload reproduced from actual dry-run listing: 22 files; all paths, sizes and SHA-256 match source
Inventory SHA-256: d73593ced4a5b3b75e9fc77674bf25eabd51e1eadff347e18c50e180932c9f0e

Exit: 0
```

### payload-dry

Working directory: `/private/tmp/webmcp-release-010-run/payload`

Command arguments: `["dart", "pub", "publish", "--dry-run"]`

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
Publishing webmcp_flutter 0.1.0 to https://pub.dev:
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

Total compressed archive size: 7 KB.
Validating package...
Package validation found the following potential issue:
* It's strongly recommended to include a "homepage" or "repository" field in your pubspec.yaml
The server may enforce additional checks.

Package has 1 warning.

Exit: 65
```

### payload-waived

Working directory: `/private/tmp/webmcp-release-010-run/payload`

Command arguments: `["dart", "pub", "publish", "--dry-run", "--ignore-warnings"]`

```text
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
Try `dart pub outdated` for more information.
Publishing webmcp_flutter 0.1.0 to https://pub.dev:
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

Total compressed archive size: 7 KB.
Validating package...
Package validation found the following potential issue:
* It's strongly recommended to include a "homepage" or "repository" field in your pubspec.yaml
The server may enforce additional checks.

Package has 1 warning.

Exit: 0
```

### diagnostics

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

Command arguments: `["python3", "/private/tmp/webmcp-release-010-run/check_diagnostics.py", "source-dry", "source-waived", "payload-dry", "payload-waived"]`

```text
source-dry: exact optional-URL warning only, zero errors; expected exit 65
source-waived: exact optional-URL warning only, zero errors; expected exit 0
payload-dry: exact optional-URL warning only, zero errors; expected exit 65
payload-waived: exact optional-URL warning only, zero errors; expected exit 0

Exit: 0
```

### consumer-create

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

Command arguments: `["python3", "/private/tmp/webmcp-release-010-run/consumer.py", "create"]`

```text
Created fresh consumer with README sample and only payload dependency: /private/tmp/webmcp-release-010-run/payload

Exit: 0
```

### consumer-build

Working directory: `/private/tmp/webmcp-release-010-run/consumer`

Command arguments: `["flutter", "build", "web"]`

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
+ webmcp_flutter 0.1.0 from path /private/tmp/webmcp-release-010-run/payload
Changed 9 dependencies!
1 package has newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 7736 bytes (99.5% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             23.7s
✓ Built build/web

Exit: 0
```

### example-build

Working directory: `/private/tmp/webmcp-release-010-run/payload/example`

Command arguments: `["flutter", "build", "web"]`

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
+ webmcp_flutter 0.1.0 from path ..
Changed 28 dependencies!
2 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 7736 bytes (99.5% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             21.4s
✓ Built build/web

Exit: 0
```

### provenance

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

Command arguments: `["python3", "/private/tmp/webmcp-release-010-run/consumer.py", "provenance"]`

```text
consumer: webmcp_flutter resolves ONLY to /private/tmp/webmcp-release-010-run/payload
web build index: True
payload/example: webmcp_flutter resolves ONLY to /private/tmp/webmcp-release-010-run/payload
web build index: True

Exit: 0
```

### negative-create

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

Command arguments: `["python3", "/private/tmp/webmcp-release-010-run/consumer.py", "negative"]`

```text
Created fresh negative-consumer with README sample and only payload dependency: /private/tmp/webmcp-release-010-run/negative-payload

Exit: 0
```

### negative-build

Working directory: `/private/tmp/webmcp-release-010-run/negative-consumer`

Command arguments: `["flutter", "build", "web"]`

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
+ webmcp_flutter 0.1.0 from path /private/tmp/webmcp-release-010-run/negative-payload
Changed 9 dependencies!
1 package has newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Target dart2js failed: ProcessException: Process exited abnormally with exit code 1:
lib/main.dart:2:8:
Error: Error when reading '../negative-payload/lib/webmcp_flutter.dart': Error reading '../negative-payload/lib/webmcp_flutter.dart'  (No such file or directory)
import 'package:webmcp_flutter/webmcp_flutter.dart';
       ^
lib/main.dart:16:10:
Error: Type 'WebMcpScreen' not found.
    with WebMcpScreen<CounterPage> {
         ^^^^^^^^^^^^
lib/main.dart:28:16:
Error: The method 'WebMcpAction' isn't defined for the type '_CounterPageState'.
 - '_CounterPageState' is from 'package:release_consumer/main.dart' ('lib/main.dart').
        child: WebMcpAction(
               ^^^^^^^^^^^^
Error: Compilation failed.
  Command: /Users/ortalcohen/fvm/versions/3.47.0/bin/cache/dart-sdk/bin/dart compile js --platform-binaries=/Users/ortalcohen/fvm/versions/3.47.0/bin/cache/flutter_web_sdk/kernel --invoker=flutter_tool -Ddart.vm.product=true -DFLUTTER_VERSION=3.47.0 -DFLUTTER_CHANNEL=[user-branch] -DFLUTTER_GIT_URL=https://github.com/flutter/flutter.git -DFLUTTER_FRAMEWORK_REVISION=4cf2416426 -DFLUTTER_ENGINE_REVISION=5f77625673 -DFLUTTER_DART_VERSION=3.13.0 -DFLUTTER_WEB_USE_SKIA=true -DFLUTTER_WEB_USE_SKWASM=false -DFLUTTER_WEB_CANVASKIT_URL=https://www.gstatic.com/flutter-canvaskit/5f77625673248ee5846fbcaf5d3e1a3878386fd7/ --write-resources --enable-experiment=record-use --native-null-assertions --no-source-maps -O4 --minify -o /private/tmp/webmcp-release-010-run/negative-consumer/.dart_tool/flutter_build/aad43801bebba2593f30c05255f3a33e/app.dill --packages=/private/tmp/webmcp-release-010-run/negative-consumer/.dart_tool/package_config.json --cfe-only /private/tmp/webmcp-release-010-run/negative-consumer/.dart_tool/flutter_build/aad43801bebba2593f30c05255f3a33e/main.dart
#0      RunResult.throwException (package:flutter_tools/src/base/process.dart:153:5)
#1      _DefaultProcessUtils.run (package:flutter_tools/src/base/process.dart:379:19)
<asynchronous suspension>
#2      Dart2JSTarget.build (package:flutter_tools/src/build_system/targets/web.dart:219:5)
<asynchronous suspension>
#3      _BuildInstance._invokeInternal (package:flutter_tools/src/build_system/build_system.dart:937:9)
<asynchronous suspension>
#4      Future.wait.<anonymous closure> (dart:async/future.dart:567:21)
<asynchronous suspension>
#5      _BuildInstance.invokeTarget (package:flutter_tools/src/build_system/build_system.dart:875:32)
<asynchronous suspension>
#6      Future.wait.<anonymous closure> (dart:async/future.dart:567:21)
<asynchronous suspension>
#7      _BuildInstance.invokeTarget (package:flutter_tools/src/build_system/build_system.dart:875:32)
<asynchronous suspension>
#8      Future.wait.<anonymous closure> (dart:async/future.dart:567:21)
<asynchronous suspension>
#9      _BuildInstance.invokeTarget (package:flutter_tools/src/build_system/build_system.dart:875:32)
<asynchronous suspension>
#10     FlutterBuildSystem.build (package:flutter_tools/src/build_system/build_system.dart:684:16)
<asynchronous suspension>
#11     WebBuilder.buildWeb (package:flutter_tools/src/web/compile.dart:107:34)
<asynchronous suspension>
#12     BuildWebCommand.runCommand (package:flutter_tools/src/commands/build_web.dart:293:5)
<asynchronous suspension>
#13     FlutterCommand.run.<anonymous closure> (package:flutter_tools/src/runner/flutter_command.dart:1663:27)
<asynchronous suspension>
#14     AppContext.run.<anonymous closure> (package:flutter_tools/src/base/context.dart:154:19)
<asynchronous suspension>
#15     CommandRunner.runCommand (package:args/command_runner.dart:212:13)
<asynchronous suspension>
#16     FlutterCommandRunner.runCommand.<anonymous closure> (package:flutter_tools/src/runner/flutter_command_runner.dart:496:9)
<asynchronous suspension>
#17     AppContext.run.<anonymous closure> (package:flutter_tools/src/base/context.dart:154:19)
<asynchronous suspension>
#18     FlutterCommandRunner.runCommand (package:flutter_tools/src/runner/flutter_command_runner.dart:431:5)
<asynchronous suspension>
#19     FlutterCommandRunner.run.<anonymous closure> (package:flutter_tools/src/runner/flutter_command_runner.dart:307:33)
<asynchronous suspension>
#20     run.<anonymous closure>.<anonymous closure> (package:flutter_tools/runner.dart:104:11)
<asynchronous suspension>
#21     AppContext.run.<anonymous closure> (package:flutter_tools/src/base/context.dart:154:19)
<asynchronous suspension>
#22     main (package:flutter_tools/executable.dart:103:3)
<asynchronous suspension>

Compiling lib/main.dart for the Web...                             17.4s
Error: Failed to compile application for the Web.

Exit: 1
```

### payload-identity

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

Command arguments: `["python3", "/private/tmp/webmcp-release-010-run/payload.py", "verify"]`

```text
PASS: source/payload paths, sizes and SHA-256 unchanged; all four dry-run inventories identical

Exit: 0
```

