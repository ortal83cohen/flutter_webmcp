# Publication and public repository link verification

## Published result

The metadata-only0.1.1 release was published under the user request to add the supplied repository link and the previously authorized account. The ordinary interactive publisher retained all validation, showed22 approved paths with no warnings/errors and was confirmed only after independent preupload PASS and final availability/identity checks. No credentials or private account identity are recorded. The exact repository anchor is now rendered on both the versioned and default pub.dev package pages.

## Interactive upload

Command: `/Users/ortalcohen/fvm/versions/3.47.0/bin/dart pub publish`

Working directory: `/private/tmp/webmcp-release-011-run/payload`

Terminal backspaces are rendered into final displayed text.

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

Publishing is forever; packages cannot be unpublished.
Policy details are available at https://pub.dev/policy

Do you want to publish webmcp_flutter 0.1.1 to https://pub.dev (y/N)? y
Uploading... 
Message from server: Successfully uploaded https://pub.dev/packages/webmcp_flutter version 0.1.1, it may take up-to 10 minutes before the new version is available.


Exit: 0
```

## Full postpublication outputs

### launch-metadata

Command arguments: `["python3", "/private/tmp/webmcp-release-011-run/metadata_probe.py"]`

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

```text
https://api.github.com/repos/ortal83cohen/flutter_webmcp HTTP 200
Public repository: ortal83cohen/flutter_webmcp private: False branch: main
https://raw.githubusercontent.com/ortal83cohen/flutter_webmcp/main/pubspec.yaml HTTP 200
Public repository root manifest declares name: webmcp_flutter
https://pub.dev/api/packages/webmcp_flutter HTTP 200
Latest version: 0.1.0 repository: None
https://pub.dev/api/packages/webmcp_flutter/versions/0.1.1 HTTP 404

Exit: 0
```

### final-identity

Command arguments: `["python3", "/private/tmp/webmcp-release-011-run/candidate.py", "check", "final-dry"]`

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

```text
final-dry: actual CLI inventory matches22 reviewed files; zero warnings.
All approved source and payload paths, sizes and SHA-256 unchanged.

Exit: 0
```

### hosted-archive

Command arguments: `["python3", "/private/tmp/webmcp-release-011-run/hosted_verify.py", "archive"]`

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

```text
Hosted exact version API: https://pub.dev/api/packages/webmcp_flutter/versions/0.1.1 HTTP 200; version 0.1.1
Hosted archive SHA-256 matches registry: 157eb5adbbc7091228f3de4c419b7d817a7a1e62824e71d932f6823cae7cc645
Hosted archive exactly matches all 22 approved paths, sizes and SHA-256 values.

Exit: 0
```

### hosted-link

Command arguments: `["python3", "/private/tmp/webmcp-release-011-run/link_check.py"]`

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

```text
https://pub.dev/api/packages/webmcp_flutter/versions/0.1.1 HTTP 200
Hosted exact version repository: https://github.com/ortal83cohen/flutter_webmcp
https://pub.dev/packages/webmcp_flutter/versions/0.1.1 HTTP 200
Repository anchors: ['https://github.com/ortal83cohen/flutter_webmcp', 'https://github.com/ortal83cohen/flutter_webmcp']
https://pub.dev/packages/webmcp_flutter HTTP 200
Repository anchors: ['https://github.com/ortal83cohen/flutter_webmcp', 'https://github.com/ortal83cohen/flutter_webmcp']
PASS: requested public repository link appears on exact version and default package pages.

Exit: 0
```

### hosted-consumer-create

Command arguments: `["python3", "/private/tmp/webmcp-release-011-run/hosted_verify.py", "create"]`

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

```text
Created fresh hosted-only consumer with exact version 0.1.1 and README sample.

Exit: 0
```

### hosted-build

Command arguments: `["env", "PUB_CACHE=/private/tmp/webmcp-release-011-run/hosted-cache", "flutter", "build", "web"]`

Working directory: `/private/tmp/webmcp-release-011-run/hosted-consumer`

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
+ webmcp_flutter 0.1.1
Changed 9 dependencies!
1 package has newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Compiling lib/main.dart for the Web...                          
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Expected to find fonts for (MaterialIcons, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 7736 bytes (99.5% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Compiling lib/main.dart for the Web...                             20.4s
✓ Built build/web

Exit: 0
```

### hosted-provenance

Command arguments: `["python3", "/private/tmp/webmcp-release-011-run/hosted_verify.py", "provenance"]`

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

```text
Hosted consumer package provenance: /private/tmp/webmcp-release-011-run/hosted-cache/hosted/pub.dev/webmcp_flutter-0.1.1
Exact hosted 0.1.1 resolved from fresh isolated pub cache; web build index exists.

Exit: 0
```

### final-preservation

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

