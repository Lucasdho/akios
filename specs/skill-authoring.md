# akios — Skill Authoring ("Criar Skill")
**Working spec · v1.0 · kit-evolution family · 2026-06-30**

Gives akios a first-class path to **author its own skills and knowledge packs**: a `skill-author` skill +
`/akios:new-skill` command that scaffolds a conforming `SKILL.md`, wires the references, and — critically —
**self-registers** the new skill everywhere the kit requires (the `install-skills.sh` array, a `commands/`
wrapper, and the version-bump trio), structurally eliminating the kit's most common maintenance mistake.
Answers backlog **B1**. Complements `knowledge-architecture.md` (G2 — packs are the other thing this can
scaffold), `ios-agentic-kit.md` (the conventions it must honor), and `Context.md` (the gotcha it fixes). See
`akios-backlog-map.md` (G3).

> **State:** designed

> **The shift:** authoring a skill in akios today is manual and error-prone — the `Context.md` "Gotchas"
> section literally names *"forgetting to update `install-skills.sh` is the most common mistake."* A kit that
> builds iOS features from a spec should build *its own extensions* from a spec too. This makes skill/pack
> creation a first-class, self-registering action so a new capability is never half-installed.

---

## 1. What it produces (D1) — a conforming, registered skill

`/akios:new-skill <name>` (skill: `skill-author`) scaffolds and wires, in one pass:

```
skills/<name>/
  SKILL.md            → house frontmatter + a skeleton body in the kit's voice
  references/         → created if the skill needs progressive-disclosure guides
commands/<name>.md    → thin command wrapper (description + disable-model-invocation: true), if a command is wanted
```

…and then **self-registers**:

- appends `<name>` to the `SKILLS=(...)` array in `scripts/install-skills.sh`;
- adds the `commands/<name>.md` wrapper (mirroring the skill), if requested;
- bumps `VERSION` + `CHANGELOG.md` + `.claude-plugin/plugin.json` **together in one commit before any push**
  (the standing memory rule — the marketplace reads the remote);
- runs the install smoke-test (`~/.claude/skills/<name>/SKILL.md` exists after `install-skills.sh`).

**Decision & reason:** the registration steps are exactly the checklist a human forgets, and they are
*mechanical* — precisely what an agent should own. Scaffolding the `SKILL.md` alone (rejected) leaves the
half-install problem the backlog implies. Automating registration *without* scaffolding (rejected) misses the
frontmatter/voice conformance that makes a skill trigger correctly. Doing both in one pass makes "a skill
exists" and "a skill is installed + released" the same event.

---

## 2. Two artifact kinds (D2) — a behavior skill vs. a knowledge pack

`skill-author` asks one routing question (skipped under `just-vibes`, auto-decided): **is this a *behavior*
or *knowledge*?**

- **Behavior skill** — a meta-prompt that *does something* (a gate, a workflow, a router). Scaffolds the
  `skills/<name>/SKILL.md` shape above.
- **Knowledge pack** — domain *facts/patterns* the pipeline loads (G2 format:
  `knowledge/<name>/{pack.yml,INDEX.md,references/}`). `skill-author` scaffolds the **empty pack skeleton**;
  filling it from real sources (code/PDF/image/book) is `knowledge-ingest`'s job (`/akios:learn`, G2 §4). The
  two compose: author the skeleton here, ingest content there.

**Decision & reason:** the backlog's "Criar Skill" and G2's "upload skills/code/docs about a knowledge area"
are the *same authoring surface* seen from two sides — unifying them behind one skill avoids two overlapping
creators. Splitting *skeleton* (structural, here) from *fill* (source-driven, in `knowledge-ingest`) keeps
each step single-purpose: this spec owns *shape + registration*, G2 owns *distillation*.

---

## 3. Guardrails (D3) — wrap `skill-creator`, enforce house conventions

- **Reuse, don't reinvent.** Anthropic's `skill-creator` skill already teaches skill structure and
  description-writing (the part that governs whether a skill *triggers*). `skill-author` **delegates the
  generic craft to `skill-creator`** and layers akios's specifics on top: the house frontmatter
  (`license`, `metadata.author`, `metadata.version`), the kit's terse imperative voice, and the registration
  automation (§1) that `skill-creator` has no reason to know about. (This is `oss-first` applied to the kit.)
