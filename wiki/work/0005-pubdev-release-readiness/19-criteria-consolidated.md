# Acceptance criteria: consolidated release readiness

## Frozen

- Frozen at: not yet; freeze upon authorized release implementation.
- Frozen by: nobody in this planning-only turn.

Supersedes the unfrozen wording of 02-criteria.md while preserving AC-001 through AC-011 identities. After freeze, amendments require a recorded new validation round. Planning acceptance checks that the plan covers the gates below; it does not claim execution gates passed. Preupload implementation review assesses only prepublication portions; hosted portions remain scheduled until publication.

## Criteria

| ID | Criterion | How it is checked | Negative case |
|---|---|---|---|
| AC-001 | Before freeze, comparisons shall have pinned sources and a disposition for every capability and risk. | Read 08, 14, 15 and 21; completed research is reused. | Unsupported parity or an undecided local contract blocks freeze. |
| AC-002 | Before freeze, the plan shall select webmcp_flutter 0.1.0 ordinary release, exact SDK verification scope, truthful URL policy and preserved MIT; immediately before upload, authorized account, name/version availability and redistribution authority shall be verified. | Read 21 and 23 now; retain dated launch-gate evidence later without private account data. | Occupied name, reused version or uncertain authority stops upload; fabricated URLs fail metadata review. |
| AC-003 | Prepared metadata shall use the accepted name/barrel, 0.1.0 release notes, Dart minimum 3.13.0 and Flutter minimum 3.47.0, web-only support and publish-disabled example. | Inspect manifests, public import, changelog and exact-SDK documentation. | Stale active imports, mismatched versions or untested-matrix claims fail. |
| AC-004 | README shall contain hosted installation and a public-import example that compiles from the payload, and disclose no browser publication/invocation. | Inspect README and compile its sample in the clean consumer. | Internal-import sample, obsolete scaffold instructions or bridge claims fail. |
| AC-005 | Consumer/product documentation shall accurately describe every retained semantic limit in 21 without behavioral expansion. | Compare source, docs and focused contract tests, including throwing custom notifications and reset behavior. | Deep-copy, atomic registration, metadata reconciliation or external-reset-cleanup promises fail. |
| AC-006 | In real Chrome, actual transport detection shall distinguish controlled marker-absent and marker-present states with cleanup and no public-barrel addition. | Retain two runtime assertions, fixture restoration and detection-only log evidence. | Missing marker reported present, skipped absent case, substituted fake transport or source-string-only proof fails. |
| AC-007 | Complete final source shall pass the canonical six-stage suite and explicit browser test on Flutter 3.47.0/Dart 3.13.0. | Paste exact versions, commands, complete outputs and exits; this one combination is both minimum and selected current verification target. | Any nonzero, skipped stage, cache failure or broader tested-matrix claim blocks readiness. |
| AC-008 | Final payload dry-run shall satisfy 23's exact warning policy with zero errors; reviewed full path/size/hash inventory shall include runtime, metadata and runnable example only. | Compare actual dry-run lists against source-to-payload hashes, .pubignore and generated/secret exclusions. | Extra wiki/tool/test material, leaked credentials, missing asset or any unaccepted diagnostic blocks release. |
| AC-009 | Before upload, a fresh external consumer shall compile README usage and build web from only the verified payload; after upload, a separate hosted consumer shall resolve/build the exact published version. | Capture dependency provenance, hashes, commands and output separately for each phase; test shipped example from payload. | Removing the barrel in a fresh disposable payload copy must fail; repository fallback or stale consumer caches fail evidence. |
| AC-010 | After technical preupload gates and blind review pass, upload shall require explicit approval of the exact payload/version/account; after upload, hosted version and presentation shall be checked. | Inspect phase-ordered evidence and approval, then hosted consumer/page/docs/example/changelog/web-badge results. | Missing approval, changed included bytes, unresolved preupload failure or occupied name prevents upload; hosted failures trigger recovery. |

## Non-functional criteria

| ID | Criterion | How it is checked | Negative case |
|---|---|---|---|
| AC-011 | All phases shall preserve unrelated edits, Git index, MIT and wiki history, avoid credentials/personal fixture data, and retain immutable-release recovery instructions. | Review scoped diffs, payload, evidence, wiki lint and finding dispositions. | Unauthorized Git mutation, deleted history, private payload or overwrite-based recovery fails. |

## Explicitly not required

No feature parity, browser bridge, native API availability, public support-status interface, broader SDK matrix, public repository URL, verified publisher, Git commit, push or publication is required to finish planning. Hosted checks are required only after separately authorized publication.

## Verdict log

| Round | Date | Verdict | Report |
|---|---|---|---|
