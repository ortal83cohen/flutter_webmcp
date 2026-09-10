# Research: Automated pub.dev Publishing via GitHub Actions

## Question

How must a GitHub Actions workflow publish a Dart/Flutter package to pub.dev in 2026, including authentication, required permissions, and the official publish command, so that a push to main can upload a new version without storing a long-lived pub.dev password in git.

## Answer

A GitHub Actions workflow can publish to pub.dev using OpenID Connect (OIDC) trusted publishing without storing long-lived credentials. The workflow must be triggered by tag pushes (not branch pushes), require `id-token: write` permissions, and use the official `dart-lang/setup-dart` reusable workflow or configure OIDC manually. The package must first be published manually using `dart pub publish`, then automated publishing must be enabled in the pub.dev admin panel for the specific repository and tag pattern.

## Findings

### OIDC Trusted Publishing (Recommended Method)

- Claim: OIDC authentication eliminates the need for long-lived secrets by using temporary GitHub-signed tokens
- Evidence: "When configuring automated publishing you don't need to create a long-lived secret that is copied into your automated deployment environment. Instead, authentication relies on temporary OpenID-Connect tokens signed by either GitHub Actions"
- Source: https://dart.dev/tools/pub/automated-publishing

### Required GitHub Permissions

- Claim: Workflows must explicitly grant `id-token: write` permission to request OIDC tokens
- Evidence: "The job or workflow must grant the `id-token: write` permission to allow GitHub's OIDC provider to create a JSON Web Token (JWT)"
- Source: https://docs.github.com/en/actions/reference/security/oidc

- Claim: If using actions/checkout, `contents: read` permission is also required
- Evidence: "permissions: id-token: write # This is required for requesting the JWT contents: read # This is required for actions/checkout"
- Source: https://docs.github.com/en/actions/reference/security/oidc

### Tag-Based Trigger Requirement

- Claim: Automated publishing only works when triggered by tag pushes, not branch pushes
- Evidence: "Pub.dev only allows automated publishing from GitHub Actions when the workflow is triggered by pushing a git tag to GitHub. Pub.dev rejects publishing from GitHub Actions triggered without a tag"
- Source: https://dart.dev/tools/pub/automated-publishing

### Pub.dev Configuration Prerequisite

- Claim: Publishers must enable automated publishing on pub.dev before first automated upload
- Evidence: "To enable automated publication from GitHub Actions to `pub.dev`, you must be: An uploader on the package, or, An admin of the publisher... Click Enable publishing from GitHub Actions, this prompts you to specify: A repository, A tag-pattern"
- Source: https://dart.dev/tools/pub/automated-publishing

### Flutter Package Support

- Claim: The official reusable workflow supports both Dart and Flutter packages by installing both SDKs
- Evidence: "Download flutter SDK - needed for publishing Flutter packages. Can also publish pure Dart packages. The dart binary from a Flutter SDK facilitates publishing both Flutter and pure-dart packages"
- Source: https://github.com/dart-lang/setup-dart/blob/main/.github/workflows/publish.yml

### Force Flag Requirement

- Claim: `--force` flag is required in CI to skip interactive confirmation prompts
- Evidence: "With this, pub does not ask for confirmation before publishing. Normally, it shows you the package contents and asks for you to confirm the upload"
- Source: https://dart.dev/tools/pub/cmd/pub-lish

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| OIDC Trusted Publishing (dart-lang/setup-dart) | Uses official reusable workflow with automatic OIDC token provisioning | Free | **CHOSEN** - Official, maintained, secure, handles both Dart and Flutter packages |
| OIDC Custom Workflow | Manual OIDC token creation using dart-lang/setup-dart action | Free | Rejected - More complex, requires manual token management, less maintainable |
| PUB_CREDENTIALS Secret | Traditional approach with long-lived JSON credentials | Security risk | Rejected - Security risk, requires credential rotation, deprecated approach |
| Service Account (Google Cloud) | Uses GCP service account with OIDC or exported keys | GCP costs | Rejected - Unnecessary complexity for GitHub Actions, requires GCP setup |

## Constraints discovered

- **Bootstrap Limitation**: [UNVERIFIED: New packages must be published manually first] - "Today, you can only automate publishing of existing packages. To create a new package, you must publish the first version using `dart pub publish`"
- **Rate Limits**: Pub.dev enforces rate limits of 4 packages per few minutes (burst limit) and 12 packages per 24 hours (daily limit)
- **Tag Pattern Matching**: The GitHub workflow trigger pattern must exactly match the tag pattern configured on pub.dev admin panel
- **Version Immutability**: Cannot republish the same version number - "a published package lasts forever"
- **Retraction Window**: Package versions can only be retracted within 7 days of publication
- **Repository Access**: Only works with public GitHub repositories or those accessible to pub.dev's OIDC configuration

## Unresolved

- [UNRESOLVED: Whether GitHub Enterprise or private repositories are supported for OIDC publishing]
- [UNRESOLVED: Specific timeout values for OIDC token expiration in publishing workflows]
- [UNRESOLVED: Whether tag protection rules interfere with automated publishing triggers]
- [UNRESOLVED: Exact behavior when multiple packages in monorepo have conflicting tag patterns]

## Sources

- https://dart.dev/tools/pub/automated-publishing - consulted 2026-09-10
- https://dart.dev/tools/pub/publishing - consulted 2026-09-10  
- https://dart.dev/tools/pub/cmd/pub-lish - consulted 2026-09-10
- https://github.com/dart-lang/setup-dart/blob/main/.github/workflows/publish.yml - consulted 2026-09-10
- https://docs.github.com/en/actions/reference/security/oidc - consulted 2026-09-10
- https://github.com/dart-lang/pub-dev/issues/7595 - consulted 2026-09-10
- https://github.com/dart-lang/pub-dev/issues/7465 - consulted 2026-09-10
- https://github.com/dart-lang/setup-dart/issues/68 - consulted 2026-09-10