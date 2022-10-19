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
  printf 'Adding %s\n' "${file_url}"

  # Read the sha256 hash from the sha256asc file
  file_sha256=$(curl -sSf -L "${sha256asc_url}" | cut -d' ' -f1)
  file_name="${file_url##*/}"
  printf 'DIST %s - URL %s SHA256 %s\n' "${file_name}" "${file_url}" "${file_sha256}" > "${dest_path}/${file_name}.mgv"
  "${mgv}" fix-size "${dest_path}/${file_name}.mgv"
done
