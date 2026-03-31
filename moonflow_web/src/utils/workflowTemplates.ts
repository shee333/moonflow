import { Workflow } from '../components/types';

export interface WorkflowTemplate {
  id: string;
  name: string;
  description: string;
  category: string;
  icon: string;
  workflow: Workflow;
}

export const workflowTemplates: WorkflowTemplate[] = [
  {
    id: 'api-gateway',
    name: 'API 网关',
    description: '接收 HTTP 请求，处理后返回响应',
    category: '入门',
    icon: '🌐',
    workflow: {
      id: 'api-gateway',
      name: 'API Gateway',
      version: '1.0.0',
      nodes: [
        {
          id: '1',
          type: 'http',
          label: 'HTTP Trigger',
          position: { x: 250, y: 5 },
          config: {
            url: 'https://api.example.com/webhook',
            method: 'POST',
          },
        },
        {
          id: '2',
          type: 'transformer',
          label: 'Transform Data',
          position: { x: 250, y: 150 },
          config: {
            transform_type: 'map',
            mappings: '{"status": "success"}',
          },
        },
        {
          id: '3',
          type: 'response',
          label: 'Response',
          position: { x: 250, y: 300 },
          config: {
            status_code: 200,
          },
        },
      ],
      edges: [
        { id: 'e1-2', source: '1', target: '2' },
        { id: 'e2-3', source: '2', target: '3' },
      ],
    },
  },
  {
    id: 'llm-chatbot',
    name: 'AI 聊天机器人',
    description: '基于 LLM 的对话处理工作流',
    category: 'AI',
    icon: '🤖',
    workflow: {
      id: 'llm-chatbot',
      name: 'LLM Chatbot',
      version: '1.0.0',
      nodes: [
        {
          id: '1',
          type: 'http',
          label: 'User Input',
          position: { x: 250, y: 5 },
          config: {
            method: 'POST',
          },
        },
        {
          id: '2',
          type: 'cache',
          label: 'Check Context',
          position: { x: 100, y: 150 },
          config: {
            operation: 'get',
            key: 'conversation:user123',
            provider: 'redis',
          },
        },
        {
          id: '3',
          type: 'llm',
          label: 'LLM Processing',
          position: { x: 250, y: 300 },
          config: {
            model: 'gpt-4',
            prompt: 'You are a helpful assistant.',
            max_tokens: 1000,
          },
        },
        {
          id: '4',
          type: 'cache',
          label: 'Save Context',
          position: { x: 400, y: 150 },
          config: {
            operation: 'set',
            key: 'conversation:user123',
            provider: 'redis',
            ttl: 3600,
          },
        },
        {
          id: '5',
          type: 'response',
          label: 'Response',
          position: { x: 250, y: 450 },
          config: {
            status_code: 200,
          },
        },
      ],
      edges: [
        { id: 'e1-2', source: '1', target: '2' },
        { id: 'e1-4', source: '1', target: '4' },
        { id: 'e2-3', source: '2', target: '3' },
        { id: 'e4-3', source: '4', target: '3' },
        { id: 'e3-5', source: '3', target: '5' },
      ],
    },
  },
  {
    id: 'data-pipeline',
    name: '数据处理管道',
    description: '从数据库读取、处理、转换数据并存储',
    category: '数据',
    icon: '🔄',
    workflow: {
      id: 'data-pipeline',
      name: 'Data Pipeline',
      version: '1.0.0',
      nodes: [
        {
          id: '1',
          type: 'database',
          label: 'Read Data',
          position: { x: 250, y: 5 },
          config: {
            type: 'postgresql',
            query: 'SELECT * FROM users WHERE active = true',
          },
        },
        {
          id: '2',
          type: 'transformer',
          label: 'Transform',
          position: { x: 250, y: 150 },
          config: {
            transform_type: 'map',
            mappings: '{"id": "user_id", "name": "full_name"}',
          },
        },
        {
          id: '3',
          type: 'cache',
          label: 'Cache Result',
          position: { x: 250, y: 300 },
          config: {
            operation: 'set',
            key: 'processed_users',
            provider: 'redis',
            ttl: 1800,
          },
        },
        {
          id: '4',
          type: 'response',
          label: 'Return Data',
          position: { x: 250, y: 450 },
          config: {
            status_code: 200,
          },
        },
      ],
      edges: [
        { id: 'e1-2', source: '1', target: '2' },
        { id: 'e2-3', source: '2', target: '3' },
        { id: 'e3-4', source: '3', target: '4' },
      ],
    },
  },
  {
    id: 'graphql-api',
    name: 'GraphQL API',
    description: 'GraphQL 查询处理和聚合',
    category: 'API',
    icon: '◈',
    workflow: {
      id: 'graphql-api',
      name: 'GraphQL API',
      version: '1.0.0',
      nodes: [
        {
          id: '1',
          type: 'graphql',
          label: 'GraphQL Query',
          position: { x: 250, y: 5 },
          config: {
            endpoint: 'https://api.example.com/graphql',
            query: 'query { users { id name email } }',
          },
        },
        {
          id: '2',
          type: 'transformer',
          label: 'Aggregate',
          position: { x: 250, y: 150 },
          config: {
            transform_type: 'map',
          },
        },
        {
          id: '3',
          type: 'response',
          label: 'Response',
          position: { x: 250, y: 300 },
          config: {
            status_code: 200,
          },
        },
      ],
      edges: [
        { id: 'e1-2', source: '1', target: '2' },
        { id: 'e2-3', source: '2', target: '3' },
      ],
    },
  },
  {
    id: 'grpc-microservice',
    name: 'gRPC 微服务',
    description: 'gRPC 服务调用和处理',
    category: '微服务',
    icon: '⚡',
    workflow: {
      id: 'grpc-microservice',
      name: 'gRPC Microservice',
      version: '1.0.0',
      nodes: [
        {
          id: '1',
          type: 'http',
          label: 'HTTP Trigger',
          position: { x: 250, y: 5 },
          config: {
            method: 'POST',
          },
        },
        {
          id: '2',
          type: 'grpc',
          label: 'Call Service',
          position: { x: 250, y: 150 },
          config: {
            service: 'UserService',
            method: 'GetUser',
            endpoint: 'localhost:50051',
          },
        },
        {
          id: '3',
          type: 'response',
          label: 'Response',
          position: { x: 250, y: 300 },
          config: {
            status_code: 200,
          },
        },
      ],
      edges: [
        { id: 'e1-2', source: '1', target: '2' },
        { id: 'e2-3', source: '2', target: '3' },
      ],
    },
  },
  {
    id: 'realtime-websocket',
    name: '实时 WebSocket',
    description: 'WebSocket 实时通信处理',
    category: '实时',
    icon: '🔌',
    workflow: {
      id: 'realtime-websocket',
      name: 'Real-time WebSocket',
      version: '1.0.0',
      nodes: [
        {
          id: '1',
          type: 'websocket',
          label: 'WebSocket Connect',
          position: { x: 250, y: 5 },
          config: {
            url: 'wss://ws.example.com/live',
            auto_reconnect: true,
            reconnect_interval: 3000,
          },
        },
        {
          id: '2',
          type: 'llm',
          label: 'Process Message',
          position: { x: 250, y: 150 },
          config: {
            model: 'gpt-3.5-turbo',
            prompt: 'Analyze and respond to the message.',
          },
        },
        {
          id: '3',
          type: 'websocket',
          label: 'Send Response',
          position: { x: 250, y: 300 },
          config: {
            url: 'wss://ws.example.com/live',
          },
        },
      ],
      edges: [
        { id: 'e1-2', source: '1', target: '2' },
        { id: 'e2-3', source: '2', target: '3' },
      ],
    },
  },
];

export function getTemplatesByCategory(category: string): WorkflowTemplate[] {
  return workflowTemplates.filter((t) => t.category === category);
}

export function getAllCategories(): string[] {
  const categories = new Set(workflowTemplates.map((t) => t.category));
  return Array.from(categories);
}

export function getTemplateById(id: string): WorkflowTemplate | undefined {
  return workflowTemplates.find((t) => t.id === id);
}
