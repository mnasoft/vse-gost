#!/usr/bin/env bash
set -euo pipefail

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux is required but not installed." >&2
  echo "Install tmux and run again." >&2
  exit 1
fi

SESSION_NAME="${SESSION_NAME:-vsegost-web}"
RUN_CMD="${RUN_CMD:-vsegost-web.sh}"
DEFAULT_EXE_CMD='vsegost-web.exe --eval "(vse-gost/web:start-gosts)"'
ACTION="${1:-start}"

is_msys2() {
  case "$(uname -s 2>/dev/null || true)" in
    MSYS*|MINGW*|CYGWIN*) return 0 ;;
    *) return 1 ;;
  esac
}

start_postgresql_msys2() {
  local pg_ctl_cmd
  pg_ctl_cmd="${PG_CTL_CMD:-D:/home/_namatv/PRG/msys64/ucrt64/bin/pg_ctl}"
  local pg_data
  pg_data="${PGDATA_DIR:-D:/home/_namatv/PRG/msys64/var/lib/postgres/data}"
  local pg_log
  pg_log="${PG_LOG_FILE:-journal.log}"

  if [[ ! -x "${pg_ctl_cmd}" ]]; then
    if command -v pg_ctl >/dev/null 2>&1; then
      pg_ctl_cmd="$(command -v pg_ctl)"
    else
      echo "MSYS2 detected, but pg_ctl was not found. Skipping PostgreSQL start." >&2
      return 0
    fi
  fi

  (cd "${HOME}" && "${pg_ctl_cmd}" -D "${pg_data}" -l "${pg_log}" stop || true)
  (cd "${HOME}" && "${pg_ctl_cmd}" -D "${pg_data}" -l "${pg_log}" start)
}

if [[ "${RUN_CMD}" == "vsegost-web.sh" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [[ -x "${SCRIPT_DIR}/vsegost-web.sh" ]]; then
    RUN_CMD="${SCRIPT_DIR}/vsegost-web.sh"
  elif command -v vsegost-web.sh >/dev/null 2>&1; then
    RUN_CMD="$(command -v vsegost-web.sh)"
  else
    RUN_CMD="${DEFAULT_EXE_CMD}"
  fi
fi

start_session() {
  if tmux has-session -t "${SESSION_NAME}" 2>/dev/null; then
    echo "tmux session '${SESSION_NAME}' already exists."
    echo "Attach with: tmux attach -t ${SESSION_NAME}"
    return 0
  fi

  if is_msys2 && [[ "${START_POSTGRES_ON_MSYS2:-1}" == "1" ]]; then
    start_postgresql_msys2
  fi

  tmux new-session -d -s "${SESSION_NAME}" "bash -lc '${RUN_CMD}'"

  sleep 0.2
  if ! tmux has-session -t "${SESSION_NAME}" 2>/dev/null; then
    echo "Failed to start tmux session '${SESSION_NAME}'." >&2
    echo "Check command: ${RUN_CMD}" >&2
    return 1
  fi

  echo "Started tmux session: ${SESSION_NAME}"
  echo "Attach with: tmux attach -t ${SESSION_NAME}"
}

stop_session() {
  if ! tmux has-session -t "${SESSION_NAME}" 2>/dev/null; then
    echo "tmux session '${SESSION_NAME}' is not running."
    return 0
  fi

  tmux kill-session -t "${SESSION_NAME}"
  echo "Stopped tmux session: ${SESSION_NAME}"
}

status_session() {
  if tmux has-session -t "${SESSION_NAME}" 2>/dev/null; then
    echo "running"
    return 0
  fi

  echo "stopped"
  return 1
}

case "${ACTION}" in
  start)
    start_session
    ;;
  stop)
    stop_session
    ;;
  status)
    status_session
    ;;
  restart)
    stop_session
    start_session
    ;;
  *)
    echo "Usage: $(basename "$0") [start|stop|status|restart]" >&2
    exit 2
    ;;
esac
