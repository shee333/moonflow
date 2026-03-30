# GitHub 仓库设置指南

## 步骤 1: 登录 GitHub

使用 GitHub CLI 登录：

```powershell
"C:\Program Files\GitHub CLI\gh.exe" auth login --web
```

这会打开浏览器，请在浏览器中完成认证。

或者使用 Token 方式登录：

```powershell
# 1. 在 GitHub 上创建 Personal Access Token
# Settings -> Developer settings -> Personal access tokens -> Generate new token

# 2. 使用 Token 登录
"C:\Program Files\GitHub CLI\gh.exe" auth login --token YOUR_TOKEN_HERE
```

## 步骤 2: 创建 GitHub 仓库

认证完成后，运行以下命令创建仓库：

```powershell
"C:\Program Files\GitHub CLI\gh.exe" repo create moonagent --public --source=. --remote=origin
```

## 步骤 3: 推送到 GitHub

```powershell
git push -u origin master
```

## 验证

创建成功后，你可以访问：
https://github.com/YOUR_USERNAME/moonagent

## 常见问题

### Q: 如何查看是否已登录？
```powershell
"C:\Program Files\GitHub CLI\gh.exe" auth status
```

### Q: 如何退出登录？
```powershell
"C:\Program Files\GitHub CLI\gh.exe" auth logout
```

### Q: 如果创建仓库时提示仓库已存在？
可以先删除现有仓库或使用不同的仓库名：
```powershell
"C:\Program Files\GitHub CLI\gh.exe" repo create moonagent-v2 --public --source=. --remote=origin
```

然后修改本地 git remote：
```powershell
git remote set-url origin https://github.com/YOUR_USERNAME/moonagent-v2.git
```
