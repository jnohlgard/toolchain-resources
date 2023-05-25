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

# See: https://data.services.jetbrains.com/products (raw json data)
#
# Example: https://data.services.jetbrains.com/products/releases?code=CL&latest=true&type=release,eap

# AC: AppCode
# CL: CLion
# CWML: Code With Me Lobby
# CWMR: Code With Me Relay
# DC: dotCover
# DCCLT: dotCover Command Line Tools
# DG: DataGrip
# DL: Datalore
# DLE: Datalore Enterprise
# DM: dotMemory
# DMCLP: dotMemory Command Line Profiler
# DMU: dotMemory Unit
# DP: dotTrace
# DPCLT: dotTrace Command Line Tools
# DPK: dotPeek
# DPPS: dotTrace Profiling SDK
# DS: DataSpell
# EHS: ETW Host Service
# FL: Fleet
# FLL: Fleet Launcher
# FLS: Floating License Server
# GO: GoLand
# GW: Gateway
# HB: Hub
# HCC: HTTP Client CLI
# IIC: IntelliJ IDEA Community Edition
# IIE: IntelliJ IDEA Edu
# IIU: IntelliJ IDEA Ultimate
# JCD: JetBrains Clients Downloader
# KT: Kotlin
# MF: Mono Font
# MPS: MPS
# MPSIIP: MPS IntelliJ IDEA plugin
# PCC: PyCharm Community Edition
# PCE: PyCharm Edu
# PCP: PyCharm Professional Edition
# PS: PhpStorm
# QA: Aqua
# QDAND: Qodana for Android
# QDGO: Qodana for Go
# QDJVM: Qodana for JVM
# QDJVMC: Qodana Community for JVM
# QDJVME: Qodana Enterprise for JVM
# QDPHP: Qodana for PHP
# QDPHPE: Qodana Enterprise for PHP
# QDPY: Qodana for Python
# QDPYC: Qodana Community for Python
# QDPYE: Qodana Enterprise for Python
# QDRST: Qodana for Rust
# RC: ReSharper C++
# RD: Rider
# RDCPPP: Rider for Unreal Engine
# RFU: RiderFlow for Unity
# RM: RubyMine
# RRD: Rider Remote Debugger
# RS: ReSharper
# RSCHB: ReSharper Checked builds
# RSCLT: ReSharper Command Line Tools
# RSU: ReSharper Tools
# SP: Space Cloud
# SPA: Space Desktop
# SPP: Space On-Premises
# TBA: Toolbox App
# TC: TeamCity
# TCC: TeamCity Cloud
# US: Upsource
# WS: WebStorm
# YTD: YouTrack
# YTWE: Youtrack Workflow Editor

for product in \
  AC CL DG DL DS FL GO GW IIU IIC JCD KT MF MPS PCC PCP PS QA RC RD RDCPPP RFU RM RRD RS RSCLT RSU SPA WS \
  ;\
do
  for kind in 'release' 'eap,rc' 'prerelease'; do
    data_url="https://data.services.jetbrains.com/products/releases?code=${product}&latest=true&type=${kind}"
    curl -fsSL -H 'Accept: application/json' "${data_url}" | jq -r \
      '.[][].downloads | select(.) | .[] | select(.link | startswith("https://download.jetbrains.com")) | . += { "file": .link | split("/") | last } | "DIST \(.file) \(.size) URL \(.link) \(.checksumLink)"' | \
      while read tag filename size url_tag url checksum_url
    do
      printf '%s\n' "${filename}"
      if [ -f "${filename}.mgv" ]; then
        continue
      fi
      checksums=$(get_shasum "${checksum_url}")
      printf '%s %s %s %s %s %s\n' "${tag}" "${filename}" "${size}" "${url_tag}" "${url}" "${checksums}" | "${mgv}" import
    done
  done
done
