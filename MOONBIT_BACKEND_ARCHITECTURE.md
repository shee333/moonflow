# MoonBit 后端架构设计

**日期**: 2026-04-04
**状态**: 架构设计完成

---

## 🎯 架构目标

使用 MoonBit 实现完整的后端服务，让 MoonFlow 工作流可以在 MoonBit 原生环境执行。

---

## 📦 核心组件

### 1. HTTP 服务器 - `moonbitlang/async`

```moonbit
import moonbitlang/async

async fn main {
  let server = @http.Server::new(port=8080, host="0.0.0.0")
  server.run_forever(handle_request)
}
```

**功能**:
- ✅ 异步 HTTP 服务器
- ✅ 请求路由
- ✅ 响应处理

**API**:
| 方法 | 说明 |
|------|------|
| `@http.Server::new(port, host)` | 创建服务器 |
| `server.run_forever(callback)` | 启动服务器 |
| `request.path` | 获取请求路径 |
| `request.method` | 获取请求方法 |
| `request.headers` | 获取请求头 |
| `response.write_header()` | 写入响应头 |
| `response.write()` | 写入响应体 |
| `response.end()` | 结束响应 |

### 2. HTTP 客户端 - `moonbit-community/requests`

```moonbit
import allwefantasy/requests

// GET 请求
let response = @allwefantasy/requests.get(url, params?, headers?, timeout_ms?)

// POST 请求
let response = @allwefantasy/requests.post(url, headers?, body?, timeout_ms?)

// JSON 请求
let json_data = { "key": "value" }
let response = @allwefantasy/requests.post(url, None, Some(json_data), None)
```

**功能**:
- ✅ GET/POST/PUT/DELETE/PATCH
- ✅ JSON 和表单数据
- ✅ 自定义请求头
- ✅ 超时控制
- ✅ Cookie 管理
- ✅ Session 支持

**错误处理**:
```moonbit
try {
  let response = @allwefantasy/requests.get(url)
  response.raise_for_status()
} catch {
  @allwefantasy/requests.RequestError::HTTPError(404, _, _) => {
    println("Not Found")
  }
  @allwefantasy/requests.RequestError::Timeout(msg) => {
    println("Timeout: \{msg}")
  }
}
```

### 3. 工作流执行引擎 - 现有模块

```moonbit
import moonflow_core::runtime
import moonflow_core::workflow

// 执行工作流
let workflow = parse_workflow(json_string)
let result = @moonflow_core::runtime.execute_workflow(workflow)
```

**模块**:
- ✅ `moonflow_core::workflow` - 工作流类型和解析
- ✅ `moonflow_core::runtime` - 执行器和调度器
- ✅ `moonflow_core::components` - 40+ 工作流组件

---

## 🏗️ 系统架构

```
┌─────────────────────────────────────────────────────────┐
│                    HTTP Server                           │
│              (moonbitlang/async)                         │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │  Router   │  │  Handler │  │ Response │             │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘             │
└───────┼─────────────┼─────────────┼────────────────────┘
        │             │             │
        ▼             ▼             ▼
┌─────────────────────────────────────────────────────────┐
│              Request Handler                             │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │Workflow  │  │Workflow  │  │Workflow  │             │
│  │ CRUD     │  │ Execute  │  │ Validate │             │
│  └──────────┘  └──────────┘  └──────────┘             │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│           Workflow Execution Engine                       │
│           (moonflow_core::runtime)                      │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │ Executor │  │Scheduler │  │ Context  │             │
│  └──────────┘  └──────────┘  └──────────┘             │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│             Component Library                            │
│           (moonflow_core::components)                   │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │   LLM    │  │  HTTP   │  │  Timer   │             │
│  └──────────┘  └──────────┘  └──────────┘             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │  Email   │  │  File   │  │ Database │             │
│  └──────────┘  └──────────┘  └──────────┘             │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 项目结构

```
moonflow/
├── moon.mod.json                 # 模块配置
├── moon.pkg                      # 根包配置
│
├── src/                          # 核心库
│   ├── workflow/                 # 工作流类型
│   ├── runtime/                  # 执行引擎
│   ├── components/               # 组件库
│   └── utils/                    # 工具函数
│
├── cmd/                          # 命令行工具
│   ├── server/                   # HTTP 服务器
│   │   ├── main.mbt
│   │   ├── router.mbt           # 路由
│   │   ├── handlers/             # 请求处理器
│   │   │   ├── workflow.mbt     # 工作流 CRUD
│   │   │   ├── execute.mbt      # 工作流执行
│   │   │   └── health.mbt       # 健康检查
│   │   └── middleware/           # 中间件
│   │       ├── logger.mbt        # 日志
│   │       └── cors.mbt          # CORS
│   │
│   └── cli/                      # CLI 工具
│       ├── main.mbt
│       └── commands/             # 命令
│           ├── run.mbt           # 运行工作流
│           ├── validate.mbt       # 验证工作流
│           └── generate.mbt       # 生成代码
│
└── tests/                        # 测试
    ├── server_test.mbt
    ├── workflow_test.mbt
    └── integration_test.mbt
