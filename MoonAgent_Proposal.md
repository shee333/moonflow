# MoonAgent: 基于 MoonBit 的 AI 智能体编排引擎

## （1）项目目标与应用场景

### 项目背景

当前主流的 Agent 编排工具（如 Dify、LangChain、LangGraph）普遍基于 Python 或 Node.js 构建。以 Dify 为例，其执行引擎本质上是 Python 进程，通过 Flask/FastAPI 提供 HTTP 接口，节点调度依赖于 asyncio 协程。这种实现方式存在以下固有问题：

1. **GIL 限制**：Python 的全局解释器锁使得 CPU 密集型的 Agent 节点（如 JSON 解析、XML 转换、正则匹配）无法真正并行执行。
2. **冷启动延迟**：Python 解释器的启动时间通常在 100-500ms，在边缘计算场景（如 Cloudflare Workers、嵌入式网关）中难以接受。
3. **内存占用**：一个包含基础 Python 依赖（numpy、requests、langchain 等）的 Agent 镜像通常 >200MB，而同等能力的 MoonBit/Wasm 镜像可 <1MB。
4. **沙箱隔离缺陷**：Python 的 ctypes FFI 可以直接调用任意 C 库，恶意节点代码可以轻易提权。现有方案依赖 Docker 容器做隔离，但容器启动慢、资源占用大。

### 解决的实际问题

本项目计划构建一个名为 MoonAgent 的原型系统，核心目标是验证 MoonBit 语言在 Agent 编排场景下的可行性，并产出可运行的参考实现。具体聚焦以下问题：

- **R1**：如何设计一个支持节点并行执行的 DAG 调度器，使其能充分利用 MoonBit 的并发特性（async/await、channel）。
- **R2**：如何利用 MoonBit -> Wasm 的极致体积（<30KB Hello World）和高效启动（<10ms），实现毫秒级冷启动。
- **R3**：如何通过 WASI 接口安全地封装文件系统、网络、GUI 操控等系统级能力，使 Agent 节点既能执行复杂任务，又不会危害宿主安全。
- **R4**：如何设计一套工作流描述规范（DSL），使其既能被人编写、也能被 LLM 生成。

### 应用场景

以下场景是从实际需求中选取的典型案例，用于指导开发优先级和功能边界划定：

**场景 A：定时数据采集与推送**
- 触发条件：每日 9:00 UTC 或 cron 表达式。
- 执行链路：HTTP GET(url) -> JSON 解析 -> Jinja2 模板渲染 -> SMTP 发送邮件。
- 特点：节点逻辑固定、IO 密集、无状态。适合作为首个原型场景。

**场景 B：CSV/Excel 批处理流水线**
- 触发条件：文件上传或 API 调用。
- 执行链路：读取 CSV -> 数据清洗（正则） -> 聚合计算 -> 生成 Excel(xlsxwriter) -> 上传到 OSS。
- 特点：涉及 MoonBit FFI 调用 C 库（xlsxwriter），需要验证 MoonBit 与 C 库互操作的可行性。

**场景 C：桌面应用自动化（参考 OpenClaw）**
- 触发条件：用户手动启动或热键触发。
- 执行链路：截图 -> OCR 识别（调用本地 LLM API） -> 坐标点击 -> 等待画面变化。
- 特点：需要 WASI host function 实现鼠标、键盘、截图能力，且需要"人工确认"机制防止误操作。

**场景 D：LLM 驱动的多轮对话 Agent**
- 触发条件：用户消息进入。
- 执行链路：意图识别（LLM） -> 分支路由（3个并行子链） -> 结果聚合 -> TTS 合成 -> 播放。
- 特点：需要 LLM API 调用、动态 DAG 变更、流式输出处理。

## （2）交付物说明

### 核心功能与功能边界 (Scope)

本项目的交付物为一个包含核心引擎、CLI 工具和 Web UI 的完整原型系统。以下按优先级分为 P0（必须交付）、P1（计划交付）、P2（视时间交付）三个层次。

**P0 - 核心引擎 (moonagent-core)**

