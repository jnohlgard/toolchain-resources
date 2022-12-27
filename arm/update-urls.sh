#!/bin/sh
set -euo pipefail

download_page_url="https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads"
download_root_url="https://developer.arm.com"

mgv="$(dirname "$0")/../mgv/mgv"
dest_path="$(dirname "$0")"
# download all *.sha256asc URLs from the download page HTML source.
curl -sSf -L "${download_page_url}" | \
    sed -n -e 's/^.*href="\([^"]*\.sha256asc\)[^"]*".*$/\1/p' | \
    sed -e "s,^/,${download_root_url}/," | \
    while read -r sha256asc_url
do
  [ -n "${sha256asc_url}" ] || continue
  file_url=${sha256asc_url%.sha256asc}
  file_name="${file_url##*/}"
  printf 'Adding %s\n' "${file_url}"

  # Read the sha256 hash from the sha256asc file
  if ! file_sha256=$(curl -sSf -L "${sha256asc_url}" | cut -d' ' -f1); then
    >&2 printf 'Failed to fetch SHA256 sum for %s, skipping...\n' "${file_name}"
    continue
  fi
  printf 'DIST %s - URL %s SHA256 %s\n' "${file_name}" "${file_url}" "${file_sha256}" > "${dest_path}/${file_name}.mgv"
  if ! "${mgv}" fix-size "${dest_path}/${file_name}.mgv"; then
    >&2 printf 'Failed to get real file size for %s, skipping...\n' "${file_name}"
    rm -f "${dest_path}/${file_name}.mgv"
    git -C "${dest_path}" checkout -f HEAD -- "${file_name}.mgv" 2>/dev/null || true
    continue
  fi
done
