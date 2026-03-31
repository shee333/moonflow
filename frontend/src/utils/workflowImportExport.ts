import { Workflow, WorkflowNode, WorkflowEdge } from '../types';

export interface ImportResult {
  success: boolean;
  workflow?: Workflow;
  errors?: string[];
}

export interface ExportOptions {
  pretty?: boolean;
  includeMetadata?: boolean;
}

export function importWorkflow(jsonString: string): ImportResult {
  try {
    const data = JSON.parse(jsonString);
    
    if (!data.id || !data.name || !data.version) {
      return {
        success: false,
        errors: ['Missing required fields: id, name, or version'],
      };
    }

    if (!Array.isArray(data.nodes)) {
      return {
        success: false,
        errors: ['nodes must be an array'],
      };
    }

    if (!Array.isArray(data.edges)) {
      return {
        success: false,
        errors: ['edges must be an array'],
      };
    }

    const workflow: Workflow = {
      id: data.id,
      name: data.name,
      description: data.description,
      version: data.version,
      nodes: data.nodes.map((node: Partial<WorkflowNode>, index: number) => {
        if (!node.id || !node.type || !node.label || !node.position) {
          throw new Error(`Invalid node at index ${index}`);
        }
        return {
          id: node.id,
          type: node.type,
          label: node.label,
          position: node.position,
          description: node.description,
          config: node.config,
        };
      }),
      edges: data.edges.map((edge: Partial<WorkflowEdge>, index: number) => {
        if (!edge.id || !edge.source || !edge.target) {
          throw new Error(`Invalid edge at index ${index}`);
        }
        return {
          id: edge.id,
          source: edge.source,
          target: edge.target,
          label: edge.label,
          animated: edge.animated,
        };
      }),
      createdAt: data.createdAt || new Date().toISOString(),
      updatedAt: data.updatedAt || new Date().toISOString(),
    };

    return { success: true, workflow };
  } catch (error) {
    return {
      success: false,
      errors: [error instanceof Error ? error.message : 'Unknown error'],
    };
  }
}

export function exportWorkflow(workflow: Workflow, options: ExportOptions = {}): string {
  const { pretty = true, includeMetadata = true } = options;

  const exportData = {
    id: workflow.id,
    name: workflow.name,
    description: workflow.description,
    version: workflow.version,
    nodes: workflow.nodes.map((node) => ({
      id: node.id,
      type: node.type,
      label: node.label,
      position: node.position,
      description: node.description,
      config: node.config,
    })),
    edges: workflow.edges.map((edge) => ({
      id: edge.id,
      source: edge.source,
      target: edge.target,
      label: edge.label,
      animated: edge.animated,
    })),
    ...(includeMetadata && {
      createdAt: workflow.createdAt || new Date().toISOString(),
      updatedAt: workflow.updatedAt || new Date().toISOString(),
    }),
  };

  return JSON.stringify(exportData, null, pretty ? 2 : 0);
}

export function downloadWorkflow(workflow: Workflow, filename?: string): void {
  const json = exportWorkflow(workflow);
  const blob = new Blob([json], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  
  const link = document.createElement('a');
  link.href = url;
  link.download = filename || `${workflow.name.replace(/\s+/g, '-').toLowerCase()}.json`;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  
  URL.revokeObjectURL(url);
}

export function uploadWorkflow(): Promise<ImportResult> {
  return new Promise((resolve) => {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.json';
    
    input.onchange = async (e) => {
      const file = (e.target as HTMLInputElement).files?.[0];
      if (!file) {
        resolve({ success: false, errors: ['No file selected'] });
        return;
      }

      try {
        const text = await file.text();
        const result = importWorkflow(text);
        resolve(result);
      } catch (error) {
        resolve({
          success: false,
          errors: [error instanceof Error ? error.message : 'Failed to read file'],
        });
      }
    };
    
    input.click();
  });
}

export function validateWorkflowStructure(workflow: Workflow): string[] {
  const errors: string[] = [];
  const nodeIds = new Set(workflow.nodes.map((n) => n.id));
  const edgeIds = new Set<string>();

  for (const node of workflow.nodes) {
    if (!node.id || !node.type || !node.label) {
      errors.push(`Node missing required fields: ${JSON.stringify(node)}`);
    }
  }

  for (const edge of workflow.edges) {
    if (!edge.id || !edge.source || !edge.target) {
      errors.push(`Edge missing required fields: ${JSON.stringify(edge)}`);
      continue;
    }

    if (edgeIds.has(edge.id)) {
      errors.push(`Duplicate edge id: ${edge.id}`);
    }
    edgeIds.add(edge.id);

    if (!nodeIds.has(edge.source)) {
      errors.push(`Edge references non-existent source node: ${edge.source}`);
    }

    if (!nodeIds.has(edge.target)) {
      errors.push(`Edge references non-existent target node: ${edge.target}`);
    }
  }

  return errors;
}
