import { useModelingStore } from '../store/useModelingStore';

declare global {
  interface Window {
    agentTools: any;
  }
}

export const initAgentInterface = () => {
  window.agentTools = {
    // --- CREATE ---
    addEntity: (name: string, attributes?: any[]) => {
      const id = useModelingStore.getState().addSemanticEntity(name, attributes);
      useModelingStore.getState().autoLayout();
      return id;
    },
    addRelation: (sourceId: string, targetId: string, options?: any) => {
      const id = useModelingStore.getState().addSemanticRelation(sourceId, targetId, options);
      useModelingStore.getState().autoLayout();
      return id;
    },
    addAttribute: (entityId: string, data?: any) => {
      const attrId = useModelingStore.getState().addAttribute(entityId, data);
      return attrId;
    },

    // --- READ ---
    getSpec: () => {
      return useModelingStore.getState().exportSpec();
    },

    // --- UPDATE ---
    updateEntity: (id: string, name: string) => {
      useModelingStore.getState().updateEntityLabel(id, name);
    },
    updateEntityColor: (id: string, color: string) => {
      useModelingStore.getState().updateNodeColor(id, color);
    },
    updateAttribute: (entityId: string, attrId: string, data: any) => {
      useModelingStore.getState().updateAttribute(entityId, attrId, data);
    },
    updateRelation: (relationId: string, options: { markerType?: string; color?: string; width?: number }) => {
      if (options.color) useModelingStore.getState().updateEdgeColor(relationId, options.color);
      if (options.markerType) useModelingStore.getState().updateEdgeMarker(relationId, options.markerType);
      if (options.width) useModelingStore.getState().updateEdgeWidth(relationId, options.width);
    },

    // --- DELETE ---
    removeEntity: (id: string) => {
      useModelingStore.getState().removeEntity(id);
      useModelingStore.getState().autoLayout();
    },
    removeRelation: (id: string) => {
      useModelingStore.getState().removeRelation(id);
      useModelingStore.getState().autoLayout();
    },
    removeAttribute: (entityId: string, attrId: string) => {
      useModelingStore.getState().removeAttribute(entityId, attrId);
    },

    // --- UTILS ---
    autoLayout: () => {
      useModelingStore.getState().autoLayout();
    },
    clear: () => {
      useModelingStore.getState().clearCanvas();
    },
    undo: () => {
      useModelingStore.temporal.getState().undo();
    },
    redo: () => {
      useModelingStore.temporal.getState().redo();
    },
    help: () => {
      return `
🤖 AGENT TOOLS API - Canvas Modeling
===================================
State reading:
- getSpec() => Returns JSON representation of the entire canvas.

Attribute types: 'string' | 'number' | 'boolean' | 'date' | 'uuid' | 'json' | 'reference'
- 'reference' means the field's value IS another entity (a nested/complex type, e.g.
  Clube.financas: Financas) — set refEntityId to the target entity's id. This auto-draws/updates
  a composition line from the attribute to that entity on the canvas (dashed if isOptional).
  Removing the attribute, changing its type away from 'reference', or deleting the target entity
  cleans the line up automatically.
- isOptional: true means the field may be absent/null (e.g. Jogador.clube being optional because
  a player may not belong to a club). Works on any attribute type, not just 'reference'. Shown as
  a dashed composition line for references, and as a toggle in the UI otherwise.

Create:
- addEntity(name: string, attributes?: {name: string, type: string, isPrimary?: boolean, isOptional?: boolean, refEntityId?: string}[]) => returns entityId
  * For 'reference' attributes pointing at an entity created earlier in the same batch, refEntityId works immediately. If the target doesn't exist yet, create it first (or addAttribute/updateAttribute afterward once it does).
- addRelation(sourceEntityId: string, targetEntityId: string, options?: {markerType?: string, color?: string, sourceHandle?: string, targetHandle?: string}) => returns relationId
  * Note: sourceHandle/targetHandle should be the Attribute IDs if connecting specific fields.
  * Use this for hand-drawn FK-style relations. For "entity A contains/optionally-contains entity B" composition, prefer a 'reference' attribute instead (see above) — it draws itself.
- addAttribute(entityId: string, data?: {name: string, type: string, isPrimary?: boolean, isOptional?: boolean, refEntityId?: string}) => returns attributeId

Update:
- updateEntity(entityId: string, newName: string)
- updateEntityColor(entityId: string, colorHex: string)
- updateAttribute(entityId: string, attributeId: string, data: {name?: string, type?: string, isPrimary?: boolean, isOptional?: boolean, refEntityId?: string})
- updateRelation(relationId: string, options: {markerType?: string, color?: string, width?: number})

Delete:
- removeEntity(entityId: string)
- removeRelation(relationId: string)
- removeAttribute(entityId: string, attributeId: string)

Utils:
- clear() => Wipes the canvas
- autoLayout() => Reorganizes nodes visually (called automatically on add/remove entity)
- undo() / redo() => Reverts or reapplies changes
      `.trim();
    }
  };
  
  console.log('🤖 Agent Interface initialized. You can now use window.agentTools from the console or local agent plugins.');
};
