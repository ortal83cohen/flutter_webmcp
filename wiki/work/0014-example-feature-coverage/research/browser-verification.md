# Research: How to build/run `example/` for web and verify registered WebMCP tools from a Chrome browser

## Question

How do you build and run `example/` as a Flutter web app so it opens in an external Chrome browser, and how do you verify from the browser (DevTools console / native WebMCP surface) that the app's registered tools actually round-trip a call?

## Answer

Run `cd example && flutter pub get && flutter run -d chrome` (or `flutter build web` + serve `example/build/web/`); the app serves on a Flutter-DevTools-assigned localhost port shown in the CLI output (not a fixed port unless `--web-port` is passed). The native publisher exposes tools on the same-origin `document.modelContext` object (not `window.navigator.modelContext`), detectable in the console via `!!document.modelContext`, and it is only present in Chrome 152+ launched with the experimental flags `--enable-features=WebMCP,WebMCPTesting --enable-experimental-web-platform-features` — a normal, unflagged installed Chrome does **not** expose it, per this repository's own recorded spike evidence. Because `flutter run -d chrome` and `flutter build web` serve over plain HTTP on `localhost`, and Chrome's WebMCP page-conformance evidence in this repo was only established over HTTPS with COOP/COEP isolation headers, whether the plain `flutter run -d chrome` dev server (no custom headers, HTTP not HTTPS) is sufficient for `document.modelContext` to appear is `[UNRESOLVED]`.

## Findings

### Build/run commands and serving URL

- Claim: The documented way to run the example on web is `cd example && flutter pub get && flutter run -d chrome`.
- Evidence: `README.md:606-612` — "From this repository, launch the example application: ```sh\ncd example\nflutter pub get\nflutter run -d chrome\n```".
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/README.md:606-612`

- Claim: `tools/check.sh` builds the example as a static site with `flutter build web` and asserts `example/build/web/index.html` exists; it does not run/serve the app.
- Evidence: `tools/check.sh:63-64` — `(cd example && flutter build web) || stage_failed 6 "build"` then `test -f example/build/web/index.html || stage_failed 6 "build"`.
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/tools/check.sh:63-64`

- Claim: A prior build already exists at `example/build/web/` (index.html, main.dart.js, flutter_bootstrap.js, canvaskit assets, etc.), so a static build artifact is already present in this checkout without this investigation building anything.
- Evidence: directory listing of `example/build/web/**` shows `index.html`, `flutter_bootstrap.js`, `main.dart.js`, `flutter.js`, `canvaskit/*`, `assets/*`.
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/build/web/index.html` (and sibling files, same directory)

- Claim: `flutter run -d chrome` does not pin a fixed port by default; Flutter's tooling picks/reports an ephemeral localhost port in its CLI output (e.g. `http://localhost:<port>`) unless `--web-port` is explicitly passed. The exact port for this environment cannot be determined without actually running the command.
- Evidence: `[UNVERIFIED: exact port number]` — no `--web-port` argument is configured anywhere in this repo (`example/pubspec.yaml`, `README.md`, `tools/check.sh` show no such flag), and this investigation is read-only and did not execute `flutter run`.
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/pubspec.yaml:1-22` (no web-port config); general Flutter CLI behavior is `[UNVERIFIED]` here because it was not run.

- Claim: `example/web/index.html` is a minimal Flutter web bootstrap page with no custom script that exposes anything beyond stock Flutter web bootstrapping (`flutter_bootstrap.js`).
- Evidence: full file content — `<script src="flutter_bootstrap.js" async></script>`, no other injected script.
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/web/index.html:12`

- Claim: Flutter CLI availability on this machine and whether `flutter`/`dart` are installed could not be checked in this investigation.
- Evidence: this subagent was given `Read`, `WebSearch`, `WebFetch`, `Grep`, `Glob`, `Write` tools only; no shell/Bash execution tool (`which`, `--version`) was available to it, despite the parent prompt asking for it.
- Source: `[UNVERIFIED: flutter/dart CLI availability — no shell tool was available to this subagent to run `which flutter` or `flutter --version`]`

