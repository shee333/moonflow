# MoonFlow - 基于 MoonBit 的 AI Agent 工作流编排平台

<p align="center">
  <img src="https://img.shields.io/badge/MoonBit-0.8.0-blue" alt="MoonBit">
  <img src="https://img.shields.io/badge/React-19.0.0-61dafb" alt="React">
  <img src="https://img.shields.io/badge/TypeScript-5.0-3178c6" alt="TypeScript">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
</p>

> 🌙 MoonFlow 是一个类似 Dify/Coze 的 AI Agent 工作流编排平台，支持可视化编排和 MoonBit DSL 代码生成。

## 📁 项目结构

```
moonflow/                           # 统一的工作目录
├── core/                           # MoonBit 后端运行时
│   ├── src/
│   │   ├── components/            # 工作流组件库 (30+ 组件)
│   │   ├── runtime/               # 执行引擎和调度器
│   │   ├── workflow/              # 工作流解析和验证
│   │   └── demo/                  # 示例代码
│   ├── examples/                   # MoonBit DSL 示例
│   ├── tests/                     # 测试用例
│   └── moon.mod.json              # MoonBit 模块配置
│
├── frontend/                       # React 前端
│   ├── src/
│   │   ├── components/             # React 组件
│   │   ├── context/               # React Context
│   │   ├── hooks/                 # 自定义 Hooks
│   │   ├── utils/                # 工具函数
│   │   └── test/                  # 测试用例
│   ├── examples/                  # 工作流示例 JSON
│   └── public/                    # 静态资源
│
├── docs/                          # 项目文档
└── README.md                      # 本文件
```

## 🚀 快速开始

### 1. 启动前端

```bash
# 进入前端目录
cd frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 访问 http://localhost:5173
```

### 2. 编译后端 (可选)

```bash
# 进入后端目录
cd core

# 编译项目
moon run moonflow_core

# 运行测试
moon test

# 构建发布版本
moon build
```

## 🎯 核心功能

### 1. 可视化工作流编排
- 🎨 Drag & Drop 节点编辑
- 🔗 节点连线配置
- 📋 实时预览生成的代码
- 🎭 主题切换（明/暗模式）

### 2. LLM 集成
- 🤖 **OpenAI** - GPT-3.5/GPT-4
- 🦙 **Claude** - Claude 3/4
- ✨ **Gemini** - Gemini Pro
- 🔄 多模型组合使用

### 3. 组件库 (30+)
- **触发器**: HTTP、Webhook、Cron、Timer
- **处理器**: LLM、代码执行、模板渲染
- **逻辑**: 条件分支、循环、并行、串行
- **工具**: HTTP 请求、数据库、文件操作、邮件、通知
- **高级**: 重试、断路器、限流、缓存、熔断

### 4. 代码生成
- 📝 MoonBit DSL 代码生成
- ✅ 语法验证
- 🎯 类型检查
- 💡 代码提示

## 📖 使用文档

### 示例工作流

我们提供了多种预构建的工作流示例：

#### 1. 基础聊天机器人
- 📁 `frontend/examples/llm-chatbot.json`
- 简单的LLM调用流程

#### 2. HTTP + LLM 工作流
- 📁 `frontend/examples/http-llm-workflow.json`
- HTTP触发 → LLM处理 → 响应

#### 3. LLM Agent
- 📁 `frontend/examples/llm-agent.json`
- 带内存和工具调用的Agent

#### 4. RAG Chatbot
- 📁 `frontend/examples/rag-workflow.json`
- 检索增强生成聊天机器人

#### 5. Agent Planning Workflow
- 📁 `frontend/examples/agent-planning-workflow.json`
- 多步骤任务分解和执行

#### 6. Batch Data Processing
- 📁 `frontend/examples/data-pipeline-workflow.json`
- 大规模数据批量处理

### 使用示例工作流

1. 打开 MoonFlow Studio
2. 点击"导入"按钮
3. 选择示例JSON文件
4. 根据需要修改节点配置
5. 生成MoonBit代码或直接运行

### 创建第一个工作流

1. **添加触发器**
   - 从左侧面板拖拽 "HTTP 触发器" 到画布
   - 配置端点路径和方法

