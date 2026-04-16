# MoonFlow 架构设计文档

**日期**: 2026-04-07
**版本**: 2.0

---

## 核心架构

```
┌─────────────────────────────────────────────────────────────┐
│                     MoonFlow                              │
│                                                          │
│  ┌─────────────┐           ┌─────────────────────────┐  │
│  │   前端      │   JSON    │      MoonBit 后端        │  │
│  │  (React)   │ ────────→ │    (执行引擎)           │  │
│  │            │           │                         │  │
│  │ 可视化编辑  │ ←─────── │   HTTP Server         │  │
│  │ 组件面板   │   执行结果 │   执行引擎           │  │
│  │ 代码预览   │           │   LLM Client         │  │
│  └─────────────┘           └─────────────────────────┘  │
│                                                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 前后端分工

### 前端职责

| 功能 | 说明 |
|------|------|
| 可视化编辑 | 拖拽式工作流设计 |
| 组件面板 | 40+ 组件选择 |
| 代码预览 | 实时生成 MoonBit DSL |
| 调用后端 | 发送工作流 JSON |
| 结果展示 | 显示执行结果和日志 |

### MoonBit 后端职责

| 功能 | 说明 |
|------|------|
| HTTP Server | 接收前端请求 |
| 路由分发 | `/api/execute`, `/api/health` |
| 工作流解析 | JSON → Workflow 类型 |
| 执行引擎 | 按拓扑序执行节点 |
| LLM Client | 调用 OpenAI/Claude/Gemini |
| 错误处理 | 异常捕获和日志 |
| 结果返回 | JSON 格式执行结果 |

---

## API 设计

### 基础信息

- **Base URL**: `http://localhost:8080`
- **Content-Type**: `application/json`

### 端点

#### 1. 健康检查

```
GET /api/health
```

**响应**:
```json
{
  "status": "ok",
  "version": "0.1.0",
  "timestamp": "2026-04-07T10:00:00Z"
}
```

#### 2. 执行工作流

```
POST /api/execute
Content-Type: application/json

{
  "workflow": {
    "name": "My Workflow",
    "nodes": [...],
    "edges": [...]
  },
  "inputs": {
    "message": "Hello"
  }
}
```

**响应**:
```json
{
  "execution_id": "exec_123",
  "status": "completed",
  "results": {
    "llm_output": "AI response..."
  },
  "logs": [...],
  "duration_ms": 1500
}
```

#### 3. 节点执行

```
POST /api/execute/node
Content-Type: application/json

{
  "node": {
    "id": "llm_1",
    "type": "llm",
    "config": {...}
  },
  "context": {...}
}
```

**响应**:
```json
{
  "success": true,
  "output": {
    "content": "AI response..."
  },
  "duration_ms": 1200
}
```

#### 4. LLM 调用

```
POST /api/llm
Content-Type: application/json

{
  "provider": "openai",
  "model": "gpt-4",
  "api_key": "sk-xxx",
  "messages": [
    {"role": "user", "content": "Hello"}
  ]
}
```

**响应**:
```json
{
  "success": true,
  "content": "AI response...",
  "usage": {
    "prompt_tokens": 10,
    "completion_tokens": 20,
    "total_tokens": 30
  }
}
```

---

## 模块结构

```
core/
├── moon.mod.json
├── moon.pkg
│
├── src/
│   ├── server/
│   │   ├── server.mbt      # HTTP Server 主入口
│   │   ├── router.mbt      # 路由分发
│   │   ├── handlers/       # 请求处理器
│   │   │   ├── execute.mbt # 工作流执行
│   │   │   ├── health.mbt  # 健康检查
│   │   │   └── llm.mbt    # LLM 调用
│   │   └── middleware/
│   │       ├── logger.mbt  # 日志中间件
│   │       └── cors.mbt    # CORS 中间件
│   │
│   ├── http/
│   │   ├── client.mbt      # HTTP Client
│   │   └── types.mbt       # HTTP 类型定义
│   │
│   ├── llm/
│   │   ├── client.mbt      # LLM 客户端
│   │   ├── openai.mbt      # OpenAI 实现
│   │   ├── claude.mbt      # Claude 实现
│   │   └── types.mbt       # LLM 类型定义
│   │
│   ├── runtime/
│   │   ├── executor.mbt    # 执行器
│   │   ├── context.mbt    # 执行上下文
│   │   ├── workflow_executor.mbt # 工作流执行
│   │   └── scheduler.mbt  # 调度器
│   │
│   ├── workflow/
│   │   ├── types.mbt      # 工作流类型
│   │   ├── parser.mbt     # JSON 解析
│   │   └── validator.mbt  # 验证器
│   │
│   └── utils/
│       ├── logger.mbt      # 日志工具
│       └── json.mbt        # JSON 工具
│
└── cmd/
    └── server/
        ├── main.mbt       # 程序入口
        └── moon.pkg.json   # 包配置
```

---

## 技术栈

| 组件 | 技术 | 说明 |
|------|------|------|
| 前端 | React + TypeScript | 可视化编辑 |
| 后端 | MoonBit | 执行引擎 |
| 协议 | HTTP | 前后端通信 |
| LLM | OpenAI API | AI 调用 |

---

## 数据流

```
1. 用户在前端拖拽设计工作流
        ↓
2. 前端生成工作流 JSON
        ↓
3. 前端调用 POST /api/execute
        ↓
4. MoonBit 后端接收 JSON
        ↓
5. 解析为 Workflow 类型
        ↓
6. 验证工作流
        ↓
7. 按拓扑序执行节点
        ↓
   ├── LLM 节点 → 调用 LLM Client → OpenAI API
   ├── HTTP 节点 → 调用 HTTP Client → 外部 API
   └── 其他节点 → 本地处理
        ↓
8. 收集执行结果
        ↓
9. 返回 JSON 响应
        ↓
10. 前端展示结果
```

---

## 错误处理

```moonbit
enum ServerError {
  InvalidRequest(String)
  WorkflowNotFound
  ExecutionFailed(String)
  LLMError(String)
  NetworkError(String)
}

fn handle_error(err: ServerError) -> (Int, String) {
  match err {
    InvalidRequest(msg) => (400, @json.stringify({ error => msg }))
    WorkflowNotFound => (404, @json.stringify({ error => "Workflow not found" }))
    ExecutionFailed(msg) => (500, @json.stringify({ error => msg }))
    LLMError(msg) => (502, @json.stringify({ error => "LLM error: \{msg}" }))
    NetworkError(msg) => (503, @json.stringify({ error => "Network error: \{msg}" }))
  }
}
```

---

## 性能优化

1. **连接复用**: HTTP Client 连接池
2. **异步执行**: 非阻塞 I/O
3. **结果缓存**: 常用结果缓存
4. **超时控制**: 防止长时间等待

---

## 下一步

1. [ ] 实现 HTTP Server
2. [ ] 实现 HTTP Client
3. [ ] 实现 LLM Client (OpenAI)
4. [ ] 集成执行引擎
5. [ ] 前端改造
6. [ ] 端到端测试

---

**维护者**: MoonFlow Team
