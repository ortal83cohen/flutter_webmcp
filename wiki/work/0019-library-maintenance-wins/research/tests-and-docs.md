# Research: Missing public-API assertions, requestId boundary tests, and documentation gaps

## Question

What are the exact missing public-API symbol assertions in `test/webmcp_public_surface_test.dart`,
the exact `requestId` boundary rules and which boundary cases have no test coverage, and the
smallest accurate documentation additions needed for the `pubspec.yaml` issue-tracker field,
the public library entry, and an example README?

## Answer

Seven exported public symbols have no assertion in the surface test.  The `requestId` fences are
`< 1` and `> webMcpMaxSafeInteger`; the idempotent-replay path requires an identical 6-field
fingerprint; and four boundary cases are untested.  The `pubspec.yaml` is missing the `issue_tracker`
field, `example/README.md` does not exist, and the README body understates the fingerprint rule
for same-id replay.

## Findings

### Seven exported symbols are absent from the public-surface test

- Claim: `WebMcpEvidenceKind`, `WebMcpPageErrorCode`, `webMcpMaxSafeInteger`, `webMcpPageProtocolVersion`, `WebMcpBindingViewProvider`, `WebMcpViewBinding`, and `WebMcpViewProvider` are each exported from `lib/webmcp_flutter.dart` but have no `expect(..., isNotNull)` assertion in the surface test.
- Evidence: All seven names appear in `lib/src/page/page.dart` (lines 5, 9, 12, 13, 15) and therefore re-exported through `lib/webmcp_flutter.dart` (line 1). The surface test file spans lines 20–73 of `test/webmcp_public_surface_test.dart` and contains no reference to any of the seven names.
- Source: `lib/src/page/page.dart:5–15`; `test/webmcp_public_surface_test.dart:20–73`

### requestId lower fence: `< 1` returns `invalidArguments`

- Claim: Any `requestId` whose normalised integer value is less than 1 is rejected with `WebMcpPageErrorCode.invalidArguments` before any admission or fingerprint check.
- Evidence: `if (requestId < 1 || requestId > webMcpMaxSafeInteger) { return webMcpPageError(WebMcpPageErrorCode.invalidArguments); }` appears after the integer normalisation and unsupported-action check.
- Source: `lib/src/page/webmcp_page.dart:1010–1011`

### requestId upper fence: `> webMcpMaxSafeInteger` returns `invalidArguments`

- Claim: Any normalised integer value above `webMcpMaxSafeInteger` (9007199254740991) is rejected with the same fence check; Dart `int` can represent `webMcpMaxSafeInteger + 1` so the check is reachable in test.
- Evidence: Same guard as above; `webMcpMaxSafeInteger` is defined as `9007199254740991` at `lib/src/page/webmcp_page_protocol.dart:7`.
- Source: `lib/src/page/webmcp_page.dart:1010–1011`; `lib/src/page/webmcp_page_protocol.dart:7`

### Idempotent-replay path requires identical 6-field fingerprint

- Claim: A repeat call with `requestId == _highestRequestId` returns the cached receipt only when the fingerprint (a JSON encoding of `pageId`, `mountToken`, `revision`, `handle`, `action`, and `arguments`) is identical to `_latestRequestFingerprint`; a matching id with any differing field returns `duplicateRequest`.
- Evidence: `if (requestId == _highestRequestId && fingerprint == _latestRequestFingerprint && _latestReceipt != null) { return _latestReceipt; } return webMcpPageError(WebMcpPageErrorCode.duplicateRequest);` at lines 1026–1032; the fingerprint map construction at lines 1014–1023 names exactly those six keys.
- Source: `lib/src/page/webmcp_page.dart:1014–1032`

### Four requestId boundary cases have no test

- Claim: The existing test at lines 102–169 of `test/page/webmcp_page_test.dart` covers `requestId=2` success, `requestId=2` exact-repeat idempotency, and `requestId=1` out-of-order `duplicateRequest`, but does not test: (a) `requestId=0` → `invalidArguments`; (b) `requestId=webMcpMaxSafeInteger` → success; (c) `requestId=webMcpMaxSafeInteger+1` → `invalidArguments`; (d) same `requestId` with a different `action` → `duplicateRequest` (not cached receipt).
- Evidence: A grep for `requestId.*0`, `requestId.*webMcpMax`, and the fingerprint-mismatch branch in `test/page/webmcp_page_test.dart` returns no matches beyond line 230 (`1.0` float normalisation) and lines 132–167 (the out-of-order case).  The float normalisation test (`requestId: 1.0`) at lines 222–235 does not test a boundary value.
- Source: `test/page/webmcp_page_test.dart:102–169`, `test/page/webmcp_page_test.dart:222–235`; `lib/src/page/webmcp_page.dart:1010–1032`

### `pubspec.yaml` is missing the `issue_tracker` field

- Claim: `pubspec.yaml` declares `repository` and `homepage` but omits `issue_tracker`, so pub.dev will not render an issue-tracker link.  The README body already links to `https://github.com/ortal83cohen/flutter_webmcp/issues/new/choose`, confirming the intended URL.
- Evidence: `pubspec.yaml` lines 3–8 contain `repository` and `homepage` but no `issue_tracker` key.  The README at line 15 references `https://github.com/ortal83cohen/flutter_webmcp/issues/new/choose`.
- Source: `pubspec.yaml:3–8`; `README.md:15`