```

---

## 🔌 API 设计

### 基础信息

- **Base URL**: `http://localhost:8080`
- **Content-Type**: `application/json`

### 端点

#### 1. 健康检查

```
GET /health
```

**响应**:
```json
{
  "status": "ok",
  "version": "0.1.0",
  "uptime": 3600
}
```

#### 2. 工作流 CRUD

```
GET    /api/workflows           # 列出所有工作流
GET    /api/workflows/:id       # 获取工作流详情
POST   /api/workflows           # 创建工作流
PUT    /api/workflows/:id       # 更新工作流
DELETE /api/workflows/:id       # 删除工作流
POST   /api/workflows/:id/clone # 克隆工作流
```

**创建工作流**:
```json
POST /api/workflows
{
  "name": "My Workflow",
  "description": "A sample workflow",
  "nodes": [...],
  "edges": [...]
}
```

#### 3. 工作流执行

```
POST /api/execute/:workflow_id  # 执行工作流
GET  /api/execute/:execution_id # 获取执行状态
GET  /api/execute/:execution_id/logs # 获取执行日志
POST /api/execute/:execution_id/stop  # 停止执行
```

**执行工作流**:
```json
POST /api/execute/my-workflow
{
  "inputs": {
    "user_input": "Hello world"
  },
  "options": {
    "timeout": 300000,
    "retry": true
  }
}
```

**响应**:
```json
{
  "execution_id": "exec_123456",
  "status": "running",
  "started_at": "2026-04-04T10:00:00Z"
}
```

#### 4. 组件信息

```
GET /api/components             # 列出所有组件
GET /api/components/:type      # 获取组件详情
```

---

## 📝 实现代码

### 1. HTTP 服务器入口

```moonbit
package moonflow_server

import moonbitlang/async

async fn main {
  @pipe.stdout.write("===========================================\n")
  @pipe.stdout.write("  MoonFlow Server\n")
  @pipe.stdout.write("  AI Workflow Engine in MoonBit\n")
  @pipe.stdout.write("===========================================\n")

  let server = @http.Server::new(port=8080, host="0.0.0.0")
  @pipe.stdout.write("Listening on http://localhost:8080\n")
  @pipe.stdout.write("API Docs: http://localhost:8080/api/health\n\n")

  server.run_forever(handle_request)
}

async fn handle_request(
  request: @http.Request,
  body: @io.Reader,
  response: @http.ResponseWriter
) -> Unit {
  let path = request.path
  let method = request.method

  @pipe.stderr.write("[{method}] {path}\n")

  match (method, path) {
    ("GET", "/health" | "/api/health") => {
      health_handler(response)
    }
    ("GET", "/api/workflows") => {
      list_workflows_handler(response)
    }
    ("POST", "/api/workflows") => {
      create_workflow_handler(request, body, response)
    }
    ("GET", path) if path.starts_with("/api/workflows/") => {
      let id = path.substring(start=15)
      get_workflow_handler(id, response)
    }
    ("POST", path) if path.starts_with("/api/execute/") => {
      let workflow_id = path.substring(start=13)
      execute_workflow_handler(workflow_id, body, response)
    }
    _ => {
      not_found_handler(response)
    }
  }
}
```

### 2. 工作流处理器

