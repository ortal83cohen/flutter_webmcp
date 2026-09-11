# Implementation: Publish repository metadata link

## Scope

Changed only the authorized release source files:

- `pubspec.yaml`: advanced `version` from `0.1.0` to `0.1.1` and added the exact repository value `https://github.com/ortal83cohen/flutter_webmcp`.
- `CHANGELOG.md`: inserted the 0.1.1 metadata-release entry immediately after the changelog title while retaining the complete 0.1.0 entry.

No dependency, SDK constraint, platform, runtime, example, test, prior work-item state, or Git index entry was changed.

## Source metadata and preservation check

Command:

    python3 /private/tmp/webmcp-release-011-run/source_checks.py

Output:

    PASS: parsed manifest changes only version and exact repository; changelog adds only the metadata release.
    Expected rejection: missing repository
    Expected rejection: wrong repository
    Expected rejection: wrong version
    Expected rejection: changed dependency
    PASS: all unrelated source/config bytes and prior0005 STATE unchanged.
    Index entries equal baseline: True
    Current index entries SHA-256: 2485f324580eb7636e2a735f9a496a78e3360bea6b556e82c4d72abcd4942434

Exit status: `0`.

## Diff whitespace check

Command:

    git diff --check

Output: empty.

Exit status: `0`.

## Result

The source patch is stable and ready for the parent-owned full suite, payload preparation, dry run, publication, and hosted verification phases. Those phases were not run here.
