---
description: Drive the "Data Modeling Founder Lens" visual data-modeling canvas live in the browser via Chrome automation.
disable-model-invocation: true
---

# /akios:data-modeling-canvas — Visual Schema Canvas

Load the `data-modeling-canvas` skill (single source of truth — don't re-document it).

Assumes the "Data Modeling Founder Lens" app is already running (`npm run dev`) in a Chrome tab.
Drives `window.agentTools` via the `claude-in-chrome` MCP tools to add/update/remove entities,
attributes, and relations from a natural-language description — no DevTools console paste.

Arguments (optional description of the model to build), pass as `$ARGUMENTS`: `$ARGUMENTS`
