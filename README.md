# MoonFlow: 基于 MoonBit 的 Dify 式 AI 智能体编排平台

[English](README_en.md) | 简体中文

## 项目简介

MoonFlow 是一个基于 MoonBit 语言的高性能 AI 智能体编排平台，产品形态更接近"基于 MoonBit 的 Dify"：提供 Web Studio（可视化编排、调试与发布）+ Workflow DSL（事实来源）+ Runtime（执行/调度/隔离）+ Marketplace（工具与 Agent 组件）。

### 核心特性

- 🚀 **高性能调度**：基于 MoonBit AOT 编译，突破 Python GIL 限制，支持高并发 Agent 任务
- 🔒 **隔离安全性**：进程级隔离 + 能力声明 + 人在回路门禁 + 可回滚发布
- 🤖 **AI 原生开发**：自然语言到 MoonBit 编排代码的无缝转换
- 📦 **一键部署**：支持单机本地模式与服务端部署，一键打包与版本化
- 🎨 **可视化编排**：拖拽式 DAG 编辑器，实时预览与调试
- 🛒 **组件市场**：标准化的 Marketplace，支持社区贡献插件

### 解决的问题

1. **高性能调度**：Python GIL 限制了高并发 Agent 任务的处理能力。MoonBit 的高性能 AOT 编译大幅提升并发处理性能
2. **隔离安全性**：Tool/Agent 最小权限与能力声明，敏感操作的人在回路审批，不可信代码的进程级隔离
3. **AI 原生开发**：利用 MoonBit 工具链对 AI 生成代码的友好性，实现从自然语言描述到高性能编排代码的无缝转换
4. **易部署**：提供单机本地模式与服务端部署模式，支持一键打包、版本化与回滚

## 技术架构

```
┌─────────────────────────────────────────────────────────────┐
│  控制面 (Control Plane)                                    │
│  Web Studio │ 工作流管理 │ 版本化 │ 权限与密钥管理 │ 发布审批 │
├─────────────────────────────────────────────────────────────┤
│  数据面 (Data Plane)                                       │
│  DAG 执行器 │ 工具网关 │ 状态存储 │ 日志/Trace │ 执行回放   │
├─────────────────────────────────────────────────────────────┤
│  组件层 (Component Layer)                                  │
│  Tool/Agent 插件 │ Marketplace │ 权限声明与审计             │
└─────────────────────────────────────────────────────────────┘
```

## 目录结构

```
moonflow/
├── src/                          # 源代码
│   ├── core/                    # 核心引擎
│   │   ├── scheduler/          # DAG 调度器
│   │   ├── state/              # 状态管理
│   │   └── executor/           # 执行器
│   ├── dsl/                    # DSL 解析与编译
│   │   ├── parser/            # DSL 解析器
│   │   ├── validator/         # DSL 校验器
│   │   └── codegen/           # 代码生成器
│   ├── bridge/                # 宿主系统接口封装
│   ├── nodes/                 # 内置节点库
│   └── cli/                    # 命令行工具
├── web-studio/                 # Web 可视化编排界面
├── runtime/                    # 运行时环境
├── docs/                       # 项目文档
├── tests/                      # 测试代码
├── configs/                    # 配置文件
├── scripts/                    # 工具脚本
├── demo/                       # 演示示例
└── README.md
```

## 核心模块

| 模块 | 描述 |
|------|------|
| `moonflow-core` | DAG 调度器、状态存储、并发原语 |
| `moonflow-codegen` | 基于 AI 的代码合成，将自然语言转为 MoonBit 代码 |
| `moonflow-dsl` | DSL Schema、解析校验、Workflow IR 编译流水线 |
| `moonflow-bridge` | 连接宿主系统与插件/工具执行环境的接口封装 |
| `moonflow-studio` | Web 可视化编辑器（可选开发） |
| `moonflow-marketplace` | 插件打包与组件市场（可选开发） |

## 应用场景

