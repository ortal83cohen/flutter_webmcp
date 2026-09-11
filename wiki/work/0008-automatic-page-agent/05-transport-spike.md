# Chrome-only WebMCP transport spike

## Scope and evidence classes

This artifact executes baseline task 1.2 and observation task O1.2 only. It
tests Chrome 152 `document.modelContext` on a secure, cross-origin-isolated
Flutter fixture compiled to JavaScript and WebAssembly.

Evidence is split into two classes:

- **Page-conformance evidence** is produced by real headed Google Chrome using
  `document.modelContext.getTools()` and `executeTool()`. ChromeDriver only
  opens the page and retrieves the fixture's result records. This evidence
  cannot satisfy native-agent AC-014/O1.2 by itself.
- **Native-agent evidence** requires the required
  `beaufortfrancois/model-context-tool-inspector` extension, Gemini
  authentication, a natural-language prompt, agent-selected tools, and a
  discover/observe/act/navigate/observe trace. Manual execution, WebDriver,
  CDP, and direct in-page `executeTool()` never count as native-agent proof.

Property detection was not treated as evidence. Every page verdict below
followed successful registration and actual `getTools()`/`executeTool()` calls.

## Overall verdict

**FAIL**

Two independent blockers prevent the transport gate from passing:

1. The corrected cancellation run first proved that the execute callback
   started, then aborted the caller and waited 900 ms for a callback configured
   to complete after 600 ms. In both JavaScript and WebAssembly,
   `started=true`, no callback signal was supplied, no abort was observed, and
   the callback completed its synthetic side effect:
   `signalProvided=false signalObserved=false completed=true sideEffects=1`.
   This is valid AC-002/AC-011 cancellation-propagation gate evidence. It does
   not rely on the earlier callback-not-started result.
2. The required extension was installed into an isolated temporary Chrome
   profile with exact ID `gbpdfapgefenggkahomfgkhfehlcenpd` and version
   `1.9.15`, but the profile had no Gemini API key. The natural-language prompt
   control was disabled, so no Gemini agent invocation occurred. Per the
   requested proof rule, AC-014/O1.2 is FAIL.

No native publisher interface may freeze and no automatic WebMCP shipping claim
is supported by this spike.

## Exact environment

```text
$ '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' --version
Google Chrome 152.0.7977.83

$ /tmp/flutter-3.47.0-page-semantics/bin/flutter --version
Flutter 3.47.0 • channel [user-branch] • https://github.com/flutter/flutter.git
Framework • revision 4cf2416426 (4 weeks ago) • 2026-08-11 11:53:49 -0700
Engine • hash 59d54a2b2896a6bbf356c94b7fac7b9e235bdacd (revision 5f77625673) (29 days ago) • 2026-08-11 16:38:36.000Z
Tools • Dart 3.13.0 • DevTools 2.60.0

$ /tmp/flutter-3.47.0-page-semantics/bin/dart --version
Dart SDK version: 3.13.0 (stable) (Wed Aug 5 00:28:05 2026 -0700) on "macos_arm64"

$ chromedriver --version
ChromeDriver 152.0.7977.83 (79460ebecaa5625e57a5fb679a735659e73dc687-refs/branch-heads/7977@{#2323})
```

The extension evidence used the Chrome Web Store CRX for the required ID.

```text
Extension name: WebMCP - Model Context Tool Inspector
Extension ID: gbpdfapgefenggkahomfgkhfehlcenpd
Extension version: 1.9.15
Source revision: c0f71387aa015a65fb67eccefa3bd27342ef4a8c
CRX SHA-256: f87e0f3d707aefc0a46cc96c7165974c6780cf0ef8cc653137bdf08f932699bd
```

The official repository's own disclaimer says the extension is not an
officially supported Google product. It is nevertheless the exact extension
and ID required for this gate.

## Secure fixture and launch controls

The fixture is `spikes/native-publisher/`. Flutter owns the visible state and
Dart callbacks; `web/webmcp_fixture.js` performs the native WebMCP interop. The
same source is compiled as JavaScript and Wasm.

The local server uses a one-day synthetic localhost certificate and these
response headers:

```text
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
Origin-Agent-Cluster: ?1
Cross-Origin-Resource-Policy: same-origin
X-Content-Type-Options: nosniff
Cache-Control: no-store
```

Chrome was headed and used a newly created temporary `--user-data-dir` on every
run. The normal Chrome profile was never supplied, read, or modified. Effective
feature flags were:

