#!/usr/bin/env bash
# Check whether the kit clone and a project's install are up to date.
# Usage: check-update.sh [project-dir]   (defaults to the current directory)
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"
VERSION="$(cat "$KIT/VERSION" 2>/dev/null || echo unknown)"
stale=0

# 1. Is this kit clone behind its GitHub remote?
if git -C "$KIT" rev-parse --git-dir >/dev/null 2>&1; then
  git -C "$KIT" fetch -q 2>/dev/null || echo "kit:     (could not fetch remote — check network/auth)"
  local_rev="$(git -C "$KIT" rev-parse HEAD)"
  remote_rev="$(git -C "$KIT" rev-parse '@{u}' 2>/dev/null || echo "")"
  if [ -n "$remote_rev" ] && [ "$local_rev" != "$remote_rev" ]; then
    echo "kit:     BEHIND remote (VERSION $VERSION) — run: git -C \"$KIT\" pull"
    stale=1
  else
    echo "kit:     up to date (VERSION $VERSION)"
  fi
else
  echo "kit:     not a git clone — can't check remote (VERSION $VERSION)"
fi

# 2. Is the target project's install behind this kit?
TARGET="${1:-.}"
ROOT="$(git -C "$TARGET" rev-parse --show-toplevel 2>/dev/null || echo "$TARGET")"
# stamp may live at the given dir (--here install) or at the git root (default)
STAMP=""
for d in "$TARGET" "$ROOT"; do
  [ -f "$d/.claude/.agentic-kit-version" ] && { STAMP="$d/.claude/.agentic-kit-version"; break; }
done

if [ -z "$STAMP" ]; then
  echo "project: no kit install found under $TARGET (or installed before versioning)"
  echo "         run: $KIT/install.sh \"$TARGET\""
  stale=1
else
  installed="$(cat "$STAMP")"
  if [ "$installed" = "$VERSION" ]; then
    echo "project: up to date ($(dirname "$(dirname "$STAMP")") @ $installed)"
  else
    echo "project: OUTDATED (installed $installed, kit is $VERSION)"
    echo "         re-run: $KIT/install.sh \"$(dirname "$(dirname "$STAMP")")\""
    stale=1
  fi
fi

exit "$stale"
