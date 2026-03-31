import { useCallback, useState } from 'react';
import {
  ReactFlow,
  addEdge,
  Background,
  Controls,
  MiniMap,
  useNodesState,
  useEdgesState,
  Connection,
  Edge,
  Node,
  Panel,
} from '@xyflow/react';
import '@xyflow/react/dist/style.css';
import { MoonFlowNode } from './MoonFlowNode';
import { ComponentPalette } from './ComponentPalette';

const nodeTypes = {
  moonflow: MoonFlowNode,
};

const initialNodes: Node[] = [
  {
    id: '1',
    type: 'moonflow',
    position: { x: 250, y: 5 },
    data: { 
      label: 'HTTP Trigger',
      component: 'http',
      description: 'Start workflow via HTTP request'
    },
  },
  {
    id: '2',
    type: 'moonflow',
    position: { x: 100, y: 200 },
    data: { 
      label: 'LLM Processor',
      component: 'llm',
      description: 'Process with AI language model'
    },
  },
  {
    id: '3',
    type: 'moonflow',
    position: { x: 400, y: 200 },
    data: { 
      label: 'HTTP Request',
      component: 'http',
      description: 'Make external API call'
    },
  },
  {
    id: '4',
    type: 'moonflow',
    position: { x: 250, y: 400 },
    data: { 
      label: 'Response',
      component: 'response',
      description: 'Return result to caller'
    },
  },
];

const initialEdges: Edge[] = [
  { id: 'e1-2', source: '1', target: '2', animated: true },
  { id: 'e1-3', source: '1', target: '3', animated: true },
  { id: 'e2-4', source: '2', target: '4' },
  { id: 'e3-4', source: '3', target: '4' },
];

export function DAGEditor() {
  const [nodes, setNodes, onNodesChange] = useNodesState(initialNodes);
  const [edges, setEdges, onEdgesChange] = useEdgesState(initialEdges);
  const [selectedNode, setSelectedNode] = useState<Node | null>(null);

  const onConnect = useCallback(
    (params: Connection) => setEdges((eds) => addEdge(params, eds)),
    [setEdges],
  );

  const onNodeClick = useCallback((event: React.MouseEvent, node: Node) => {
    setSelectedNode(node);
  }, []);

  const onPaneClick = useCallback(() => {
    setSelectedNode(null);
  }, []);

  const onNodeAdd = useCallback((componentType: string, label: string, description: string) => {
    const newNode: Node = {
      id: `${Date.now()}`,
      type: 'moonflow',
      position: { x: Math.random() * 400, y: Math.random() * 400 },
      data: {
        label,
        component: componentType,
        description,
      },
    };
    setNodes((nds) => [...nds, newNode]);
  }, [setNodes]);

  return (
    <div style={{ width: '100%', height: '100vh' }}>
      <ReactFlow
        nodes={nodes}
        edges={edges}
        onNodesChange={onNodesChange}
        onEdgesChange={onEdgesChange}
        onConnect={onConnect}
        onNodeClick={onNodeClick}
        onPaneClick={onPaneClick}
        nodeTypes={nodeTypes}
        fitView
      >
        <Background />
        <Controls />
        <MiniMap />
        <Panel position="top-left">
          <ComponentPalette onAdd={onNodeAdd} />
        </Panel>
        {selectedNode && (
          <Panel position="top-right">
            <div style={{ 
              padding: '16px', 
              background: 'white', 
              borderRadius: '8px', 
              boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
              minWidth: '250px'
            }}>
              <h3 style={{ marginTop: 0 }}>{selectedNode.data.label}</h3>
              <p><strong>Component:</strong> {selectedNode.data.component}</p>
              <p><strong>Description:</strong> {selectedNode.data.description}</p>
              <p><strong>ID:</strong> {selectedNode.id}</p>
            </div>
          </Panel>
        )}
      </ReactFlow>
    </div>
  );
}