```text
--enable-features=WebMCP,WebMCPTesting
--enable-experimental-web-platform-features
--no-first-run
--no-default-browser-check
```

An initial headed/headless probe with only
`--enable-features=WebMCPForTesting` returned
`modelContext=false`. It is recorded as a failed launch configuration, not as
browser support evidence. The required extension's own end-to-end source uses
the documented `WebMCP,WebMCPTesting` pair.

## Build commands and raw output

```text
$ /tmp/flutter-3.47.0-page-semantics/bin/flutter build web --release --output=build/web-js
Compiling lib/main.dart for the Web...
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Compiling lib/main.dart for the Web...                             24.7s
✓ Built build/web-js

$ /tmp/flutter-3.47.0-page-semantics/bin/flutter build web --release --wasm --output=build/web-wasm
Compiling lib/main.dart for the Web...                           2,316ms
✓ Built build/web-wasm
```

Both runs used this page command, changing only `--build-dir`:

```text
$ python3 tool/run_page_conformance.py \
    --chrome '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' \
    --chromedriver /tmp/chromedriver-spike/chromedriver/mac_arm-152.0.7977.83/chromedriver-mac-arm64/chromedriver \
    --build-dir build/web-js \
    --cert .cert/localhost-cert.pem \
    --key .cert/localhost-key.pem
```

## Page-conformance verdicts

The following verdicts were identical for JavaScript and Wasm.

- `secure-functional-surface`: **PASS** — `secure=true isolated=true`; all
  three native methods existed and were then exercised.
- `origin-isolation`: **PASS** — page origin and every returned fixture tool
  origin were exactly `https://localhost:8443`.
- `registration-gettools`: **PASS** — seven registered fixture tools were
  returned alphabetically and their schemas round-tripped.
- `annotations`: **PASS** — the read-only annotation returned true and no
  unsafe/consequential true value appeared. Chrome omitted the false
  `consequentialHint`, so consumers must treat absent optional false hints as
  false.
- `execute-json-string`: **PASS** — a JSON-string input invoked the Dart-owned
  counter once and returned
  `{"ok":true,"counter":1,"evidence":"visibleEffectObserved"}`.
- `invalid-input-no-dispatch`: **PASS** — malformed JSON rejected and the
  counter remained one.
- `safe-results-errors`: **PASS** — bounded JSON values and sanitized
  `syntheticFailure` were returned with no stack or secret.
- `execute-cancellation-after-start`: **FAIL** — the callback synchronously
  recorded `started=true`; Chrome supplied no callback signal, the caller
  rejected with `AbortError`, and the callback still completed its timer and
  synthetic side effect.
- `cancel-before-dispatch`: **PASS** — an already-aborted caller signal rejected
  with `AbortError: Execution cancelled.` while callback start, completion, and
  side effects all remained false/zero.
- `abortsignal-unregistration`: **PASS** — the temporary tool was present
  before registration-controller abort and absent afterward.
- `observe-immediate-polling`: **PASS** — `waitMs:0` returned current metadata;
  a positive wait returned `unsupportedWait` and advertised immediate polling.
- `cursor-gap-remount`: **PASS** — remount plus ring eviction returned
  `gap=true`, `refreshRequired=true`, a current cursor, and only the current
  active scope reference.
- `navigation-receipt-observe`: **PASS** — the admitted mount was two, the
  returned app-owned `commandDispatched` receipt named current mount three,
  and an immediate observe returned page `details` at mount three.

### Superseded pre-correction raw results

The following two raw blocks are retained as diagnostic history only. Their
fixed-50-ms cancellation result did not prove callback start and is superseded
by the bounded start-aware rerun below. It is not evidence of failed
propagation.

JavaScript pre-correction raw result:

```text
PAGE_EVIDENCE={"done": true, "isolated": true, "modelContext": true, "results": [{"detail": "secure=true isolated=true", "name": "secure-functional-surface", "verdict": "PASS"}, {"detail": "page=https://localhost:8443 tools=[\"https://localhost:8443\"]", "name": "origin-isolation", "verdict": "PASS"}, {"detail": "count=7 sorted=true", "name": "registration-gettools", "verdict": "PASS"}, {"detail": "{\"readOnlyHint\":true,\"untrustedContentHint\":false}", "name": "annotations", "verdict": "PASS"}, {"detail": "{\"ok\":true,\"counter\":1,\"evidence\":\"visibleEffectObserved\"}", "name": "execute-json-string", "verdict": "PASS"}, {"detail": "rejected=true counter=1", "name": "invalid-input-no-dispatch", "verdict": "PASS"}, {"detail": "{\"safeResult\":{\"ok\":true,\"values\":[\"alpha\",7,true,null],\"nonFiniteValue\":null},\"safeError\":{\"ok\":false,\"error\":{\"code\":\"syntheticFailure\",\"retryable\":false}}}", "name": "safe-results-errors", "verdict": "PASS"}, {"detail": "signalObserved=false completed=false rejected=false result=undefined", "name": "execute-cancellation", "verdict": "FAIL"}, {"detail": "before=true after=false", "name": "abortsignal-unregistration", "verdict": "PASS"}, {"detail": "{\"firstObserve\":{\"ok\":true,\"appCursor\":\"3eb930cb-10c3-472e-9f5a-91e6a54ac5bf:2\",\"gap\":false,\"refreshRequired\":false,\"active\":[{\"ref\":\"scope-1\",\"page\":\"home\",\"mount\":1}],\"events\":[{\"sequence\":1,\"kind\":\"scopeMounted\"},{\"sequence\":2,\"kind\":\"visibleEffectObserved\"}],\"capabilities\":{\"immediatePolling\":true,\"positiveWait\":false}},\"unsupportedWait\":{\"ok\":false,\"error\":{\"code\":\"unsupportedWait\"},\"capabilities\":{\"immediatePolling\":true,\"positiveWait\":false}}}", "name": "observe-immediate-polling", "verdict": "PASS"}, {"detail": "{\"ok\":true,\"appCursor\":\"3eb930cb-10c3-472e-9f5a-91e6a54ac5bf:7\",\"gap\":true,\"refreshRequired\":true,\"active\":[{\"ref\":\"scope-2\",\"page\":\"home\",\"mount\":2}],\"events\":[],\"capabilities\":{\"immediatePolling\":true,\"positiveWait\":false}}", "name": "cursor-gap-remount", "verdict": "PASS"}, {"detail": "{\"navigation\":{\"ok\":true,\"receipt\":{\"status\":\"commandDispatched\",\"admittedMount\":2,\"currentMount\":3}},\"afterNavigation\":{\"ok\":true,\"appCursor\":\"3eb930cb-10c3-472e-9f5a-91e6a54ac5bf:8\",\"gap\":false,\"refreshRequired\":false,\"active\":[{\"ref\":\"scope-3\",\"page\":\"details\",\"mount\":3}],\"events\":[{\"sequence\":5,\"kind\":\"scopeChanged\"},{\"sequence\":6,\"kind\":\"scopeChanged\"},{\"sequence\":7,\"kind\":\"scopeChanged\"},{\"sequence\":8,\"kind\":\"commandDispatched\"}],\"capabilities\":{\"immediatePolling\":true,\"positiveWait\":false}}}", "name": "navigation-receipt-observe", "verdict": "PASS"}], "secure": true}
RuntimeError: Page conformance failures: [{'detail': 'signalObserved=false completed=false rejected=false result=undefined', 'name': 'execute-cancellation', 'verdict': 'FAIL'}]
```

Wasm pre-correction raw result:

```text
127.0.0.1 - - [10/Sep/2026 20:18:15] "GET /main.dart.mjs HTTP/1.1" 200 -
127.0.0.1 - - [10/Sep/2026 20:18:15] "GET /main.dart.wasm HTTP/1.1" 200 -
PAGE_EVIDENCE={"done": true, "isolated": true, "modelContext": true, "results": [{"detail": "secure=true isolated=true", "name": "secure-functional-surface", "verdict": "PASS"}, {"detail": "page=https://localhost:8443 tools=[\"https://localhost:8443\"]", "name": "origin-isolation", "verdict": "PASS"}, {"detail": "count=7 sorted=true", "name": "registration-gettools", "verdict": "PASS"}, {"detail": "{\"readOnlyHint\":true,\"untrustedContentHint\":false}", "name": "annotations", "verdict": "PASS"}, {"detail": "{\"ok\":true,\"counter\":1,\"evidence\":\"visibleEffectObserved\"}", "name": "execute-json-string", "verdict": "PASS"}, {"detail": "rejected=true counter=1", "name": "invalid-input-no-dispatch", "verdict": "PASS"}, {"detail": "{\"safeResult\":{\"ok\":true,\"values\":[\"alpha\",7,true,null],\"nonFiniteValue\":null},\"safeError\":{\"ok\":false,\"error\":{\"code\":\"syntheticFailure\",\"retryable\":false}}}", "name": "safe-results-errors", "verdict": "PASS"}, {"detail": "signalObserved=false completed=false rejected=false result=undefined", "name": "execute-cancellation", "verdict": "FAIL"}, {"detail": "before=true after=false", "name": "abortsignal-unregistration", "verdict": "PASS"}, {"detail": "{\"firstObserve\":{\"ok\":true,\"appCursor\":\"cc0560e5-9a94-4a4c-8b82-14f3e8181760:2\",\"gap\":false,\"refreshRequired\":false,\"active\":[{\"ref\":\"scope-1\",\"page\":\"home\",\"mount\":1}],\"events\":[{\"sequence\":1,\"kind\":\"scopeMounted\"},{\"sequence\":2,\"kind\":\"visibleEffectObserved\"}],\"capabilities\":{\"immediatePolling\":true,\"positiveWait\":false}},\"unsupportedWait\":{\"ok\":false,\"error\":{\"code\":\"unsupportedWait\"},\"capabilities\":{\"immediatePolling\":true,\"positiveWait\":false}}}", "name": "observe-immediate-polling", "verdict": "PASS"}, {"detail": "{\"ok\":true,\"appCursor\":\"cc0560e5-9a94-4a4c-8b82-14f3e8181760:7\",\"gap\":true,\"refreshRequired\":true,\"active\":[{\"ref\":\"scope-2\",\"page\":\"home\",\"mount\":2}],\"events\":[],\"capabilities\":{\"immediatePolling\":true,\"positiveWait\":false}}", "name": "cursor-gap-remount", "verdict": "PASS"}, {"detail": "{\"navigation\":{\"ok\":true,\"receipt\":{\"status\":\"commandDispatched\",\"admittedMount\":2,\"currentMount\":3}},\"afterNavigation\":{\"ok\":true,\"appCursor\":\"cc0560e5-9a94-4a4c-8b82-14f3e8181760:8\",\"gap\":false,\"refreshRequired\":false,\"active\":[{\"ref\":\"scope-3\",\"page\":\"details\",\"mount\":3}],\"events\":[{\"sequence\":5,\"kind\":\"scopeChanged\"},{\"sequence\":6,\"kind\":\"scopeChanged\"},{\"sequence\":7,\"kind\":\"scopeChanged\"},{\"sequence\":8,\"kind\":\"commandDispatched\"}],\"capabilities\":{\"immediatePolling\":true,\"positiveWait\":false}}}", "name": "navigation-receipt-observe", "verdict": "PASS"}], "secure": true}
RuntimeError: Page conformance failures: [{'detail': 'signalObserved=false completed=false rejected=false result=undefined', 'name': 'execute-cancellation', 'verdict': 'FAIL'}]
EXPECTED_GATE_STATUS js=1 wasm=1
```

### Corrected start-aware raw results

The callback sets `cancellationStarted` synchronously before inspecting the
optional execution context. The runner polls at 10-ms intervals for at most two
seconds. Only after observed start does it abort, settle the caller, and wait
900 ms, which exceeds the callback's 600-ms completion timer. The separate
before-dispatch case aborts its signal before calling `executeTool()` and waits
the same 900-ms observation window.

The complete `CASE_EVIDENCE` sequence below was identical in headed Chrome 152
for the release JavaScript and Wasm builds, apart from generated cursor UUIDs:

```text
CASE_EVIDENCE={"detail": "secure=true isolated=true", "name": "secure-functional-surface", "verdict": "PASS"}
CASE_EVIDENCE={"detail": "page=https://localhost:8443 tools=[\"https://localhost:8443\"]", "name": "origin-isolation", "verdict": "PASS"}
CASE_EVIDENCE={"detail": "count=7 sorted=true", "name": "registration-gettools", "verdict": "PASS"}
CASE_EVIDENCE={"detail": "{\"readOnlyHint\":true,\"untrustedContentHint\":false}", "name": "annotations", "verdict": "PASS"}
CASE_EVIDENCE={"detail": "{\"ok\":true,\"counter\":1,\"evidence\":\"visibleEffectObserved\"}", "name": "execute-json-string", "verdict": "PASS"}
CASE_EVIDENCE={"detail": "rejected=true counter=1", "name": "invalid-input-no-dispatch", "verdict": "PASS"}
CASE_EVIDENCE={"detail": "{\"safeResult\":{\"ok\":true,\"values\":[\"alpha\",7,true,null],\"nonFiniteValue\":null},\"safeError\":{\"ok\":false,\"error\":{\"code\":\"syntheticFailure\",\"retryable\":false}}}", "name": "safe-results-errors", "verdict": "PASS"}
CASE_EVIDENCE={"detail": "started=true signalProvided=false signalObserved=false completed=true sideEffects=1 settlement={\"settled\":true,\"fulfilled\":false,\"error\":\"AbortError: signal is aborted without reason\"}", "name": "execute-cancellation-after-start", "verdict": "FAIL"}
CASE_EVIDENCE={"detail": "started=false signalProvided=false signalObserved=false completed=false sideEffects=0 settlement={\"settled\":true,\"fulfilled\":false,\"error\":\"AbortError: Execution cancelled.\"}", "name": "cancel-before-dispatch", "verdict": "PASS"}
CASE_EVIDENCE={"detail": "before=true after=false", "name": "abortsignal-unregistration", "verdict": "PASS"}
CASE_EVIDENCE={"detail": "{\"firstObserve\":{\"ok\":true,\"appCursor\":\"79e5a576-e5ea-4a66-8ef8-fe95d91d8353:2\",\"gap\":false,\"refreshRequired\":false,\"active\":[{\"ref\":\"scope-1\",\"page\":\"home\",\"mount\":1}],\"events\":[{\"sequence\":1,\"kind\":\"scopeMounted\"},{\"sequence\":2,\"kind\":\"visibleEffectObserved\"}],\"capabilities\":{\"immediatePolling\":true,\"positiveWait\":false}},\"unsupportedWait\":{\"ok\":false,\"error\":{\"code\":\"unsupportedWait\"},\"capabilities\":{\"immediatePolling\":true,\"positiveWait\":false}}}", "name": "observe-immediate-polling", "verdict": "PASS"}
CASE_EVIDENCE={"detail": "{\"ok\":true,\"appCursor\":\"79e5a576-e5ea-4a66-8ef8-fe95d91d8353:7\",\"gap\":true,\"refreshRequired\":true,\"active\":[{\"ref\":\"scope-2\",\"page\":\"home\",\"mount\":2}],\"events\":[],\"capabilities\":{\"immediatePolling\":true,\"positiveWait\":false}}", "name": "cursor-gap-remount", "verdict": "PASS"}
CASE_EVIDENCE={"detail": "{\"navigation\":{\"ok\":true,\"receipt\":{\"status\":\"commandDispatched\",\"admittedMount\":2,\"currentMount\":3}},\"afterNavigation\":{\"ok\":true,\"appCursor\":\"79e5a576-e5ea-4a66-8ef8-fe95d91d8353:8\",\"gap\":false,\"refreshRequired\":false,\"active\":[{\"ref\":\"scope-3\",\"page\":\"details\",\"mount\":3}],\"events\":[{\"sequence\":5,\"kind\":\"scopeChanged\"},{\"sequence\":6,\"kind\":\"scopeChanged\"},{\"sequence\":7,\"kind\":\"scopeChanged\"},{\"sequence\":8,\"kind\":\"commandDispatched\"}],\"capabilities\":{\"immediatePolling\":true,\"positiveWait\":false}}}", "name": "navigation-receipt-observe", "verdict": "PASS"}
```

The final raw cancellation lines, including build-specific runs, were:

```text
JavaScript:
CASE_EVIDENCE={"detail": "started=true signalProvided=false signalObserved=false completed=true sideEffects=1 settlement={\"settled\":true,\"fulfilled\":false,\"error\":\"AbortError: signal is aborted without reason\"}", "name": "execute-cancellation-after-start", "verdict": "FAIL"}
CASE_EVIDENCE={"detail": "started=false signalProvided=false signalObserved=false completed=false sideEffects=0 settlement={\"settled\":true,\"fulfilled\":false,\"error\":\"AbortError: Execution cancelled.\"}", "name": "cancel-before-dispatch", "verdict": "PASS"}

Wasm:
CASE_EVIDENCE={"detail": "started=true signalProvided=false signalObserved=false completed=true sideEffects=1 settlement={\"settled\":true,\"fulfilled\":false,\"error\":\"AbortError: signal is aborted without reason\"}", "name": "execute-cancellation-after-start", "verdict": "FAIL"}
CASE_EVIDENCE={"detail": "started=false signalProvided=false signalObserved=false completed=false sideEffects=0 settlement={\"settled\":true,\"fulfilled\":false,\"error\":\"AbortError: Execution cancelled.\"}", "name": "cancel-before-dispatch", "verdict": "PASS"}

GATE_STATUS js=1 wasm=1
```

