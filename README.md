# MoonFlow: 基于 MoonBit 的 Dify 式 AI 智能体编排平台

简体中文

## 项目简介

MoonFlow 是一个基于 MoonBit 语言的高性能 AI 智能体编排平台，产品形态更接近"基于 MoonBit 的 Dify"：提供 Web Studio（可视化编排、调试与发布）+ Workflow DSL（事实来源）+ Runtime（执行/调度/隔离）+ Marketplace（工具与 Agent 组件）。

### 核心特性

- 🚀 **高性能调度**：基于 MoonBit AOT 编译，突破 Python GIL 限制，支持高并发 Agent 任务
- 🔒 **隔离安全性**：进程级隔离 + 能力声明 + 人在回路门禁 + 可回滚发布
- 🤖 **AI 原生开发**：自然语言到 MoonBit 编排代码的无缝转换
- 📦 **一键部署**：支持单机本地模式与服务端部署，一键打包与版本化
- 🎨 **可视化编排**：拖拽式 DAG 编辑器，实时预览与调试
- 🛒 **组件市场**：标准化的 Marketplace，支持社区贡献插件

## 项目结构

MoonFlow 由多个核心模块组成：

### 🌟 moonflow_core
MoonBit 实现的工作流引擎核心，包含：
- **工作流定义**: types, parser, validator
- **运行时引擎**: executor, scheduler
- **组件库**: 40+ 预置组件（HTTP、LLM、Timer、Database 等）
- **示例**: 演示工作流和测试用例

📖 [查看 moonflow_core 详细文档](moonflow_core/README.mbt.md)

### 🎨 moonflow_web
基于 Web 的可视化工作流编辑器：
- **React 19** + TypeScript + Vite
- **ReactFlow** DAG 可视化编辑器
- **Monaco Editor** 代码编辑器
- **拖拽式** 节点创建和连接
- **实时预览** 工作流执行

📖 [查看 moonflow_web 详细文档](moonflow_web/README.md)

## 快速开始

### MoonFlow Core

```bash
cd moonflow_core
moon run src/demo/demo.mbt
```

### MoonFlow Web UI

```bash
cd moonflow_web
npm install
npm run dev
```

访问 http://localhost:5173/ 查看可视化编辑器

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 贡献指南

欢迎提交 Issue 和 Pull Request！

## 联系方式

- 项目主页：https://github.com/shee333/moonflow
- 问题反馈：https://github.com/shee333/moonflow/issues
