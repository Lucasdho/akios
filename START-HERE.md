# Start here 👋

New to this, or not a command-line person? You're in the right place. This page gets you
set up and building your first feature **by pasting one block and answering plain
questions** — no shell knowledge needed. Read top to bottom.

---

## 1. What this is

This kit turns Claude Code into a disciplined teammate for building an iPhone/iPad/Mac app.
Instead of you knowing *how* to design, build, and ship a feature, you describe what you
want in plain words and the assistant walks you through it — one step at a time, asking you
to decide or approve at each turn. It keeps the work organized so you don't end up with a
messy, half-finished app.

**What to do next:** do the one-time setup in section 2, then build something in section 3.

---

## 2. Set it up

**Easiest — install the plugin.** In Claude Code, type these two lines:

```text
/plugin marketplace add Lucasdho/iOS-agentic-kit
/plugin install akios
```

Then, with Claude Code open **inside your app project**, type `/akios:init` and answer its
questions. It sets everything up for you and tells you if you still need to install the
`superpowers` and `axiom` plugins (it shows the exact commands). When it's done, skip to
section 3.

---

**Or — paste this (no plugin).** Prefer the script route, or using Codex/Gemini? Open Claude
Code **inside the app project you want to work on** and paste the block below as your
message. The assistant does the whole setup and asks you three simple questions along the
way. You don't run any commands yourself.

```text
Set up the iOS agentic-kit in this project for me. I'm new to this, so keep it simple
and explain choices in plain language.

1. Get the kit. Clone it to ~/iOS-agentic-kit if it isn't there yet:
     git clone https://github.com/Lucasdho/iOS-agentic-kit.git ~/iOS-agentic-kit
   If the folder already exists, run `git -C ~/iOS-agentic-kit pull` to update it.
2. Install the helper skills: ~/iOS-agentic-kit/scripts/install-skills.sh
   Then check the REQUIRED plugins (superpowers, axiom) are available. If either is
   missing, show me the exact command and STOP until I say go:
     /plugin marketplace add obra/superpowers      &&  /plugin install superpowers
     /plugin marketplace add CharlesWiltgen/Axiom   &&  /plugin install axiom
   ponytail is OPTIONAL (it just keeps the code lean). Offer it, but don't stop for it:
     /plugin marketplace add DietrichGebert/ponytail  &&  /plugin install ponytail
3. Before wiring anything in, ASK me these three things in plain language, one at a time,
   and suggest a sensible default for each so I can just say "use the default":
   a. Which folders hold my actual app code, and which to ignore (build output,
      downloaded packages, generated files)?
   b. How is the app organized? If I don't know, suggest MVVM and explain it in one line.
   c. Which devices and minimum iOS version does it target? Read this from the app
      itself, not the test targets, and confirm with me.
4. Run: ~/iOS-agentic-kit/scripts/install.sh "$(pwd)"
   This drops the kit's guide files into my project. It never overwrites files I already
   have.
5. Now FILL IN every {{...}} blank in the files it created — Context.md, AGENTS.md, and
   CLAUDE.md. Use my answers from step 3 and what you can read from the code: the stack,
   the install/run/test/build commands, the architecture, the target, the conventions,
   and any project-specific rules. Leave NO {{...}} blanks behind.
6. Show me a short, plain-language summary of what you set up and what you filled in.

Don't commit anything unless I ask.
```

When it's done you'll have a project that "knows how it works" — every future Claude Code
session starts already oriented.

---

## 3. Build your first feature

Once setup is done, building a feature is a conversation. Just tell the assistant what you
want, in plain words:

> **I want to add a favorites screen where users can save items.**

That kicks off the **feature pipeline** (the skill `ios-feature-pipeline`). Here's what
happens, and what *you* do at each step — mostly just answer questions and say "looks good":

| Step | What the assistant does | What you do |
|---|---|---|
| **Design** | Asks you questions and writes a short plan ("spec") of the feature | Answer, then approve the plan |
| **Clarify** | Spots anything vague or missing and pins it down | Confirm the details |
| **Plan** | Works out *how* to build it | Glance over it |
| **Tasks** | Breaks it into a checklist of small steps | Nothing — just let it run |
| **Build & test** | Writes the code and tests, step by step | Watch; answer if it asks |
| **Review** | Checks its own work for problems | Approve, or ask for changes |

You stay in control the whole way — nothing ships without you approving it. The first step
(Design) **always** happens with you present; the assistant won't run off and build the
wrong thing.

That's it. Say what you want, answer the questions, approve the result.

---

## 4. Words you'll see

A few terms come up. Plain-English versions:

- **Gate** — a "before you do X, do Y first" checkpoint. E.g. *before writing code, make a
  plan.* It's a habit, not a wall.
- **Spec** — a short written description of a feature: what it does and how it should behave.
- **Speckit** — an optional tool that turns a spec into a structured build checklist. The kit
  works fine without it.
- **Axiom** — a library of Apple/Swift expertise the assistant pulls in when it touches
  Swift code, so the code follows current best practice.
- **Subagent** — a fresh helper the assistant spins up for one focused job (like building one
  screen) so the main conversation stays clean.
- **ponytail** — the optional "keep it lean" overlay: it stops the assistant from
  over-building. Nice to have, not required.
- **MEMORY** — where Claude Code remembers decisions across sessions, so you don't repeat
  yourself.

---

Want the technical details, manual install, or how updates work? See
[README.md](README.md).