### `example/README.md` does not exist

- Claim: `example/` has no `README.md`; a consumer browsing the repository or pub.dev example tab sees only code with no orientation text.
- Evidence: A glob for `example/README.md` under the workspace root returned zero results.  The directory contains 11 Dart source files and `pubspec.yaml` but no markdown.
- Source: `example/` directory listing (glob result)

### README understates the fingerprint rule for same-id replay

- Claim: `README.md` line 354–355 states "A matching retry of the latest request can return its cached receipt" without stating that all six wire fields (`pageId`, `mountToken`, `revision`, `handle`, `action`, `arguments`) must match; a consumer reading only the README would not know that changing any one field on a reused id returns `duplicateRequest`.
- Evidence: The README text at lines 352–355 says only "Use increasing positive `requestId` values up to `webMcpMaxSafeInteger`" and "A matching retry of the latest request can return its cached receipt while the snapshot remains valid".  The implementation fingerprints all six fields at `lib/src/page/webmcp_page.dart:1014–1023`.
- Source: `README.md:352–355`; `lib/src/page/webmcp_page.dart:1014–1032`

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Add missing assertions to existing surface test | Append seven `expect` lines inside the existing single test case in `test/webmcp_public_surface_test.dart` | One file, ~7 lines | Chosen: minimal, keeps surface test consistent with its established pattern |
| Create a separate surface-test file for page exports | New file covering only page-layer exports | Two files, more duplication | Rejected: the existing single test covers all other layers; splitting adds maintenance overhead without benefit |
| Add requestId boundary cases to existing `_act` test | Add four `testWidgets` sub-cases or extend the existing "stale revision" test at line 102 | ~30 lines in existing file | Chosen: co-locates with the established boundary test; no new file needed |
| Test requestId boundaries in a separate unit test (no widget) | Pure unit test; would require reaching internal `_act` via reflection or a shim | Requires internal access | Rejected: `_act` is private; widget-based test is the only clean path |
| Add `issue_tracker` to `pubspec.yaml` | One key addition; value mirrors the existing README link | One line | Chosen: smallest accurate change; no invented information |
| Add a full `example/CONTRIBUTING.md` or `example/CHANGELOG.md` | More documentation surface | Several files | Rejected: out of scope; only the missing README was identified |

## Constraints discovered

- `webMcpMaxSafeInteger` is a top-level Dart `const int`; Dart `int` supports values above it on native, so a test sending `webMcpMaxSafeInteger + 1` (= 9007199254740992) does not require floating-point tricks.
- The `_act` handler normalises `double` values that are integer-valued to `int` (lines 703–712), so a boundary test sending `webMcpMaxSafeInteger.toDouble()` would accept the value, not reject it; only `webMcpMaxSafeInteger + 1` as an `int` will hit the upper fence.
- The seven missing surface-test symbols are all from the page layer (`lib/src/page/page.dart`); they were introduced in a prior phase and the surface test was not updated.
- `example/pubspec.yaml` sets `publish_to: none` (line 4), so the example directory is never published; a README there is for human readers only.
- The annotation packages (`webmcp_flutter_annotations`, `webmcp_flutter_generator`) are listed in README line 471 with the explicit note "publication availability is not established here", so no documentation should claim those packages are on pub.dev.
- `webMcpPageProtocolVersion` and `webMcpMaxSafeInteger` are `const int` top-level names, not class or enum names; their surface-test assertions must use `expect(webMcpMaxSafeInteger, isA<int>())` or a similar form, not `expect(webMcpMaxSafeInteger, isNotNull)` (integers are always non-null in Dart).

## Unresolved

- [UNRESOLVED: The README addition for the fingerprint rule needs an exact prose draft; the minimum accurate wording has not been validated against the full act documentation block.]
- [UNRESOLVED: Whether pub.dev renders the `issue_tracker` field at `https://github.com/ortal83cohen/flutter_webmcp/issues` (without `/new/choose`) or requires the exact `new/choose` suffix was not verified against live pub.dev rendering.]

## Sources

- `lib/webmcp_flutter.dart` — public library entry (lines 1–13)
- `lib/src/page/page.dart` — page-layer re-exports (lines 1–16)
- `lib/src/page/webmcp_page.dart` — `_act` implementation (lines 940–1124)
- `lib/src/page/webmcp_page_protocol.dart` — `WebMcpPageErrorCode`, `webMcpMaxSafeInteger`, `webMcpPageProtocolVersion` (lines 1–125)
- `lib/src/page/webmcp_app_session.dart` — `WebMcpEvidenceKind` (lines 14–25)
- `lib/src/page/webmcp_view_provider.dart` — `WebMcpViewBinding`, `WebMcpViewProvider`, `WebMcpBindingViewProvider`
- `test/webmcp_public_surface_test.dart` — current surface test (lines 20–73)
- `test/page/webmcp_page_test.dart` — requestId tests (lines 102–169, 202–237)
- `pubspec.yaml` — package metadata (lines 1–35); consulted 2026-10-11
- `README.md` — user-facing documentation (lines 350–360); consulted 2026-10-11
- `example/pubspec.yaml` — example metadata; consulted 2026-10-11
