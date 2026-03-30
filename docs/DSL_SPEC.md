# MoonFlow Workflow DSL 规范

## 概述

MoonFlow 使用 YAML/JSON 作为工作流描述的事实来源（Single Source of Truth），通过 JSON Schema 进行校验和 IDE 提示。

## 基本结构

```yaml
version: v1
name: workflow_name
description: 工作流描述（可选）
metadata:
  author: 作者
  version: 版本
  tags: [标签1, 标签2]
nodes:
  - id: node_id          # 节点唯一标识符
    type: node_type      # 节点类型
    label: 显示名称      # 可选
    with: {}             # 节点参数
    timeout: 30000       # 超时时间（毫秒），可选
    retry:               # 重试配置，可选
      max_attempts: 3
      strategy: exponential_backoff
      initial_delay: 1000
    condition: ""        # 执行条件，可选
edges:
  - from: source_id      # 源节点 ID
    to: target_id        # 目标节点 ID
    label: ""            # 边标签，可选
    condition: ""        # 条件，可选
config:
  timeout: 3600000       # 全局超时（毫秒）
  retry: {}              # 全局重试配置
  concurrency: 10        # 最大并发数
```

## 节点类型

### 触发器（Trigger）

```yaml
nodes:
  - id: timer
    type: trigger.timer
    with:
      schedule: '0 9 * * *'  # cron 表达式
  
  - id: webhook
    type: trigger.webhook
    with:
      path: /webhook/trigger
      method: POST
  
  - id: manual
    type: trigger.manual
```

### 工具（Tool）

```yaml
nodes:
  # HTTP 请求
  - id: http_fetch
    type: tool.http_get
    with:
      url: 'https://api.example.com/data'
      headers:
        Authorization: 'Bearer {secret.api_key}'
      timeout: 5000
  
  # 发送邮件
  - id: send_email
    type: tool.email.send
    with:
      to: user@example.com
      subject: '通知邮件'
      body: '邮件内容'
      smtp_host: smtp.example.com
  
  # 飞书消息
  - id: send_feishu
    type: tool.feishu.send
    with:
      webhook: '{secret.feishu_webhook}'
      message_type: text
      content:
        text: '飞书消息内容'
```

### 代理（Agent）

```yaml
nodes:
  # LLM 代理
  - id: llm_summarize
    type: agent.llm
    with:
      model: gpt-4
      prompt: '用中文总结以下内容：{input}'
      temperature: 0.7
      max_tokens: 1000
      api_key: '{secret.openai_key}'
  
  # 意图识别
  - id: intent_classify
    type: agent.intent_classify
    with:
      model: gpt-4
      intents:
        - query_weather
        - set_reminder
        - search_news
      default_intent: unknown
```

### 控制流（Control）

```yaml
nodes:
  # 条件分支
  - id: check_condition
    type: control.condition
    with:
      expression: '$.weather.temperature > 30'
  
  # 并行分支
  - id: parallel_process
    type: control.parallel
    with:
      join_type: all  # all | any | n
      threshold: 2
  
  # 循环
  - id: loop_process
    type: control.loop
    with:
      items: '$.data.items'
      max_iterations: 100
  
  # 结束
  - id: end
    type: control.end
    with:
      status: success  # success | failure
```

## 边定义

### 基本边

```yaml
edges:
  - from: trigger
    to: fetch_data
```

### 条件边

```yaml
edges:
  - from: check_weather
    to: send_cold_alert
    condition: '$.weather.temperature < 10'
  
  - from: check_weather
    to: send_hot_alert
    condition: '$.weather.temperature > 30'
  
  - from: check_weather
    to: send_normal_alert
    condition: 'true'  # 默认分支
```

### 数据边

```yaml
edges:
  - from: fetch_weather
    to: summarize_weather
    data_mapping:
      weather_data: '$.weather'  # 从源节点传递数据
```

## 变量引用

### 输入变量

```yaml
nodes:
  - id: process
    type: agent.llm
    with:
      prompt: '用户输入是：{$.input.user_message}'
```

### 节点输出

```yaml
nodes:
  - id: fetch
    type: tool.http_get
    with:
      url: 'https://api.github.com/{$.params.repo}'
  
  # 引用前一个节点的输出
  - id: summarize
    type: agent.llm
    with:
      prompt: '总结：{$.fetch.result}'
```

### 表达式

```yaml
nodes:
  - id: filter
    type: control.condition
    with:
      expression: 'len($.fetch.items) > 10'
```

## 完整示例

### GitHub Trending 每日推送

```yaml
version: v1
name: github_trending_daily
description: 每日抓取 GitHub Trending，生成中文摘要，发送通知

metadata:
  author: MoonFlow Team
  version: 1.0.0
  tags: [自动化, GitHub, 每日推送]

nodes:
  # 定时触发
  - id: timer
    type: trigger.timer
    with:
      schedule: '0 9 * * *'
  
  # 抓取 GitHub Trending
  - id: fetch_trending
    type: tool.http_get
    with:
      url: 'https://github.com/trending'
      timeout: 10000
    retry:
      max_attempts: 3
      strategy: exponential_backoff
  
  # 解析 HTML（简化）
  - id: parse_html
    type: tool.html_parse
    with:
      html: '{$.fetch_trending.body}'
      selector: '.repo-list-item h3 a'
  
  # LLM 总结
  - id: summarize
    type: agent.llm
    with:
      model: gpt-4
      prompt: |
        请用中文总结以下 GitHub 热门项目列表（不超过500字）：
        {$.parse_html.result}
      temperature: 0.5
      max_tokens: 1000
      api_key: '{secret.openai_key}'
  
  # 发送飞书通知
  - id: send_feishu
    type: tool.feishu.send
    with:
      webhook: '{secret.feishu_webhook}'
      message_type: text
      content:
        text: |
          📊 GitHub Trending 每日汇总
          
          {$.summarize.result}
          
          🕐 生成时间：{$.meta.timestamp}

edges:
  - { from: timer, to: fetch_trending }
  - { from: fetch_trending, to: parse_html }
  - { from: parse_html, to: summarize }
  - { from: summarize, to: send_feishu }

config:
  timeout: 120000
  retry:
    max_attempts: 2
    initial_delay: 1000
```

## JSON Schema

完整 JSON Schema 定义请参考：[workflow.schema.json](workflow.schema.json)

## 校验规则

1. **节点 ID 唯一性**：所有节点 ID 必须唯一
2. **边引用有效性**：所有边引用的节点 ID 必须存在
3. **类型检查**：节点 `type` 必须是已注册的类型
4. **必填字段**：每种节点类型都有必填字段
5. **循环检测**：不允许存在循环依赖

## IDE 支持

使用 JSON Schema 可以在以下 IDE 中获得自动补全和校验：

- VS Code（安装 YAML/JSON Schema 插件）
- JetBrains 系列 IDE
- WebStorm
- 其他支持 JSON Schema 的编辑器
