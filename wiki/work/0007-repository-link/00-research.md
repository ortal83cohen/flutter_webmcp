# Research: Publish repository metadata link

## Question

How can the requested GitHub repository link be displayed on the existing webmcp_flutter pub.dev package with the smallest release change?

## Answer

Publish version 0.1.1 with the supplied repository URL in pubspec.yaml and a metadata-only changelog entry. Dart documents that pub.dev displays the repository field and that a published version cannot be modified; the repository field is therefore the direct mechanism and a new version is necessary. [Source: https://dart.dev/tools/pub/pubspec#repository and https://dart.dev/tools/pub/pubspec#version, accessed 2026-09-10.]

## Findings

### Metadata is the relevant interface

- Claim: The repository field represents the source repository and is displayed on pub.dev; homepage is a separate optional field.
- Evidence: The official Repository and Homepage sections define those fields and their displayed links.
- Source: https://dart.dev/tools/pub/pubspec#repository and https://dart.dev/tools/pub/pubspec#homepage, accessed 2026-09-10.

### A patch release preserves the published version

- Claim: The source manifest currently declares 0.1.0 without a repository field. Published 0.1.0 has an approved 22-file archive; only pubspec.yaml and CHANGELOG.md need release changes under the requested scope.
- Evidence: Source pubspec.yaml and CHANGELOG.md read on 2026-09-10; prior archive inventory and hosted verification contain exact file hashes and command output. The choice to change two files is this work item's scope decision, not a runtime requirement.
- Source: pubspec.yaml; CHANGELOG.md; wiki/work/0005-pubdev-release-readiness/27-payload-inventory.json; wiki/work/0005-pubdev-release-readiness/35-hosted-publication-evidence.md.

### The prior release establishes concrete publication controls

- Claim: The pinned publisher rejected an interactive warning-bypass flag; ordinary interactive publication succeeded. Generated example build files previously entered a candidate listing until the existing .pubignore was retained in the isolated payload.
- Evidence: Prior control artifact includes the rejection output, corrected invocation, and a final exact 22-path comparison. The successful hosted release output is separately retained.
- Source: wiki/work/0005-pubdev-release-readiness/34-final-publication-controls.md; wiki/work/0005-pubdev-release-readiness/35-hosted-publication-evidence.md; .pubignore.

### Existing pending presentation checks are separate

- Claim: Work item 0005 remains open for its recorded API documentation and web badge checks. Its STATE does not establish their present public status.
- Evidence: STATE.yaml records a verification failure limited to those external presentation checks; the outcome preserves that boundary.
- Source: wiki/work/0005-pubdev-release-readiness/STATE.yaml; wiki/work/0005-pubdev-release-readiness/36-publication-outcome.md.

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Repository field in 0.1.1 | Publish the supplied source URL using its designated metadata field | One patch release and changelog entry | Chosen; directly represents the requested repository link |
| Homepage field in 0.1.1 | Publish the repository URL as a homepage | Similar release cost | Rejected; less specific when the requested URL is the source repository |
| Modify published 0.1.0 | Attempt to replace existing version metadata | Unsupported by documented immutable version rules | Rejected; a new version is required |
| README-only link | Edit package prose | Still requires a release | Rejected; does not populate the repository metadata field |

## Constraints discovered

The full pipeline applies because the release changes two source files. The repository requires canonical checks and blind validation, while the user-authorized scope permits the patch publication. Source runtime, dependencies, SDK constraints, README and example remain unchanged. These are scope decisions governed by AGENTS.md, wiki/conventions/workflow.md and this item's STATE.yaml.

The existing selected publishing account and prior successful authentication are recorded without personal identity in work item 0005's publication controls. Recheck version availability and the public destination immediately before publication; do not interpret prior observations as a permanent availability guarantee.

## Unresolved

No unresolved design question. The availability of 0.1.1, current destination reachability, zero-warning dry run, payload identity, upload success, hosted archive identity, fresh consumer build and actual rendered repository link are execution gates; none is claimed complete by this research artifact.

## Sources

All listed source and wiki files were read on 2026-09-10. Official references consulted on that date: https://dart.dev/tools/pub/pubspec and https://dart.dev/tools/pub/publishing. The parent agent's fresh GitHub and pub.dev observations must be retained as execution evidence rather than silently replacing the earlier publication record.

## Current destination checkpoint

The now-retained live observation in 04-initial-observations.md reports GitHub HTTP 200 for the supplied public repository and its root manifest declaring webmcp_flutter. Pub.dev reports latest 0.1.0 with no repository metadata and HTTP 404 for exact 0.1.1. These are initial observations on 2026-09-10, not a reservation or a substitute for the final publication availability check. Source: 04-initial-observations.md, including the full probe command and output.
