---
id: T046
spec: specs/verification-and-learning-loop.md
est_tokens: 12k
runner: orchestrator
parallel: false
area: auto-build-test-hook
checkpoint: 28
---

# T046 — the auto-build/test hook (Vision wishlist #3)

> **State:** done

## Description
Realizes `verification-and-learning-loop.md` §4 (D4): a post-checkpoint hook that runs the
build + test battery automatically and writes a deterministic result file `task-execution` reads,
instead of relying on a manually-run `/verify`. Degrades gracefully to a no-op when there's no
build tool reachable (a background sandbox denying `xcodebuild`, or — as in this repo — no Xcode
project at all).

## Files
- `scripts/hook/post-checkpoint-verify.sh` (new) — prefers `Context.md`'s recorded `Test:`
  command; falls back to auto-detecting `.xcodeproj`/`.xcworkspace` + first scheme; writes
  `.akios/verify-result.json` (`ts`, `ran`, `tool`, `exit_code`, `summary`); exits 0 always.
- `commands/init.md` — materialize table gains an always-copy executable row; self-check confirms
  its presence.
- `skills/task-execution/SKILL.md` — "The three proofs" table's build/test row names the exact
  script + result file; "Barrier = audit + commit" calls it at `[major]` checkpoints and reads the
  result instead of parsing build output.
- `.gitignore` — `.akios/` added (the hook's result file is runtime-local, same as the journal
  and trace files already documented as gitignored in `AGENTS.md`'s artifact map).

## Definition of Done
- `scripts/hook/post-checkpoint-verify.sh` exists, is executable (`chmod +x`), passes `bash -n`,
  and running it in a repo with no `Context.md` `Test:` line and no `.xcodeproj`/`.xcworkspace`
  produces `.akios/verify-result.json` with `"ran":false` and exits 0 (verified: ran it in this
  repo, got exactly that result, then deleted the runtime artifact).
- `commands/init.md`'s materialize table has a row for `.claude/hooks/post-checkpoint-verify.sh`
  (always copy, executable); the self-check step lists it alongside the other two hooks.
- `task-execution/SKILL.md` names the script + `.akios/verify-result.json` explicitly in both "The
  three proofs" and "Barrier = audit + commit", and states the inline/DoD-audit degrade path.
- `.gitignore` contains `.akios/`; no `.akios/verify-result.json` or `.akios/verify-last-run.log`
  is tracked in this commit.
- `grep -n "post-checkpoint-verify" commands/init.md skills/task-execution/SKILL.md` both hit.

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/verification-and-learning-loop.md` §4 (D4), §7 ("Build/test hook unavailable"
edge state). Per this repo's own project-type note (`Roadmap.md`), the DoD here is "the hook
exists and installs correctly," not "the hook ran a real xcodebuild test suite here" — there is
no Xcode project in this plugin repo to run it against, exactly as the spec's own "Plugin-repo
note" (§4) anticipates.
