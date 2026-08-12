# Start here 👋

New to this, or not a command-line person? You're in the right place. This page gets you
set up and building your first feature **by answering plain questions** — no shell knowledge
needed. Read top to bottom.

---

## 1. What this is

This kit turns Claude Code into a disciplined teammate for building software — any kind, in any
language. Instead of you knowing *how* to design, build, and ship a feature, you describe what
you want in plain words and the assistant walks you through it — one step at a time, asking you
to decide or approve at each turn. It keeps the work organized so you don't end up with a
messy, half-finished project.

It doesn't come preloaded with knowledge about your particular language or framework, and that's
deliberate — it asks about your project once, writes the answers down, and reuses them forever
after. It also follows the patterns your existing code already uses, rather than imposing its
own — the project always outranks its generic defaults.

**What to do next:** do the one-time setup in section 2, then build something in section 3.

---

## 2. Set it up

In Claude Code, type these two lines:

```text
/plugin marketplace add Lucasdho/akios
/plugin install akios
```

Then, with Claude Code open **inside your project**, type `/akios:setup` and answer its
questions. It sets everything up for you — there are **no other plugins to install** (the kit
ships everything it needs).

It will ask you a handful of things. The one that matters most is **your project's commands** —
how to install, run, test, and build it. Get those right and everything downstream works; the
assistant never guesses a command it wasn't told.

When it's done you'll have a project that "knows how it works" — every future Claude Code
session starts already oriented.

---

## 3. Build your first feature

Once setup is done, building a feature is a conversation. Just tell the assistant what you
want, in plain words:

> **I want to add a favorites screen where users can save items.**

That kicks off the **feature pipeline** (the skill `feature-pipeline`). Here's what
happens, and what *you* do at each step — mostly just answer questions and say "looks good":

| Step | What the assistant does | What you do |
|---|---|---|
| **Brainstorm** | Asks you questions and writes a short plan ("spec") of the feature | Answer, then approve the plan |
| **Plan** | Breaks the spec into a checklist of small steps, in one pass | Glance over it once and say "looks good" |
| **Build & test** | Writes the code and tests step by step, on its own branch, checking in at each milestone | Watch; answer if it asks |
| **Review** | Checks its own work and reports what changed | Review the changes and commit them yourself |

You stay in control the whole way — **it never commits or pushes anything**; the changes sit in your
working tree until you decide. The first step
(Brainstorm) **always** happens with you present; the assistant won't run off and build the
wrong thing.

That's it. Say what you want, answer the questions, approve the result.

---

## 4. Words you'll see

A few terms come up. Plain-English versions:

- **Gate** — a "before you do X, do Y first" checkpoint. E.g. *before writing code, make a
  plan.* It's a habit, not a wall.
- **Spec** — a short written description of a feature: what it does and how it should behave.
- **Tasks** — the build checklist the assistant makes from the spec, in small steps with
  clear "done" conditions and checkpoints where it runs the tests.
- **Subagent** — a fresh helper the assistant spins up for one focused job so the main
  conversation stays clean. It uses one only when the conversation is getting long.
- **MEMORY** — where Claude Code remembers *this project's* decisions across sessions, so you
  don't repeat yourself.
- **Preferences** — your cross-project coding taste, learned as you work and saved in
  `~/.claude/akios/preferences.md` (it asks before saving anything).

---

Want the technical details or how updates work? See [README.md](README.md).
