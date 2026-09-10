# Package audit

## Scope and verdict

This is a planning-only audit of the dirty checkout on 2026-09-10. The publication target is the root package `webmcp_pilot`; `example/` is its non-published demo. No source, package metadata, Git state, or remote state was changed by this audit.

Verdict: **not ready to publish**. The SDK could not reach pub's validator in the restricted environment, so the authoritative archive contents and pub validation result remain unresolved. Independently visible release-content blockers also remain in the README and changelog.

## Findings

### Blockers

1. **The required pub publish validation has no successful result.** The bounded `dart pub publish --dry-run` probe exited 1 before package validation because the Flutter-managed Dart launcher attempted to write `/Users/ortalcohen/flutter/bin/cache/engine.stamp`, which the sandbox denied. This is an environment failure, not evidence that the package passes or fails pub validation.
2. **The README contains repository-scaffold copy that does not describe the package.** After the package introduction at `README.md:1-9`, a second top-level section starts at `README.md:11` and says the repository has “No product code yet” at `README.md:13`. It then documents agent commands and internal workflow through `README.md:81`. This would be the primary pub.dev landing page and contradicts the implemented package described above it.
3. **The changelog does not contain a release entry matching version 0.1.0.** `pubspec.yaml:3` declares `0.1.0`, while `CHANGELOG.md:3` has only `Unreleased`. The initial feature list at `CHANGELOG.md:5` therefore is not attached to the version being prepared for publication.
4. **The final public package URLs are unresolved.** The manifest has no `repository`, `homepage`, or `issue_tracker` fields (`pubspec.yaml:1-21`). The configured Git remote is the historical skeleton URL `https://github.com/ortal83cohen/project-AI-skeleton`; it must not be copied into package metadata without confirming the final public repository and issue destination.

### Recommendations

1. **Define a deliberate publish allowlist with `.pubignore`.** There is no `.pubignore`; `.gitignore:1-35` excludes generated and local files but does not exclude repository-only automation and planning material. A tracked-file approximation contains 135 files: 71 under `wiki/`, 23 under `.claude/`, 4 under `.cursor/`, plus `AGENTS.md`, `CLAUDE.md`, `tools/`, and `.github/`. Because the real dry-run did not reach archive construction, the exact pub archive is `[UNVERIFIED]`, but these tracked paths should be explicitly reviewed and excluded unless users need them.
2. **Keep the demo publish-disabled.** `example/pubspec.yaml:3` correctly sets `publish_to: none`, and `example/pubspec.yaml:12-13` uses a path dependency back to the root. Retain both properties in the demo.
3. **Add package discovery metadata after the public destinations are decided.** The package already has a concise description (`pubspec.yaml:2`), semantic version (`pubspec.yaml:3`), Dart constraint (`pubspec.yaml:5-6`), and explicit web platform declaration (`pubspec.yaml:20-21`). Consider verified `repository`, `issue_tracker`, and relevant `topics`; do not add placeholder URLs.
4. **Review the Dart/Flutter compatibility claim as one release decision.** The README says Flutter 3.47.0 at `README.md:5`, while the manifest expresses only Dart `^3.13.0` at `pubspec.yaml:5-6`. Confirm the intended minimum supported Flutter release and express/document it consistently before release.
5. **Keep the current license.** `LICENSE:1-21` contains the complete MIT license text. Confirm the copyright-holder wording at `LICENSE:3` is the intended public attribution.
6. **Inspect the generated archive after the environment issue is resolved.** Review every file printed by the successful dry-run, its compressed/uncompressed size, detected warnings, and the final validation summary before any publish command is considered.

## Command evidence

### Authoritative publish dry-run probe

The probe was bounded to 90 seconds by a subprocess timeout. Command requested:

```text
dart pub publish --dry-run
```

Exact combined stdout/stderr and recorded exit code:

```text
/Users/ortalcohen/flutter/bin/internal/update_engine_version.sh: line 64: /Users/ortalcohen/flutter/bin/cache/engine.stamp: Operation not permitted

[exit code: 1]
```

Result: **ERROR / UNVERIFIED**, not pass.

### Tracked-file payload approximation

Commands:

```text
git ls-files | wc -l
git ls-files | awk -F/ '{print $1}' | sort | uniq -c | sort -nr
```

Exact output:

```text
     135
  71 wiki
  23 .claude
  12 lib
   7 test
   7 example
   4 .cursor
   2 tools
   1 pubspec.yaml
   1 analysis_options.yaml
   1 README.md
   1 LICENSE
   1 CLAUDE.md
   1 CHANGELOG.md
   1 AGENTS.md
   1 .gitignore
   1 .github
```

This is evidence about tracked files, not a substitute for pub's archive list.

## Unresolved

- `[UNRESOLVED: Run dart pub publish --dry-run successfully in an environment where the Flutter SDK cache is writable, then retain its complete archive listing, warnings, and validation summary.]`
- `[UNRESOLVED: Confirm the final public repository URL and issue tracker; the current remote is a skeleton repository and is not assumed to be correct.]`
- `[UNRESOLVED: Decide which repository-only paths, tests, and demo assets belong in the published archive, then encode that decision in .pubignore and verify the resulting dry-run payload.]`
- `[UNRESOLVED: Confirm the intended public package name is available on pub.dev before publication; no network-backed availability check completed in this audit.]`
- `[UNRESOLVED: Confirm the intended public copyright-holder wording.]`
