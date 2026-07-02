#!/usr/bin/env bash
# Idempotently register a kit-authored skill into scripts/install-skills.sh's SKILLS array,
# then re-run install-skills.sh to install it into ~/.claude/skills/ and smoke-test it.
#
# This is the deterministic half of skill registration (specs/skill-authoring.md §1/§7) — the
# `skill-author` skill calls this instead of hand-editing the array as an LLM string edit,
# which is exactly the mistake Context.md's "Gotchas" section names as most common in this kit.
#
# Usage: scripts/register-skill.sh <skill-name>
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "usage: $(basename "$0") <skill-name>" >&2
  exit 1
fi

NAME="$1"
KIT="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL_SH="$KIT/scripts/install-skills.sh"

if [ ! -d "$KIT/skills/$NAME" ]; then
  echo "FAIL: skills/$NAME does not exist — scaffold the skill before registering it" >&2
  exit 1
fi

if grep -E "^SKILLS=\(" "$INSTALL_SH" | grep -qE "(^|[[:space:]\(])${NAME}([[:space:]\)]|$)"; then
  echo "already registered: $NAME (no edit needed)"
else
  awk -v name="$NAME" '
    /^SKILLS=\(/ && !done { sub(/\)$/, " " name ")"); done=1 }
    { print }
  ' "$INSTALL_SH" > "$INSTALL_SH.tmp" && mv "$INSTALL_SH.tmp" "$INSTALL_SH"
  chmod +x "$INSTALL_SH"
  echo "registered $NAME -> $INSTALL_SH"
fi

echo "running install-skills.sh (install + smoke-test)..."
bash "$INSTALL_SH"
