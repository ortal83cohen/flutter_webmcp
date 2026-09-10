# Missing source URL warning policy evidence

## Question

Can the pinned SDK's ordinary publication dry-run succeed without `homepage` or `repository` when all other currently known publication diagnostics are absent?

## Disposable candidate

On 2026-09-10, a disposable directory under `/private/tmp` was populated with the current `lib` tree and `pubspec.yaml`, the existing MIT `LICENSE`, and short synthetic `README.md` and `CHANGELOG.md` files. The changelog named version `0.1.0`. The candidate included no Git metadata, wiki, tests, tools, agent files, example, source URL, personal data, or secret-shaped fixtures. No repository source file was edited. The directory was used only for this diagnostic.

## Command

`PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH dart pub publish --dry-run`

The command used neither `--force`, `--skip-validation`, nor `--ignore-warnings`.

## Exact relevant output

```text
Publishing webmcp_flutter 0.1.0 to https://pub.dev:
├── CHANGELOG.md (<1 KB)
├── LICENSE (1 KB)
├── README.md (<1 KB)
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

Total compressed archive size: 5 KB.
Validating package...
Package validation found the following potential issue:
* It's strongly recommended to include a "homepage" or "repository" field in your pubspec.yaml
The server may enforce additional checks.

Package has 1 warning.

Exit: 65
```

Dependency-resolution progress was routine and is omitted because it does not affect the warning-policy result. No secret-shaped fixture values are reproduced in this artifact.

## Conclusion

Under the pinned Flutter 3.47.0 Dart SDK, the single missing-source-URL warning makes the ordinary dry-run exit 65. Omitting optional URL metadata is valid pubspec syntax, but it cannot satisfy this project's stronger launch gate of an ordinary dry-run with exit zero and no warnings. The executable policy is to publish the actual reviewed source at a publicly readable repository, set that truthful URL as `repository`, verify it without authentication, and rerun the dry-run. Bypass flags remain prohibited.

## Supported narrow waiver diagnostic

The same disposable candidate was then tested with the pinned SDK's documented `--ignore-warnings` option. No candidate file changed between runs.

Command: `PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH dart pub publish --dry-run --ignore-warnings`

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
├── README.md (<1 KB)
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

Total compressed archive size: 5 KB.
Validating package...
Package validation found the following potential issue:
* It's strongly recommended to include a "homepage" or "repository" field in your pubspec.yaml
The server may enforce additional checks.

Package has 1 warning.

Exit: 0
```

This result supersedes the earlier conclusion that a public source repository is required by this project's release policy. The allowlisted warning is optional URL metadata only. Release evidence must include an ordinary dry-run showing exactly this one warning and no errors, followed on the identical candidate by the `--ignore-warnings` dry-run exiting zero with the same sole warning and file list. Any other warning or any error remains blocking. Neither `--skip-validation` nor `--force` is permitted.
