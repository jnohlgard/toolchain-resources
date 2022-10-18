#!/bin/sh
set -euo pipefail

cd "$(dirname "$0")"
for d in arm espressif; do
  "./$d/update-urls.sh"
  git commit "./$d" -m "$d: Sync latest upstream links"
done
