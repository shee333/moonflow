import { Node } from '@xyflow/react';
import { useState } from 'react';

interface NodeConfigPanelProps {
  node: Node | null;
  onClose: () => void;
  onUpdate: (nodeId: string, updates: Record<string, any>) => void;
}

interface ConfigField {
  key: string;
  label: string;
  type: 'text' | 'number' | 'boolean' | 'select';
  defaultValue?: any;
  options?: { label: string; value: string }[];
  description?: string;
}

const componentConfigs: Record<string, ConfigField[]> = {
  http: [
    { key: 'method', label: 'HTTP Method', type: 'select', defaultValue: 'GET', options: [
      { label: 'GET', value: 'GET' },
      { label: 'POST', value: 'POST' },
      { label: 'PUT', value: 'PUT' },
      { label: 'DELETE', value: 'DELETE' },
    ]},
    { key: 'url', label: 'URL', type: 'text', defaultValue: 'https://api.example.com' },
    { key: 'timeout', label: 'Timeout (ms)', type: 'number', defaultValue: 30000 },
    { key: 'headers', label: 'Headers (JSON)', type: 'text', defaultValue: '{}' },
  ],
  llm: [
    { key: 'model', label: 'Model', type: 'select', defaultValue: 'gpt-4', options: [
      { label: 'GPT-4', value: 'gpt-4' },
      { label: 'GPT-3.5 Turbo', value: 'gpt-3.5-turbo' },
      { label: 'Claude 3', value: 'claude-3' },
    ]},
    { key: 'prompt', label: 'System Prompt', type: 'text', defaultValue: 'You are a helpful assistant.' },
    { key: 'temperature', label: 'Temperature', type: 'number', defaultValue: 0.7 },
    { key: 'maxTokens', label: 'Max Tokens', type: 'number', defaultValue: 1000 },
  ],
  timer: [
    { key: 'interval', label: 'Interval (ms)', type: 'number', defaultValue: 60000 },
    { key: 'cron', label: 'Cron Expression', type: 'text', defaultValue: '* * * * *' },
    { key: 'enabled', label: 'Enabled', type: 'boolean', defaultValue: true },
  ],
  database: [
    { key: 'host', label: 'Host', type: 'text', defaultValue: 'localhost' },
    { key: 'port', label: 'Port', type: 'number', defaultValue: 5432 },
    { key: 'database', label: 'Database Name', type: 'text', defaultValue: 'mydb' },
    { key: 'query', label: 'SQL Query', type: 'text', defaultValue: 'SELECT * FROM users' },
  ],
  email: [
    { key: 'to', label: 'To', type: 'text', defaultValue: 'user@example.com' },
    { key: 'from', label: 'From', type: 'text', defaultValue: 'noreply@example.com' },
    { key: 'subject', label: 'Subject', type: 'text', defaultValue: 'Notification' },
    { key: 'body', label: 'Body Template', type: 'text', defaultValue: 'Hello, this is a notification.' },
  ],
  file: [
    { key: 'path', label: 'File Path', type: 'text', defaultValue: './data.json' },
    { key: 'operation', label: 'Operation', type: 'select', defaultValue: 'read', options: [
      { label: 'Read', value: 'read' },
      { label: 'Write', value: 'write' },
      { label: 'Append', value: 'append' },
    ]},
    { key: 'encoding', label: 'Encoding', type: 'text', defaultValue: 'utf-8' },
  ],
  logger: [
    { key: 'level', label: 'Log Level', type: 'select', defaultValue: 'info', options: [
      { label: 'Debug', value: 'debug' },
      { label: 'Info', value: 'info' },
      { label: 'Warning', value: 'warning' },
      { label: 'Error', value: 'error' },
    ]},
    { key: 'message', label: 'Message Template', type: 'text', defaultValue: 'Workflow log entry' },
  ],
  queue: [
    { key: 'queueName', label: 'Queue Name', type: 'text', defaultValue: 'default' },
    { key: 'operation', label: 'Operation', type: 'select', defaultValue: 'send', options: [
      { label: 'Send', value: 'send' },
      { label: 'Receive', value: 'receive' },
    ]},
    { key: 'durable', label: 'Durable', type: 'boolean', defaultValue: true },
  ],
  filter: [
    { key: 'condition', label: 'Filter Condition', type: 'text', defaultValue: 'data.value > 0' },
    { key: 'passIfTrue', label: 'Pass If True', type: 'boolean', defaultValue: true },
  ],
  transform: [
    { key: 'inputFormat', label: 'Input Format', type: 'text', defaultValue: 'json' },
    { key: 'outputFormat', label: 'Output Format', type: 'text', defaultValue: 'json' },
    { key: 'mapping', label: 'Field Mapping (JSON)', type: 'text', defaultValue: '{}' },
  ],
  aggregator: [
    { key: 'strategy', label: 'Aggregation Strategy', type: 'select', defaultValue: 'collect', options: [
      { label: 'Collect All', value: 'collect' },
      { label: 'First', value: 'first' },
      { label: 'Last', value: 'last' },
      { label: 'Merge', value: 'merge' },
    ]},
    { key: 'timeout', label: 'Timeout (ms)', type: 'number', defaultValue: 5000 },
  ],
  router: [
    { key: 'routes', label: 'Routes (JSON)', type: 'text', defaultValue: '[]' },
    { key: 'defaultRoute', label: 'Default Route', type: 'text', defaultValue: 'error' },
  ],
  response: [
    { key: 'statusCode', label: 'Status Code', type: 'number', defaultValue: 200 },
    { key: 'contentType', label: 'Content Type', type: 'text', defaultValue: 'application/json' },
    { key: 'body', label: 'Response Body', type: 'text', defaultValue: '{}' },
  ],
};

