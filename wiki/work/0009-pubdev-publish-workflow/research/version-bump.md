# Research: Version Bump Strategy for Dart Package Publishing

## Question

How should GitHub Actions on push to main bump a Dart package patch version (0.1.1 to 0.1.2), keep CHANGELOG.md and pubspec.yaml in sync, commit/tag/push without creating an infinite workflow loop, and still leave a publishable unique version for pub.dev.

## Answer

Use a tag-driven workflow with bot commit detection. The workflow creates an annotated tag (v0.1.2), updates pubspec.yaml and CHANGELOG.md with [skip ci] in the commit message, then publishes to pub.dev. Infinite loops are prevented by checking `github.actor != 'github-actions[bot]'` and using [skip ci] markers. Bot commits back to main are required for consumers who clone from git rather than pub.dev.

## Findings

### GITHUB_TOKEN Permissions and Skip CI

- Claim: GitHub Actions skip CI triggers work with commit message markers
- Evidence: Workflows triggered by `on: push` or `on: pull_request` won't run if commit message contains `[skip ci]`, `[ci skip]`, `[no ci]`, `[skip actions]`, or `[actions skip]`
- Source: https://docs.github.com/en/actions/how-tos/manage-workflow-runs/skip-workflow-runs

- Claim: github.actor detection prevents infinite loops
- Evidence: Job-level conditional `if: github.actor != 'github-actions[bot]'` prevents workflows from triggering themselves when using default GITHUB_TOKEN
- Source: https://github.com/maximhq/bifrost/pull/326, https://medium.com/ninjaneers/letting-github-actions-push-to-protected-branches-a-how-to-57096876850d

- Claim: actions permission required for concurrency cancellation
- Evidence: `permissions: actions: write` must be set to use `concurrency.cancel-in-progress: true`
- Source: https://pdsinterop.org/docs/development/github-actions/github-actions.permissions/

### Dart Version Semantics and 0.x Handling

- Claim: In Dart 0.x versions, patch number is third digit
- Evidence: Dart analyzer treats versions like `x.0.0` or `0.x.0` as breaking versions. For 0.x packages, increment from `0.1.1` to `0.1.2` is a patch bump (third number)
- Source: https://dart.dev/tools/linter-rules/remove_deprecations_in_breaking_versions

- Claim: pubspec.yaml version field accepts semver format
- Evidence: Version must be three numbers separated by dots, optionally with build suffix (`+1`) or prerelease (`-dev.4`). Format follows semantic versioning
- Source: https://dart.dev/tools/pub/pubspec, https://dart.dev/tools/pub/versioning

### Keep a Changelog Requirements

- Claim: Unreleased section must be converted to versioned section
- Evidence: Keep a Changelog format requires moving `[Unreleased]` content into `## [version] - YYYY-MM-DD` section at release time
- Source: https://keepachangelog.com/en/2.0.0/

- Claim: Automation should handle mechanics, not judgment
- Evidence: "Use it for mechanical tasks: move the Unreleased section into a dated version at release time, check that the file is formatted correctly"
- Source: https://keepachangelog.com/en/2.0.0/

### Pub.dev Publishing Options

- Claim: dry-run validates without publishing
- Evidence: `dart pub publish --dry-run` goes through validation process but does not upload the package
- Source: https://dart.dev/tools/pub/cmd/pub-lish

- Claim: force flag skips interactive prompts
- Evidence: `dart pub publish --force` does not ask for confirmation before publishing, suitable for CI
- Source: https://dart.dev/tools/pub/cmd/pub-lish

- Claim: OIDC authentication enables secure automated publishing
- Evidence: Official reusable workflow `dart-lang/setup-dart/.github/workflows/publish.yml` uses `id-token: write` permission for GitHub OIDC
- Source: https://dart.dev/tools/pub/automated-publishing

### Version Extraction from pubspec.yaml

