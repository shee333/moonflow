import { ComponentType } from './types';

interface ComponentPaletteProps {
  onAdd: (componentType: string, label: string, description: string) => void;
}

const components: ComponentType[] = [
  // 触发器
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
    type: 'timer',
    label: '定时器',
    description: '基于时间的触发器',
    category: 'trigger',
  },
  {
    type: 'cron',
    label: 'Cron 调度',
    description: '定时任务调度',
    category: 'trigger',
  },
  {
    type: 'webhook',
    label: 'Webhook',
    description: '接收外部 Webhook',
    category: 'trigger',
  },
  // AI / LLM
  {
    type: 'llm',
    label: 'LLM 处理器',
    description: '使用 AI 语言模型处理',
    category: 'ai',
  },
  {
    type: 'agent',
    label: 'AI Agent',
    description: '带记忆的智能体',
    category: 'ai',
  },
  {
    type: 'rag',
    label: 'RAG',
    description: '检索增强生成',
    category: 'ai',
  },
  {
    type: 'embedding',
    label: 'Embedding',
    description: '向量嵌入生成',
    category: 'ai',
  },
  // 网络请求
  {
    type: 'http_request',
    label: 'HTTP 请求',
    description: '发起 HTTP 请求',
    category: 'network',
  },
  {
    type: 'fetch',
    label: 'Fetch',
    description: '获取远程数据',
    category: 'network',
  },
  {
    type: 'graphql',
    label: 'GraphQL',
    description: 'GraphQL 查询',
    category: 'network',
  },
  // 数据处理
  {
    type: 'json',
    label: 'JSON 处理',
    description: 'JSON 解析和转换',
    category: 'data',
  },
  {
    type: 'filter',
    label: '过滤器',
    description: '根据条件过滤数据',
    category: 'data',
  },
  {
    type: 'transform',
    label: '数据转换',
    description: '转换数据格式',
    category: 'data',
  },
  {
    type: 'aggregator',
    label: '聚合器',
    description: '聚合多个输入',
    category: 'data',
  },
  {
    type: 'formatter',
    label: '格式化',
    description: '格式化输出',
    category: 'data',
  },
  {
    type: 'splitter',
    label: '数据拆分',
    description: '拆分数据流',
    category: 'data',
  },
  {
    type: 'merger',
    label: '数据合并',
    description: '合并多个数据源',
    category: 'data',
  },
  // 流控制
  {
    type: 'router',
    label: '路由器',
    description: '条件路由',
    category: 'control',
  },
  {
    type: 'condition',
    label: '条件分支',
    description: 'if/else 分支',
    category: 'control',
  },
  {
    type: 'iterator',
    label: '循环迭代',
    description: '遍历数组',
    category: 'control',
  },
  {
    type: 'parallel',
    label: '并行执行',
    description: '并行处理',
    category: 'control',
  },
  {
    type: 'pipeline',
    label: '管道',
    description: '链式处理',
    category: 'control',
  },
  {
    type: 'retry',
    label: '重试',
    description: '失败重试机制',
    category: 'control',
  },
  {
    type: 'throttle',
    label: '限流',
    description: '控制请求频率',
    category: 'control',
  },
  // 存储
  {
    type: 'database',
    label: '数据库',
    description: '连接数据库',
    category: 'storage',
  },
  {
    type: 'cache',
    label: '缓存',
    description: '快速访问缓存',
    category: 'storage',
  },
  {
    type: 'file',
    label: '文件操作',
    description: '读写文件',
    category: 'storage',
  },
  {
    type: 'queue',
    label: '消息队列',
    description: '队列操作',
    category: 'storage',
  },
  {
    type: 'storage',
    label: '存储',
    description: '通用存储',
    category: 'storage',
  },
  // 通知
  {
    type: 'email',
    label: '邮件',
    description: '发送邮件',
    category: 'notification',
  },
  {
    type: 'feishu',
    label: '飞书',
    description: '飞书消息通知',
    category: 'notification',
  },
  {
    type: 'dingtalk',
    label: '钉钉',
    description: '钉钉消息通知',
    category: 'notification',
  },
  {
    type: 'webhook_notify',
    label: 'Webhook 通知',
    description: '发送 Webhook',
    category: 'notification',
  },
  {
    type: 'notification',
    label: '通知',
    description: '通用通知',
    category: 'notification',
  },
  // 输出
  {
    type: 'response',
    label: 'HTTP 响应',
    description: '返回响应',
    category: 'output',
  },
  {
    type: 'template',
    label: '模板渲染',
    description: '渲染输出模板',
    category: 'output',
  },
  // 工具
  {
    type: 'logger',
    label: '日志',
    description: '记录日志',
    category: 'utility',
  },
  {
    type: 'validator',
    label: '验证器',
    description: '数据验证',
    category: 'utility',
  },
  {
    type: 'pool',
    label: '连接池',
    description: '连接池管理',
    category: 'utility',
  },
  {
    type: 'code',
    label: '代码执行',
    description: '执行代码片段',
    category: 'utility',
  },
];

const categoryConfig: Record<string, { name: string; icon: string; color: string }> = {
  trigger: { name: '触发器', icon: '⚡', color: '#ff6b6b' },
  ai: { name: 'AI / LLM', icon: '🤖', color: '#9b59b6' },
  network: { name: '网络请求', icon: '🌐', color: '#3498db' },
  data: { name: '数据处理', icon: '🔧', color: '#2ecc71' },
  control: { name: '流程控制', icon: '🔀', color: '#f39c12' },
  storage: { name: '存储', icon: '💾', color: '#1abc9c' },
  notification: { name: '通知', icon: '📬', color: '#e74c3c' },
  output: { name: '输出', icon: '📤', color: '#34495e' },
  utility: { name: '工具', icon: '🛠️', color: '#95a5a6' },
};

