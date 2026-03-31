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

    it('should validate complex multi-branch workflow', () => {
      const workflow: Workflow = {
        id: 'workflow-complex',
        name: 'Complex Multi-Branch Workflow',
        version: '1.0.0',
        nodes: [
          { id: 'trigger', type: 'http', label: 'HTTP Trigger', position: { x: 250, y: 0 } },
          { id: 'llm1', type: 'llm', label: 'LLM Processor 1', position: { x: 100, y: 150 } },
          { id: 'llm2', type: 'llm', label: 'LLM Processor 2', position: { x: 400, y: 150 } },
          { id: 'aggregator', type: 'transformer', label: 'Aggregator', position: { x: 250, y: 300 } },
          { id: 'response', type: 'response', label: 'Response', position: { x: 250, y: 450 } },
        ],
        edges: [
          { id: 'e1', source: 'trigger', target: 'llm1' },
          { id: 'e2', source: 'trigger', target: 'llm2' },
          { id: 'e3', source: 'llm1', target: 'aggregator' },
          { id: 'e4', source: 'llm2', target: 'aggregator' },
          { id: 'e5', source: 'aggregator', target: 'response' },
        ],
      };

      const result = validateWorkflow(workflow);
      expect(result.valid).toBe(true);
      expect(result.errors).toHaveLength(0);
    });

    it('should reject workflow with self-loop', () => {
      const workflow: Workflow = {
        id: 'workflow-self-loop',
        name: 'Self Loop Workflow',
        version: '1.0.0',
        nodes: [
          { id: '1', type: 'llm', label: 'LLM Node', position: { x: 0, y: 0 } },
        ],
        edges: [
          { id: 'e1', source: '1', target: '1' },
        ],
      };

      const result = validateWorkflow(workflow);
      expect(result.valid).toBe(false);
      expect(result.errors.some(e => e.includes('cycle'))).toBe(true);
    });
  });

  describe('generateMoonBitCode', () => {
    it('should generate valid MoonBit code structure', async () => {
      const { generateMoonBitCode } = await import('../utils/codeGenerator');
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

      const code = generateMoonBitCode(workflow);
      expect(code).toContain('package moonflow_generated');
      expect(code).toContain('pub fn main');
      expect(code).toContain('fn init_http_node');
      expect(code).toContain('fn init_llm_node');
      expect(code).toContain('fn execute_node');
    });
  });

  describe('generateWorkflowDocumentation', () => {
    it('should generate documentation with all sections', async () => {
      const { generateWorkflowDocumentation } = await import('../utils/codeGenerator');
      const workflow: Workflow = {
        id: 'workflow-1',
        name: 'Test Workflow',
        description: 'A test workflow for documentation',
        version: '1.0.0',
        nodes: [
          { id: '1', type: 'http', label: 'Start', position: { x: 0, y: 0 } },
        ],
        edges: [],
      };

      const doc = generateWorkflowDocumentation(workflow);
      expect(doc).toContain('# Test Workflow');
      expect(doc).toContain('## Description');
      expect(doc).toContain('## Workflow Information');
      expect(doc).toContain('## Nodes');
      expect(doc).toContain('## Connections');
      expect(doc).toContain('## Execution Order');
    });
  });
});
