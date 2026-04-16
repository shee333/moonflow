# MoonFlow Project Guide

MoonFlow 是一个 AI Agent 工作流编排平台（类似 Dify/Coze），支持可视化 DAG 工作流设计、40+ 预构建组件、MoonBit 代码生成。

---

## 技术栈

| 层级 | 技术 | 用途 |
|------|------|------|
| 前端 | React 19 + TypeScript 5 + Vite 5 | 可视化 DAG 编辑器 |
| 可视化 | @xyflow/react (ReactFlow) | 节点图编辑 |
| 代码编辑 | Monaco Editor | MoonBit 代码预览/编辑 |
| 后端核心 | MoonBit | 高性能执行引擎 |
| HTTP 服务 | moonbitlang/async | 服务器实现（需 Unix） |
| 包管理 | MoonBit Package Manager | 模块管理 |
| 测试 | Vitest（前端）+ moon test（后端）| 测试套件 |

---

## 项目目录结构

```
moonflow/
├── core/                           # MoonBit 后端（核心引擎）
│   ├── moon.mod.json               # 模块配置（name: "username/moonflow"）
│   ├── moon.pkg.json               # 根包配置
│   ├── moonflow_core.mbt           # 主包公共 API
│   ├── moonflow_core_test.mbt      # 黑盒测试
│   ├── moonflow_core_wbtest.mbt    # 白盒测试
│   ├── cmd/server/                 # HTTP 服务入口
│   │   ├── main.mbt               # fn main { moonflow_core.start_server(port=8080) }
│   │   └── moon.pkg.json
│   ├── src/
│   │   ├── index.mbt              # 入口索引
│   │   ├── components/            # 组件实现（40+ 文件）
│   │   │   ├── component.mbt      # Component trait + 核心类型定义
│   │   │   ├── registry.mbt       # 组件注册表
│   │   │   ├── http.mbt           # HTTP 请求组件
│   │   │   ├── llm.mbt            # LLM 组件（OpenAI/Claude/Gemini）
│   │   │   ├── filter.mbt         # 数据过滤组件
│   │   │   ├── router.mbt         # 路由组件
│   │   │   ├── retry.mbt          # 重试机制
│   │   │   ├── circuit_breaker.mbt # 断路器模式
│   │   │   ├── email.mbt          # 邮件组件
│   │   │   ├── feishu.mbt         # 飞书组件
│   │   │   ├── database.mbt       # 数据库组件
│   │   │   ├── file.mbt           # 文件操作组件
│   │   │   ├── cache.mbt          # 缓存组件
│   │   │   ├── queue.mbt          # 队列组件
│   │   │   ├── pool.mbt           # 连接池组件
│   │   │   ├── rate_limiter.mbt   # 限流器
│   │   │   ├── batch.mbt          # 批处理
│   │   │   ├── buffer.mbt         # 缓冲区
│   │   │   ├── pipeline.mbt       # 管道
│   │   │   ├── split.mbt / splitter.mbt  # 分流
│   │   │   ├── merger.mbt         # 合并
│   │   │   ├── multicast.mbt      # 多播
│   │   │   └── ... (更多组件)
│   │   ├── runtime/               # 执行层
│   │   │   ├── context.mbt        # ExecutionContext, Value, NodeResult, NodeStatus
│   │   │   ├── executor.mbt       # 节点执行器（按类型分发）
│   │   │   ├── scheduler.mbt      # DAG 调度器（拓扑排序）
│   │   │   └── workflow_executor.mbt  # 工作流执行编排
│   │   ├── workflow/              # 工作流 DSL 层
│   │   │   ├── types.mbt          # NodeType, TriggerType, ToolType 等类型定义
│   │   │   ├── parser.mbt         # JSON 工作流解析器
│   │   │   ├── validator.mbt      # 工作流验证（环检测、引用检查等）
│   │   │   └── workflow_helpers.mbt  # 工作流辅助函数
│   │   ├── utils/                 # 工具库
│   │   │   ├── array_utils.mbt    # 数组操作（flatten, unique, chunk 等）
│   │   │   ├── string_utils.mbt   # 字符串操作（case 转换、split、slugify 等）
│   │   │   ├── datetime_utils.mbt # 日期时间处理（DateTime 结构体）
│   │   │   └── validator_utils.mbt # 验证工具（email, URL, UUID 等）
│   │   └── demo/                  # 演示程序
│   │       └── demo.mbt
│   └── examples/                  # 示例工作流（YAML/JSON）
│       ├── demo_workflow.json
│       └── github_trending_daily.yaml
│
├── frontend/                      # React 前端
│   ├── src/
│   │   ├── App.tsx                # 主应用
│   │   ├── components/            # React 组件（DAGEditor, MoonFlowNode 等）
│   │   ├── context/               # React Context（全局工作流状态）
│   │   ├── hooks/                 # 自定义 Hooks（useWorkflow 等）
│   │   ├── services/              # API 服务（workflowService, codeGenerator）
│   │   ├── types/                 # TypeScript 类型定义
│   │   └── utils/                 # 前端工具函数
│   └── package.json
│
├── docs/                          # 文档
│   ├── DSL_SPEC.md                # 工作流 DSL 规范
│   └── SECURITY.md                # 安全设计文档
│
└── .trae/skills/                  # AI Agent 技能
```