| 功能 | 描述 | 技术指标 |
|------|------|----------|
| DAG 执行引擎 | 基于 MoonBit 实现的拓扑排序调度器，支持多节点并行执行 | 支持最多 100 个节点、5 层深度的 DAG |
| 节点状态管理 | 每个节点有 Pending / Running / Success / Failed / Retry 五种状态 | 状态变更需原子化，支持断点恢复 |
| 错误重试机制 | 支持固定间隔和指数退避两种重试策略 | 最大重试次数可配置（默认 3 次） |
| WASI 沙箱 | 基于 WASI Preview 1 接口，运行不受信任的节点代码 | 禁止 syscalls 之外的任何系统调用 |
| 内置节点库 | Timer、HTTP Client、JSON Parser、Jinja2 Renderer、SMTP Sender | 每个节点代码量 <200 行 MoonBit |

**P1 - 工作流工具链 (moonagent-toolchain)**

| 功能 | 描述 | 技术指标 |
|------|------|----------|
| DSL 规范 | 基于 JSON Schema 的工作流描述格式 | 定义节点类型、连接关系、参数绑定、重试策略 |
| CLI 工具 | `moonagent run <workflow.json>` 启动执行 | 支持本地和远程（HTTP URL）两种工作流来源 |
| 日志与追踪 | 结构化日志（JSON Lines），记录每个节点的输入输出 | 日志文件按节点 ID 索引，支持 `jq` 查询 |
| Web UI | 拖拽式编辑器（React + X6），实时预览 DAG | 支持导入/导出 JSON 工作流 |

**P2 - 高级功能 (moonagent-ext)**

| 功能 | 描述 | 说明 |
|------|------|------|
| LLM 节点 | 支持调用 OpenAI/DeepSeek API | 需要处理流式输出和 token 计数 |
| 桌面自动化 | 通过 WASI host function 实现鼠标/键盘控制 | 依赖平台特定的实现（Windows/macOS/Linux） |
| 组件市场 | 提供 `moonagent publish` / `moonagent install` 命令 | 使用 moonbitlang.com 作为 registry |

### 预期使用方式与交互流程

**交互流程 1：从零创建工作流**

1. 用户在 Web UI 的左侧组件面板中选择"Timer"节点，拖入画布。
2. 选择 Timer 的触发条件为 `cron: 0 9 * * *`。
3. 从面板拖入"HTTP Client"节点，将其连接到 Timer 的输出端口。
4. 在右侧属性面板填写 URL: `https://api.github.com/trending`。
5. 继续添加"JSON Parser"和"Jinja2 Renderer"节点，完成 DAG 绘制。
6. 点击"保存"，Web UI 将 DAG 序列化为 JSON DSL，存储在本地文件或远程服务器。
7. 用户执行 `moonagent run ./workflow.json`，引擎开始调度。

**交互流程 2：自然语言生成工作流**

1. 用户在 Web UI 的文本框输入：`每天早上9点抓取GitHub Trending，生成中文摘要，发到我邮箱 test@example.com`。
2. 前端将文本发送给内置的 LLM API（可配置为 DeepSeek/Claude）。
3. LLM 返回符合 JSON Schema 的工作流描述。
4. 前端将工作流渲染为可编辑的 DAG，用户可手动调整。
5. 用户确认后保存并执行。

### 初步测试规划

测试将遵循 MoonBit 官方的 `moon test` 规范，使用内置测试框架。

**单元测试**

- `test_dag_scheduler`: 测试拓扑排序、循环检测、节点依赖解析。
- `test_state_machine`: 测试各状态之间的合法转换和非法转换（期望失败）。
- `test_retry_policy`: 测试指数退避算法的等待时间计算。
- `test_wasi_sandbox`: 测试沙箱内代码无法访问禁止的 syscalls。

**集成测试**

- `test_http_pipeline`: 测试 HTTP GET -> JSON Parser -> Jinja2 Renderer 的完整链路。
- `test_parallel_execution`: 启动 10 个独立节点，验证并行执行和状态汇总正确。
- `test_retry_on_failure`: 模拟 HTTP Server 返回 500，验证 3 次重试后状态为 Failed。
- `test_breakpoint_resume`: 执行到一半时中断，重启后从断点恢复。

**沙箱安全测试**

- 测试恶意节点尝试 `fd_write` 到非允许的 fd。
- 测试恶意节点尝试读取 `/etc/passwd`。
- 测试恶意节点尝试无限循环耗尽 CPU 时间片（应被 WASI 资源限制终止）。

**性能基准测试**

测试环境：Apple M2 MacBook Pro，macOS 14，MoonBit nightly build。

| 指标 | MoonAgent (Wasm) | Dify (Python/FastAPI) | 对比 |
|------|-----------------|----------------------|------|
| 冷启动时间 | <10ms | ~200ms | 20x 更快 |
| 内存占用（idle） | ~2MB | ~120MB | 60x 更小 |
| 100 节点 DAG 调度耗时 | 待测 | - | - |
| Wasm 产物大小 | <500KB（含内置节点） | - | - |

