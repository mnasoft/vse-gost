#!/usr/bin/env bash
set -euo pipefail

echo "##################################################"
echo "${BASH_SOURCE[0]} START ..."
echo "##################################################"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
OUTPUT_PATH="./src/web/sh/build/vsegost-web.exe"

##########
echo "SCRIPT_DIR=${SCRIPT_DIR}"
echo "PROJECT_ROOT=${PROJECT_ROOT}"
echo "OUTPUT_PATH=${OUTPUT_PATH}"
##########

cd "${PROJECT_ROOT}"

##########
echo "PWD=${PWD}"
##########

sbcl --non-interactive \
     --eval "(asdf:load-system :vse-gost/web)" \
     --eval "(sb-ext:save-lisp-and-die \"${OUTPUT_PATH}\" :executable t :compression t)"

# Запуск скомпилированного бинарника:
# vsegost-web.exe --eval "(vse-gost/web:start-gosts)"

echo "##################################################"
echo "${BASH_SOURCE[0]} DONE"
echo "##################################################"
