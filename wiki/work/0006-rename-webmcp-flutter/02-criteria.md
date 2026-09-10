# Acceptance criteria: Rename package to webmcp_flutter

## Frozen

- Frozen at: 2026-09-10
- Frozen by: Codex

## Criteria

| ID | Criterion | How it is checked | Negative case |
|---|---|---|---|
| AC-001 | When dependencies are resolved, the root package shall be webmcp_flutter with lib/webmcp_flutter.dart as its only public barrel and all existing exported symbols retained. | Inspect manifest and barrel diff; run existing public-import tests. | A disposable consumer importing the old barrel fails to resolve. |
| AC-002 | When the example resolves and tests run, it shall use webmcp_flutter_example and the webmcp_flutter path dependency throughout its imports and resolved metadata. | Inspect example manifest and generated metadata; run example tests through the full check. | Replacing one example import with the old package identity in a disposable copy causes its test to fail. |
| AC-003 | When active files are inspected, README, source logger names, example branding and web metadata, hygiene rules, and active product documentation shall use the new identity with no old package identity remaining. | Search active source, tests, manifests, README and product docs, excluding historical work records and generated build output; inspect new labels. | An old identity inserted into a disposable active file makes the same absence check fail. |

## Non-functional criteria

| ID | Criterion | How it is checked | Negative case |
|---|---|---|---|
| AC-004 | When compared with the pre-rename baseline, version, license, dependencies other than renamed local package keys, platforms, exported API and runtime behavior shall remain unchanged, and pre-existing edits and historical wiki artifacts shall be preserved. | Review the isolated diff against the supplied snapshot and run bash tools/check.sh plus python3 tools/lint_wiki.py with the pinned SDK; paste exact outputs. | In a disposable copy, change the version and confirm the same baseline invariant check rejects it. |

## Explicitly not required

Publication, name availability, account authorization, work item 0005 release gates, compatibility shims, new features, new permanent rename-only tests, staging, commits, or publishing. Ignored dependency metadata is regenerated without adding it to version control.

## Verdict log

| Round | Date | Verdict | Report |
|---|---|---|---|
