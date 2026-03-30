# MoonFlow 安全设计

## 安全架构

MoonFlow 采用多层安全防护机制，确保 Agent 编排过程中的安全性和可靠性。

```
┌─────────────────────────────────────────────────────────────┐
│                    能力声明层 (Capability Layer)            │
│  Tool/Agent 必须声明所需权限，超出声明范围的访问被拒绝      │
├─────────────────────────────────────────────────────────────┤
│                    进程隔离层 (Isolation Layer)              │
│  不可信代码在独立进程中运行，无法直接访问宿主资源           │
├─────────────────────────────────────────────────────────────┤
│                    运行时拦截层 (Runtime Interception)       │
│  敏感操作（如文件删除、支付）需要人工确认                   │
├─────────────────────────────────────────────────────────────┤
│                    审计日志层 (Audit Layer)                  │
│  所有操作完整记录，支持回溯和追责                           │
└─────────────────────────────────────────────────────────────┘
```

## 核心安全特性

### 1. 进程级隔离

#### 本地模式

```yaml
nodes:
  - id: untrusted_plugin
    type: tool.custom_plugin
    isolation:
      mode: process  # 进程隔离
      timeout: 30000
      memory_limit: 256MB
      network: false  # 禁止网络访问
      filesystem: read-only  # 只读文件系统访问
```

#### 服务端模式

```yaml
nodes:
  - id: external_api
    type: tool.http_get
    isolation:
      mode: container
      image: moonflow/plugin-base:latest
      network_policy: allowlist
      resources:
        cpu: '0.5'
        memory: '512Mi'
```

### 2. 能力声明（Capability Declaration）

每个 Tool/Agent 在 manifest 中必须声明所需权限：

```yaml
# plugin_manifest.yaml
name: email_sender
version: 1.0.0
capabilities:
  - type: network
    targets:
      - smtp.example.com:587
    protocols:
      - smtp
  - type: environment
    variables:
      - SMTP_USER
      - SMTP_PASSWORD
constraints:
  max_execution_time: 30000
  max_memory_mb: 128
```

#### 权限类型

| 权限类型 | 描述 | 风险等级 |
|---------|------|---------|
| `network` | 网络访问权限 | 中 |
| `filesystem.read` | 文件系统只读权限 | 中 |
| `filesystem.write` | 文件系统读写权限 | 高 |
| `shell` | Shell 命令执行权限 | 极高 |
| `database` | 数据库访问权限 | 高 |
| `payment` | 支付操作权限 | 极高 |
| `system` | 系统级操作权限 | 极高 |

### 3. 人在回路（Human-in-the-Loop）

对于高风险操作，系统强制要求人工确认：

```yaml
nodes:
  - id: delete_files
    type: tool.file.delete
    with:
      path: '/tmp/*.log'
    approval:
      required: true
      approvers:
        - admin@example.com
      timeout: 3600  # 审批超时时间（秒）
      message: '确认删除以下文件？'
      auto_reject_if_timeout: true
  
  - id: send_payment
    type: tool.payment.execute
    with:
      amount: '{$.input.amount}'
      recipient: '{$.input.recipient}'
    approval:
      required: true
      min_approvals: 2  # 需要多个审批人
```

#### 审批流程

1. **自动挂起**：高风险操作执行前自动挂起
2. **通知审批人**：发送邮件/消息通知
3. **审批/拒绝**：审批人通过管理界面审批或拒绝
4. **执行或取消**：根据审批结果执行或取消操作
5. **记录审计日志**：所有审批操作完整记录

### 4. 密钥托管（Key Escrow）

#### 问题

❌ **不安全做法**：
```yaml
nodes:
  - id: send_email
    type: tool.email
    with:
      api_key: 'sk-1234567890abcdef'  # 密钥直接写在 DSL 中！
```

✅ **安全做法**：
```yaml
nodes:
  - id: send_email
    type: tool.email
    with:
      api_key: '{secret.email_api_key}'  # 引用托管密钥
```

#### 密钥管理

```bash
# 添加密钥
moonflow secret add email_api_key

# 列出密钥
moonflow secret list

# 删除密钥
moonflow secret delete email_api_key

# 设置环境变量（推荐用于生产环境）
export MOONFLOW_SECRET_EMAIL_API_KEY='sk-xxx'
```

### 5. 审计日志（Audit Logging）