### 文档与使用说明覆盖范围

- **《MoonAgent 快速开始》**：5 分钟上手教程，包含安装、`moonagent run` 命令、行日志解读。
- **《MoonAgent DSL 规范》**：完整的 JSON Schema 定义，每个字段的类型和枚举值说明。
- **《内置节点参考》**：每个内置节点的参数说明、输入输出类型、使用示例。
- **《开发者指南》**：如何使用 MoonBit 编写自定义节点并发布到市场。
- **《部署指南》**：在 Wasmtime、Deno、企业内网等不同环境的部署方式。

## （3）技术路线说明

### 整体系统架构

系统分为四个层次，自顶向下依赖：

```
┌─────────────────────────────────────────────┐
│  表示层（Web UI）                           │
│  React 18 + X6 流程图 + Tailwind CSS        │
├─────────────────────────────────────────────┤
│  接口层（REST API）                         │
│  Axum (Rust) 或 Actix-web，将请求转发给引擎 │
├─────────────────────────────────────────────┤
│  逻辑层（MoonAgent Engine）                 │
│  MoonBit / Wasm 实现的 DAG 调度器           │
├─────────────────────────────────────────────┤
│  资源层（WASI Runtime）                     │
│  Wasmtime 或 wasmoon，提供系统级接口         │
└─────────────────────────────────────────────┘
```

**设计决策说明**：

- **表示层选择 React + X6**：X6 是 Ant Group 出品的流程图库，支持节点拖拽、连线、缩略图、社区活跃。相比自研或使用 GoJS，X6 在定制化和许可证上更合适。
- **接口层使用 Rust 而非 Node.js**：接口层承担鉴权、请求验证、日志格式化等 IO 密集任务。Rust 的 Axum 框架性能优秀，且与 Wasm 生态集成良好。如果时间紧张，也可复用 MoonBit 的 HTTP 库实现简单的接口层。
- **逻辑层完全使用 MoonBit**：核心调度逻辑必须使用 MoonBit，这是本项目的核心验证目标。
- **WASI 而非纯 Wasm**：纯 Wasm 无法访问文件系统、网络等资源。WASI Preview 1 提供了标准化的接口，且被主流 Wasm 运行时广泛支持。

### 核心模块划分

| 模块名 | 语言 | 职责 | 关键接口 |
|--------|------|------|----------|
| `moonagent-core` | MoonBit | DAG 调度、状态管理、重试策略 | `Scheduler.run(workflow)`, `State.get_node_state(id)` |
| `moonagent-dsl` | MoonBit | JSON Schema 解析、DSL 验证 | `Dsl.parse(json)`, `Dsl.validate(schema)` |
| `moonagent-wasi` | MoonBit | WASI host function 封装 | `WasiHttp.request(url, method, headers, body)` |
| `moonagent-nodes` | MoonBit | 内置节点实现 | `TimerNode.execute(ctx)`, `HttpNode.execute(ctx)` |
| `moonagent-cli` | MoonBit | 命令行入口 | `moonagent run <file>`, `moonagent log <id>` |
| `moonagent-api` | Rust | REST 接口 | `POST /workflow/run`, `GET /workflow/{id}/state` |

### 大模型与智能体工具在开发过程中的作用

**代码生成**

开发过程中，将使用 Codex（通过 GitHub Copilot）或 DeepSeek API 辅助生成 MoonBit 代码。具体方式为：

1. 人工编写函数签名和注释，描述期望行为。
2. 将其作为 prompt 前缀，让 LLM 生成实现。
3. 人工审查生成的代码，重点检查类型安全和错误处理。
4. 通过 `moon check` 和 `moon test` 验证。

**结构推演**

DSL 的节点类型和参数设计，将借助 LLM 分析现有的 Dify/LangGraph 节点定义，提取共性模式，避免设计遗漏。

**不依赖 LLM 生成最终产品代码**

本项目的核心价值在于验证 MoonBit 的工程能力，因此核心调度器和内置节点必须由人工编写，确保可维护性和正确性。LLM 仅作为辅助开发工具使用。

### 关键技术选型说明

**MoonBit**

选择 MoonBit 而非 Rust 或 C++ 的原因：

