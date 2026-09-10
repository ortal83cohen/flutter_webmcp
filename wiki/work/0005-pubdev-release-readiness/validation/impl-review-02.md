# Implementation review — round 02

- Work item: 0005-pubdev-release-readiness
- Reviewed artifact: `19-criteria-consolidated.md`, normative `21-release-decisions.md` and final warning policy in `23-warning-policy-evidence.md`; original payload `/private/tmp/webmcp-release-010-run/payload`; frozen `27-payload-inventory.json` and the final source-controls dry-run/controls-waived logs.
- Reviewer: independent launch_inventory_review agent
- Date: 2026-09-10

## Verdict

**FAIL**

The 22 included files, packaging exclusions, unchanged-byte continuity and dry-run warning gate pass, but the normative launch procedure permits an upload flag combination rejected by the pinned CLI. This is a plan-level defect, not a source/payload defect. Earlier product, full-suite and preupload consumer verdicts remain preserved for the unchanged included bytes; account, authority, approval, actual upload and hosted checks remain deferred and are not certified by this report.

## Verification performed

The reviewer read only the assigned criteria, normative artifacts, inventories, raw final logs, previous independent review evidence and validation conventions. No author implementation narratives were used. The complete payload was copied to `/private/tmp/webmcp-inventory-review-02/copy`, including 32 existing example/build files and the source-identical hidden `.pubignore`. All publishing validation used that disposable copy. No original source, payload, criteria or Git index was edited. Four synthetic exclusion probes were created only inside the disposable copy: `example/build/reviewer-synthetic-generated.txt`, `build/reviewer-synthetic-generated.txt`, `.env.reviewer` and `wiki/reviewer-synthetic.md`.

The first pinned CLI help attempt encountered sandbox cache denial, recorded here; its subsequent approved retry exited zero. This was an environment error resolved by SDK cache access, not a passed initial check.

Command in original payload: `/Users/ortalcohen/fvm/versions/3.47.0/bin/dart pub publish --help`

```text
/Users/ortalcohen/fvm/versions/3.47.0/bin/internal/update_engine_version.sh: line 71: /Users/ortalcohen/fvm/versions/3.47.0/bin/cache/engine.stamp.tmp.53269: Operation not permitted
/Users/ortalcohen/fvm/versions/3.47.0/bin/internal/update_engine_version.sh: line 78: /Users/ortalcohen/fvm/versions/3.47.0/bin/cache/engine.realm: Operation not permitted
Exit: 1
```

Approved help retry:

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

The flag probe below ran in a freshly created empty directory with no package manifest or publishable content and returned during argument validation. It did not authenticate or upload. Help alone does not expose this restriction. All remaining CLI commands are explicit dry-runs.

### upload-argument

Working directory: `/private/tmp/webmcp-inventory-review-02/empty`.

Command: `/Users/ortalcohen/fvm/versions/3.47.0/bin/dart pub publish --ignore-warnings`

```text
`--ignore-warnings` can only be used with `--dry-run`.

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

Exit: 64
```

### ordinary

Working directory: `/private/tmp/webmcp-inventory-review-02/copy`.

Command: `/Users/ortalcohen/fvm/versions/3.47.0/bin/dart pub publish --dry-run`

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

### waived

Working directory: `/private/tmp/webmcp-inventory-review-02/copy`.

Command: `/Users/ortalcohen/fvm/versions/3.47.0/bin/dart pub publish --dry-run --ignore-warnings`

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

### exclusions

Working directory: `/private/tmp/webmcp-inventory-review-02/copy`.

Command: `/Users/ortalcohen/fvm/versions/3.47.0/bin/dart pub publish --dry-run --ignore-warnings`

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

### Full inventory, warning policy and negative identity checks

Command: `python3 /private/tmp/webmcp-inventory-review-02/verify.py`

