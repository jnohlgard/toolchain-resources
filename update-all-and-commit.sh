#!/bin/sh
set -euo pipefail

cd "$(dirname "$0")"
if [ -n "$(git status --porcelain)" ]; then
  >&2 printf 'Working directory is not clean\n'
  exit 1
fi
for d in arm espressif; do
  "./$d/update-urls.sh"
  if [ -n "$(git status --porcelain "./$d")" ]; then
    git add "./$d"
    git commit "./$d" -m "$d: Sync latest upstream links"
  fi
done
