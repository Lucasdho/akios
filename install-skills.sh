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

# Fallback source per plain skill, in case it's missing from the bundle.
fallback() {
  case "$1" in
    idea-to-spec|oss-first|ios-feature-pipeline)
      echo "npx skills add Lucasdho/iOS-agentic-kit --skill $1  (or re-clone the kit and re-run)" ;;
    *) echo "(no known source)" ;;
  esac
}

for s in idea-to-spec oss-first ios-feature-pipeline; do
  if [ -e "$DEST/$s" ]; then
    echo "skip      $s (already in ~/.claude/skills)"
  elif [ -d "$TMP/skills/$s" ]; then
    cp -R "$TMP/skills/$s" "$DEST/$s"
    echo "installed $s -> ~/.claude/skills/$s"
  else
    echo "MISSING   $s — not in the bundle. Install it with:"
    echo "          $(fallback "$s")"
  fi
done

# check
for s in idea-to-spec oss-first ios-feature-pipeline; do
  [ -f "$DEST/$s/SKILL.md" ] || {
    echo "FAIL: $s is not installed. Get it with: $(fallback "$s")" >&2; exit 1; }
done

cat <<'EOF'

Plugins — if NOT already installed, add them via their marketplaces inside Claude Code:
  /plugin marketplace add DietrichGebert/ponytail   ->  /plugin install ponytail
  /plugin marketplace add obra/superpowers          ->  /plugin install superpowers
  /plugin marketplace add CharlesWiltgen/Axiom      ->  /plugin install axiom

ok — plain skills handled; if any plugin above is missing, run its commands.
EOF
