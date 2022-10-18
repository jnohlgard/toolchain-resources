#!/bin/bash
set -euo pipefail

manifest_url=https://raw.githubusercontent.com/espressif/esp-idf/master/tools/tools.json 
curl -LfsS "${manifest_url}" | jq -r '.tools[] | select(.name) | .versions[][] | select(. | type=="object") | . += { "file": .url | split("/") | last } | "DIST \(.file) \(.size) URL \(.url) SHA256 \(.sha256)"' | while read tag filename args; do printf '%s %s %s\n' "${tag}" "${filename}" "${args}" > "${filename}.mgv"; done