---

## 核心类型系统

### Component 接口（`core/src/components/component.mbt`）

这是整个组件系统的核心 trait，所有组件必须实现：

```mbt nocheck
pub trait Component {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult
  fn validate(config: Map[String, String]) -> Bool
  fn get_metadata() -> ComponentMetadata
}

pub type ComponentResult = Result[ComponentOutput, ComponentError]

pub struct ComponentInput {
  data: String
  params: Map[String, String]
  secrets: Map[String, String]
}

pub struct ComponentOutput {
  data: String
  metadata: Map[String, String]
}

pub type ComponentError =
  | NetworkError(String)
  | AuthenticationError(String)
  | ValidationError(String)
  | ExecutionError(String)
  | TimeoutError
  | RateLimitError
  | UnknownError(String)

pub struct ComponentMetadata {
  name: String
  version: String
  description: String
  category: ComponentCategory
  inputs: Array[InputSchema]
  outputs: Array[OutputSchema]
}

pub enum ComponentCategory { Trigger; Tool; Agent; Control }
```

### 工作流类型（`core/src/workflow/types.mbt`）

```mbt nocheck
pub type NodeType = Trigger | Tool | Agent | Control
pub type TriggerType = Timer | Webhook | Manual
pub type ToolType = HTTP | Email | Feishu | File | Database | LLM | ...
pub type AgentType = LLM | IntentClassify
pub type ControlType = Condition | Parallel | Loop | End
pub type RetryStrategy = ExponentialBackoff | Linear | Fixed

pub struct Node {
  id: String
  node_type: String
  name: String
  config: Map[String, String]
  retry_config: RetryConfig?
  timeout_ms: Int
}

pub struct Edge {
  from: String
  to: String
  condition: String?
}

pub struct Workflow {
  name: String
  version: String
  description: String
  nodes: Array[Node]
  edges: Array[Edge]
  metadata: Map[String, String]
}
```

### 运行时类型（`core/src/runtime/context.mbt`）

```mbt nocheck
pub struct ExecutionContext {
  data: String
  metadata: ExecutionMetadata
  variables: Map[String, String]
}

pub struct ExecutionMetadata {
  execution_id: String
  workflow_id: String
  start_time: Int
  node_results: Map[String, NodeResult]
  logs: Array[String]
}

pub enum NodeStatus { Pending; Running; Success; Failure; Skipped }

pub struct NodeResult {
  node_id: String
  status: NodeStatus
  output: String
  duration_ms: Int
  error: String?
}
```

---

## 新增组件开发指南

### 标准模板

在 `core/src/components/` 下创建新文件：