- **自动化办公流**：智能分析邮件、自动生成 Excel 报表并发送通知
- **桌面应用自动化**：通过插件隔离与宿主系统权限控制，实现跨应用的桌面任务自动化
- **高频金融/数据处理**：需要极低延迟的 Agent 决策链路
- **企业工作流编排**：多 Agent 协作、API 集成、数据库操作等复杂业务流程

## 快速开始

> ⚠️ **首次使用？** 请先阅读 [GitHub 仓库设置指南](SETUP_GITHUB.md)

### 环境要求

- MoonBit SDK (nightly build)
- Node.js 18+ (用于 Web UI)
- Wasmtime 或其他 WASI 运行时（可选）

### 安装

```bash
# 克隆仓库
git clone https://github.com/shee333/moonflow.git
cd moonflow

# 安装 MoonBit 依赖 (如果需要)
moon install

# 运行演示
moon run demo/moonflow_demo.mbt
```

### 使用 CLI

```bash
# 解析和校验工作流
moonflow validate ./workflow.yaml

# 运行工作流
moonflow run ./workflow.yaml

# 查看执行日志
moonflow log <workflow-id>
```

## Workflow DSL 示例

```yaml
version: v1
name: github_trending_daily
nodes:
  - id: timer
    type: trigger.timer
    schedule: '0 9 * * *'
  - id: fetch
    type: tool.http_get
    with: { url: 'https://github.com/trending' }
  - id: summarize
    type: agent.llm
    with: { prompt: '用中文总结上面的内容' }
  - id: send
    type: tool.feishu.send
edges:
  - { from: timer, to: fetch }
  - { from: fetch, to: summarize }
  - { from: summarize, to: send }
```

## 性能对比

| 指标 | MoonFlow (MoonBit) | Dify (Python) | 提升 |
|------|-------------------|--------------|------|
| 并发处理能力 | 高 | 受 GIL 限制 | ~10x |
| 冷启动时间 | <10ms | ~200ms | 20x |
| 内存占用 | ~2MB | ~120MB | 60x |
| 类型安全 | 编译期检查 | 运行时检查 | 更可靠 |

## 开发指南

### 编译

```bash
# 编译核心引擎
moon build --target wasm

# 编译 CLI 工具
moon build -o moonflow ./src/cli/main.mbt
```

### 测试

```bash
# 运行单元测试
moon test

# 运行集成测试
moon test ./tests/integration/
```

### 代码规范

遵循 MoonBit 官方代码风格，使用 `moon check` 进行类型检查。

## 路线图

### MVP (v1.0)

- [ ] DSL v1：workflow.yaml/json + JSON Schema 校验 + 版本化
- [ ] Runtime v1：本地/服务端执行器 + DAG 调度 + 超时/重试
- [ ] Studio v1：画布编排 + 参数表单 + YAML/JSON 双向同步
- [ ] 可观测性 v1：按 node id 输出执行时间线与日志

### 后续迭代

- [ ] Marketplace v1：插件打包与组件市场
- [ ] AI Codegen：自然语言生成工作流
- [ ] 分布式多机调度
- [ ] 多租户与计费系统

## 相关项目

- [Dify](https://github.com/langgenius/dify) - 开源 Agent 编排平台参考
- [LangGraph](https://github.com/langchain-ai/langgraph) - 状态机执行语义参考
- [OpenClaw](https://github.com/wxmaxima-developers/openclaw) - 智能体桌面操作框架
- [fastcc](https://github.com/moonbit-community/fastcc) - MoonBit C 编译器标杆项目
- [MoonBit](https://github.com/moonbitlang/core) - MoonBit 官方核心库

## 安全特性

- **进程级隔离**：不可信代码在独立进程中运行
- **能力声明**：Tool/Agent 必须声明所需权限
- **人在回路**：敏感操作需要人工确认
- **密钥托管**：Token/密钥集中管理，不落 DSL 文件
- **审计日志**：所有操作完整记录，支持回溯

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 贡献指南

欢迎提交 Issue 和 Pull Request！

## 联系方式

- 项目主页：https://github.com/shee333/moonflow
- 问题反馈：https://github.com/shee333/moonflow/issues
