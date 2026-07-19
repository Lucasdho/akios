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

## Attribute types

`'string' | 'number' | 'boolean' | 'date' | 'uuid' | 'json' | 'reference'`

- `reference` means the attribute's value **is another entity** — a nested/complex type, e.g.
  `Clube.financas: Financas`. Set `refEntityId` to the target entity's id. The canvas
  auto-draws (and keeps in sync) a composition line from the attribute to that entity — no
  manual `addRelation` call needed. Changing the attribute's type away from `'reference'`,
  removing the attribute, or deleting the target entity all clean the line up automatically.
- `isOptional: true` marks a field that may be absent/null, e.g. `Jogador.clube` being optional
  because a player may not belong to a club. Works on any attribute type. For `reference`
  attributes it renders the composition line **dashed**; for others it's just a flag in the
  spec/UI toggle.

Use a `reference` attribute (not `addRelation`) whenever the request is "entity A contains /
optionally contains entity B" — that's composition, not a hand-drawn FK. Reach for `addRelation`
for FK-style connections between two independent entities instead.

## Create

- `addEntity(name: string, attributes?: {name: string, type: string, isPrimary?: boolean, isOptional?: boolean, refEntityId?: string}[])`
  → returns `entityId`. Triggers `autoLayout()` automatically.
  If a `reference` attribute's `refEntityId` points at an entity that doesn't exist yet in the
  same batch, the composition line won't appear until you `updateAttribute` with that id after
  creating the target — order entity creation so referenced entities exist first when possible.
- `addAttribute(entityId: string, data?: {name: string, type: string, isPrimary?: boolean, isOptional?: boolean, refEntityId?: string})`
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
- `updateAttribute(entityId: string, attributeId: string, data: {name?: string, type?: string, isPrimary?: boolean, isOptional?: boolean, refEntityId?: string})`
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

## Worked example — complex/optional types

"Um Clube contém um modelo Financas. Um Jogador pode ou não pertencer a um Clube."

```js
// Create the referenced entities first so refEntityId resolves immediately.
const financasId = window.agentTools.addEntity("Financas", [
  { name: "id", type: "uuid", isPrimary: true },
  { name: "saldo", type: "number" }
]);

const clubeId = window.agentTools.addEntity("Clube", [
  { name: "id", type: "uuid", isPrimary: true },
  { name: "nome", type: "string" },
  // Composition — Clube always contains a Financas. Draws a solid line.
  { name: "financas", type: "reference", refEntityId: financasId }
]);

const jogadorId = window.agentTools.addEntity("Jogador", [
  { name: "id", type: "uuid", isPrimary: true },
  { name: "nome", type: "string" },
  // Optional composition — a player may not belong to a club. Draws a dashed line.
  { name: "clube", type: "reference", refEntityId: clubeId, isOptional: true }
]);
```
