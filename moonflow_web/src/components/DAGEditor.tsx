import { useCallback, useState, useEffect } from 'react';
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
  ReactFlowInstance,
  NodeMouseHandler,
  MarkerType,
} from '@xyflow/react';
import '@xyflow/react/dist/style.css';
import { MoonFlowNode } from './MoonFlowNode';
import { ComponentPalette } from './ComponentPalette';
import { ComponentType } from './types';

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
  { 
    id: 'e1-2', 
    source: '1', 
    target: '2', 
    animated: true,
    style: { stroke: '#007acc', strokeWidth: 2 },
    markerEnd: { type: MarkerType.ArrowClosed, color: '#007acc' }
  },
  { 
    id: 'e1-3', 
    source: '1', 
    target: '3', 
    animated: true,
    style: { stroke: '#007acc', strokeWidth: 2 },
    markerEnd: { type: MarkerType.ArrowClosed, color: '#007acc' }
  },
  { 
    id: 'e2-4', 
    source: '2', 
    target: '4',
    style: { stroke: '#28a745', strokeWidth: 2 },
    markerEnd: { type: MarkerType.ArrowClosed, color: '#28a745' }
  },
  { 
    id: 'e3-4', 
    source: '3', 
    target: '4',
    style: { stroke: '#28a745', strokeWidth: 2 },
    markerEnd: { type: MarkerType.ArrowClosed, color: '#28a745' }
  },
];

