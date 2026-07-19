import { create } from 'zustand';
import { temporal } from 'zundo';
import {
  addEdge,
  applyNodeChanges,
  applyEdgeChanges,
  MarkerType,
} from '@xyflow/react';
import type {
  Connection,
  Edge,
  EdgeChange,
  Node,
  NodeChange,
  OnNodesChange,
  OnEdgesChange,
  OnConnect,
} from '@xyflow/react';
import { v4 as uuidv4 } from 'uuid';
import { getLayoutedElements } from '../utils/layout';

export type AttributeType = 'string' | 'number' | 'boolean' | 'date' | 'uuid' | 'json' | 'reference';

export interface Attribute {
  id: string;
  name: string;
  type: AttributeType;
  isPrimary?: boolean;
  /** True when the field may be absent/null (e.g. Swift `Type?`). */
  isOptional?: boolean;
  /** Set when type === 'reference': id of the entity this attribute's value is an instance of. */
  refEntityId?: string;
}

export type EntityNodeData = {
  label: string;
  attributes: Attribute[];
  onAddAttribute: (nodeId: string) => void;
  onUpdateAttribute: (nodeId: string, attrId: string, data: Partial<Attribute>) => void;
  onRemoveAttribute: (nodeId: string, attrId: string) => void;
  onChangeLabel: (nodeId: string, label: string) => void;
  color?: string;
};

export type AppNode = Node<EntityNodeData>;

interface ModelingState {
  nodes: AppNode[];
  edges: Edge[];
  clipboard: { nodes: AppNode[], edges: Edge[] } | null;
  interactionMode: 'pan' | 'select';
  isColorPickerOpen: boolean;
  onNodesChange: OnNodesChange;
  onEdgesChange: OnEdgesChange;
  onConnect: OnConnect;
  addEntity: (position: { x: number; y: number }) => void;
  addAttribute: (nodeId: string, data?: Partial<Attribute>) => string | undefined;
  updateAttribute: (nodeId: string, attrId: string, data: Partial<Attribute>) => void;
  removeAttribute: (nodeId: string, attrId: string) => void;
  updateEntityLabel: (nodeId: string, label: string) => void;
  updateNodeColor: (nodeId: string, color: string) => void;
  updateEdgeColor: (edgeId: string, color: string) => void;
  updateEdgeWidth: (edgeId: string, width: number) => void;
  setColorPickerOpen: (open: boolean) => void;
  clearCanvas: () => void;
  exportSpec: () => string;
  importSpec: (specJson: string) => void;
  updateEdgeMarker: (edgeId: string, markerType: string | undefined) => void;
  copySelection: () => void;
  pasteSelection: () => void;
  setInteractionMode: (mode: 'pan' | 'select') => void;
  // Agent / Headless Semantic Interface
  addSemanticEntity: (name: string, attributes?: Partial<Attribute>[]) => string;
  addSemanticRelation: (sourceId: string, targetId: string, options?: { markerType?: string; color?: string; sourceHandle?: string; targetHandle?: string }) => string;
  removeEntity: (nodeId: string) => void;
  removeRelation: (edgeId: string) => void;
  autoLayout: () => void;
}

