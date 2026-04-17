const API_BASE = '/api';

async function request<T>(path: string, options?: RequestInit): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`, {
    headers: { 'Content-Type': 'application/json' },
    ...options,
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(body || res.statusText);
  }
  return res.json();
}

export interface HealthResponse {
  status: string;
  engine: string;
  version: string;
}

export interface ExecutionResult {
  success: boolean;
  execution_id?: string;
  workflow_id?: string;
  status?: string;
  duration_ms?: number;
  node_results?: Record<string, { status: string; duration_ms: number }>;
  error?: string;
}

export interface ValidationResult {
  valid: boolean;
  error?: string;
}

export interface WorkflowListResponse {
  workflows: Array<{ name: string; data: unknown }>;
}

export interface ComponentListResponse {
  components: Array<{ name: string; category: string }>;
}

export const apiService = {
  health: () => request<HealthResponse>('/health'),

  executeWorkflow: (workflowJson: string) =>
    request<ExecutionResult>('/execute', {
      method: 'POST',
      body: workflowJson,
    }),

  validateWorkflow: (workflowJson: string) =>
    request<ValidationResult>('/validate', {
      method: 'POST',
      body: workflowJson,
    }),

  saveWorkflow: (workflowJson: string) =>
    request<{ success: boolean; name: string }>('/workflows', {
      method: 'POST',
      body: workflowJson,
    }),

  listWorkflows: () => request<WorkflowListResponse>('/workflows'),

  listComponents: () => request<ComponentListResponse>('/components'),

  listExecutions: () =>
    request<{ executions: unknown[] }>('/executions'),

  llmProxy: (body: string) =>
    request<{ success: boolean; response: { content: string; model: string; tokens: number } }>('/llm', {
      method: 'POST',
      body,
    }),
};