2. **添加 LLM 节点**
   - 拖拽 "LLM 处理器" 到画布
   - 选择提供商（OpenAI/Claude/Gemini）
   - 配置模型和提示词

3. **连接节点**
   - 从触发器的输出拖拽到 LLM 的输入
   - 从 LLM 的输出拖拽到响应节点

4. **测试运行**
   - 点击 "▶️ 运行" 按钮
   - 在日志面板查看执行结果

5. **导出代码**
   - 点击 "📋 复制代码" 获取 MoonBit DSL
   - 或点击 "💾 导出" 保存为 JSON

### LLM 测试工具

1. 点击工具栏的 "🤖 LLM 测试" 按钮
2. 选择提供商并配置：
   - API Key
   - 模型选择
   - Temperature
   - Max Tokens
3. 输入系统提示词和用户提示词
4. 点击 "发送测试" 查看结果
5. 测试通过后，点击 "插入到工作流" 添加节点

## 🔧 技术栈

### 前端 (frontend/)
- **框架**: React 19 + TypeScript 5
- **构建工具**: Vite 5
- **工作流可视化**: @xyflow/react (React Flow)
- **状态管理**: React Context + Hooks
- **样式**: CSS Modules + CSS Variables
- **测试**: Vitest

### 后端 (core/) - MoonBit
- **语言**: MoonBit
- **模块管理**: MoonBit Package Manager
- **执行引擎**: 自定义运行时
- **组件库**: 30+ 内置组件

## 📦 示例工作流

### 1. 基础聊天机器人
```
HTTP Trigger → LLM Processor → Response
```
[查看示例](./frontend/examples/llm-chatbot.json)

### 2. 条件分支
```
HTTP Trigger → Condition Router
              ├─→ Urgent Handler → Email Notification → Response
              └─→ Normal Handler → Response
```
[查看示例](./frontend/examples/conditional-response.json)

### 3. 多步数据分析
```
HTTP Trigger → LLM (提取信息) → LLM (分析) → LLM (总结) → Response
```
[查看示例](./frontend/examples/multi-step-analysis.json)

### 4. Agent 工作流
```
HTTP Trigger → LLM (规划) → Condition Router
                           ├─→ Web Search → LLM (总结) → Response
                           ├─→ Database Query → LLM (格式化) → Response
                           └─→ Code Execution → Response
```
[查看示例](./frontend/examples/llm-agent.json)

## 🛠️ 开发指南

### 前端开发

```bash
# 代码检查
cd frontend
npm run lint

# 类型检查
npm run typecheck

# 运行测试
npm test

# 构建生产版本
npm run build
```

### 后端开发 (MoonBit)

```bash
# 进入后端目录
cd core

# 查看所有组件
cat COMPONENTS.md

# 运行示例
moon run moonflow_core

# 添加新组件
# 1. 在 src/components/ 下创建新文件
# 2. 注册到 component.mbt
# 3. 更新 COMPONENTS.md
```

### 添加新组件

1. 创建组件文件 `src/components/my_component.mbt`:
```moonbit
pub struct MyComponent {
  pub config: MyConfig
}

impl Component for MyComponent {
  fn execute(ctx: Context) -> Unit {
    // 实现逻辑
  }
}
```

2. 在 `component.mbt` 中注册:
```moonbit
pub fn register_components() {
  Registry::register("my_component", MyComponent::new);
}
```

3. 在前端 `frontend/src/utils/codeGenerator.ts` 中添加节点定义

## 📊 工作流执行流程

```
用户请求
   ↓
触发器接收
   ↓
构建执行顺序 (拓扑排序)
   ↓
执行节点 (按顺序)
   ├─ 准备输入
   ├─ 执行逻辑
   └─ 保存输出
   ↓
条件判断/循环
   ↓
返回结果
   ↓
日志记录
```

## 📝 文档

- [组件文档](./core/COMPONENTS.md) - 所有组件的详细说明
- [快速开始](./core/QUICKSTART.md) - MoonBit 后端快速开始
- [代理说明](./core/AGENTS.md) - Agent 架构说明
- [项目进度](./core/PROGRESS.md) - 开发进度跟踪
- [MoonBit 语法](./core/README.mbt.md) - MoonBit 语言参考


