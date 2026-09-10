# Implementation and handoff evidence

## Delivery status

The runtime and annotation-generator implementations are present. The final
JavaScript package completed the direct native Chrome API sequence:
discover, observe, read, act, navigate, receive a dispatch receipt, observe the
destination as the only eligible scope, reject the covered source page, and
read the destination.

This does not complete the work item. The corresponding Wasm package did not
revoke the covered home scope from application observation, and the required
authenticated Inspector/Gemini model-selected trace remains unavailable.
Native-agent support, Wasm automatic-page support, release, and full work-item
completion must not be claimed.

No package was published or deployed. No commit or push was performed as part
of this handoff.

## Repository verification

The complete repository check was rerun after the final runtime change:

```text
$ bash tools/check.sh
Preflight: flutter and dart found
lint_wiki: clean (0 warning(s)).
Stage 1 passed: wiki lint
Stage 2 passed: dependencies
Stage 3 passed: format
No issues found!
No issues found!
No issues found!
No issues found!
Stage 4 passed: analysis
00:05 +101: All tests passed!
00:00 +1: All tests passed!
00:00 +3: All tests passed!
00:00 +3: All tests passed!
Stage 5 passed: tests
✓ Built build/web
Stage 6 passed: build
All tests passed
Stage 7 passed: version bump test
[exit 0]
```

The page suite also passed on the upper supported SDK fixture:

```text
$ /Users/ortalcohen/fvm/versions/3.47.3/bin/flutter test test/page
00:01 +34: ... nested Navigator uses its forwarding observer and current route
00:01 +35: ... navigation action returns receipt and observes destination
00:01 +36: ... domain execution saturation rejects before handler side effects
00:01 +37: ... disposing a page removes owned endpoints and remounts fresh
00:01 +38: All tests passed!
[exit 0]
```

The full check used the repository default Flutter 3.47.0 / Dart 3.13.0
environment. The prior gate artifact records the six compiled-mode semantics
runs on Flutter 3.47.0 and 3.47.3. The final 3.47.3 page-suite rerun above
specifically includes the admission revalidation change.

## Final JavaScript native API flow

The build produced by the full repository check was exercised in official
Google Chrome 152.0.7977.83 with matching ChromeDriver:

```text
$ python3 spikes/native-publisher/tool/run_final_package_conformance.py \
    --chrome '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' \
    --chromedriver /tmp/chromedriver-spike/chromedriver/mac_arm-152.0.7977.83/chromedriver-mac-arm64/chromedriver \
    --build-dir example/build/web \
    --cert spikes/native-publisher/.cert/localhost-cert.pem \
    --key spikes/native-publisher/.cert/localhost-key.pem
FINAL_PACKAGE_EVIDENCE={"destinationNames":["example.app.observe","example.counter.increment","example.counter.read","example.details.page.act","example.details.page.read","example.home.page.act","example.home.page.read","example.screen.describe","example.screen.increment"],"details":{"labels":["Return home","Details"],"mountToken":"s2","pageId":"example.details","revision":1},"home":{"mountToken":"s1","pageId":"example.home","revision":1,"targetLabel":"Open details"},"homeAfterNavigation":{"code":"inactiveScope","message":"The page scope is not currently active.","ok":false,"protocolVersion":1,"refreshRequired":true,"retryable":true},"observedAfter":{"eligibleScopes":["s2"],"gap":false,"ok":true,"refreshRequired":false},"observedBefore":{"eligibleScopes":["s1"],"gap":false,"ok":true,"refreshRequired":false},"ok":true,"receipt":{"dispatched":true,"evidence":"commandDispatched","mountToken":"s1","ok":true,"operationId":"o1","pageId":"example.home"},"secure":true}
[exit 0]
```

The evidence line above is a field-preserving compact transcription of the
runner's exact JSON result; event-ring entries and browser/server diagnostics
were omitted from this document because they contain no additional verdict
fields. The runner itself exited successfully only after all ordered assertions
passed. This is direct `document.modelContext` API conformance selected by the
fixture, not model-selected native-agent evidence.

## Final Wasm result

The Wasm build completed successfully, but its integrated lifecycle flow failed
twice. The first run exposed that the old page remained readable. The runner
was then corrected to wait for application observation rather than treating
destination tool registration as lifecycle evidence. The corrected run still
failed after its 60-second deadline:

```text
$ flutter build web --release --wasm --output=build/web-final-wasm
Compiling lib/main.dart for the Web...                             19.8s
✓ Built build/web-final-wasm
[exit 0]

$ python3 tool/run_final_package_conformance.py ... \
    --build-dir ../../example/build/web-final-wasm
FINAL_PACKAGE_EVIDENCE={"error": "Error: Destination scope did not become exclusively eligible", "ok": false, "step": "observe-after"}
RuntimeError: Final package flow failed: {'error': 'Error: Destination scope did not become exclusively eligible', 'ok': False, 'step': 'observe-after'}
[exit 1]
```

This is a runtime blocker, not a harness substitution: `app.observe` never
reported the destination as the only eligible scope. The Wasm automatic-page
claim remains unsupported until the cause is fixed and this same settled-broker
negative case passes.

## Generator and package evidence

The full check independently analyzed the annotation package, generator, and
consumer fixture. It ran three generator tests and three generated consumer
fixture tests, rebuilt the generated adapter, and passed all package analyses.
The consumer fixture supplies a live instance and covers invocation,
authorization denial, and live-instance replacement.

## Remaining verification gates

1. Diagnose and fix the Wasm-only stale eligible scope, then rerun the final
   package flow without weakening the exclusive-scope or covered-page checks.
2. Supply Gemini authentication to the isolated official Inspector profile and
   archive a natural-language model-selected AC-035 trace. Direct browser API,
   WebDriver, or manual calls do not satisfy this gate.
3. Run one fresh blind implementation review against AC-001 through AC-035 and
   record each finding disposition. No extra review round is needed unless the
   corrective change is materially large.
4. After those gates pass, rerun `bash tools/check.sh`, both supported Flutter
   page suites, JavaScript and Wasm final-package fixtures, and wiki lint before
   changing the work item to done.

Optional follow-ups remain multiple Flutter views, positive observation waits,
Chrome platform-back gestures, generated route wrapping, framework state
adapters, generalized service proxies, and custom data providers.
