# 工作流示例说明

本目录包含 MoonFlow 的示例工作流，可用于学习和测试平台功能。

## 示例列表

### 1. Basic LLM Chatbot (basic-llm-chatbot.json)
最简单的 LLM 聊天机器人示例。
- **用途**: 学习 LLM 节点的基本使用
- **节点**: HTTP Trigger → LLM Processor → Response
- **特点**: 
  - 使用 OpenAI GPT-3.5-turbo
  - 包含系统提示词和用户提示词配置
  - 支持温度和最大令牌数调节

### 2. Conditional Response (conditional-response.json)
条件分支工作流示例。
- **用途**: 了解条件判断和分支逻辑
- **节点**: Trigger → Condition → (Urgent/Normal Handler) → Response
- **特点**:
  - 实现条件分支逻辑
  - 根据条件选择不同的处理路径
  - 演示并行分支处理

### 3. Multi-Step Analysis (multi-step-analysis.json)
多步骤数据分析工作流。
- **用途**: 了解复杂工作流的编排
- **节点**: Trigger → Summarize → Extract Insights → Recommendations → Response
- **特点**:
  - 3个连续的 LLM 调用
  - 每个步骤依赖前一步的输出
  - 演示链式处理模式

### 4. Claude Writing Assistant (claude-writing-assistant.json)
使用 Claude AI 的写作助手。
- **用途**: 展示多提供商支持
- **节点**: Trigger → Draft → Review → Finalize → Response
- **特点**:
  - 使用 Claude 模型（非 OpenAI）
  - 多步骤内容生成流程
  - 包含草稿、审阅、润色三个阶段

## 使用方法

### 在 MoonFlow Studio 中加载示例

1. 打开 MoonFlow Studio
2. 点击"导入"按钮或使用快捷键 `Ctrl+I`
3. 选择要加载的 JSON 文件
4. 工作流将自动加载到编辑器中

### 配置 API 密钥

在加载工作流后，需要为 LLM 节点配置 API 密钥：

1. 点击 LLM 节点打开配置面板
2. 在"API Key"字段中输入您的 API 密钥
   - OpenAI: https://platform.openai.com/api-keys
   - Claude: https://console.anthropic.com/settings/keys
   - Gemini: https://makersuite.google.com/app/apikey
3. 保存配置

### 测试工作流

1. 点击"开始执行"按钮
2. 观察执行日志中的详细信息
3. 查看输出结果

## 常见问题

### Q: 为什么工作流执行失败？
A: 检查以下几点：
- LLM 节点的 API 密钥是否正确配置
- API 密钥是否有足够的额度
- 网络连接是否正常
- 节点之间的连接是否正确

### Q: 如何调整 LLM 输出质量？
A: 可以通过调整以下参数：
- **Temperature**: 控制创造性（0.0-2.0，较低值更确定性，较高值更有创造性）
- **Max Tokens**: 控制最大输出长度
- **System Prompt**: 优化系统提示词可以显著提升输出质量

### Q: 如何处理长文本？
A: 
- 适当增加 Max Tokens 值
- 使用支持长上下文的模型（如 GPT-4、Claude 3）
- 考虑分步处理长文本

## 更多资源

- [MoonFlow 官方文档](https://moonflow.example.com)
- [API 参考文档](https://docs.moonflow.example.com)
- [工作流设计最佳实践](https://docs.moonflow.example.com/best-practices)
- [社区示例库](https://github.com/moonflow/examples)

## 贡献示例

欢迎提交您的工作流示例！
1. Fork 项目仓库
2. 在 `examples/workflow-examples` 目录中添加您的 JSON 文件
3. 更新本 README.md
4. 提交 Pull Request

## 许可证

示例工作流遵循项目主许可证。
