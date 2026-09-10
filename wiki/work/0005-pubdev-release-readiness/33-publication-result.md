# Publication gate

## Current outcome

No upload has been attempted. Prepublication implementation review is PASS; see validation/impl-review-01.md and 32-release-readiness.md. The exact candidate is webmcp_flutter 0.1.0, 22 included files at `/private/tmp/webmcp-release-010-run/payload`, inventory SHA-256 `d73593ced4a5b3b75e9fc77674bf25eabd51e1eadff347e18c50e180932c9f0e`.

The user requested execution of the publication plan. The official pinned Dart `pub login` flow has started and is waiting for the user to authenticate and select the authorized account. Credentials, account identity and OAuth flow values are deliberately not recorded here. Confirm the exact candidate/account and redistribution authority at the launch gate.

## Availability observation

Command: `python3 /private/tmp/webmcp-release-010-run/name_check.py`

```text
Checked UTC: 2026-09-10T13:37:31.314968+00:00
https://pub.dev/api/packages/webmcp_flutter HTTP 404
https://pub.dev/api/packages/webmcp_flutter/versions/0.1.0 HTTP 404
Exit: 0
```

This observation is not a reservation; recheck immediately before upload after any user delay.

## Resume sequence

After account authentication and launch confirmation, recheck the name/version and all 22 included path/size/hashes against 27. From the same payload directory, run the pinned `dart pub publish --ignore-warnings` interactively with ordinary validation. The only allowed warning is the already evidenced missing homepage/repository warning; unexpected warnings/errors or changed bytes stop confirmation. Do not use --force or --skip-validation. Record actual upload output without personal data.

Then confirm the exact hosted API version and archive, build a fresh consumer with hosted dependency pinned to 0.1.0, and verify package page, API docs, Example, Changelog and web badge. Record failures and recover through a separately reviewed higher version; do not overwrite or delete published bytes. No hosted checks are claimed before upload.