- MoonBit 的 Wasm 输出体积远小于 Rust（Rust Hello World Wasm 通常 >200KB，MoonBit <30KB）。
- MoonBit 的强类型系统能早期捕获错误，减少调试成本。
- MoonBit 的编译速度极快，适合频繁修改迭代。

**WebAssembly + WASI Preview 1**

- Wasm 提供了进程级隔离，且启动速度远快于 Docker 容器。
- WASI Preview 1 是目前最稳定的 WASI 版本，被 Wasmtime、wasmoon、WasmEdge 支持。
- WASI Preview 2（Component Model）正在成熟中，但当前兼容性有限，计划在 P2 阶段评估升级。

**Wasmtime vs wasmoon**

| 特性 | Wasmtime | wasmoon |
|------|----------|---------|
| 成熟度 | 生产级 stable | 活跃开发中 |
| JIT | Cranelift JIT | 自研 SSA-based JIT |
| 性能 | 优秀 | 接近 Wasmtime |
| MoonBit 集成 | 需通过 WASI | 可直接加载 .mbt 产物 |
| 许可证 | Apache 2.0 | MIT |

考虑到 MoonAgent 未来可能需要直接运行 MoonBit 编译产物，wasmoon 的自研 JIT 更具战略价值。P0 阶段将使用 Wasmtime 保证稳定性，P1 阶段切换到 wasmoon。

**并行执行模型**

MoonBit 的并发模型基于 async/await + channel。调度器将使用以下设计：

- 每个节点对应一个异步任务（Future）。
- 依赖就绪的节点并发启动（最多 N 个，N 可配置，默认 CPU 核数）。
- 使用 channel 在节点间传递数据（避免共享内存锁竞争）。
- 超时控制通过 `Select` + `Timer` 实现。

## （4）风险分析与应对方案

### 技术风险

**风险 T1：MoonBit 的 WASI 支持不完善**

目前 MoonBit 的 WASI 支持主要面向 HTTP 和文件 IO，桌面自动化所需的 host function（如鼠标移动、截图）不在 WASI 标准范围内。

*缓解措施*：

- P0 阶段聚焦在 HTTP、Timer、JSON Parser 等纯 WASI 节点。
- P2 阶段通过自定义 WASI host function 实现桌面操控，使用 `moon build --target wasi` 时通过 linker 指定符号。
- 长期跟踪 MoonBit 的 WASI 扩展提案，参与社区讨论。

**风险 T2：MoonBit 的 FFI 能力限制**

部分节点（如 Excel 生成）需要调用 C 库。MoonBit 的 C FFI 目前稳定性和文档有限。

*缓解措施*：

- P0 阶段使用纯 MoonBit 实现（如手写 xlsx 格式，或使用纯 MoonBit 的 ZIP 库生成 OOXML）。
- P1 阶段评估 moonbitlang.com 上是否有现成的 Excel 库。
- 如必须使用 C FFI，优先选用 moonbitlang.com 上已有 FFI 示例的库。

**风险 T3：wasmoon 的稳定性**

wasmoon 处于活跃开发中，可能遇到 JIT 崩溃、spec 不兼容等问题。

*缓解措施*：

- P0 阶段使用成熟的 Wasmtime，隔离此风险。
- 建立测试矩阵，覆盖 Wasmtime 和 wasmoon 两种运行时。
- 关注 wasmoon 的 GitHub issues 和 releases，设置护栏以在运行时检测版本兼容性。

### 工程风险

**风险 E1：开发周期不足**

比赛时间线（3 月截止，4 月答辩）约为 2 个月，对于一个包含引擎、CLI、Web UI 的完整系统较为紧张。

*缓解措施*：

- 严格按 P0/P1/P2 优先级控制范围，P0 阶段聚焦可运行的最小功能集。
- Web UI 在 P0 阶段可简化为 JSON 文件编辑器（Monaco Editor），不实现拖拽功能。
- CLI 和引擎优先开发，接口层可推迟。

**风险 E2：MoonBit 工具链不熟悉**

团队（或个人）对 MoonBit 的熟练度不如 Python/Rust，可能影响开发效率。

*缓解措施*：

- 提前熟悉 MoonBit 的标准库（特别是 async、channel、JSON 处理）。
- 参考 fastcc 的源码结构，学习如何组织大型 MoonBit 项目。
- 利用 MoonBit 的 LSP 和 `moon check --watch` 加速开发迭代。

### 市场/竞争风险

**风险 M1：Dify 等现有产品已足够成熟**

如果 Dify/LangGraph 已能完全满足需求，MoonAgent 的差异化价值可能不足。

