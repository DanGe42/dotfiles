#!/bin/bash

# Start an HTTP server from a directory, optionally specifying the port

function server() {
    local port="${1:-8000}"
    xdg-open "http://localhost:${port}/"
    python -m SimpleHTTPServer "$port"
}
