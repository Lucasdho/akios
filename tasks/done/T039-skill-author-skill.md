---
id: T039
spec: specs/skill-authoring.md
est_tokens: 16k
runner: orchestrator
parallel: false
area: skill-author-skill
checkpoint: 24
---

# T039 — `skill-author` skill (scaffold + self-register skills and knowledge packs)

> **State:** done

## Description
Hand-author the `skill-author` skill (this repo predates `skill-authoring.md`'s own tool, same
bootstrap situation `knowledge-ingest`'s T031 was in). Implements §1 (D1 — produces a conforming,
registered skill in one pass), §2 (D2 — routes behavior-skill vs. knowledge-pack), §3 (D3 —
delegates generic skill craft to Anthropic's `skill-creator`, layers house conventions +
registration + trigger-check DoD on top), and §4 (D4 — off the build spine, a maintenance action
like `/akios:init`/`/akios:learn`, reachable by `just-vibes`). Self-registers via `T038`'s
`scripts/register-skill.sh`.

## Files
- `skills/skill-author/SKILL.md` (new)
- `scripts/install-skills.sh` (add `skill-author` to the `SKILLS=()` array — run via
  `scripts/register-skill.sh skill-author`, not a hand edit, dogfooding T038's own tool)

## Definition of Done
- `SKILL.md` documents what it produces (§1): `skills/<name>/SKILL.md` + optional `references/`,
  an optional `commands/<name>.md` wrapper, then self-registration — append to
  `install-skills.sh`'s `SKILLS=()` array (via `scripts/register-skill.sh`, never a hand edit),
  add the command wrapper if requested, and **document** (not execute) that a future invocation
  bumps `VERSION` + `CHANGELOG.md` + `.claude-plugin/plugin.json` together in one commit before
  any push — the standing `feedback_plugin_version_bump` memory rule — followed by running the
  install smoke-test.
- Documents the **two artifact kinds** (§2): a *behavior skill* (scaffolds the `skills/<name>/`
  shape) vs. a *knowledge pack* (scaffolds the **empty** pack skeleton —
  `knowledge/<name>/{pack.yml, INDEX.md}`, `baseline: false` — per `knowledge-architecture.md`
  §2's format; filling it is `knowledge-ingest`'s job, not this skill's). One routing question,
  auto-decided under `just-vibes` (default: behavior skill, unless the request names sources to
  ingest).
- Documents the **guardrails** (§3): explicitly delegates generic skill structure and
  description-writing craft to Anthropic's `skill-creator` skill rather than reimplementing it
  (this is `oss-first` applied to the kit itself); akios's own contribution is house frontmatter
  (`license`, `metadata.author`, `metadata.version`), the kit's terse imperative voice, and the
  registration automation. States the **trigger-check DoD**: a drafted description must name
  concrete triggers + anti-triggers (per `skill-creator`'s own guidance) and a vague one is
  flagged, not accepted. States plainly: **DoD = installed + smoke-tested + triggerable**, not
  "file exists."
- Documents **where it sits** (§4): off `workflow.yml`'s `phases` (a maintenance action beside
  `/akios:init`/`/akios:learn`, not a pipeline phase); reachable by `just-vibes` when an
  autonomous run wants to encode a recurring capability, gated by the same record-the-why
  discipline as any other unattended action.
- Empty/edge states from §6 documented: name collision offers an edit instead of a silent
  overwrite; no command wrapper wanted → skip `commands/<name>.md`, registration still updates
  `install-skills.sh`; ambiguous routing under `just-vibes` defaults to behavior skill (journal
  the choice); a version bump that would collide with an in-flight release is staged and flagged
  for a human rather than guessed.
- `scripts/install-skills.sh`'s `SKILLS=()` array includes `skill-author` — added by actually
  running `scripts/register-skill.sh skill-author` (not a hand edit), and the run's smoke-test
  passing is confirmed (`~/.claude/skills/skill-author/SKILL.md` exists after the run).

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/skill-authoring.md` §1–§4, §6. `skill-creator` (Anthropic's own skill) is not
vendored into this repo — this skill's SKILL.md references it by name as the delegate for
generic craft, the same way `oss-first` references external tools without vendoring them. No
actual new skill/pack is scaffolded *by* this task beyond `skill-author` registering itself —
building the tool, not using it to author a third thing, matches this session's mechanism-only
posture for the whole family.
