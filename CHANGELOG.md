# Changelog

## 1.0.0 (2026-08-11)

**akios is now stack-agnostic.** The kit carries process, not framework knowledge, so it behaves
the same in a TypeScript service, a Python pipeline, a Rust library, or a repo with no code in it
at all. This is a breaking change for anyone who used akios as a Swift/iOS kit.

### akios never writes to git

No commits, no branches, no pushes, no merges — in any mode, autonomous runs included. Every run
ends the same way: changed files in your working tree and a report of what changed, for you to
review and commit however you like. Approving the *work* is not approving a *commit*, and akios
doesn't offer. Reading git is unaffected.

### Nothing is assumed about your project

`akios/Context.md` is the only place a language, framework, or command may be named. Every phase
reads its real install / test / build invocation from there instead of guessing one, and an honest
`none` is a correct answer — the phases fall back to auditing the definition of done. `/akios:setup`
now opens by asking what the repo *is*, records several stacks for a monorepo rather than
flattening them, treats a non-code project as fully supported, and imposes no architecture.

### Removed — the Swift/iOS layer

The bundled Swift/SwiftUI guidance, the preview-native design phase, and the runnable canvas app
are gone, and with them every shell script and hook the kit used to install. Installation is
plugin-only: setup writes markdown and one YAML contract, and nothing else.

### The spine is `brainstorm → plan → deliver`

Three phases, defined in `workflow.yml` at the repo root. `/akios:deep-brainstorm` maps a whole
subject into a spec family first — and it is no longer software-only: the same session maps a game,
a book, a course, a business, or a research question, in that subject's own vocabulary.
`/akios:just-vibes` runs the spine unattended; the quality gate stays, and a unit that won't go
green is parked, never marked done.

### Every command works without `/akios:setup`

No command treats setup as a prerequisite. Each one creates what it needs, asks only the questions
it actually depends on, and offers setup at the end rather than as a gate.

### Simpler by subtraction

The priority chain is three tiers — project decision → your preferences → the model's general
knowledge. Durable decisions and solved hurdles go to native auto-memory instead of files that had
to be indexed and kept in sync. Knowledge packs, the meta-skill that documented the kit, and the
flags that only changed the agent's tone of voice are all gone.

---

Versions 0.9.1 and earlier documented akios as a Swift/iOS kit — a product this release replaces
wholesale.
