# KickNext `flutter_webmcp` 0.3.0 source comparison

Reviewed 2026-09-10. This is a planning input, not a parity requirement. The first
`webmcp_flutter` release remains a detection-first local registry: no browser bridge
expansion is proposed here.

## Compared snapshots and acquisition evidence

- Local: the working-tree `lib/**` and tests at repository HEAD
  `dccbad724308ce93f75fb95580282b18292ad0df`. The tree is modified, so that commit
  is context rather than an exact content identity. A sorted `lib/` + `test/`
  path/content manifest produced SHA-256
  `b65729c6b6ff9fdc87312353de9a5d2c563d57d0b14d412156caeab58bae8b8a`.
- Published comparison: pub.dev package `flutter_webmcp` version `0.3.0`, published
  `2026-09-04T03:19:26.398829Z`. The API-declared and locally calculated archive
  SHA-256 both equal
  `e4e7b513c84a6a51267605bd2cbc5f3df4a7e33307a77618b927f443448f22c6`.
- The upstream GitHub tag `v0.3.0` resolves to commit
  `f5915039991072291c674e0780e0b85bd7c9c5f7`. Recursive comparison found no
  difference between the tag and pub archive for `lib/**`, `test/**`, or
  `pubspec.yaml`.
- Reproduction: fetch the [pub API](https://pub.dev/api/packages/flutter_webmcp),
  select version `0.3.0`, download its returned
  [archive](https://pub.dev/api/archives/flutter_webmcp-0.3.0.tar.gz), list it with
  `tar -tzf` before extraction, calculate `shasum -a 256`, then compare `lib`,
  `test`, and `pubspec.yaml` with the
  [GitHub v0.3.0 tag](https://github.com/KickNext/flutter_webmcp/tree/v0.3.0).
  All downloads and extraction used a disposable `/private/tmp` directory.

`K:` references below mean the verified 0.3.0 archive. Line numbers are stable
against the tag above. Absence claims are limited to the listed local and upstream
`lib/**` files and their tests; examples, README claims, and historical summaries
are not treated as implementation evidence.

## Capability matrix

| Area | Local `webmcp_flutter` 0.1.0 | KickNext 0.3.0 | Release classification |
|---|---|---|---|
| Registration | Process-wide singleton validates a name, stores a descriptor, and notifies a pluggable transport (`lib/src/webmcp.dart:9-39`). Sources batch descriptors (`:35-40`). | Static API validates then begins platform registration and returns an async handle (`K:lib/src/webmcp.dart:12-79`); browser adapter calls `document.modelContext.registerTool` (`K:lib/src/platform/platform_web.dart:44-109`). | **Supported locally** for in-process registration. Browser publication is **deliberately deferred**. |
| Removal and invocation | Removal is synchronous by name; invocation looks up the local map and awaits a `FutureOr` handler (`lib/src/webmcp.dart:42-71`; `lib/src/webmcp_tool.dart:4-7`). Tests cover duplicate preservation, awaited invocation, missing names, and idempotent removal (`test/registry_test.dart:50-115`). | Registration and pending-attempt handles unregister/cancel once (`K:lib/src/webmcp_registration.dart:3-22`; `K:lib/src/webmcp_registration_attempt.dart:5-41`). Agent invocation enters through the browser callback (`K:lib/src/platform/platform_web.dart:112-165`). | **Supported locally** for app/test invocation. Pending registration and browser invocation are **deliberately deferred**. |
| Descriptor and schema | Descriptor has name, description, copied shallow-immutable schema, and handler (`lib/src/webmcp_tool.dart:9-31`). Registration validates only name syntax (`lib/src/webmcp.dart:18,23-33`). | Adds title, safety annotations, execution context, and typed input decoder (`K:lib/src/webmcp_tool.dart:5-79`); validates nonblank description, origin-shaped `exposedTo`, and JSON-encodable schema (`K:lib/src/webmcp.dart:45-79`). | Core descriptor is **supported locally**. Title, typed decoder, annotations, and wire-oriented validation are **deliberately deferred** with the bridge. Local schema is only JSON-schema-like; do not claim wire validity. |
| Results and errors | Registry/widget exceptions identify invalid, duplicate, missing, and unscoped tools (`lib/src/webmcp_exceptions.dart:1-45`). Handler values and errors pass through unchanged (`lib/src/webmcp.dart:61-71`). | Result helpers provide text, structured, raw JSON, and agent-safe error envelopes (`K:lib/src/webmcp_result.dart:1-50`). Expected errors are serialized, unexpected details are hidden, and all results are JSON checked (`K:lib/src/platform/platform_web.dart:117-165`; `K:lib/src/webmcp_exception.dart:18-41`). | Local registry errors are **supported locally**. Agent wire envelopes and privacy filtering are **deliberately deferred**. Raw local results must not be represented as browser-safe MCP results. |
| Async and cancellation | Async handlers are awaited, but handlers receive only arguments and no cancellation context (`lib/src/webmcp.dart:61-71`; `lib/src/webmcp_tool.dart:4-7`). | Registration may be synchronous or Promise-based; AbortController cancels pending registration and invocation context exposes agent cancellation (`K:lib/src/platform/platform_web.dart:49-109,112-126`; `K:test/webmcp_browser_test.dart:150-228`). | Async app handlers are **supported locally**. Registration/invocation cancellation is **deliberately deferred**. |
| Scopes and widgets | `WebMcpScope` tracks ownership, skips duplicate owners, and closes idempotently (`lib/src/webmcp_scope.dart:9-88`). `WebMcpScreen` owns a scope for a State lifetime; `WebMcpAction` registers an unchanged child and removes only its owned name (`lib/src/widgets/webmcp_screen.dart:5-40`; `lib/src/widgets/webmcp_action.dart:10-81`). | `WebMcpToolScope` reconciles a list post-frame across tool identity, enabled state, adapter, support check, and origin exposure; it cancels changed/disposed slots and reports errors (`K:lib/src/flutter/webmcp_tool_scope.dart:14-178,189-248`). | Explicit screen/action ownership is **supported locally** and is a meaningful local capability. Dynamic list reconciliation and enable toggling are **deliberately deferred**. |
| Mounted widget updates | A mounted action keeps its original registered name/schema/description; only the closure observes the newest callback (`lib/src/widgets/webmcp_action.dart:49-69`). The behavior is asserted explicitly (`test/widget_layer_test.dart:109-139`). | Changed descriptor identity or exposure cancels and replaces its slot (`K:lib/src/flutter/webmcp_tool_scope.dart:63-119,195-223`). | **Uncertain product constraint**, not proven bug: document immutable-while-mounted semantics for 0.1.0 or plan reconciliation later. Do not silently imply Flutter prop updates republish metadata. |
| Browser detection and transport | Conditional selection uses a no-op VM transport or browser detection transport (`lib/src/transport/transport_selector.dart:1`; `lib/src/transport/transport_noop.dart:4-19`). Web detection checks `document.modelContext`, then only logs “tools not published” (`lib/src/transport/transport_web.dart:10-38`; `test/transport_web_source_test.dart:5-11`). No public support-status API exists in reviewed local exports (`lib/webmcp_flutter.dart:1-8`). | Distinguishes unsupported platform, insecure context, missing browser API, and supported (`K:lib/src/webmcp_support.dart:1-31`; `K:lib/src/platform/platform_web.dart:19-42`), then publishes tools. | Detection-first behavior is **supported locally by design**. Detailed status and browser bridge are **deliberately deferred**. Current spec also places the entry point at `Document.modelContext`; KickNext is third-party implementation evidence, not the specification ([WebMCP draft section 4.1](https://webmachinelearning.github.io/webmcp/#dom-document-modelcontext), accessed 2026-09-10). |
| Exposure and safety hints | No `exposedTo`, read-only/untrusted-content annotation, result privacy boundary, or completed-call logger appears in reviewed local `lib/**` exports (`lib/webmcp_flutter.dart:1-8`; `lib/src/webmcp_tool.dart:9-31`). | Origins flow into registration options (`K:lib/src/platform/platform_web.dart:83-86,215-221`); hints map to browser annotations (`:68-81,206-213`); logger captures status, duration, local error, and stack (`K:lib/src/webmcp_logging.dart:1-57`). | **Deliberately deferred** with browser publication. Before any future bridge, origin validation, safe error conversion, JSON serialization, and logging privacy require explicit criteria. |
| Lifecycle edge | `reset` clears the registry and swaps transport without unregister notifications (`lib/src/webmcp.dart:73-77`). Registration inserts before notifying transport, so a throwing custom transport can leave the tool stored (`lib/src/webmcp.dart:23-33`). Current built-ins do not throw (`lib/src/transport/transport_noop.dart:15-19`; `lib/src/transport/transport_web.dart:26-34`). | Handles make cleanup idempotent; widget reconciliation observes async registration and cleanup failures (`K:lib/src/webmcp_registration.dart:14-22`; `K:lib/src/flutter/webmcp_tool_scope.dart:121-175,200-240`). | **Bug/uncertain contract** for custom transports. Before documenting `WebMcpTransport` as a supported extension point, define notification failure atomicity and reset cleanup; this does not require browser bridge expansion. |

## Planning consequence

The verified comparison closes the prerequisite without turning KickNext into a
parity target. Release 0.1.0 can accurately promise a deterministic local registry,
direct async invocation, ownership-safe scopes, explicit Flutter wrappers, and
browser capability detection. It must state that tools are not published to browser
agents. The only local follow-up worth deciding before release is the custom
transport lifecycle contract; richer registration handles, wire results, exposure
origins, annotations, cancellation, and browser execution belong to a later bridge
work item.
