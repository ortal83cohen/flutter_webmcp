# Impl review — round 01

- Work item: 0016-user-facing-feature-opportunities
- Reviewed artifact: uncommitted diff of the paths listed in the review request, against git revision bc1d786
- Reviewer: impl-validator
- Date: 2026-09-25

## Verdict

**PASS**

Every criterion AC-001 through AC-017 is met by the uncommitted diff, each specified negative case is asserted, and the checks below exited 0.

## Verification performed

Command:

```
flutter test test/native_publisher_test.dart test/page/webmcp_page_test.dart test/registry_test.dart test/transport_selection_test.dart test/webmcp_public_surface_test.dart test/widget_layer_test.dart --reporter expanded
```

Output:

```
00:00 +0: loading /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/native_publisher_test.dart
00:00 +0: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/native_publisher_test.dart: absent browser remains local-only without registration attempts
00:00 +1: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/native_publisher_test.dart: attach mirrors snapshot and later mutations without duplication
00:00 +2: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/native_publisher_test.dart: detach is idempotent and reset is a cleanup safety net
00:00 +3: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/native_publisher_test.dart: browser failure leaves the local tool registered and usable
00:00 +4: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/native_publisher_test.dart: skipped duplicate never unregisters the live browser owner
00:00 +5: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/native_publisher_test.dart: registration limit rejects one over without evicting owners
00:00 +6: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/native_publisher_test.dart: wire boundary round trips bounded JSON and rejects invalid input
00:00 +7: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/native_publisher_test.dart: browser sanitizes handler errors while local invocation stays raw
00:00 +8: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/native_publisher_test.dart: rejects invalid output without retaining result or exception text
00:00 +9: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/native_publisher_test.dart: cancel before dispatch has no handler call and no replay
00:00 +10: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/native_publisher_test.dart: operation exact limit and one over fail before side effects
00:00 +11: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/native_publisher_test.dart: receipt expiry does not free outstanding execution slots
00:00 +12: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/native_publisher_test.dart: capabilities and diagnostics contain allowlisted safe metadata only
00:00 +13: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/native_publisher_test.dart: call handler sees the execution signal once
00:00 +14: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/native_publisher_test.dart: abort after start leaves the handler future pending
00:00 +15: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/native_publisher_test.dart: cancel before dispatch skips the call handler
00:00 +16: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/native_publisher_test.dart: registration object omits unset title debugging and exposedTo
00:00 +17: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/native_publisher_test.dart: tool activity is delivered and dropped after detach
00:00 +18: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/native_publisher_test.dart: toolcancel does not finish the running call handler
00:00 +19: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/native_publisher_test.dart: structured tool exceptions become agent errors
00:00 +20: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:01 +79: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: page dispatch uses a call handler with a null signal
00:01 +80: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: page dispatch invokes a handler-only tool once
00:01 +81: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: disposing a page removes owned endpoints and remounts fresh
00:01 +82: All tests passed!
```

The reporter interleaved the remaining files. Exit code was 0 and the final line was `All tests passed!` for the six files named above. Criterion tests that this run executed include `one callback receives the map and exposedTo is copied`, `both tool callbacks throw and leave the registry unchanged`, `local invoke throws the tool exception`, `log hook records kind and tool name without arguments`, `a throwing hook leaves the tool registered`, `declared input rejects bad values before the callback`, `free-form schema is a shallow copy and is not validated`, `non-web registration is local and native publication is a no-op`, `onCall and onInvoke each mount one callback`, `both widget callbacks throw and register nothing`, and `first mount keeps the published title`.

Command:

```
dart analyze --fatal-infos --fatal-warnings lib/src/page/webmcp_page.dart lib/src/transport/native_publisher_boundary.dart lib/src/transport/native_publisher_boundary_noop.dart lib/src/transport/native_publisher_boundary_web.dart lib/src/transport/webmcp_native_publisher.dart lib/src/webmcp.dart lib/src/webmcp_exceptions.dart lib/src/webmcp_tool.dart lib/src/webmcp_typed_input.dart lib/src/widgets/webmcp_action.dart lib/webmcp_flutter.dart test/native_publisher_test.dart test/page/webmcp_page_test.dart test/registry_test.dart test/transport_selection_test.dart test/webmcp_public_surface_test.dart test/widget_layer_test.dart
```

