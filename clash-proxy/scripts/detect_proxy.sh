#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  detect_proxy.sh
  detect_proxy.sh --help

Outputs shell export statements for a working proxy configuration.

Environment:
  CLASH_PROXY_HOST   Optional host to probe first
  CLASH_PROXY_PORT   Optional port to probe first
  CLASH_TEST_URL     URL used for connectivity checks
  CLASH_TIMEOUT_SECS Per-request timeout, default 8
EOF
}

if [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required for proxy detection." >&2
  exit 1
fi

TEST_URL="${CLASH_TEST_URL:-https://raw.githubusercontent.com}"
TIMEOUT="${CLASH_TIMEOUT_SECS:-8}"

shell_quote() {
  printf "%q" "$1"
}

emit_exports() {
  local proxy_url="$1"
  cat <<EOF
export HTTP_PROXY=$(shell_quote "$proxy_url")
export HTTPS_PROXY=$(shell_quote "$proxy_url")
export ALL_PROXY=$(shell_quote "$proxy_url")
export http_proxy=$(shell_quote "$proxy_url")
export https_proxy=$(shell_quote "$proxy_url")
export all_proxy=$(shell_quote "$proxy_url")
EOF
}

probe_via_http_proxy() {
  local host="$1"
  local port="$2"
  curl -fsSIL --max-time "$TIMEOUT" -x "http://${host}:${port}" "$TEST_URL" >/dev/null 2>&1
}

probe_via_socks_proxy() {
  local host="$1"
  local port="$2"
  curl -fsSIL --max-time "$TIMEOUT" --socks5-hostname "${host}:${port}" "$TEST_URL" >/dev/null 2>&1
}

probe_existing_env_proxy() {
  local candidate
  for candidate in "${HTTPS_PROXY:-}" "${HTTP_PROXY:-}" "${ALL_PROXY:-}" "${https_proxy:-}" "${http_proxy:-}" "${all_proxy:-}"; do
    if [[ -z "$candidate" ]]; then
      continue
    fi
    if env \
      HTTP_PROXY="$candidate" \
      HTTPS_PROXY="$candidate" \
      ALL_PROXY="$candidate" \
      http_proxy="$candidate" \
      https_proxy="$candidate" \
      all_proxy="$candidate" \
      curl -fsSIL --max-time "$TIMEOUT" "$TEST_URL" >/dev/null 2>&1; then
      emit_exports "$candidate"
      return 0
    fi
  done
  return 1
}

append_unique() {
  local value="$1"
  shift
  local item
  for item in "$@"; do
    if [[ "$item" == "$value" ]]; then
      return 1
    fi
  done
  return 0
}

default_gateway() {
  ip route 2>/dev/null | awk '/^default via / { print $3; exit }'
}

declare -a hosts=()
declare -a ports=()

if probe_existing_env_proxy; then
  exit 0
fi

if [[ -n "${CLASH_PROXY_HOST:-}" ]]; then
  hosts+=("${CLASH_PROXY_HOST}")
fi

hosts+=("127.0.0.1")

gateway="$(default_gateway || true)"
if [[ -n "${gateway:-}" ]] && append_unique "$gateway" "${hosts[@]}"; then
  hosts+=("$gateway")
fi

if [[ -n "${CLASH_PROXY_PORT:-}" ]]; then
  ports+=("${CLASH_PROXY_PORT}")
fi

for port in 7890 7897 9090; do
  if append_unique "$port" "${ports[@]}"; then
    ports+=("$port")
  fi
done

declare -a tried=()

for host in "${hosts[@]}"; do
  for port in "${ports[@]}"; do
    tried+=("http://${host}:${port}")
    if probe_via_http_proxy "$host" "$port"; then
      emit_exports "http://${host}:${port}"
      exit 0
    fi
    tried+=("socks5h://${host}:${port}")
    if probe_via_socks_proxy "$host" "$port"; then
      emit_exports "socks5h://${host}:${port}"
      exit 0
    fi
  done
done

{
  echo "Error: no working Clash proxy detected." >&2
  echo "Test URL: $TEST_URL" >&2
  echo "Tried endpoints:" >&2
  printf '  %s\n' "${tried[@]}" >&2
} 
exit 1
