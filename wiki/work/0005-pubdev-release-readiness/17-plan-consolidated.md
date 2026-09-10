# Plan: webmcp_flutter first pub.dev release

## Goal

Deliver an executable plan for publishing the already renamed webmcp_flutter as ordinary version 0.1.0, with accurate consumer documentation and reproducible release evidence. This artifact supersedes the implementation instructions in 01-plan.md and 16-release-preflight.md; their evidence remains historical. The companion criteria, tasks and decisions are 19-criteria-consolidated.md, 20-tasks-consolidated.md and 21-release-decisions.md. This turn completes planning only, without source changes or upload authorization.

## Approach

Prepare the existing detection-first local registry, preserving MIT and the public barrel lib/webmcp_flutter.dart. Work item 0006 completed the rename; 08-capability-comparison.md resolves the source comparisons in 14 and 15. Neither needs repeating. Pin the release verification environment to Flutter 3.47.0 with Dart 3.13.0, add that Flutter minimum to pubspec.yaml, retain the Dart lower bound and web-only declaration, and make no wider tested-matrix claim.

Separate the complete source candidate used for repository checks from the filtered consumer payload used for publishing. Identify both by sorted full relative paths, byte sizes and SHA-256 content hashes. Run the full suite on the original complete source with its existing Git context, recording a content snapshot. Then copy that reviewed content into a disposable packaging source directory without Git metadata to avoid Git-status warnings without changing the user's index or requiring a commit. Do not run repository-hygiene tests on that Git-free copy or a stripped payload.

## Why this approach

The comparisons support useful local registry and Flutter lifecycle behavior without a browser bridge. Adding parity now would create a separate interface project. Ordinary 0.1.0 follows the search-visibility rationale documented in 16; a prerelease is not selected. Optional source URLs remain absent because the verified public remote is empty. Inventing a URL or publishing unrelated source to fill metadata is inappropriate. Warning handling follows the verified command behavior in 23-warning-policy-evidence.md, not an assumed zero-warning exit policy.

## Steps

1. After implementation authorization and blind plan validation, freeze the consolidated criteria in STATE.yaml. Preserve old artifacts. Capture the existing dirty-tree baseline and completed rename as inputs; retain all unrelated changes. Record release ownership and MIT continuity, with account selection reserved for the launch gate.
2. Update pubspec.yaml with the selected Flutter minimum and consistent 0.1.0 metadata, and CHANGELOG.md with the eventual release date and actual capabilities. Leave optional project URLs absent. Add .pubignore with the consumer boundary in 21, repeating relevant environment, key, local and generated exclusions because it overrides .gitignore. Do not suppress secret detection with false-secrets metadata.
3. Rewrite README.md for hosted installation, the renamed public import, a runnable minimal example and web-only compatibility. Update wiki/product/webmcp-contract.md and wiki/product/README.md alongside it. Document every current semantic limit in 21 and compile the README sample through the payload consumer. Extend focused existing contract tests only where evidence is missing.
4. Add a read-only detection observation on the internal WebDetectionTransport class, absent from the public barrel. Add a browser-only test at test/transport_web_browser_test.dart. In a controlled real Chrome fixture, ensure document.modelContext is absent, instantiate the actual transport and assert false; install a property marker, instantiate again and assert true. Preserve and restore the original property descriptor in cleanup. Use a browser with the experimental feature disabled so the absent case is controllable; an uncontrollable fixture is a failure, never a skipped pass. This observes property presence, not native API functionality. No publishing bridge or fake transport is introduced. Capture both branch results and the detection-only log contract; test registration/removal without browser publication.
5. Capture exact Flutter and Dart version output and run the canonical full check script on the complete final source candidate. Run the new Chrome test explicitly in addition to ordinary VM tests, using its browser-only declaration to keep VM discovery valid. The declared minimum and selected current verification SDK are the same pinned combination. Retain full commands, outputs and exits for all six suite stages and browser cases; repair environment failures and rerun affected checks.
6. Create the disposable packaging source copy without Git metadata, verify its release-relevant bytes against the complete-source snapshot, and run the pinned SDK's publish dry-run there and retain its entire intended file list, sizes, compressed total, diagnostics and exit. Resolve all errors and every warning except the precisely accepted optional-URL diagnostic in 23. Never bypass validation. Using that actual listing, reproduce a disposable payload with identical bytes; compare every full relative path, size and SHA-256, not just basenames or tracked files. Reject ambiguity, symlinks escaping the candidate, missing files and unexpected files. Rerun dry-run from this payload and require the same reviewed inclusion inventory and warning policy. Record that this reproduces the selected files, not a CLI-exported archive.
7. Create a clean external Flutter web consumer outside both trees, depending only on the absolute payload directory. Compile the README sample, resolve hosted third-party dependencies, verify package resolution points to the payload and build web. Exercise the shipped example using its payload-contained parent dependency. Reject references back to the source checkout and stale caches. In a fresh disposable payload copy remove the public barrel and prove consumer resolution or compilation fails. Never mutate the approved payload for a negative probe.
8. Complete blind implementation review against prepublication criteria, retaining every finding and main-agent disposition. Record source and payload hashes after checks; any changed included byte invalidates payload and consumer evidence. Documentation-only evidence additions outside the payload do not change its identity. Present a reproducible candidate with no unresolved prepublication technical failures for the launch decision.
9. Immediately before upload, recheck the package name and unused version, verify the selected authorized account privately, review license/redistribution authority and obtain explicit approval for the exact package, version, payload and account. A newly occupied name or uncertain authority stops upload, not planning. Keep personal account details and credentials out of wiki evidence.
10. Only following that approval, publish interactively from the same hash-verified payload directory used for final dry-run and consumer checks, with ordinary validation enabled. After upload, verify the exact hosted version, clean hosted consumer build, package page, API documentation, Example and Changelog presentation and web badge. Record actual outcomes without treating these future checks as prerequisites to uploading their own artifact.

