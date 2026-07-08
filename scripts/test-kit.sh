#!/usr/bin/env bash
# Sanity check: the authored skills and install templates are all present and
# well-formed. Catches a missing skill or template before it fails at runtime.
set -euo pipefail

KIT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0

# 1. Authored skills present with a name: frontmatter line.
for s in idea-to-spec oss-first ios-feature-pipeline ios-agentic-kit spec-to-tasks task-execution swift-dev; do
  f="$KIT/skills/$s/SKILL.md"
  if [ ! -f "$f" ]; then
    echo "FAIL: missing skill: skills/$s/SKILL.md"; fail=1
  elif ! grep -qE '^name:[[:space:]]*'"$s"'[[:space:]]*$' "$f"; then
    echo "FAIL: skills/$s/SKILL.md has no 'name: $s' frontmatter"; fail=1
  else
    echo "ok   skills/$s"
  fi
done

# 2. Install templates + phase contract + hook present.
for f in templates/AGENTS.md templates/Context.md templates/CLAUDE.md \
         templates/Roadmap.md templates/spec.md templates/task.md templates/preferences.seed.md \
         templates/rules/swift.md akios/workflow.yml \
         scripts/hook/agentic-kit-inject.sh scripts/hook/skill-trace.sh; do
  if [ -e "$KIT/$f" ]; then echo "ok   $f"
  else echo "FAIL: missing $f"; fail=1; fi
done

# 3. Plugin artifacts: manifests parse, plugin is named akios, commands present.
if command -v jq >/dev/null; then
  for m in .claude-plugin/plugin.json .claude-plugin/marketplace.json .codex-plugin/plugin.json; do
    if jq -e . "$KIT/$m" >/dev/null 2>&1; then echo "ok   $m"
    else echo "FAIL: $m missing or not valid JSON"; fail=1; fi
  done
  claude_name="$(jq -r '.name // empty' "$KIT/.claude-plugin/plugin.json" 2>/dev/null || true)"
  [ "$claude_name" = "akios" ] || { echo "FAIL: .claude-plugin/plugin.json name is '$claude_name', expected 'akios'"; fail=1; }
  codex_name="$(jq -r '.name // empty' "$KIT/.codex-plugin/plugin.json" 2>/dev/null || true)"
  [ "$codex_name" = "akios" ] || { echo "FAIL: .codex-plugin/plugin.json name is '$codex_name', expected 'akios'"; fail=1; }
  codex_skills="$(jq -r '.skills // empty' "$KIT/.codex-plugin/plugin.json" 2>/dev/null || true)"
  [ "$codex_skills" = "./skills/" ] || { echo "FAIL: .codex-plugin/plugin.json skills is '$codex_skills', expected './skills/'"; fail=1; }
  version="$(tr -d '[:space:]' < "$KIT/VERSION")"
  codex_version="$(jq -r '.version // empty' "$KIT/.codex-plugin/plugin.json" 2>/dev/null || true)"
  claude_version="$(jq -r '.version // empty' "$KIT/.claude-plugin/plugin.json" 2>/dev/null || true)"
  echo "$codex_version" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+([+-][0-9A-Za-z.-]+)?$' || { echo "FAIL: .codex-plugin/plugin.json version '$codex_version' is not semver"; fail=1; }
  [ "$codex_version" = "$version" ] || { echo "FAIL: .codex-plugin/plugin.json version '$codex_version' does not match VERSION '$version'"; fail=1; }
  [ "$claude_version" = "$version" ] || { echo "FAIL: .claude-plugin/plugin.json version '$claude_version' does not match VERSION '$version'"; fail=1; }
else
  echo "warn jq not found — skipping plugin manifest JSON validation"
fi
for c in setup brainstorm plan deliver; do
  f="$KIT/commands/$c.md"
  if [ ! -f "$f" ]; then
    echo "FAIL: missing command: commands/$c.md"; fail=1
  elif ! grep -qE '^description:[[:space:]]*.+' "$f"; then
    echo "FAIL: commands/$c.md has no 'description:' frontmatter"; fail=1
  else
    echo "ok   commands/$c.md"
  fi
done

[ "$fail" -eq 0 ] && echo "ok — kit is consistent" || { echo "kit has missing artifacts" >&2; exit 1; }
