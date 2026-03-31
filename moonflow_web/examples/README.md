# MoonFlow 工作流示例指南

简体中文 | [English](./README.en.md)

## 🎯 快速开始

### 1. 启动 MoonFlow Studio

```bash
cd moonflow_web
npm install
npm run dev
```

访问 http://localhost:5173/

### 2. 导入示例工作流

1. 点击顶部菜单 "导入"
2. 选择 `examples/` 目录下的 JSON 文件
3. 工作流将自动加载到编辑器中

---

## 📚 可用示例

### 1. LLM 聊天机器人 (`llm-chatbot.json`)

**功能**: 基于 AI 的智能对话系统

**架构**:
```
HTTP 触发器 → LLM 处理器 → 响应
```

**配置步骤**:

1. **HTTP 触发器**
   - 请求方法: `POST`
   - 路径: `/chat`
   - 接收用户输入

2. **LLM 处理器** ⚠️ 重要
   - **提供商**: 选择 `openai`、`claude` 或 `gemini`
   - **模型**: 输入模型名称
     - OpenAI: `gpt-4`, `gpt-3.5-turbo`
     - Claude: `claude-3-opus`, `claude-3-sonnet`
     - Gemini: `gemini-pro`
   - **API Key**: 输入您的 API 密钥 ⚠️
     - OpenAI: https://platform.openai.com/api-keys
     - Claude: https://console.anthropic.com/settings/keys
     - Gemini: https://makersuite.google.com/app/apikey
   - **系统提示词**: 设置 AI 的角色和行为
   - **用户提示词**: `{{input}}` 表示来自上一步的数据
   - **Temperature**: 0.0-2.0，控制创造性（默认 0.7）
   - **Max Tokens**: 最大生成 token 数

3. **响应**
   - 返回 LLM 的回答给用户

**使用示例**:

```bash
curl -X POST http://localhost:3000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "你好，请介绍一下你自己"}'
```

**响应示例**:

```json
{
  "reply": "你好！我是 MoonFlow AI 助手，很高兴为您服务..."
}
```

---

## 🔧 配置说明

### LLM 提供商

#### OpenAI

```json
{
  "provider": "openai",
  "model": "gpt-4",
  "api_key": "sk-xxxxx"
}
```

**可用模型**:
- `gpt-4o` - 最新 GPT-4
- `gpt-4-turbo` - GPT-4 快速版
- `gpt-4` - GPT-4
- `gpt-3.5-turbo` - 快速且便宜
- `o1-preview` - 推理模型
- `o1-mini` - 轻量推理

#### Anthropic Claude

```json
{
  "provider": "claude",
  "model": "claude-3-5-sonnet-20241022",
  "api_key": "sk-ant-xxxxx"
}
```

**可用模型**:
- `claude-3-5-sonnet-20241022` - 最新 Sonnet
- `claude-3-opus-20240229` - 最强 Opus
- `claude-3-sonnet-20240229` - 平衡选择
- `claude-3-haiku-20240307` - 快速且便宜

#### Google Gemini

```json
{
  "provider": "gemini",
  "model": "gemini-2.0-flash-exp",
  "api_key": "AIzaSyxxxxx"
}
```

**可用模型**:
- `gemini-2.0-flash-exp` - 最新 Flash
- `gemini-1.5-flash` - 快速免费
- `gemini-1.5-pro` - 最强 Pro
- `gemini-1.0-pro` - 稳定版

---

## ⚙️ 参数说明

### Temperature (0.0-2.0)

- **0.0**: 最确定性的回答
- **0.7**: 平衡创造性和确定性
- **1.0-2.0**: 更有创造性但可能不稳定

### Max Tokens

- 控制单次回复的最大长度
- GPT-4 最大 128k tokens
- 建议根据用途设置:
  - 简短回答: 100-500
  - 中等回答: 500-2000
  - 长文本: 2000+

---

## 🚨 常见问题

### 1. API Key 无效

确保:
- API Key 格式正确
- Key 已激活且有余额
- 密钥权限正确

### 2. 请求超时

调整:
- 增加节点配置的 `timeout` 值
- 减少 `max_tokens` 值

### 3. 模型不支持

检查:
- 模型名称拼写正确
- API Key 对应正确的服务商
- 模型在您的账户中可用

---

## 💡 最佳实践

1. **使用系统提示词**
   - 明确定义 AI 角色
   - 提供示例回答格式
   - 设置限制和规则

2. **优化 Temperature**
   - 需要确定性: 0.0-0.3
   - 平衡: 0.5-0.8
   - 创意写作: 0.8-1.2

3. **控制输出长度**
   - 设置合理的 `max_tokens`
   - 在系统提示词中说明格式要求

4. **错误处理**
   - 添加重试机制
   - 设置超时限制
   - 记录错误日志

---

## 📖 下一步

- 查看其他示例工作流
- 学习 MoonBit DSL 语法
- 部署到生产环境

---

## 🔗 相关链接

- [MoonFlow GitHub](https://github.com/shee333/moonflow)
- [MoonBit 文档](https://moonbitlang.cn/docs/)
- [OpenAI API 文档](https://platform.openai.com/docs)
- [Anthropic Claude 文档](https://docs.anthropic.com/)
- [Google Gemini 文档](https://ai.google.dev/docs)
