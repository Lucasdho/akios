---
feature: deep-brainstorm-rww-audit
spec: specs/deep-brainstorm-rww-audit.md
task: T003
owner: akios-instance-solo
est_tokens: 6000
runner: inline
depends_on: [T001, T002]
---

# T003 — Version bump + DoD audit

## What

After T001 and T002 complete: bump version to 0.7.3, update CHANGELOG.md, update
`.claude-plugin/plugin.json`, and run a full orphan-reference audit.

## DoD

1. `VERSION` = `0.7.3`.
2. `CHANGELOG.md` has a `## [0.7.3]` entry describing:
   - deep-brainstorm Phase 5 R-W-W audit added.
   - just-vibes `needs-revision` fuel filter added.
   - `specs/deep-brainstorm-rww-audit.md` added (spec for this feature).
3. `.claude-plugin/plugin.json` `"version"` = `"0.7.3"`.
4. `grep -ri "Phase 5" skills/deep-brainstorm/SKILL.md` returns only the new Validate heading.
5. `grep -ri "Phase 5 — Review" skills/ commands/ workflow.yml` returns zero matches
   (old heading fully renamed).
6. `grep -ri "grill-ui" . --include=*.md --include=*.sh --include=*.yml` returns zero matches
   (orphan check from prior rename).
7. YAML validate passes: `python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" workflow.yml`.
8. Install script smoke-test: `bash scripts/install-skills.sh` exits 0.

↳ barrier: all DoD checks pass → commit "chore: bump version to 0.7.3"