### What JS-visible surface the native publisher exposes

- Claim: The native publisher's browser boundary checks for and registers tools on `document.modelContext` (a property of the page's `document` object), **not** `window.navigator.modelContext` or any `window.*` property.
- Evidence: `_modelContext` getter checks `document.hasProperty('modelContext'.toJS)` and reads `document.getProperty<JSObject?>('modelContext'.toJS)`; `registerTool` calls `_ModelContext(rawModelContext).registerTool(definition, options)`.
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/lib/src/transport/native_publisher_boundary_web.dart:26-31,42-51,75-77`

- Claim: A second, independent piece of code (`WebDetectionTransport`, the default local transport, distinct from the native publisher) performs the same same-origin detection at startup and logs a `developer.log` message named `webmcp_flutter` recording whether `modelContext` was detected — this is visible in Flutter's own debug console/DevTools log, not necessarily the browser JS console.
- Evidence: `_isAvailable = document.hasProperty('modelContext'.toJS).toDart` then `_write('modelContext detected: $_isAvailable; tools not published')` via `developer.log(message, name: 'webmcp_flutter')`.
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/lib/src/transport/transport_web.dart:17-20,45-47`

- Claim: The tool registration definition passed to `document.modelContext.registerTool(definition, options)` has shape `{name, description, inputSchema, annotations: {readOnlyHint, untrustedContentHint, consequentialHint}, execute}`, and `options` is `{signal: AbortController.signal}` — this is the exact shape Chrome's native surface expects and is what a console call to `document.modelContext.getTools()` (Chrome API, not defined in this repo) should surface back.
- Evidence: object literal construction of `definition` and `options` before calling `.registerTool(...)`.
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/lib/src/transport/native_publisher_boundary_web.dart:57-77`

- Claim: `document.modelContext.registerTool` / `getTools` / `executeTool` are Chrome-native APIs; this repository only calls into them via `dart:js_interop`/`package:web` — it does not implement or polyfill `modelContext` itself. Whether `getTools()`/`executeTool()` exist as named methods on `document.modelContext` is asserted by this repo's own conformance notes (see below), consistent with the extension type `_ModelContext` only declaring `registerTool` because that is the only method this library calls.
- Evidence: `extension type _ModelContext(JSObject _) implements JSObject { external JSPromise<JSAny?> registerTool(...); }` — only `registerTool` is declared/used by the Dart side; `getTools`/`executeTool` are referenced only in prose evidence documents, not in this library's Dart code.
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/lib/src/transport/native_publisher_boundary_web.dart:14-19`; cross-reference `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/wiki/work/0008-automatic-page-agent/05-transport-spike.md:13-22` (mentions `document.modelContext.getTools()` and `executeTool()` as the Chrome-native methods used by page-conformance evidence, external to this repo's Dart code).

- Claim: Each registered tool's `execute` callback, when invoked from the native surface, JSON-decodes the input via `dartify()`, calls the local `WebMcpTool.handler`, and returns a JSON string (`.toDartify` → JS string) — either the encoded successful result or a safe JSON failure object `{"ok": false, "error": {"code": <reasonCode>, "retryable": <bool>}}`.
- Evidence: `_executeSafely` and `WebMcpNativePublisher._invoke`/`_safeFailure`.
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/lib/src/transport/native_publisher_boundary_web.dart:87-107`; `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/lib/src/transport/webmcp_native_publisher.dart:309-365`

### Example app's actual registered tool names

- Claim: The example app, once running, registers at minimum these tool names in the local `WebMcp.instance` registry, all of which the `WebMcpNativePublisher` in `main.dart` attempts to additively mirror to `document.modelContext` if detected:
  - `example.counter.read` — reads a counter (registered unconditionally at startup via `registerExampleTools`).
  - `example.counter.increment` — increments the counter (same source).
  - `example.screen.describe` — returns the literal string `'ExampleScreen'`, registered only while `ExampleScreen` is mounted (`WebMcpScreen.registerWebMcpTools`).
  - `example.screen.increment` — a `WebMcpAction`-wrapped tool bound to the on-screen Increment button, registered only while `ExampleScreen` is mounted.
- Evidence: `registerExampleTools` registers the first two; `_ExampleScreenState.registerWebMcpTools` registers `example.screen.describe`; the `WebMcpAction` widget in `build()` registers `example.screen.increment`.
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/lib/example_tools.dart:13-29`; `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/lib/example_screen.dart:28-37,68-79`

- Claim: The running app's own UI (a `Text(names)` widget) already lists every currently registered tool name on screen, which is a Flutter-rendered (not JS-console) way to confirm registration without touching DevTools.
- Evidence: `final String names = WebMcp.instance.tools.map((tool) => tool.name).join('\n'); ... Text(names)`.
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/lib/example_screen.dart:45-47,65-66`

- Claim: `main.dart` creates one `WebMcpNativePublisher()` and calls `await publisher.attach()` before `runApp`, and the visible `ExampleScreen` prints `widget.publisher.status.support.name` on screen — this on-screen text (`localOnly` / `browserDetected` / `conformanceUsable` / `failed`) is the app's own built-in signal of whether native publication is working, independent of the JS console.
- Evidence: `main.dart` publisher construction/attach; `example_screen.dart` `Text('Native publisher: ${widget.publisher.status.support.name}')`.
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/lib/main.dart:12-13`; `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/lib/example_screen.dart:59`

### Chrome/environment limitations affecting "a normal installed Chrome"

- Claim: `document.modelContext` is Chrome's own experimental, unshipped WebMCP surface; the repository's product contract explicitly warns "WebMCP is an experimental browser surface and may change. Property detection alone is not proof that the native API works."
- Evidence: direct quote.
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/wiki/product/webmcp-contract.md:118-119`

- Claim: The repository's own recorded conformance spike needed Chrome 152 launched headed with a **temporary user-data-dir** and explicit experimental flags: `--enable-features=WebMCP,WebMCPTesting --enable-experimental-web-platform-features --no-first-run --no-default-browser-check`. A configuration with only `--enable-features=WebMCPForTesting` was tried and returned `modelContext=false` (recorded as a failed launch configuration).
- Evidence: direct quote of the flag block and the failed-probe note.
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/wiki/work/0008-automatic-page-agent/05-transport-spike.md:98-113`

- Claim: This means a stock/default installed Chrome — opened normally, without these command-line flags — would not be expected to expose `document.modelContext` at all, based on this repository's own negative-probe evidence. `[UNVERIFIED: whether a later stable Chrome release ships WebMCP by default without flags — this repo's evidence is dated to Chrome 152.0.7977.83 and explicitly experimental]`.
- Evidence: inferred from the above two findings; not separately re-tested by this investigation (read-only boundary; no Chrome was launched).
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/wiki/work/0008-automatic-page-agent/05-transport-spike.md:47-64,98-113`

