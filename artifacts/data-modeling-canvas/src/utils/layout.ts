import dagre from 'dagre';
import type { Edge, Node } from '@xyflow/react';

const dagreGraph = new dagre.graphlib.Graph();
dagreGraph.setDefaultEdgeLabel(() => ({}));

// Standard dimensions for nodes
const nodeWidth = 260;

export const getLayoutedElements = (nodes: Node[], edges: Edge[], direction = 'LR') => {
  dagreGraph.setGraph({ rankdir: direction, nodesep: 50, ranksep: 150 });

  nodes.forEach((node) => {
    // Estimate node height based on the number of attributes to avoid overlap
    const attrsCount = Array.isArray(node.data.attributes) ? node.data.attributes.length : 0;
    const estimatedHeight = 100 + attrsCount * 42; 
    
    dagreGraph.setNode(node.id, { width: nodeWidth, height: estimatedHeight });
  });

  edges.forEach((edge) => {
    dagreGraph.setEdge(edge.source, edge.target);
  });

  dagre.layout(dagreGraph);

  const newNodes = nodes.map((node) => {
    const nodeWithPosition = dagreGraph.node(node.id);
    // Dagre returns the center point of the node, React Flow expects top-left.
    const newNode = {
      ...node,
      position: {
        x: nodeWithPosition.x - nodeWidth / 2,
        y: nodeWithPosition.y - dagreGraph.node(node.id).height / 2,
      },
    };

    return newNode;
  });

  return { nodes: newNodes, edges };
};
