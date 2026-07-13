import { useEffect, useMemo } from 'react';
import {
  ReactFlow,
  Background,
  Controls,
  MiniMap,
  BackgroundVariant,
  Panel,
  SelectionMode
} from '@xyflow/react';
import '@xyflow/react/dist/style.css';
import EntityNode from '../Nodes/EntityNode';
import CustomEdge from '../Edges/CustomEdge';
import MainToolbar from '../Toolbar/MainToolbar';
import { DraggableColorPicker } from '../Toolbar/DraggableColorPicker';
import { useModelingStore } from '../../store/useModelingStore';

const DataModelingCanvas = () => {
  const { 
    nodes, 
    edges, 
    onNodesChange, 
    onEdgesChange, 
    onConnect,
    isColorPickerOpen,
    setColorPickerOpen,
    updateNodeColor,
    updateEdgeColor,
    copySelection,
    pasteSelection,
    interactionMode
  } = useModelingStore();

  // Get temporal controls from zundo
  const { undo, redo, pause, resume } = useModelingStore.temporal.getState();

  const selectedNode = nodes.find(n => n.selected);
  const selectedEdge = edges.find(e => e.selected);

  useEffect(() => {
    // Fecha o picker flutuante se nada estiver selecionado
    if (!selectedNode && !selectedEdge && isColorPickerOpen) {
      setColorPickerOpen(false);
    }
  }, [selectedNode, selectedEdge, isColorPickerOpen, setColorPickerOpen]);

  const currentColor = selectedNode?.data.color || selectedEdge?.style?.stroke || '#1c1c23';

  const handleColorChange = (color: string) => {
    if (selectedNode) {
      updateNodeColor(selectedNode.id, color);
    } else if (selectedEdge) {
      updateEdgeColor(selectedEdge.id, color);
    }
  };

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // Don't trigger if user is typing in an input
      if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) {
        return;
      }
      
      const isCmdOrCtrl = e.metaKey || e.ctrlKey;
      
      if (isCmdOrCtrl && !e.shiftKey && e.key.toLowerCase() === 'z') {
        e.preventDefault();
        undo();
      } else if (isCmdOrCtrl && (e.key.toLowerCase() === 'y' || (e.shiftKey && e.key.toLowerCase() === 'z'))) {
        e.preventDefault();
        redo();
      } else if (isCmdOrCtrl && e.key.toLowerCase() === 'c') {
        e.preventDefault();
        copySelection();
      } else if (isCmdOrCtrl && e.key.toLowerCase() === 'v') {
        e.preventDefault();
        pasteSelection();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [copySelection, pasteSelection, undo, redo]);

  const nodeTypes = useMemo(() => ({ entity: EntityNode }), []);
  const edgeTypes = useMemo(() => ({ custom: CustomEdge }), []);

  return (
    <div style={{ width: '100vw', height: '100vh', background: 'var(--bg-canvas)' }}>
      <ReactFlow
        nodes={nodes}
        edges={edges}
        onNodesChange={onNodesChange}
        onEdgesChange={onEdgesChange}
        onConnect={onConnect}
        nodeTypes={nodeTypes}
        edgeTypes={edgeTypes}
        fitView
        minZoom={0.1}
        maxZoom={2}
        defaultEdgeOptions={{ 
          type: 'custom',
          animated: true,
          style: { stroke: 'var(--accent-secondary)', strokeWidth: 2 } 
        }}
        panOnDrag={interactionMode === 'pan'}
        selectionOnDrag={interactionMode === 'select'}
        panOnScroll={true}
        selectionMode={SelectionMode.Partial}
        proOptions={{ hideAttribution: true }}
        onNodeDragStart={() => pause()}
        onNodeDragStop={() => resume()}
        onSelectionDragStart={() => pause()}
        onSelectionDragStop={() => resume()}
      >
        <Background variant={BackgroundVariant.Dots} gap={24} size={2} color="var(--grid-color)" />
        
        <Panel position="top-center" style={{ pointerEvents: 'none' }}>
           <div style={{ pointerEvents: 'auto' }}>
             <MainToolbar />
           </div>
        </Panel>

        <Controls 
          position="bottom-left" 
          style={{ 
            background: 'var(--bg-panel)', 
            border: 'var(--glass-border)',
            borderRadius: '8px',
            overflow: 'hidden'
          }} 
        />
        
        <MiniMap 
          position="bottom-right"
          nodeColor="var(--accent-primary)"
          maskColor="rgba(0, 0, 0, 0.4)"
          style={{
            background: 'var(--bg-panel)',
            border: 'var(--glass-border)',
            borderRadius: '8px'
          }}
        />
      </ReactFlow>

      {isColorPickerOpen && (
        <DraggableColorPicker
          color={currentColor}
          onChange={handleColorChange}
          onClose={() => setColorPickerOpen(false)}
        />
      )}
    </div>
  );
};

export default DataModelingCanvas;
