#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  with_proxy.sh <command> [args...]
  with_proxy.sh --print-env

Detect a working Clash proxy and run the given command with proxy env vars.
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DETECT_SCRIPT="${SCRIPT_DIR}/detect_proxy.sh"

if [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

proxy_exports="$("$DETECT_SCRIPT")"

if [[ "${1:-}" == "--print-env" ]]; then
  printf '%s\n' "$proxy_exports"
  exit 0
fi

if [[ "$#" -eq 0 ]]; then
  usage >&2
  exit 2
fi

eval "$proxy_exports"

exec env \
  HTTP_PROXY="$HTTP_PROXY" \
  HTTPS_PROXY="$HTTPS_PROXY" \
  ALL_PROXY="$ALL_PROXY" \
  http_proxy="$http_proxy" \
  https_proxy="$https_proxy" \
  all_proxy="$all_proxy" \
  "$@"
