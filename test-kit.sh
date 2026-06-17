#!/usr/bin/env bash
# Sanity check: every guide the swift-dev router points at must exist in the
# bundle, and the top-level skills must be present. Catches upstream renames
# that would otherwise fail silently at runtime.
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"
[ -f "$KIT/skills-bundle.zip" ] || { echo "FAIL: skills-bundle.zip missing (run ./bundle-skills.sh)" >&2; exit 1; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
unzip -q "$KIT/skills-bundle.zip" -d "$TMP"
SD="$TMP/skills/swift-dev"
fail=0

# 1. Top-level skills present.
for s in swift-dev idea-to-spec oss-first ponytail superpowers; do
  [ -d "$TMP/skills/$s" ] || { echo "FAIL: top-level skill missing: $s"; fail=1; }
done

# 2. Every `skills/<name>/GUIDE.md` the router references must exist.
[ -f "$SD/SKILL.md" ] || { echo "FAIL: swift-dev/SKILL.md missing"; exit 1; }
refs=$(grep -oE 'skills/[A-Za-z0-9._-]+/GUIDE\.md' "$SD/SKILL.md" | sort -u)
[ -n "$refs" ] || { echo "FAIL: no guide references found in router (parser broke?)"; exit 1; }
while read -r ref; do
  if [ -f "$SD/$ref" ]; then echo "ok   $ref"
  else echo "FAIL: router points at missing guide: $ref"; fail=1; fi
done <<< "$refs"

[ "$fail" -eq 0 ] && echo "ok — kit bundle is consistent" || { echo "kit bundle has broken references" >&2; exit 1; }
