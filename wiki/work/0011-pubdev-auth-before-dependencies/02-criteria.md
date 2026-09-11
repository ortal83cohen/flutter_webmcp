# Acceptance criteria: Prevent pub.dev OIDC auth from breaking dependency resolution

## Frozen

- Frozen at: 2026-09-11
- Frozen by: codex

## Criteria

| ID | Criterion | How it is checked | Negative case |
|---|---|---|---|
| AC-001 | When the publish workflow is triggered by a matching version tag, it shall resolve dependencies before installing pub.dev OIDC authentication. | Inspect workflow step order. | OIDC setup before dependency resolution fails the criterion. |
| AC-002 | The publish workflow shall retain `id-token: write` and shall publish using the authenticated Dart command. | Inspect workflow permissions and publish steps. | A workflow without OIDC permission or with no authenticated publish step fails the criterion. |
| AC-003 | The publish workflow shall not introduce a long-lived pub.dev credential. | Search the workflow and diff for pub.dev secrets or token literals. | Any stored pub.dev credential fails the criterion. |

## Non-functional criteria

| ID | Criterion | How it is checked | Negative case |
|---|---|---|---|
| AC-004 | The workflow shall preserve the configured `v{{version}}` tag compatibility. | Compare the tag trigger with the repository release documentation. | A changed or incompatible tag pattern fails the criterion. |

## Explicitly not required

The local environment cannot prove a GitHub-hosted rerun, pub.dev OIDC exchange, or successful publication.

## Verdict log

| Round | Date | Verdict | Report |
|---|---|---|---|
