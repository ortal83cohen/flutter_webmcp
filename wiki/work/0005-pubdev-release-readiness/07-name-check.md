# Requested package name check

On 2026-09-10 the user requested the name flutter_webmcp instead of webmcp_pilot. This supersedes the provisional name assumption and name-availability uncertainty in 00-research.md and the initial research streams. Current source remains webmcp_pilot until implementation.

## Evidence

The public registry endpoint https://pub.dev/api/packages/flutter_webmcp returned HTTP 200. Selected fields from the returned JSON:

- name: flutter_webmcp
- latest.version: 0.3.0
- latest.pubspec.repository: https://github.com/KickNext/flutter_webmcp
- latest.pubspec.issue_tracker: https://github.com/KickNext/flutter_webmcp/issues
- published versions: 0.2.0, 0.2.1, 0.3.0

Command:

    curl -sS --max-time 20 -w '\nHTTP_STATUS=%{http_code}\n' https://pub.dev/api/packages/flutter_webmcp

Status output:

    HTTP_STATUS=200

The initial browser fetch was inaccessible and the sandbox shell could not resolve pub.dev. The successful read-only query ran with network permission; the selected JSON fields above are from that response, not search inference.

## Consequence

The name is occupied. A source rename alone cannot authorize uploading to that existing package. Publishing requires uploader rights (or the relevant publisher membership), an unused version and compatibility review against its existing release history. Source: https://dart.dev/tools/pub/publishing, publishing permissions section, accessed 2026-09-10.

[UNRESOLVED: Does the user hold publishing rights to the existing flutter_webmcp package? An asynchronous question is pending. If not, the user must choose a different publication name; no alternative is chosen automatically.]

Until resolved, continue independent release planning while keeping name-dependent implementation and upload gated. Do not describe this as a fresh unclaimed package or use a provisional 0.1.0 version without revisiting release history.
