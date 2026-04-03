import { Node, Edge } from '@xyflow/react';
import { LLMConfig, LLMRequest, callLLM } from './llmService';
import { HttpConfig, callHttp } from '../services/httpService';

export interface NodeExecutionResult {
  nodeId: string;
  success: boolean;
  output?: unknown;
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
  [key: string]: unknown;
};

export async function executeNode(
  node: Node<NodeData>,
  context: Map<string, unknown>
): Promise<NodeExecutionResult> {
  const startTime = Date.now();
  const nodeId = node.id;
  const nodeType = node.data?.type as string;

  try {
    let output: unknown;

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

      case 'http': {
        const url = node.data?.url as string;
        const method = (node.data?.method as string || 'GET').toUpperCase() as HttpConfig['method'];
        const headers = node.data?.headers as Record<string, string>;
        const body = node.data?.body as string;
        const timeout = parseInt(node.data?.timeout as string) || 30000;
        const retryEnabled = node.data?.retry_enabled === true;
        const maxAttempts = parseInt(node.data?.max_attempts as string) || 3;
        const retryDelay = parseInt(node.data?.retry_delay as string) || 1000;

        if (!url) {
          throw new Error('HTTP URL is required');
        }

        const resolvedBody = resolvePromptVariables(body || '', context);
        let parsedBody: string | Record<string, unknown> | undefined;
        if (resolvedBody) {
          try {
            parsedBody = JSON.parse(resolvedBody);
          } catch {
            parsedBody = resolvedBody;
          }
        }

        const httpConfig: HttpConfig = {
          url: resolvePromptVariables(url, context),
          method,
          headers,
          body: parsedBody,
          timeout,
          retry: retryEnabled ? { enabled: true, maxAttempts, delayMs: retryDelay } : undefined,
        };

        const httpResponse = await callHttp(httpConfig);
        output = {
          type: 'http_response',
          status: httpResponse.status,
          statusText: httpResponse.statusText,
          headers: httpResponse.headers,
          body: httpResponse.body,
          responseTime: httpResponse.responseTime,
          size: httpResponse.size,
        };
        break;
      }

      case 'json': {
        const operation = node.data?.operation as string;
        const input = node.data?.input as string;
        const resolvedInput = resolvePromptVariables(input || '{}', context);

        let jsonData: unknown;
        try {
          jsonData = JSON.parse(resolvedInput);
        } catch {
          throw new Error('Invalid JSON input');
        }

        let result: unknown;
        switch (operation) {
          case 'parse':
            result = jsonData;
            break;
          case 'stringify':
            result = JSON.stringify(jsonData, null, 2);
            break;
          case 'get': {
            const path = node.data?.path as string;
            result = getJsonPath(jsonData, path);
            break;
          }
          case 'set': {
            const setPath = node.data?.path as string;
            const value = node.data?.value as string;
            result = setJsonPath(jsonData, setPath, JSON.parse(value));
            break;
          }
          default:
            result = jsonData;
        }

        output = {
          type: 'json_result',
          operation,
          result,
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

function resolvePromptVariables(template: string, context: Map<string, unknown>): string {
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

function evaluateCondition(condition: string, context: Map<string, unknown>): boolean {
  try {
    const resolved = resolvePromptVariables(condition, context);
    
    if (resolved.toLowerCase() === 'true') return true;
    if (resolved.toLowerCase() === 'false') return false;
    
    return Boolean(resolved);
  } catch {
    return false;
  }
}

function executeCode(code: string, context: Map<string, unknown>): unknown {
  try {
    const contextObj: Record<string, unknown> = {};
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

function getJsonPath(obj: unknown, path: string): unknown {
  if (!path) return obj;

  const parts = path.split('.').filter(Boolean);
  let current: unknown = obj;

  for (const part of parts) {
    if (current === null || current === undefined) {
      return undefined;
    }

    if (typeof current === 'object') {
      const key = part.replace(/['"]/g, '');
      current = (current as Record<string, unknown>)[key];
    } else {
      return undefined;
    }
  }

  return current;
}

function setJsonPath(obj: unknown, path: string, value: unknown): unknown {
  if (!path) return value;

  const parts = path.split('.').filter(Boolean);
  const result = Array.isArray(obj) ? [...obj] : { ...(obj as Record<string, unknown>) };
  let current: Record<string, unknown> = result;

  for (let i = 0; i < parts.length - 1; i++) {
    const part = parts[i].replace(/['"]/g, '');
    if (!(part in current) || typeof current[part] !== 'object') {
      current[part] = {};
    }
    current = current[part] as Record<string, unknown>;
  }

  const lastPart = parts[parts.length - 1].replace(/['"]/g, '');
  current[lastPart] = value;

  return result;
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
  const context = new Map<string, unknown>();
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