export const useModelingStore = create<ModelingState>()(
  temporal(
    (set, get) => {
      // Reference-type attributes (e.g. Clube.financas: Financas) represent a nested/composed
      // model, not a hand-drawn FK relation. We keep one derived edge per such attribute in
      // sync automatically — id'd off the attribute so it can be found/updated/removed without
      // scanning, and cleaned up for free by removeAttribute's existing sourceHandle filter.
      const syncReferenceEdge = (nodeId: string, attrId: string) => {
        const state = get();
        const node = state.nodes.find((n) => n.id === nodeId);
        const attr = node?.data.attributes.find((a) => a.id === attrId);
        const edgeId = `refedge_${attrId}`;
        const targetExists = !!attr && !!attr.refEntityId && state.nodes.some((n) => n.id === attr.refEntityId);

        if (attr && attr.type === 'reference' && attr.refEntityId && targetExists) {
          const color = 'var(--accent-secondary)';
          const dashed = !!attr.isOptional;
          const newEdge: Edge = {
            id: edgeId,
            source: nodeId,
            target: attr.refEntityId,
            sourceHandle: attrId,
            targetHandle: 'entity-target-top',
            animated: false,
            type: 'custom',
            data: { markerType: 'arrowclosed', isComposition: true },
            markerEnd: { type: MarkerType.ArrowClosed, width: 18, height: 18, color },
            style: {
              stroke: color,
              strokeWidth: 2,
              strokeDasharray: dashed ? '6 4' : undefined
            }
          };
          set((s) => {
            const exists = s.edges.some((e) => e.id === edgeId);
            return {
              edges: exists
                ? s.edges.map((e) => (e.id === edgeId ? newEdge : e))
                : [...s.edges, newEdge]
            };
          });
        } else {
          set((s) => ({ edges: s.edges.filter((e) => e.id !== edgeId) }));
        }
      };

      return {
      nodes: [],
      edges: [],
      clipboard: null,
      interactionMode: 'pan',
      isColorPickerOpen: false,
  onNodesChange: (changes: NodeChange[]) => {
    set({
      nodes: applyNodeChanges(changes, get().nodes) as AppNode[],
    });
  },
  onEdgesChange: (changes: EdgeChange[]) => {
    set({
      edges: applyEdgeChanges(changes, get().edges),
    });
  },
  onConnect: (connection: Connection) => {
    set({
      edges: addEdge({ ...connection, animated: true, style: { stroke: 'var(--accent-secondary)' } }, get().edges),
    });
  },
  addEntity: (position) => {
    const newNodeId = `entity_${uuidv4()}`;
    const newNode: AppNode = {
      id: newNodeId,
      type: 'entity',
      position,
      data: {
        label: 'Nova Entidade',
        attributes: [
          { id: `attr_${uuidv4()}`, name: 'id', type: 'uuid', isPrimary: true }
        ],
        onAddAttribute: get().addAttribute,
        onUpdateAttribute: get().updateAttribute,
        onRemoveAttribute: get().removeAttribute,
        onChangeLabel: get().updateEntityLabel,
      },
    };
    set({ nodes: [...get().nodes, newNode] });
  },
  addAttribute: (nodeId, data = {}) => {
    const newAttrId = data.id || `attr_${uuidv4()}`;
    let success = false;

    set((state) => {
      const newNodes = state.nodes.map((node) => {
        if (node.id === nodeId) {
          success = true;
          return {
            ...node,
            data: {
              ...node.data,
              attributes: [
                ...node.data.attributes,
                {
                  id: newAttrId,
                  name: data.name || 'novo_atributo',
                  type: data.type || 'string',
                  isPrimary: data.isPrimary,
                  isOptional: data.isOptional,
                  refEntityId: data.refEntityId
                }
              ]
            }
          };
        }
        return node;
      });
      return { nodes: newNodes };
    });

    if (success) {
      syncReferenceEdge(nodeId, newAttrId);
    }

    return success ? newAttrId : undefined;
  },
  updateAttribute: (nodeId, attrId, data) => {
    set((state) => ({
      nodes: state.nodes.map((node) => {
        if (node.id === nodeId) {
          return {
            ...node,
            data: {
              ...node.data,
              attributes: node.data.attributes.map((attr) =>
                attr.id === attrId ? { ...attr, ...data } : attr
              )
            }
          };
        }
        return node;
      })
    }));

    if ('type' in data || 'refEntityId' in data || 'isOptional' in data) {
      syncReferenceEdge(nodeId, attrId);
    }
  },
  removeAttribute: (nodeId, attrId) => {
    set((state) => ({
      nodes: state.nodes.map((node) => {
        if (node.id === nodeId) {
          return {
            ...node,
            data: {
              ...node.data,
              attributes: node.data.attributes.filter((attr) => attr.id !== attrId)
            }
          };
        }
        return node;
      }),
      edges: state.edges.filter((edge) => edge.sourceHandle !== attrId && edge.targetHandle !== attrId)
    }));
  },
  updateEntityLabel: (nodeId, label) => {
    set((state) => ({
      nodes: state.nodes.map((node) => {
        if (node.id === nodeId) {
          return {
            ...node,
            data: { ...node.data, label }
          };
        }
        return node;
      })
    }));
  },
  updateNodeColor: (nodeId, color) => {
    set((state) => ({
      nodes: state.nodes.map((node) => {
        if (node.id === nodeId) {
          return {
            ...node,
            data: { ...node.data, color }
          };
        }
        return node;
      })
    }));
  },
  updateEdgeColor: (edgeId, color) => {
    set((state) => ({
      edges: state.edges.map((edge) => {
        if (edge.id === edgeId) {
          // Keep marker color in sync if it's an object marker
          const updatedMarkerEnd = edge.markerEnd && typeof edge.markerEnd === 'object' 
            ? { ...edge.markerEnd, color }
            : edge.markerEnd;
            
          const updatedMarkerStart = edge.markerStart && typeof edge.markerStart === 'object' 
            ? { ...edge.markerStart, color }
            : edge.markerStart;

          return {
            ...edge,
            markerEnd: updatedMarkerEnd,
            markerStart: updatedMarkerStart,
            style: { ...edge.style, stroke: color, strokeWidth: edge.style?.strokeWidth || 3 }
          };
        }
        return edge;
      })
    }));
  },
  updateEdgeWidth: (edgeId, width) => {
    set((state) => ({
      edges: state.edges.map((edge) => {
        if (edge.id === edgeId) {
          return {
            ...edge,
            style: { ...edge.style, strokeWidth: width }
          };
        }
        return edge;
      })
    }));
  },
  updateEdgeMarker: (edgeId, markerType) => {
    set((state) => ({
      edges: state.edges.map((edge) => {
        if (edge.id === edgeId) {
          let markerEnd = undefined;
          let markerStart = undefined;
          
          if (markerType === 'arrow') {
            markerEnd = { type: MarkerType.Arrow, width: 20, height: 20, color: edge.style?.stroke };
          } else if (markerType === 'bidirectional') {
            markerEnd = { type: MarkerType.Arrow, width: 20, height: 20, color: edge.style?.stroke };
            // markerStart usually points the wrong way if just set to Arrow natively, 
            // but React Flow handles orient="auto-start-reverse" if configured, 
            // or we just use type: Arrow with markerStart
            markerStart = { type: MarkerType.Arrow, width: 20, height: 20, color: edge.style?.stroke, orient: 'auto-start-reverse' };
          }
          return {
            ...edge,
            markerEnd,
            markerStart,
            data: { ...edge.data, markerType }
          };
        }
        return edge;
      })
    }));
  },
  setColorPickerOpen: (open) => set({ isColorPickerOpen: open }),
  clearCanvas: () => {
    set({ nodes: [], edges: [] });
  },
  exportSpec: () => {
    const { nodes, edges } = get();
    const spec = {
      entities: nodes.map(n => ({
        id: n.id,
        name: n.data.label,
        attributes: n.data.attributes,
        position: n.position,
        color: n.data.color
      })),
      // Composition edges (from reference-type attributes) are derived from entity.attributes
      // above and re-synced on import, not hand-authored — exclude them here so they don't show
      // up twice in the spec.
      relations: edges.filter(e => !e.data?.isComposition).map(e => {
        const isEntitySource = e.sourceHandle?.startsWith('entity-source');
        const isEntityTarget = e.targetHandle?.startsWith('entity-target');

        return {
          sourceEntity: e.source,
          sourceAttribute: isEntitySource ? null : e.sourceHandle,
          targetEntity: e.target,
          targetAttribute: isEntityTarget ? null : e.targetHandle,
          color: e.style?.stroke,
          markerType: e.data?.markerType
        };
      })
    };
    return JSON.stringify(spec, null, 2);
  },
  importSpec: (specJson) => {
    try {
      const spec = JSON.parse(specJson);

      // Reference-type attributes get their composition edge regenerated below, after nodes
      // exist — skip any matching relation entries so we don't create a duplicate edge.
      const referenceAttrIds = new Set<string>();
      spec.entities.forEach((e: any) => {
        (e.attributes || []).forEach((a: any) => {
          if (a.type === 'reference' && a.refEntityId) referenceAttrIds.add(a.id);
        });
      });

      const importedNodes: AppNode[] = spec.entities.map((e: any) => ({
        id: e.id,
        type: 'entity',
        position: e.position || { x: 0, y: 0 },
        data: {
          label: e.name,
          attributes: e.attributes || [],
          onAddAttribute: get().addAttribute,
          onUpdateAttribute: get().updateAttribute,
          onRemoveAttribute: get().removeAttribute,
          onChangeLabel: get().updateEntityLabel,
          color: e.color
        }
      }));

      const importedEdges: Edge[] = spec.relations
        .filter((r: any) => !(r.sourceAttribute && referenceAttrIds.has(r.sourceAttribute)))
        .map((r: any) => {
        // Same real-handle-id requirement as addSemanticRelation above.
        const sourceHandle = r.sourceAttribute || 'entity-source-bottom';
        const targetHandle = r.targetAttribute || 'entity-target-top';
        return {
          id: `edge_${uuidv4()}`,
          source: r.sourceEntity,
          target: r.targetEntity,
          sourceHandle,
          targetHandle,
          animated: true,
          type: 'custom',
          data: { markerType: r.markerType },
          markerEnd: (r.markerType === 'arrow' || r.markerType === 'bidirectional')
            ? { type: MarkerType.Arrow, width: 20, height: 20, color: r.color || 'var(--accent-secondary)' } 
            : undefined,
          markerStart: r.markerType === 'bidirectional'
            ? { type: MarkerType.Arrow, width: 20, height: 20, color: r.color || 'var(--accent-secondary)', orient: 'auto-start-reverse' } 
            : undefined,
          style: {  
            stroke: r.color || 'var(--accent-secondary)', 
            strokeWidth: r.color ? 3 : 2 
          }
        };
      });

      set({ nodes: importedNodes, edges: importedEdges });

      // Regenerate composition edges for every reference-type attribute now that all
      // entities exist, rather than trusting the JSON to have encoded them faithfully.
      importedNodes.forEach((node) => {
        node.data.attributes.forEach((attr) => {
          if (attr.type === 'reference' && attr.refEntityId) {
            syncReferenceEdge(node.id, attr.id);
          }
        });
      });
    } catch (error) {
      console.error('Failed to import spec', error);
      alert('Erro ao importar arquivo JSON. O formato pode estar incorreto.');
    }
  },
  setInteractionMode: (mode) => set({ interactionMode: mode }),
  copySelection: () => {
    const { nodes, edges } = get();
    const selectedNodes = nodes.filter((n) => n.selected);
    const selectedEdges = edges.filter((e) => e.selected);
    
    if (selectedNodes.length > 0 || selectedEdges.length > 0) {
      set({ clipboard: { nodes: selectedNodes, edges: selectedEdges } });
    }
  },
  pasteSelection: () => {
    const { clipboard, nodes, edges } = get();
    if (!clipboard || clipboard.nodes.length === 0) return;

    const idMap = new Map<string, string>(); // oldId -> newId for nodes and attributes

    // Process nodes
    const newNodes = clipboard.nodes.map((node) => {
      const newNodeId = `entity_${uuidv4()}`;
      idMap.set(node.id, newNodeId);

      const newAttributes = node.data.attributes.map((attr) => {
        const newAttrId = `attr_${uuidv4()}`;
        idMap.set(attr.id, newAttrId);
        return { ...attr, id: newAttrId };
      });

      return {
        ...node,
        id: newNodeId,
        position: { x: node.position.x + 30, y: node.position.y + 30 },
        selected: true,
        data: {
          ...node.data,
          attributes: newAttributes
        }
      };
    });

    // Process edges
    const newEdges = clipboard.edges.map((edge) => {
      const newEdgeId = `edge_${uuidv4()}`;
      
      const newSource = idMap.get(edge.source) || edge.source;
      const newTarget = idMap.get(edge.target) || edge.target;
      
      // If the handle is an attribute, use the mapped new attribute ID.
      // Otherwise, it might be the default 'entity-source' or 'entity-target'
      const newSourceHandle = edge.sourceHandle?.startsWith('entity') 
        ? edge.sourceHandle 
        : idMap.get(edge.sourceHandle || '') || edge.sourceHandle;
        
      const newTargetHandle = edge.targetHandle?.startsWith('entity')
        ? edge.targetHandle
        : idMap.get(edge.targetHandle || '') || edge.targetHandle;

      return {
        ...edge,
        id: newEdgeId,
        source: newSource,
        target: newTarget,
        sourceHandle: newSourceHandle,
        targetHandle: newTargetHandle,
        selected: true
      };
    }).filter(edge => {
      // Only keep edges where BOTH source and target exist in the new context
      // (This avoids pasting dangling edges if only one node was copied)
      const sourceExists = newNodes.some(n => n.id === edge.source) || nodes.some(n => n.id === edge.source);
      const targetExists = newNodes.some(n => n.id === edge.target) || nodes.some(n => n.id === edge.target);
      return sourceExists && targetExists;
    });

    set({
      // Deselect old items, add new ones
      nodes: [
        ...nodes.map(n => ({ ...n, selected: false })),
        ...newNodes
      ],
      edges: [
        ...edges.map(e => ({ ...e, selected: false })),
        ...newEdges
      ]
    });
  },
  addSemanticEntity: (name, attributes = []) => {
    const newNodeId = `entity_${uuidv4()}`;
    const defaultAttributes: Attribute[] = attributes.length > 0 ? attributes.map(a => ({
      id: a.id || `attr_${uuidv4()}`,
      name: a.name || 'attr',
      type: a.type || 'string',
      isPrimary: a.isPrimary,
      isOptional: a.isOptional,
      refEntityId: a.refEntityId
    })) : [
      { id: `attr_${uuidv4()}`, name: 'id', type: 'uuid', isPrimary: true }
    ];

    const newNode: AppNode = {
      id: newNodeId,
      type: 'entity',
      position: { x: 0, y: 0 }, // Will be fixed by autoLayout
      data: {
        label: name,
        attributes: defaultAttributes,
        onAddAttribute: get().addAttribute,
        onUpdateAttribute: get().updateAttribute,
        onRemoveAttribute: get().removeAttribute,
        onChangeLabel: get().updateEntityLabel,
      },
    };

    set({ nodes: [...get().nodes, newNode] });

    // If any attribute is already typed as a reference to an entity that exists
    // (e.g. created earlier in the same batch), wire up its composition edge now.
    defaultAttributes.forEach((attr) => {
      if (attr.type === 'reference' && attr.refEntityId) {
        syncReferenceEdge(newNodeId, attr.id);
      }
    });

    return newNodeId;
  },
  addSemanticRelation: (sourceId, targetId, options = {}) => {
    const newEdgeId = `edge_${uuidv4()}`;
    const markerType = options.markerType || 'arrowclosed';
    const color = options.color || 'var(--accent-secondary)';

    const newEdge: Edge = {
      id: newEdgeId,
      source: sourceId,
      target: targetId,
      // Must be a real Handle id rendered on EntityNode — there is no bare 'entity-source'/
      // 'entity-target' handle, only the '-top'/'-bottom' variants. The unsuffixed id used to
      // be the default here, which silently failed to render (React Flow drops edges whose
      // handle id doesn't resolve on either node) whenever a caller omitted sourceHandle/
      // targetHandle for a whole-entity relation.
      sourceHandle: options.sourceHandle || 'entity-source-bottom',
      targetHandle: options.targetHandle || 'entity-target-top',
      animated: true,
      type: 'custom',
      data: { markerType },
      markerEnd: markerType === 'arrow' 
        ? { type: MarkerType.Arrow, width: 20, height: 20, color } 
        : markerType === 'arrowclosed' 
          ? { type: MarkerType.ArrowClosed, width: 20, height: 20, color } 
          : undefined,
      style: { 
        stroke: color, 
        strokeWidth: 2 
      }
    };
    
    set({ edges: [...get().edges, newEdge] });
    return newEdgeId;
  },
  removeEntity: (nodeId) => {
    set((state) => ({
      // Deleting an entity that other attributes point to as a complex type would leave a
      // dangling reference — fall those attributes back to a plain string instead.
      nodes: state.nodes
        .filter((n) => n.id !== nodeId)
        .map((n) => ({
          ...n,
          data: {
            ...n.data,
            attributes: n.data.attributes.map((a) =>
              a.refEntityId === nodeId ? { ...a, type: 'string' as AttributeType, refEntityId: undefined } : a
            )
          }
        })),
      edges: state.edges.filter((e) => e.source !== nodeId && e.target !== nodeId)
    }));
  },
  removeRelation: (edgeId) => {
    set((state) => ({
      edges: state.edges.filter((e) => e.id !== edgeId)
    }));
  },
  autoLayout: () => {
    const { nodes, edges } = get();
    const { nodes: layoutedNodes, edges: layoutedEdges } = getLayoutedElements(nodes, edges, 'LR');
    set({ nodes: [...layoutedNodes] as AppNode[], edges: [...layoutedEdges] });
  }
      };
    },
{
  limit: 30,
  partialize: (state) => ({ nodes: state.nodes, edges: state.edges }),
  equality: (pastState, currentState) => {
    // Se algum nó está sendo arrastado, consideramos o estado "igual" ao passado
    // para que o Zundo ignore e não salve essas posições intermediárias.
    if (currentState.nodes.some(n => n.dragging)) {
      return true;
    }

    // Ignoramos propriedades voláteis (dimensões medidas e seleção)
    // Isso impede que o React Flow sobrescreva o histórico futuro (redo) ao injetar o tamanho do nó
    const sanitizeNodes = (nodes: AppNode[]) => nodes.map(n => {
      const { measured, width, height, selected, dragging, ...rest } = n;
      return rest;
    });

    const sanitizeEdges = (edges: Edge[]) => edges.map(e => {
      const { selected, ...rest } = e;
      return rest;
    });

    const pastSanitized = {
      nodes: sanitizeNodes(pastState.nodes),
      edges: sanitizeEdges(pastState.edges)
    };
    
    const currentSanitized = {
      nodes: sanitizeNodes(currentState.nodes),
      edges: sanitizeEdges(currentState.edges)
    };

    // Salva apenas se houver alguma diferença estrutural real (nome, conexões, cor)
    return JSON.stringify(pastSanitized) === JSON.stringify(currentSanitized);
  }
}));
