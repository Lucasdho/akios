# `window.agentTools` API reference

Documentation only — adapted from the app's `src/utils/agentInterface.ts`. No source code from
that app lives in this repo; this file exists so the agent doesn't need to fetch it live before
every session. If the app's API changes, re-derive this file rather than trusting it blindly —
check `window.agentTools.help()` on the live page against what's written here.

Call every method through `javascript_tool` in the page context, e.g.:

```js
window.agentTools.addEntity("User", [
  { name: "id", type: "uuid", isPrimary: true },
  { name: "email", type: "string" }
]);
```

## Create

- `addEntity(name: string, attributes?: {name: string, type: string, isPrimary?: boolean}[])`
  → returns `entityId`. Triggers `autoLayout()` automatically.
  Types: `'string' | 'number' | 'boolean' | 'date' | 'uuid' | 'json'`.
- `addAttribute(entityId: string, data?: {name: string, type: string, isPrimary?: boolean})`
  → returns `attributeId`. Does **not** auto-layout.
- `addRelation(sourceEntityId: string, targetEntityId: string, options?: {markerType?: string, color?: string, sourceHandle?: string, targetHandle?: string})`
  → returns `relationId`. Triggers `autoLayout()` automatically.
  `sourceHandle`/`targetHandle` should be the specific `attributeId` when connecting a named FK
  to a named PK; omit to link at the entity level.

## Read

- `getSpec()` → returns the full JSON state of the canvas. Use this to verify a batch of changes
  actually landed as intended before reporting success.
- `help()` → returns the live in-app text summary of this API (sanity-check against this file).

## Update

- `updateEntity(entityId: string, newName: string)`
- `updateEntityColor(entityId: string, colorHex: string)`
- `updateAttribute(entityId: string, attributeId: string, data: {name?: string, type?: string, isPrimary?: boolean})`
- `updateRelation(relationId: string, options: {markerType?: string, color?: string, width?: number})`
  `markerType`: `'arrow' | 'arrowclosed' | 'bidirectional'`.

## Delete

- `removeEntity(entityId: string)` — triggers `autoLayout()` automatically.
- `removeRelation(relationId: string)` — triggers `autoLayout()` automatically.
- `removeAttribute(entityId: string, attributeId: string)`

## Utils

- `autoLayout()` — reorganizes nodes visually. Called automatically by the entity/relation
  create+remove calls above; call it manually after a batch of `addAttribute`/`updateAttribute`
  calls if the layout looks cramped.
- `clear()` — wipes the entire canvas. Confirm with the user before calling this — it's
  destructive and has no built-in confirmation dialog.
- `undo()` / `redo()` — reverts/reapplies the last change (backed by `zundo` history).

## Worked example

```js
const userId = window.agentTools.addEntity("User", [
  { name: "id", type: "uuid", isPrimary: true },
  { name: "email", type: "string" }
]);

const postId = window.agentTools.addEntity("Post", [
  { name: "id", type: "uuid", isPrimary: true },
  { name: "title", type: "string" }
]);

const authorAttrId = window.agentTools.addAttribute(postId, { name: "author_id", type: "uuid" });

window.agentTools.addRelation(postId, userId, {
  sourceHandle: authorAttrId
});
```