```mbt nocheck
package moonflow_core::components

///|
pub struct MyComponent

///|
impl Component for MyComponent {
  fn execute(input: ComponentInput, ctx: moonflow_core::runtime::ExecutionContext) -> ComponentResult {
    // 1. 提取并验证参数
    let param = input.params.get_or("key", "default")
    if param == "" {
      return Err(ComponentError::ValidationError("Key is required"))
    }

    // 2. 执行业务逻辑
    let result = process(param, input.data)

    // 3. 构建输出
    let metadata: Map[String, String] = {}
    metadata["processed"] = "true"
    Ok(create_component_output_with_metadata(result, metadata))
  }

  fn validate(config: Map[String, String]) -> Bool {
    match config["key"] {
      Some(v) => v.length() > 0
      None => false
    }
  }

  fn get_metadata() -> ComponentMetadata {
    ComponentMetadata::{
      name: "my_component",
      version: "1.0.0",
      description: "描述组件功能",
      category: ComponentCategory::Tool,
      inputs: [
        InputSchema::{ name: "key", type_: "string", required: true, description: "参数说明" },
      ],
      outputs: [
        OutputSchema::{ name: "result", type_: "string", description: "输出说明" },
      ],
    }
  }
}

///|
pub fn create_my_component() -> MyComponent {
  MyComponent::{  }
}
```

### 组件开发要点

1. **所有组件在 `moonflow_core::components` 包内**，同包文件共享所有声明
2. **必须实现 Component trait 的三个方法**：`execute`, `validate`, `get_metadata`
3. **错误处理**：使用 `ComponentError` 的具体变体，不要用 `UnknownError` 代替
4. **参数提取**：使用 `input.params.get_or(key, default)` 获取参数
5. **密钥管理**：API key 等从 `input.secrets` 获取，不从 params
6. **辅助函数**：组件内部函数不需要 `pub`，仅用 `fn`
7. **构造函数**：提供 `pub fn create_xxx_component()` 工厂方法
8. **注册组件**：在 `registry.mbt` 的 `init_registry()` 中注册新组件

---

## 工作流 DSL 格式

### YAML 示例

```yaml
version: v1
name: github_trending_daily
metadata:
  author: MoonFlow Team
  version: "1.0"

nodes:
  - id: trigger
    type: trigger.timer
    with:
      schedule: '0 9 * * *'

  - id: fetch_trending
    type: tool.http_get
    with:
      url: 'https://api.github.com/trending'
      timeout: 10000
      retry:
        max_attempts: 3
        strategy: exponential_backoff

  - id: summarize
    type: agent.llm
    with:
      model: gpt-4
      prompt: 'Summarize: {$.fetch_trending.body}'
      temperature: 0.7
      max_tokens: 1000

edges:
  - { from: trigger, to: fetch_trending }
  - { from: fetch_trending, to: summarize }
```

### DSL 关键特性

- **变量引用**：`{$.node_id.field}` 访问前序节点输出
- **条件表达式**：`{$.temperature > 30}` 条件执行
- **重试策略**：exponential_backoff, linear, fixed
- **超时控制**：per-node 和全局超时
- **审批门禁**：人工审批高风险操作

---

## 工作流执行流程

```
JSON/YAML 工作流定义
       ↓
  parser.mbt（解析为 Workflow 结构体）
       ↓
  validator.mbt（验证：ID 唯一性、环检测、引用有效性）
       ↓
  scheduler.mbt（构建 DAG、拓扑排序）
       ↓
  workflow_executor.mbt（按序执行节点）
       ↓
  executor.mbt（根据节点类型分发到具体组件）
       ↓
  components/*.mbt（执行具体逻辑）
       ↓
  NodeResult + ExecutionContext（收集结果）
```

### 验证规则（`validator.mbt`）

1. **ID 唯一性**：所有节点 ID 不重复
2. **环检测**：DAG 不能有循环依赖（DFS 检测）
3. **引用有效性**：Edge 引用的 from/to 必须存在
4. **节点类型**：类型字符串必须合法
5. **完整性**：必须有 trigger 和 end 节点

