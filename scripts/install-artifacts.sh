#!/usr/bin/env bash
# Install the runnable artifacts this kit owns (full apps that skills drive live in the
# browser, e.g. data-modeling-canvas) into ~/.akios/artifacts/, straight from the repo tree
# (the repo is their source of truth). Unlike skills/ (markdown+docs, refreshed wholesale every
# run), artifacts/ ships real npm projects — source is refreshed on every run but node_modules/
# is preserved across runs and only installed once, so re-running this script doesn't force a
# multi-minute npm install every time.
#
# Usage: scripts/install-artifacts.sh
set -euo pipefail

KIT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$KIT/artifacts"
DEST="$HOME/.akios/artifacts"
mkdir -p "$DEST"

ARTIFACTS=(data-modeling-canvas)

for a in "${ARTIFACTS[@]}"; do
  if [ ! -d "$SRC/$a" ]; then
    echo "MISSING   $a — not in repo at $SRC/$a (re-clone the kit)" >&2
    exit 1
  fi
  mkdir -p "$DEST/$a"
  # refresh source, but never touch an already-installed node_modules/ or dist/
  rsync -a --delete --exclude node_modules --exclude dist "$SRC/$a/" "$DEST/$a/"
  echo "installed $a -> ~/.akios/artifacts/$a"

  if [ ! -d "$DEST/$a/node_modules" ]; then
    echo "installing dependencies for $a (first run only)..."
    (cd "$DEST/$a" && npm install)
  fi
done

# check
for a in "${ARTIFACTS[@]}"; do
  [ -f "$DEST/$a/package.json" ] || { echo "FAIL: $a did not install" >&2; exit 1; }
  [ -d "$DEST/$a/node_modules" ] || { echo "FAIL: $a dependencies missing" >&2; exit 1; }
done

cat <<'EOF'

ok — artifacts installed. Skills that drive a live app (e.g. data-modeling-canvas) start it with:
  cd ~/.akios/artifacts/<name> && npm run dev
EOF
