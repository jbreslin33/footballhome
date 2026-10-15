#!/usr/bin/env python3
"""Temporary upload receiver for the Newspapers.com recapture session.
Accepts POST /drop with X-Drop-Token + X-Drop-Name, saves to /files."""
import os, re, json
from http.server import BaseHTTPRequestHandler, HTTPServer

TOKEN = os.environ["DROP_TOKEN"]
MAX = 80 * 1024 * 1024

class H(BaseHTTPRequestHandler):
    def _cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "content-type,x-drop-token,x-drop-name")

    def do_OPTIONS(self):
        self.send_response(204); self._cors(); self.end_headers()

    def do_GET(self):
        body = b'{"ok":true}' if self.path == "/health" else b'{"err":"nope"}'
        self.send_response(200); self._cors()
        self.send_header("Content-Type", "application/json")
        self.end_headers(); self.wfile.write(body)

    def do_POST(self):
        if self.path != "/drop" or self.headers.get("X-Drop-Token") != TOKEN:
            self.send_response(403); self._cors(); self.end_headers(); return
        name = re.sub(r"[^A-Za-z0-9._-]", "_", self.headers.get("X-Drop-Name", "x"))[:120]
        n = int(self.headers.get("Content-Length", "0"))
        if not (0 < n <= MAX):
            self.send_response(413); self._cors(); self.end_headers(); return
        data = self.rfile.read(n)
        with open(os.path.join("/files", name), "wb") as f:
            f.write(data)
        out = json.dumps({"saved": name, "size": len(data)}).encode()
        self.send_response(200); self._cors()
        self.send_header("Content-Type", "application/json")
        self.end_headers(); self.wfile.write(out)

    def log_message(self, *a):
        pass

HTTPServer(("0.0.0.0", 8977), H).serve_forever()
