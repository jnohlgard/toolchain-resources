#!/bin/sh
set -euo pipefail

cd "$(dirname "$0")"
pwd
for update_script in */update-urls.sh; do
  dir=${update_script%/*}
  printf 'Updating %s\n' "${dir}"
  if [ -n "$(git status --porcelain "${dir}")" ]; then
    >&2 printf 'Skipping unclean %s\n' "${dir}"
    continue
  fi
  if ! sh "${update_script}"; then
    >&2 printf 'Update script failed in %s\n' "${dir}"
    git clean -f "${dir}"
    git checkout -f HEAD "${dir}"
    continue
  fi
  if [ -n "$(git status --porcelain "${dir}")" ]; then
    git add "${dir}"
    git commit "${dir}" -m "${dir}: Sync latest upstream links"
  fi
done
