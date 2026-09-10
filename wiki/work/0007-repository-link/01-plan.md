# Plan: Publish repository metadata link

## Goal

The pub.dev page for webmcp_flutter 0.1.1 displays a repository link to https://github.com/ortal83cohen/flutter_webmcp, and its published archive changes only release metadata and the changelog relative to the approved 0.1.0 payload.

## Approach

Use the full pipeline for the two-file release. Add the user-supplied repository URL and advance the package version to 0.1.1 in pubspec.yaml. Add an English changelog entry describing the repository metadata addition. Keep all other package bytes, SDK constraints and dependencies unchanged.

Prepare an isolated publication directory from the prior approved 22-path inventory and the existing excluded .pubignore control file. Record the new inventory with sizes and hashes, prove that only the two authorized files changed, and retain the filter through builds. Recompare the publisher's actual final file listing after all build steps and again before confirming the ordinary interactive upload.

## Why this approach

As established in 00-research.md, the repository field directly expresses the requested source link. Homepage is less specific, a README-only change does not populate repository metadata, and replacing published 0.1.0 is excluded by immutable version rules. A metadata-only patch preserves the runtime already verified during the first release.

## Steps

1. Record the current source, Git index and prior payload baseline in a new work-item evidence artifact. Verify the supplied repository is public and that version 0.1.1 remains available. Complete blind research and plan reviews, resolve findings in STATE.yaml and freeze the criteria before source edits.
2. Update only pubspec.yaml and CHANGELOG.md in the package source. Assert the exact repository URL, package name, new version and unchanged remaining manifest fields; compare the other approved file hashes with 0.1.0. Record rejected synthetic metadata and payload mutations as negative checks.
3. Run the canonical full check suite and wiki lint with raw command output retained. Prepare the isolated payload, build a fresh external consumer from it and build its shipped example. Record dependency provenance and output artifacts. Reuse the prior runtime and browser evidence only after the corresponding source bytes are proven identical.
4. Run ordinary publication dry-run validation and require zero package warnings and errors. Compare its final selected paths, sizes and hashes with the new 22-file inventory, including after generated build files exist. Obtain independent prepublication implementation review of the frozen criteria and diff; public-only criteria remain explicitly pending at that point.
5. Recheck version availability and destination reachability, verify the existing authenticated publication context without exposing personal data, and run the ordinary interactive publisher under the user's existing request. Inspect its actual file listing and validation output before confirmation. Capture the upload result; do not bypass validation or warnings.
6. Fetch the exact hosted 0.1.1 metadata and archive, verify the registry archive hash and every included path and byte, and build a new exact-version hosted consumer using an empty isolated cache. Confirm its dependency provenance and inspect the rendered pub.dev repository anchor against the exact supplied URL. Record positive and synthetic negative checks.
7. Obtain a fresh independent final implementation verdict, record all finding dispositions, and append publication evidence and the documentation outcome. Close this work item only after all its criteria pass. Preserve the separate pending presentation checks and state of work item 0005.

## Interfaces and shared decisions

The package remains webmcp_flutter. The release is 0.1.1. Repository metadata is exactly https://github.com/ortal83cohen/flutter_webmcp. The source edit boundary is pubspec.yaml and CHANGELOG.md; work-item evidence is additional repository-only documentation. The release inventory remains exactly the 22 paths recorded for 0.1.0. The .pubignore control file remains excluded from publication. No source tests are added for this metadata change; focused assertions exercise the manifest, selection, archive and presentation gates.

## Risks

| Risk | Likelihood | Impact | Mitigation | Trigger that means it happened |
|---|---|---|---|---|
| Generated files enter the upload | Observed in prior release | Unreviewed payload published | Keep .pubignore in isolation and compare actual final CLI selection | Any unexpected or missing path |
| A concurrent edit changes release bytes | Possible | Payload exceeds scope | Recheck source and payload hashes before confirmation | Any unauthorized hash difference |
| Version becomes unavailable | Possible | Upload conflict | Fresh exact-version check before upload | Existing 0.1.1 or non-authoritative network result |
| Hosted repository link is delayed or absent | Possible | Requested outcome remains incomplete | Inspect actual anchor and retain unresolved status until observed | Missing or incorrect repository href |
| Authentication or package validation fails | Possible | Release cannot proceed | Retain errors and resolve within the existing authorized scope | Nonzero result, new warning or account challenge |

## Rollback

Before upload, abandon the isolated candidate and restore only this item's two source edits if needed, preserving unrelated changes and the Git index. Do not delete wiki evidence. After publication, 0.1.1 is immutable; preserve the public record and diagnose any defect before proposing a corrective release. Do not retract or publish an additional version automatically. A failed hosted check leaves this item open rather than implying the upload was reversed.

## Out of scope

Runtime behavior, transport capabilities, tests of new behavior, dependency or SDK changes, README or example edits, repository commits or pushes, and changes to the prior release's pending API documentation or platform badge gates are outside this item. No additional publishing approval is inferred as necessary when the requested patch upload is already authorized.

## Verification approach

Run the canonical suite through bash tools/check.sh and retain its complete output with exit status. Use focused positive and deliberately corrupted negative inputs for every frozen criterion, without altering production files for negative cases. Require exact baseline and final manifest comparisons, final CLI selection comparisons after builds, fresh isolated consumer builds before and after upload, hosted archive hash equality, and an actual rendered repository anchor. Wiki lint and independent validation must pass before closing; a pending server check stays pending.
