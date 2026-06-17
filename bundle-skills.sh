#!/usr/bin/env bash
# Bundle the skills this kit references into skills/ + a zip, for the repo.
# Built-in Claude Code skills (code-review, fewer-permission-prompts) ship with
# the CLI and are NOT bundled — see SKILLS-USED.md.
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"
CC="$HOME/.claude"
OUT="$KIT/skills"
rm -rf "$OUT"; mkdir -p "$OUT"

# name -> source dir (deref symlinks with cp -RL)
add() {
  local name="$1" src="$2"
  if [ -e "$src" ]; then cp -RL "$src" "$OUT/$name"; echo "bundled $name"
  else echo "MISSING  $name ($src)" >&2; fi
}

add swift-dev            "$CC/skills/swift-dev"
add swiftui-design-skill "$CC/skills/swiftui-design-skill"
add ponytail             "$CC/plugins/cache/ponytail"
add superpowers          "$CC/plugins/cache/superpowers-marketplace/superpowers"

( cd "$KIT" && zip -rq skills-bundle.zip skills )
echo "ok -> $KIT/skills-bundle.zip ($(du -sh "$KIT/skills-bundle.zip" | cut -f1))"