```moonbit
import moonflow_core::runtime
import moonflow_core::workflow
import moonflow_core::workflow::parser

fn execute_workflow_handler(
  workflow_id: String,
  body: @io.Reader,
  response: @http.ResponseWriter
) -> Unit {
  try {
    let body_text = body.read_all() |> @result.unwrap
    let inputs = @json.parse(body_text) |> @result.unwrap

    let workflow = load_workflow(workflow_id)?
    let result = @moonflow_core::runtime.execute_workflow(workflow, inputs)

    response.write_header(200, "OK")
    response.write(@json.stringify({
      execution_id => result.execution_id,
      status => result.status,
      output => result.output,
    }))
    response.end()
  } catch {
    e => {
      response.write_header(500, "Internal Server Error")
      response.write(@json.stringify({ error => e }))
      response.end()
    }
  }
}
```

### 3. LLM 组件集成

```moonbit
import allwefantasy/requests

async fn execute_llm_component(config: LLMConfig, ctx: ExecutionContext) -> ComponentResult {
  let api_key = config.get("api_key")?
  let model = config.get_or("model", "gpt-3.5-turbo")
  let provider = config.get_or("provider", "openai")

  let endpoint = match provider {
    "openai" => "https://api.openai.com/v1/chat/completions"
    "anthropic" => "https://api.anthropic.com/v1/messages"
    _ => fail("Unsupported provider: {provider}")
  }

  let headers = [
    ("Authorization", "Bearer {api_key}"),
    ("Content-Type", "application/json"),
  ]

  let body = @json.stringify({
    model => model,
    messages => [
      { role => "user", content => ctx.input }
    ],
    temperature => config.get_or("temperature", 0.7),
  })

  let response = @allwefantasy/requests.post(
    endpoint,
    Some(headers),
    Some(body),
    timeout_ms=Some(60000)
  )

  response.raise_for_status()?

  let result = response.json()?
  let content = result["choices"][0]["message"]["content"]

  {
    success => true,
    output => content,
    metadata => {
      model => model,
      provider => provider,
      usage => result["usage"],
    }
  }
}
```

---

## 🧪 测试方案

### 1. 单元测试

```moonbit
test "health endpoint returns ok" {
  let response = make_request("GET", "/health")
  inspect(response.status, content="200")
  inspect(response.body.status, content="ok")
}

test "workflow execution returns execution_id" {
  let workflow = create_test_workflow()
  let response = make_request("POST", "/api/workflows", workflow)
  inspect(response.status, content="201")

  let execution = make_request("POST", "/api/execute/{response.body.id}", {})
  guard execution.body.execution_id.is_some()
}
```

### 2. 集成测试

```moonbit
async test "full workflow execution" {
  let workflow = load_workflow("test-workflow")
  let result = @moonflow_core::runtime.execute_workflow(workflow, {})

  inspect(result.status, content="Success")
  guard result.output.is_some()
}
```

---

## 🚀 部署方案

### 1. 原生编译

```bash
# 编译
moon build cmd/server --target native

# 运行
./cmd/server
```

### 2. Docker 部署

```dockerfile
FROM debian:bookworm-slim

# 安装运行时依赖
RUN apt-get update && apt-get install -y \
    libgc1 \
    && rm -rf /var/lib/apt/lists/*

# 复制可执行文件
COPY moonflow-server /usr/local/bin/

# 启动服务器
CMD ["moonflow-server"]
```

### 3. 环境变量

```bash
# 服务器配置
export MOONFLOW_PORT=8080
export MOONFLOW_HOST=0.0.0.0

# 工作流配置
export MOONFLOW_DATA_DIR=/data/workflows
export MOONFLOW_LOG_LEVEL=info

# LLM API Keys
export OPENAI_API_KEY=sk-xxx
export ANTHROPIC_API_KEY=sk-ant-xxx
```

---

## 📊 性能优化

### 1. 连接池

```moonbit
let session = @allwefantasy/requests.Session::with_timeout(30000)
session.set_max_connections(100)
```

### 2. 工作流缓存

```moonbit
let cache = @cache.LruCache::new(max_size=1000)
cache.set(workflow_id, workflow)
```

### 3. 异步执行

```moonbit
@async.spawn(async fn() {
  execute_workflow_background(workflow_id)
})
```

---

## 🎯 下一步行动

1. [ ] 创建 `cmd/server/` 目录结构
2. [ ] 实现 HTTP 服务器
3. [ ] 实现路由系统
4. [ ] 实现工作流 CRUD
5. [ ] 实现工作流执行
6. [ ] 集成 LLM 组件
7. [ ] 添加测试
8. [ ] 创建 Docker 配置

---

**维护者**: MoonFlow Team
