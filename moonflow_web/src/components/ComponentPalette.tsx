import { ComponentType } from './types';

interface ComponentPaletteProps {
  onAdd: (componentType: string, label: string, description: string) => void;
}

const components: ComponentType[] = [
  {
    type: 'http',
    label: 'HTTP Trigger',
    description: 'Start workflow via HTTP request',
    category: 'trigger',
  },
  {
    type: 'websocket',
    label: 'WebSocket',
    description: 'Real-time bidirectional communication',
    category: 'trigger',
  },
  {
    type: 'grpc',
    label: 'gRPC',
    description: 'High-performance RPC communication',
    category: 'trigger',
  },
  {
    type: 'graphql',
    label: 'GraphQL',
    description: 'Query and mutate data with GraphQL',
    category: 'trigger',
  },
  {
    type: 'llm',
    label: 'LLM Processor',
    description: 'Process with AI language model',
    category: 'processor',
  },
  {
    type: 'timer',
    label: 'Timer',
    description: 'Schedule time-based triggers',
    category: 'trigger',
  },
  {
    type: 'database',
    label: 'Database',
    description: 'Connect to databases',
    category: 'storage',
  },
  {
    type: 'cache',
    label: 'Cache',
    description: 'Cache data for fast access',
    category: 'storage',
  },
  {
    type: 'email',
    label: 'Email',
    description: 'Send emails',
    category: 'notification',
  },
  {
    type: 'file',
    label: 'File Operations',
    description: 'Read/write files',
    category: 'storage',
  },
  {
    type: 'logger',
    label: 'Logger',
    description: 'Log workflow events',
    category: 'utility',
  },
  {
    type: 'queue',
    label: 'Queue',
    description: 'Message queue operations',
    category: 'messaging',
  },
  {
    type: 'filter',
    label: 'Filter',
    description: 'Filter data based on conditions',
    category: 'processor',
  },
  {
    type: 'transform',
    label: 'Transform',
    description: 'Transform data format',
    category: 'processor',
  },
  {
    type: 'aggregator',
    label: 'Aggregator',
    description: 'Aggregate multiple inputs',
    category: 'processor',
  },
  {
    type: 'router',
    label: 'Router',
    description: 'Route to different paths',
    category: 'control',
  },
  {
    type: 'response',
    label: 'Response',
    description: 'Return result to caller',
    category: 'output',
  },
];

export function ComponentPalette({ onAdd }: ComponentPaletteProps) {
  const categories = [...new Set(components.map((c) => c.category))];

  const handleDragStart = (e: React.DragEvent, component: ComponentType) => {
    e.dataTransfer.setData('application/json', JSON.stringify(component));
    e.dataTransfer.effectAllowed = 'move';
  };

  return (
    <div
      style={{
        backgroundColor: 'white',
        padding: '16px',
        borderRadius: '8px',
        boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
        maxHeight: '80vh',
        overflowY: 'auto',
        minWidth: '280px',
      }}
    >
      <h3 style={{ marginTop: 0, marginBottom: '16px', fontSize: '16px', fontWeight: 600 }}>
        Components
      </h3>
      {categories.map((category) => (
        <div key={category} style={{ marginBottom: '16px' }}>
          <h4
            style={{
              fontSize: '12px',
              fontWeight: 600,
              color: '#666',
              textTransform: 'uppercase',
              marginBottom: '8px',
            }}
          >
            {category}
          </h4>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            {components
              .filter((c) => c.category === category)
              .map((component) => (
                <div
                  key={component.type}
                  draggable
                  onDragStart={(e) => handleDragStart(e, component)}
                  onClick={() => onAdd(component.type, component.label, component.description)}
                  style={{
                    padding: '10px 12px',
                    backgroundColor: '#f5f5f5',
                    border: '1px solid #ddd',
                    borderRadius: '6px',
                    cursor: 'pointer',
                    transition: 'all 0.2s',
                  }}
                  onMouseEnter={(e) => {
                    e.currentTarget.style.backgroundColor = '#e8e8e8';
                    e.currentTarget.style.borderColor = '#007acc';
                  }}
                  onMouseLeave={(e) => {
                    e.currentTarget.style.backgroundColor = '#f5f5f5';
                    e.currentTarget.style.borderColor = '#ddd';
                  }}
                >
                  <div style={{ fontSize: '14px', fontWeight: 500, marginBottom: '2px' }}>
                    {component.label}
                  </div>
                  <div style={{ fontSize: '11px', color: '#666' }}>
                    {component.description}
                  </div>
                </div>
              ))}
          </div>
        </div>
      ))}
    </div>
  );
}