---

## 构建与测试命令

### MoonBit 后端

```bash
cd core

# 类型检查（快速，常用）
moon check

# 格式化代码
moon fmt

# 运行测试
moon test
moon test --update         # 更新快照

# 构建
moon build

# 运行演示
moon run src/demo/demo.mbt

# 更新公共 API 接口文件
moon info
```

### React 前端

```bash
cd frontend

npm run dev          # 开发服务器 localhost:5173
npm run build        # 生产构建
npm run lint         # ESLint 检查
npm run typecheck    # TypeScript 检查
npm test             # Vitest 测试
```

---

## 组件分类清单

### Trigger（触发器）
- `Timer` / `Cron` - 定时触发
- `Webhook` - HTTP 回调触发
- `Manual` - 手动触发

### Tool（工具）
- **网络**：HTTP（GET/POST/PUT/DELETE/PATCH）, Webhook
- **存储**：File, Database, JSON
- **通信**：Email, Feishu, Slack, Notification
- **格式化**：Formatter, Validator

### Agent（智能体）
- LLM（GPT-4/Claude/Gemini，通过 provider 自动检测）
- Intent Classification

### Control（流控）
- Retry, Circuit Breaker, Rate Limiter
- Buffer, Batch, Debounce, Throttle
- Pool, Split, Multicast, Pipeline
- Router（RoundRobin/Random/Weighted/Hash）
- Aggregator, Merger, Collect, Iterator

---

## 前端架构

### React 组件层次

```
App
├── DAGEditor (ReactFlow)
│   ├── MoonFlowNode（自定义节点）
│   ├── MoonFlowEdge（自定义边）
│   └── ComponentPalette（可拖拽组件面板）
├── CodeEditor (Monaco)
├── PropertiesPanel（节点属性配置）
└── ExecutionPanel（执行结果/日志）
```

### 状态管理

- React Context 管理全局工作流状态
- 自定义 Hooks：`useWorkflow`, `useCodeGeneration` 等
- 服务层：`workflowService.ts`（API 通信）、`codeGenerator.ts`（MoonBit 代码生成）

---

## 代码规范

### MoonBit 后端

1. **命名**：函数 `lower_snake_case`，类型 `PascalCase`，枚举变体 `PascalCase`
2. **块分隔**：顶层声明之间用 `///|` 分隔
3. **错误处理**：使用 `Result` 类型和 `ComponentError` 变体
4. **验证前置**：在处理逻辑之前验证所有输入
5. **元数据完整**：组件必须提供完整的 inputs/outputs Schema
6. **最小公开 API**：仅 `pub` 必要的导出

### React/TypeScript 前端

1. **组件命名**：`PascalCase`
2. **Hooks**：`use` 前缀 + `camelCase`
3. **类型定义**：所有 props 使用 TypeScript 类型，避免 `any`

### Git 提交格式

```
<type>(<scope>): <subject>
```

- **type**: feat, fix, docs, style, refactor, perf, test, build, ci, chore
- **scope**: frontend, core, components, workflow, docs

---

## 已知限制

1. **MoonBit 原生编译**：仅在 Unix（Linux/macOS）上支持，Windows 需要 WSL2
2. **moonbitlang/async**：HTTP 服务器库有平台要求
3. **组件为模拟实现**：当前部分组件（如 HTTP、LLM）返回模拟数据，尚未接入真实网络调用
4. **前端代码生成**：将可视化工作流转换为 MoonBit 代码的功能

---

## 安全设计要点

- 多层安全架构：能力声明 → 进程隔离 → 运行时拦截 → 审计
- 高风险操作需人工审批（ApprovalConfig）
- API Key 通过 `secrets` 字段传递，不在 `params` 中明文
- 输入验证使用 `validator_utils.mbt` 中的工具函数
- 日志完整记录操作轨迹