#### 记录内容

- 操作时间戳
- 执行用户/服务
- 操作类型
- 涉及资源
- 操作结果
- 源 IP 地址
- 审批记录（如果需要）

#### 日志格式

```json
{
  "timestamp": "2026-03-30T10:30:00Z",
  "event_type": "workflow.execution",
  "workflow_id": "wf_abc123",
  "node_id": "send_email",
  "actor": {
    "type": "user",
    "id": "user@example.com"
  },
  "action": "tool.email.send",
  "resource": {
    "type": "email",
    "to": "recipient@example.com"
  },
  "result": "success",
  "metadata": {
    "execution_time_ms": 1234,
    "approval_id": "apr_xyz789"  // 如果有审批
  }
}
```

#### 查询日志

```bash
# 查询特定工作流的执行记录
moonflow log query --workflow-id wf_abc123 --since 7d

# 查询所有敏感操作
moonflow log query --event-type payment.execute,file.delete --since 30d

# 导出日志用于分析
moonflow log export --format csv --since 30d > audit_log.csv
```

### 6. 输入验证与过滤

#### Prompt 注入防护

```yaml
nodes:
  - id: llm_query
    type: agent.llm
    with:
      model: gpt-4
      prompt: |
        用户输入：{$.input.user_message}
        
        指示：请回答用户问题，不要执行任何命令。
      input_filter:
        enabled: true
        block_patterns:
          - '(?i)rm\s+-rf'
          - '(?i)drop\s+table'
          - '(?i)exec\s*\('
        max_length: 10000
```

#### 输出脱敏

```yaml
nodes:
  - id: query_user_info
    type: tool.database.query
    with:
      sql: 'SELECT * FROM users WHERE id = {$.input.user_id}'
    output_filter:
      enabled: true
      mask_fields:
        - password
        - credit_card
        - ssn
      redact_pattern: '\d{4}-\d{4}-\d{4}-(\d{4})'
```

## 安全最佳实践

### 开发阶段

1. ✅ 使用本地模式开发和测试
2. ✅ 使用 mock/测试密钥
3. ✅ 启用所有安全检查
4. ✅ 编写安全测试用例

### 部署阶段

1. ✅ 使用环境变量管理密钥
2. ✅ 限制进程资源使用
3. ✅ 配置合理的审批流程
4. ✅ 启用完整审计日志

### 运营阶段

1. ✅ 定期审计日志
2. ✅ 更新安全策略
3. ✅ 监控异常行为
4. ✅ 定期安全评估

## 应急响应

### 发现安全问题

1. **立即隔离**：停止相关工作流执行
2. **保留现场**：保存完整日志和状态
3. **评估影响**：确定影响范围
4. **修复漏洞**：修复安全问题
5. **恢复服务**：验证修复后恢复服务
6. **复盘总结**：编写事故报告

### 密钥泄露

```bash
# 1. 立即撤销密钥
moonflow secret revoke email_api_key

# 2. 轮换密钥
moonflow secret rotate email_api_key

# 3. 检查泄露影响
moonflow audit check --secret-id email_api_key --since 7d

# 4. 通知相关方
moonflow notify --template security_incident
```

## 合规性

MoonFlow 设计符合以下安全和隐私标准：

- **数据保护**：敏感数据加密存储，传输使用 TLS
- **访问控制**：最小权限原则，基于角色的访问控制
- **审计追溯**：完整操作记录，支持合规审计
- **隐私保护**：PII 数据脱敏，符合 GDPR 要求

## 安全配置示例

### 高安全级别配置

```yaml
# moonflow-config.yaml
security:
  mode: strict
  
  isolation:
    default_mode: container
    default_network: denylist
    allowed_networks:
      - api.github.com
      - api.openai.com
  
  approval:
    auto_approve: false
    high_risk_operations:
      - file.delete
      - payment.execute
      - system.shutdown
  
  secrets:
    storage: vault  # 使用 Vault 管理密钥
    env_override: false
  
  audit:
    level: verbose
    retention_days: 365
    export_enabled: true
```

### 开发环境配置

```yaml
# moonflow-config.dev.yaml
security:
  mode: relaxed
  
  isolation:
    default_mode: process
    default_network: allowlist
  
  approval:
    auto_approve: true
  
  secrets:
    storage: env
    env_override: true
  
  audit:
    level: basic
    retention_days: 30
```
