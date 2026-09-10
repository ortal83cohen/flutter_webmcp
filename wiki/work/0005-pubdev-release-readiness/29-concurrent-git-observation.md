# Concurrent Git observation

During independent verification, the repository HEAD and index changed outside the release agents' executed commands. The actor is [UNVERIFIED]. The original dirty baseline and index digest remain in 30-release-execution.md. Release agents issued no stage, commit, branch checkout, reset, stash or push commands. Preserve the current state rather than restoring the old baseline.

Command: `git log -3 --format="%h %s"`

```text
4689c66 2
34de14d 1
dfc8c48 init webmcp_flutter
Exit: 0
```

Command: `git status --short` (before this record was created)

```text
Exit: 0
```

The source snapshot comparison found only the release-owned STATE.yaml changed after the tested snapshot. All payload paths, sizes and hashes were rechecked against both source and disposable payload.

Command: `python3 /private/tmp/webmcp-release-010-run/payload.py verify`

```text
PASS: source/payload paths, sizes and SHA-256 unchanged; all four dry-run inventories identical
Exit: 0
```
