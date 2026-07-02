#!/usr/bin/env bash
# post-checkpoint-verify.sh — the auto-build/test hook (Vision wishlist #3).
# Doctrine: specs/verification-and-learning-loop.md §4 (D4).
#
# Runs after a [major] checkpoint / spec completion so the build/test proof (one of
# task-execution's "three proofs") is automatic instead of relying on someone remembering
# to run /verify by hand. Writes a deterministic result file; it never blocks or parks
# anything itself — task-execution READS the result and decides whether to proceed or
# park the spec (same "you read the ledger, you never count" discipline as
# alva-usage-ledger.sh: this script produces a fact, the agent applies judgment).
#
# Install: copied by /akios:setup into <repo>/.claude/hooks/post-checkpoint-verify.sh
# (always-copy, executable — see commands/setup.md's materialize table). Invoked by
# task-execution at each [major] checkpoint barrier and at spec completion; NOT wired to
# a Claude Code hook event by default (a build+test battery is too slow for a per-tool-call
# hook) — it's a script task-execution calls explicitly, same posture as alva-usage-ledger.sh
# being called from a git pre-commit hook rather than PostToolUse.
#
# Degrades gracefully — never a hard dependency:
#   - no xcodebuild on PATH (denied to a subagent/background session, or a non-Xcode repo)
#     -> writes ran:false, tool:"none" and exits 0. task-execution then either runs the
#        battery INLINE in the session (if xcodebuild is reachable there) or, in a
#        plugin/docs repo with no build tool at all, falls back to the DoD audit
#        (grep + YAML validation + install smoke-test) per Roadmap.md project-type.
#   - no .xcodeproj/.xcworkspace found -> same graceful "ran:false" result, reason noted.
#   - Context.md's own recorded test command always wins over auto-detection when present
#     (project decision beats a guessed invocation — same priority-chain spirit as everywhere
#     else in this kit).
#
# Requires: bash, optionally jq (soft dep — falls back to a hand-built JSON line if absent,
# matching alva-usage-ledger.sh's own jq-optional posture... except this script's output
# schema is simple enough to not need jq for writing, only xcodebuild for the real check).

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
OUT_DIR="$ROOT/.akios"
OUT="$OUT_DIR/verify-result.json"
CONTEXT_MD="$ROOT/Context.md"
ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

mkdir -p "$OUT_DIR"

write_result() {
  local ran="$1" tool="$2" exit_code="$3" summary="$4"
  printf '{"ts":"%s","ran":%s,"tool":"%s","exit_code":%s,"summary":"%s"}\n' \
    "$ts" "$ran" "$tool" "$exit_code" "$summary" > "$OUT"
}

# 1. Prefer the project's own recorded test command (Context.md ## Commands), if resolvable
#    and not still a template placeholder.
test_cmd=""
if [ -f "$CONTEXT_MD" ]; then
  test_cmd="$(grep -m1 -E '^- Test:' "$CONTEXT_MD" 2>/dev/null | sed -E 's/^- Test:[[:space:]]*`?([^`]*)`?/\1/' || true)"
  case "$test_cmd" in
    *'{{'*|'') test_cmd="" ;;   # unresolved placeholder or empty -> fall through to detection
  esac
fi

# 2. No usable command and no build tool on PATH -> graceful no-op (plugin/docs repo, or a
#    sandbox that denies it). This is the expected, non-error path for THIS repo.
if [ -z "$test_cmd" ] && ! command -v xcodebuild >/dev/null 2>&1; then
  write_result "false" "none" "null" "no test command in Context.md and no xcodebuild on PATH"
  exit 0
fi

# 3. Run it. Never let a failing build kill the hook itself — capture the exit code instead.
if [ -n "$test_cmd" ]; then
  set +e
  eval "$test_cmd" >"$OUT_DIR/verify-last-run.log" 2>&1
  code=$?
  set -e
  write_result "true" "context.md" "$code" "ran Context.md's recorded Test: command"
  exit 0
fi

# 4. Fallback auto-detection: first .xcodeproj/.xcworkspace + first scheme found.
project_file="$(find "$ROOT" -maxdepth 2 \( -name '*.xcworkspace' -o -name '*.xcodeproj' \) -print -quit 2>/dev/null || true)"
if [ -z "$project_file" ]; then
  write_result "false" "none" "null" "no .xcodeproj/.xcworkspace found at repo root"
  exit 0
fi

proj_flag="-project"; [ "${project_file##*.}" = "xcworkspace" ] && proj_flag="-workspace"
scheme="$(xcodebuild -list "$proj_flag" "$project_file" 2>/dev/null | awk '/Schemes:/{f=1;next} f && NF{print $1; exit}')"
if [ -z "$scheme" ]; then
  write_result "false" "xcodebuild" "null" "found $project_file but could not detect a scheme"
  exit 0
fi

set +e
xcodebuild test "$proj_flag" "$project_file" -scheme "$scheme" -quiet >"$OUT_DIR/verify-last-run.log" 2>&1
code=$?
set -e
write_result "true" "xcodebuild" "$code" "xcodebuild test $proj_flag $(basename "$project_file") -scheme $scheme"
exit 0
