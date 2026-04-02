# Pre-commit Hooks

MoonFlow 项目配置了 Git hooks 来确保代码质量和提交规范。

## 概述

项目使用 Husky 来管理 Git hooks，位于 `.husky/` 目录。

## 安装

```bash
# 在项目根目录安装 Husky
cd frontend
npm install husky --save-dev

# 初始化 Husky
npx husky install

# 添加 hooks
npx husky add .husky/pre-commit
npx husky add .husky/commit-msg
```

## Hooks 说明

### pre-commit

在提交前自动运行以下检查：

#### 前端检查
- ESLint 代码检查
- TypeScript 类型检查

#### 后端检查
- MoonBit 代码检查 (`moon check`)
- MoonBit 格式检查 (`moon fmt --check`)

### commit-msg

验证提交信息符合 Conventional Commits 规范：

```
<type>(<scope>): <subject>

示例：
feat(frontend): add user authentication
fix(core): resolve workflow validation bug
docs: update README installation guide
```

## 跳过 Hooks

如果需要跳过 hooks（例如紧急修复）：

```bash
# 跳过 pre-commit hooks
git commit --no-verify -m "fix: urgent hotfix"

# 跳过 commit-msg hook
git commit --no-verify -m "chore: temp fix"
```

⚠️ 谨慎使用，会绕过代码质量检查。

## 常见问题

### 1. Husky 未安装

```bash
npm install
```

### 2. Hooks 未生效

```bash
# 确保在 git 仓库中
git status

# 重新初始化
npx husky install
```

### 3. Windows 权限问题

```powershell
# 使用管理员权限运行
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 自定义

### 修改 pre-commit 检查

编辑 `.husky/pre-commit` 文件：

```bash
# 添加新的检查
npm run custom-check
```

### 修改 commit 规范

编辑 `.husky/commit-msg` 文件中的正则表达式。

## 更多信息

- [Husky 官方文档](https://typicode.github.io/husky/)
- [Conventional Commits 规范](https://www.conventionalcommits.org/)
