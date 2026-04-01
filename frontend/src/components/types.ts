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
  config?: Record<string, unknown>;
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
  version: string;
  nodes: WorkflowNode[];
  edges: WorkflowEdge[];
  createdAt?: string;
  updatedAt?: string;
}

export interface ValidationResult {
  valid: boolean;
  errors: string[];
  warnings?: string[];
}

export interface ExecutionResult {
  status: 'success' | 'error' | 'pending';
  message: string;
  data?: unknown;
  timestamp: number;
}

export interface LLMConfig {
  provider: 'openai' | 'claude' | 'gemini' | 'custom';
  model: string;
  apiKey?: string;
  baseUrl?: string;
  temperature?: number;
  maxTokens?: number;
}

export interface NodeExecutionContext {
  nodeId: string;
  input: unknown;
  config: Record<string, unknown>;
  secrets: Record<string, string>;
}
