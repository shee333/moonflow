# MoonFlow Web UI

MoonFlow Studio 是一个基于 Web 的可视化工作流编辑器，用于创建和管理 AI 智能体工作流。

## 技术栈

- **React 19** - 前端框架
- **TypeScript** - 类型安全
- **Vite 5.4** - 快速构建工具
- **ReactFlow (@xyflow/react)** - DAG 可视化编辑器
- **Monaco Editor** - 强大的代码编辑器

## 功能特性

### DAG 可视化编辑器
- 拖拽式节点创建
- 节点连接和边管理
- 节点选择和属性查看
- 缩放和导航控制
- MiniMap 概览

### 组件库
预置丰富的组件，包括：
- **触发器**: HTTP Trigger, Timer, Cron
- **处理器**: LLM Processor, Filter, Transform, Aggregator
- **存储**: Database, File Operations
- **消息**: Queue, Router
- **通知**: Email, Logger

### 交互功能
- 点击节点查看详情
- 从组件面板添加新节点
- 连接节点创建工作流
- 平移和缩放画布

## 快速开始

### 安装依赖

```bash
npm install
```

### 开发模式

```bash
npm run dev
```

访问 http://localhost:5173/

### 构建生产版本

```bash
npm run build
```

### 预览生产版本

```bash
npm run preview
```

## 项目结构

```
moonflow_web/
├── src/
│   ├── components/
│   │   ├── DAGEditor.tsx          # DAG 可视化编辑器主组件
│   │   ├── MoonFlowNode.tsx       # 自定义节点组件
│   │   ├── ComponentPalette.tsx    # 组件选择面板
│   │   └── types.ts               # TypeScript 类型定义
│   ├── App.tsx                     # 应用主组件
│   ├── App.css                     # 应用样式
│   ├── index.css                   # 全局样式
│   └── main.tsx                    # 入口文件
├── public/                         # 静态资源
├── index.html                      # HTML 模板
├── package.json                    # 依赖配置
├── vite.config.ts                 # Vite 配置
├── tsconfig.json                  # TypeScript 配置
└── README.md                       # 项目文档
```

## 使用说明

### 添加节点
1. 在左侧面板中浏览组件分类
2. 点击要添加的组件
3. 节点会自动添加到画布中央

### 连接节点
1. 将鼠标悬停在节点底部的手柄上
2. 拖动到目标节点的顶部手柄
3. 释放鼠标建立连接

### 查看节点属性
1. 点击画布上的任意节点
2. 右侧面板会显示节点详情
3. 显示组件类型、标签和描述

### 编辑画布
- **缩放**: 鼠标滚轮
- **平移**: 拖动画布空白区域
- **选中**: 点击节点
- **删除**: 选择后按 Delete 键

## 未来计划

- [ ] 集成 MoonPad 代码编辑器
- [ ] 工作流执行和控制面板
- [ ] 拖拽式节点创建
- [ ] 工作流导入/导出
- [ ] 与 MoonFlow Core 引擎集成
- [ ] 实时协作编辑
- [ ] 工作流版本管理
- [ ] 组件配置面板

## 与 MoonFlow Core 集成

MoonFlow Web UI 将与 [MoonFlow Core](../moonflow_core/) 引擎集成，提供：

- 可视化工作流设计
- 代码生成（导出为 MoonBit 代码）
- 工作流执行
- 运行时监控

## 开发指南

### 添加新组件
在 `src/components/types.ts` 中定义组件类型：

```typescript
export interface ComponentType {
  type: string;
  label: string;
  description: string;
  category: string;
}
```

在 `src/components/ComponentPalette.tsx` 中添加组件到列表。

### 自定义节点样式
在 `src/components/MoonFlowNode.tsx` 中修改节点外观。

## 许可证

MIT License
