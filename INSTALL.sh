#!/usr/bin/env bash
set -euo pipefail

##################################################
#### functions

usage() {
  cat <<EOF
Usage:
  $(basename "$0") [build|clean]
  $(basename "$0") [install|uninstall]
  $(service_usage)

Modes:
  build             Build standalone binary and launcher scripts into build directory.
  install           Install artifacts to BIN_DIR (build is auto-run if needed).
  uninstall         Remove installed files from BIN_DIR.
  clean             Remove local build artifacts from build directory.
  service-install   Install and enable systemd service (${SERVICE_NAME:-vsegost-web}.service).
  service-status    Show systemd service status (${SERVICE_NAME:-vsegost-web}.service).
  service-uninstall Stop, disable and remove systemd service (${SERVICE_NAME:-vsegost-web}.service).

Environment_variables:
  BIN_DIR       Target directory for installation (default: /usr/local/bin)
  SERVICE_NAME  systemd unit base name (default: vsegost-web)
  SERVICE_USER  service user (default: current user)
  SESSION_NAME  tmux session name (default: vsegost-web)

$(echo_vars)

Examples:
  $(basename "$0")
  $(basename "$0") build
  $(basename "$0") clean
  BIN_DIR="${HOME}/.local/bin" $(basename "$0") install
EOF
}

# Detect system type and set up sudo prefix accordingly
# On MSYS2/Windows, sudo is not available and not needed
detect_system() {
    if (uname -o 2>/dev/null | grep -iq "msys\|mingw\|cygwin")
    then
        echo "msys2"
    else
        echo "linux"
    fi
}

service_supported() {
    if [ "${SYSTEM}" = "msys2" ]
    then
        return 1
    fi
    command -v systemctl >/dev/null 2>&1
}

service_usage() {
    if service_supported
    then
        echo "$(basename "$0") [service-install|service-status|service-uninstall]"
    fi
}

build_artifacts() {
  mkdir -p "${BUILD_DIR}"
  "${SH_DIR}/build.sh" "${BUILD_DIR}/vsegost-web.exe"
  cp "${SH_DIR}/vsegost-web.sh" "${BUILD_DIR}/"
  cp "${SH_DIR}/vsegost-web-tmux.sh" "${BUILD_DIR}/"
  cp "${SH_DIR}/mk-service.sh" "${BUILD_DIR}/"
}

install_artifacts() {
    if [[ ! -x "${BUILD_DIR}/vsegost-web.exe" ]]
    then
        echo "Standalone binary not found in ${BUILD_DIR}. Running build first."
        build_artifacts
    fi

  $SUDO install -m 0755 "${BUILD_DIR}/vsegost-web.exe" "${BIN_DIR}/vsegost-web.exe"
  $SUDO install -m 0755 "${SH_DIR}/vsegost-web.sh" "${BIN_DIR}/vsegost-web.sh"
  $SUDO install -m 0755 "${SH_DIR}/vsegost-web-tmux.sh" "${BIN_DIR}/vsegost-web-tmux.sh"
  $SUDO install -m 0755 "${SH_DIR}/mk-service.sh" "${BIN_DIR}/vsegost-web-mk-service.sh"
}

uninstall_artifacts() {
    $SUDO rm -f \
          "${BIN_DIR}/vsegost-web.exe" \
          "${BIN_DIR}/vsegost-web.sh" \
          "${BIN_DIR}/vsegost-web-tmux.sh" \
          "${BIN_DIR}/vsegost-web-mk-service.sh"
}

service_install() {
  local mk_service_cmd
  mk_service_cmd="${BIN_DIR}/vsegost-web-mk-service.sh"

  if ! service_supported
  then
      echo "systemd/systemctl is not available on this system." >&2
      exit 1
  fi

  if [[ ! -x "${mk_service_cmd}" ]]; then
    echo "${mk_service_cmd} not found. Running install first."
    install_artifacts
  fi

  SERVICE_NAME="${SERVICE_NAME:-vsegost-web}" \
  SERVICE_USER="${SERVICE_USER:-${USER}}" \
  SESSION_NAME="${SESSION_NAME:-vsegost-web}" \
  TMUX_SCRIPT="${BIN_DIR}/vsegost-web-tmux.sh" \
  "${mk_service_cmd}"

  echo "Starting service ${SERVICE_NAME:-vsegost-web}"
  $SUDO systemctl start "${SERVICE_NAME:-vsegost-web}"
}

service_uninstall() {
  local service_name
  local unit_path
  service_name="${SERVICE_NAME:-vsegost-web}"
  unit_path="/etc/systemd/system/${service_name}.service"

  if ! service_supported; then
    echo "systemd/systemctl is not available on this system." >&2
    exit 1
  fi

  $SUDO systemctl stop "${service_name}" || true
  $SUDO systemctl disable "${service_name}" || true
  $SUDO rm -f "${unit_path}"
  $SUDO systemctl daemon-reload
  echo "Removed service: ${service_name}.service"
}

service_status() {
  local service_name
  service_name="${SERVICE_NAME:-vsegost-web}"

  if ! service_supported; then
    echo "systemd/systemctl is not available on this system." >&2
    exit 1
  fi

  systemctl status "${service_name}"
}

clean_artifacts() {
    if [[ -d "${BUILD_DIR}" ]]
    then
        find "${BUILD_DIR}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
    fi
}

# Вывод значений глобальных переменных
echo_vars() {
    echo "Environment_variables_values:"
    echo "  PROJECT_ROOT:${PROJECT_ROOT}"
    echo "  SH_DIR      :${SH_DIR}"
    echo "  BUILD_DIR   :${BUILD_DIR}"
    echo "  BIN_DIR     :${BIN_DIR}"
    
    echo "  SERVICE_NAME:${SERVICE_NAME}"
    echo "  SERVICE_USER:${SERVICE_USER}"
    echo "  SESSION_NAME:${SESSION_NAME}"
    echo "  TMUX_SCRIPT :${TMUX_SCRIPT}"
    
    echo "  MODE        :${MODE}"
}

echo_start() {
    echo "${BASH_SOURCE[0]} START ..."
}

echo_done() {
    echo "${BASH_SOURCE[0]} DONE"
}

##################################################
#### Установка глобальных переменных

echo_start

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SH_DIR="${PROJECT_ROOT}/src/web/sh"
BUILD_DIR="${SH_DIR}/build"
BIN_DIR="${BIN_DIR:-/usr/local/bin}"

SERVICE_NAME="${SERVICE_NAME:-vsegost-web}"
SERVICE_USER="${SERVICE_USER:-${USER}}"
SESSION_NAME="${SESSION_NAME:-vsegost-web}"

TMUX_SCRIPT="${BIN_DIR}/vsegost-web-tmux.sh"

MODE="${1:---help}"

##################################################
#### Разбор аргументов

SYSTEM="$(detect_system)"

if [ "$SYSTEM" = "msys2" ]
then  SUDO=""
else  SUDO="sudo"
fi

case "${MODE}" in
    -h|--help|help)
        usage
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
    service-install)
        service_install
        ;;
    service-status)
        service_status
        ;;
    service-uninstall)
        service_uninstall
        ;;
    *)
        echo "Unknown mode: ${MODE}" >&2
        usage
    exit 1
    ;;
esac
echo_vars
echo_done
