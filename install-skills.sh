#!/usr/bin/env bash
# Install the authored skills this kit owns into ~/.claude/skills/, straight from
# the repo tree (the repo is their source of truth). Kit-owned skills are
# REFRESHED on every run so installed copies never drift — re-run after a pull.
# Plugins (ponytail, superpowers, axiom) are NOT copied here; install them via
# their marketplaces so their hooks/commands register. Commands printed at the end.
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"
SRC="$KIT/skills"
DEST="$HOME/.claude/skills"
mkdir -p "$DEST"

SKILLS=(idea-to-spec oss-first ios-feature-pipeline ios-agentic-kit)

for s in "${SKILLS[@]}"; do
  if [ -d "$SRC/$s" ]; then
    rm -rf "$DEST/$s"            # refresh: repo is canonical, overwrite any drift
    cp -R "$SRC/$s" "$DEST/$s"
    echo "installed $s -> ~/.claude/skills/$s"
  else
    echo "MISSING   $s — not in repo at $SRC/$s (re-clone the kit)" >&2
    exit 1
  fi
done

# check
for s in "${SKILLS[@]}"; do
  [ -f "$DEST/$s/SKILL.md" ] || { echo "FAIL: $s did not install" >&2; exit 1; }
done

cat <<'EOF'

Plugins — install via their marketplaces inside Claude Code if not already present.
Required:
  /plugin marketplace add obra/superpowers          ->  /plugin install superpowers
  /plugin marketplace add CharlesWiltgen/Axiom      ->  /plugin install axiom
Optional (recommended — efficiency overlay; the kit works without it):
  /plugin marketplace add DietrichGebert/ponytail   ->  /plugin install ponytail

ok — authored skills refreshed; install the required plugins above if missing.
EOF
