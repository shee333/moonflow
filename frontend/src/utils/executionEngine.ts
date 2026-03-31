import { Node, Edge } from '@xyflow/react';
import { LLMConfig, LLMRequest, callLLM } from './llmService';

export interface NodeExecutionResult {
  nodeId: string;
  success: boolean;
  output?: any;
  error?: string;
  startTime: number;
  endTime: number;
  duration: number;
}

export interface WorkflowExecutionResult {
  nodeResults: Map<string, NodeExecutionResult>;
  totalDuration: number;
  success: boolean;
}

export type NodeData = {
  label?: string;
  type?: string;
  [key: string]: any;
};

export async function executeNode(
  node: Node<NodeData>,
  context: Map<string, any>
): Promise<NodeExecutionResult> {
  const startTime = Date.now();
  const nodeId = node.id;
  const nodeType = node.data?.type as string;

  try {
    let output: any;

    switch (nodeType) {
      case 'llm': {
        const provider = node.data?.provider as LLMConfig['provider'];
        const model = node.data?.model as string;
        const apiKey = node.data?.api_key as string;
        const systemPrompt = node.data?.system_prompt as string;
        const userPrompt = node.data?.user_prompt as string;
        const temperature = parseFloat(node.data?.temperature as string) || 0.7;
        const maxTokens = parseInt(node.data?.max_tokens as string) || 1000;

        if (!apiKey) {
          throw new Error('LLM API key not configured');
        }

        const resolvedPrompt = resolvePromptVariables(userPrompt, context);

        const llmConfig: LLMConfig = {
          provider: provider || 'openai',
          model: model || 'gpt-3.5-turbo',
          apiKey,
          temperature,
          maxTokens,
          systemPrompt,
        };

        const llmRequest: LLMRequest = {
          prompt: resolvedPrompt,
          systemPrompt,
          temperature,
          maxTokens,
        };

        const llmResponse = await callLLM(llmConfig, llmRequest);
        output = {
          type: 'llm_response',
          content: llmResponse.content,
          model: llmResponse.model,
          usage: llmResponse.usage,
          finishReason: llmResponse.finishReason,
        };
        break;
      }

      case 'trigger':
      case 'http-trigger': {
        output = {
          type: 'trigger',
          message: 'Trigger executed',
          timestamp: new Date().toISOString(),
        };
        break;
      }

      case 'response': {
        const responseBody = node.data?.responseBody || 'Default response';
        output = {
          type: 'response',
          body: resolvePromptVariables(responseBody, context),
          statusCode: 200,
          timestamp: new Date().toISOString(),
        };
        break;
      }

      case 'condition': {
        const condition = node.data?.condition as string;
        const evaluated = evaluateCondition(condition, context);
        output = {
          type: 'condition_result',
          result: evaluated,
          originalCondition: condition,
        };
        break;
      }

      case 'code': {
        const code = node.data?.code as string;
        output = {
          type: 'code_result',
          result: executeCode(code, context),
          timestamp: new Date().toISOString(),
        };
        break;
      }

      case 'template': {
        const template = node.data?.template as string;
        output = {
          type: 'template_result',
          result: resolvePromptVariables(template, context),
          timestamp: new Date().toISOString(),
        };
        break;
      }

      default: {
        output = {
          type: 'unknown',
          message: `Node type "${nodeType}" executed`,
          timestamp: new Date().toISOString(),
        };
      }
    }

    const endTime = Date.now();
    return {
      nodeId,
      success: true,
      output,
      startTime,
      endTime,
      duration: endTime - startTime,
    };
  } catch (error) {
    const endTime = Date.now();
    return {
      nodeId,
      success: false,
      error: error instanceof Error ? error.message : String(error),
      startTime,
      endTime,
      duration: endTime - startTime,
    };
  }
}

function resolvePromptVariables(template: string, context: Map<string, any>): string {
  let result = template;
  const variablePattern = /\{\{(\w+)\}\}/g;
  
  result = result.replace(variablePattern, (match, varName) => {
    const value = context.get(varName);
    if (value !== undefined) {
      return typeof value === 'object' ? JSON.stringify(value) : String(value);
    }
    return match;
  });

  return result;
}

function evaluateCondition(condition: string, context: Map<string, any>): boolean {
  try {
    const resolved = resolvePromptVariables(condition, context);
    
    if (resolved.toLowerCase() === 'true') return true;
    if (resolved.toLowerCase() === 'false') return false;
    
    return Boolean(resolved);
  } catch {
    return false;
  }
}

function executeCode(code: string, context: Map<string, any>): any {
  try {
    const contextObj: Record<string, any> = {};
    context.forEach((value, key) => {
      contextObj[key] = value;
    });
    
    const func = new Function('context', `
      const { ${Array.from(context.keys()).join(', ')} } = context;
      ${code}
    `);
    
    return func(contextObj);
  } catch (error) {
    return { error: error instanceof Error ? error.message : String(error) };
  }
}

export function buildExecutionOrder(nodes: Node<NodeData>[], edges: Edge[]): Node<NodeData>[] {
  const nodeMap = new Map(nodes.map(n => [n.id, n]));
  const inDegree = new Map<string, number>();
  const adjacency = new Map<string, string[]>();
  
  nodes.forEach(n => {
    inDegree.set(n.id, 0);
    adjacency.set(n.id, []);
  });
  
  edges.forEach(e => {
    if (e.source && e.target) {
      inDegree.set(e.target, (inDegree.get(e.target) || 0) + 1);
      adjacency.get(e.source)?.push(e.target);
    }
  });
  
  const queue: string[] = [];
  inDegree.forEach((degree, nodeId) => {
    if (degree === 0) queue.push(nodeId);
  });
  
  const order: Node<NodeData>[] = [];
  while (queue.length > 0) {
    const nodeId = queue.shift()!;
    const node = nodeMap.get(nodeId);
    if (node) order.push(node);
    
    adjacency.get(nodeId)?.forEach(targetId => {
      inDegree.set(targetId, (inDegree.get(targetId) || 0) - 1);
      if (inDegree.get(targetId) === 0) queue.push(targetId);
    });
  }
  
  return order;
}

export async function executeWorkflow(
  nodes: Node<NodeData>[],
  edges: Edge[],
  onNodeStart?: (nodeId: string) => void,
  onNodeComplete?: (result: NodeExecutionResult) => void
): Promise<WorkflowExecutionResult> {
  const executionOrder = buildExecutionOrder(nodes, edges);
  const nodeResults = new Map<string, NodeExecutionResult>();
  const context = new Map<string, any>();
  const startTime = Date.now();

  for (const node of executionOrder) {
    onNodeStart?.(node.id);
    
    const result = await executeNode(node, context);
    nodeResults.set(node.id, result);
    onNodeComplete?.(result);
    
    if (result.success && result.output) {
      context.set(node.id, result.output);
      if (result.output.content !== undefined) {
        context.set('last_output', result.output.content);
      }
    }
    
    if (!result.success && node.data?.type !== 'condition') {
      break;
    }
  }

  const totalDuration = Date.now() - startTime;
  const allSuccessful = Array.from(nodeResults.values()).every(r => r.success);

  return {
    nodeResults,
    totalDuration,
    success: allSuccessful,
  };
}
