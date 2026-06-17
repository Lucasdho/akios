#!/usr/bin/env bash
# Plug the agentic-kit meta-system into a target repo.
# Usage: ./install.sh /path/to/repo
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:?usage: install.sh /path/to/repo}"
[ -d "$TARGET" ] || { echo "not a directory: $TARGET" >&2; exit 1; }

# 1. Context files — never clobber an existing one.
for f in AGENTS.md Context.md Memory.md; do
  if [ -e "$TARGET/$f" ]; then
    echo "skip  $f (already exists)"
  else
    cp "$KIT/templates/$f" "$TARGET/$f"
    echo "added $f"
  fi
done

# 2. Reinforcement hook.
mkdir -p "$TARGET/.claude/hooks"
cp "$KIT/hook/agentic-kit-inject.sh" "$TARGET/.claude/hooks/"
chmod +x "$TARGET/.claude/hooks/agentic-kit-inject.sh"

# 3. Wire the SessionStart hook into .claude/settings.json (idempotent).
SETTINGS="$TARGET/.claude/settings.json"
CMD='bash "$CLAUDE_PROJECT_DIR/.claude/hooks/agentic-kit-inject.sh"'
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
if grep -q agentic-kit-inject "$SETTINGS"; then
  echo "hook already wired"
elif command -v jq >/dev/null; then
  tmp="$(mktemp)"
  jq --arg cmd "$CMD" \
    '.hooks.SessionStart += [ { "hooks": [ { "type":"command", "command":$cmd } ] } ]' \
    "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  echo "wired SessionStart hook"
else
  # ponytail: jq missing is rare; print the snippet instead of shipping a JSON parser
  echo "jq not found — add this to $SETTINGS under hooks.SessionStart:"
  echo "  $CMD"
fi

# 4. Self-check: the install is only done if every artifact landed.
for f in AGENTS.md Context.md Memory.md .claude/hooks/agentic-kit-inject.sh; do
  [ -e "$TARGET/$f" ] || { echo "FAIL: missing $TARGET/$f" >&2; exit 1; }
done
echo "ok — agentic-kit installed in $TARGET (fill in the {{...}} placeholders)"
