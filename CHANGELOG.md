# MoonFlow 变更日志

所有重要的项目变更都将记录在此文件中。格式遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/) 规范。

---

## [Unreleased]

### Added

- 项目缺失清单 (`PROJECT_GAPS.md`)
- CONTRIBUTING.md 贡献指南
- DEPLOYMENT.md 部署文档
- GitHub Actions CI/CD 工作流配置
- 前端单元测试 (30+ 测试用例)

### Changed

- 优化前端代码质量和类型定义
- 增强 HTTP 组件功能（添加 PATCH 方法、URL 验证）
- 优化 Email 和 Feishu 组件（添加格式验证）
- 修复 React Hooks lint 警告

### Fixed

- 前端 lint 错误（105 个错误 → 0 错误）

---

## [0.1.0] - 2026-04-02

### Added

#### 核心功能

- ✅ 核心数据类型定义 (`types.mbt`)
  - 节点类型枚举（Trigger, Tool, Agent, Control）
  - 工作流数据结构
  - 执行上下文
  - 重试配置

- ✅ 工作流解析器 (`parser.mbt`)
  - JSON 格式支持
  - YAML 格式支持
  - 元数据解析
  - 嵌套对象解析

- ✅ 工作流验证器 (`validator.mbt`)
  - 节点 ID 唯一性检查
  - 边引用有效性检查
  - 节点类型检查
  - 必填字段检查
  - 循环依赖检测

- ✅ DAG 调度引擎 (`scheduler.mbt`)
  - 图构建
  - 拓扑排序（Kahn 算法）
  - 就绪节点检测
  - 并发控制

- ✅ 节点执行器 (`executor.mbt`)
  - 触发器执行器
  - 工具执行器
  - 代理执行器
  - 控制流执行器

#### 组件库 (40+ 组件)

- **触发器**: Timer, Webhook, Manual, HTTP
- **工具**: HTTP 请求, 邮件, 飞书, 文件操作, 数据库
- **代理**: LLM, 意图识别
- **逻辑**: 条件分支, 并行, 循环, 结束
- **高级**: 重试, 断路器, 限流, 缓存, 熔断

#### 前端 (React)

- ✅ 可视化工作流编辑器
- ✅ Drag & Drop 节点编辑
- ✅ 节点连线配置
- ✅ 实时代码预览
- ✅ 主题切换（明/暗）
- ✅ LLM 测试工具
- ✅ 工作流导入/导出
- ✅ 节点验证显示

#### 文档

- ✅ README.md 项目说明
- ✅ COMPONENTS.md 组件文档
- ✅ PROGRESS.md 开发进度
- ✅ DSL_SPEC.md DSL 规范
- ✅ SECURITY.md 安全设计
- ✅ SETUP_GITHUB.md GitHub 设置

#### 示例工作流

- ✅ llm-chatbot.json - 基础聊天机器人
- ✅ http-llm-workflow.json - HTTP + LLM 工作流
- ✅ llm-agent.json - LLM Agent
- ✅ rag-workflow.json - RAG Chatbot
- ✅ agent-planning-workflow.json - Agent 规划
- ✅ data-pipeline-workflow.json - 数据管道
- ✅ conditional-response.json - 条件分支
- ✅ notification-workflow.json - 通知工作流

#### 测试

- ✅ MoonBit 单元测试 (5 个测试)
- ✅ 前端 Vitest 测试 (30 个测试)
- ✅ 代码生成器测试
- ✅ 工作流导入导出测试

#### CI/CD

- ✅ GitHub Actions CI 工作流
- ✅ GitHub Actions Release 工作流

### Changed

#### 代码质量提升

- 前端: TypeScript 严格模式
- 后端: MoonBit 类型系统
- 统一代码风格和命名规范

#### 组件优化

- HTTP: 支持多种 HTTP 方法
- Email: SMTP 支持
- Feishu: Webhook 通知
- LLM: 多模型支持框架

#### 性能优化

- DAG 调度: 并行执行优化
- 前端: React Flow 性能优化
- 缓存机制: 结果缓存

### Fixed

- 工作流验证器循环依赖检测
- 节点执行超时处理
- 错误类型定义
- 类型转换问题

### Deprecated

- ~~YAML 解析器部分功能~~ (2026-Q3 移除)

### Removed

- 旧版 JSON Schema 验证 (替换为新的验证器)

---

## [0.0.1] - 2026-03-31

### Added

- MoonFlow 项目初始化
- 基础项目结构
- MoonBit 后端框架
- React 前端框架
- 基础组件占位符
- 项目文档框架

---

## 即将发布

### [0.2.0] - 计划中 (2026-Q2)

#### 计划功能

- [ ] 真实 LLM 集成
  - OpenAI GPT-4 支持
  - Anthropic Claude 支持
  - Google Gemini 支持
  - 流式响应

- [ ] CLI 工具
  - `moonflow run` 运行工作流
  - `moonflow validate` 验证工作流
  - `moonflow deploy` 部署工作流
  - `moonflow secret` 密钥管理

- [ ] 工作流版本管理
  - 版本历史
  - 回滚功能
  - 发布管理

- [ ] 国际化
  - English 支持
  - 日本語 支持
  - 语言切换器

### [0.3.0] - 计划中 (2026-Q3)

#### 计划功能

- [ ] 分布式调度
  - 多节点协调
  - 分布式锁
  - 状态同步

- [ ] 组件市场
  - 组件发布
  - 版本管理
  - 搜索浏览

- [ ] 自然语言生成工作流
  - AI Codegen
  - 自然语言查询

### [1.0.0] - 计划中 (2026-Q4)

#### 目标功能

- [ ] 生产就绪
- [ ] 多租户支持
- [ ] 计费系统
- [ ] 企业级功能

---

## 贡献者

[感谢所有贡献者](https://github.com/shee333/moonflow/graphs/contributors)

---

## 版本策略

我们遵循[语义化版本](https://semver.org/lang/zh-CN/)：

- **MAJOR** 版本: 破坏性更改
- **MINOR** 版本: 新功能（向后兼容）
- **PATCH** 版本: Bug 修复（向后兼容）

### 发布周期

- **MAJOR**: 每年 1-2 次
- **MINOR**: 每季度 1 次
- **PATCH**: 按需发布（Bug 修复）

---

## 升级指南

### 从 v0.0.x 升级到 v0.1.0

**Breaking Changes**:

1. 工作流 JSON 格式略有调整
   ```json
   // 旧格式
   { "type": "trigger", "trigger_type": "http" }
   
   // 新格式
   { "type": "trigger.http" }
   ```

2. 配置项路径变更
   ```yaml
   # 旧路径
   config.retry.max_attempts
   
   # 新路径
   config.retry.max
   ```

**升级步骤**:

```bash
# 1. 拉取最新代码
git pull upstream master

# 2. 更新依赖
cd frontend && npm update
cd core && moon update

# 3. 迁移工作流
# 使用迁移工具或手动更新格式

# 4. 验证
moon test
npm test
```

---

## 更多信息

- [项目进度](core/PROGRESS.md)
- [项目缺失清单](PROJECT_GAPS.md)
- [贡献指南](CONTRIBUTING.md)
- [部署指南](DEPLOYMENT.md)

---

**维护者**: MoonFlow Team  
**许可证**: MIT  
**最后更新**: 2026-04-02
