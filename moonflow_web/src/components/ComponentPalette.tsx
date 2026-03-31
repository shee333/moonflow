import { ComponentType } from './types';

interface ComponentPaletteProps {
  onAdd: (componentType: string, label: string, description: string) => void;
}

const components: ComponentType[] = [
  {
    type: 'http',
    label: 'HTTP 触发器',
    description: '通过 HTTP 请求启动工作流',
    category: 'trigger',
  },
  {
    type: 'websocket',
    label: 'WebSocket',
    description: '实时双向通信',
    category: 'trigger',
  },
  {
    type: 'grpc',
    label: 'gRPC',
    description: '高性能 RPC 通信',
    category: 'trigger',
  },
  {
    type: 'graphql',
    label: 'GraphQL',
    description: 'GraphQL 查询和变更',
    category: 'trigger',
  },
  {
    type: 'llm',
    label: 'LLM 处理器',
    description: '使用 AI 语言模型处理',
    category: 'processor',
  },
  {
    type: 'timer',
    label: '定时器',
    description: '基于时间的触发器',
    category: 'trigger',
  },
  {
    type: 'database',
    label: '数据库',
    description: '连接数据库',
    category: 'storage',
  },
  {
    type: 'cache',
    label: '缓存',
    description: '快速访问的数据缓存',
    category: 'storage',
  },
  {
    type: 'email',
    label: '邮件',
    description: '发送电子邮件',
    category: 'notification',
  },
  {
    type: 'file',
    label: '文件操作',
    description: '读写文件',
    category: 'storage',
  },
  {
    type: 'logger',
    label: '日志记录',
    description: '记录工作流事件',
    category: 'utility',
  },
  {
    type: 'queue',
    label: '消息队列',
    description: '消息队列操作',
    category: 'messaging',
  },
  {
    type: 'filter',
    label: '过滤器',
    description: '根据条件过滤数据',
    category: 'processor',
  },
  {
    type: 'transform',
    label: '数据转换',
    description: '转换数据格式',
    category: 'processor',
  },
  {
    type: 'aggregator',
    label: '聚合器',
    description: '聚合多个输入',
    category: 'processor',
  },
  {
    type: 'router',
    label: '路由器',
    description: '路由到不同路径',
    category: 'control',
  },
  {
    type: 'response',
    label: '响应',
    description: '返回结果给调用方',
    category: 'output',
  },
];

export function ComponentPalette({ onAdd }: ComponentPaletteProps) {
  const categoryNames: Record<string, string> = {
    trigger: '触发器',
    processor: '处理器',
    storage: '存储',
    notification: '通知',
    utility: '工具',
    messaging: '消息',
    control: '控制',
    output: '输出',
  };

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
        组件库
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
            {categoryNames[category] || category}
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
