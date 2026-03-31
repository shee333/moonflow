import { Handle, Position, NodeProps } from '@xyflow/react';

export interface MoonFlowNodeData {
  label: string;
  component: string;
  description: string;
}

const getComponentIcon = (component: string): string => {
  const icons: Record<string, string> = {
    http: '🌐',
    websocket: '🔌',
    grpc: '⚡',
    graphql: '◈',
    llm: '🤖',
    timer: '⏱️',
    database: '🗄️',
    cache: '💾',
    email: '📧',
    file: '📁',
    logger: '📝',
    queue: '📬',
    response: '📤',
    filter: '🔍',
    transform: '🔄',
    aggregator: '⊞',
    router: '🔀',
    default: '⚙️',
  };
  return icons[component] || icons.default;
};

const getComponentColor = (component: string): string => {
  const colors: Record<string, string> = {
    http: '#3498db',
    websocket: '#00d9ff',
    grpc: '#00ff88',
    graphql: '#e535ab',
    llm: '#9b59b6',
    timer: '#e67e22',
    database: '#27ae60',
    cache: '#f39c12',
    email: '#e74c3c',
    file: '#1abc9c',
    logger: '#95a5a6',
    queue: '#34495e',
    response: '#2ecc71',
    filter: '#8e44ad',
    transform: '#d35400',
    aggregator: '#2980b9',
    router: '#c0392b',
    default: '#7f8c8d',
  };
  return colors[component] || colors.default;
};

const getComponentCategory = (component: string): string => {
  const categories: Record<string, string> = {
    http: 'trigger',
    websocket: 'trigger',
    grpc: 'trigger',
    graphql: 'trigger',
    llm: 'processor',
    timer: 'trigger',
    database: 'storage',
    cache: 'storage',
    email: 'notification',
    file: 'storage',
    logger: 'utility',
    queue: 'messaging',
    response: 'output',
    filter: 'processor',
    transform: 'processor',
    aggregator: 'processor',
    router: 'control',
  };
  return categories[component] || 'utility';
};

export function MoonFlowNode({ data, selected }: NodeProps) {
  const nodeData = data as MoonFlowNodeData;
  const color = getComponentColor(nodeData.component);
  const icon = getComponentIcon(nodeData.component);
  const category = getComponentCategory(nodeData.component);

  return (
    <div
      style={{
        padding: '12px 16px',
        borderRadius: '8px',
        border: `2px solid ${selected ? color : '#ddd'}`,
        backgroundColor: 'white',
        boxShadow: selected 
          ? `0 0 20px ${color}40` 
          : '0 2px 8px rgba(0,0,0,0.1)',
        minWidth: '150px',
        transition: 'all 0.2s ease',
        transform: selected ? 'scale(1.02)' : 'scale(1)',
      }}
    >
      <Handle type="target" position={Position.Top} />
      <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '4px' }}>
        <span style={{ fontSize: '24px' }}>{icon}</span>
        <span style={{ fontWeight: 600, fontSize: '14px' }}>{nodeData.label}</span>
      </div>
      <div
        style={{
          fontSize: '10px',
          color: color,
          padding: '2px 6px',
          backgroundColor: `${color}20`,
          borderRadius: '4px',
          display: 'inline-block',
          marginTop: '4px',
          fontWeight: 500,
          textTransform: 'uppercase',
        }}
      >
        {category}
      </div>
      <Handle type="source" position={Position.Bottom} />
    </div>
  );
}
