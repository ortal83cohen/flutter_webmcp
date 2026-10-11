# Acceptance criteria: Tighten package publishing, tests, and onboarding docs

## Frozen

- Frozen at: 2026-10-11
- Frozen by: orchestrator

## Criteria

| ID | Criterion | How it is checked | Negative case |
|---|---|---|---|
| AC-001 | When `flutter pub publish --dry-run` runs from the repository root, its archive-tree entries shall include no entry named `packages` and no entry named `spikes`. An archive-tree entry is a listing line prefixed by box-drawing characters; its name is the token after that prefix and before a size parenthesis. | Run the dry run and collect those names; assert `packages` and `spikes` are absent. | Run the same dry run on commit `bf6d4795e0f339043487c4f007f1365573adf762`: both names shall be present, proving the search detects the directory entries and does not depend on the word appearing in prose. |
| AC-002 | When the same dry run runs, its archive-tree entries shall include top-level entries named `README.md`, `CHANGELOG.md` and `LICENSE`, an entry named `webmcp_flutter.dart` nested under `lib`, an entry named `main.dart` nested under `example` then `lib`, and an entry named `README.md` nested directly under `example`. | Walk the tree by indentation and assert each of those parent-and-name pairs is present. | On commit `bf6d4795e0f339043487c4f007f1365573adf762`, the entry named `README.md` nested directly under `example` shall be absent, so the check can fail. |
| AC-003 | When `.pubignore` is read, it shall contain the rooted entries `/packages/` and `/spikes/`, and every line present at commit `bf6d4795e0f339043487c4f007f1365573adf762` shall still be present. | Read the file; diff it against that commit and assert the diff only adds lines. | A diff that removes or edits any line from that commit, such as `/test/`, shall be reported as a failure by the same added-lines-only check. |
| AC-004 | When `.github/workflows/publish.yml` is parsed, it shall define a job with identifier `check` whose steps run `bash tools/check.sh`, and the job with identifier `publish` shall list `check` in its `needs`. | Parse the file as YAML; assert the `check` job exists, one of its steps runs that command, and `publish.needs` contains `check`. | Remove the `needs` entry from a scratch copy and re-run the assertion: it shall fail. |
| AC-005 | When the `check` job is read, it shall set up Flutter with `flutter-actions/setup-flutter@v4` on channel `stable` at version `3.47.0`, and set up Python `3.12` with `actions/setup-python@v5`, before running the check script. | Read the job steps in order; assert both setup steps precede the check-script step with those exact values. | A scratch copy with version `3.46.0` or with the setup step after the script step shall fail the same assertion. |
| AC-006 | When `publish.yml` is compared with commit `bf6d4795e0f339043487c4f007f1365573adf762`, its `on` block shall be identical and the `publish` job's `steps`, `permissions`, `runs-on` and `name` shall be identical. | Parse both versions as YAML and compare those keys for equality. | Comparing a scratch copy whose tag pattern drops the `v` prefix shall report a difference. |
| AC-007 | When the change is complete, `.github/workflows/release.yml` and `tools/check.sh` shall be byte-identical to commit `bf6d4795e0f339043487c4f007f1365573adf762`. | Path-scoped git diff against that commit for both files; assert empty output. | Append a blank line to a scratch copy of `release.yml` and diff: the output shall be non-empty. |
| AC-008 | When `test/webmcp_public_surface_test.dart` runs, it shall reference each of `WebMcpEvidenceKind`, `WebMcpPageErrorCode`, `WebMcpBindingViewProvider`, `WebMcpViewBinding`, `WebMcpViewProvider`, `WebMcpInputShape`, `webMcpPageProtocolVersion`, `webMcpMaxSafeInteger`, `webMcpSafeIntegerMinimum` and `webMcpSafeIntegerMaximum`, and shall pass. | Search the file for each of the ten names; run `flutter test test/webmcp_public_surface_test.dart` and assert it passes. | Remove `WebMcpViewBinding` from the `show` list in `lib/src/page/page.dart` in a scratch checkout and re-run the test: it shall fail to compile. |
| AC-009 | When the surface test runs, it shall assert by value equality that `webMcpPageProtocolVersion` is 1, `webMcpMaxSafeInteger` is 9007199254740991, `webMcpSafeIntegerMinimum` is -9007199254740991 and `webMcpSafeIntegerMaximum` is 9007199254740991, and that `WebMcpPageErrorCode.values` contains `invalidArguments` and `duplicateRequest`. | Read the assertions; assert each uses an equality or containment matcher with that value rather than a not-null matcher; run the test. | Change the expected protocol version to 2 in a scratch copy and run the test: it shall fail. |
| AC-010 | When the page act tool receives requestId 0 with otherwise valid fields, it shall return code `invalidArguments` and shall not invoke the node's tap callback. | A new widget test in `test/page/webmcp_page_test.dart` asserts the code and a callback counter of zero. | Removing the lower-bound comparison in a scratch copy of the act guard shall make that test fail. |
| AC-011 | When the page act tool receives the Dart integer `webMcpMaxSafeInteger + 1` as requestId, it shall return code `invalidArguments` and shall not invoke the tap callback. | The same new test asserts the code and an unchanged counter; the value is passed as an integer, not a double. | Removing the upper-bound comparison in a scratch copy of the act guard shall make that test fail. |
| AC-012 | When a request with requestId 1 and action `tap` has dispatched, and a second request reuses requestId 1 with action `longPress` and the same snapshot fields, the tool shall return code `duplicateRequest` and the tap callback count shall remain 1. | The same new test asserts the code and the counter after the second request. | The existing exact-repeat assertion in the same file, with action `tap` unchanged, shall still return the cached receipt rather than `duplicateRequest`. |
| AC-013 | When the page act tool receives requestId equal to `webMcpMaxSafeInteger` after a lower accepted id, it shall dispatch and the tap callback count shall increase by one. | The same new test asserts the dispatched flag is true and the counter is 2 at the end. | Asserting the same request with requestId `webMcpMaxSafeInteger + 1` yields `invalidArguments` (AC-011), so the accepted boundary is shown to be exactly the maximum. |
| AC-014 | When `pubspec.yaml` is read, it shall contain `issue_tracker: https://github.com/ortal83cohen/flutter_webmcp/issues` and its `version` shall equal the version at commit `bf6d4795e0f339043487c4f007f1365573adf762`. | Read the file and diff it against that commit; assert the only change is the added field. | A value ending in `/issues/new/choose` shall fail an exact-string comparison against the required value. |
| AC-015 | When `lib/webmcp_flutter.dart` is read, it shall begin with a library doc comment attached to a `library` directive, and that comment shall contain `WebMcp`, `WebMcpPage`, `WebMcpNativePublisher`, the word `experimental` and a reference to the README. | Read the file; search the doc comment for each term; run `dart analyze --fatal-infos --fatal-warnings` and assert no issue. | Remove the `library` directive in a scratch copy and run the analyzer: it shall report a dangling library doc comment. |
| AC-016 | When `example/README.md` is read, it shall state that the example must run from a repository checkout because it uses relative path dependencies, and give the steps to fetch dependencies and run it in Chrome from the `example` directory. | Read the file for the checkout requirement, the path-dependency reason and the run steps. | Commit `bf6d4795e0f339043487c4f007f1365573adf762` has no `example/README.md`: a glob for it there returns nothing. |
| AC-017 | When `example/README.md` and `lib/webmcp_flutter.dart` are read, neither shall state that `webmcp_flutter_annotations` or `webmcp_flutter_generator` is published on or available from pub.dev. | Search those texts for each companion package name and read every sentence that contains one. | A sentence such as "install webmcp_flutter_generator from pub.dev" added to a scratch copy shall be found by the same search and fail the read. |
| AC-018 | When the change is complete, the root `README.md` shall be byte-identical to commit `bf6d4795e0f339043487c4f007f1365573adf762`. | Path-scoped git diff of `README.md` against that commit; assert empty output. | Adding one sentence to a scratch copy shall make that diff non-empty. |
| AC-019 | When the change is complete, `bash tools/check.sh` shall exit zero and print `Stage 8 passed`. | Run the script from the repository root and paste its tail output. | Any failing stage prints `Stage N failed` and exits non-zero; a run showing that line fails this criterion. |
| AC-020 | When the change is complete, no file under `lib/src/`, `packages/` or `spikes/` shall differ from commit `bf6d4795e0f339043487c4f007f1365573adf762`. | Path-scoped git diff against that commit for those three paths; assert empty output. | Touching any file under `lib/src/` in a scratch copy shall make the diff non-empty. |