*分析*：MoonAgent 的核心差异化在于性能（Wasm 冷启动）和安全性（细粒度沙箱），这是现有 Python 框架的结构性缺陷，而非功能差异。在边缘部署和桌面自动化场景下，MoonAgent 有明确的技术优势。

## （5）相关研究与实践基础

### 既有研究与开源项目

**Dify (https://github.com/langgenius/dify)**

Dify 是目前最流行的开源 Agent 编排平台之一。其架构为：

- 后端：Python/FastAPI + PostgreSQL + Redis
- 前端：React + Rete.js（流程图）
- 执行模型：基于 Python asyncio，每个节点是独立函数，状态存储在 Redis

优点：生态成熟、社区活跃、功能完整。
缺点：内存占用大（>500MB 镜像）、冷启动慢（>2s），无法在浏览器或边缘运行。

**LangGraph (https://github.com/langchain-ai/langgraph)**

LangGraph 是 LangChain 的扩展，引入了状态机模型来表达多轮对话和条件分支。其核心抽象是 `StateGraph`，节点是 Python 函数，边是状态转换规则。

优点：状态机抽象表达力强，适合复杂对话流。
缺点：同样基于 Python，性能受限。

**OpenClaw (参考)**
OpenClaw 是一个新兴的开源项目，旨在实现"AI Agent 操作桌面应用"。其核心思路是：
- 通过平台特定的 accessibility API 感知桌面状态（Windows: UI Automation, macOS: AX API）
- 通过模拟输入事件操控应用
- 使用 OCR/Vision 感知执行结果

本项目在场景 C 中借鉴了这一思路，但实现上会有差异（基于 Wasm + WASI 而非原生进程）。

**fastcc (https://github.com/moonbit-community/fastcc)**

fastcc 是使用 MoonBit 从零构建的 C 编译器，在 M2 Mac 上编译 138K LOC 的 C 代码仅需 0.425s。其代码组织结构对本项目有直接参考价值：

```
fastcc/
  src/
  parse/      # 词法/语法分析
  sem/        # 语义分析
  codegen/    # 指令生成
  refs/       # 参照实现（tinycc）
```

本项目将采用类似的多模块结构：`moonagent-core/scheduler`、`moonagent-core/state`、`moonagent-wasi/bridge` 等。

**wasmoon (https://github.com/Milily2018/wasmoon)**

wasmoon 是使用 MoonBit 构建的 WebAssembly 运行时，支持 JIT 编译。其架构分为三层：

- **IR 层**：SSA 形式的中间表示
- **VCode 层**：体系结构相关的指令选择
- **MC 层**：机器码生成

本项目的 WASI 沙箱可借鉴 wasmoon 的 JIT 优化技术，对热点节点代码进行 JIT 编译，避免解释执行的性能损失。

### 对相关技术现状的理解与参考情况

**Agent 框架的演进方向**

从 Dify 和 LangGraph 的发展轨迹来看，Agent 框架正在向两个方向分化：

1. **平台化方向**：追求功能完整性，支持复杂的知识库、向量检索、多 Agent 协作。代表是 Dify。
2. **轻量化方向**：追求极致的边缘部署能力和执行效率。代表是受到 WebAssembly 启发的新兴项目。

MoonAgent 属于后者。其核心假设是：当 Agent 框架的部署从"服务器"扩展到"边缘设备"和"浏览器"时，Python 的运行时模型将遇到根本性障碍，而 MoonBit/Wasm 的组合能填补这一空白。

**MoonBit 在复杂系统上的验证**

fastcc 和 wasmoon 已经证明 MoonBit 能够构建编译器（138K LOC）和运行时（JIT）这类复杂系统。本项目如果成功，将进一步证明 MoonBit 在应用层框架上的可行性。

**技术就绪度评估**

| 技术 | 就绪度 | 说明 |
|------|--------|------|
| MoonBit 语言基础 | 高 | nightly build 可用，语法稳定 |
| MoonBit -> Wasm | 高 | `moon build --target wasm` 稳定 |
| WASI Preview 1 | 高 | Wasmtime 支持完善 |
| wasmoon JIT | 中 | 活跃开发，但基本功能可用 |
| MoonBit async/await | 中 | 文档有限，需要参考源码 |
| 自定义 WASI host function | 低 | 需要较多踩坑实践 |

基于上述评估，P0 阶段的技术风险可控，P2 阶段有一定不确定性，但不影响核心验证目标。