export function DAGEditor() {
  const [nodes, setNodes, onNodesChange] = useNodesState(initialNodes);
  const [edges, setEdges, onEdgesChange] = useEdgesState(initialEdges);
  const [selectedNode, setSelectedNode] = useState<Node | null>(null);
  const [reactFlowInstance, setReactFlowInstance] = useState<ReactFlowInstance | null>(null);

  const onConnect = useCallback(
    (params: Connection) => setEdges((eds) => addEdge({ ...params, 
      animated: true,
      style: { stroke: '#007acc', strokeWidth: 2 },
      markerEnd: { type: MarkerType.ArrowClosed, color: '#007acc' }
    }, eds)),
    [setEdges],
  );

  const onNodeClick: NodeMouseHandler = useCallback((event, node) => {
    setSelectedNode(node);
  }, []);

  const onNodeDoubleClick: NodeMouseHandler = useCallback((event, node) => {
    setSelectedNode(node);
    const customEvent = new CustomEvent('openNodeConfig', { detail: { nodeId: node.id } });
    window.dispatchEvent(customEvent);
  }, []);

  const onPaneClick = useCallback(() => {
    setSelectedNode(null);
  }, []);

  const onNodeAdd = useCallback((componentType: string, label: string, description: string) => {
    const newNode: Node = {
      id: `${Date.now()}`,
      type: 'moonflow',
      position: { x: Math.random() * 400 + 100, y: Math.random() * 300 + 100 },
      data: {
        label,
        component: componentType,
        description,
      },
    };
    setNodes((nds) => [...nds, newNode]);
  }, [setNodes]);

  const onInit = useCallback((instance: ReactFlowInstance) => {
    setReactFlowInstance(instance);
  }, []);

  const onDragOver = useCallback((event: React.DragEvent) => {
    event.preventDefault();
    event.dataTransfer.dropEffect = 'move';
  }, []);

  const onDrop = useCallback(
    (event: React.DragEvent) => {
      event.preventDefault();

      if (!reactFlowInstance) {
        return;
      }

      const dataStr = event.dataTransfer.getData('application/json');
      if (!dataStr) {
        return;
      }

      try {
        const component: ComponentType = JSON.parse(dataStr);
        
        const bounds = event.currentTarget.getBoundingClientRect();
        const position = reactFlowInstance.screenToFlowPosition({
          x: event.clientX - bounds.left,
          y: event.clientY - bounds.top,
        });

        const newNode: Node = {
          id: `${Date.now()}`,
          type: 'moonflow',
          position,
          data: {
            label: component.label,
            component: component.type,
            description: component.description,
          },
        };

        setNodes((nds) => [...nds, newNode]);
      } catch (error) {
        console.error('Failed to parse dropped component:', error);
      }
    },
    [reactFlowInstance, setNodes],
  );

  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Delete' || event.key === 'Backspace') {
        if (selectedNode && !(event.target instanceof HTMLInputElement || event.target instanceof HTMLTextAreaElement)) {
          setNodes((nds) => nds.filter((node) => node.id !== selectedNode.id));
          setEdges((eds) => eds.filter((edge) => edge.source !== selectedNode.id && edge.target !== selectedNode.id));
          setSelectedNode(null);
        }
      } else if (event.key === 'Escape') {
        setSelectedNode(null);
      } else if (event.key === 's' && (event.ctrlKey || event.metaKey)) {
        event.preventDefault();
        const workflow = {
          id: 'workflow-1',
          name: 'Saved Workflow',
          nodes: nodes.map((node) => ({
            id: node.id,
            type: node.data.component,
            label: node.data.label,
            description: node.data.description,
            config: node.data.config,
            position: node.position,
          })),
          edges: edges.map((edge) => ({
            id: edge.id,
            source: edge.source,
            target: edge.target,
          })),
        };
        const blob = new Blob([JSON.stringify(workflow, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'workflow.json';
        a.click();
        URL.revokeObjectURL(url);
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [selectedNode, nodes, edges, setNodes, setEdges]);

  return (
    <div style={{ width: '100%', height: '100%' }}>
      <ReactFlow
        nodes={nodes}
        edges={edges}
        onNodesChange={onNodesChange}
        onEdgesChange={onEdgesChange}
        onConnect={onConnect}
        onNodeClick={onNodeClick}
        onNodeDoubleClick={onNodeDoubleClick}
        onPaneClick={onPaneClick}
        onInit={onInit}
        onDrop={onDrop}
        onDragOver={onDragOver}
        nodeTypes={nodeTypes}
        fitView
        deleteKeyCode={['Delete', 'Backspace']}
      >
        <Background color="#3c3c3c" gap={20} />
        <Controls 
          showZoom={true}
          showFitView={true}
          showInteractive={false}
          position="bottom-right"
        />
        <MiniMap 
          nodeColor={(node) => {
            const component = node.data?.component;
            switch (component) {
              case 'http': return '#007acc';
              case 'llm': return '#9333ea';
              case 'timer': return '#f59e0b';
              case 'database': return '#10b981';
              case 'response': return '#22c55e';
              default: return '#6b7280';
            }
          }}
          maskColor="rgba(0, 0, 0, 0.8)"
          style={{
            backgroundColor: '#252526'
          }}
        />
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
              minWidth: '280px'
            }}>
              <h3 style={{ marginTop: 0, marginBottom: '8px' }}>{selectedNode.data.label}</h3>
              <p style={{ margin: '4px 0', fontSize: '13px' }}><strong>Component:</strong> {selectedNode.data.component}</p>
              <p style={{ margin: '4px 0', fontSize: '13px' }}><strong>Description:</strong> {selectedNode.data.description}</p>
              <p style={{ margin: '4px 0', fontSize: '13px' }}><strong>ID:</strong> {selectedNode.id}</p>
              <button
                onClick={() => {
                  const customEvent = new CustomEvent('openNodeConfig', { detail: { nodeId: selectedNode.id } });
                  window.dispatchEvent(customEvent);
                }}
                style={{
                  marginTop: '12px',
                  width: '100%',
                  padding: '8px',
                  backgroundColor: '#007acc',
                  border: 'none',
                  borderRadius: '4px',
                  color: 'white',
                  cursor: 'pointer',
                  fontSize: '13px'
                }}
              >
                Configure Node
              </button>
            </div>
          </Panel>
        )}
        <div style={{
          position: 'absolute',
          bottom: '20px',
          left: '20px',
          background: 'rgba(0, 0, 0, 0.7)',
          color: 'white',
          padding: '8px 12px',
          borderRadius: '4px',
          fontSize: '12px',
          pointerEvents: 'none'
        }}>
          Double-click node to configure • Delete to remove • Ctrl+S to save
        </div>
      </ReactFlow>
    </div>
  );
}
