# Research: Prevent pub.dev OIDC auth from breaking dependency resolution

## Question

Why does the tag-triggered pub.dev workflow fail during dependency installation, and what repository-side change can preserve OIDC publishing?

## Answer

The failure is consistent with the publishing workflow provisioning a temporary pub.dev token before `dart pub get`; pub.dev can reject that token during ordinary package resolution, making a public dependency appear unavailable. The safe workaround is to resolve dependencies before OIDC provisioning, then provision OIDC and publish.

## Findings

### Official workflow order

- Claim: The Dart reusable publishing workflow provisions OIDC authentication before installing dependencies.
- Evidence: Its steps set up Dart, provision the OIDC token, then run dependency installation.
- Source: https://raw.githubusercontent.com/dart-lang/setup-dart/main/.github/workflows/publish.yml

### Documented authentication model

- Claim: Dart recommends temporary GitHub OIDC tokens for automated publishing and requires `id-token: write`.
- Evidence: The official publishing guide documents the OIDC permission and reusable workflow.
- Source: https://dart.dev/tools/pub/automated-publishing

### Observed failure

- Claim: The supplied run failed during dependency resolution with an authorization error for pub.dev, before dry-run or publication.
- Evidence: Attached screenshot, and repository dependency declaration at `pubspec.yaml`.
- Source: User-provided evidence and `pubspec.yaml`

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Keep the reusable workflow unchanged | Use the official workflow order | No repository change | Rejected because that exact order produced the observed failure. |
| Add a long-lived pub.dev token | Authenticate all pub operations with a stored credential | Secret management and leak risk | Rejected because it weakens the documented OIDC model. |
| Custom workflow with dependency resolution first | Resolve anonymously, then install OIDC auth for publication | Maintains a small local workflow | Chosen because it addresses the failure boundary without a long-lived secret. |

## Constraints discovered

- Publishing must remain tag-triggered and the tag pattern must remain aligned with pub.dev configuration.
- The package is a Flutter package, so the workflow must retain Flutter tooling.
- The actual GitHub-hosted rerun cannot be proven locally.

## Unresolved

- [UNRESOLVED: Whether the current pub.dev service is experiencing a transient OIDC validation problem at the next rerun.]

## Sources

- Dart automated publishing guide, consulted 2026-09-11: https://dart.dev/tools/pub/automated-publishing
- Dart setup-dart reusable workflow, consulted 2026-09-11: https://raw.githubusercontent.com/dart-lang/setup-dart/main/.github/workflows/publish.yml
