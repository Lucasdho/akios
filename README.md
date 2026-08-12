# AKIOS

A stack-agnostic agent workflow kit for Claude Code: brainstorm, plan, deliver — work grounded in
specs instead of improvised session by session. It carries **process, not framework knowledge**,
so it behaves the same in a TypeScript service, a Python pipeline, a Rust library, or a repo with
no code in it at all.

Two things follow from that, and they're the whole design:

- **It never assumes your stack.** `/akios:setup` asks once, writes the answers to
  `akios/Context.md`, and every phase reads its real install/test/build commands from there. It
  never guesses an invocation.
- **It never writes to git.** No commits, no branches, no pushes — in any mode, autonomous runs
  included. Every run ends the same way: changed files in your working tree and a report of what
  changed. Your history stays yours.

## Commands

| Command | What it does |
|---|---|
| `/akios:setup` | Onboard a repo — interview → scan → fill templates |
| `/akios:brainstorm "<idea>"` | Idea → approved spec in `akios/specs/` |
| `/akios:deep-brainstorm [focus]` | Map a whole subject → a complete spec family in one session |
| `/akios:plan <spec>` | Spec → task backlog in `akios/tasks/todo/` |
| `/akios:deliver` | Implement tasks; hand the working tree back uncommitted |
| `/akios:just-vibes [idea]` | Full pipeline, unattended; `--force` to loop |
| `/akios:handoff` | Write a handoff doc for another agent session, or return results |

**Commands are model-invocable**, like the skills underneath them: you can type `/akios:plan`, or
just say what you want and let Claude route there itself. Describe a feature and it may take you
into the spine on its own. Two things stay true regardless of who invoked what — `brainstorm` is
always interactive, and `just-vibes` runs unattended only when *you* asked to be left out of the
loop, never because Claude decided to skip asking. If you'd rather nothing auto-fire, add
`disable-model-invocation: true` to the commands you want typed-only, and disable the matching
skills.

Every command works **without** `/akios:setup`: it creates what it needs, asks only what it depends
on, and offers setup at the end rather than as a gate.

## Install

Inside Claude Code:

```
/plugin marketplace add Lucasdho/akios
/plugin install akios
```

Then, inside the repo you want to set up:

```
/akios:setup
```

It interviews you, scans the repo, fills the templates, and creates `akios/` (`specs/`, `tasks/`,
`archive/`). No external dependencies, no hooks, no shell scripts, no build step.

The one answer that matters most is your project's **commands** — how to install, run, test, and
build it. Get those right and everything downstream works. An honest `none` is a correct answer;
a fabricated command is the worst possible entry.

akios targets **Claude Code only**. Both layers depend on it — the commands on `CLAUDE.md`,
`.claude/`, and `~/.claude`, and the skills on `${CLAUDE_PLUGIN_ROOT}` to reach their templates.

## The spine

`brainstorm → plan → deliver`, defined in `workflow.yml` and driven by the skills in `skills/`.

You describe what you want in plain words; `brainstorm` turns it into a spec one decision at a
time, with you present. `plan` breaks the spec into a sized task backlog in one pass. `deliver`
implements it task by task — tests first, a DoD audit at every checkpoint, and your project's own
test command plus `/code-review` before anything is called done — and leaves the diff for you.

`/akios:deep-brainstorm` zooms out first: it maps an entire subject and produces a whole family of
specs at once. It is deliberately not software-only — the same session maps a game, a book, a
course, a business, or a research question, using the vocabulary that subject actually has.

`/akios:just-vibes` runs the spine unattended. It is the explicit opt-out of being asked, not of
being correct: the quality gate stays, and a unit that won't go green is **parked**, never marked
done.

## The priority chain

For any decision: **project decisions → your preferences → the model's general knowledge.** That
last tier is the floor, used only when the two above are silent — what your repo already does
outranks any general best practice. Existing code counts as a project decision even when nobody
wrote it down.

## Who it's for

Any repo where work benefits from specs, a task backlog, and a repeatable idea-to-done loop — in
any language, or none. The gates are process gates, not language gates.

---

[CHANGELOG](CHANGELOG.md) · [CREDITS](CREDITS.md) · MIT License · [Lucasdho](https://github.com/Lucasdho)
