# Acceptance criteria: Publish repository metadata link

## Frozen

- Frozen at: not yet
- Frozen by: pending implementation gate

## Criteria

| ID | Criterion | How it is checked | Negative case |
|---|---|---|---|
| AC-001 | When the release source is prepared, pubspec.yaml declares webmcp_flutter 0.1.1 and repository https://github.com/ortal83cohen/flutter_webmcp, all remaining manifest fields equal the baseline, and CHANGELOG.md records only the new metadata release above the retained 0.1.0 entry. | Parse and compare the manifest against the pre-edit baseline and inspect the changelog diff; retain command output. | Synthetic missing or incorrect repository, wrong version and changed dependency fail the same assertions. |
| AC-002 | When the candidate is selected for publication, its actual final CLI selection contains exactly the approved 22 paths, only pubspec.yaml and CHANGELOG.md differ from the approved 0.1.0 bytes, and ordinary dry-run validation reports zero package warnings and errors. | Compare selected paths and candidate sizes and hashes after all builds and immediately before upload confirmation; retain .pubignore identity and full dry-run output. | Synthetic extra generated path, omitted approved path or altered runtime hash is rejected; a synthetic package warning is rejected by the diagnostic gate. |
| AC-003 | When verification runs, the canonical suite and wiki lint exit successfully, and fresh external payload and exact hosted 0.1.1 consumers build for web with verified package provenance. | Paste bash tools/check.sh, lint and both build outputs with exit statuses; record package roots, exact hosted version, fresh cache and built output. | The verification gate rejects a nonzero check or build status, missing build artifact, or a synthetic provenance record resolving another version or a local path for the hosted consumer. |
| AC-004 | When publication finishes, the exact hosted 0.1.1 API contains the requested repository metadata, its archive matches the registry SHA-256 and all approved candidate paths, sizes and hashes, and the rendered pub.dev version page links to the exact supplied repository URL. | Retain normal interactive upload output, exact hosted API and archive verification output, and parsed repository anchor evidence from the public version page. | Synthetic wrong-version API, altered archive bytes, and missing or incorrect repository anchor fail the same checks. |

## Non-functional criteria

| ID | Criterion | How it is checked | Negative case |
|---|---|---|---|
| AC-005 | When this item is closed, its append-only evidence and independent final verdict substantiate every criterion, unrelated source and Git index changes remain preserved, and work item 0005's pending presentation state has not been overwritten. | Compare before/after snapshots for source outside the two-file boundary, index and prior STATE; run wiki lint; inspect review and disposition records. | Synthetic unauthorized source/index/prior-state changes or a closure record with a pending criterion are rejected by the preservation and closure checks. |

## Explicitly not required

No new runtime tests or repeated browser session are required when the runtime and browser-tested source bytes match the approved 0.1.0 inventory. The prior work item's API documentation and web badge processing do not gate this repository-link outcome. No commit, push, new dependency, README edit, or new runtime capability is required.

## Verdict log

| Round | Date | Verdict | Report |
|---|---|---|---|
