#!/usr/bin/env python3
import os
import sys
from http import server

class MyHTTPRequestHandler(server.SimpleHTTPRequestHandler):
        def end_headers(self):
                self.send_my_headers()
                server.SimpleHTTPRequestHandler.end_headers(self)

        def send_my_headers(self):
                self.send_header("Access-Control-Allow-Origin", "*")
                self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
                self.send_header("Cross-Origin-Opener-Policy", "same-origin")

if __name__ == '__main__':
        args = sys.argv[1:]
        if len(args) > 0:
                print("changing to dir : {}".format(args[0]))
                os.chdir(args[0])
        print("starting server : http://localhost:8000")
        server.test(HandlerClass=MyHTTPRequestHandler)