export function NodeConfigPanel({ node, onClose, onUpdate }: NodeConfigPanelProps) {
  const [config, setConfig] = useState<Record<string, any>>(() => {
    if (!node) return {};
    return node.data?.config || {};
  });

  if (!node) return null;

  const componentType = node.data?.component || 'http';
  const fields = componentConfigs[componentType] || [];

  const handleChange = (key: string, value: any) => {
    const newConfig = { ...config, [key]: value };
    setConfig(newConfig);
    onUpdate(node.id, { config: newConfig });
  };

  return (
    <div
      style={{
        position: 'fixed',
        top: 0,
        right: 0,
        width: '400px',
        height: '100vh',
        backgroundColor: '#252526',
        borderLeft: '1px solid #3c3c3c',
        boxShadow: '-4px 0 12px rgba(0,0,0,0.3)',
        zIndex: 1000,
        display: 'flex',
        flexDirection: 'column',
      }}
    >
      <div
        style={{
          padding: '20px',
          borderBottom: '1px solid #3c3c3c',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
        }}
      >
        <h2 style={{ margin: 0, fontSize: '18px', color: '#d4d4d4' }}>
          Configure: {node.data?.label || 'Node'}
        </h2>
        <button
          onClick={onClose}
          style={{
            background: 'transparent',
            border: 'none',
            color: '#d4d4d4',
            fontSize: '24px',
            cursor: 'pointer',
            padding: '4px 8px',
          }}
        >
          ×
        </button>
      </div>

      <div style={{ padding: '20px', overflowY: 'auto', flex: 1 }}>
        <div style={{ marginBottom: '20px' }}>
          <label style={{ display: 'block', marginBottom: '4px', color: '#d4d4d4', fontSize: '12px' }}>
            Node ID
          </label>
          <input
            type="text"
            value={node.id}
            disabled
            style={{
              width: '100%',
              padding: '8px',
              backgroundColor: '#1e1e1e',
              border: '1px solid #3c3c3c',
              borderRadius: '4px',
              color: '#858585',
              fontSize: '13px',
            }}
          />
        </div>

        <div style={{ marginBottom: '20px' }}>
          <label style={{ display: 'block', marginBottom: '4px', color: '#d4d4d4', fontSize: '12px' }}>
            Component Type
          </label>
          <input
            type="text"
            value={componentType}
            disabled
            style={{
              width: '100%',
              padding: '8px',
              backgroundColor: '#1e1e1e',
              border: '1px solid #3c3c3c',
              borderRadius: '4px',
              color: '#858585',
              fontSize: '13px',
              textTransform: 'uppercase',
            }}
          />
        </div>

        <h3 style={{ marginTop: '24px', marginBottom: '16px', fontSize: '14px', color: '#d4d4d4' }}>
          Component Configuration
        </h3>

        {fields.length === 0 ? (
          <p style={{ color: '#858585', fontSize: '13px' }}>No configuration available for this component.</p>
        ) : (
          fields.map((field) => (
            <div key={field.key} style={{ marginBottom: '16px' }}>
              <label style={{ display: 'block', marginBottom: '4px', color: '#d4d4d4', fontSize: '12px' }}>
                {field.label}
                {field.description && (
                  <span style={{ color: '#858585', marginLeft: '4px' }}>({field.description})</span>
                )}
              </label>
              
              {field.type === 'select' ? (
                <select
                  value={config[field.key] ?? field.defaultValue}
                  onChange={(e) => handleChange(field.key, e.target.value)}
                  style={{
                    width: '100%',
                    padding: '8px',
                    backgroundColor: '#1e1e1e',
                    border: '1px solid #3c3c3c',
                    borderRadius: '4px',
                    color: '#d4d4d4',
                    fontSize: '13px',
                  }}
                >
                  {field.options?.map((opt) => (
                    <option key={opt.value} value={opt.value}>
                      {opt.label}
                    </option>
                  ))}
                </select>
              ) : field.type === 'boolean' ? (
                <label style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <input
                    type="checkbox"
                    checked={config[field.key] ?? field.defaultValue}
                    onChange={(e) => handleChange(field.key, e.target.checked)}
                  />
                  <span style={{ color: '#d4d4d4', fontSize: '13px' }}>
                    {config[field.key] ?? field.defaultValue ? 'Enabled' : 'Disabled'}
                  </span>
                </label>
              ) : field.type === 'number' ? (
                <input
                  type="number"
                  value={config[field.key] ?? field.defaultValue}
                  onChange={(e) => handleChange(field.key, Number(e.target.value))}
                  style={{
                    width: '100%',
                    padding: '8px',
                    backgroundColor: '#1e1e1e',
                    border: '1px solid #3c3c3c',
                    borderRadius: '4px',
                    color: '#d4d4d4',
                    fontSize: '13px',
                  }}
                />
              ) : (
                <textarea
                  value={config[field.key] ?? field.defaultValue}
                  onChange={(e) => handleChange(field.key, e.target.value)}
                  rows={field.type === 'text' && (config[field.key] ?? field.defaultValue).length > 50 ? 4 : 2}
                  style={{
                    width: '100%',
                    padding: '8px',
                    backgroundColor: '#1e1e1e',
                    border: '1px solid #3c3c3c',
                    borderRadius: '4px',
                    color: '#d4d4d4',
                    fontSize: '13px',
                    fontFamily: 'monospace',
                    resize: 'vertical',
                  }}
                />
              )}
            </div>
          ))
        )}
      </div>

      <div
        style={{
          padding: '16px 20px',
          borderTop: '1px solid #3c3c3c',
          display: 'flex',
          gap: '8px',
        }}
      >
        <button
          onClick={() => {
            const resetConfig: Record<string, any> = {};
            fields.forEach((field) => {
              resetConfig[field.key] = field.defaultValue;
            });
            setConfig(resetConfig);
            onUpdate(node.id, { config: resetConfig });
          }}
          style={{
            flex: 1,
            padding: '10px',
            backgroundColor: '#3c3c3c',
            border: 'none',
            borderRadius: '4px',
            color: '#d4d4d4',
            fontSize: '13px',
            cursor: 'pointer',
          }}
        >
          Reset to Default
        </button>
        <button
          onClick={onClose}
          style={{
            flex: 1,
            padding: '10px',
            backgroundColor: '#007acc',
            border: 'none',
            borderRadius: '4px',
            color: 'white',
            fontSize: '13px',
            cursor: 'pointer',
          }}
        >
          Save & Close
        </button>
      </div>
    </div>
  );
}
