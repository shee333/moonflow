import { Handle, Position, NodeProps } from '@xyflow/react';

export interface MoonFlowNodeData {
  label: string;
  component: string;
  description: string;
}

const getComponentIcon = (component: string): string => {
  const icons: Record<string, string> = {
    http: '🌐',
    llm: '🤖',
    timer: '⏱️',
    database: '🗄️',
    email: '📧',
    file: '📁',
    logger: '📝',
    queue: '📬',
    response: '📤',
    default: '⚙️',
  };
  return icons[component] || icons.default;
};

const getComponentColor = (component: string): string => {
  const colors: Record<string, string> = {
    http: '#3498db',
    llm: '#9b59b6',
    timer: '#e67e22',
    database: '#27ae60',
    email: '#e74c3c',
    file: '#1abc9c',
    logger: '#95a5a6',
    queue: '#34495e',
    response: '#2ecc71',
    default: '#7f8c8d',
  };
  return colors[component] || colors.default;
};

export function MoonFlowNode({ data, selected }: NodeProps) {
  const nodeData = data as MoonFlowNodeData;
  const color = getComponentColor(nodeData.component);
  const icon = getComponentIcon(nodeData.component);

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
          color: '#666',
          padding: '2px 6px',
          backgroundColor: `${color}20`,
          borderRadius: '4px',
          display: 'inline-block',
          marginTop: '4px',
        }}
      >
        {nodeData.component.toUpperCase()}
      </div>
      <Handle type="source" position={Position.Bottom} />
    </div>
  );
}
