#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_BIN="${SCRIPT_DIR}/vsegost-web.exe"
START_FORM="(vse-gost/web:start-gosts)"

if [[ -x "${LOCAL_BIN}" ]]; then
	exec "${LOCAL_BIN}" --eval "${START_FORM}" "$@"
fi

exec vsegost-web.exe --eval "${START_FORM}" "$@"