Output:

```
Analyzing webmcp_page.dart, native_publisher_boundary.dart, native_publisher_boundary_noop.dart, native_publisher_boundary_web.dart, webmcp_native_publisher.dart, webmcp.dart, webmcp_exceptions.dart, webmcp_tool.dart, webmcp_typed_input.dart, webmcp_action.dart, webmcp_flutter.dart, native_publisher_test.dart, webmcp_page_test.dart, registry_test.dart, transport_selection_test.dart, webmcp_public_surface_test.dart, widget_layer_test.dart...
No issues found!
```

`test/transport_web_browser_test.dart` is in the diff only as a removed import. No criterion names it. It was not run.

## Per-criterion results

| Criterion | Result | Evidence (file:line) | Negative case exercised |
|---|---|---|---|
| AC-001 | pass | `lib/src/transport/webmcp_native_publisher.dart:357`; `test/native_publisher_test.dart:548` | yes |
| AC-002 | pass | `lib/src/transport/webmcp_native_publisher.dart:336`; `test/native_publisher_test.dart:561` | yes |
| AC-003 | pass | `lib/src/webmcp.dart:240`; `lib/src/transport/webmcp_native_publisher.dart:366`; `test/registry_test.dart:199`; `test/native_publisher_test.dart:291` | yes |
| AC-004 | pass | `lib/src/transport/native_publisher_boundary.dart:76`; `test/native_publisher_test.dart:659`; `test/widget_layer_test.dart:302` | yes |
| AC-005 | pass | `lib/src/transport/native_publisher_boundary.dart:81`; `test/native_publisher_test.dart:667` | yes |
| AC-006 | pass | `lib/src/webmcp_tool.dart:89`; `test/native_publisher_test.dart:670`; `test/registry_test.dart:192` | yes |
| AC-007 | pass | `lib/src/transport/webmcp_native_publisher.dart:399`; `test/native_publisher_test.dart:679` | yes |
| AC-008 | pass | `lib/src/transport/webmcp_native_publisher.dart:399`; `test/native_publisher_test.dart:718` | yes |
| AC-009 | pass | `lib/src/webmcp_typed_input.dart:75`; `test/registry_test.dart:291` | yes |
| AC-010 | pass | `lib/src/webmcp_tool.dart:848`; `test/registry_test.dart:335` | yes |
| AC-011 | pass | `lib/src/transport/webmcp_native_publisher.dart:414`; `test/native_publisher_test.dart:768` | yes |
| AC-012 | pass | `lib/src/webmcp.dart:219`; `test/registry_test.dart:215`; `test/native_publisher_test.dart:823` | yes |
| AC-013 | pass | `lib/src/webmcp.dart:98`; `test/registry_test.dart:239`; `test/native_publisher_test.dart:704` | yes |
| AC-014 | pass | `lib/src/transport/native_publisher_boundary_noop.dart:17`; `lib/src/transport/webmcp_native_publisher.dart:198`; `test/transport_selection_test.dart:110` | yes |
| AC-015 | pass | `lib/src/webmcp.dart:86`; `lib/src/transport/webmcp_native_publisher.dart:382`; `test/native_publisher_test.dart:825` | yes |
| AC-016 | pass | `lib/src/page/webmcp_page.dart:639`; `test/page/webmcp_page_test.dart:1005` | yes |
| AC-017 | pass | `lib/src/widgets/webmcp_action.dart:99`; `test/widget_layer_test.dart:240` | yes |

Negative-case checks that fail when the behaviour is wrong:

