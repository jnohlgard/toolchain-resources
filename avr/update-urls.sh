#!/bin/sh
set -euo pipefail

repo_url=https://api.github.com/repos/ZakKemble/avr-gcc-build
mgv="$(dirname "$0")/../mgv/mgv"

update_shasums() {
  if [ "$#" -ne 1 ]; then
    return 1
  fi
  shasum_url=$1
  release=${shasum_url%/*}
  release=${release##*/}
  printf 'Updating SHA256 sums for release %s\n' "${release}"
  curl -fsSL "${shasum_url}" | while read hash dest
  do
    dest=${dest#\*}
    if [ -w "${dest}.mgv" ]; then
      while read kind filename expected_size url_tag url checksums; do
        checksums="SHA256 ${hash}"
        printf '%s %s %s %s %s %s\n' "${kind}" "${filename}" "${expected_size}" "${url_tag}" "${url}" "${checksums}" > "${dest}.mgv.tmp"
      done < "${dest}.mgv"
      mv -f "${dest}.mgv.tmp" "${dest}.mgv"
    else
      >&2 printf 'Missing %s\n' "${dest}.mgv"
    fi
  done
}

curl -fsSL -H 'Accept: application/vnd.github+json' "${repo_url}/releases" | jq -r \
    '.[] | select(.assets[].name == "SHA256SUMS") | .assets[] | (select(.name != "SHA256SUMS"), select(.name == "SHA256SUMS")) | ("DIST \(.name) \(.size) URL \(.browser_download_url)")' | \
  while read tag filename size url_tag url checksums
do
  if [ "${filename}" = 'SHA256SUMS' ]; then
    update_shasums "${url}"
    continue
  fi
  printf '%s\n' "${filename}"
  printf '%s %s %s %s %s %s\n' "${tag}" "${filename}" "${size}" "${url_tag}" "${url}" "${checksums}" | "${mgv}" import
done
