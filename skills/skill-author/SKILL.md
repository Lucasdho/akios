---
name: skill-author
description: |
  Scaffolds a new akios skill or knowledge pack and self-registers it (install-skills.sh's SKILLS array, a commands/ wrapper, the version-bump trio) in one pass, so a capability is never half-installed.

  Trigger for:
  - The user wants to add a new skill/gate/router to this kit ("create a skill for X", "add a new gate")
  - The user runs /akios:new-skill
  - just-vibes decides, mid-run, that it needs a recurring capability encoded as a skill
  - The user wants to scaffold a new knowledge pack shell (before filling it with knowledge-ingest)

  Don't trigger for:
  - Filling an existing pack's content from code/PDF/image/docs — that's knowledge-ingest (/akios:learn)
  - Editing an already-registered skill's behavior — just edit its SKILL.md directly
  - Any Swift/iOS app code — this only authors kit-internal skills/packs, never app features
license: MIT
metadata:
  author: Lucas Oliveira
  version: "1.0.0"
---

# Skill Author — scaffold + self-register a skill or a knowledge pack

Gives akios a first-class path to author its **own** skills and knowledge packs:
`/akios:new-skill <name> [--pack]` scaffolds a conforming artifact and — critically —
**self-registers** it everywhere the kit requires. This is a *maintenance* action, like
`/akios:setup`/`/akios:learn` — not a `workflow.yml` phase.

**Why this exists.** `Context.md`'s "Gotchas" section names *"forgetting to update
install-skills.sh"* as this kit's most common mistake. A kit that builds iOS features from a
spec should build its own extensions from a spec too — this makes skill/pack creation
self-registering so a new capability is never half-installed.

## What it produces, in one pass (D1)

```
skills/<name>/
  SKILL.md            → house frontmatter + a skeleton body in the kit's voice
  references/         → created only if the skill needs progressive-disclosure guides
commands/<name>.md    → thin command wrapper (description + disable-model-invocation: true),
                         only if a command is wanted
```

…then **self-registers**:

1. Appends `<name>` to `install-skills.sh`'s `SKILLS=()` array — via
   **`scripts/register-skill.sh <name>`**, never a hand string-edit. That script is idempotent
   (safe to re-run) and runs `install-skills.sh` itself afterward as the install + smoke-test.
2. Adds the `commands/<name>.md` wrapper (mirroring the skill's own frontmatter shape), if one
   was requested.
3. **Documents, and when actually invoked, performs** the standing version-bump rule: bump
   `VERSION` + `CHANGELOG.md` + `.claude-plugin/plugin.json` together, in one commit, before any
   push (`feedback_plugin_version_bump`) — the marketplace reads the remote, so a skill that
   exists in the repo but not in a bumped release is invisible to consumers.
4. Confirms the smoke-test passed: `~/.claude/skills/<name>/SKILL.md` exists after
   `register-skill.sh` runs `install-skills.sh`.

**Decision & reason:** scaffolding the `SKILL.md` alone leaves the half-install problem the
backlog names. Automating registration *without* scaffolding misses the frontmatter/voice
conformance that makes a skill trigger correctly. Doing both in one pass makes "a skill exists"
and "a skill is installed + released" the same event.

## Two artifact kinds (D2)

Ask one routing question — **is this a *behavior* or *knowledge*?** — skipped under
`just-vibes` (auto-decided, journaled):

- **Behavior skill** — a meta-prompt that *does something* (a gate, a workflow, a router).
  Scaffolds the `skills/<name>/SKILL.md` shape above.
- **Knowledge pack** — domain facts/patterns the pipeline loads
  (`knowledge/<name>/{pack.yml, INDEX.md, references/}`, `knowledge-architecture.md` §2 format).
  This skill scaffolds only the **empty pack skeleton** (`pack.yml` with `baseline: false` +
  an empty `INDEX.md`) — filling it from real sources (code/PDF/image/book) is
  `knowledge-ingest`'s job (`/akios:learn --pack <name>`). The two compose: author the skeleton
  here, ingest content there.

**Decision & reason:** the backlog's "Criar Skill" and `knowledge-architecture.md`'s "upload
skills/code/docs about a knowledge area" are the same authoring surface seen from two sides —
one skill avoids two overlapping creators. Splitting *skeleton* (structural, here) from *fill*
(source-driven, in `knowledge-ingest`) keeps each step single-purpose.

## Guardrails (D3) — wrap `skill-creator`, enforce house conventions

- **Reuse, don't reinvent.** Anthropic's own **`skill-creator`** skill already teaches skill
  structure and description-writing — the part that governs whether a skill actually *triggers*.
  This skill **delegates that generic craft to `skill-creator`** and layers akios's specifics on
  top: house frontmatter (`license`, `metadata.author`, `metadata.version`), the kit's terse
  imperative voice, and the registration automation above (which `skill-creator` has no reason
  to know about). This is `oss-first` applied to the kit itself — duplicating `skill-creator`'s
  craft inside akios would be exactly the hand-generation `oss-first` exists to prevent.
- **Description discipline is the acceptance bar.** A skill that doesn't trigger is dead weight.
  The DoD includes a **trigger check**: the drafted description must name concrete cues (what
  the user says/does) and anti-triggers, per `skill-creator`'s own guidance — a vague first draft
  (e.g. "helps with skills") is flagged and tightened, not accepted.
- **DoD = installed + smoke-tested + triggerable**, not "file exists." The scaffold isn't done
  until `install-skills.sh` picks it up (§ above) and the description passes the trigger check.

## Where it sits in the kit (D4)

- **Off the build spine.** Like `/akios:setup` and `/akios:learn`, `/akios:new-skill` is a
  *maintenance* action — it does not appear in `workflow.yml`'s `phases`. It's how the kit
  *grows*, invoked when extending akios, not when building an app feature.
- **Available to `just-vibes`.** An autonomous run that discovers it needs a capability that
  doesn't exist (a recurring hurdle worth encoding, a domain it keeps hitting) *can* author the
  skill/pack unattended — auto-deciding the routing question above, journaling the rationale —
  under the same record-the-why discipline as any other unattended action.

## Worked example

- `/akios:new-skill spec-lint` → delegates structure to `skill-creator`, writes
  `skills/spec-lint/SKILL.md` with house frontmatter + a drafted description naming its
  triggers, runs `scripts/register-skill.sh spec-lint` (appends to `install-skills.sh`, installs,
  smoke-tests), adds `commands/spec-lint.md`, documents the version bump. The trigger check flags
  the first draft description as too generic ("helps lint specs"); it's tightened to name
  concrete cues before the DoD passes.
- `/akios:new-skill design-system-acme --pack` → scaffolds `knowledge/design-system-acme/` with
  an empty `pack.yml` (`baseline: false`) + `INDEX.md`. The user then runs `/akios:learn
  ~/acme/tokens.pdf --pack design-system-acme` to fill it.

## Empty / edge states

- **Name collides with an existing skill/pack:** refuse to clobber — offer to *edit* the
  existing one instead (this skill also does in-place edits).
- **Command wrapper not wanted:** skip `commands/<name>.md`; a skill can be description-triggered
  only. The `install-skills.sh` registration still happens.
- **Under `just-vibes`, routing ambiguous:** default to **behavior skill** unless the request
  names sources to ingest (then it's a pack + a follow-on `/akios:learn`); journal the choice.
- **Version bump would collide with an in-flight release:** stage the file edits and flag the
  bump for a human rather than guessing the semver on a dirty release — the one step this skill
  won't auto-resolve.

## Anti-patterns

- Hand-editing `install-skills.sh`'s `SKILLS=()` array as an LLM string edit instead of calling
  `scripts/register-skill.sh` — the exact non-deterministic mistake this skill exists to remove.
- Reimplementing `skill-creator`'s structure/description-writing guidance instead of delegating
  to it.
- Accepting a vague, untriggerable description because "the file exists."
- Silently overwriting an existing skill/pack on a name collision instead of offering an edit.
- Guessing a semver bump against an in-flight release instead of flagging it for a human.
