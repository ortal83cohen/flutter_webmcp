# Chrome WebMCP transport gate fixture

This fixture registers Chrome 152 `document.modelContext` tools from a Flutter
app through JavaScript interop. It exercises registration, discovery,
execution, annotations, safe results/errors, cancellation, AbortSignal
unregistration, immediate observation, cursor gaps, remounts, and
navigation-owned receipts.

The HTTPS server sets COOP, COEP, Origin-Agent-Cluster, CORP, no-sniff, and
no-store headers. Certificates, temporary profiles, and Flutter build outputs
are generated locally and ignored.

Build both renderers:

```text
flutter build web --release --output=build/web-js
flutter build web --release --wasm --output=build/web-wasm
```

Create a one-day localhost certificate, then run the page conformance tool with
real headed Google Chrome and a matching ChromeDriver:

```text
openssl req -x509 -newkey rsa:2048 -nodes -sha256 -days 1 \
  -keyout .cert/localhost-key.pem -out .cert/localhost-cert.pem \
  -subj '/CN=localhost' \
  -addext 'subjectAltName=DNS:localhost,IP:127.0.0.1'
python3 tool/run_page_conformance.py \
  --chrome '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' \
  --chromedriver /absolute/path/to/chromedriver \
  --build-dir build/web-js \
  --cert .cert/localhost-cert.pem \
  --key .cert/localhost-key.pem
```

The inspector runner requires Selenium with WebDriver BiDi support. It installs
the required extension into a new temporary profile and never reads or mutates
the normal Chrome profile:

```text
python3 -m venv /tmp/webmcp-selenium
/tmp/webmcp-selenium/bin/pip install selenium==4.35.0
/tmp/webmcp-selenium/bin/python tool/run_inspector_attempt.py \
  --chrome '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' \
  --chromedriver /absolute/path/to/chromedriver \
  --build-dir build/web-js \
  --cert .cert/localhost-cert.pem \
  --key .cert/localhost-key.pem \
  --unpacked-extension /absolute/path/to/verified-extension
```

The runner deliberately returns failure when Gemini authentication is absent.
Manual execution, WebDriver, and in-page `executeTool` are page-conformance
evidence only and never count as native-agent proof.
