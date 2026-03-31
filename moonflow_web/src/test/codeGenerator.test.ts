import { describe, it, expect } from 'vitest';
import { validateWorkflow } from '../utils/codeGenerator';
import type { Workflow } from '../components/types';

describe('codeGenerator', () => {
  describe('validateWorkflow', () => {
    it('should validate a correct workflow', () => {
      const workflow: Workflow = {
        id: 'workflow-1',
        name: 'Test Workflow',
        version: '1.0.0',
        nodes: [
          { id: '1', type: 'http', label: 'Start', position: { x: 0, y: 0 } },
          { id: '2', type: 'llm', label: 'Process', position: { x: 0, y: 100 } },
        ],
        edges: [
          { id: 'e1', source: '1', target: '2' },
        ],
      };

      const result = validateWorkflow(workflow);
      expect(result.valid).toBe(true);
      expect(result.errors).toHaveLength(0);
    });

    it('should reject workflow without id', () => {
      const workflow = {
        name: 'Test Workflow',
        nodes: [],
        edges: [],
      } as Workflow;

      const result = validateWorkflow(workflow);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Workflow ID is required');
    });

    it('should reject workflow without name', () => {
      const workflow = {
        id: 'workflow-1',
        nodes: [],
        edges: [],
      } as Workflow;

      const result = validateWorkflow(workflow);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Workflow name is required');
    });

    it('should reject workflow without nodes', () => {
      const workflow = {
        id: 'workflow-1',
        name: 'Test Workflow',
        nodes: [],
        edges: [],
      } as Workflow;

      const result = validateWorkflow(workflow);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Workflow must have at least one node');
    });

    it('should reject workflow without start node', () => {
      const workflow: Workflow = {
        id: 'workflow-1',
        name: 'Test Workflow',
        version: '1.0.0',
        nodes: [
          { id: '1', type: 'http', label: 'Start', position: { x: 0, y: 0 } },
          { id: '2', type: 'llm', label: 'Process', position: { x: 0, y: 100 } },
        ],
        edges: [
          { id: 'e1', source: '1', target: '2' },
          { id: 'e2', source: '2', target: '1' },
        ],
      };

      const result = validateWorkflow(workflow);
      expect(result.valid).toBe(false);
    });

    it('should reject workflow with unreachable nodes', () => {
      const workflow: Workflow = {
        id: 'workflow-1',
        name: 'Test Workflow',
        version: '1.0.0',
        nodes: [
          { id: '1', type: 'http', label: 'Start', position: { x: 0, y: 0 } },
          { id: '2', type: 'llm', label: 'Process', position: { x: 0, y: 100 } },
          { id: '3', type: 'response', label: 'End', position: { x: 0, y: 200 } },
          { id: '4', type: 'database', label: 'DB', position: { x: 0, y: 300 } },
        ],
        edges: [
          { id: 'e1', source: '1', target: '2' },
          { id: 'e2', source: '3', target: '4' },
        ],
      };

      const result = validateWorkflow(workflow);
      expect(result.valid).toBe(false);
      expect(result.errors.some(e => e.includes('Unreachable'))).toBe(true);
    });

    it('should reject workflow with invalid edges', () => {
      const workflow: Workflow = {
        id: 'workflow-1',
        name: 'Test Workflow',
        version: '1.0.0',
        nodes: [
          { id: '1', type: 'http', label: 'Start', position: { x: 0, y: 0 } },
        ],
        edges: [
          { id: 'e1', source: '1', target: 'nonexistent' },
        ],
      };

      const result = validateWorkflow(workflow);
      expect(result.valid).toBe(false);
      expect(result.errors.some(e => e.includes('does not exist'))).toBe(true);
    });
  });
});
