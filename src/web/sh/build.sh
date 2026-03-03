#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
OUTPUT_PATH="${1:-${PWD}/vsegost-web.exe}"

cd "${PROJECT_ROOT}"

sbcl --non-interactive \
     --eval "(asdf:load-system :vse-gost/web)" \
     --eval "(sb-ext:save-lisp-and-die \"${OUTPUT_PATH}\" :executable t :compression t)"

# :toplevel #'vse-gost/web:start-gosts
# vsegost-web.exe --eval "(vse-gost/web:start-gosts)"
