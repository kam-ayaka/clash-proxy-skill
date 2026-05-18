#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  install.sh [--target <skills-dir>] [--force]
  install.sh --help

Install the clash-proxy skill into a Codex skills directory.

Options:
  --target <skills-dir>  Override the default skills directory
  --force                Replace an existing clash-proxy skill
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_NAME="clash-proxy"
SOURCE_DIR="${SCRIPT_DIR}/${SKILL_NAME}"
TARGET_ROOT="${CODEX_HOME:-$HOME/.codex}/skills"
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      if [[ $# -lt 2 ]]; then
        echo "Error: --target requires a value." >&2
        exit 2
      fi
      TARGET_ROOT="$2"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Error: source skill directory not found: $SOURCE_DIR" >&2
  exit 1
fi

mkdir -p "$TARGET_ROOT"
DEST_DIR="${TARGET_ROOT}/${SKILL_NAME}"

if [[ -e "$DEST_DIR" ]]; then
  if [[ "$FORCE" -ne 1 ]]; then
    echo "Error: destination already exists: $DEST_DIR" >&2
    echo "Run again with --force to replace it." >&2
    exit 1
  fi
  rm -rf "$DEST_DIR"
fi

cp -a "$SOURCE_DIR" "$DEST_DIR"

echo "Installed ${SKILL_NAME} to ${DEST_DIR}"
