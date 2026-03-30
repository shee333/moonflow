# 手动重命名目录指南

## 问题说明

由于 `d:\Project\moonbit` 目录正在被其他进程占用，无法自动重命名。请按照以下步骤手动操作：

## 方法 1：使用文件资源管理器（推荐）

1. 打开 **文件资源管理器**
2. 导航到 `D:\Project\`
3. 右键点击 `moonbit` 文件夹
4. 选择 **"重命名"**
5. 输入 `moonflow`
6. 按 Enter 确认

## 方法 2：使用命令提示符

1. 打开 **命令提示符**（CMD）
2. 运行以下命令：

```cmd
cd D:\Project
ren moonbit moonflow
```

## 方法 3：使用 PowerShell

1. 打开 **PowerShell**（管理员）
2. 运行以下命令：

```powershell
Rename-Item -Path "D:\Project\moonbit" -NewName "moonflow"
```

## 方法 4：运行批处理脚本

双击运行项目根目录下的 `rename_project.bat` 文件。

## 重命名后的操作

### 1. 更新 Git 仓库

```bash
cd D:\Project\moonflow
git status
```

### 2. 重新创建 GitHub 仓库

按照 [SETUP_GITHUB.md](SETUP_GITHUB.md) 的步骤：

```powershell
# 登录 GitHub
"C:\Program Files\GitHub CLI\gh.exe" auth login --web

# 创建仓库
"C:\Program Files\GitHub CLI\gh.exe" repo create moonflow --public --source=. --remote=origin

# 推送代码
git push -u origin master
```

### 3. 验证克隆地址

仓库创建成功后，可以克隆到本地：
```bash
git clone https://github.com/YOUR_USERNAME/moonflow.git
```

## 故障排除

### Q: 为什么目录无法重命名？

A: 可能有以下原因：
- 有程序正在该目录中打开文件
- 有终端会话正在该目录中运行命令
- 杀毒软件正在扫描该目录

### Q: 如何找出占用目录的进程？

A: 使用以下命令查看：

```powershell
# 列出所有进程
Get-Process

# 或使用资源监视器
resmon.exe
```

### Q: 如果仍然无法重命名怎么办？

A: 可以尝试：
1. 重启计算机
2. 使用安全模式
3. 使用第三方文件管理器（如 Total Commander）
