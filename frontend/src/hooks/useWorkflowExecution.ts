import { useState, useCallback } from 'react';
import { Node, Edge } from '@xyflow/react';
import { 
  executeWorkflow, 
  executeNode,
  WorkflowExecutionResult, 
  NodeExecutionResult,
  NodeData 
} from '../utils/executionEngine';

export type ExecutionStatus = 'idle' | 'running' | 'completed' | 'failed';

export interface ExecutionLog {
  id: string;
  timestamp: number;
  type: 'info' | 'success' | 'error' | 'warning';
  nodeId?: string;
  message: string;
  data?: unknown;
}

export interface WorkflowExecutionState {
  status: ExecutionStatus;
  logs: ExecutionLog[];
  currentNodeId: string | null;
  results: Map<string, NodeExecutionResult>;
  totalDuration: number;
  startTime: number | null;
  endTime: number | null;
}

export function useWorkflowExecution() {
  const [state, setState] = useState<WorkflowExecutionState>({
    status: 'idle',
    logs: [],
    currentNodeId: null,
    results: new Map(),
    totalDuration: 0,
    startTime: null,
    endTime: null,
  });

  const addLog = useCallback((
    type: ExecutionLog['type'],
    message: string,
    nodeId?: string,
    data?: unknown
  ) => {
    const log: ExecutionLog = {
      id: `log-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      timestamp: Date.now(),
      type,
      nodeId,
      message,
      data,
    };
    setState(prev => ({
      ...prev,
      logs: [...prev.logs, log],
    }));
    return log;
  }, []);

  const clearLogs = useCallback(() => {
    setState(prev => ({
      ...prev,
      logs: [],
    }));
  }, []);

  const reset = useCallback(() => {
    setState({
      status: 'idle',
      logs: [],
      currentNodeId: null,
      results: new Map(),
      totalDuration: 0,
      startTime: null,
      endTime: null,
    });
  }, []);

  const execute = useCallback(async (
    nodes: Node<NodeData>[],
    edges: Edge[],
    options?: {
      onNodeStart?: (nodeId: string) => void;
      onNodeComplete?: (result: NodeExecutionResult) => void;
    }
  ) => {
    const startTime = Date.now();
    
    setState(prev => ({
      ...prev,
      status: 'running',
      startTime,
      currentNodeId: null,
      results: new Map(),
      logs: [{
        id: `log-start-${startTime}`,
        timestamp: startTime,
        type: 'info',
        message: `开始执行工作流 (共 ${nodes.length} 个节点)`,
      }],
    }));

    try {
      addLog('info', '验证工作流配置...');
      
      const validNodes = nodes.filter(n => n.data?.type);
      if (validNodes.length === 0) {
        throw new Error('没有可执行的节点');
      }

      addLog('info', `找到 ${validNodes.length} 个有效节点`);

      const result = await executeWorkflow(
        nodes,
        edges,
        (nodeId) => {
          setState(prev => ({ ...prev, currentNodeId: nodeId }));
          addLog('info', `执行节点: ${nodeId}`, nodeId);
          options?.onNodeStart?.(nodeId);
        },
        (nodeResult) => {
          setState(prev => {
            const newResults = new Map(prev.results);
            newResults.set(nodeResult.nodeId, nodeResult);
            return { ...prev, results: newResults };
          });
          
          if (nodeResult.success) {
            addLog(
              'success', 
              `节点 ${nodeResult.nodeId} 执行成功 (${nodeResult.duration}ms)`,
              nodeResult.nodeId,
              nodeResult.output
            );
          } else {
            addLog(
              'error',
              `节点 ${nodeResult.nodeId} 执行失败: ${nodeResult.error}`,
              nodeResult.nodeId
            );
          }
          options?.onNodeComplete?.(nodeResult);
        }
      );

      const endTime = Date.now();
      
      setState(prev => ({
        ...prev,
        status: result.success ? 'completed' : 'failed',
        currentNodeId: null,
        totalDuration: endTime - startTime,
        endTime,
      }));

      if (result.success) {
        addLog('success', `工作流执行成功! 总耗时: ${endTime - startTime}ms`);
      } else {
        addLog('error', '工作流执行失败');
      }

      return result;
    } catch (error) {
      const endTime = Date.now();
      const errorMessage = error instanceof Error ? error.message : String(error);
      
      setState(prev => ({
        ...prev,
        status: 'failed',
        currentNodeId: null,
        totalDuration: endTime - startTime,
        endTime,
      }));

      addLog('error', `执行错误: ${errorMessage}`);
      
      return {
        nodeResults: new Map(),
        totalDuration: endTime - startTime,
        success: false,
      } as WorkflowExecutionResult;
    }
  }, [addLog]);

  const executeSingleNode = useCallback(async (
    node: Node<NodeData>,
    context: Map<string, unknown>
  ): Promise<NodeExecutionResult> => {
    const result = await executeNode(node, context);
    
    if (result.success) {
      addLog('success', `节点 ${node.id} 执行成功`, node.id, result.output);
    } else {
      addLog('error', `节点 ${node.id} 执行失败: ${result.error}`, node.id);
    }
    
    return result;
  }, [addLog]);

  const abort = useCallback(() => {
    setState(prev => ({
      ...prev,
      status: 'idle',
      currentNodeId: null,
      logs: [
        ...prev.logs,
        {
          id: `log-abort-${Date.now()}`,
          timestamp: Date.now(),
          type: 'warning',
          message: '执行已中止',
        },
      ],
    }));
  }, []);

  return {
    ...state,
    execute,
    executeSingleNode,
    abort,
    reset,
    clearLogs,
    addLog,
  };
}