export function ComponentPalette({ onAdd }: ComponentPaletteProps) {
  const categories = [...new Set(components.map((c) => c.category))];

  const handleDragStart = (e: React.DragEvent, component: ComponentType) => {
    e.dataTransfer.setData('application/json', JSON.stringify(component));
    e.dataTransfer.effectAllowed = 'move';
  };

  return (
    <div className="component-palette">
      <h3 className="palette-title">🧩 组件库</h3>
      <div className="palette-search">
        <input
          type="text"
          placeholder="搜索组件..."
          className="search-input"
        />
      </div>
      <div className="palette-content">
        {categories.map((category) => {
          const config = categoryConfig[category] || {
            name: category,
            icon: '📦',
            color: '#666',
          };
          return (
            <div key={category} className="category-section">
              <h4
                className="category-header"
                style={{ borderLeftColor: config.color }}
              >
                <span className="category-icon">{config.icon}</span>
                <span className="category-name">{config.name}</span>
                <span className="category-count">
                  {components.filter((c) => c.category === category).length}
                </span>
              </h4>
              <div className="category-components">
                {components
                  .filter((c) => c.category === category)
                  .map((component) => (
                    <div
                      key={component.type}
                      draggable
                      onDragStart={(e) => handleDragStart(e, component)}
                      onClick={() =>
                        onAdd(component.type, component.label, component.description)
                      }
                      className="component-item"
                    >
                      <div className="component-icon">
                        {getComponentIcon(component.type)}
                      </div>
                      <div className="component-info">
                        <div className="component-label">{component.label}</div>
                        <div className="component-desc">{component.description}</div>
                      </div>
                    </div>
                  ))}
              </div>
            </div>
          );
        })}
      </div>
      <style>{`
        .component-palette {
          background: white;
          padding: 16px;
          border-radius: 8px;
          box-shadow: 0 4px 12px rgba(0,0,0,0.15);
          height: 100%;
          display: flex;
          flex-direction: column;
        }
        .palette-title {
          margin: 0 0 16px 0;
          font-size: 18px;
          font-weight: 600;
          color: #333;
        }
        .palette-search {
          margin-bottom: 16px;
        }
        .search-input {
          width: 100%;
          padding: 8px 12px;
          border: 1px solid #ddd;
          border-radius: 6px;
          font-size: 14px;
          outline: none;
          transition: border-color 0.2s;
        }
        .search-input:focus {
          border-color: #007acc;
        }
        .palette-content {
          flex: 1;
          overflow-y: auto;
        }
        .category-section {
          margin-bottom: 20px;
        }
        .category-header {
          display: flex;
          align-items: center;
          gap: 8px;
          margin: 0 0 10px 0;
          padding: 8px 12px;
          background: #f5f5f5;
          border-radius: 6px;
          border-left: 4px solid;
          font-size: 13px;
        }
        .category-icon {
          font-size: 16px;
        }
        .category-name {
          flex: 1;
          font-weight: 600;
          color: #333;
        }
        .category-count {
          background: #ddd;
          padding: 2px 8px;
          border-radius: 10px;
          font-size: 11px;
          color: #666;
        }
        .category-components {
          display: flex;
          flex-direction: column;
          gap: 6px;
        }
        .component-item {
          display: flex;
          align-items: flex-start;
          gap: 10px;
          padding: 10px 12px;
          background: #fafafa;
          border: 1px solid #eee;
          border-radius: 6px;
          cursor: pointer;
          transition: all 0.2s;
        }
        .component-item:hover {
          background: #f0f7ff;
          border-color: #007acc;
          transform: translateX(4px);
        }
        .component-icon {
          font-size: 20px;
          width: 32px;
          height: 32px;
          display: flex;
          align-items: center;
          justify-content: center;
          background: white;
          border-radius: 6px;
          box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        .component-info {
          flex: 1;
          min-width: 0;
        }
        .component-label {
          font-size: 13px;
          font-weight: 500;
          color: #333;
          margin-bottom: 2px;
        }
        .component-desc {
          font-size: 11px;
          color: #888;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }
      `}</style>
    </div>
  );
}

function getComponentIcon(type: string): string {
  const icons: Record<string, string> = {
    http: '📡',
    websocket: '🔌',
    timer: '⏰',
    cron: '📅',
    webhook: '🪝',
    llm: '🤖',
    agent: '🧠',
    rag: '📚',
    embedding: '🔢',
    http_request: '🌐',
    fetch: '📥',
    graphql: '◈',
    json: '📄',
    filter: '🔍',
    transform: '🔄',
    aggregator: '📊',
    formatter: '📝',
    splitter: '✂️',
    merger: '🔗',
    router: '🔀',
    condition: '❓',
    iterator: '🔁',
    parallel: '⚡',
    pipeline: '➡️',
    retry: '🔁',
    throttle: '⏱️',
    database: '🗄️',
    cache: '⚡',
    file: '📁',
    queue: '📬',
    storage: '💾',
    email: '📧',
    feishu: '✈️',
    dingtalk: '🔔',
    webhook_notify: '📤',
    notification: '📣',
    response: '📤',
    template: '📋',
    logger: '📋',
    validator: '✅',
    pool: '🔗',
    code: '💻',
  };
  return icons[type] || '📦';
}
