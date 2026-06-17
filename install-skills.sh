#!/usr/bin/env bash
# Install the plain skills this kit needs into ~/.claude/skills/ from the bundle.
# Plugins (ponytail, superpowers) are NOT copied here — install them via their
# marketplaces so their hooks/commands register. Commands printed at the end.
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.claude/skills"
mkdir -p "$DEST"

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
unzip -q "$KIT/skills-bundle.zip" -d "$TMP"

for s in swift-dev swiftui-design-skill; do
  if [ -e "$DEST/$s" ]; then
    echo "skip      $s (already in ~/.claude/skills)"
  else
    cp -R "$TMP/skills/$s" "$DEST/$s"
    echo "installed $s -> ~/.claude/skills/$s"
  fi
done

# check
for s in swift-dev swiftui-design-skill; do
  [ -f "$DEST/$s/SKILL.md" ] || { echo "FAIL: $s has no SKILL.md" >&2; exit 1; }
done

cat <<'EOF'

Plugins — install via marketplaces inside Claude Code (registers hooks/commands):
  /plugin marketplace add DietrichGebert/ponytail   ->  /plugin install ponytail
  /plugin marketplace add obra/superpowers          ->  /plugin install superpowers

ok — plain skills installed; install the two plugins above.
EOF
