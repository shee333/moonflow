# MoonFlow 快速入门指南

**目标**: 让项目负责人在 5 分钟内了解 MoonFlow 核心功能和 Demo

---

## 🚀 5 分钟快速概览

### MoonFlow 是什么？

MoonFlow 是一个基于 DAG 的工作流引擎，使用 MoonBit 语言开发，具有：

- ✅ **高性能**: MoonBit 原生编译，执行效率高
- ✅ **类型安全**: MoonBit 强类型系统，减少运行时错误
- ✅ **轻量级**: 核心库小巧，适合嵌入式场景
- ✅ **可扩展**: 支持自定义组件和插件

---

## 📦 核心概念

### 1. 工作流 (Workflow)

工作流是 MoonFlow 的核心，包含：

- **节点 (Node)**: 执行单元
- **边 (Edge)**: 节点之间的依赖关系
- **配置 (Config)**: 节点参数和设置

### 2. 节点类型

```
触发器 (Trigger) → 工具 (Tool) → 代理 (Agent) → 控制 (Control)
     ↓                ↓              ↓              ↓
  timer            http          llm          condition
  webhook          email         intent      parallel
  manual           file          classify    loop
```

### 3. 执行模型

```
DAG 构建 → 拓扑排序 → 节点执行 → 结果收集
    ↓           ↓           ↓           ↓
  validator   scheduler   executor    output
```

---

## 🖥️ 运行 Demo

### 方法 1: 运行示例 Demo

```bash
cd moonflow_core
moon run src/demo/demo.mbt
```

**预期输出**:
```
===========================================
MoonFlow Demo - Starting...
===========================================

1. Creating demo workflow programmatically...
   - Node 1: start (Trigger)
   - Node 2: step1 (Tool)
   - Node 3: step2 (Tool)
   - Node 4: end (Control)
   ...
===========================================
MoonFlow Demo - Completed Successfully!
===========================================
```

### 方法 2: 运行单元测试

```bash
cd moonflow_core
moon test
```

**测试内容**:
- ✅ 工作流验证器测试
- ✅ 节点 ID 唯一性检查
- ✅ 边引用有效性检查
- ✅ 循环依赖检测

---

## 📝 工作流定义示例

### YAML 格式

```yaml
name: github_trending_daily
version: "1.0"
author: MoonFlow Team
description: "每日获取 GitHub Trending 数据并发送通知"

nodes:
  # 触发器：每天早上 8 点执行
  - id: trigger
    type: timer
    config:
      interval: 86400

  # HTTP 工具：获取 GitHub Trending
  - id: fetch_trending
    type: http
    config:
      url: "https://api.github.com/search/repositories"
      method: GET
      params:
        q: "created:>2024-01-01"
        sort: "stars"

  # 过滤工具：筛选前 10 名
  - id: filter_top10
    type: filter
    config:
      condition: "stars > 1000"
      limit: 10

  # 飞书通知：发送消息
  - id: send_notification
    type: feishu
    config:
      webhook_url: "https://open.feishu.cn/..."
      message_type: "text"
      content: "今日 GitHub Trending 已更新！"

edges:
  # 定义执行顺序
  - from: trigger
    to: fetch_trending
  - from: fetch_trending
    to: filter_top10
  - from: filter_top10
    to: send_notification
```

### JSON 格式

```json
{
  "name": "github_trending_daily",
  "version": "1.0",
  "nodes": [
    {
      "id": "trigger",
      "type": "timer",
      "config": {
        "interval": 86400
      }
    },
    {
      "id": "fetch_trending",
      "type": "http",
      "config": {
        "url": "https://api.github.com/search/repositories",
        "method": "GET"
      }
    }
  ],
  "edges": [
    {
      "from": "trigger",
      "to": "fetch_trending"
    }
  ]
}
```

---

## 🔧 核心模块

### 1. 类型定义 (src/workflow/types.mbt)

```moonbit
// 节点类型
pub type NodeType =
  | Trigger      // 触发器
  | Tool         // 工具
  | Agent        // 代理
  | Control      // 控制流

// 工作流定义
pub struct Workflow {
  name: String
  version: String
  nodes: Array[Node]
  edges: Array[Edge]
  metadata: Map[String, String]
}
```

### 2. 工作流验证器 (src/workflow/validator.mbt)

```moonbit
// 验证规则
✅ 节点 ID 唯一性
✅ 边引用有效性
✅ 节点类型检查
✅ 必填字段检查
✅ 循环依赖检测

// 错误类型
| DuplicateNodeId(String)
| InvalidEdgeReference(String)
| CycleDetected(Array[String])
```

### 3. DAG 调度引擎 (src/runtime/scheduler.mbt)

```moonbit
// 核心功能
✅ 图构建：从节点和边构建 DAG
✅ 拓扑排序：Kahn 算法确定执行顺序
✅ 就绪节点检测：依赖完成状态判断
✅ 执行上下文：管理执行状态、结果、变量

// 执行状态
| Pending    // 等待执行
| Running    // 正在执行
| Completed  // 已完成
| Failed     // 失败
| Cancelled  // 已取消
```

