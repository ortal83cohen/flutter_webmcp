#!/usr/bin/env python3
"""Run the final package flow through Chrome's real WebMCP page API."""

from __future__ import annotations

import argparse
import json
import ssl
import subprocess
import tempfile
import time
import urllib.error
import urllib.request
from pathlib import Path


def request_json(url: str, method: str = "GET", body: object | None = None) -> dict:
    data = None if body is None else json.dumps(body).encode()
    request = urllib.request.Request(
        url,
        data=data,
        method=method,
        headers={"Content-Type": "application/json"},
    )
    context = ssl._create_unverified_context()
    with urllib.request.urlopen(request, context=context, timeout=130) as response:
        return json.loads(response.read())


def wait_ready(url: str, timeout: float = 15) -> None:
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        try:
            request_json(url)
            return
        except (OSError, urllib.error.URLError, json.JSONDecodeError):
            time.sleep(0.1)
    raise RuntimeError(f"Timed out waiting for {url}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--chrome", type=Path, required=True)
    parser.add_argument("--chromedriver", type=Path, required=True)
    parser.add_argument("--build-dir", type=Path, required=True)
    parser.add_argument("--cert", type=Path, required=True)
    parser.add_argument("--key", type=Path, required=True)
    args = parser.parse_args()

    fixture_url = "https://localhost:8443"
    server = subprocess.Popen(
        [
            "python3",
            str(Path(__file__).with_name("serve_fixture.py")),
            "--directory",
            str(args.build_dir),
            "--cert",
            str(args.cert),
            "--key",
            str(args.key),
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    driver = subprocess.Popen(
        [str(args.chromedriver), "--port=9515"],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    session_id = None
    try:
        wait_ready("http://127.0.0.1:9515/status")
        with tempfile.TemporaryDirectory(
            prefix="webmcp-final-profile-",
            ignore_cleanup_errors=True,
        ) as profile:
            response = request_json(
                "http://127.0.0.1:9515/session",
                "POST",
                {
                    "capabilities": {
                        "alwaysMatch": {
                            "browserName": "chrome",
                            "acceptInsecureCerts": True,
                            "pageLoadStrategy": "none",
                            "timeouts": {"script": 120000},
                            "goog:loggingPrefs": {"browser": "ALL"},
                            "goog:chromeOptions": {
                                "binary": str(args.chrome),
                                "args": [
                                    "--enable-features=WebMCP,WebMCPTesting",
                                    "--enable-experimental-web-platform-features",
                                    f"--user-data-dir={profile}",
                                    "--no-first-run",
                                    "--no-default-browser-check",
                                ],
                            },
                        }
                    }
                },
            )
            session_id = response["value"]["sessionId"]
            capabilities = response["value"]["capabilities"]
            print(
                "SESSION_CAPABILITIES="
                + json.dumps(capabilities, sort_keys=True),
                flush=True,
            )
            request_json(
                f"http://127.0.0.1:9515/session/{session_id}/url",
                "POST",
                {"url": fixture_url},
            )
            script = r"""
const done = arguments[arguments.length - 1];
const decode = (value) => {
  if (typeof value !== 'string') return value;
  try { return JSON.parse(value); } catch (_) { return value; }
};
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const getTools = async () => await document.modelContext.getTools();
let step = 'discover';
const execute = async (name, input) => {
  const tool = (await getTools()).find((candidate) => candidate.name === name);
  if (!tool) throw new Error(`Missing native tool ${name}`);
  return decode(await document.modelContext.executeTool(tool, JSON.stringify(input)));
};
(async () => {
  const deadline = performance.now() + 90000;
  let names = [];
  while (performance.now() < deadline) {
    names = (await getTools()).map((tool) => tool.name).sort();
    if (
      names.includes('example.app.observe') &&
      names.includes('example.home.page.read') &&
      names.includes('example.home.page.act')
    ) break;
    await sleep(50);
  }
  const discovered = names.filter((name) => name.startsWith('example.'));
  step = 'observe-before';
  const observedBefore = await execute('example.app.observe', {});
  step = 'read-home';
  const home = await execute('example.home.page.read', {});
  const target = home.nodes.find(
    (node) => node.label === 'Open details' && node.actions.includes('tap'),
  );
  if (!target) throw new Error('Open details semantic action was not discovered');
  step = 'act';
  const receipt = await execute('example.home.page.act', {
    pageId: home.pageId,
    mountToken: home.mountToken,
    revision: home.revision,
    handle: target.handle,
    action: 'tap',
    requestId: 1,
    arguments: {},
  });
  step = 'navigate';
  let destinationNames = [];
  while (performance.now() < deadline) {
    destinationNames = (await getTools()).map((tool) => tool.name).sort();
    if (destinationNames.includes('example.details.page.read')) break;
    await sleep(50);
  }
  step = 'observe-after';
  let observedAfter;
  while (performance.now() < deadline) {
    observedAfter = await execute('example.app.observe', {
      cursor: observedBefore.cursor,
    });
    if (
      observedAfter.ok === true &&
      observedAfter.eligibleScopes.length === 1 &&
      !observedAfter.eligibleScopes.includes(home.mountToken)
    ) break;
    await sleep(50);
  }
  if (
    observedAfter?.ok !== true ||
    observedAfter.eligibleScopes.length !== 1 ||
    observedAfter.eligibleScopes.includes(home.mountToken)
  ) {
    throw new Error('Destination scope did not become exclusively eligible');
  }
  step = 'covered-page-negative';
  const homeStillRegistered = destinationNames.includes('example.home.page.read');
  const homeAfterNavigation = homeStillRegistered
    ? await execute('example.home.page.read', {})
    : {ok: false, code: 'unregistered'};
  if (homeAfterNavigation.ok !== false) {
    throw new Error(
      `Covered home page remained readable: ${JSON.stringify(homeAfterNavigation)}`,
    );
  }
  step = 'read-details';
  const details = await execute('example.details.page.read', {});
  done({
    ok: true,
    secure: window.isSecureContext,
    isolated: window.crossOriginIsolated,
    discovered,
    observedBefore,
    home: {
      pageId: home.pageId,
      mountToken: home.mountToken,
      revision: home.revision,
      targetLabel: target.label,
    },
    receipt,
    homeAfterNavigation,
    destinationNames: destinationNames.filter((name) => name.startsWith('example.')),
    observedAfter,
    details: {
      pageId: details.pageId,
      mountToken: details.mountToken,
      revision: details.revision,
      labels: details.nodes.map((node) => node.label).filter(Boolean),
    },
  });
})().catch((error) => done({ok: false, step, error: String(error)}));
"""
            result = request_json(
                f"http://127.0.0.1:9515/session/{session_id}/execute/async",
                "POST",
                {"script": script, "args": []},
            )["value"]
            print("FINAL_PACKAGE_EVIDENCE=" + json.dumps(result, sort_keys=True))
            browser_logs = request_json(
                f"http://127.0.0.1:9515/session/{session_id}/log",
                "POST",
                {"type": "browser"},
            )["value"]
            print("BROWSER_LOGS=" + json.dumps(browser_logs, sort_keys=True))
            if not result.get("ok"):
                raise RuntimeError(f"Final package flow failed: {result}")
            if result["details"]["pageId"] != "example.details":
                raise RuntimeError("Destination page was not read")
            if not result["receipt"].get("dispatched"):
                raise RuntimeError("Action dispatch receipt was absent")
    finally:
        if session_id is not None:
            try:
                request_json(
                    f"http://127.0.0.1:9515/session/{session_id}",
                    "DELETE",
                )
            except Exception:
                pass
        for process in (driver, server):
            process.terminate()
        for label, process in (("CHROMEDRIVER", driver), ("SERVER", server)):
            try:
                output, _ = process.communicate(timeout=5)
            except subprocess.TimeoutExpired:
                process.kill()
                output, _ = process.communicate()
            print(f"{label}_OUTPUT_START\n{output}{label}_OUTPUT_END", flush=True)


if __name__ == "__main__":
    main()
