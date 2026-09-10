#!/usr/bin/env python3
"""Run page-level WebMCP conformance in a temporary Chrome profile."""

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
    with urllib.request.urlopen(request, context=context, timeout=10) as response:
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
    server_command = [
        "python3",
        str(Path(__file__).with_name("serve_fixture.py")),
        "--directory",
        str(args.build_dir),
        "--cert",
        str(args.cert),
        "--key",
        str(args.key),
    ]
    driver_command = [str(args.chromedriver), "--port=9515"]
    server = subprocess.Popen(
        server_command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    driver = subprocess.Popen(
        driver_command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    session_id = None
    try:
        wait_ready("http://127.0.0.1:9515/status")
        with tempfile.TemporaryDirectory(prefix="webmcp-page-profile-") as profile:
            response = request_json(
                "http://127.0.0.1:9515/session",
                "POST",
                {
                    "capabilities": {
                        "alwaysMatch": {
                            "browserName": "chrome",
                            "acceptInsecureCerts": True,
                            "pageLoadStrategy": "none",
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
            value = response["value"]
            session_id = value["sessionId"]
            print(
                "SESSION_CAPABILITIES="
                + json.dumps(value["capabilities"], sort_keys=True),
                flush=True,
            )
            request_json(
                f"http://127.0.0.1:9515/session/{session_id}/url",
                "POST",
                {"url": fixture_url},
            )
            deadline = time.monotonic() + 90
            evidence = None
            while time.monotonic() < deadline:
                response = request_json(
                    f"http://127.0.0.1:9515/session/{session_id}/execute/sync",
                    "POST",
                    {
                        "script": (
                            "return {done: window.__gateDone === true, "
                            "results: window.__gateResults || [], "
                            "secure: window.isSecureContext, "
                            "isolated: window.crossOriginIsolated, "
                            "modelContext: !!document.modelContext};"
                        ),
                        "args": [],
                    },
                )
                evidence = response["value"]
                if evidence["done"]:
                    break
                time.sleep(0.25)
            print("PAGE_EVIDENCE=" + json.dumps(evidence, sort_keys=True), flush=True)
            if not evidence or not evidence["done"]:
                raise RuntimeError("Fixture did not complete")
            for result in evidence["results"]:
                print(
                    "CASE_EVIDENCE=" + json.dumps(result, sort_keys=True),
                    flush=True,
                )
            failed = [item for item in evidence["results"] if item["verdict"] != "PASS"]
            if failed:
                raise RuntimeError(f"Page conformance failures: {failed}")
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
