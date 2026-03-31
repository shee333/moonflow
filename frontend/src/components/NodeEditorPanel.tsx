import React, { useState, useEffect } from 'react';
import { ConfigValidatorDisplay } from './ConfigValidatorDisplay';
import './NodeEditorPanel.css';

export interface NodeConfig {
  label: string;
  description: string;
  [key: string]: any;
}

interface NodeEditorPanelProps {
  node: {
    id: string;
    data: {
      label: string;
      component: string;
      description?: string;
      config?: NodeConfig;
    };
  } | null;
  onUpdate: (nodeId: string, data: any) => void;
  onClose: () => void;
}

const COMPONENT_SCHEMAS: Record<string, Array<{key: string; label: string; type: string; placeholder?: string; options?: string[]}>> = {
  http: [
    { key: 'url', label: 'URL 地址', type: 'text', placeholder: 'https://api.example.com/endpoint' },
    { key: 'method', label: '请求方法', type: 'select', options: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD', 'OPTIONS'] },
    { key: 'timeout', label: '超时时间 (ms)', type: 'number', placeholder: '30000' },
    { key: 'headers', label: '请求头 (JSON)', type: 'textarea', placeholder: '{"Authorization": "Bearer token"}' },
  ],
  llm: [
    { key: 'provider', label: 'LLM 提供商', type: 'select', options: ['openai', 'claude', 'gemini'] },
    { key: 'model', label: '模型', type: 'text', placeholder: 'gpt-4, claude-3-opus, gemini-pro' },
    { key: 'api_key', label: 'API Key', type: 'text', placeholder: 'sk-...' },
    { key: 'system_prompt', label: '系统提示词', type: 'textarea', placeholder: '你是一个有用的助手...' },
    { key: 'user_prompt', label: '用户提示词', type: 'textarea', placeholder: '{{input}} 或自定义文本' },
    { key: 'temperature', label: 'Temperature', type: 'number', placeholder: '0.7' },
    { key: 'max_tokens', label: 'Max Tokens', type: 'number', placeholder: '1000' },
  ],
  database: [
    { key: 'type', label: 'Database Type', type: 'select', options: ['postgresql', 'mysql', 'sqlite', 'mongodb'] },
    { key: 'query', label: 'SQL Query', type: 'textarea', placeholder: 'SELECT * FROM users WHERE id = $1' },
    { key: 'connection_string', label: 'Connection String', type: 'text', placeholder: 'postgresql://user:pass@localhost:5432/db' },
  ],
  cache: [
    { key: 'operation', label: 'Operation', type: 'select', options: ['get', 'set', 'delete', 'exists'] },
    { key: 'key', label: 'Cache Key', type: 'text', placeholder: 'user:123:profile' },
    { key: 'provider', label: 'Provider', type: 'select', options: ['redis', 'memcached', 'memory'] },
    { key: 'ttl', label: 'TTL (seconds)', type: 'number', placeholder: '3600' },
    { key: 'value', label: 'Value (for SET)', type: 'textarea', placeholder: 'Cache value' },
  ],
  websocket: [
    { key: 'url', label: 'WebSocket URL', type: 'text', placeholder: 'wss://ws.example.com' },
    { key: 'protocol', label: 'Protocol', type: 'text', placeholder: 'graphql-ws' },
    { key: 'auto_reconnect', label: 'Auto Reconnect', type: 'checkbox' },
    { key: 'reconnect_interval', label: 'Reconnect Interval (ms)', type: 'number', placeholder: '3000' },
  ],
  grpc: [
    { key: 'service', label: 'Service Name', type: 'text', placeholder: 'UserService' },
    { key: 'method', label: 'Method', type: 'text', placeholder: 'GetUser' },
    { key: 'endpoint', label: 'Endpoint', type: 'text', placeholder: 'localhost:50051' },
    { key: 'proto_file', label: 'Proto File Path', type: 'text', placeholder: './protos/user.proto' },
  ],
  graphql: [
    { key: 'endpoint', label: 'GraphQL Endpoint', type: 'text', placeholder: 'https://api.example.com/graphql' },
    { key: 'query', label: 'Query', type: 'textarea', placeholder: 'query { users { id name } }' },
    { key: 'variables', label: 'Variables (JSON)', type: 'textarea', placeholder: '{"id": 1}' },
    { key: 'headers', label: 'Headers (JSON)', type: 'textarea', placeholder: '{"Authorization": "Bearer token"}' },
  ],
  response: [
    { key: 'status_code', label: 'Status Code', type: 'number', placeholder: '200' },
    { key: 'body', label: 'Response Body Template', type: 'textarea', placeholder: '{"message": "Success", "data": {{data}}}' },
    { key: 'delay', label: 'Delay (ms)', type: 'number', placeholder: '0' },
    { key: 'headers', label: 'Headers (JSON)', type: 'textarea', placeholder: '{"Content-Type": "application/json"}' },
  ],
  transformer: [
    { key: 'transform_type', label: 'Transform Type', type: 'select', options: ['map', 'filter', 'reduce', 'flatten', 'custom'] },
    { key: 'mappings', label: 'Mappings (JSON)', type: 'textarea', placeholder: '{"field1": "output1", "field2": "output2"}' },
    { key: 'expression', label: 'Custom Expression', type: 'textarea', placeholder: 'item.field * 2' },
  ],
};

export function NodeEditorPanel({ node, onUpdate, onClose }: NodeEditorPanelProps) {
  const [config, setConfig] = useState<NodeConfig>({
    label: '',
    description: '',
  });

  useEffect(() => {
    if (node) {
      setConfig({
        label: node.data.label || '',
        description: node.data.description || '',
        ...node.data.config,
      });
    }
  }, [node]);

  if (!node) {
    return (
      <div className="node-editor-panel empty">
        <div className="empty-message">
          <span className="icon">👆</span>
          <p>选择一个节点以编辑其配置</p>
        </div>
      </div>
    );
  }

  const schema = COMPONENT_SCHEMAS[node.data.component] || [];
  const componentConfig = Object.fromEntries(
    Object.entries(config).filter(([key]) => key !== 'label' && key !== 'description')
  );

  const handleChange = (key: string, value: any) => {
    setConfig((prev) => ({ ...prev, [key]: value }));
  };

  const handleSave = () => {
    const { label, description, ...rest } = config;
    onUpdate(node.id, {
      ...node.data,
      label,
      description,
      config: rest,
    });
  };

  const renderField = (field: {key: string; label: string; type: string; placeholder?: string; options?: string[]}) => {
    const value = config[field.key] || '';
    
    switch (field.type) {
      case 'text':
        return (
          <div key={field.key} className="field-group">
            <label>{field.label}</label>
            <input
              type="text"
              value={value}
              onChange={(e) => handleChange(field.key, e.target.value)}
              placeholder={field.placeholder}
              className="field-input"
            />
          </div>
        );
      case 'number':
        return (
          <div key={field.key} className="field-group">
            <label>{field.label}</label>
            <input
              type="number"
              value={value}
              onChange={(e) => handleChange(field.key, e.target.value)}
              placeholder={field.placeholder}
              className="field-input"
            />
          </div>
        );
      case 'textarea':
        return (
          <div key={field.key} className="field-group">
            <label>{field.label}</label>
            <textarea
              value={value}
              onChange={(e) => handleChange(field.key, e.target.value)}
              placeholder={field.placeholder}
              className="field-textarea"
              rows={4}
            />
          </div>
        );
      case 'select':
        return (
          <div key={field.key} className="field-group">
            <label>{field.label}</label>
            <select
              value={value}
              onChange={(e) => handleChange(field.key, e.target.value)}
              className="field-select"
            >
              <option value="">Select...</option>
              {field.options?.map((option) => (
                <option key={option} value={option}>
                  {option}
                </option>
              ))}
            </select>
          </div>
        );
      case 'checkbox':
        return (
          <div key={field.key} className="field-group checkbox">
            <label>
              <input
                type="checkbox"
                checked={value}
                onChange={(e) => handleChange(field.key, e.target.checked)}
              />
              {field.label}
            </label>
          </div>
        );
      default:
        return null;
    }
  };

  return (
    <div className="node-editor-panel">
      <div className="panel-header">
        <h3>节点配置</h3>
        <button className="close-btn" onClick={onClose}>×</button>
      </div>

      <div className="panel-content">
        <div className="basic-info">
          <div className="field-group">
            <label>节点标签</label>
            <input
              type="text"
              value={config.label}
              onChange={(e) => handleChange('label', e.target.value)}
              className="field-input"
              placeholder="输入节点名称"
            />
          </div>

          <div className="field-group">
            <label>描述</label>
            <textarea
              value={config.description}
              onChange={(e) => handleChange('description', e.target.value)}
              className="field-textarea"
              rows={2}
              placeholder="描述此节点的功能"
            />
          </div>
        </div>

        {schema.length > 0 && (
          <div className="component-config">
            <h4>组件配置</h4>
            {schema.map(renderField)}
          </div>
        )}

        <ConfigValidatorDisplay
          nodeType={node.data.component}
          config={componentConfig}
          label={config.label}
        />
      </div>

      <div className="panel-footer">
        <button className="cancel-btn" onClick={onClose}>
          取消
        </button>
        <button className="save-btn" onClick={handleSave}>
          保存更改
        </button>
      </div>
    </div>
  );
}
