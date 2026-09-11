#!/usr/bin/env python3
"""Attempt the official inspector's Gemini flow in an isolated Chrome profile."""

from __future__ import annotations

import argparse
import json
import subprocess
import tempfile
from pathlib import Path

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait


EXTENSION_ID = "gbpdfapgefenggkahomfgkhfehlcenpd"
PROMPT = "Observe the app, increment once, navigate to details, and observe again."


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--chrome", type=Path, required=True)
    parser.add_argument("--chromedriver", type=Path, required=True)
    parser.add_argument("--build-dir", type=Path, required=True)
    parser.add_argument("--cert", type=Path, required=True)
    parser.add_argument("--key", type=Path, required=True)
    parser.add_argument("--unpacked-extension", type=Path, required=True)
    args = parser.parse_args()

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
    profile = tempfile.mkdtemp(prefix="webmcp-inspector-bidi-profile-")
    options = Options()
    options.binary_location = str(args.chrome)
    options.enable_bidi = True
    options.enable_webextensions = True
    options.accept_insecure_certs = True
    for argument in (
        "--enable-features=WebMCP,WebMCPTesting",
        "--enable-experimental-web-platform-features",
        f"--user-data-dir={profile}",
        "--no-first-run",
        "--no-default-browser-check",
    ):
        options.add_argument(argument)

    driver = webdriver.Chrome(
        service=Service(str(args.chromedriver)),
        options=options,
    )
    try:
        print(
            "SELENIUM_CAPABILITIES="
            + json.dumps(driver.capabilities, sort_keys=True),
            flush=True,
        )
        installed = driver.webextension.install(path=str(args.unpacked_extension))
        print("WEBEXTENSION_INSTALL=" + json.dumps(installed, sort_keys=True), flush=True)

        driver.get("https://localhost:8443")
        WebDriverWait(driver, 30).until(
            lambda current: current.execute_script(
                "return window.__gateDone === true;",
            ),
        )
        print("FIXTURE_TOOLS_READY=true", flush=True)

        driver.get(f"chrome-extension://{EXTENSION_ID}/sidebar.html")
        WebDriverWait(driver, 15).until(
            lambda current: current.execute_script(
                "return Boolean(document.getElementById('promptBtn'));",
            ),
        )
        evidence = driver.execute_script(
            """
            const prompt = document.getElementById('userPromptText');
            const button = document.getElementById('promptBtn');
            prompt.value = arguments[0];
            button.click();
            return {
              id: chrome.runtime.id,
              version: chrome.runtime.getManifest().version,
              apiKeyConfigured: Boolean(localStorage.apiKey),
              promptDisabled: button.disabled,
              attemptedPrompt: prompt.value,
              promptResults: document.getElementById('promptResults').textContent,
            };
            """,
            PROMPT,
        )
        print("INSPECTOR_ATTEMPT=" + json.dumps(evidence, sort_keys=True), flush=True)
        if evidence["id"] != EXTENSION_ID:
            raise RuntimeError("Official extension identity mismatch")
        if not evidence["apiKeyConfigured"]:
            raise RuntimeError(
                "Gemini authentication unavailable; native agent invocation is FAIL",
            )
    finally:
        driver.quit()
        server.terminate()
        try:
            output, _ = server.communicate(timeout=5)
        except subprocess.TimeoutExpired:
            server.kill()
            output, _ = server.communicate()
        print(f"SERVER_OUTPUT_START\n{output}SERVER_OUTPUT_END", flush=True)


if __name__ == "__main__":
    main()
