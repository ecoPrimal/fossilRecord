#!/usr/bin/env python3
"""membrane-census-http.py — serve commensals.json on port 9753
Tiny HTTP server. Runs as a systemd unit on non-golgi nodes.
Only serves /commensals.json — everything else returns 404.
"""
import http.server
import json
import os

PORT = 9754
CENSUS_FILE = '/opt/membrane/commensals.json'

class CensusServer(http.server.HTTPServer):
    allow_reuse_address = True
    allow_reuse_port = True

class CensusHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/commensals.json':
            try:
                with open(CENSUS_FILE) as f:
                    data = f.read()
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Cache-Control', 'public, max-age=60')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(data.encode())
            except FileNotFoundError:
                self.send_error(404, 'Census not ready')
        else:
            self.send_error(404)

    def log_message(self, format, *args):
        pass  # silent

if __name__ == '__main__':
    server = CensusServer(('0.0.0.0', PORT), CensusHandler)
    print(f'membrane-census-http listening on :{PORT}')
    server.serve_forever()
