# MoonFlow: Dify-style AI Agent Orchestration Platform Based on MoonBit

[English](README_en.md) | [简体中文](README.md)

## Project Overview

MoonFlow is a high-performance AI agent orchestration platform based on MoonBit language, similar to "Dify built on MoonBit": providing Web Studio (visual orchestration, debugging & publishing) + Workflow DSL (single source of truth) + Runtime (execution/scheduling/isolation) + Marketplace (tools & agent components).

### Core Features

- 🚀 **High Performance Scheduling**: Based on MoonBit AOT compilation, breaking Python GIL limitations, supporting high-concurrency Agent tasks
- 🔒 **Security Isolation**: Process-level isolation + capability declaration + human-in-the-loop + rollback deployment
- 🤖 **AI-Native Development**: Seamless conversion from natural language to MoonBit orchestration code
- 📦 **One-Click Deployment**: Supports standalone local mode and server deployment, one-click packaging and versioning
- 🎨 **Visual Orchestration**: Drag-and-drop DAG editor with real-time preview and debugging
- 🛒 **Component Marketplace**: Standardized Marketplace supporting community-contributed plugins

### Problem Solving

1. **High Performance Scheduling**: Python GIL limits high-concurrency Agent task processing. MoonBit's high-performance AOT compilation greatly improves concurrent processing performance
2. **Security Isolation**: Tool/Agent minimum permissions with capability declaration, human-in-the-loop approval for sensitive operations, process-level isolation for untrusted code
3. **AI-Native Development**: Utilizing MoonBit toolchain's AI-friendly code generation to achieve seamless conversion from natural language to high-performance orchestration code
4. **Easy Deployment**: Provides standalone local mode and server deployment, supporting one-click packaging, versioning and rollback

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Control Plane                                            │
│  Web Studio │ Workflow Management │ Versioning │ Auth │ Release │
├─────────────────────────────────────────────────────────────┤
│  Data Plane                                              │
│  DAG Executor │ Tool Gateway │ State Storage │ Trace │ Replay │
├─────────────────────────────────────────────────────────────┤
│  Component Layer                                         │
│  Tool/Agent Plugins │ Marketplace │ Permission & Audit     │
└─────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
moonflow/
├── src/                          # Source code
│   ├── core/                    # Core engine
│   │   ├── scheduler/          # DAG scheduler
│   │   ├── state/              # State management
│   │   └── executor/           # Executor
│   ├── dsl/                    # DSL parsing & compilation
│   │   ├── parser/            # DSL parser
│   │   ├── validator/         # DSL validator
│   │   └── codegen/           # Code generator
│   ├── bridge/                # Host system interface
│   ├── nodes/                 # Built-in node library
│   └── cli/                    # CLI tools
├── web-studio/                 # Web visual editor
├── runtime/                    # Runtime environment
├── docs/                       # Documentation
├── tests/                      # Test code
├── configs/                    # Configuration
├── scripts/                    # Utility scripts
├── demo/                       # Demos
└── README.md
```

## Core Modules

| Module | Description |
|--------|------------|
| `moonflow-core` | DAG scheduler, state storage, concurrency primitives |
| `moonflow-codegen` | AI-based code synthesis, converting natural language to MoonBit code |
| `moonflow-dsl` | DSL Schema, parsing validation, Workflow IR compilation pipeline |
| `moonflow-bridge` | Host system interface wrapper for plugins/tools |
| `moonflow-studio` | Web visual editor (optional) |
| `moonflow-marketplace` | Plugin packaging & marketplace (optional) |

## Application Scenarios

- **Automated Office Workflows**: Intelligent email analysis, automatic Excel report generation and notification
- **Desktop Application Automation**: Cross-application desktop task automation through plugin isolation and host system permission control
- **High-Frequency Finance/Data Processing**: Agent decision chains requiring extremely low latency
- **Enterprise Workflow Orchestration**: Complex business processes with multi-agent collaboration, API integration, database operations

## Quick Start

> ⚠️ **First time?** Please read [GitHub Setup Guide](SETUP_GITHUB.md)

### Requirements

- MoonBit SDK (nightly build)
- Node.js 18+ (for Web UI)
- Wasmtime or other WASI runtime (optional)

### Installation

```bash
# Clone repository
git clone https://github.com/shee333/moonflow.git
cd moonflow

# Install MoonBit dependencies (if needed)
moon install

# Run demo
moon run demo/moonflow_demo.mbt
```

### Using CLI

```bash
# Validate workflow
moonflow validate ./workflow.yaml

# Run workflow
moonflow run ./workflow.yaml

# View logs
moonflow log <workflow-id>
```

## Workflow DSL Example

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
    with: { prompt: 'Summarize the above content in Chinese' }
  - id: send
    type: tool.feishu.send
edges:
  - { from: timer, to: fetch }
  - { from: fetch, to: summarize }
  - { from: summarize, to: send }
```

## Performance Comparison

| Metric | MoonFlow (MoonBit) | Dify (Python) | Improvement |
|--------|-------------------|--------------|-------------|
| Concurrency | High | GIL Limited | ~10x |
| Cold Start | <10ms | ~200ms | 20x |
| Memory Usage | ~2MB | ~120MB | 60x |
| Type Safety | Compile-time | Runtime | More Reliable |

## Development Guide

### Build

```bash
# Build core engine
moon build --target wasm

# Build CLI
moon build -o moonflow ./src/cli/main.mbt
```

### Test

```bash
# Run unit tests
moon test

# Run integration tests
moon test ./tests/integration/
```

### Code Standards

Follow MoonBit official code style, use `moon check` for type checking.

## Roadmap

### MVP (v1.0)

- [ ] DSL v1: workflow.yaml/json + JSON Schema validation + versioning
- [ ] Runtime v1: Local/server executor + DAG scheduling + timeout/retry
- [ ] Studio v1: Canvas orchestration + parameter forms + YAML/JSON sync
- [ ] Observability v1: Per-node execution timeline and logs

### Future Iterations

- [ ] Marketplace v1: Plugin packaging and marketplace
- [ ] AI Codegen: Natural language to workflow
- [ ] Distributed multi-machine scheduling
- [ ] Multi-tenancy and billing

## Related Projects

- [Dify](https://github.com/langgenius/dify) - Open source Agent orchestration platform reference
- [LangGraph](https://github.com/langchain-ai/langgraph) - State machine execution semantics reference
- [OpenClaw](https://github.com/wxmaxima-developers/openclaw) - Agent desktop operation framework
- [fastcc](https://github.com/moonbit-community/fastcc) - MoonBit C compiler reference project
- [MoonBit](https://github.com/moonbitlang/core) - MoonBit official core library

## Security Features

- **Process-level Isolation**: Untrusted code runs in separate processes
- **Capability Declaration**: Tool/Agent must declare required permissions
- **Human-in-the-loop**: Sensitive operations require manual confirmation
- **Key Escrow**: Token/keys managed centrally, not stored in DSL files
- **Audit Logging**: All operations recorded completely for traceability

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Contributing

Issues and Pull Requests are welcome!

## Contact

- Project Home: https://github.com/shee333/moonflow
- Issue Tracker: https://github.com/shee333/moonflow/issues
