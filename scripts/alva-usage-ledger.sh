#!/usr/bin/env bash
# ALVA Foundation usage ledger — strategy A (grep + git-hook).
# Doctrine: specs/alva-architecture-doctrine.md §6.4 (strategy A, upgrade path to B/C/D).
#
# Regenerates <repo>/Foundation/usage-ledger.json: a deterministic count of which
# Features/*/ reference which symbol, so task-execution can *read* promotion/demotion
# candidates instead of the agent guessing by grepping the whole repo (ALVA P6).
#
# Install as a git pre-commit hook (wired by /akios:setup — see commands/setup.md):
#   cp scripts/alva-usage-ledger.sh .git/hooks/pre-commit-alva-ledger   (or call it from
#   an existing pre-commit hook; don't clobber one the user already has)
#
# Imprecise by design (textual match, not the compiler's index — name collisions can
# over- or under-count). That's the accepted cost of strategy A: trivial, deterministic,
# proves the concept. Evolve to strategy B (compiler index, exact conformance counts for
# protocols) when the app outgrows this — see the doctrine section above. `oss-first`
# note: Swift has a maintained dead-code tool (periphery) that already walks the
# compiler's index — a natural strategy-B backend if/when this graduates. Strategy A here
# uses only `grep -r` (BSD + GNU compatible, always present) rather than ripgrep, matching
# akios's "no required external dependencies" default.
#
# Requires: grep, jq (the one soft dependency — skips quietly if missing). Exits 0 quietly
# if there's no Features/ tree (e.g. this repo, which ships the script but has no Swift
# slices itself).

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
FEATURES_DIR="$ROOT/Features"
FOUNDATION_DIR="$ROOT/Foundation"
LEDGER="$FOUNDATION_DIR/usage-ledger.json"

THRESHOLD_DESIGN="${ALVA_DESIGN_TOKEN_THRESHOLD:-2}"
THRESHOLD_CODE="${ALVA_CODE_TOKEN_THRESHOLD:-3}"

if ! command -v jq >/dev/null 2>&1; then
  echo "alva-usage-ledger: jq not found — skipping (install jq to enable)." >&2
  exit 0
fi
if [ ! -d "$FEATURES_DIR" ]; then
  exit 0   # no slices yet — nothing to ledger
fi

mkdir -p "$FOUNDATION_DIR"

feature_dirs() { find "$FEATURES_DIR" -mindepth 1 -maxdepth 1 -type d | sort; }

# Top-level struct/class/enum/protocol/func declarations under $1 (empty if dir has no matches).
declared_symbols_in() {
  local dir="$1"
  grep -rhEo --include='*.swift' \
    '(public |internal )?(struct|class|enum|protocol|func) +[A-Z][A-Za-z0-9_]*' \
    "$dir" 2>/dev/null | grep -Eo '[A-Z][A-Za-z0-9_]*$' | sort -u || true
}

# Does $2 (a word-boundary identifier) appear anywhere under directory $1?
symbol_used_in() {
  local dir="$1" symbol="$2"
  grep -rlEq --include='*.swift' "\\b${symbol}\\b" "$dir" 2>/dev/null
}

# How many distinct Features/<F> reference $1?
features_referencing() {
  local symbol="$1" count=0 f
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    symbol_used_in "$f" "$symbol" && count=$((count + 1))
  done < <(feature_dirs)
  echo "$count"
}

# Which distinct Features/<F> reference $1 (JSON array of names, for the ledger entry)?
features_list_referencing() {
  local symbol="$1" f names=()
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    symbol_used_in "$f" "$symbol" && names+=("\"$(basename "$f")\"")
  done < <(feature_dirs)
  local IFS=,
  echo "[${names[*]:-}]"
}

# design-token-shaped name (leaf visual) vs code-token (protocol/helper/service): different bar.
classify_symbol() {
  local symbol="$1"
  if [[ "$symbol" =~ (View|Component|Modifier|Style|Badge|Row)$ ]]; then
    echo "designToken $THRESHOLD_DESIGN Foundation/Design-tokens"
  else
    echo "codeToken $THRESHOLD_CODE Foundation/Code-tokens"
  fi
}

promote_entries="[]"
for symbol in $(declared_symbols_in "$FEATURES_DIR"); do
  if [ -d "$FOUNDATION_DIR" ] && symbol_used_in "$FOUNDATION_DIR" "$symbol"; then
    continue   # already promoted
  fi
  read -r kind threshold target <<< "$(classify_symbol "$symbol")"
  count="$(features_referencing "$symbol")"
  if [ "$count" -ge "$threshold" ]; then
    entry=$(jq -n --arg symbol "$symbol" --arg kind "$kind" \
      --argjson features "$(features_list_referencing "$symbol")" \
      --argjson count "$count" --argjson threshold "$threshold" --arg target "$target" \
      '{symbol: $symbol, kind: $kind, features: $features, count: $count, threshold: $threshold, target: $target}')
    promote_entries=$(echo "$promote_entries" | jq --argjson e "$entry" '. + [$e]')
  fi
done

demote_entries="[]"
for symbol in $(declared_symbols_in "$FOUNDATION_DIR"); do
  read -r kind threshold _ <<< "$(classify_symbol "$symbol")"
  count="$(features_referencing "$symbol")"
  if [ "$count" -lt "$threshold" ]; then
    entry=$(jq -n --arg symbol "$symbol" --arg kind "$kind" \
      --argjson features "$(features_list_referencing "$symbol")" \
      --argjson count "$count" --argjson threshold "$threshold" \
      '{symbol: $symbol, kind: $kind, features: $features, count: $count, threshold: $threshold, action: "return-to-feature"}')
    demote_entries=$(echo "$demote_entries" | jq --argjson e "$entry" '. + [$e]')
  fi
done

jq -n --arg generated "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --argjson promote "$promote_entries" --argjson demote "$demote_entries" \
  '{generated: $generated, candidates_promote: $promote, candidates_demote: $demote}' \
  > "$LEDGER"

echo "alva-usage-ledger: wrote $LEDGER ($(echo "$promote_entries" | jq 'length') promote, $(echo "$demote_entries" | jq 'length') demote)"
