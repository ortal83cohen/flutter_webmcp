# Research: Publish webmcp_flutter on every push to main

## Question

How can this repository bump a patch version and publish webmcp_flutter to pub.dev on every push to main, without storing a pub.dev password in git, without republishing 0.1.0 or 0.1.1, and without fighting the existing checks workflow.

## Answer

Pub.dev automated publishing authenticates with GitHub Actions OpenID Connect and only accepts workflows started by a git tag push. A push-to-main release job must therefore bump the patch number, commit pubspec and changelog, and push an annotated tag whose name matches the pubspec version. A second workflow, started by that tag, runs the official Dart reusable publish workflow. The default GitHub Actions token cannot start the tag workflow, so the bump job must push with a personal access token or GitHub App token stored as a repository secret. The next publishable version is 0.1.2.

## Findings

### Pub.dev requires tag-triggered GitHub Actions

- Claim: Automated publishing from GitHub Actions is allowed only when the workflow is triggered by pushing a git tag. Publishing from a branch push is rejected.
- Evidence: Official Dart documentation states that pub.dev rejects publishing from GitHub Actions triggered without a tag, and that the publisher must configure a repository and a tag pattern containing a version placeholder.
- Source: https://dart.dev/tools/pub/automated-publishing (consulted 2026-09-10)

### First version of a package cannot be created by automation

- Claim: Automated publishing works only for packages that already exist. The first version must be published with an interactive dart pub publish.
- Evidence: Same Dart page, note that only existing packages can be automated.
- Source: https://dart.dev/tools/pub/automated-publishing (consulted 2026-09-10)

### This package already exists on pub.dev

- Claim: webmcp_flutter 0.1.0 and 0.1.1 are already published. Those versions must never be reused. The next patch is 0.1.2.
- Evidence: pub.dev package API returns latest 0.1.1 published 2026-09-10T14:26:01Z and versions 0.1.0 and 0.1.1.
- Source: https://pub.dev/api/packages/webmcp_flutter (consulted 2026-09-10); wiki/work/0005-pubdev-release-readiness/STATE.yaml line 58

### Official publish workflow uses OIDC, not a pub.dev password

- Claim: The recommended GitHub workflow file uses id-token write permission and the reusable workflow dart-lang/setup-dart publish workflow at v1. Custom jobs may run dart pub publish with the force flag after dart-lang/setup-dart, which installs a temporary GitHub-signed token.
- Evidence: Official example workflow on the automated publishing page.
- Source: https://dart.dev/tools/pub/automated-publishing (consulted 2026-09-10); https://github.com/dart-lang/setup-dart/blob/main/.github/workflows/publish.yml

### Default Actions token cannot start the publish workflow

- Claim: Events created with the repository GITHUB_TOKEN do not start new workflow runs, except for listed pull-request cases. A bump job that pushes a tag with that token will not run a tag-triggered publish workflow.
- Evidence: GitHub documentation on triggering a workflow from a workflow.
- Source: https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow (consulted 2026-09-10)

### Skip-ci markers stop push and pull-request workflows

- Claim: A commit message containing skip ci, ci skip, no ci, skip actions, or actions skip prevents push and pull-request workflows from running. The documentation scopes the suppression to the runs that the commit carrying the instruction would trigger, and a tag push is a push event whose head commit is that same commit.
- Evidence: GitHub skip-workflow-runs documentation states that skip instructions apply to the push and pull-request events and to the workflow runs that would be triggered by the commit containing the instruction.
- Source: https://docs.github.com/en/actions/how-tos/manage-workflow-runs/skip-workflow-runs (consulted 2026-09-10)

### A skip marker is unsafe for this design, so the loop guard must be our own condition

- Claim: Because the annotated tag points at the bump commit, a skip marker in that commit message risks suppressing the tag-triggered publish run, which is the only run that can publish. A repository-owned job condition that inspects the head commit message avoids GitHub's suppression mechanism entirely while still stopping the bump commit from re-entering the release job.
- Evidence: [UNVERIFIED: whether GitHub applies a skip instruction to a tag-ref push whose head commit carries the marker; the skip-workflow-runs page does not distinguish branch pushes from tag pushes.] The documented alternative is a job-level if expression, which GitHub evaluates from the push payload rather than suppressing the run.
- Source: https://docs.github.com/en/actions/how-tos/manage-workflow-runs/skip-workflow-runs (consulted 2026-09-10); https://docs.github.com/en/actions/reference/workflows-and-actions/contexts (consulted 2026-09-10)

### The triggering actor of a token-authenticated push is the token owner, not the Actions bot

- Claim: A job condition comparing the triggering actor against github-actions[bot] cannot stop a loop caused by a push made with a personal access token or GitHub App installation token, because the actor of such a push is the token owner or the App account. The commit author can be the bot while the actor is not.
- Evidence: GitHub contexts documentation defines the actor field as the username of the user that triggered the initial workflow run.
- Source: https://docs.github.com/en/actions/reference/workflows-and-actions/contexts (consulted 2026-09-10)

### Workflows that define only branch filters ignore tag pushes

- Claim: The existing checks workflow, which filters push events by branch only, does not run for a tag push. The release workflow therefore competes with nothing on the tag.
- Evidence: GitHub trigger documentation states that when only branches or branches-ignore is defined, the workflow does not run for events affecting the undefined git ref.
- Source: https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow (consulted 2026-09-10); .github/workflows/checks.yml line 4

### Existing checks already run on every branch including main

