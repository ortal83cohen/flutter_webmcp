# Plan: pub.dev release readiness

## Goal

Prepare a verifiable release candidate of the root package under the requested flutter_webmcp name that consumers can install with accurate expectations. This request delivers planning artifacts only; implementation and publication remain future actions requiring their own authorization.

## Approach

Provisionally prepare a detection-first prerelease with a deliberate package/import rename from webmcp_pilot to flutter_webmcp and no behavioral feature expansion. Preserve the already authorized MIT holder. The requested name is occupied by the package whose latest release is 0.3.0; see 07-name-check.md. Publishing is blocked until existing uploader rights are established, or the user chooses another name. A source rename grants no upload authority; do not select an alternative automatically. Resolve the exact version, public URLs and publisher identity before implementation criteria freeze. The example remains a non-published demonstration.

Treat valid package metadata, license, redistribution rights, dependency restrictions and archive limits as pub requirements, verified against current official rules and pub validation. Treat the capability comparison, consumer documentation, fresh suite, browser detection evidence and external consumer check as this project's release gates. Topics, publisher-team setup and release automation are recommendations, not mandatory pub fields.

## Why this approach

The research in 00-research.md supports a narrow existing-scope release after evidence gaps close. Immediate publication would carry obsolete documentation and unresolved checks. A stable release remains an owner choice after contract review; a prerelease makes the provisional contract clearer without excusing failed gates. Implementing a browser bridge first would introduce a separate interface project and is unnecessary for truthful detection-first publication.

## Steps

1. Complete the prior work item's capability comparison against KickNext/flutter_webmcp v0.3.0 and a recorded revision of intentcall_webmcp. Write a source-linked behavior-by-behavior matrix classifying supported, deferred and missing capabilities. Resolve accidental omissions; send scope changes back through research, plan and validation before criteria freeze.
2. Resolve uploader rights to the occupied flutter_webmcp namespace, review its existing release history and compatibility obligations, select an unused version and release channel, canonical repository and issue destinations, account authority and redistribution rights. Record decisions in the work item; retain the authorized MIT holder. Unresolved decisions block freezing the implementation criteria.
3. After implementation authorization and blind validation, freeze 02-criteria.md, rename the public barrel from lib/webmcp_pilot.dart to lib/flutter_webmcp.dart, update all package imports and name literals in source, example, tests, hygiene checks and active consumer documentation, and prepare pubspec.yaml, CHANGELOG.md and .pubignore. Preserve historical wiki records. Align the version and release notes, verify public URLs, define the supported SDK bounds and preserve generated-file exclusions because .pubignore overrides .gitignore. Review visible wiki, tools and agent-instruction files deliberately; do not assume normally excluded hidden directories enter the archive. Keep required package and consumer example assets.
4. Rewrite README.md around hosted installation, a compiled example, lifecycle usage and explicit detection-only behavior. Document singleton lifetime, duplicates, scoped ownership, disabled-child invocation, mounted descriptor identity, shallow schema copying, partial source registration and reset limitations. Update the product contract without expanding behavior.
5. Add focused checks for the documented example and observable browser detection with the capability present and absent. Exercise the existing web transport in a real browser; a source-string assertion or web build is insufficient. Keep any test-only seam internal and do not add a public capability API. Failure requiring an interface change returns to planning.
6. Resolve the SDK cache environment failure and capture the full check script's output on the final candidate. Test the declared minimum and the selected current supported Flutter/Dart combination, recording exact versions; narrow unsupported claims rather than treating historical results as current evidence. Capture root and example tests, analysis, format, wiki lint and web build evidence.
7. Run pub's publish dry-run on the exact candidate and retain its actual file listing, sizes, warnings and exit status. Inspect the corresponding publish payload, not a tracked-file approximation. Build a clean external Flutter consumer using only that payload through a temporary local dependency, without the repository's parent path or caches masking missing assets. Compile the README usage and build web; deliberately remove a required library in a disposable payload copy and confirm the consumer fails.
8. Complete blind implementation validation and record all finding dispositions. Refresh documentation and prepare a release evidence record identifying the exact candidate and matching manifest version. Present it for an explicit publication decision naming version and account. Only a separately authorized publication may follow; after upload, verify hosted installation from pub.dev and the public package page.

## Interfaces and shared decisions

The package and barrel rename is an intentional import-interface change requiring complete import, consumer and suite verification. No new behavioral public interfaces, transport protocol or data model are planned. The public scope is an in-process registry with detection and logging, not browser tool publication or invocation. Browser detection evidence must demonstrate both capability states without implying external integration. Packaging decisions apply to the root package; the example retains publish-disabled metadata. Release checks apply to one identified candidate; any subsequent edit invalidates affected evidence.

## Risks

| Risk | Likelihood | Impact | Mitigation | Trigger that means it happened |
|---|---|---|---|---|
| Capability comparison changes the intended contract | Unknown | Plan invalidation | Complete it before freeze and revalidate scope changes | A missing behavior is selected for implementation |
| SDK environment prevents validation | Observed | Release blocked | Use a writable SDK environment and rerun the canonical suite | Cache error or incomplete suite |
| Archive exclusions remove needed files or retain private material | Unknown | Broken or inappropriate release | Inspect pub's actual payload and test an isolated consumer | Missing import, generated file or sensitive content found |
| Documentation overstates browser support | Observed coverage gap | Consumers rely on unsupported behavior | Require runtime detection evidence and explicit bridge exclusion | Browser result differs from documentation |
| Published version contains a defect | Unknown | Immutable public artifact | Review exact candidate and require final publication decision | Hosted smoke check or consumer report fails |

## Rollback

Before publication, supersede planning artifacts rather than deleting them and revert only release-owned implementation changes, preserving unrelated work. After publication, the version cannot be overwritten or treated as deleted: stop further rollout, assess retraction under current pub rules, communicate the affected version and publish a corrected new version after checks and authorization. Retraction is not erasure; existing users may retain the release.

## Out of scope

Browser bridge implementation, automatic DOM discovery, transactional registration, deep schema immutability, new public detection interfaces beyond the requested package/import rename, platform expansion, automated publishing, Git commits or pushes, and publication during this planning request are excluded.

## Verification approach

Check every criterion independently with retained commands, output and exit codes. Use the canonical full suite, browser runtime cases, version-specific compatibility runs, pub dry-run and a clean payload consumer. Include negative checks for missing capabilities, invalid release metadata, excluded required files and unauthorized publication. Failed or partial SDK and pub probes remain unresolved evidence, never passes. The current planning deliverable needs wiki lint and blind research/plan review; future implementation and release criteria are not claimed satisfied now.

## Superseded by consolidated release planning

On 2026-09-10, [17-plan-consolidated.md](17-plan-consolidated.md) superseded the instructions above after the accepted rename and completed capability comparison. This artifact is retained as historical evidence. STATE.yaml identifies the operative artifacts.
