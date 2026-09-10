# Plan review round 03: corrected upload command

Verdict: **PASS**

Findings: none.

## Scope and criterion assessment

This is one blind, narrow plan review of `34-final-publication-controls.md` against frozen criteria `19-criteria-consolidated.md`, normative warning policy `23-warning-policy-evidence.md`, and the validation rubric. It assesses corrected command guidance; it does not revalidate the product, authenticate an account, establish user authorization independently, confirm a live publisher, or establish hosted publication success. State was read for the required work-item phase check; its recorded decisions were not evidence for this verdict. Naming conventions were consulted only for report format.

- AC-002: PASS for the reviewed guidance. Artifact 34:24 records private account authentication and existing exact-candidate execution authorization; 34:40-51 records the availability check. This review does not independently attest to those historical facts or broaden authorization.
- AC-008: PASS for the reviewed guidance. Artifact 34:14 limits `--ignore-warnings` to dry-run. The captured ordinary and waived diagnostics match policy 23's exact optional-URL warning; neither force nor validation bypass is selected. Artifact 34:18-20 requires the final actual publisher inventory before confirmation; 34:225-234 checks paths, sizes, hashes and publication-control bytes.
- AC-010: PASS for the reviewed guidance. Ordinary interactive publish retains confirmation. Artifact 34:18-24 retains unchanged candidate identity, actual final inventory comparison and the selected authorized account. The frozen criterion continues to require technical gates and blind review before upload and hosted checks after upload; this command correction does not waive those gates.
- AC-011: PASS for the reviewed guidance. Artifact 34:14 uses explicit supersession, and 34:24 preserves private account handling and MIT continuity. No source, payload, index or state changes were made by this review.
- AC-001 and AC-003 through AC-007 and AC-009: unchanged and outside this narrow command-plan delta; no new implementation or hosted verdict is issued for them.

## Independently executed command evidence

Command: `/Users/ortalcohen/fvm/versions/3.47.0/bin/cache/dart-sdk/bin/dart --version`

```text
Dart SDK version: 3.13.0 (stable) (Wed Aug 5 00:28:05 2026 -0700) on "macos_arm64"
```

Command: `/Users/ortalcohen/fvm/versions/3.47.0/bin/cache/dart-sdk/bin/dart pub publish --help`

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
```

The tool call containing these two commands exited 0.

The following three commands were independently executed in the same empty temporary directory, with stdin closed and a 20-second subprocess timeout. No package was present, so no authentication or upload could occur. The live publisher was not accessed. The negative command confirms that the superseded invocation is rejected; the other commands reach package discovery, demonstrating accepted argument combinations without attempting a release.

Command: `/Users/ortalcohen/fvm/versions/3.47.0/bin/cache/dart-sdk/bin/dart pub publish --ignore-warnings`

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

Command: `/Users/ortalcohen/fvm/versions/3.47.0/bin/cache/dart-sdk/bin/dart pub publish --dry-run --ignore-warnings`

```text
Found no `pubspec.yaml` file in `/private/var/folders/gl/7cm92gjx1pq9ftt5fxjthhbw0000gn/T/webmcp-plan-review-03-2z8begsl` or parent directories
Exit: 66
```

Command: `/Users/ortalcohen/fvm/versions/3.47.0/bin/cache/dart-sdk/bin/dart pub publish`

```text
Found no `pubspec.yaml` file in `/private/var/folders/gl/7cm92gjx1pq9ftt5fxjthhbw0000gn/T/webmcp-plan-review-03-2z8begsl` or parent directories
Exit: 66
```

## Independent artifact comparison

Command: `python3 -` with the following stdin. This checks the supplied evidence text and plan controls; it does not claim a fresh dry-run or live byte inventory.

```python
from pathlib import Path
import re
p=Path('wiki/work/0005-pubdev-release-readiness/34-final-publication-controls.md').read_text()
blocks=re.findall(r'```text\n(.*?)```',p,re.S)
ordinary=next(b for b in blocks if 'Publishing webmcp_flutter' in b and 'Exit: 65' in b)
waived=next(b for b in blocks if 'Publishing webmcp_flutter' in b and 'Exit: 0' in b)
warning='* It\'s strongly recommended to include a "homepage" or "repository" field in your pubspec.yaml'
policy=Path('wiki/work/0005-pubdev-release-readiness/23-warning-policy-evidence.md').read_text()
assert warning in policy
for label,b in [('ordinary',ordinary),('waived',waived)]:
 diagnostics=b.split('Validating package...\n')[1].split('\nExit:')[0].strip()
 expected='Package validation found the following potential issue:\n'+warning+'\nThe server may enforce additional checks.\n\nPackage has 1 warning.'
 assert diagnostics==expected
 print(label+': captured diagnostic exactly matches the sole policy warning; no additional diagnostic')
a=ordinary.split('Publishing webmcp_flutter')[1].split('Total compressed')[0]
b=waived.split('Publishing webmcp_flutter')[1].split('Total compressed')[0]
assert a==b
assert len(re.findall(r'^.*[├└]── .* \([^()]+\)$',a,re.M))==22
print('Captured ordinary and waived publisher listings match exactly: 22 file entries')
assert 'The final actual publish inventory must also be checked before confirmation.' in p
assert 'full relative paths, byte sizes, SHA-256' in p
assert 'ordinary interactive `dart pub publish`, retaining validation and explicit confirmation' in p
assert 'Do not record account identity or credentials' in p
print('Guidance retains actual live inventory check, byte identity, interactive confirmation and private account handling')
```

```text
ordinary: captured diagnostic exactly matches the sole policy warning; no additional diagnostic
waived: captured diagnostic exactly matches the sole policy warning; no additional diagnostic
Captured ordinary and waived publisher listings match exactly: 22 file entries
Guidance retains actual live inventory check, byte identity, interactive confirmation and private account handling
```

Exit: 0.

## Verification performed

Report-format addendum by the orchestrator: the independently executed commands and complete outputs remain preserved under "Independently executed command evidence" and "Independent artifact comparison" above. This adds the canonical rubric heading without altering the review verdict or evidence.

## Recurrence check

- Previous plan round: plan-review-02.md.
- Recurring plan-review findings: none; this narrow review has no findings.
- The intervening implementation review's F-001 prompted corrected command guidance in 34, which this round reviewed independently.
- Oscillating: no.
