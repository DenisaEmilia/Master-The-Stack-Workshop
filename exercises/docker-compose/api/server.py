"""A tiny JSON API using only Python's standard library."""

import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        path = urlsplit(self.path).path
        if path == "/message":
            status = 200
            payload = {"message": os.environ.get("WELCOME_MESSAGE", "Hello from the backend!")}
        elif path == "/health":
            status = 200
            payload = {"status": "UP"}
        else:
            status = 404
            payload = {"error": "Not found"}

        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)


if __name__ == "__main__":
    print("API listening on port 5000", flush=True)
    ThreadingHTTPServer(("0.0.0.0", 5000), Handler).serve_forever()
