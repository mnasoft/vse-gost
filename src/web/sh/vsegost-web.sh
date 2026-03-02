#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_BIN="${SCRIPT_DIR}/vsegost-web.exe"

if [[ -x "${LOCAL_BIN}" ]]; then
	exec "${LOCAL_BIN}" "$@"
fi

exec vsegost-web.exe "$@"
