# Final publication controls

## Observed launch defects and disposition

The first launch command used the optional flag described in 17/21/33. The pinned SDK rejected it before any upload:

Command: `/Users/ortalcohen/fvm/versions/3.47.0/bin/dart pub publish --ignore-warnings`

```text
`--ignore-warnings` can only be used with `--dry-run`.
Exit: 64
```

This is an execution-command defect in prior plan guidance, not a change to the frozen criteria or permitted warning policy. The corrected upload command is ordinary interactive `dart pub publish`, retaining validation and explicit confirmation. `--ignore-warnings` remains valid only for the already verified dry-run. This record supersedes conflicting live-upload command wording in 17/21/33. No --force or --skip-validation is used.

An ordinary interactive launch then showed generated example/build/web files left by the shipped-example check. That 13 MB candidate differed from the reviewed 22-file inventory and was interrupted during validation, before any confirmation or upload. This exposed a verification-harness defect: the previous identity helper ignored generated directories and compared earlier dry-run logs rather than refreshing CLI selection after building the example. No included release file changed.

The already-reviewed source .pubignore was copied into the payload directory as an excluded publication-control file. It is not part of the published inventory. Actual final CLI listings, after the generated files exist, now equal exactly the approved 22-file inventory. New final_gate.py compares actual final CLI listings, full relative paths, byte sizes, SHA-256 and the source/payload control-file bytes. This record supersedes the earlier claim that the original payload.py verify alone proves final publisher inclusion after builds.

Independent focused followup review is recorded in validation/impl-review-02.md. Existing full-suite, browser, README consumer and example build evidence remains applicable to the unchanged 22 included files. The final actual publish inventory must also be checked before confirmation.

## Authentication and authorization

The official pub login process returned authorization success and the selected account privately. The user explicitly requested execution of the named release, was shown the exact reviewed candidate and pending account gate, then completed authentication and instructed continuation by reporting that login was complete. Continue under that existing publication authorization with the selected account. MIT source/license continuity is unchanged; no new third-party source was added. Do not record account identity or credentials in wiki artifacts.

## Final verification output

### launch-identity-final

Command arguments: `["python3", "/private/tmp/webmcp-release-010-run/payload.py", "verify"]`

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

```text
PASS: source/payload paths, sizes and SHA-256 unchanged; all four dry-run inventories identical

Exit: 0
```

### launch-availability-final

Command arguments: `["python3", "/private/tmp/webmcp-release-010-run/name_check.py"]`

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

```text
Checked UTC: 2026-09-10T13:45:38.483120+00:00
https://pub.dev/api/packages/webmcp_flutter HTTP 404
https://pub.dev/api/packages/webmcp_flutter/versions/0.1.0 HTTP 404

Exit: 0
```

### final-source-controls-dry

Command arguments: `["dart", "pub", "publish", "--dry-run"]`

Working directory: `/private/tmp/webmcp-release-010-run/payload`

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

### final-controls-waived

Command arguments: `["dart", "pub", "publish", "--dry-run", "--ignore-warnings"]`

Working directory: `/private/tmp/webmcp-release-010-run/payload`

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

### final-publication-identity

Command arguments: `["python3", "/private/tmp/webmcp-release-010-run/final_gate.py", "final-source-controls-dry", "final-controls-waived"]`

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

```text
final-source-controls-dry: actual publisher inclusion inventory equals all 22 approved paths
final-controls-waived: actual publisher inclusion inventory equals all 22 approved paths
All 22 included path/size/SHA-256 entries unchanged in payload and source.
Excluded .pubignore control bytes match the already-reviewed source exclusions.
Inventory SHA-256: d73593ced4a5b3b75e9fc77674bf25eabd51e1eadff347e18c50e180932c9f0e

Exit: 0
```

### final-publication-diagnostics

Command arguments: `["python3", "/private/tmp/webmcp-release-010-run/check_diagnostics.py", "final-source-controls-dry", "final-controls-waived"]`

Working directory: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp`

```text
final-source-controls-dry: exact optional-URL warning only, zero errors; expected exit 65
final-controls-waived: exact optional-URL warning only, zero errors; expected exit 0

Exit: 0
```

## Corrected final inclusion verifier

```python
from pathlib import Path
import json,hashlib,re,sys
root=Path('/private/tmp/webmcp-release-010-run');payload=root/'payload';repo=Path('/Users/ortalcohen/Documents/GitHub/flutter_webmcp')
rows=json.loads((root/'payload-inventory.json').read_text());expected=[r['path'] for r in rows]
def listing(label):
    stack=[];files=[];started=False
    for line in (root/(label+'.log')).read_text().splitlines():
        if line.startswith('Publishing webmcp_flutter 0.1.0 '):started=True;continue
        if not started:continue
        if line.startswith('Total compressed archive size:'):break
        m=re.match(r'^((?:│   |    )*)[├└]── (.+)$',line)
        if not m:continue
        depth=len(m[1])//4;stack=stack[:depth];f=re.match(r'^(.*) \([^()]+\)$',m[2])
        if f:files.append('/'.join(stack+[f[1]]))
        else:stack.append(m[2])
    assert len(files)==len(set(files)),'Duplicate publisher paths'
    return sorted(files)
for label in sys.argv[1:]:
    actual=listing(label)
    assert actual==expected,{'unexpected':sorted(set(actual)-set(expected)),'missing':sorted(set(expected)-set(actual))}
    print(label+': actual publisher inclusion inventory equals all 22 approved paths')
for row in rows:
    for tree in (payload,repo):
        p=tree/row['path']
        assert p.is_file() and not p.is_symlink()
        assert p.stat().st_size==row['size'] and hashlib.sha256(p.read_bytes()).hexdigest()==row['sha256'],str(p)
assert (payload/'.pubignore').read_bytes()==(repo/'.pubignore').read_bytes()
print('All 22 included path/size/SHA-256 entries unchanged in payload and source.')
print('Excluded .pubignore control bytes match the already-reviewed source exclusions.')
print('Inventory SHA-256:',hashlib.sha256((root/'payload-inventory.json').read_bytes()).hexdigest())
```
