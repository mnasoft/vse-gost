#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Deprecated: use vsegost-web-tmux.sh instead of vsegost-web-screen.sh" >&2
exec "${SCRIPT_DIR}/vsegost-web-tmux.sh" "$@"

