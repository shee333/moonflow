export interface ComponentType {
  type: string;
  label: string;
  description: string;
  category: string;
}

export interface WorkflowNode {
  id: string;
  type: string;
  label: string;
  description?: string;
  config?: Record<string, any>;
  position?: {
    x: number;
    y: number;
  };
}

export interface WorkflowEdge {
  id: string;
  source: string;
  target: string;
  label?: string;
  condition?: string;
}

export interface Workflow {
  id: string;
  name: string;
  description?: string;
  nodes: WorkflowNode[];
  edges: WorkflowEdge[];
  version: string;
  createdAt?: string;
  updatedAt?: string;
}
