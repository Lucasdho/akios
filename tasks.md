---
feature: akios-refactor
spec: specs/plugin-architecture.md, specs/pipeline.md, specs/preferences-and-priority.md
branch: feature/akios-refactor        # task-execution creates this; never master
---

# akios refactor — execution backlog

Implements the 3-spec family (plugin-architecture → pipeline → preferences-and-priority):
**axiom → swift-dev**, **superpowers → task-execution**, no external plugin/skill deps.

**Global conventions (apply to every task):**
- **UI states: N/A** — all artifacts are md/yml/sh/skill files, not SwiftUI screens.
- **Axiom domain routing: N/A** — the work *is* removing axiom; tasks author the plugin, not Swift code.
- **No test battery** (plugin/docs repo) → each `↳ barrier` audit = DoD check + grep for orphaned
  refs, not unit/integration tests.
- `project-scaffolding` (spec #4) is **out of scope** — deferred.

---

## Checkpoint 1 — Contract & templates
- [ ] T001 [P] Create `workflow.yml`        files: workflow.yml
        DoD: schema from pipeline.md §1 (version, modes, bootstrap, 3 phases with
        id·command·skill·prereqs·outputs·roadmap) · valid YAML · init listed as bootstrap, not a phase
- [ ] T002 [P] `Roadmap.md` template        files: templates/Roadmap.md
        DoD: mode flag field (new/one-shot/feature) · one-line-per-spec state table
        (spec · domain · status designed/planned/in-progress/done) · empty-state row example
- [ ] T003 [P] `preferences.seed.md`         files: templates/preferences.seed.md
        DoD: header explaining user-global scope + the priority chain · zero entries ·
        note "copied to ~/.claude/akios/ on init"
- [ ] T004 [P] `spec.md` + `task.md` templates  files: templates/spec.md, templates/task.md
        DoD: each carries State + Description + body · task template has est_tokens + runner
        fields · modeled on speckit/templates structure
- [ ] T005 [P] `swift.md` rule → swift-dev   files: templates/rules/swift.md
        DoD: loads the swift-dev gate on .swift read (replaces the axiom gate) · no axiom mention left
  ↳ barrier: audit all DoDs → commit "checkpoint: contract & templates"

## Checkpoint 2 — Skills
- [ ] T006 Rewrite `AGENTS.md` template       files: templates/AGENTS.md
        DoD: drops axiom/superpowers always-on · adds swift-dev (domain) + task-execution (execution) ·
        priority-chain house rule (project → code-references → preferences → swift-dev) ·
        references workflow.yml as phase SSOT · gate table updated · artifact map updated
        (tasks/{todo,in-progress,review,done}/, archive/, code-references/, Roadmap.md, preferences.md)
- [ ] T007 [P] Demote `ios-feature-pipeline`  files: skills/ios-feature-pipeline/SKILL.md
        DoD: thin router that reads workflow.yml and walks phases · no duplicated phase definitions ·
        stays the "I want to build X" auto-trigger entry point
- [ ] T008 [P] Rewrite `ios-agentic-kit`      files: skills/ios-agentic-kit/SKILL.md, skills/ios-agentic-kit/references/*
        DoD: no axiom/superpowers · describes swift-dev + the 3-phase spine + global/repo layout ·
        references/ (sandbox.md, hooks.md) updated to match
- [ ] T009 Rewrite `spec-to-tasks`            files: skills/spec-to-tasks/SKILL.md
        DoD: emits task files under tasks/todo/ (not a single tasks.md) · size+similarity decomposition ·
        80k soft ceiling with split · est_tokens + runner recorded per task · [P] by area ·
        swift-dev replaces axiom routing
- [ ] T010 Rewrite `task-execution`           files: skills/task-execution/SKILL.md
        DoD: absorbs superpowers execution practices · folder-state lifecycle (todo→in-progress→review→done) ·
        TDD-first with light UI bar · runner routing (≤20k inline / >20k subagent, degrade to inline) ·
        context budget (warn 120k / urgent compact 180k, compress between specs) · archive mechanism
        (Archive.md index + MEMORY.md split) · consults the priority chain · human gate at push/merge
  ↳ barrier: audit all DoDs → commit "checkpoint: skills"

## Checkpoint 3 — Commands
- [ ] T011 [P] `define` → `brainstorm`        files: commands/brainstorm.md (delete commands/define.md)
        DoD: reads workflow.yml · soft gate + offer · runs idea-to-spec · old define.md removed
- [ ] T012 [P] `deliver` → `execute`          files: commands/execute.md (delete commands/deliver.md)
        DoD: runs task-execution · soft gate + offer · old deliver.md removed
- [ ] T013 [P] Update `plan.md`               files: commands/plan.md
        DoD: soft gate + offer · reads workflow.yml · runs spec-to-tasks
- [ ] T014 Implement `init.md`                files: commands/init.md
        DoD: idempotent/version-aware onboard · light interview fills Context.md · writes mode flag
        to Roadmap.md · creates tree (specs/ tasks/{todo,in-progress,review,done}/ archive/ code-references/) ·
        copies preferences.seed.md → ~/.claude/akios/preferences.md (if absent)
  ↳ barrier: audit all DoDs → commit "checkpoint: commands"

## Checkpoint 4 — Scripts & hook
- [ ] T015 [P] Update inject hook            files: scripts/hook/agentic-kit-inject.sh
        DoD: gate wording reflects swift-dev + task-execution · no axiom/superpowers strings
- [ ] T016 [P] Update install-skills         files: scripts/install-skills.sh
        DoD: skill set includes swift-dev · no axiom/superpowers references
  ↳ barrier: audit all DoDs → commit "checkpoint: scripts & hook"

## Checkpoint 5 — Docs & manifest [final consistency pass]
- [ ] T017 [P] Update `README.md`            files: README.md
        DoD: axiom→swift-dev, superpowers→task-execution · new command names · "no external deps" framing
- [ ] T018 [P] Update `START-HERE.md`        files: START-HERE.md
        DoD: walkthrough uses init/brainstorm/plan/execute · no axiom/superpowers
- [ ] T019 [P] Update `CREDITS.md`           files: CREDITS.md
        DoD: swift-dev sub-skill attributions present · axiom/superpowers credit lines adjusted/removed
- [ ] T020 Bump version + changelog          files: CHANGELOG.md, VERSION, .claude-plugin/plugin.json
        DoD: VERSION + plugin.json → 0.5.0 (consistent) · CHANGELOG 0.5.0 entry summarizing the refactor
- [ ] T021 Final orphan-reference audit      files: (verification only)
        DoD: `grep -ri 'axiom\|superpower\|ponytail' --include=*.md --include=*.sh --include=*.yml --include=*.json`
        over tracked files returns only intentional mentions (e.g. CHANGELOG history, "ponytail optional") ·
        no stray gate/routing references
  ↳ barrier: audit all DoDs → commit "checkpoint: docs & manifest"

---

## Hand-off
`tasks.md` is the sole input to `task-execution` (`/akios:deliver`). It creates branch
`feature/akios-refactor`, runs each checkpoint, commits at every barrier, and stops at the
human gate before any push/merge.