```text
PASS: ordinary actual CLI selected exactly all 22 approved paths, excluded .pubignore/generated outputs, sole allowed warning, exit 65
PASS: waived actual CLI selected exactly all 22 approved paths, excluded .pubignore/generated outputs, sole allowed warning, exit 0
PASS: exclusions actual CLI selected exactly all 22 approved paths, excluded .pubignore/generated outputs, sole allowed warning, exit 0
PASS: existing final-source-controls-dry listing and warnings match independent actual runs
PASS: existing final-controls-waived listing and warnings match independent actual runs
PASS: unchanged source/inventory paths, sizes and SHA-256 in /Users/ortalcohen/Documents/GitHub/flutter_webmcp
PASS: unchanged source/inventory paths, sizes and SHA-256 in /private/tmp/webmcp-release-010-run/payload
PASS: unchanged source/inventory paths, sizes and SHA-256 in /private/tmp/webmcp-inventory-review-02/copy
PASS: control SHA-256 441429ac422354d4ecfa28c25027c735f2d09aa3cbf35ecb322427e1432a33c3
Inventory SHA-256: d73593ced4a5b3b75e9fc77674bf25eabd51e1eadff347e18c50e180932c9f0e
EXPECTED REJECTION: unexpected warning
EXPECTED REJECTION: unexpected error
EXPECTED REJECTION: changed included bytes fail approved inventory identity
PASS: disposable changed-byte probe restored
CHANGELOG.md 298 2684920c1198836a2d9c29840d2fd6f6323ca519450f566addb87ffee9ad4832
LICENSE 1071 03da847fe3b1c3de80123eecdd6e591661982ead07c5ecf7671d4f3a79b9875e
README.md 3991 2065e0ce4de29e236d72dd249044425dd9196d0647b9d36ac1c9e9f9760d7c4f
example/analysis_options.yaml 191 057d9e7ac76d22002c3d152858da3f450165588ace6e55ccdf90662b70ff1432
example/lib/example_screen.dart 2156 fd186adcbfa5bc01e44ebf51f9a31b039984dbc339115cff53502b6991217bbc
example/lib/example_tools.dart 858 cf8c1328a6bc3d6d5fb06b99ad70585dda7b9765fc3c56e972653aed0bddfc9a
example/lib/main.dart 404 8e4207ad7b48b9ec7070c83e5f06cb1a522a1ea78986d65a572e51d6d03be383
example/pubspec.yaml 345 56543caef9acb59bb1dd3322e4a3789488063d3c8ddffa89e339b52360d2cf36
example/web/index.html 397 6a64ebf75be267a6e3f6571a5ace88569eecff6ede26ed9ef93b5514fe17c166
lib/src/transport/transport_noop.dart 500 a186e586040aac849cc64c5c7287802c2a6e1cab39fe11994701bed423a880aa
lib/src/transport/transport_selector.dart 80 e7227a06a84a45fc0f34b55fb847873cc2e84bec043a7736cb94a97161846d26
lib/src/transport/transport_web.dart 1407 4d32536fa44f83c933359e9ed0ad664398b75622e501ce7130f6efdbc0abeac1
lib/src/transport/webmcp_transport.dart 413 95ff6e6dd4b757332fb6c2b77f56a6540bdb765e56e2ced7e588c3fb782d95ff
lib/src/webmcp.dart 2425 faf662d7eba4ee706f693de8c42a6dbc8695995e1619ad7a1cb7c3639b33b1e5
lib/src/webmcp_exceptions.dart 1700 bfc4bbb445aa2e025919f992f563d17432546ce6c3fb494290e91283db7350ec
lib/src/webmcp_scope.dart 2413 65e332711bc560446ad7997395be88eb4d5fe427bbe0ba270333f80e42e73bd8
lib/src/webmcp_tool.dart 931 6d331d724adee4dfd50296a1d6a9cc4ec3e2f1922b76776bdd5a7538718dad12
lib/src/webmcp_tool_source.dart 219 b989272951455c982f69f56f4dfb18e1ec4c21ca4e4b7721d714f144175dfc81
lib/src/widgets/webmcp_action.dart 2175 888f113ce9b2db489c202efb81e8b631afd7261f09075a4b6f0994b4502e0146
lib/src/widgets/webmcp_screen.dart 1100 ceb46b9a2de0f0fc5cebb1224be737457acbb7bcab625cbfacd0c36221d3e37d
lib/webmcp_flutter.dart 292 7c9c9aed4e054679c4e47267ae9d8a8fe2eaf7e232ebbafb773f66ba10e20fd3
pubspec.yaml 384 c4d014318d00568e229bbc0c8d85ab62c44c8d411919da70705f86ea9345dd1a
Exit: 0
```

