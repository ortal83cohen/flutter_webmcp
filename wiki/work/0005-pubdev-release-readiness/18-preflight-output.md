# Release preflight command output

## Publish help

Command: `PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH dart pub publish --help`

```text
Publish the current package to pub.dev.

Usage: dart pub publish [options]
-h, --help               Print this usage information.
-n, --dry-run            Validate but do not publish the package.
-f, --force              Publish without confirmation if there are no errors.
    --skip-validation    Publish without validation and resolution (this will
                         ignore errors).
-C, --directory=<dir>    Run this in the directory <dir>.
    --ignore-warnings    Do not treat warnings as fatal.

Run "dart help" to see global options.
See https://dart.dev/tools/pub/cmd/pub-lish for detailed documentation.

Exit: 0
```

## Publish dry-run

Command: `PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH dart pub publish --dry-run`

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
├── AGENTS.md (4 KB)
├── CHANGELOG.md (<1 KB)
├── CLAUDE.md (<1 KB)
├── LICENSE (1 KB)
├── README.md (5 KB)
├── analysis_options.yaml (<1 KB)
├── example
│   ├── analysis_options.yaml (<1 KB)
│   ├── lib
│   │   ├── example_screen.dart (2 KB)
│   │   ├── example_tools.dart (<1 KB)
│   │   └── main.dart (<1 KB)
│   ├── pubspec.yaml (<1 KB)
│   ├── test
│   │   └── example_tools_test.dart (<1 KB)
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
├── pubspec.yaml (<1 KB)
├── test
│   ├── registry_test.dart (3 KB)
│   ├── repo_hygiene_test.dart (9 KB)
│   ├── transport_selection_test.dart (1 KB)
│   ├── transport_web_source_test.dart (<1 KB)
│   ├── webmcp_public_surface_test.dart (1 KB)
│   ├── webmcp_scope_test.dart (2 KB)
│   └── widget_layer_test.dart (6 KB)
├── tools
│   ├── check.sh (1 KB)
│   └── lint_wiki.py (15 KB)
└── wiki
    ├── INDEX.md (3 KB)
    ├── adr
    │   ├── 0001-use-a-phased-agent-pipeline.md (4 KB)
    │   ├── 0002-share-agent-config-between-claude-code-and-cursor.md (5 KB)
    │   ├── 0003-webmcp-detection-first-registry.md (2 KB)
    │   └── README.md (2 KB)
    ├── conventions
    │   ├── definition-of-done.md (2 KB)
    │   ├── model-routing.md (2 KB)
    │   ├── naming.md (2 KB)
    │   ├── parallelism.md (3 KB)
    │   ├── validation-rubrics.md (3 KB)
    │   └── workflow.md (6 KB)
    ├── product
    │   ├── README.md (2 KB)
    │   └── webmcp-contract.md (2 KB)
    ├── templates
    │   ├── 00-research.md (1 KB)
    │   ├── 01-plan.md (2 KB)
    │   ├── 02-criteria.md (1 KB)
    │   ├── 03-tasks.md (1 KB)
    │   ├── STATE.yaml (1 KB)
    │   ├── adr.md (1 KB)
    │   └── validation-report.md (2 KB)
    └── work
        ├── 0001-add-build-dispatcher-skill
        │   ├── RECORD.md (2 KB)
        │   └── STATE.yaml (1 KB)
        ├── 0002-flutter-webmcp-stack
        │   ├── 00-research.md (29 KB)
        │   ├── 01-plan.md (28 KB)
        │   ├── 02-criteria.md (19 KB)
        │   ├── STATE.yaml (10 KB)
        │   ├── research
        │   │   ├── dart-js-interop-bridge.md (21 KB)
        │   │   ├── prior-art-and-pubdev-conventions.md (16 KB)
        │   │   ├── tool-registry-architecture.md (18 KB)
        │   │   └── webmcp-api-shape.md (23 KB)
        │   └── validation
        │       ├── plan-review-01.md (16 KB)
        │       ├── plan-review-02.md (23 KB)
        │       ├── plan-review-03.md (30 KB)
        │       ├── research-review-01.md (18 KB)
        │       └── research-review-02.md (21 KB)
        ├── 0003-flutter-webmcp-skeleton
        │   ├── 00-research.md (29 KB)
        │   ├── 01-plan.md (33 KB)
        │   ├── 02-criteria.md (22 KB)
        │   ├── STATE.yaml (8 KB)
        │   ├── research
        │   │   ├── dart-js-interop-bridge.md (21 KB)
        │   │   ├── prior-art-and-pubdev-conventions.md (16 KB)
        │   │   ├── tool-registry-architecture.md (18 KB)
        │   │   └── webmcp-api-shape.md (23 KB)
        │   └── validation
        │       ├── plan-review-01.md (24 KB)
        │       ├── plan-review-02.md (26 KB)
        │       └── plan-review-03.md (22 KB)
        ├── 0004-flutter-webmcp-skeleton
        │   ├── 00-research.md (29 KB)
        │   ├── 01-plan.md (62 KB)
        │   ├── 02-criteria.md (34 KB)
        │   ├── 03-tasks.md (9 KB)
        │   ├── 04-notes.md (7 KB)
        │   ├── 05-negative-checks.md (85 KB)
        │   ├── 06-plan-amendment.md (6 KB)
        │   ├── 07-repair-evidence.md (6 KB)
        │   ├── 08-escape-repair.md (5 KB)
        │   ├── 09-parser-plan-amendment.md (8 KB)
        │   ├── 10-parser-repair-evidence.md (7 KB)
        │   ├── 11-completion.md (4 KB)
        │   ├── STATE.yaml (13 KB)
        │   ├── research
        │   │   ├── dart-js-interop-bridge.md (21 KB)
        │   │   ├── prior-art-and-pubdev-conventions.md (16 KB)
        │   │   ├── tool-registry-architecture.md (18 KB)
        │   │   └── webmcp-api-shape.md (23 KB)
        │   └── validation
        │       ├── impl-review-01.md (112 KB)
        │       ├── impl-review-02.md (58 KB)
        │       ├── impl-review-03.md (47 KB)
        │       ├── impl-review-04.md (45 KB)
        │       ├── plan-review-01.md (24 KB)
        │       ├── plan-review-02.md (23 KB)
        │       ├── plan-review-03.md (4 KB)
        │       └── plan-review-04.md (6 KB)
        ├── 0005-pubdev-release-readiness
        │   ├── 00-research.md (3 KB)
        │   ├── 01-plan.md (8 KB)
        │   ├── 02-criteria.md (5 KB)
        │   ├── 03-tasks.md (5 KB)
        │   ├── 04-package-audit.md (5 KB)
        │   ├── 05-quality-audit.md (11 KB)
        │   ├── 06-publishing-rules.md (1 KB)
        │   ├── 07-name-check.md (1 KB)
        │   ├── 13-name-selection.md (3 KB)
        │   ├── STATE.yaml (1 KB)
        │   └── validation
        │       ├── plan-review-01.md (1 KB)
        │       └── research-review-01.md (2 KB)
        └── 0006-rename-webmcp-flutter
            ├── 00-research.md (4 KB)
            ├── 01-plan.md (3 KB)
            ├── 02-criteria.md (2 KB)
            ├── 03-tasks.md (1 KB)
            ├── 04-implementation-evidence.md (14 KB)
            ├── 05-documentation.md (2 KB)
            ├── 06-completion.md (1 KB)
            ├── STATE.yaml (1 KB)
            └── validation
                ├── impl-review-01.md (18 KB)
                ├── plan-review-01.md (1 KB)
                └── research-review-01.md (1 KB)

