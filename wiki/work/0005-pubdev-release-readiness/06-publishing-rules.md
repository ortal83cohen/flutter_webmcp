# Pub.dev publishing rules

Checked 2026-09-10.

## Requirements

- Pub.dev requires `LICENSE`, redistribution rights, acceptable size, only default-hosted or `sdk: flutter` dependencies, and a Google Account. The pubspec requires a valid name, version, English description, and SDK constraint. Published versions remain available.
- Root `pubspec.yaml` has those fields, permitted dependencies, and web-only platform declaration; `LICENSE`, `README.md`, and `CHANGELOG.md` exist. Publish validation remains unverified.

## Recommendations

- Run `dart pub publish --dry-run` and inspect its files. Add `repository` or `homepage`; target below 100 MB compressed and 256 MB uncompressed; use a verified publisher with multiple members. Ignoring root `pubspec.lock` matches library guidance.
- Automation is optional after the manual first release. GitHub automation requires a matching tag push and pubspec version.

## Unresolved

- [UNRESOLVED: `webmcp_pilot` availability; the unauthenticated API lookup was inaccessible.]
- [UNRESOLVED: redistribution, account, uploader, publisher, and domain rights.]
- [UNRESOLVED: release `0.1.0` stable or as a prerelease; publication needs an explicit human choice.]

## Sources

- https://dart.dev/tools/pub/publishing (updated 2026-05-15; accessed 2026-09-10)
- https://dart.dev/tools/pub/pubspec (accessed 2026-09-10)
- https://dart.dev/tools/pub/package-layout (accessed 2026-09-10)
- https://dart.dev/tools/pub/automated-publishing (accessed 2026-09-10)
