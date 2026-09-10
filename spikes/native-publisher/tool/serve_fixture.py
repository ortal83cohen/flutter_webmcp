#!/usr/bin/env python3
"""Serve a built fixture over isolated HTTPS localhost."""

from __future__ import annotations

import argparse
import http.server
import ssl
from pathlib import Path


class IsolatedHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self) -> None:
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Origin-Agent-Cluster", "?1")
        self.send_header("Cross-Origin-Resource-Policy", "same-origin")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("Cache-Control", "no-store")
        super().end_headers()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--directory", type=Path, required=True)
    parser.add_argument("--cert", type=Path, required=True)
    parser.add_argument("--key", type=Path, required=True)
    parser.add_argument("--port", type=int, default=8443)
    args = parser.parse_args()

    handler = lambda *handler_args, **kwargs: IsolatedHandler(  # noqa: E731
        *handler_args,
        directory=str(args.directory),
        **kwargs,
    )
    server = http.server.ThreadingHTTPServer(("127.0.0.1", args.port), handler)
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.load_cert_chain(args.cert, args.key)
    server.socket = context.wrap_socket(server.socket, server_side=True)
    print(f"HTTPS fixture listening on https://localhost:{args.port}", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
