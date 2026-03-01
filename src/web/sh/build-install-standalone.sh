#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"
BIN_DIR="${BIN_DIR:-/usr/local/bin}"

MODE="${1:---help}"

print_help() {
  cat <<EOF
Usage:
  $(basename "$0") [build|install|uninstall|clean]

Modes:
  build    Build standalone binary and launcher scripts into build directory.
  install  Install artifacts to BIN_DIR (build is auto-run if needed).
  uninstall Remove installed files from BIN_DIR.
  clean    Remove local build artifacts from build directory.

Environment variables:
  BIN_DIR  Target directory for installation (default: /usr/local/bin)

Examples:
  $(basename "$0")
  $(basename "$0") build
  $(basename "$0") clean
  BIN_DIR="${HOME}/.local/bin" $(basename "$0") install
EOF
}

build_artifacts() {
  mkdir -p "${BUILD_DIR}"
  "${SCRIPT_DIR}/build.sh" "${BUILD_DIR}/vsegost-web"
  cp "${SCRIPT_DIR}/vsegost-web.sh" "${BUILD_DIR}/"
  cp "${SCRIPT_DIR}/vsegost-web-tmux.sh" "${BUILD_DIR}/"
}

install_artifacts() {
  if [[ ! -x "${BUILD_DIR}/vsegost-web" ]]; then
    echo "Standalone binary not found in ${BUILD_DIR}. Running build first."
    build_artifacts
  fi

  sudo install -m 0755 "${BUILD_DIR}/vsegost-web" "${BIN_DIR}/vsegost-web"
  sudo install -m 0755 "${BUILD_DIR}/vsegost-web.sh" "${BIN_DIR}/vsegost-web.sh"
  sudo install -m 0755 "${BUILD_DIR}/vsegost-web-tmux.sh" "${BIN_DIR}/vsegost-web-tmux.sh"
}

uninstall_artifacts() {
  sudo rm -f "${BIN_DIR}/vsegost-web" \
             "${BIN_DIR}/vsegost-web.sh" \
             "${BIN_DIR}/vsegost-web-tmux.sh" \
             "${BIN_DIR}/vsegost-web-screen.sh"
}

clean_artifacts() {
  rm -f "${BUILD_DIR}/vsegost-web" \
        "${BUILD_DIR}/vsegost-web.sh" \
        "${BUILD_DIR}/vsegost-web-tmux.sh" \
        "${BUILD_DIR}/vsegost-web-screen.sh"
}

case "${MODE}" in
  -h|--help|help)
    print_help
    exit 0
    ;;
  build)
    build_artifacts
    ;;
  install)
    install_artifacts
    ;;
  uninstall)
    uninstall_artifacts
    ;;
  clean)
    clean_artifacts
    ;;
  *)
    echo "Unknown mode: ${MODE}" >&2
    print_help
    exit 1
    ;;
esac

echo "Done: mode=${MODE}, build=${BUILD_DIR}, bin=${BIN_DIR}"
