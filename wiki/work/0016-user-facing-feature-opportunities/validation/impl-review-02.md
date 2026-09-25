# Impl review — round 02

- Work item: 0016-user-facing-feature-opportunities
- Reviewed artifact: uncommitted diff of the paths listed in the review request, against git revision bc1d786
- Reviewer: impl-validator
- Date: 2026-09-25

## Verdict

**PASS**

Every criterion AC-001 through AC-017 holds in the reviewed diff, each specified negative case is asserted, and the documentation claims in the reviewed files match that behavior.

## Verification performed

Command:

```
flutter test test/native_publisher_test.dart test/page/webmcp_page_test.dart test/registry_test.dart test/transport_selection_test.dart test/transport_web_browser_test.dart test/webmcp_public_surface_test.dart test/widget_layer_test.dart
```

Output:

```
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 103.0.0 (108.0.0 available)
  analyzer 13.3.0 (14.4.0 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  package_config 2.2.0 (3.0.0 available)
  test 1.31.1 (1.32.0 available)
  test_api 0.7.12 (0.7.14 available)
  test_core 0.6.18 (0.6.20 available)
  vector_math 2.4.2 (2.4.3 available)
Got dependencies!
8 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Resolving dependencies in `./example`...
Downloading packages...
Got dependencies in `./example`.
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
00:00 +20: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: selects noop on the Dart VM and resets transport
00:00 +21: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/transport_selection_test.dart: notifies registration and unregistration in order
00:00 +22: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_public_surface_test.dart: exports the complete public API and seven registry operations
00:00 +23: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_public_surface_test.dart: exports the complete public API and seven registry operations
00:00 +24: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_public_surface_test.dart: exports the complete public API and seven registry operations
00:00 +25: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_public_surface_test.dart: exports the complete public API and seven registry operations
00:00 +26: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/webmcp_public_surface_test.dart: exports the complete public API and seven registry operations
00:00 +27: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/registry_test.dart: registers tools and lists them in ascending order
00:00 +28: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +29: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +30: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +31: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +32: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +33: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +34: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +35: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +36: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +37: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +38: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +39: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +40: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +41: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +42: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +43: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +44: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +45: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +46: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +47: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +48: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +49: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +50: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +51: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: one wrapper discovers ordinary semantics without descriptors
00:00 +52: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: action without a screen reports the tool and registers nothing
00:00 +53: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: an unwrapped page exposes no automatic endpoints
00:00 +54: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: duplicate actions preserve the first owner
00:00 +55: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: nearest wrapper owns nested content and siblings do not overlap
00:00 +56: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: nearest wrapper owns nested content and siblings do not overlap
00:00 +57: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: nearest wrapper owns nested content and siblings do not overlap
00:00 +58: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: nearest wrapper owns nested content and siblings do not overlap
00:00 +59: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/widget_layer_test.dart: invalid action names fail loudly
00:00 +60: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: stale revision, handle, and request order refuse dispatch
00:00 +61: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: cancel-before-dispatch causes no callback
00:00 +62: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: accepts integer-valued JSON doubles at the action boundary
00:00 +63: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: semantic change records visible effect separately from dispatch
00:00 +64: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: unchanged activity notification emits no content event
00:00 +65: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: dirty page without a serviced frame stays unavailable
00:00 +66: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: privacy omits obscured and excluded subtrees
00:00 +67: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: setText requires separate explicit mutation opt-in
00:00 +68: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: pagination is bounded to one revision and expires on change
00:00 +69: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: response byte limit omits whole optional fields explicitly
00:00 +70: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: capture node, visit, and depth ceilings truncate explicitly
00:00 +71: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: zero and two view providers refuse automatic exposure
00:00 +72: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: owner replacement revokes, rebinds, and ignores old callbacks
00:00 +73: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: unknown transition remains inactive after frames
00:00 +74: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: root modals suspend underlying pages and wrapped modals isolate
00:00 +75: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: nested Navigator uses its forwarding observer and current route
00:00 +76: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: navigation action returns receipt and observes destination
00:00 +77: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: settled Navigator top route controls eligibility during replacement
00:00 +78: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: domain execution saturation rejects before handler side effects
00:00 +79: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: page dispatch uses a call handler with a null signal
00:00 +80: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: page dispatch invokes a handler-only tool once
00:00 +81: /Users/ortalcohen/Documents/GitHub/flutter_webmcp/test/page/webmcp_page_test.dart: disposing a page removes owned endpoints and remounts fresh
00:01 +82: All tests passed!
```

Exit code 0. The compact reporter omitted some names that completed in the same tick. The final count is 82, which is every VM test in the named files. `test/transport_web_browser_test.dart` is `@TestOn('browser')` at line 1, so the VM run does not load it. Its diff only removes an unused import. No criterion names it.

Command:

```
dart analyze --fatal-infos --fatal-warnings lib/src/page/webmcp_page.dart lib/src/transport/native_publisher_boundary.dart lib/src/transport/native_publisher_boundary_noop.dart lib/src/transport/native_publisher_boundary_web.dart lib/src/transport/webmcp_native_publisher.dart lib/src/webmcp.dart lib/src/webmcp_exceptions.dart lib/src/webmcp_tool.dart lib/src/webmcp_typed_input.dart lib/src/widgets/webmcp_action.dart lib/webmcp_flutter.dart test/native_publisher_test.dart test/page/webmcp_page_test.dart test/registry_test.dart test/transport_selection_test.dart test/transport_web_browser_test.dart test/webmcp_public_surface_test.dart test/widget_layer_test.dart
```

Output:

