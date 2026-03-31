export type NodeType = 
  | 'trigger'
  | 'tool'
  | 'agent'
  | 'control'
  | 'llm'
  | 'http'
  | 'database'
  | 'transformer'
  | 'response'
  | 'notification'
  | 'cron';

export type TriggerType = 'http' | 'cron' | 'webhook' | 'manual';

export type ToolType = 
  | 'http-get'
  | 'http-post'
  | 'email'
  | 'feishu'
  | 'file-read'
  | 'file-write'
  | 'file-delete';

export type AgentType = 'llm' | 'intent-classify';

export type ControlType = 'condition' | 'parallel' | 'loop' | 'end';

export interface NodePosition {
  x: number;
  y: number;
}

export interface NodeConfig {
  [key: string]: unknown;
}

export interface WorkflowNode {
  id: string;
  type: NodeType;
  label: string;
  position: NodePosition;
  description?: string;
  config?: NodeConfig;
}

export interface WorkflowEdge {
  id: string;
  source: string;
  target: string;
  label?: string;
  animated?: boolean;
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

export interface WorkflowValidationResult {
  valid: boolean;
  errors: string[];
  warnings?: string[];
}

export interface CodeGenerationOptions {
  packageName?: string;
  includeComments?: boolean;
  minify?: boolean;
}

export interface ExecutionContext {
  workflow: Workflow;
  variables: Map<string, unknown>;
  secrets: Map<string, string>;
  executionId: string;
}

export type ExecutionStatus = 
  | 'pending'
  | 'running'
  | 'completed'
  | 'failed'
  | 'cancelled';

export interface ExecutionResult {
  executionId: string;
  status: ExecutionStatus;
  output?: unknown;
  error?: string;
  duration?: number;
  nodeResults?: Map<string, unknown>;
}

export interface ComponentDefinition {
  type: NodeType;
  label: string;
  description: string;
  icon: string;
  category: 'trigger' | 'processor' | 'logic' | 'output';
  fields: FieldDefinition[];
  defaultConfig?: NodeConfig;
}

export interface FieldDefinition {
  name: string;
  label: string;
  type: 'string' | 'number' | 'boolean' | 'select' | 'code' | 'json';
  required?: boolean;
  defaultValue?: unknown;
  options?: { label: string; value: string }[];
  placeholder?: string;
  helpText?: string;
}

export const NODE_CATEGORIES = {
  trigger: {
    label: '触发器',
    color: '#10b981',
  },
  processor: {
    label: '处理器',
    color: '#3b82f6',
  },
  logic: {
    label: '逻辑控制',
    color: '#f59e0b',
  },
  output: {
    label: '输出',
    color: '#8b5cf6',
  },
} as const;

export const NODE_ICONS: Record<NodeType, string> = {
  trigger: '⚡',
  tool: '🔧',
  agent: '🤖',
  control: '🔀',
  llm: '🧠',
  http: '🌐',
  database: '💾',
  transformer: '⚙️',
  response: '📤',
  notification: '📢',
  cron: '⏰',
};
