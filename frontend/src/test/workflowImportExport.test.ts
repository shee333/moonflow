import { describe, it, expect } from 'vitest';
import { 
  importWorkflow, 
  exportWorkflow, 
  validateWorkflowStructure 
} from '../utils/workflowImportExport';
import { Workflow } from '../types';

describe('importWorkflow', () => {
  it('should import valid workflow', () => {
    const json = JSON.stringify({
      id: 'test-workflow',
      name: 'Test Workflow',
      version: '1.0.0',
      nodes: [
        { id: '1', type: 'trigger', label: 'Start', position: { x: 0, y: 0 } },
      ],
      edges: [],
    });

    const result = importWorkflow(json);
    expect(result.success).toBe(true);
    expect(result.workflow?.id).toBe('test-workflow');
    expect(result.workflow?.name).toBe('Test Workflow');
  });

  it('should reject workflow without id', () => {
    const json = JSON.stringify({
      name: 'Test',
      version: '1.0.0',
      nodes: [],
      edges: [],
    });

    const result = importWorkflow(json);
    expect(result.success).toBe(false);
    expect(result.errors).toContain('Missing required fields: id, name, or version');
  });

  it('should reject workflow with invalid nodes', () => {
    const json = JSON.stringify({
      id: 'test',
      name: 'Test',
      version: '1.0.0',
      nodes: 'not-an-array',
      edges: [],
    });

    const result = importWorkflow(json);
    expect(result.success).toBe(false);
    expect(result.errors).toContain('nodes must be an array');
  });

  it('should reject workflow with invalid edges', () => {
    const json = JSON.stringify({
      id: 'test',
      name: 'Test',
      version: '1.0.0',
      nodes: [],
      edges: 'not-an-array',
    });

    const result = importWorkflow(json);
    expect(result.success).toBe(false);
    expect(result.errors).toContain('edges must be an array');
  });
});

describe('exportWorkflow', () => {
  it('should export workflow as JSON', () => {
    const workflow: Workflow = {
      id: 'test',
      name: 'Test',
      version: '1.0.0',
      nodes: [],
      edges: [],
    };

    const json = exportWorkflow(workflow);
    const parsed = JSON.parse(json);
    
    expect(parsed.id).toBe('test');
    expect(parsed.name).toBe('Test');
    expect(parsed.version).toBe('1.0.0');
  });

  it('should export with pretty formatting by default', () => {
    const workflow: Workflow = {
      id: 'test',
      name: 'Test',
      version: '1.0.0',
      nodes: [],
      edges: [],
    };

    const json = exportWorkflow(workflow);
    expect(json).toContain('\n');
  });

  it('should export without pretty formatting when disabled', () => {
    const workflow: Workflow = {
      id: 'test',
      name: 'Test',
      version: '1.0.0',
      nodes: [],
      edges: [],
    };

    const json = exportWorkflow(workflow, { pretty: false });
    expect(json).not.toContain('\n');
  });
});

describe('validateWorkflowStructure', () => {
  it('should validate correct workflow', () => {
    const workflow: Workflow = {
      id: 'test',
      name: 'Test',
      version: '1.0.0',
      nodes: [
        { id: '1', type: 'trigger', label: 'Start', position: { x: 0, y: 0 } },
        { id: '2', type: 'llm', label: 'Process', position: { x: 0, y: 100 } },
      ],
      edges: [
        { id: 'e1', source: '1', target: '2' },
      ],
    };

    const errors = validateWorkflowStructure(workflow);
    expect(errors).toHaveLength(0);
  });

  it('should detect duplicate edge ids', () => {
    const workflow: Workflow = {
      id: 'test',
      name: 'Test',
      version: '1.0.0',
      nodes: [
        { id: '1', type: 'trigger', label: 'Start', position: { x: 0, y: 0 } },
        { id: '2', type: 'llm', label: 'End', position: { x: 0, y: 100 } },
      ],
      edges: [
        { id: 'e1', source: '1', target: '2' },
        { id: 'e1', source: '2', target: '1' },
      ],
    };

    const errors = validateWorkflowStructure(workflow);
    expect(errors).toContain('Duplicate edge id: e1');
  });

  it('should detect invalid edge references', () => {
    const workflow: Workflow = {
      id: 'test',
      name: 'Test',
      version: '1.0.0',
      nodes: [
        { id: '1', type: 'trigger', label: 'Start', position: { x: 0, y: 0 } },
      ],
      edges: [
        { id: 'e1', source: '1', target: 'nonexistent' },
      ],
    };

    const errors = validateWorkflowStructure(workflow);
    expect(errors).toContain('Edge references non-existent target node: nonexistent');
  });
});
