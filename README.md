# MoonAgent: 基于 MoonBit 的 AI 智能体编排引擎

[English](README_en.md) | 简体中文

## 项目简介

MoonAgent 是一个基于 MoonBit 语言和 WebAssembly 的 AI 智能体编排引擎，旨在验证 MoonBit 在 Agent 编排场景下的可行性，并产出可运行的参考实现。

### 核心特性

- 🚀 **极致性能**：基于 WebAssembly 的毫秒级冷启动（<10ms）
- 📦 **极小体积**：Wasm 产物小于 500KB（包含内置节点）
- 🔒 **安全沙箱**：基于 WASI 接口的安全隔离机制
- ⚡ **并行执行**：支持多节点并行调度的 DAG 执行引擎
- 🎯 **跨平台**：可在 Wasmtime、Deno、浏览器等多种环境运行

## 技术架构

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

## 目录结构

```
moonbit/
├── src/                    # MoonBit 源代码
│   ├── core/              # 核心引擎
│   ├── dsl/               # DSL 解析器
│   ├── nodes/             # 内置节点库
│   └── cli/               # 命令行工具
├── demo/                  # 示例和演示
├── docs/                  # 项目文档
├── tests/                 # 测试代码
├── configs/               # 配置文件
├── scripts/               # 工具脚本
└── README.md
```

## 快速开始

### 环境要求

- MoonBit SDK (nightly build)
- Wasmtime 或其他 WASI 运行时
- Node.js 18+ (用于 Web UI)

### 安装

```bash
# 克隆仓库
git clone https://github.com/yourusername/moonagent.git
cd moonagent

# 安装 MoonBit 依赖 (如果需要)
moon install

# 运行演示
moon run demo/moonagent_demo.mbt
```

### 使用 CLI

```bash
# 运行工作流
moonagent run ./workflow.json

# 查看日志
moonagent log <workflow-id>
```

## 核心模块

| 模块 | 描述 |
|------|------|
| moonagent-core | DAG 调度器、状态管理、重试策略 |
| moonagent-dsl | JSON Schema 解析、DSL 验证 |
| moonagent-wasi | WASI host function 封装 |
| moonagent-nodes | 内置节点实现 |
| moonagent-cli | 命令行工具 |

## 应用场景

- **定时数据采集与推送**：HTTP GET -> JSON 解析 -> 模板渲染 -> SMTP 发送
- **CSV/Excel 批处理**：数据清洗、聚合计算、文件生成
- **桌面应用自动化**：截图、OCR、鼠标键盘控制
- **LLM 驱动的对话 Agent**：意图识别、多分支路由、流式输出

## 性能对比

| 指标 | MoonAgent (Wasm) | Dify (Python) | 提升 |
|------|-----------------|--------------|------|
| 冷启动时间 | <10ms | ~200ms | 20x |
| 内存占用 | ~2MB | ~120MB | 60x |

## 开发指南

### 编译

```bash
moon build --target wasm
```

### 测试

```bash
moon test
```

### 代码规范

遵循 MoonBit 官方代码风格，使用 `moon check` 进行类型检查。

## 相关项目

- [fastcc](https://github.com/moonbit-community/fastcc) - MoonBit C 编译器
- [wasmoon](https://github.com/Milily2018/wasmoon) - MoonBit WebAssembly 运行时
- [Dify](https://github.com/langgenius/dify) - 开源 Agent 编排平台
- [LangGraph](https://github.com/langchain-ai/langgraph) - 基于状态机的 Agent 框架

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 贡献指南

欢迎提交 Issue 和 Pull Request！

## 联系方式

- 项目主页：https://github.com/yourusername/moonagent
- 问题反馈：https://github.com/yourusername/moonagent/issues
