#!/usr/bin/env bash
# Plug the agentic-kit meta-system into a target repo.
# Usage: ./install.sh /path/to/repo
set -euo pipefail

KIT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(cat "$KIT/VERSION" 2>/dev/null || echo unknown)"

# Args: [--here] /path/to/repo. By default the kit installs at the git repo root
# (where Claude Code loads CLAUDE.md from); --here installs at the exact path.
HERE=0; args=()
for a in "$@"; do
  case "$a" in --here) HERE=1 ;; *) args+=("$a") ;; esac
done
TARGET="${args[0]:?usage: install.sh [--here] /path/to/repo}"
[ -d "$TARGET" ] || { echo "not a directory: $TARGET" >&2; exit 1; }

if [ "$HERE" -eq 0 ]; then
  GITROOT="$(git -C "$TARGET" rev-parse --show-toplevel 2>/dev/null || true)"
  if [ -n "$GITROOT" ] && [ "$GITROOT" != "$(cd "$TARGET" && pwd)" ]; then
    echo "note: installing at git root $GITROOT (pass --here to install in the given dir instead)"
    TARGET="$GITROOT"
  fi
fi

# 1. Context files — never clobber an existing one.
for f in AGENTS.md Context.md; do
  if [ -e "$TARGET/$f" ]; then
    echo "skip  $f (already exists)"
  else
    cp "$KIT/templates/$f" "$TARGET/$f"
    echo "added $f"
  fi
done

# 2. CLAUDE.md — the file Claude Code actually auto-loads. Make it import the
#    operating manual (@AGENTS.md) and the project context (@Context.md).
if [ ! -e "$TARGET/CLAUDE.md" ]; then
  cp "$KIT/templates/CLAUDE.md" "$TARGET/CLAUDE.md"
  echo "added CLAUDE.md (imports @AGENTS.md, @Context.md)"
else
  # ensure each import exists; prepend whichever is missing (Context first so
  # AGENTS ends up on top). Handles upgrades from a CLAUDE.md that only had AGENTS.
  for imp in '@Context.md' '@AGENTS.md'; do
    if grep -qF "$imp" "$TARGET/CLAUDE.md"; then
      echo "skip  CLAUDE.md (already imports $imp)"
    else
      printf '%s\n%s' "$imp" "$(cat "$TARGET/CLAUDE.md")" > "$TARGET/CLAUDE.md"
      echo "patched CLAUDE.md (prepended $imp import)"
    fi
  done
fi

# 3. Path-scoped rule: load the Swift gate whenever a .swift file is read.
mkdir -p "$TARGET/.claude/rules"
if [ -e "$TARGET/.claude/rules/swift.md" ]; then
  echo "skip  .claude/rules/swift.md (already exists)"
else
  cp "$KIT/templates/rules/swift.md" "$TARGET/.claude/rules/swift.md"
  echo "added .claude/rules/swift.md (paths: **/*.swift)"
fi

# 4. Reinforcement hook.
mkdir -p "$TARGET/.claude/hooks"
cp "$KIT/scripts/hook/agentic-kit-inject.sh" "$TARGET/.claude/hooks/"
chmod +x "$TARGET/.claude/hooks/agentic-kit-inject.sh"

# 5. Wire the SessionStart hook into .claude/settings.json (idempotent).
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

# 6. Stamp the installed version (check-update.sh compares against the kit VERSION).
echo "$VERSION" > "$TARGET/.claude/.agentic-kit-version"
echo "stamped version $VERSION"

# 7. Self-check: the install is only done if every artifact landed.
for f in AGENTS.md Context.md CLAUDE.md .claude/.agentic-kit-version \
         .claude/rules/swift.md .claude/hooks/agentic-kit-inject.sh; do
  [ -e "$TARGET/$f" ] || { echo "FAIL: missing $TARGET/$f" >&2; exit 1; }
done
for imp in '@AGENTS.md' '@Context.md'; do
  grep -qF "$imp" "$TARGET/CLAUDE.md" || { echo "FAIL: CLAUDE.md does not import $imp" >&2; exit 1; }
done
# Warn if the SessionStart hook was never wired (jq absent and user hasn't added it manually).
if ! grep -q agentic-kit-inject "$TARGET/.claude/settings.json" 2>/dev/null; then
  echo "WARNING: SessionStart hook not wired in .claude/settings.json — add it manually:" >&2
  echo "  bash \"\$CLAUDE_PROJECT_DIR/.claude/hooks/agentic-kit-inject.sh\"" >&2
fi
echo "ok — agentic-kit installed in $TARGET (fill in the {{...}} placeholders)"
