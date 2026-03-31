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
import { useHistory } from '../hooks';
import { NodeEditorPanel } from './NodeEditorPanel';

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

interface GraphState {
  nodes: Node[];
  edges: Edge[];
}

export function DAGEditor() {
  const [nodes, setNodes, onNodesChange] = useNodesState(initialNodes);
  const [edges, setEdges, onEdgesChange] = useEdgesState(initialEdges);
  const [selectedNode, setSelectedNode] = useState<Node | null>(null);
  const [reactFlowInstance, setReactFlowInstance] = useState<ReactFlowInstance | null>(null);
  const [showNodeEditor, setShowNodeEditor] = useState(false);
  
  const history = useHistory<GraphState>(
    { nodes: initialNodes, edges: initialEdges },
    100
  );

  const handleNodeUpdate = useCallback((nodeId: string, data: any) => {
    const updatedNodes = nodes.map((node) => {
      if (node.id === nodeId) {
        return {
          ...node,
          data: {
            ...node.data,
            ...data,
          },
        };
      }
      return node;
    });
    setNodes(updatedNodes);
    history.set({ nodes: updatedNodes, edges });
    setShowNodeEditor(false);
  }, [nodes, edges, setNodes, history]);

  const onNodeClick: NodeMouseHandler = useCallback((event, node) => {
    setSelectedNode(node);
  }, []);

  const onNodeDoubleClick: NodeMouseHandler = useCallback((event, node) => {
    setSelectedNode(node);
    setShowNodeEditor(true);
  }, []);

  const onPaneClick = useCallback(() => {
    setSelectedNode(null);
    setShowNodeEditor(false);
  }, []);

  const onConnect = useCallback(
    (params: Connection) => {
      const newEdge = {
        ...params,
        animated: true,
        style: { stroke: '#007acc', strokeWidth: 2 },
        markerEnd: { type: MarkerType.ArrowClosed, color: '#007acc' }
      } as Edge;
      
      const newEdges = addEdge(newEdge, edges);
      setEdges(newEdges);
      history.set({ nodes, edges: newEdges });
    },
    [edges, nodes, setEdges, history]
  );

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
    const newNodes = [...nodes, newNode];
    setNodes(newNodes);
    history.set({ nodes: newNodes, edges });
  }, [nodes, edges, setNodes, history]);

  const onNodesDelete = useCallback(
    (deletedNodes: Node[]) => {
      const newNodes = nodes.filter((node) => !deletedNodes.some((d) => d.id === node.id));
      const newEdges = edges.filter(
        (edge) => !deletedNodes.some((d) => d.id === edge.source || d.id === edge.target)
      );
      setNodes(newNodes);
      setEdges(newEdges);
      history.set({ nodes: newNodes, edges: newEdges });
      setSelectedNode(null);
    },
    [nodes, edges, setNodes, setEdges, history]
  );

  const onEdgesDelete = useCallback(
    (deletedEdges: Edge[]) => {
      const newEdges = edges.filter((edge) => !deletedEdges.some((d) => d.id === edge.id));
      setEdges(newEdges);
      history.set({ nodes, edges: newEdges });
    },
    [nodes, edges, setEdges, history]
  );

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

        const newNodes = [...nodes, newNode];
        setNodes(newNodes);
        history.set({ nodes: newNodes, edges });
      } catch (error) {
        console.error('Failed to parse dropped component:', error);
      }
    },
    [reactFlowInstance, nodes, edges, setNodes, history]
  );

  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      const isInputFocused = event.target instanceof HTMLInputElement || 
                             event.target instanceof HTMLTextAreaElement;
      
      if (isInputFocused) return;

      if (event.key === 'z' && (event.ctrlKey || event.metaKey) && !event.shiftKey) {
        event.preventDefault();
        if (history.canUndo) {
          const prevState = history.past[history.past.length - 1];
          history.undo();
          setNodes(prevState.nodes);
          setEdges(prevState.edges);
        }
      } else if ((event.key === 'z' && (event.ctrlKey || event.metaKey) && event.shiftKey) ||
                 (event.key === 'y' && (event.ctrlKey || event.metaKey))) {
        event.preventDefault();
        if (history.canRedo) {
          const nextState = history.future[0];
          history.redo();
          setNodes(nextState.nodes);
          setEdges(nextState.edges);
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
  }, [history, nodes, edges, setNodes, setEdges, selectedNode]);

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
        onNodesDelete={onNodesDelete}
        onEdgesDelete={onEdgesDelete}
        onInit={onInit}
        onDrop={onDrop}
        onDragOver={onDragOver}
        nodeTypes={nodeTypes}
        fitView
        deleteKeyCode={['Delete', 'Backspace']}
      >
        {showNodeEditor && selectedNode && (
          <NodeEditorPanel
            node={selectedNode}
            onUpdate={handleNodeUpdate}
            onClose={() => setShowNodeEditor(false)}
          />
        )}
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
        
        <Panel position="top-right">
          <div style={{
            display: 'flex',
            gap: '8px',
            marginBottom: '8px'
          }}>
            <button
              onClick={() => {
                if (history.canUndo) {
                  const prevState = history.past[history.past.length - 1];
                  history.undo();
                  setNodes(prevState.nodes);
                  setEdges(prevState.edges);
                }
              }}
              disabled={!history.canUndo}
              style={{
                padding: '6px 12px',
                backgroundColor: history.canUndo ? '#6b7280' : '#3c3c3c',
                border: 'none',
                borderRadius: '4px',
                color: 'white',
                cursor: history.canUndo ? 'pointer' : 'not-allowed',
                fontSize: '12px',
                opacity: history.canUndo ? 1 : 0.5,
              }}
              title="撤销 (Ctrl+Z)"
            >
              ↩️ 撤销
            </button>
            <button
              onClick={() => {
                if (history.canRedo) {
                  const nextState = history.future[0];
                  history.redo();
                  setNodes(nextState.nodes);
                  setEdges(nextState.edges);
                }
              }}
              disabled={!history.canRedo}
              style={{
                padding: '6px 12px',
                backgroundColor: history.canRedo ? '#6b7280' : '#3c3c3c',
                border: 'none',
                borderRadius: '4px',
                color: 'white',
                cursor: history.canRedo ? 'pointer' : 'not-allowed',
                fontSize: '12px',
                opacity: history.canRedo ? 1 : 0.5,
              }}
              title="重做 (Ctrl+Shift+Z)"
            >
              ↪️ 重做
            </button>
          </div>
        </Panel>
        
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
          双击节点编辑配置 • Delete 删除节点 • Ctrl+Z 撤销 • Ctrl+Shift+Z 重做 • Ctrl+S 保存
        </div>
      </ReactFlow>
    </div>
  );
}
