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
];

export function ComponentPalette({ onAdd }: ComponentPaletteProps) {
  const categories = [...new Set(components.map((c) => c.category))];

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
      <h3 style={{ marginTop: 0, marginBottom: '12px' }}>Components</h3>
      {categories.map((category) => (
        <div key={category} style={{ marginBottom: '16px' }}>
          <h4
            style={{
              fontSize: '12px',
              textTransform: 'uppercase',
              color: '#666',
              marginBottom: '8px',
              fontWeight: 600,
            }}
          >
            {category}
          </h4>
          {components
            .filter((c) => c.category === category)
            .map((component) => (
              <button
                key={component.type}
                onClick={() => onAdd(component.type, component.label, component.description)}
                style={{
                  display: 'block',
                  width: '100%',
                  padding: '8px 12px',
                  marginBottom: '6px',
                  backgroundColor: '#f8f9fa',
                  border: '1px solid #ddd',
                  borderRadius: '6px',
                  cursor: 'pointer',
                  textAlign: 'left',
                  transition: 'all 0.2s',
                }}
                onMouseEnter={(e) => {
                  e.currentTarget.style.backgroundColor = '#e9ecef';
                  e.currentTarget.style.borderColor = '#007bff';
                }}
                onMouseLeave={(e) => {
                  e.currentTarget.style.backgroundColor = '#f8f9fa';
                  e.currentTarget.style.borderColor = '#ddd';
                }}
              >
                <div style={{ fontWeight: 600, fontSize: '13px' }}>{component.label}</div>
                <div style={{ fontSize: '11px', color: '#666', marginTop: '2px' }}>
                  {component.description}
                </div>
              </button>
            ))}
        </div>
      ))}
    </div>
  );
}
