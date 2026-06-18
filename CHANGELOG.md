# Changelog

## 0.2.3 (2026-06-18)

### Fixes
- **axiom-xcode → axiom-build rename** — corrected the Axiom sub-skill name in 6 files
  (`AGENTS.md`, `skills/ios-agentic-kit/SKILL.md`, and related templates/rules). Any
  installed repo that has `axiom-xcode` in `AGENTS.md` or `.claude/rules/swift.md`
  should run `install.sh` again to pick up the corrected templates.
- Hook gate notation standardized to match `AGENTS.md` style (`swift-dev`→`sub-skill`).
- `idea-to-spec` and `ios-feature-pipeline` spec filename conventions aligned
  (`specs/<feature>.md` preferred form documented in `spec-format.md`).
- `test-kit.sh` now covers `templates/workflows/ios-feature-pipeline.yml`, so a
  missing workflow artifact is caught by CI.
- `install.sh` self-check now emits a visible warning (exit 1) when the SessionStart
  hook is not wired, instead of silently passing.

### Docs
- `skills/ios-agentic-kit/references/hooks.md` slimmed: clarifies that the kit
  installs exactly one SessionStart hook; opt-in examples (lint/format-on-save, file
  protection) moved to a clearly marked section.
- Removed three large, low-signal reference files (`prd-workflow.md`,
  `project-structure.md`, `xcodebuildmcp.md`) that duplicated content maintained
  elsewhere.
- Noted that `version:` frontmatter inside each skill file is an independent track
  from the kit's `VERSION`; added axiom pin verification date to `CREDITS.md`.
- Added comment explaining the SessionStart hook gate list is intentionally compressed
  vs `AGENTS.md` (not a drift).

## 0.2.2 (2026-06-17)

- `START-HERE.md` added — novice-friendly on-ramp; consolidates the agent-install
  block so `README.md` and `START-HERE.md` don't drift.
- Centralized workflow spine in a single orchestration document.

## 0.2.0 — 0.2.1

Initial public release of the 0.2.x line: `install.sh` idempotency, `check-update.sh`,
`install-skills.sh`, versioned `VERSION` stamp.
