#!/usr/bin/env bash
set -euo pipefail

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux is required but not installed." >&2
  echo "Install tmux and run again." >&2
  exit 1
fi

SESSION_NAME="${SESSION_NAME:-vsegost-web}"
RUN_CMD="${RUN_CMD:-vsegost-web.sh}"

if [[ "${RUN_CMD}" == "vsegost-web.sh" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [[ -x "${SCRIPT_DIR}/vsegost-web.sh" ]]; then
    RUN_CMD="${SCRIPT_DIR}/vsegost-web.sh"
  elif command -v vsegost-web.sh >/dev/null 2>&1; then
    RUN_CMD="$(command -v vsegost-web.sh)"
  fi
fi

if tmux has-session -t "${SESSION_NAME}" 2>/dev/null; then
  echo "tmux session '${SESSION_NAME}' already exists."
  echo "Attach with: tmux attach -t ${SESSION_NAME}"
  exit 0
fi

tmux new-session -d -s "${SESSION_NAME}" "bash -lc '${RUN_CMD}'"

sleep 0.2
if ! tmux has-session -t "${SESSION_NAME}" 2>/dev/null; then
  echo "Failed to start tmux session '${SESSION_NAME}'." >&2
  echo "Check command: ${RUN_CMD}" >&2
  exit 1
fi

echo "Started tmux session: ${SESSION_NAME}"
echo "Attach with: tmux attach -t ${SESSION_NAME}"
