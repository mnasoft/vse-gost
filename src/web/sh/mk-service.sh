#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="${SERVICE_NAME:-vsegost-web}"
SERVICE_USER="${SERVICE_USER:-${USER}}"
SESSION_NAME="${SESSION_NAME:-vsegost-web}"
SYSTEMD_DIR="${SYSTEMD_DIR:-/etc/systemd/system}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMUX_SCRIPT_DEFAULT="${SCRIPT_DIR}/vsegost-web-tmux.sh"
TMUX_SCRIPT="${TMUX_SCRIPT:-${TMUX_SCRIPT_DEFAULT}}"

UNIT_PATH="${SYSTEMD_DIR}/${SERVICE_NAME}.service"
TMP_UNIT="$(mktemp)"

if [[ ! -x "${TMUX_SCRIPT}" ]]; then
	echo "Executable script not found: ${TMUX_SCRIPT}" >&2
	echo "Set TMUX_SCRIPT=<path> if needed." >&2
	exit 1
fi

cat > "${TMP_UNIT}" <<EOF
[Unit]
Description=${SERVICE_NAME} (tmux-managed)
After=network.target

[Service]
Type=oneshot
User=${SERVICE_USER}
WorkingDirectory=${SCRIPT_DIR}
Environment=SESSION_NAME=${SESSION_NAME}
ExecStart=${TMUX_SCRIPT} start
ExecStop=${TMUX_SCRIPT} stop
ExecReload=${TMUX_SCRIPT} restart
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

echo "Generated unit file:"
echo "----------------------------------------"
cat "${TMP_UNIT}"
echo "----------------------------------------"

echo "Installing ${UNIT_PATH}"
sudo install -m 0644 "${TMP_UNIT}" "${UNIT_PATH}"
rm -f "${TMP_UNIT}"

sudo systemctl daemon-reload
sudo systemctl enable "${SERVICE_NAME}.service"

echo
echo "Service installed: ${SERVICE_NAME}.service"
echo "Start:  sudo systemctl start ${SERVICE_NAME}"
echo "Stop:   sudo systemctl stop ${SERVICE_NAME}"
echo "Status: systemctl status ${SERVICE_NAME}"
