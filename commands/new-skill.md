---
description: Scaffold a new akios skill or knowledge pack and self-register it (install-skills.sh, a commands/ wrapper, the version-bump trio).
disable-model-invocation: true
---

# /akios:new-skill — Author a skill or knowledge pack (workflow.yml: skill-author, maintenance action)

**Not a pipeline phase.** Like `/akios:setup` and `/akios:learn`, this is a maintenance
action — run it whenever you're extending akios itself, not building an app feature.

**Run.** Load the `skill-author` skill (single source of truth for the pipeline — don't
re-document it) against `<name>`:

- Ask the routing question — behavior skill or knowledge pack? (skipped, auto-decided, under
  `just-vibes`). Plain `<name>` scaffolds a behavior skill (`skills/<name>/SKILL.md` +
  `references/` if needed); `--pack` scaffolds an **empty** knowledge-pack skeleton
  (`knowledge/<name>/{pack.yml, INDEX.md}`, `baseline: false`) — fill it afterward with
  `/akios:learn --pack <name>`.
- Delegate generic skill structure and description-writing craft to Anthropic's `skill-creator`
  skill; layer akios's house frontmatter, voice, and registration on top.
- **Self-register:** `scripts/register-skill.sh <name>` (never a hand string-edit) appends to
  `install-skills.sh`'s `SKILLS=()` array, installs, and smoke-tests. Add `commands/<name>.md`
  if a command wrapper was requested. Document the standing version-bump rule
  (`VERSION`/`CHANGELOG.md`/`.claude-plugin/plugin.json` together, one commit, before any push).
- **Trigger check:** the drafted description must name concrete triggers + anti-triggers — a
  vague draft is flagged and tightened before the DoD passes.

`--pack` routes to the knowledge-pack scaffold instead of the behavior-skill scaffold.

Arguments (`<name> [--pack]`), pass as `$ARGUMENTS`: `$ARGUMENTS`

Stop when the skill/pack exists, is registered in `install-skills.sh`, and (attended) the
drafted description has passed the trigger check. Tell the user what was created and how it's
invoked.