- Claim: yq is the recommended tool for parsing YAML
- Evidence: `yq -r .version pubspec.yaml` extracts version reliably. Windows runners need `choco install yq` or use PowerShell alternatives
- Source: https://stackoverflow.com/questions/75523265/how-to-extract-app-version-from-pubspec-yaml-in-a-flutter-app-to-use-it-in-githu, https://gist.github.com/anggoran/3bbe36e18c58657f475d92e744b57f84

### Git Tagging and Version Bump Logic

- Claim: Conventional Commits can drive semver bumps
- Evidence: `feat:` triggers minor bump, `fix:` triggers patch bump, `BREAKING CHANGE:` or `!` suffix triggers major bump
- Source: https://github.com/pipescloud/ppz/blob/main/.github/workflows/auto-tag.yml, https://how2.sh/posts/how-to-automate-semantic-versioning-with-git/

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| **Bot commit back to main** | Workflow bumps version in pubspec.yaml and CHANGELOG.md, commits with [skip ci], then publishes | Higher git history noise, requires skip ci logic | **CHOSEN** - Required for git-clone consumers who don't use pub.dev |
| **Publish without committing** | Version only exists in published archive, not in git repository | Lower git noise, version drift risk | REJECTED - Git cloners get mismatched versions, breaks development workflow |
| **[skip ci] in commit message** | Include skip markers in version bump commit to prevent re-trigger | Standard GitHub feature, reliable | **CHOSEN** - Official GitHub mechanism, widely supported |
| **github.actor detection** | Check if triggering actor is github-actions[bot] in job conditions | Simple conditional logic | **CHOSEN** - Reliable defense in depth against infinite loops |
| **workflow_dispatch only** | Only allow manual triggering for version bumps | Manual overhead, slower releases | REJECTED - Automation goal conflicts with manual triggers |
| **Tag-driven workflow** | Create annotated tag first, then update files and publish | Clear version source of truth | **CHOSEN** - Tags are immutable, good audit trail |
| **Commit-driven workflow** | Update files first, then create tag from updated commit | Files and tags always in sync | REJECTED - More complex error recovery if publish fails |

## Constraints discovered

- Dart 0.x semver: For version 0.1.1, patch increment goes to 0.1.2 (third number), not 0.2.0
- GitHub Actions skip instructions only apply to `push` and `pull_request` events, not `pull_request_target`
- Windows GitHub runners don't have yq pre-installed, requiring additional setup step
- pub.dev OIDC authentication requires `id-token: write` permission and official reusable workflow
- Keep a Changelog format requires exact `## [version] - YYYY-MM-DD` structure for version sections
- Git consumers need version information in repository files, not just published packages

## Unresolved

- [UNRESOLVED: What happens if pub.dev publish succeeds but the version commit fails to push back to main?]
- [UNRESOLVED: Should the workflow create GitHub releases automatically or only tags?]
- [UNRESOLVED: How to handle version conflicts if multiple concurrent pushes trigger the workflow?]

## Sources

- GitHub Actions skip workflow documentation: https://docs.github.com/en/actions/how-tos/manage-workflow-runs/skip-workflow-runs (consulted 2026-09-10)
- Dart pubspec version format: https://dart.dev/tools/pub/pubspec (consulted 2026-09-10)
- Dart versioning guide: https://dart.dev/tools/pub/versioning (consulted 2026-09-10)
- Keep a Changelog specification: https://keepachangelog.com/en/2.0.0/ (consulted 2026-09-10)
- Dart pub publish command: https://dart.dev/tools/pub/cmd/pub-lish (consulted 2026-09-10)
- Automated publishing to pub.dev: https://dart.dev/tools/pub/automated-publishing (consulted 2026-09-10)
- GitHub Actions infinite loop prevention examples: https://github.com/maximhq/bifrost/pull/326 (consulted 2026-09-10)
- Version extraction examples: https://stackoverflow.com/questions/75523265/how-to-extract-app-version-from-pubspec-yaml-in-a-flutter-app-to-use-it-in-githu (consulted 2026-09-10)