```
Analyzing webmcp_page.dart, native_publisher_boundary.dart, native_publisher_boundary_noop.dart, native_publisher_boundary_web.dart, webmcp_native_publisher.dart, webmcp.dart, webmcp_exceptions.dart, webmcp_tool.dart, webmcp_typed_input.dart, webmcp_action.dart, webmcp_flutter.dart, native_publisher_test.dart, webmcp_page_test.dart, registry_test.dart, transport_selection_test.dart, transport_web_browser_test.dart, webmcp_public_surface_test.dart, widget_layer_test.dart...
No issues found!
```

Documentation comparison, read against the implementation and not treated as a prior verdict: `CHANGELOG.md` lines 39–52, `README.md` lines 40–42, 79–84, and 570–626, `wiki/product/webmcp-contract.md` lines 27–59 and 132–165, `wiki/product/README.md` lines 22–28, and `wiki/INDEX.md` line 54. Each behavioral sentence matches the code cited in the table. None claims that a current Chrome build aborts the execution signal after the callback starts.

## Per-criterion results

| Criterion | Result | Evidence (file:line) | Negative case exercised |
|---|---|---|---|
| AC-001 | pass | `lib/src/transport/webmcp_native_publisher.dart:357`; `test/native_publisher_test.dart:516` | yes |
| AC-002 | pass | `lib/src/transport/webmcp_native_publisher.dart:336`; `test/native_publisher_test.dart:561` | yes |
| AC-003 | pass | `lib/src/webmcp.dart:240`; `lib/src/transport/webmcp_native_publisher.dart:366`; `test/registry_test.dart:180`; `test/native_publisher_test.dart:271` | yes |
| AC-004 | pass | `lib/src/transport/native_publisher_boundary.dart:76`; `test/native_publisher_test.dart:622`; `test/widget_layer_test.dart:302` | yes |
| AC-005 | pass | `lib/src/transport/native_publisher_boundary.dart:81`; `test/native_publisher_test.dart:622` | yes |
| AC-006 | pass | `lib/src/transport/native_publisher_boundary.dart:84`; `lib/src/webmcp_tool.dart:89`; `test/native_publisher_test.dart:622`; `test/registry_test.dart:180` | yes |
| AC-007 | pass | `lib/src/transport/webmcp_native_publisher.dart:399`; `test/native_publisher_test.dart:679` | yes |
| AC-008 | pass | `lib/src/transport/webmcp_native_publisher.dart:399`; `test/native_publisher_test.dart:718` | yes |
| AC-009 | pass | `lib/src/webmcp_typed_input.dart:75`; `test/registry_test.dart:291` | yes |
| AC-010 | pass | `lib/src/webmcp_tool.dart:84`; `test/registry_test.dart:335` | yes |
| AC-011 | pass | `lib/src/transport/webmcp_native_publisher.dart:414`; `test/native_publisher_test.dart:768` | yes |
| AC-012 | pass | `lib/src/webmcp.dart:219`; `test/registry_test.dart:215`; `test/native_publisher_test.dart:768` | yes |
| AC-013 | pass | `lib/src/webmcp.dart:98`; `test/registry_test.dart:239`; `test/native_publisher_test.dart:679` | yes |
| AC-014 | pass | `lib/src/transport/native_publisher_boundary_noop.dart:14`; `lib/src/transport/webmcp_native_publisher.dart:198`; `test/transport_selection_test.dart:110` | yes |
| AC-015 | pass | `lib/src/webmcp.dart:86`; `lib/src/transport/webmcp_native_publisher.dart:438`; `test/native_publisher_test.dart:768`; `test/registry_test.dart:239` | yes |
| AC-016 | pass | `lib/src/page/webmcp_page.dart:638`; `test/page/webmcp_page_test.dart:1005` | yes |
| AC-017 | pass | `lib/src/widgets/webmcp_action.dart:89`; `test/widget_layer_test.dart:240` | yes |

Negative cases read in the same tests: no second argument yields a null signal (`test/native_publisher_test.dart:555`); `cancelledBeforeDispatch` returns `cancelled` and skips the handler (`test/native_publisher_test.dart:597`); both callbacks throw `ArgumentError` and leave the registry empty (`test/registry_test.dart:202`); a rebuild keeps the first title (`test/widget_layer_test.dart:302`); a missing `debugging` member is asserted with `containsKey`, separate from sent `false` (`test/native_publisher_test.dart:667`); mutating the author origin list does not change the stored list (`test/registry_test.dart:192`); activity after detach is not delivered (`test/native_publisher_test.dart:708`); a later `invokeTool` still runs the handler (`test/native_publisher_test.dart:764`); a valid string field is decoded once (`test/registry_test.dart:327`); a nested schema object stays shared (`test/registry_test.dart:357`); `StateError` and oversized details become `handlerFailed` without the message or the blob (`test/native_publisher_test.dart:837`); the publisher returns the allowlisted JSON (`test/native_publisher_test.dart:818`); a throwing hook still leaves the tool invocable (`test/registry_test.dart:278`); abort on the no-op registration leaves the local tool invocable (`test/transport_selection_test.dart:138`); details that pass the size limit appear in the agent error and not in the log (`test/native_publisher_test.dart:825`); a handler-only page tool is invoked once (`test/page/webmcp_page_test.dart:1035`); both widget callbacks throw and register nothing (`test/widget_layer_test.dart:288`).

No skipped tests, widened assertions, or assertions that only restate the current output were found in the added tests.

## Findings

None.

## Recurrence check

- Previous round: `wiki/work/0016-user-facing-feature-opportunities/validation/impl-review-01.md`
- Recurring findings: none
- Oscillating: no

Round 01 recorded no findings. This round also records none. The previous verdict was not used as evidence.

## Routing

| Finding | Belongs to phase |
|---|---|
| none | — |
