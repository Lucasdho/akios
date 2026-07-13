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

Create:
- addEntity(name: string, attributes?: {name: string, type: string, isPrimary?: boolean}[]) => returns entityId
- addRelation(sourceEntityId: string, targetEntityId: string, options?: {markerType?: string, color?: string, sourceHandle?: string, targetHandle?: string}) => returns relationId
  * Note: sourceHandle/targetHandle should be the Attribute IDs if connecting specific fields.
- addAttribute(entityId: string, data?: {name: string, type: string, isPrimary?: boolean}) => returns attributeId

Update:
- updateEntity(entityId: string, newName: string)
- updateEntityColor(entityId: string, colorHex: string)
- updateAttribute(entityId: string, attributeId: string, data: {name?: string, type?: string, isPrimary?: boolean})
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
