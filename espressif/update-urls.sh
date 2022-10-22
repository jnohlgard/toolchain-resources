#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"
mgv="${PWD}/../mgv/mgv"
manifest_url=https://raw.githubusercontent.com/espressif/esp-idf/master/tools/tools.json 
curl -LfsS "${manifest_url}" | jq -r '.tools[] | select(.name) | .versions[][] | select(. | type=="object") | . += { "file": .url | split("/") | last } | "DIST \(.file) \(.size) URL \(.url) SHA256 \(.sha256)"' | "${mgv}" import
