# Acceptance criteria: pub.dev release readiness

## Frozen

- Frozen at: not yet
- Frozen by: nobody; planning-only request

These are future implementation and release gates. Producing this plan does not satisfy them.

## Criteria

| ID | Criterion | How it is checked | Negative case |
|---|---|---|---|
| AC-001 | Before implementation freeze, the required comparison shall identify source revisions and classify each compared capability as supported, deferred or missing, with evidence and a disposition for every gap. | Inspect comparison, sources and recorded decisions; confirm scope-changing findings receive new planning validation. | An uncited parity claim or unresolved scope-changing gap blocks freeze. |
| AC-002 | Before freeze, release decisions shall establish publishing rights to the occupied flutter_webmcp name (07-name-check.md), choose an unused version/channel after existing release compatibility review, verified public URLs, account authority and redistribution rights while preserving the authorized MIT holder. | Inspect dated lookups and recorded decisions; distinguish pub mandates from project gates. | Unknown uploader rights, reused versions or placeholder URLs block name-dependent implementation and publication; no fallback is chosen without the user. |
| AC-003 | When metadata is prepared, the manifest shall use flutter_webmcp, the public barrel shall be lib/flutter_webmcp.dart, active imports and package-name literals shall match, and the changelog shall agree on the selected unused version, describe detection-only scope and express compatibility consistently; the example shall remain publish-disabled. | Inspect manifest, changelog, README compatibility statement and example metadata. | Stale webmcp_pilot imports/name literals outside preserved historical artifacts, version mismatch or unsupported compatibility claims fail review. |
| AC-004 | When consumers read the README, it shall provide hosted installation and a compiled public-import example, exclude obsolete scaffold claims and explicitly disclose no browser publication or invocation. | Compile the example and inspect all README sections. | An example requiring internal imports or a claim of browser tool publication fails. |
| AC-005 | When documenting existing behavior, README and product contract shall cover singleton lifetime, duplicates and scoped ownership, disabled-child invocation, mounted descriptor identity, shallow schema copying, partial source registration and reset limitations without adding public features. | Compare documentation with source and focused positive/negative tests of the stated behavior. | A promise of deep copying, batch atomicity or external reset cleanup fails. |
| AC-006 | When executed in a real browser, the existing detection path shall produce distinguishable evidence for capability present and absent, consistent with documented logging and without publishing tools. | Retain browser runtime test output for both states and cleanup between them. | Missing capability must not be reported as present; source-string checks alone fail this gate. |
| AC-007 | On the final candidate, the canonical full suite shall exit zero, and compatibility checks shall pass on the declared minimum and chosen current supported SDK combinations. | Retain exact SDK versions, commands, full output and exit statuses, including root/example tests and web build. | Cache errors, skipped stages or unsupported claimed versions block release. |
| AC-008 | For the release payload, pub dry-run shall complete successfully and its actual manifest and sizes shall retain required assets, exclude unwanted repository/generated material and have every warning resolved or explicitly justified. | Compare dry-run listing to .pubignore and preserved .gitignore exclusions; inspect required files and current pub limits. | Missing LICENSE/library, leaked secret or unreviewed warning blocks release. |
| AC-009 | A clean external consumer shall compile the README example and build web using only the verified payload before publication; hosted installation shall be checked after authorized publication. | Record external project setup, payload identity, dependency provenance, commands and output. | Removing a required library in a disposable payload copy must make the consumer fail; repository-relative fallback is rejected. |
| AC-010 | Before publication, the exact candidate/version/account shall have a recorded explicit publication decision after all prepublication gates and blind implementation review pass. | Inspect release evidence and approval sequence; after release inspect hosted package/version and smoke result. | A changed candidate, unresolved failure or absent publication authorization prevents upload. |

## Non-functional criteria

| ID | Criterion | How it is checked | Negative case |
|---|---|---|---|
| AC-011 | Release preparation shall preserve unrelated changes, contain no credentials or personal fixture data, retain wiki history and document immutable-release recovery. | Inspect scoped diff, payload and recovery record; verify documentation/index lint and review dispositions. | Unrelated edits, deleted wiki history, sensitive payload or overwrite-based recovery fail review. |

## Explicitly not required

A browser bridge, feature parity, behavioral public-interface expansion beyond the requested package/import rename, deep copying, atomic batch registration, platform expansion, automated publishing, multiple publisher members and topics are not requirements. Actual publication is not authorized by this planning request. Hosted checks occur only after a later authorized upload.

## Verdict log

| Round | Date | Verdict | Report |
|---|---|---|---|

## Superseded by consolidated release planning

On 2026-09-10, [19-criteria-consolidated.md](19-criteria-consolidated.md) superseded the instructions above after the accepted rename and completed capability comparison. This artifact is retained as historical evidence. STATE.yaml identifies the operative artifacts.