The actual publisher tree is parsed into full relative paths; human-readable rounded CLI sizes are not treated as exact byte sizes. Exact sizes and SHA-256 values above are read directly from every corresponding source, original payload and copied file. Both supplied final logs select the same paths and warning as the independent CLI runs. `.pubignore` is a byte-identical excluded selection control, not a 23rd published file. The negative byte probe alters only the disposable README and restores it after detecting the mismatch. Unexpected-warning/error negatives exercise the acceptance predicate; generated-file exclusion exercises the actual publisher.

## Per-criterion results

| Criterion | Result | Evidence (file:line) | Negative case exercised |
|---|---|---|---|
| AC-001 | Earlier PASS preserved; outside this focused followup | `validation/impl-review-01.md:899` | Earlier pinned-source negative evidence preserved. |
| AC-002 | Earlier selection/metadata PASS preserved; launch account/availability/authority deferred | `validation/impl-review-01.md:900` | Earlier fabricated-URL negative preserved; launch negatives deferred. |
| AC-003 | Earlier PASS preserved for independently rehashed unchanged files | `validation/impl-review-01.md:901`; `27-payload-inventory.json:1` | Earlier metadata/import negatives preserved. |
| AC-004 | Earlier PASS preserved for unchanged README/barrel | `validation/impl-review-01.md:902`; `validation/impl-review-01.md:501` | Earlier fresh missing-barrel consumer failure preserved. |
| AC-005 | Earlier PASS preserved for unchanged runtime/documentation | `validation/impl-review-01.md:903` | Earlier actual runtime negatives preserved. |
| AC-006 | Earlier PASS preserved for unchanged included transport | `validation/impl-review-01.md:178`; `validation/impl-review-01.md:904` | Earlier real Chrome absent/present/restoration evidence preserved. |
| AC-007 | Earlier exact SDK full-suite PASS preserved; no full-suite rerun in this packaging followup | `validation/impl-review-01.md:34`; `validation/impl-review-01.md:151`; `validation/impl-review-01.md:905` | Earlier negative suite/browser evidence preserved; fresh sandbox help failure recorded and resolved above. |
| AC-008 | PASS | `.pubignore:30`; `27-payload-inventory.json:1`; `21-release-decisions.md:47`; independent ordinary/waived/exclusions outputs above | Actual publisher excludes existing build files and four added synthetic probes. Only allowlisted warning present. Unexpected warning/error rejected by predicate. |
| AC-009 | PASS for unchanged preupload payload continuity; hosted consumer deferred | `validation/impl-review-01.md:383`; `validation/impl-review-01.md:483`; `validation/impl-review-01.md:501`; fresh inventory output above | Earlier fresh README/example success and missing-barrel failure preserved; changed bytes rejected now. No new consumer build claimed. |
| AC-010 | FAIL for executable launch procedure; candidate identity PASS; actual account approval/upload/hosted execution deferred | `21-release-decisions.md:49`; `19-criteria-consolidated.md:23`; upload-argument output above | Actual pinned CLI rejects planned upload flag with exit 64. Changed included bytes rejected by inventory predicate. |
| AC-011 | Earlier PASS preserved; reviewer made no source/payload/index edits | `validation/impl-review-01.md:909`; `.pubignore:22`; fresh inventory/exclusion output above | Actual synthetic environment/wiki/build exclusions exercised; prior preservation and recovery evidence retained. |

The prior independent report is retained as evidence, not represented as commands rerun in this followup. This report supersedes only its implication that the normative launch procedure is executable with the documented upload flag. Earlier tested product and consumer behavior remains bounded to that review and the unchanged included bytes. All relative work-item references resolve under `wiki/work/0005-pubdev-release-readiness/`.

## Findings

### F-001 — Normative interactive upload option is unsupported

- Severity: BLOCKER
- Location: `wiki/work/0005-pubdev-release-readiness/21-release-decisions.md:49`
- Criterion affected: AC-010
- Observation: The normative decision says an interactive upload may use `--ignore-warnings`. Independently invoking the pinned CLI with that option without `--dry-run` in an empty directory returns exit 64 and the exact diagnostic: `--ignore-warnings` can only be used with `--dry-run`.
- Why it matters: This permitted launch command cannot reach the upload phase. Passing dry-run validation does not establish that the same waiver option is supported during interactive publication. The defect is in the launch procedure; included package bytes and the dry-run warning exception remain valid under their tested gates.

