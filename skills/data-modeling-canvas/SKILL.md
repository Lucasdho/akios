---
name: data-modeling-canvas
description: >-
  Drives the data-modeling-canvas app — a React/Vite canvas for visually designing database
  schemas (entities, attributes, relations) — live in the browser via Chrome automation, instead
  of asking the user to paste JavaScript into DevTools. akios owns and runs this app itself: it
  installs once to ~/.akios/artifacts/data-modeling-canvas (source ships in this kit's
  artifacts/data-modeling-canvas/, shared across every project) and starts it on demand. Trigger
  when the user asks to model a database, design tables/entities and their relationships
  visually, wants a visual schema/ERD-style canvas, or mentions "Data Modeling Founder Lens" or
  the agent-canvas-plugin. Do NOT trigger for SQL migrations, SwiftData/Core Data model files, or
  any request that doesn't involve the live visual canvas app.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "2.0.0"
---

# Data Modeling Canvas — Driving the Visual Schema Canvas

## What this is

data-modeling-canvas is a React + Vite + Zustand + `@xyflow/react` app for visually building
database schemas — entities (tables), attributes (fields), and relations (connections between
them). Unlike the rest of this kit, akios **owns and runs** this app: its full source lives in
this repo at `artifacts/data-modeling-canvas/` and installs to a single user-level location,
`~/.akios/artifacts/data-modeling-canvas/`, shared by every project on the machine — not tied to
any one project folder.

The app exposes a headless API at `window.agentTools` (see `references/agent-tools-api.md`).
The app's own in-app instructions assume a human would copy-paste JS snippets into DevTools.
**Don't do that.** Drive the app directly using the `claude-in-chrome` MCP tools — the user
never needs to touch the console.

## Golden path

1. **Load the Chrome tools.** If `mcp__claude-in-chrome__*` tools are deferred, load the core
   set plus `javascript_tool` in one `ToolSearch` call:
   `select:mcp__claude-in-chrome__tabs_context_mcp,mcp__claude-in-chrome__navigate,mcp__claude-in-chrome__computer,mcp__claude-in-chrome__read_page,mcp__claude-in-chrome__tabs_create_mcp,mcp__claude-in-chrome__javascript_tool`
2. **Ensure the app is installed.** Check `~/.akios/artifacts/data-modeling-canvas/node_modules`
   exists. If not, this is a first-time setup on this machine — tell the user to run
   `bash scripts/install-artifacts.sh` from their akios kit checkout (it installs deps once and
   is safe to re-run). Don't try to `npm install` from inside this skill session unless the user
   asks — the akios repo checkout path isn't guaranteed to be known here.
3. **Find or start the running app.** Call `tabs_context_mcp` first. If a tab already has the
   app open, reuse it — don't spawn a duplicate tab or a second dev server. Otherwise:
   - Start it: run `cd ~/.akios/artifacts/data-modeling-canvas && npm run dev` in the
     background (Bash `run_in_background`) and read the printed local URL (Vite defaults to
     `http://localhost:5173`, but increments the port if that's taken — don't hardcode it,
     confirm from the actual command output).
   - Open that URL with `navigate`.
4. **Confirm the API is present.** Run `window.agentTools ? window.agentTools.help() : 'missing'`
   via `javascript_tool`. If missing, the page hasn't finished loading — wait briefly and retry
   once before telling the user something's wrong.
5. **Translate the request into `agentTools` calls.** Read `references/agent-tools-api.md` for
   the full surface. Typical flow for "model an e-commerce system":
   - `addEntity(name, attributes)` per table, **capturing the returned id** in a JS variable
     inside the same `javascript_tool` script (or read it back before the next call).
   - `addAttribute(entityId, data)` for fields added after entity creation.
   - `addRelation(sourceEntityId, targetEntityId, options)` for each connection — pass
     `sourceHandle`/`targetHandle` as attribute ids when linking a specific FK to a specific PK.
   - Run structural batches (all entities + relations for one request) in as few
     `javascript_tool` calls as practical, but always read back ids you'll need later in the same
     batch rather than re-deriving them.
6. **Verify.** After structural changes, call `window.agentTools.getSpec()` and check the
   returned JSON matches what you intended before reporting success to the user.
7. **Report back in plain language** — which entities/attributes/relations were created or
   changed — not the raw JS you ran.

## Undo / recovery

`window.agentTools.undo()` / `.redo()` wrap the app's own history (zundo). If a batch produces
the wrong result, prefer `undo()` over manually reconstructing the prior state.

## Anti-patterns

- Asking the user to open DevTools and paste a JS snippet — the whole point of this skill is
  that Chrome automation removes that step.
- Guessing an entity/attribute/relation id instead of capturing the value `agentTools` returned
  when it was created.
- Skipping `autoLayout()` after structural changes that don't already trigger it automatically
  (`addAttribute`, `updateAttribute` do not auto-layout; `addEntity`/`removeEntity`/
  `addRelation`/`removeRelation` do).
- Triggering a JS `alert`/`confirm`/`prompt` from an injected script — this blocks all further
  `claude-in-chrome` commands per that tool's dialog-avoidance rule.
- Starting a second `npm run dev` when a tab already has the app open — check `tabs_context_mcp`
  first; multiple dev servers on the same machine just fight over ports.
- Editing the app's source under `~/.akios/artifacts/data-modeling-canvas/` directly — that's an
  installed copy, refreshed/overwritten by `scripts/install-artifacts.sh`. App changes belong in
  this kit's `artifacts/data-modeling-canvas/` source, released like any other kit change.

## References

- `references/agent-tools-api.md` — full `window.agentTools` method reference, adapted from the
  app's own `agentInterface.ts` (kept here as documentation only, not runnable source).
