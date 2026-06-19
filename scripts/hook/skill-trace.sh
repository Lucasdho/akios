#!/usr/bin/env bash
# skill-trace.sh — PostToolUse hook. Appends a one-line JSON record to
# .akios/trace.jsonl whenever a Skill loads or a skill/reference file is read,
# with a cheap `git diff --shortstat` snapshot for a before/after delta.
#
# ponytail: snapshot is git shortstat only — NO test runs here (a hook firing
# on every tool call must stay instant). The real test pass/fail before/after
# signal is written by `task-execution` at [major] checkpoints, where the
# battery runs anyway. Disclosure reads are filtered to skill/reference files
# so the trace shows progressive disclosure, not every app-file Read.
# Upgrade path: widen the Read filter below to log all reads if you want them.

set -euo pipefail

input="$(cat)"                       # PostToolUse passes JSON on stdin
root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
out="$root/.akios/trace.jsonl"

# --- extract fields (jq if present, else a grep fallback) ---
if command -v jq >/dev/null 2>&1; then
  tool="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
  skill="$(printf '%s' "$input" | jq -r '.tool_input.skill // empty')"
  file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
else
  tool="$(printf '%s' "$input" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')"
  skill="$(printf '%s' "$input" | grep -o '"skill"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')"
  file="$(printf '%s' "$input" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')"
fi

ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
stat="$(git -C "$root" diff --shortstat 2>/dev/null | tr -d '\n' | sed 's/"/\\"/g' || true)"

emit() { mkdir -p "$root/.akios"; printf '%s\n' "$1" >> "$out"; }

case "$tool" in
  Skill)
    [ -n "$skill" ] && emit "{\"ts\":\"$ts\",\"event\":\"skill\",\"name\":\"$skill\",\"diff\":\"$stat\"}"
    ;;
  Read)
    # only skill-internal disclosure (SKILL.md or a references/ file), not app source
    case "$file" in
      *SKILL.md|*/references/*) emit "{\"ts\":\"$ts\",\"event\":\"disclosure\",\"file\":\"$file\"}" ;;
    esac
    ;;
esac

exit 0
