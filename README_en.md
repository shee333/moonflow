# MoonAgent: AI Agent Orchestration Engine Based on MoonBit

[English](README_en.md) | [简体中文](README.md)

## Project Overview

MoonAgent is an AI agent orchestration engine based on MoonBit language and WebAssembly, designed to verify the feasibility of MoonBit in agent orchestration scenarios and produce a runnable reference implementation.

### Core Features

- 🚀 **Extreme Performance**: Millisecond-level cold start (<10ms) based on WebAssembly
- 📦 **Minimal Size**: Wasm artifacts less than 500KB (including built-in nodes)
- 🔒 **Secure Sandbox**: WASI-based security isolation mechanism
- ⚡ **Parallel Execution**: DAG execution engine supporting multi-node parallel scheduling
- 🎯 **Cross-Platform**: Can run in various environments like Wasmtime, Deno, and browsers

## Tech Stack

```
┌─────────────────────────────────────────────┐
│  Presentation Layer (Web UI)                │
│  React 18 + X6 Flowchart + Tailwind CSS     │
├─────────────────────────────────────────────┤
│  Interface Layer (REST API)                 │
│  Axum (Rust) or Actix-web                  │
├─────────────────────────────────────────────┤
│  Logic Layer (MoonAgent Engine)             │
│  MoonBit / Wasm DAG Scheduler               │
├─────────────────────────────────────────────┤
│  Resource Layer (WASI Runtime)             │
│  Wasmtime or wasmoon                        │
└─────────────────────────────────────────────┘
```

## Directory Structure

```
moonbit/
├── src/                    # MoonBit source code
│   ├── core/              # Core engine
│   ├── dsl/               # DSL parser
│   ├── nodes/             # Built-in node library
│   └── cli/               # CLI tools
├── demo/                  # Examples and demos
├── docs/                  # Project documentation
├── tests/                 # Test code
├── configs/               # Configuration files
├── scripts/               # Utility scripts
└── README.md
```

## Quick Start

### Requirements

- MoonBit SDK (nightly build)
- Wasmtime or other WASI runtime
- Node.js 18+ (for Web UI)

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/moonagent.git
cd moonagent

# Install MoonBit dependencies (if needed)
moon install

# Run demo
moon run demo/moonagent_demo.mbt
```

### Using CLI

```bash
# Run workflow
moonagent run ./workflow.json

# View logs
moonagent log <workflow-id>
```

## Core Modules

| Module | Description |
|--------|------------|
| moonagent-core | DAG scheduler, state management, retry strategy |
| moonagent-dsl | JSON Schema parser, DSL validation |
| moonagent-wasi | WASI host function wrapper |
| moonagent-nodes | Built-in node implementations |
| moonagent-cli | Command line tools |

## Application Scenarios

- **Scheduled Data Collection & Push**: HTTP GET -> JSON parsing -> Template rendering -> SMTP sending
- **CSV/Excel Batch Processing**: Data cleaning, aggregation, file generation
- **Desktop Application Automation**: Screenshots, OCR, mouse/keyboard control
- **LLM-driven Conversational Agent**: Intent recognition, multi-branch routing, streaming output

## Performance Comparison

| Metric | MoonAgent (Wasm) | Dify (Python) | Improvement |
|--------|-----------------|--------------|-------------|
| Cold Start Time | <10ms | ~200ms | 20x |
| Memory Usage | ~2MB | ~120MB | 60x |

## Development Guide

### Build

```bash
moon build --target wasm
```

### Test

```bash
moon test
```

### Code Standards

Follow MoonBit official code style, use `moon check` for type checking.

## Related Projects

- [fastcc](https://github.com/moonbit-community/fastcc) - MoonBit C Compiler
- [wasmoon](https://github.com/Milily2018/wasmoon) - MoonBit WebAssembly Runtime
- [Dify](https://github.com/langgenius/dify) - Open Source Agent Orchestration Platform
- [LangGraph](https://github.com/langchain-ai/langgraph) - State Machine-based Agent Framework

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Contributing

Issues and Pull Requests are welcome!

## Contact

- Project Home: https://github.com/yourusername/moonagent
- Issue Tracker: https://github.com/yourusername/moonagent/issues
