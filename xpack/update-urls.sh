#!/bin/sh
set -euo pipefail

cd "$(dirname "$0")"
mgv="${PWD}/../mgv/mgv"

get_shasum() {
  if [ "$#" -ne 1 ]; then
    return 1
  fi
  shasum_url=$1
  curl -fsSL "${shasum_url}" | while read hash dest
  do
    printf 'SHA256 %s' "${hash}"
  done
}

for repo in \
  riscv-none-elf-gcc-xpack \
  arm-none-eabi-gcc-xpack \
  aarch64-none-elf-gcc-xpack
do
  repo_url=https://api.github.com/repos/xpack-dev-tools/${repo}
  curl -fsSL -H 'Accept: application/vnd.github+json' "${repo_url}/releases" | jq -r \
    '.[].assets[] | select(.name | endswith(".sha") | not ) | ("DIST \(.name) \(.size) URL \(.browser_download_url)")' | \
    while read tag filename size url_tag url checksums
  do
    printf '%s\n' "${filename}"
    if [ -f "${filename}.mgv" ]; then
      continue
    fi
    checksums=$(get_shasum "${url}.sha")
    printf '%s %s %s %s %s %s\n' "${tag}" "${filename}" "${size}" "${url_tag}" "${url}" "${checksums}" | "${mgv}" import
  done
done
