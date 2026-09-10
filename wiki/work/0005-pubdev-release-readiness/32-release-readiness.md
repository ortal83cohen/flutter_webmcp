# Prepublication release readiness

## Scope and result

This record covers the completed prepublication checks for the ordinary `webmcp_flutter` `0.1.0` candidate. It does not claim publication, upload, hosted installation, or release completion. The immutable reviewed payload is `/private/tmp/webmcp-release-010-run/payload`, containing 22 files. Its inventory hash is `d73593ced4a5b3b75e9fc77674bf25eabd51e1eadff347e18c50e180932c9f0e`.

The independent implementation review is `PASS` in [validation/impl-review-01.md](validation/impl-review-01.md:8). It states that every applicable preupload criterion passed and that private launch authorization/account, live availability, and postpublication checks remain deferred. The concurrent Git observation is retained in [29-concurrent-git-observation.md](29-concurrent-git-observation.md:1); no release agent staged, committed, pushed, reset, stashed, or checked out Git state.

## Preupload proof

The exact pinned toolchain was Flutter 3.47.0 and Dart 3.13.0:

```text
Command: flutter --version
Flutter 3.47.0 ...
Tools • Dart 3.13.0 ...
Exit: 0
```

The canonical suite completed all six stages with no analysis issues, all tests passing, and a successful web build:

```text
Command: PATH=/Users/ortalcohen/fvm/versions/3.47.0/bin:$PATH CI=true bash tools/check.sh
lint_wiki: clean (0 warning(s)).
No issues found!
00:02 +46: All tests passed!
00:00 +1: All tests passed!
Stage 6 passed: build
Exit: 0
```

The real Chrome detection test covered both marker-absent and marker-present states without publishing registry changes:

```text
Command: flutter test --platform chrome test/transport_web_browser_test.dart --reporter expanded
00:00 +0: reports modelContext absent when the marker is missing
00:00 +1: reports modelContext present without publishing registry changes
00:00 +2: All tests passed!
Exit: 0
```

The payload was reproduced from the actual publisher listing and independently checked:

```text
Command: python3 /private/tmp/webmcp-release-010-run/payload.py verify
PASS: source/payload paths, sizes and SHA-256 unchanged; all four dry-run inventories identical
Exit: 0
```

The ordinary dry-run was retained first. It exited 65 solely for the accepted optional URL diagnostic; the unchanged `--ignore-warnings` run retained validation and exited zero. The exact diagnostic was: `It's strongly recommended to include a "homepage" or "repository" field in your pubspec.yaml.` The diagnostic checker recorded:

```text
source-dry: exact optional-URL warning only, zero errors; expected exit 65
source-waived: exact optional-URL warning only, zero errors; expected exit 0
payload-dry: exact optional-URL warning only, zero errors; expected exit 65
payload-waived: exact optional-URL warning only, zero errors; expected exit 0
Exit: 0
```

The fresh external consumer and shipped example resolved only to the reviewed payload and built successfully. Removing `lib/webmcp_flutter.dart` from a separate negative payload caused the README consumer build to fail with the missing path; the release payload was unchanged. Full command output and dependency provenance are in [31-release-verification.md](31-release-verification.md:667).

## Criteria boundary

| Criterion | Prepublication result |
|---|---|
| AC-001 | PASS: pinned capability comparisons and dispositions reused from 08, 14, 15, and 21. |
| AC-002 | PASS for selected package/version, SDK scope, URL policy, and MIT continuity; launch authority and live name/version checks remain open. |
| AC-003 | PASS: `webmcp_flutter`, `lib/webmcp_flutter.dart`, version `0.1.0`, SDK minimums, web-only scope, and publish-disabled example agree. |
| AC-004 | PASS: README hosted installation and public-import example compile from the payload; detection-only boundary is disclosed. |
| AC-005 | PASS: singleton, ownership, lifecycle, disabled-child, mounted descriptor, shallow schema, partial registration, raw local errors, notification, and reset limits are documented and tested. |
| AC-006 | PASS: real Chrome distinguishes marker absent/present and retains detection-only behavior. |
| AC-007 | PASS: pinned versions, canonical six-stage suite, and browser test exit zero. |
| AC-008 | PASS: 22-file payload identity and exclusions verified; only the explicitly accepted optional URL warning requires the recorded waiver. |
| AC-009 | PASS for preupload consumer/example checks; exact hosted-version consumer remains postpublication. |
| AC-010 | PASS for candidate identity and gate definition; exact account approval, upload, and hosted presentation remain open. |
| AC-011 | PASS for observed preservation, MIT continuity, no credential/personal fixture data, wiki history, and immutable recovery evidence. |

## Remaining launch gates

Before any upload, the user must privately verify account authority and redistribution rights while preserving the authorized MIT holder, recheck that `webmcp_flutter` and ordinary version `0.1.0` are available, and explicitly approve the exact payload, version, and account. The official `dart pub login` flow is currently waiting for the user’s account authentication. No OAuth URL, account identifier, credential, or personal account data is recorded here.

Publication must use the same unchanged hash-verified payload and the documented optional-URL waiver only if that remains the sole warning with zero errors. After authorized upload, verify the exact hosted version, clean hosted consumer, package page, API documentation, Example and Changelog presentation, and web badge.

If publication fails or the candidate is rejected, published bytes are immutable: prepare a corrected higher version, reproduce the payload, rerun all applicable gates, and obtain fresh approval. Do not overwrite or replace the published version; the recovery instruction is recorded at [17-plan-consolidated.md](../0005-pubdev-release-readiness/17-plan-consolidated.md:46).

## Local lint

Command: `python3 tools/lint_wiki.py`

```text
lint_wiki: clean (0 warning(s)).
```

Exit: 0

