# Name selection and planning amendment

## User direction

On 2026-09-10 the user requested a suitable alternative name without pilot after learning flutter_webmcp was occupied. This amendment supersedes the requested-name and occupied-namespace path in 01-plan.md, AC-002 and AC-003 in 02-criteria.md, and tasks 1.2 and 2.1 in 03-tasks.md. Historical research and reviews retain the names they inspected. Criteria remain unfrozen; no implementation has started.

## Recommended name

Use webmcp_flutter as the proposed publication name and WebMCP for Flutter as the display title. It contains both core search terms, is concise, and avoids a maturity label. These are naming judgments, not evidence of increased downloads. The description must still explicitly identify the detection-first registry scope; the name does not promise a browser bridge.

## Registry evidence

Read-only public API requests on 2026-09-10 returned the following results, in command order:

| Candidate | Public endpoint | HTTP result |
|---|---|---|
| flutter_webmcp_toolkit | https://pub.dev/api/packages/flutter_webmcp_toolkit | 404 |
| webmcp_flutter | https://pub.dev/api/packages/webmcp_flutter | 404 |
| flutter_webmcp_tools | https://pub.dev/api/packages/flutter_webmcp_tools | 404 |
| flutter_webmcp_kit | https://pub.dev/api/packages/flutter_webmcp_kit | 404 |

Exact command:

```sh
for package_name in flutter_webmcp_toolkit webmcp_flutter flutter_webmcp_tools flutter_webmcp_kit; do curl -sS --max-time 15 -w '\nHTTP_STATUS=%{http_code}\n' "https://pub.dev/api/packages/$package_name"; done
```

Each response body was:

```text
<?xml version='1.0' encoding='UTF-8'?><Error><Code>NoSuchKey</Code><Message>The specified key does not exist.</Message></Error>
HTTP_STATUS=404
```

This is evidence that no public package record was returned at check time, not a reservation or guarantee that pub will accept the name. Recheck immediately before publication. The distinct occupied flutter_webmcp name returned HTTP 200 in 07-name-check.md.

## Updated plan instructions

The proposed target manifest name becomes webmcp_flutter and the public barrel becomes lib/webmcp_flutter.dart. Update active imports, tests, example and documentation accordingly during the already planned rename task; current source remains webmcp_pilot. Preserve historical wiki artifacts and package references used in the competitor comparison.

Replace the gate requiring rights to the existing flutter_webmcp package with a fresh availability check and verification of the publishing Google Account. There is no need to obtain rights to KickNext's package for this distinct name. Keep the competitor capability comparison, public repository decisions and all other release gates unchanged. A first prerelease such as 0.1.0-dev.1 is a recommendation; the exact release version/channel remains a release decision rather than a source edit in this planning request.

The previous plan review passed the original rename workflow before this naming amendment. It does not establish release readiness or imply a completed implementation. Before implementation freeze, validate the consolidated plan including this amendment through the next numbered round, together with any scope findings from the required capability comparison.
