#!/bin/sh
set -euo pipefail

cd "$(dirname "$0")"
pwd
for d in arm espressif; do
  printf 'Updating %s\n' "$d"
  if [ -n "$(git status --porcelain "$d")" ]; then
    >&2 printf 'Skipping unclean %s\n' "$d"
    continue
  fi
  sh "./$d/update-urls.sh"
  if [ -n "$(git status --porcelain "./$d")" ]; then
    git add "./$d"
    git commit "./$d" -m "$d: Sync latest upstream links"
  fi
done