## Non-functional criteria

| ID | Criterion | How it is checked | Negative case |
|---|---|---|---|
| NF-001 | When `publish.yml` is read, only the `publish` job shall hold `id-token: write`; the `check` job shall hold `contents: read` and no other permission. | Parse the file; assert the `check` job permissions map equals contents read only and the `publish` job permissions are unchanged. | A scratch copy granting `id-token: write` to the `check` job shall fail the assertion. |
| NF-002 | When `publish.yml` is read, the `check` job shall reference no secret. | Search the `check` job block for `secrets.`; assert zero matches. | A scratch copy adding a `secrets.` reference to that job shall be matched by the search. |
| NF-003 | When `dart format --output=none --set-exit-if-changed lib test example/lib example/test` runs, it shall exit zero. | Run the command and paste the output. | Inserting an extra space in a scratch copy of an edited test file shall make it exit non-zero. |

## Explicitly not required

- A GitHub ruleset or protected-tag setting; the research leaves availability unresolved and enforcement is the workflow file.
- Running the publish workflow on GitHub during verification; the workflow is checked statically.
- Publishing the companion packages, or replacing the example path dependencies with hosted versions.
- A resolvable example from a package downloaded from pub.dev.
- Any change to the requestId fence, the fingerprint fields, or other product code under `lib/src/`.
- A manual version bump or CHANGELOG entry.
- A separate unit test or access seam for the private act method.
- Any edit to the root README. A sentence claiming that every changed fingerprint field returns duplicateRequest is not required, because pageId and mountToken mismatches return scopeGone and a non-current revision returns staleSnapshot.

## Verdict log

| Round | Date | Verdict | Report |
|---|---|---|---|
| 1 | 2026-10-11 | PASS | validation/impl-review-01.md |
