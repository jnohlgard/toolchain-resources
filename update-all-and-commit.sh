#!/bin/sh
set -euo pipefail

cd "$(dirname "$0")"
pwd
ls -la
for d in arm espressif; do
  ls -la "$d"
  if [ -n "$(git status --porcelain "$d")" ]; then
    >&2 printf 'Skipping unclean %s\n' "$d"
    continue
  fi
  sh -x "./$d/update-urls.sh"
  if [ -n "$(git status --porcelain "./$d")" ]; then
    git add "./$d"
    git commit "./$d" -m "$d: Sync latest upstream links"
  fi
done