- Claim: The conformance evidence that did succeed was gathered over a secure, cross-origin-isolated **HTTPS** localhost fixture with COOP/COEP/`Origin-Agent-Cluster`/CORP/`X-Content-Type-Options`/`Cache-Control` headers set by a custom Python server — not the plain HTTP dev server that `flutter run -d chrome` starts by default.
- Evidence: header list and server description.
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/spikes/native-publisher/README.md:9-11`; `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/wiki/work/0008-automatic-page-agent/05-transport-spike.md:80-96`

- Claim: Because `flutter run -d chrome`'s default dev server does not set COOP/COEP/cross-origin-isolation headers and serves over `http://localhost` rather than a certificate-backed `https://localhost`, it is `[UNRESOLVED]` whether `document.modelContext` will actually appear when launching Chrome the normal way (even with the right `--enable-features` flags) against the plain `flutter run -d chrome` server, versus only against the hardened HTTPS fixture server used in the spike. This investigation did not run either server, per its read-only boundary.
- Evidence: comparison of the two serving setups; no direct test performed.
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/spikes/native-publisher/README.md:9-33` vs. `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/README.md:606-612`

- Claim: Even with `document.modelContext` detected and tools registered, this repository states that native-agent (real Gemini/model-selected) support "remains unproven" and that direct `executeTool()`/WebDriver calls (i.e. exactly the kind of manual console invocation this task asks another agent to perform) are page-conformance evidence only, never a substitute for authenticated natural-language model-selected invocation.
- Evidence: direct quote.
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/wiki/product/webmcp-contract.md:141-144`; `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/spikes/native-publisher/README.md:52-54`