## Recurrence check

- Previous round: `validation/impl-review-01.md`.
- Recurring findings: none; previous round reported no findings.
- Oscillating: no.

## Routing

| Finding | Belongs to phase |
|---|---|
| F-001 | Plan — normative launch procedure contradicts pinned CLI argument contract. |

## Reproduction helper

`/private/tmp/webmcp-inventory-review-02/verify.py`

```python
from pathlib import Path
import json,re,hashlib
r=Path('/private/tmp/webmcp-inventory-review-02');repo=Path('/Users/ortalcohen/Documents/GitHub/flutter_webmcp');original=Path('/private/tmp/webmcp-release-010-run/payload');rows=json.loads((repo/'wiki/work/0005-pubdev-release-readiness/27-payload-inventory.json').read_text());expected=[v['path'] for v in rows]
def paths(text):
 result=[];stack=[];started=False
 for line in text.splitlines():
  if line.startswith('Publishing webmcp_flutter 0.1.0 '):started=True;continue
  if not started:continue
  if line.startswith('Total compressed archive size:'):break
  m=re.match(r'^((?:│   |    )*)[├└]── (.+)$',line)
  if not m:continue
  depth=len(m[1])//4;f=re.match(r'^(.*) \([^()]+\)$',m[2]);stack=stack[:depth]
  if f:result.append('/'.join(stack+[f[1]]))
  else:stack.append(m[2])
 return sorted(result)
def policy(text):
 assert [l for l in text.splitlines() if l.startswith('* ')]==['* It\'s strongly recommended to include a "homepage" or "repository" field in your pubspec.yaml']
 assert 'Package has 1 warning.' in text and 'error' not in text.lower()
for name,code in [('ordinary',65),('waived',0),('exclusions',0)]:
 text=(r/(name+'.log')).read_text();assert paths(text)==expected;policy(text);assert json.loads((r/(name+'.json')).read_text())['exit']==code
 print('PASS:',name,'actual CLI selected exactly all 22 approved paths, excluded .pubignore/generated outputs, sole allowed warning, exit',code)
for name in ['final-source-controls-dry','final-controls-waived']:
 text=(original.parent/(name+'.log')).read_text();assert paths(text)==expected;policy(text)
 print('PASS: existing',name,'listing and warnings match independent actual runs')
for root in [repo,original,r/'copy']:
 for row in rows:
  p=root/row['path'];assert p.stat().st_size==row['size'] and hashlib.sha256(p.read_bytes()).hexdigest()==row['sha256']
 print('PASS: unchanged source/inventory paths, sizes and SHA-256 in',root)
assert (repo/'.pubignore').read_bytes()==(original/'.pubignore').read_bytes()==(r/'copy/.pubignore').read_bytes()
print('PASS: control SHA-256',hashlib.sha256((original/'.pubignore').read_bytes()).hexdigest())
print('Inventory SHA-256:',hashlib.sha256((repo/'wiki/work/0005-pubdev-release-readiness/27-payload-inventory.json').read_bytes()).hexdigest())
for label,text in [('unexpected warning',(r/'waived.log').read_text()+'\n* Unexpected synthetic warning\n'),('unexpected error',(r/'waived.log').read_text()+'\nPackage has 1 error.\n')]:
 try:policy(text)
 except AssertionError:print('EXPECTED REJECTION:',label)
 else:raise AssertionError('Invalid policy accepted')
p=r/'copy/README.md';b=p.read_bytes();p.write_bytes(b+b'\nSynthetic changed-byte probe.\n')
try:
 row=next(v for v in rows if v['path']=='README.md');assert hashlib.sha256(p.read_bytes()).hexdigest()==row['sha256']
except AssertionError:print('EXPECTED REJECTION: changed included bytes fail approved inventory identity')
else:raise AssertionError('Changed bytes accepted')
p.write_bytes(b)
assert hashlib.sha256(p.read_bytes()).hexdigest()==row['sha256']
print('PASS: disposable changed-byte probe restored')
for row in rows:print(row['path'],row['size'],row['sha256'])
```
