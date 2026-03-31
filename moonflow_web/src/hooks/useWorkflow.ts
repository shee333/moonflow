import { useState, useCallback } from 'react';
import { Workflow } from '../components/types';

const DEFAULT_WORKFLOW: Workflow = {
  id: 'workflow-1',
  name: 'Example Workflow',
  version: '1.0.0',
  nodes: [
    {
      id: '1',
      type: 'http',
      label: 'HTTP Trigger',
      position: { x: 250, y: 5 },
    },
    {
      id: '2',
      type: 'llm',
      label: 'LLM Processor',
      position: { x: 100, y: 200 },
    },
    {
      id: '3',
      type: 'http',
      label: 'HTTP Request',
      position: { x: 400, y: 200 },
    },
    {
      id: '4',
      type: 'response',
      label: 'Response',
      position: { x: 250, y: 400 },
    },
  ],
  edges: [
    { id: 'e1-2', source: '1', target: '2' },
    { id: 'e1-3', source: '1', target: '3' },
    { id: 'e2-4', source: '2', target: '4' },
    { id: 'e3-4', source: '3', target: '4' },
  ],
};

export function useWorkflow(initialWorkflow?: Workflow) {
  const [workflow, setWorkflow] = useState<Workflow>(initialWorkflow || DEFAULT_WORKFLOW);

  const updateWorkflow = useCallback((updatedWorkflow: Workflow) => {
    setWorkflow(updatedWorkflow);
  }, []);

  const updateNodes = useCallback((nodes: Workflow['nodes']) => {
    setWorkflow((prev) => ({
      ...prev,
      nodes,
    }));
  }, []);

  const updateEdges = useCallback((edges: Workflow['edges']) => {
    setWorkflow((prev) => ({
      ...prev,
      edges,
    }));
  }, []);

  return {
    workflow,
    nodes: workflow.nodes,
    edges: workflow.edges,
    updateWorkflow,
    updateNodes,
    updateEdges,
  };
}