- Claim: The example app targets a minimum of Flutter 3.47.0 / Dart 3.13.0 for web; other Flutter platforms are unsupported by this release.
- Evidence: direct quote.
- Source: `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/README.md:581-582`; consistent with `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/pubspec.yaml:6-7` (`sdk: ^3.13.0`).

## Options considered

| Option | How it works | Cost | Why rejected / chosen |
|---|---|---|---|
| `flutter run -d chrome` from `example/` | Flutter's own dev-server launches a debug build, opens a new Chrome window/tab, hot-reloads on file change; CLI prints the served URL and port at startup. | Requires the Flutter SDK installed; port is ephemeral unless `--web-port` given; plain HTTP, no COOP/COEP headers by default. | **Chosen for the "open in Chrome and interact live" recipe** — it is the exact command the repository's own `README.md:606-612` documents as the way to launch the example, so it is grounded rather than invented. |
| `flutter build web` + a static file server (e.g. `python3 -m http.server`) serving `example/build/web/` | Produces the same static site `tools/check.sh` already builds and validates (`example/build/web/index.html` already exists in this checkout); any static server can then serve it on a chosen port. | Requires a separate serving step; still HTTP unless the server is TLS-terminated; loses Flutter hot-reload/DevTools wiring. | **Offered as the build/verify-artifact alternative** — matches the CI-proven path in `tools/check.sh:63-64`, useful if `flutter run` is unavailable, but does not by itself open a browser or serve — a human/agent still has to pick a port and start a server. |
| The spike's hardened HTTPS localhost server with COOP/COEP/isolation headers (`spikes/native-publisher/`) | A bespoke Python HTTPS server with a locally generated one-day cert, explicit CORS/COOP/COEP/CORP/no-sniff/no-store headers. | Not part of `example/`; requires generating certs and running a separate fixture, out of scope for "example/" per this task. | Rejected as the recipe for `example/` (it is a different app under `spikes/`), but recorded because it is the only setup in this repo with confirmed positive `document.modelContext` evidence — flagging the header/HTTPS gap as a real risk to the `example/` recipe. |

## Constraints discovered