## Required extension and native-agent attempt

The Web Store CRX was downloaded to `/tmp`, unpacked there, and given the
public key carried by the signed CRX header so that unpacked loading retained
the signed extension ID. The derived ID was verified before loading:

```text
magic b'Cr24' version 3 size 227520
header_size 2571 zip_offset 2583
{"name": "WebMCP - Model Context Tool Inspector", "update_url": "https://clients2.google.com/service/update2/crx", "version": "1.9.15"}
derived_id gbpdfapgefenggkahomfgkhfehlcenpd public_key_bytes 294
```

Official Google Chrome 152 rejects legacy `--load-extension`; WebDriver BiDi
was therefore used only to install the verified extension in the temporary
profile. Installation is not agent proof.

```text
$ python3 -m venv /tmp/webmcp-selenium
$ /tmp/webmcp-selenium/bin/pip install selenium==4.35.0
Successfully installed attrs-26.1.0 certifi-2026.7.22 h11-0.16.0 idna-3.19 outcome-1.3.0.post0 pysocks-1.7.1 selenium-4.35.0 sniffio-1.3.1 sortedcontainers-2.4.0 trio-0.30.0 trio-websocket-0.12.2 typing_extensions-4.14.1 urllib3-2.7.0 websocket-client-1.8.0 wsproto-1.3.2

$ /tmp/webmcp-selenium/bin/python tool/run_inspector_attempt.py \
    --chrome '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' \
    --chromedriver /tmp/chromedriver-spike/chromedriver/mac_arm-152.0.7977.83/chromedriver-mac-arm64/chromedriver \
    --build-dir build/web-js \
    --cert .cert/localhost-cert.pem \
    --key .cert/localhost-key.pem \
    --unpacked-extension /tmp/model-context-tool-inspector-crx
WEBEXTENSION_INSTALL={"extension": "gbpdfapgefenggkahomfgkhfehlcenpd"}
FIXTURE_TOOLS_READY=true
INSPECTOR_ATTEMPT={"apiKeyConfigured": false, "attemptedPrompt": "Observe the app, increment once, navigate to details, and observe again.", "id": "gbpdfapgefenggkahomfgkhfehlcenpd", "promptDisabled": true, "promptResults": "", "version": "1.9.15"}
RuntimeError: Gemini authentication unavailable; native agent invocation is FAIL
```

The attempted natural-language text is recorded, but a disabled prompt and
empty results are not invocation evidence. No extension/model authentication,
Gemini function call, native tool selection, or post-navigation agent trace was
produced. Native-agent verdict: **FAIL**.

## Safe fallback

Until a later append-only gate run proves both cancellation propagation and an
authenticated native-agent navigation trace:

- do not publish automatic page or app-observe tools to `document.modelContext`;
- retain explicit application-owned/manual tools only;
- keep positive waits disabled and advertise immediate polling only in
  experimental fixtures;
- treat unsupported, absent, or present-but-nonfunctional browser behavior as
  unavailable;
- never substitute CDP, WebDriver, manual inspector execution, or direct
  `executeTool()` for native-agent evidence.

## Final formatting, analysis, and wiki lint

```text
$ /tmp/flutter-3.47.0-page-semantics/bin/dart format lib
Formatted 1 file (0 changed) in 0.01 seconds.

$ /tmp/flutter-3.47.0-page-semantics/bin/flutter analyze --fatal-infos --fatal-warnings
Analyzing native-publisher...
No issues found! (ran in 2.8s)

$ python3 -m py_compile tool/serve_fixture.py tool/run_page_conformance.py tool/run_inspector_attempt.py
[exit 0; no stdout]

$ python3 tools/lint_wiki.py
lint_wiki: clean (0 warning(s)).
```

DTD discovery found no active Flutter app after the headed Chrome runs, so no
hot reload or hot restart target remained. Each page-conformance and inspector
command launched and terminated a fresh real Chrome fixture instance.
