#!/usr/bin/env bash
# Sanity check: the authored skills and install templates are all present and
# well-formed. Catches a missing skill or template before it fails at runtime.
set -euo pipefail

KIT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0

# 1. Authored skills present with a name: frontmatter line.
for s in idea-to-spec oss-first ios-feature-pipeline ios-agentic-kit; do
  f="$KIT/skills/$s/SKILL.md"
  if [ ! -f "$f" ]; then
    echo "FAIL: missing skill: skills/$s/SKILL.md"; fail=1
  elif ! grep -qE '^name:[[:space:]]*'"$s"'[[:space:]]*$' "$f"; then
    echo "FAIL: skills/$s/SKILL.md has no 'name: $s' frontmatter"; fail=1
  else
    echo "ok   skills/$s"
  fi
done

# 2. Install templates + hook present.
for f in templates/AGENTS.md templates/Context.md templates/CLAUDE.md \
         templates/rules/swift.md templates/workflows/ios-feature-pipeline.yml \
         scripts/hook/agentic-kit-inject.sh; do
  if [ -e "$KIT/$f" ]; then echo "ok   $f"
  else echo "FAIL: missing $f"; fail=1; fi
done

[ "$fail" -eq 0 ] && echo "ok — kit is consistent" || { echo "kit has missing artifacts" >&2; exit 1; }
