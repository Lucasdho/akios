#!/usr/bin/env bash
# akios instance signature — a stable identity for THIS akios instance, so a teammate's
# akios can recognize work (claims, commits) made by another akios instance vs a human.
#
# Generated once, then cached at ~/.claude/akios/instance.id (survives sessions + plugin
# updates; it's per-machine, not per-repo). Format:
#     <git-user>@<host>/<short-uuid>      e.g.  lucas@mbp/3f2a9c
#
# Usage:
#   akios-instance.sh            -> print the signature (generate + cache if absent)
#   akios-instance.sh --trailer  -> print the git commit trailer line
#   akios-instance.sh --id       -> print just the short id
set -euo pipefail

ID_DIR="$HOME/.claude/akios"
ID_FILE="$ID_DIR/instance.id"

generate() {
  local user host uuid
  user="$(git config user.name 2>/dev/null || true)"
  [ -z "$user" ] && user="$(git config user.email 2>/dev/null | cut -d@ -f1 || true)"
  [ -z "$user" ] && user="${USER:-dev}"
  user="$(printf '%s' "$user" | tr ' ' '-' | tr -cd '[:alnum:]._-')"
  host="$(hostname -s 2>/dev/null || hostname 2>/dev/null || echo host)"
  host="$(printf '%s' "$host" | tr -cd '[:alnum:].-')"
  if command -v uuidgen >/dev/null 2>&1; then
    uuid="$(uuidgen | tr 'A-Z' 'a-z' | tr -d - | cut -c1-6)"
  else
    uuid="$(head -c 4 /dev/urandom 2>/dev/null | od -An -tx1 | tr -d ' \n' | cut -c1-6)"
    [ -z "$uuid" ] && uuid="$(date +%s | tail -c 6)"
  fi
  printf '%s@%s/%s' "$user" "$host" "$uuid"
}

# Read-or-create (atomic enough: first writer wins; concurrent runs are idempotent per machine).
if [ ! -s "$ID_FILE" ]; then
  mkdir -p "$ID_DIR"
  generate > "$ID_FILE"
fi
SIG="$(cat "$ID_FILE")"

case "${1:-}" in
  --trailer) printf 'Akios-Instance: %s\n' "$SIG" ;;
  --id)      printf '%s\n' "${SIG##*/}" ;;
  *)         printf '%s\n' "$SIG" ;;
esac