## Interfaces and shared decisions

The rename is complete, not a new task. No behavioral public interface or data model changes are planned. The internal read-only observation only exposes the existing detection result to internal tests. Existing raw local results/errors, shallow schemas, partial registration, mounted identity, disabled-child behavior and custom transport mutation/reset limits remain unchanged. Decisions in 21 exhaust the comparison gap classes.

## Risks

| Risk | Likelihood | Impact | Mitigation | Trigger |
|---|---|---|---|---|
| Documentation implies browser interoperability | Known risk | Misleading release | Explicit local-only contract and property fixture | Bridge or wire-safety claim appears |
| Filtered payload omits assets or leaks history | Observed preflight issue | Broken or unsafe release | Full path/hash audit and external positive/negative consumer | Missing library, extra wiki or sensitive file |
| Environment or SDK compatibility fails | Previously observed | Release blocked | Exact pinned suite and real browser runs | Nonzero or skipped stage |
| Name/account changes by upload | Future-dependent | Upload blocked | Immediate live launch checks | Existing package, reused version or unknown authority |
| Working tree changes after checks | Possible | Evidence invalid | Stable source/payload inventories | Included byte or path differs |

## Rollback

Before upload, revert only release-owned changes with a scoped diff and preserve unrelated work and every wiki artifact. After upload, stop promotion on failure, document the affected version and prepare a corrected higher version with fresh gates and approval. Consider retraction only under then-current pub rules and explicit production authorization; retraction is not deletion or replacement of published bytes.

## Out of scope

Browser bridge/parity, native interoperability, DOM discovery, dynamic reconciliation, transactional registration, deep copying, richer support status, publisher-team setup, repository publication, CI publishing automation, Git staging/commit/push and upload in this planning turn are excluded.

## Verification approach

Planning closes when the consolidated artifacts exist, wiki lint and explicit plan-fence checks pass with pasted output, blind research/plan reviews have dispositions, and STATE.yaml identifies planning completion. Future implementation gates AC-003 through AC-009 and release gates AC-010 through AC-011 retain their own evidence status. AC-009 and AC-010 postpublication checks are deferred by phase, not failed preupload requirements. No current release-readiness claim follows from planning completion.
