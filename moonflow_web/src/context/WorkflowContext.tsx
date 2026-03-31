import React, { createContext, useContext, useState, useCallback, ReactNode } from 'react';
import { Node, Edge } from '@xyflow/react';

export type NodeData = {
  label?: string;
  type?: string;
  component?: string;
  description?: string;
  [key: string]: any;
};

interface WorkflowContextType {
  nodes: Node<NodeData>[];
  setNodes: React.Dispatch<React.SetStateAction<Node<NodeData>[]>>;
  edges: Edge[];
  setEdges: React.Dispatch<React.SetStateAction<Edge[]>>;
  updateNodeData: (nodeId: string, data: Partial<NodeData>) => void;
  addNode: (node: Node<NodeData>) => void;
  removeNode: (nodeId: string) => void;
  clearWorkflow: () => void;
  loadWorkflow: (nodes: Node<NodeData>[], edges: Edge[]) => void;
}

const WorkflowContext = createContext<WorkflowContextType | undefined>(undefined);

const initialNodes: Node<NodeData>[] = [
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
  },
  {
    id: 'e1-3',
    source: '1',
    target: '3',
    animated: true,
    style: { stroke: '#007acc', strokeWidth: 2 },
  },
  {
    id: 'e2-4',
    source: '2',
    target: '4',
    style: { stroke: '#28a745', strokeWidth: 2 },
  },
  {
    id: 'e3-4',
    source: '3',
    target: '4',
    style: { stroke: '#28a745', strokeWidth: 2 },
  },
];

export function WorkflowProvider({ children }: { children: ReactNode }) {
  const [nodes, setNodes] = useState<Node<NodeData>[]>(initialNodes);
  const [edges, setEdges] = useState<Edge[]>(initialEdges);

  const updateNodeData = useCallback((nodeId: string, data: Partial<NodeData>) => {
    setNodes(prevNodes =>
      prevNodes.map(node =>
        node.id === nodeId
          ? { ...node, data: { ...node.data, ...data } }
          : node
      )
    );
  }, []);

  const addNode = useCallback((node: Node<NodeData>) => {
    setNodes(prevNodes => [...prevNodes, node]);
  }, []);

  const removeNode = useCallback((nodeId: string) => {
    setNodes(prevNodes => prevNodes.filter(node => node.id !== nodeId));
    setEdges(prevEdges =>
      prevEdges.filter(edge => edge.source !== nodeId && edge.target !== nodeId)
    );
  }, []);

  const clearWorkflow = useCallback(() => {
    setNodes([]);
    setEdges([]);
  }, []);

  const loadWorkflow = useCallback((newNodes: Node<NodeData>[], newEdges: Edge[]) => {
    setNodes(newNodes);
    setEdges(newEdges);
  }, []);

  const value: WorkflowContextType = {
    nodes,
    setNodes,
    edges,
    setEdges,
    updateNodeData,
    addNode,
    removeNode,
    clearWorkflow,
    loadWorkflow,
  };

  return (
    <WorkflowContext.Provider value={value}>
      {children}
    </WorkflowContext.Provider>
  );
}

export function useWorkflow(): WorkflowContextType {
  const context = useContext(WorkflowContext);
  if (context === undefined) {
    throw new Error('useWorkflow must be used within a WorkflowProvider');
  }
  return context;
}
