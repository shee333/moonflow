# MoonFlow 贡献指南

感谢您对 MoonFlow 项目的兴趣！本指南将帮助您开始为项目做出贡献。

---

## 📋 目录

- [行为准则](#行为准则)
- [开始之前](#开始之前)
- [开发环境设置](#开发环境设置)
- [开发流程](#开发流程)
- [代码规范](#代码规范)
- [提交规范](#提交规范)
- [测试要求](#测试要求)
- [文档要求](#文档要求)
- [Pull Request 流程](#pull-request-流程)
- [发布流程](#发布流程)

---

## 行为准则

我们承诺为 MoonFlow 社区创造一个友好、安全的环境。无论您是贡献代码、文档还是反馈，我们都期望您：

- 使用热情和包容性的语言
- 尊重不同的观点和经验
- 建设性地接受建设性批评
- 关注对社区最有利的事情
- 与社区其他成员展现同理心

---

## 开始之前

### 选择任务

您可以通过以下方式找到贡献任务：

1. **查看 Issues**: [GitHub Issues](https://github.com/shee333/moonflow/issues)
   - `good first issue`: 适合新手的任务
   - `help wanted`: 社区需要的任务
   - `bug`: Bug 修复任务

2. **查看 Project Board**: 项目看板中的待办任务

3. **提出新想法**: 
   - 创建 Issue 提出功能建议
   - 在 PR 中详细说明您的想法

### 签署贡献者协议

在提交重大贡献之前，请考虑签署贡献者协议（如果适用）。

---

## 开发环境设置

### 系统要求

- **操作系统**: Windows 10+, macOS 10.14+, Ubuntu 18.04+
- **Node.js**: 18.x 或更高版本
- **MoonBit**: 最新版本
- **Git**: 2.x 或更高版本

### 1. Fork 和 Clone

```bash
# 1. Fork 仓库
访问 https://github.com/shee333/moonflow
点击 "Fork" 按钮

# 2. 克隆您的 Fork
git clone https://github.com/YOUR_USERNAME/moonflow.git
cd moonflow

# 3. 添加上游仓库
git remote add upstream https://github.com/shee333/moonflow.git
```

### 2. 安装前端依赖

```bash
cd frontend

# 使用 npm 安装
npm install

# 或使用 pnpm（推荐，更快）
npm install -g pnpm
pnpm install
```

### 3. 安装 MoonBit

访问 [MoonBit 官网](https://www.moonbitlang.cn/) 下载安装，或使用：

```bash
# 使用 MoonBit 安装脚本
curl -L https://raw.githubusercontent.com/moonbitlang/setup/main/setup.sh | sh
```

验证安装：

```bash
moon --version
```

### 4. 配置 Git Hooks

```bash
# 安装 Husky（可选但推荐）
cd frontend
npm install husky --save-dev
npx husky install
```

---

## 开发流程

### 分支管理

我们使用 Git Flow 分支模型：

```
main          # 生产环境代码
  ↓
master        # 开发主分支
  ↓
feature/*     # 功能分支
bugfix/*      # Bug 修复分支
hotfix/*      # 紧急修复分支
release/*     # 发布分支
```

### 创建分支

```bash
# 确保在 master 分支上
git checkout master
git pull upstream master

# 创建功能分支
git checkout -b feature/your-feature-name

# 或创建 Bug 修复分支
git checkout -b bugfix/issue-number-description
```

### 开发步骤

#### 1. 前端开发

```bash
cd frontend

# 启动开发服务器
npm run dev

# 运行 lint 检查
npm run lint

# 运行类型检查
npm run typecheck

# 运行测试
npm test

# 构建生产版本
npm run build
```

#### 2. 后端开发 (MoonBit)

```bash
cd core

# 检查代码类型
moon check

# 运行测试
moon test

# 构建项目
moon build

# 格式化代码
moon fmt
```

### 同步上游更改

```bash
# 获取上游更改
git fetch upstream

# 合并到您的分支
git checkout feature/your-feature
git merge upstream/master

# 如果有冲突，解决冲突后提交
```

---

## 代码规范

### 前端代码规范 (TypeScript/React)

我们使用 ESLint + Prettier：

#### 命名规范

```typescript
// 组件：PascalCase
function WorkflowEditor() {}

// Hooks：camelCase，以 use 开头
function useWorkflowState() {}

// 工具函数：camelCase
function generateWorkflowCode() {}

// 常量：SCREAMING_SNAKE_CASE
const MAX_RETRY_COUNT = 3;

// 类型/接口：PascalCase
interface WorkflowNode {}
type NodeStatus = 'pending' | 'running' | 'completed';
```

#### 组件规范

```typescript
// ✅ 好的实践
interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
}

export function Button({ label, onClick, variant = 'primary' }: ButtonProps) {
  return (
    <button className={`btn btn-${variant}`} onClick={onClick}>
      {label}
    </button>
  );
}

// ❌ 避免
function button(props) {
  const { label } = props;
  // ...
}
```

#### Hooks 规范

```typescript
// ✅ 好的实践
export function useWorkflow(id: string) {
  const [workflow, setWorkflow] = useState<Workflow | null>(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    fetchWorkflow(id)
      .then(setWorkflow)
      .finally(() => setLoading(false));
  }, [id]);
  
  return { workflow, loading };
}

// ❌ 避免：不使用正确的依赖
useEffect(() => {
  doSomething(data);
}, []); // 缺少 data 依赖
```

### MoonBit 代码规范

#### 命名规范

```moonbit
// 结构体：PascalCase
pub struct WorkflowNode {}

// 函数：lower_snake_case
pub fn parse_workflow_json(content: String) -> Workflow {}

// 常量：SCREAMING_SNAKE_CASE
let MAX_RETRY_COUNT: Int = 3

// 类型别名：PascalCase
pub type NodeStatus = NodeStatusType
```

#### 函数规范

```moonbit
// ✅ 好的实践：带文档注释
///|
/// 解析工作流 JSON 字符串
///
/// # 参数
/// - `content`: JSON 格式的工作流定义
///
/// # 返回
/// - 解析后的 Workflow 对象
///
/// # 示例
/// ```
/// let workflow = parse_workflow_json("{\"name\": \"test\"}")?
/// ```
pub fn parse_workflow_json(content: String) -> Workflow raise ParseError {
  // ...
}

// ✅ 好的实践：错误处理
fn validate_workflow(workflow: Workflow) -> Result[Unit, ValidationError] {
  // ...
}
```

---

## 提交规范

我们使用 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

### 格式

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### Type 类型

| Type | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | Bug 修复 |
| `docs` | 文档更新 |
| `style` | 代码格式（不影响功能） |
| `refactor` | 重构（不是新功能或修复） |
| `perf` | 性能优化 |
| `test` | 测试相关 |
| `build` | 构建或依赖更新 |
| `ci` | CI/CD 相关 |
| `chore` | 其他更改 |

### Scope 范围

可选，用于标识影响的模块：

- `frontend`: 前端相关
- `core`: MoonBit 后端相关
- `components`: 组件相关
- `workflow`: 工作流相关
- `docs`: 文档相关
- `ci`: CI/CD 相关

### 示例

```bash
# 新功能
git commit -m "feat(frontend): 添加工作流导入功能"

# Bug 修复
git commit -m "fix(core): 修复工作流验证器循环依赖检测"

# 文档更新
git commit -m "docs: 更新 README 安装说明"

# 重构
git commit -m "refactor(components): 重构 HTTP 组件验证逻辑"

# 测试
git commit -m "test(frontend): 添加工作流解析器单元测试"

# 多行提交
git commit -m "feat(workflow): 添加 DAG 调度并行执行支持

- 实现拓扑排序算法
- 添加并发控制配置
- 修复节点依赖解析问题

Closes #123"
```

### 提交前检查

```bash
# 确保所有测试通过
npm test
moon test

# 确保 lint 通过
npm run lint

# 确保类型检查通过
npm run typecheck
moon check

# 格式化代码
npm run format
moon fmt
```

---

## 测试要求

### 前端测试

#### 运行测试

```bash
cd frontend

# 运行所有测试
npm test

# 运行测试并监听变化
npm test -- --watch

# 运行特定测试文件
npm test -- codeGenerator.test.ts

# 生成覆盖率报告
npm test -- --coverage
```

#### 编写测试

```typescript
// ✅ 好的测试实践
describe('codeGenerator', () => {
  describe('generateMoonBitCode', () => {
    it('should generate valid MoonBit code for simple workflow', () => {
      const workflow: Workflow = {
        name: 'test',
        nodes: [{ id: '1', type: 'trigger' }],
        edges: [],
      };
      
      const code = generateMoonBitCode(workflow);
      
      expect(code).toContain('workflow');
      expect(code).toContain('trigger');
    });

    it('should throw error for invalid workflow', () => {
      const invalidWorkflow = { name: '' };
      
      expect(() => generateMoonBitCode(invalidWorkflow))
        .toThrow('Workflow name is required');
    });
  });
});
```

### MoonBit 测试

#### 运行测试

```bash
cd core

# 运行所有测试
moon test

# 运行特定测试
moon test src/workflow/validator_test.mbt

# 更新快照
moon test --update
```

#### 编写测试

```moonbit
test "workflow validator: should detect duplicate node IDs" {
  let workflow = Workflow::{
    name: "test",
    nodes: [
      Node::{ id: "1", type: NodeType::Trigger },
      Node::{ id: "1", type: NodeType::Tool }, // 重复 ID
    ],
    edges: [],
  }
  
  match validate_workflow(workflow) {
    Ok(_) => inspect(false, content="true") // 不应该通过
    Err(ValidationError::DuplicateNodeId(id)) => {
      inspect(id, content="1")
    }
    Err(_) => inspect(false, content="true")
  }
}
```

### 测试覆盖率要求

| 模块 | 最低覆盖率 |
|------|-----------|
| 核心模块 (core) | 80% |
| 工具函数 | 70% |
| 组件 | 60% |
| 前端 | 70% |

---

## 文档要求

### 文档位置

- 用户文档: `/docs/`
- API 文档: `/docs/API.md`
- 组件文档: `/core/COMPONENTS.md`
- 示例代码: `/examples/`

### 文档更新要求

| 更改类型 | 文档要求 |
|---------|---------|
| 新功能 | 必须更新 README.md |
| 新组件 | 必须更新 COMPONENTS.md |
| API 更改 | 必须更新 API.md |
| 配置更改 | 必须更新 CONFIG.md |
| Bug 修复 | 如果影响用户，需更新文档 |

### 文档格式

```markdown
## 组件名称

### 功能说明

描述组件的功能和使用场景。

### 参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| param1 | string | 是 | 参数说明 |

### 示例

```yaml
nodes:
  - id: example
    type: component.name
    with:
      param1: value
```

### 注意事项

- 重要的使用限制
- 已知的兼容性问
```

---

## Pull Request 流程

### 创建 PR

1. **Push 您的分支**

```bash
git push origin feature/your-feature-name
```

2. **创建 Pull Request**

访问 https://github.com/shee333/moonflow，GitHub 会提示您创建 PR。

3. **填写 PR 模板**

```markdown
## 描述
<!-- 简要描述您的更改 -->

## 类型
- [ ] 新功能 (feat)
- [ ] Bug 修复 (fix)
- [ ] 文档更新 (docs)
- [ ] 代码重构 (refactor)
- [ ] 其他 (chore)

## 影响因素
- [ ] 前端
- [ ] 后端 (MoonBit)
- [ ] 文档
- [ ] 测试

## 测试
- [ ] 我已添加测试
- [ ] 不需要测试（请说明原因）

## 截图/截图
<!-- 如果有 UI 更改，添加截图 -->

## 检查清单
- [ ] 我的代码遵循项目的代码规范
- [ ] 我已经自测过
- [ ] 我已经更新相关文档
- [ ] 我的更改没有产生新的警告
```

### PR 审查流程

1. **自动检查**: CI/CD 会自动运行
   - ✅ Lint 检查
   - ✅ 类型检查
   - ✅ 测试
   - ✅ 构建

2. **人工审查**: 维护者会审查您的代码
   - 代码质量和风格
   - 测试覆盖
   - 文档更新
   - 用户体验影响

3. **合并**: 审查通过后，维护者会合并您的 PR

### 处理反馈

```bash
# 获取最新远程分支
git fetch origin

# 在您的分支上 rebase
git checkout feature/your-feature
git rebase origin/master

# 解决冲突后，继续 rebase
git rebase --continue

# 强制推送（仅用于您的 Feature 分支）
git push --force-with-lease origin feature/your-feature
```

---

## 发布流程

### 版本号规范

我们使用语义化版本 (SemVer):

```
MAJOR.MINOR.PATCH
  │     │     │
  │     │     └─ Bug 修复
  │     └─ 新功能（向后兼容）
  └─ 破坏性更改
```

### 发布步骤

1. **准备发布**

```bash
# 确保在 master 分支
git checkout master
git pull upstream master

# 创建发布分支
git checkout -b release/v1.0.0
```

2. **更新版本号**

```bash
# 更新 CHANGELOG.md
# 更新 package.json (frontend)
# 更新 moon.mod.json (core)
```

3. **测试发布分支**

```bash
# 运行完整测试
npm test && moon test

# 运行构建
npm run build && moon build
```

4. **创建 Release Tag**

```bash
# 合并到 master
git checkout master
git merge release/v1.0.0

# 创建 Tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# 推送
git push upstream master --tags
```

5. **GitHub Release**

访问 GitHub 创建正式 Release，填写发布说明。

---

## 获取帮助

如果您在贡献过程中遇到问题：

1. **查看文档**
   - [README.md](README.md)
   - [项目 Wiki](https://github.com/shee333/moonflow/wiki)

2. **搜索 Issue**
   - 可能有其他人遇到同样问题

3. **创建 Issue**
   - 清晰描述问题
   - 提供复现步骤
   - 包含环境信息

4. **联系维护者**
   - 通过 GitHub Discussion
   - 通过邮件

---

## 许可证

通过贡献代码，您同意将您的作品按照项目的 MIT 许可证发布。

---

**感谢您的贡献！** 🎉

---

**维护者**: MoonFlow Team  
**最后更新**: 2026-04-02