Total compressed archive size: 389 KB.
Validating package...
Package validation found the following 2 errors:
* Potential leak of AWS Access Key in `wiki/work/0004-flutter-webmcp-skeleton/validation/impl-review-01.md` at offset 93692:93714.
  
  ```
   AKIAABCDEFGHIJKLMNOP'
  ```
  

* Potential leak of AWS Access Key in `wiki/work/0004-flutter-webmcp-skeleton/validation/impl-review-01.md` at offset 93751:93773.
  
  ```
   AKIAABCDEFGHIJKLMNOP
  
  ```
  
  Add a git-ignore style pattern to `false_secrets` in `pubspec.yaml`
  to ignore this. See https://dart.dev/go/false-secrets

Package validation found the following 5 potential issues:
* 1 checked-in file is ignored by a `.gitignore`.
  Previous versions of Pub would include those in the published package.
  
  Consider adjusting your `.gitignore` files to not ignore those files, and if you do not wish to
  publish these files use `.pubignore`. See also dart.dev/go/pubignore
  
  Files that are checked in while gitignored:
  
  lib/webmcp_pilot.dart
  
  

* 36 checked-in files are modified in git.
  
  Usually you want to publish from a clean git state.
  
  Consider committing these files or reverting the changes.
  
  Modified files:
  
  README.md
  example/lib/example_screen.dart
  example/lib/example_tools.dart
  example/pubspec.yaml
  example/test/example_tools_test.dart
  example/web/index.html
  lib/src/transport/transport_web.dart
  lib/src/webmcp_scope.dart
  pubspec.yaml
  test/registry_test.dart
  ...
  
  Run `git status` for more information.
  

* It's strongly recommended to include a "homepage" or "repository" field in your pubspec.yaml

* Rename the top-level "tools" directory to "tool".
  The Pub layout convention is to use singular directory names.
  Plural names won't be correctly identified by Pub and other tools.
  See https://dart.dev/tools/pub/package-layout.

* /Users/ortalcohen/Documents/GitHub/flutter_webmcp/CHANGELOG.md doesn't mention current version (0.1.0).
  Consider updating it with notes on this version prior to publication.
Sorry, your package is missing some requirements and can't be published yet.
For more information, see: https://dart.dev/tools/pub/cmd/pub-lish.

Exit: 65
```

The command output abbreviates the modified-file list after the first entries with `...`; this is the exact tool output as emitted by pub.