- Claim: .github/workflows/checks.yml listens to push on all branches and to pull requests, and runs wiki lint plus tools/check.sh with Flutter 3.47.0.
- Evidence: checks.yml lines 1 through 49.
- Source: .github/workflows/checks.yml

### Changelog and pubspec formats already in the repo

- Claim: pubspec.yaml name is webmcp_flutter, version is 0.1.1. CHANGELOG.md uses headings of the form two hashes, version, space, hyphen, space, ISO date, without Keep a Changelog brackets.
- Evidence: pubspec.yaml lines 1 and 3; CHANGELOG.md lines 3 and 7.
- Source: pubspec.yaml; CHANGELOG.md

### Work item 0005 required interactive confirmation for the first releases

- Claim: 0005 froze interactive dart pub publish with human confirmation for 0.1.0. That rule applied to that first publication, not to a later user request for main-branch automation.
- Evidence: wiki/work/0005-pubdev-release-readiness/34-final-publication-controls.md
- Source: wiki/work/0005-pubdev-release-readiness/34-final-publication-controls.md

### Rate limits and immutable versions

- Claim: Published versions last forever. [UNVERIFIED: pub.dev burst limit of four packages in a few minutes and twelve in twenty-four hours as reported in research/automated-publishing.md; the official automated-publishing page fetched on 2026-09-10 does not state those numbers in the extracted text.]
- Evidence: Publishing page states a published package lasts forever. Rate-limit numbers are marked unverified pending a primary source.
- Source: https://dart.dev/tools/pub/publishing (consulted 2026-09-10)

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| Publish from the main-branch job with OIDC | One workflow on push to main runs dart pub publish after a bump | One file | Rejected. Pub.dev rejects Actions that were not started by a tag. |
| Tag-only official publish, humans bump and tag | Humans edit pubspec, push tag vX.Y.Z | No bump automation | Rejected. The user chose bump on every push to main. |
| Two workflows: bump on main, official publish on tag | Main job bumps, commits, pushes tag with a token that can start workflows; tag job uses dart-lang reusable publish | One repository secret; pub.dev admin enablement | Chosen. Matches official auth and the user's trigger. |
| Long-lived pub credentials JSON secret | dart pub publish using stored login | Secret rotation and leak risk | Rejected. Official docs prefer OIDC. |
| Extend checks.yml with a publish job | Same file runs tests and publish | Couples release to the all-branches check | Rejected. Duplicate tests on main and mixes concerns. |
| Publish without committing the bump | Archive on pub.dev has the new version; git stays at 0.1.1 | Git and pub.dev drift | Rejected. Clone consumers and the next bump would collide. |

## Constraints discovered

- Tag pattern on pub.dev must contain the version placeholder and must match the workflow tag filter. The official example uses a v prefix plus three numeric components.
- The pubspec version must match the tag version.
- Repository on pub.dev must be the GitHub owner and name, currently ortal83cohen/flutter_webmcp per pubspec repository URL.
- Flutter packages are supported by the official reusable publish workflow, which installs a Flutter SDK.
- Default branch is main (origin/HEAD).
- A personal access token or GitHub App token with contents write is required so the tag push starts publish.yml. workflow_dispatch of the publish workflow would not satisfy pub.dev's tag-trigger rule.
- Branch protection that forbids GitHub Actions from pushing to main will block the bump commit. That is an operator configuration, not a file in this repository.
- Concurrent pushes to main can race on the same patch number. A concurrency group that does not cancel in progress serialises the bump job.
- Wiki lint and tools/check.sh must pass before a release is tagged, otherwise a failing main commit still ships to pub.dev.

## Unresolved

- [UNRESOLVED: Whether this GitHub repository currently has branch protection that blocks a bot commit to main.]
- [UNRESOLVED: Whether automated publishing from GitHub Actions is already enabled on the pub.dev admin tab for webmcp_flutter.]
- [UNRESOLVED: Whether a RELEASE_GITHUB_TOKEN or equivalent secret already exists in the repository.]
- [UNRESOLVED: Exact pub.dev daily publish rate limit numbers; treat as unknown and avoid publishing more than a handful of versions per day.]
- [UNRESOLVED: Whether a GitHub skip instruction in a commit message suppresses a workflow triggered by a push of a tag pointing at that commit. The design avoids the question by using no skip marker.]
- [UNRESOLVED: Which Flutter SDK version the official Dart reusable publish workflow installs; it delegates to an action whose default version input is latest, so the archive is validated on an SDK this repository does not pin.]

## Sources

- https://dart.dev/tools/pub/automated-publishing (consulted 2026-09-10)
- https://dart.dev/tools/pub/publishing (consulted 2026-09-10)
- https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow (consulted 2026-09-10)
- https://docs.github.com/en/actions/how-tos/manage-workflow-runs/skip-workflow-runs (consulted 2026-09-10)
- https://pub.dev/api/packages/webmcp_flutter (consulted 2026-09-10)
- .github/workflows/checks.yml (consulted 2026-09-10)
- pubspec.yaml (consulted 2026-09-10)
- CHANGELOG.md (consulted 2026-09-10)
- wiki/work/0005-pubdev-release-readiness/STATE.yaml (consulted 2026-09-10)
- wiki/work/0009-pubdev-publish-workflow/research/automated-publishing.md
- wiki/work/0009-pubdev-publish-workflow/research/version-bump.md
- wiki/work/0009-pubdev-publish-workflow/research/repo-constraints.md