- The native surface property is `document.modelContext`, not `window.navigator.modelContext` or any other `window.*` path — any console check or invocation must target `document.modelContext`. Source: `lib/src/transport/native_publisher_boundary_web.dart:26-31`.
- `document.modelContext` is Chrome-experimental and, per this repo's own negative-probe evidence, was **absent** with only a partial feature flag (`WebMCPForTesting` alone); the working configuration required both `WebMCP` and `WebMCPTesting` features plus `--enable-experimental-web-platform-features`. A stock, unflagged Chrome install should not be assumed to expose it. Source: `wiki/work/0008-automatic-page-agent/05-transport-spike.md:98-113`.
- The only in-repo evidence of `document.modelContext` actually working was gathered over an isolated HTTPS localhost origin with COOP/COEP headers, not over the plain HTTP dev server `flutter run -d chrome` starts by default — this is a real, uninvestigated gap for the `example/` app specifically.
- Manual console invocation of a tool (via `document.modelContext.executeTool(...)` or similar) is valid page-conformance verification only; the repository explicitly disclaims it as native-agent proof. Any recipe another agent writes for "invoke a tool from the console" must be framed as page-conformance verification, not as proof that a real AI agent can use the tool.
- The example's tool set is small and lifecycle-scoped: `example.counter.read`/`example.counter.increment` are always registered from app start; `example.screen.describe`/`example.screen.increment` exist only while `ExampleScreen` is the mounted/visible screen (i.e., they disappear if the user navigates to "Open details" and reappear if they navigate back — the `_ExampleDetailsPage` in `example_screen.dart:99-117` registers no tools of its own).
- No fixed web port is configured for `example/` anywhere in the repo; the served URL/port must be read from the `flutter run -d chrome` CLI output at the time it is actually run — this investigation did not run it (read-only boundary) and could not observe an actual URL.
- No shell tool was available to this subagent to confirm `flutter`/`dart` CLI presence or version, despite the parent task requesting `which flutter` / `flutter --version` checks; this is reported as a hard capability gap for this specific investigation, not as evidence that Flutter is or isn't installed.

## Unresolved

- [UNRESOLVED: Whether the Flutter/Dart CLI (`flutter`, `dart`) is actually installed and its version on this machine — no shell/Bash tool was available to this subagent to run `which flutter` or `flutter --version`.]
- [UNRESOLVED: The exact local URL and port that `flutter run -d chrome` will print for `example/` on this machine — depends on runtime port allocation and was not observed because the command was not executed under this investigation's read-only boundary.]
- [UNRESOLVED: Whether `document.modelContext` appears at all when Chrome is launched with the working `--enable-features=WebMCP,WebMCPTesting --enable-experimental-web-platform-features` flags against the *plain* `flutter run -d chrome` HTTP dev server (no COOP/COEP/cross-origin-isolation headers), as opposed to the hardened HTTPS fixture server in `spikes/native-publisher/` where the only positive evidence in this repo was gathered.]
- [UNRESOLVED: Whether `document.modelContext.getTools()` and `.executeTool()` — the two Chrome-native methods referenced in the spike's prose evidence for reading tool names and invoking a tool from the console — are stable, documented method names on the current installed Chrome's `modelContext` object, since this repository's own Dart code only calls `.registerTool()` and never calls or type-declares `getTools`/`executeTool` itself.]
- [UNRESOLVED: Whether any Chrome version newer than the repo's tested 152.0.7977.83 ships WebMCP without the experimental flags, i.e. whether the flag requirement is still current as of today.]

## Sources

- `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/README.md` (consulted 2026-09-15)
- `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/tools/check.sh` (consulted 2026-09-15)
- `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/pubspec.yaml` (consulted 2026-09-15)
- `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/web/index.html` (consulted 2026-09-15)
- `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/lib/main.dart` (consulted 2026-09-15)
- `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/lib/example_screen.dart` (consulted 2026-09-15)
- `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/example/lib/example_tools.dart` (consulted 2026-09-15)
- `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/lib/src/transport/native_publisher_boundary_web.dart` (consulted 2026-09-15)
- `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/lib/src/transport/native_publisher_boundary.dart` (consulted 2026-09-15)
- `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/lib/src/transport/webmcp_native_publisher.dart` (consulted 2026-09-15)
- `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/lib/src/transport/webmcp_native_capabilities.dart` (consulted 2026-09-15)
- `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/lib/src/transport/transport_web.dart` (consulted 2026-09-15)
- `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/wiki/product/webmcp-contract.md` (consulted 2026-09-15)
- `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/wiki/work/0008-automatic-page-agent/05-transport-spike.md` (consulted 2026-09-15)
- `/Users/ortalcohen/Documents/GitHub/flutter_webmcp/spikes/native-publisher/README.md` (consulted 2026-09-15)
- `example/build/web/` directory listing (consulted 2026-09-15) — evidence a prior build already exists in this checkout.