### 4. 节点执行器 (src/runtime/executor.mbt)

```moonbit
// 触发器执行器
- execute_timer_trigger
- execute_webhook_trigger
- execute_manual_trigger

// 工具执行器
- execute_http_get
- execute_http_post
- execute_email
- execute_feishu

// 代理执行器
- execute_llm_agent
- execute_intent_classify

// 控制流执行器
- execute_condition
- execute_parallel
- execute_loop
- execute_end
```

---

## 📚 组件库

### 组件分类

| 类别 | 数量 | 示例组件 |
|------|------|----------|
| 触发器 | 2 | timer, cron |
| 工具 | 25+ | http, email, file, database |
| 代理 | 1+ | llm |
| 流控制 | 12+ | retry, rate_limiter, circuit_breaker |

### 常用组件

#### HTTP 请求
```yaml
- id: fetch_api
  type: http
  config:
    url: "https://api.example.com/data"
    method: GET
    timeout: 30000
```

#### 定时触发
```yaml
- id: daily_task
  type: timer
  config:
    interval: 86400  # 每天执行
```

#### 限流保护
```yaml
- id: rate_limited_step
  type: rate_limiter
  config:
    rate: 100
    per: "second"
```

#### 重试机制
```yaml
- id: reliable_step
  type: retry
  config:
    max_attempts: 3
    initial_delay: 1000
    backoff_multiplier: 2
```

---

## 🏗️ 项目结构

```
moonflow_core/
├── src/
│   ├── workflow/          # 工作流核心
│   │   ├── types.mbt     # 类型定义
│   │   ├── parser.mbt    # YAML/JSON 解析
│   │   └── validator.mbt # 工作流验证
│   ├── runtime/          # 运行时引擎
│   │   ├── scheduler.mbt # DAG 调度
│   │   └── executor.mbt  # 节点执行
│   ├── components/       # 组件库 (40+)
│   │   ├── http.mbt     # HTTP 组件
│   │   ├── timer.mbt    # 定时器组件
│   │   └── ...
│   ├── demo/
│   │   └── demo.mbt     # 🚀 运行示例
│   └── utils/           # 工具函数
├── examples/
│   └── github_trending_daily.yaml
├── tests/
│   └── workflow_test.mbt
└── PROGRESS.md          # 开发进度
```

---

## 📊 技术指标

| 指标 | 数值 | 说明 |
|------|------|------|
| 核心库大小 | ~50 KB | MoonBit 编译后 |
| 支持组件数 | 40+ | 持续增加中 |
| 验证规则数 | 5 | 核心验证 |
| 执行模式 | DAG | 支持并行 |
| 类型安全 | ✅ | 编译时检查 |

---

## 🎯 应用场景

### 1. 数据管道
```yaml
触发器 → HTTP获取 → JSON解析 → 数据过滤 → 数据库写入
```

### 2. 定时任务
```yaml
定时器 → 数据采集 → 数据处理 → 发送报告
```

### 3. CI/CD 流程
```yaml
Webhook → 代码检查 → 单元测试 → 构建 → 部署
```

### 4. 通知系统
```yaml
定时器 → 数据查询 → 格式转换 → 多渠道通知
```

---

## 🔍 Demo 执行流程

运行 `moon run src/demo/demo.mbt` 时发生了什么？

### 步骤 1: 创建工作流
```
✓ 定义 4 个节点: start, step1, step2, end
✓ 定义 3 条边: start→step1, step1→step2, step2→end
```

### 步骤 2: 验证工作流
```
✓ 检查节点 ID 唯一性
✓ 检查边引用有效性
✓ 检查节点类型
```

### 步骤 3: 构建 DAG
```
✓ 添加节点到图
✓ 添加边到图
✓ 计算入度 (in-degree)
```

### 步骤 4: 拓扑排序
```
✓ 使用 Kahn 算法
✓ 确定执行顺序: start → step1 → step2 → end
```

### 步骤 5: 执行节点
```
✓ [start] 执行触发器
✓ [step1] 执行工具 (Echo)
✓ [step2] 执行工具 (Process)
✓ [end] 执行控制流
```

---

## 🚦 下一步

### 立即尝试

1. **运行 Demo**:
   ```bash
   cd moonflow_core
   moon run src/demo/demo.mbt
   ```

2. **查看代码**:
   - `src/demo/demo.mbt` - Demo 源码
   - `src/workflow/types.mbt` - 类型定义
   - `src/runtime/scheduler.mbt` - 调度引擎

3. **阅读文档**:
   - `PROGRESS.md` - 开发进度
   - `COMPONENTS.md` - 组件库详情
   - `QUICKSTART.md` - 本文档

### 后续功能

- [ ] Web UI 可视化编辑器
- [ ] 持久化存储支持
- [ ] 分布式执行
- [ ] 监控和指标
- [ ] 更多组件

---

## 📞 获取帮助

- 📖 文档: 查看 `*.md` 文件
- 💻 代码: 查看 `src/` 目录
- 🧪 测试: 运行 `moon test`
- 🐛 问题: 检查 `PROGRESS.md` 已知问题

---

**祝你玩得开心！🚀**