- **Description discipline is the acceptance bar.** A skill that doesn't trigger is dead weight, so the DoD
  includes a *trigger check*: the description must name concrete cues (what the user says/does) and
  anti-triggers, per `skill-creator`'s guidance. `skill-author` drafts it and flags a vague one.
- **DoD = installed + smoke-tested + triggerable**, not "file exists." The scaffold isn't done until
  `install-skills.sh` picks it up and the description passes the trigger check.

**Decision & reason:** `skill-creator` is a maintained asset that already solves the hard, general part
(making skills that fire) — duplicating it inside akios (rejected) is exactly the hand-generation `oss-first`
exists to prevent. akios's contribution is the *conventions + registration*, which is genuinely kit-specific
and not in `skill-creator`. Making triggerability a DoD item targets the real failure mode (skills nobody
invokes), which "file exists" would rubber-stamp.

---

## 4. Where it sits in the kit (D4)

- **Off the build spine.** Like `/akios:setup` and `/akios:learn`, `/akios:new-skill` is a *maintenance*
  action, not a pipeline phase — it doesn't appear in `workflow.yml`'s `phases`. It's how the kit *grows*,
  invoked when you're extending akios, not when you're building an app feature.
- **Available to `just-vibes`.** When an autonomous run discovers it needs a capability that doesn't exist
  (a recurring hurdle it wants to encode, a domain it keeps hitting), it *can* author the skill/pack
  unattended (auto-deciding the §2 routing question, journaling the rationale) — closing the loop where the
  kit extends itself. Gated by the same "record every decision" deepthink discipline as any just-vibes action.

**Decision & reason:** skill creation is structurally a sibling of `init` (scaffolding + registration), so it
belongs beside it as a maintenance command, not shoehorned into the feature pipeline. Letting `just-vibes`
reach it is what turns "akios can be extended" into "akios extends itself" — but only under the same
record-the-why guardrail, so an unattended skill is as auditable as an unattended spec.

---

## 5. Worked example

- `/akios:new-skill spec-lint` → `skill-author` (behavior) delegates structure to `skill-creator`, writes
  `skills/spec-lint/SKILL.md` with house frontmatter + a drafted description naming its triggers, appends
  `spec-lint` to `install-skills.sh`, adds `commands/spec-lint.md`, bumps `VERSION`/`CHANGELOG`/`plugin.json`
  in one commit, runs the smoke-test. The trigger check flags the first draft description as too generic; it's
  tightened before the DoD passes.
- `/akios:new-skill design-system-acme --pack` → scaffolds `knowledge/design-system-acme/` with an empty
  `pack.yml` (`baseline: false`) + `INDEX.md`. The user then runs `/akios:learn ~/acme/tokens.pdf --pack
  design-system-acme` (G2) to fill it. Now iOS tasks touching color/spacing load Acme's tokens at tier 2.

---

## 6. Empty / edge states

- **Name collides with an existing skill/pack:** refuse and offer to *edit* the existing one (skill-author
  also does in-place edits) rather than clobber — no silent overwrite.
- **Command wrapper not wanted:** skip `commands/<name>.md`; a skill can be description-triggered only. The
  registration still updates `install-skills.sh`.
- **Under `just-vibes`, routing ambiguous:** default to **behavior skill** unless the request names sources
  to ingest (then it's a pack + a follow-on `/akios:learn`), and journal the choice.
- **Version bump would collide** with an in-flight release: skill-author stages the file edits and flags the
  bump for the human rather than guessing the semver on a dirty release — the one step it won't auto-resolve.

---

## 7. Open / next

- **[CONSEQUENCE — to implement]** `skill-author` skill + `/akios:new-skill` command; delegates to
  `skill-creator`; owns the registration automation (§1) and the trigger-check DoD.
- **[CONSEQUENCE — to implement]** a small `scripts/` helper (or inline) that edits the `SKILLS=()` array
  idempotently and runs the smoke-test, so registration is deterministic rather than an LLM string edit.
- **[COMPOSES WITH]** `knowledge-architecture.md` (G2): pack skeleton here → pack fill there.
- **[DEFERRED]** a `/akios:new-skill --from <transcript>` that distills a repeated ad-hoc workflow from a
  session into a reusable skill (the "I keep doing this by hand" → skill path) — natural once the hurdles
  ledger (G5) exists to point at the repetition.