- AC-001: `test/native_publisher_test.dart:554` expects a null decoded result and `callCalls == 2` when `invoke` is called with no execution signal. A non-null signal or a skipped second call fails that assertion.
- AC-002: `test/native_publisher_test.dart:590` expects `TimeoutException` while the handler waits, then a completed result. `test/native_publisher_test.dart:618` expects error code `cancelled` and zero calls when `cancelledBeforeDispatch` is set.
- AC-003: `test/registry_test.dart:199` expects the exact argument map. `test/native_publisher_test.dart:291` expects the browser result to contain the map the one-argument handler returned. `test/registry_test.dart:202` expects `ArgumentError` and an empty registry when both callbacks are passed.
- AC-004: `test/native_publisher_test.dart:659` expects the title key to be absent, then `titled['title']` equal to `Author title`. `test/widget_layer_test.dart:302` expects the registered title to stay `First title` after a rebuild that passes `Second title`.
- AC-005: `test/native_publisher_test.dart:667` expects `containsKey('debugging')` to be false, then `true`, then `false` on three separate annotation objects. Absence is not asserted as a sent false.
- AC-006: `test/registry_test.dart:192` appends an origin after construction and expects the stored list to stay the original one-element list. The registration test expects the member absent, then an empty list, then the two author strings in order.
- AC-007: `test/native_publisher_test.dart:706` expects one started activity, tool name `quiet`, and zero handler calls. After detach, `test/native_publisher_test.dart:715` expects the listener length to stay 1.
- AC-008: `test/native_publisher_test.dart:759` expects the publisher future to time out while the handler is in flight and the listener to have recorded `cancel.live` once. `test/native_publisher_test.dart:765` then expects a later `invokeTool` to enter the handler and return `again`.
- AC-009: `test/registry_test.dart:325` expects zero callback calls after the unknown key, the missing required key, the double `1.0`, and the integer `9007199254740992`. The following invoke expects one call and the map `label`/`count` with no extra key.
- AC-010: `test/registry_test.dart:354` expects the handler to run on an empty argument map. `test/registry_test.dart:356` expects the outer schema map not to be identical and the nested `properties` object to stay identical.
- AC-011: `test/native_publisher_test.dart:825` expects code `author.code`, `retryable` true, and the details object. The bare exception expects no `details` key. `test/native_publisher_test.dart:842` expects `handlerFailed` and the absence of the `StateError` message. `test/native_publisher_test.dart:851` expects `handlerFailed` and the absence of the oversized blob.
- AC-012: `test/registry_test.dart:227` expects the local future to throw `WebMcpToolException` with code `author.code`. `test/native_publisher_test.dart:823` expects the publisher result to be the JSON error object.
- AC-013: `test/registry_test.dart:267` expects registered, invoked, invocationFailed, and unregistered, each named `logged`, and the joined record text not to contain `distinctive-argument-secret`. `test/native_publisher_test.dart:704` expects `nativeActivity` for `quiet`. `test/registry_test.dart:278` expects a throwing hook to leave `kept` invocable.
- AC-014: `test/transport_selection_test.dart:127` expects the handler result `local` after two `abort` calls, then `publishedToolCount` 0 and reason `browserUnavailable`. The invoke after `abort` fails if abort removed the local tool.
- AC-015: `test/native_publisher_test.dart:844` expects the argument secret and the `StateError` message to be absent from the encoded failure. `test/native_publisher_test.dart:825` expects `visible-detail` inside the agent error object, and `test/native_publisher_test.dart:858` expects that string to be absent from the log text.
- AC-016: `test/page/webmcp_page_test.dart:1032` expects one call and a null signal. `test/page/webmcp_page_test.dart:1064` expects the one-argument handler once and a null `callHandler` on the registered tool.
- AC-017: `test/widget_layer_test.dart:252` expects a call handler and a null one-argument handler, then the reverse. `test/widget_layer_test.dart:288` expects `ArgumentError` and an empty registry when both widget callbacks are passed.

No skipped tests, widened assertions, or debug leftovers were present in the reviewed diff. The one-argument browser path is the existing wire test, which returns the handler's argument map. Dispatch still passes that map at `lib/src/transport/webmcp_native_publisher.dart:366`.

## Findings

No findings.

## Recurrence check

- Previous round: none — first round
- Recurring findings: none
- Oscillating: no

## Routing

| Finding | Belongs to phase |
|---|---|
| none | none |
