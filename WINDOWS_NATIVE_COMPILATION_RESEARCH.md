# Windows 原生编译研究报告

**日期**: 2026-04-04
**状态**: 研究完成，已测试

---

## 测试结果摘要

| 后端 | Windows 支持 | moonbitlang/async 支持 |
|------|-------------|------------------------|
| wasm-gc | ✅ 完全支持 | ❌ 不支持 |
| wasm | ✅ 完全支持 | ❌ 不支持 |
| js | ✅ 完全支持 | ❌ 不支持 |
| native | ⚠️ 部分支持 | ❌ 不支持 |
| llvm | ⚠️ 实验性 | ❌ 不支持 (需要 Unix 头文件) |

**结论**: `moonbitlang/async` 在 Windows 上**无法使用**，无论选择哪个后端。

---

## 问题分析

### 编译错误

```
fatal error: sys/socket.h: No such file or directory
fatal error: spawn.h: No such file or directory
```

### 原因

`sys/socket.h` 和 `spawn.h` 是 **Unix 特有头文件**，Windows 不支持原生提供。

| 头文件 | Unix 位置 | Windows 替代 |
|--------|-----------|--------------|
| `sys/socket.h` | `/usr/include/` | `winsock2.h` |
| `spawn.h` | `/usr/include/` | Windows API |

---

## 解决方案

### 方案 1: LLVM 后端（推荐）✅

MoonBit 提供了 **LLVM 后端**，可以直接生成原生代码，不依赖 Unix 头文件。

#### 安装 LLVM 后端

```powershell
# Windows PowerShell
$env:MOONBIT_INSTALL_VERSION = "nightly"
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm https://cli.moonbitlang.com/install/powershell.ps1 | iex
```

#### 使用 LLVM 后端编译

```bash
# 编译为原生可执行文件
moon build cmd/server --target llvm

# 运行
./cmd/server.exe
# 或
./cmd/server
```

#### 测试结果

```
moon build cmd/server --target llvm
Warning: LLVM backend is experimental and only supported on nightly moonbit toolchain for now
Error: Sys_error("...prelude.mi: No such file or directory")
fatal error: sys/socket.h: No such file or directory
fatal error: spawn.h: No such file or directory
```

**问题**: `moonbitlang/async` 仍然依赖 Unix 头文件，LLVM 后端无法绕过。

#### 优点

- ✅ 不依赖 C 代码中间表示
- ✅ 直接生成机器码
- ✅ 支持 Windows CodeView 调试信息
- ✅ 支持 LLDB 调试器

#### 缺点

- ⚠️ 需要 nightly 版本
- ⚠️ LLVM 工具链较大
- ⚠️ `moonbitlang/async` 仍需要 Unix 头文件

---

### 方案 2: MSYS2/MinGW 环境

MSYS2 提供类 Unix 环境，包含 POSIX 兼容层。

#### 安装 MSYS2

1. 下载: https://www.msys2.org/
2. 安装 MSYS2 (64-bit Windows 10+)

#### 安装编译工具

```bash
# 在 MSYS2 终端中运行
pacman -S mingw-w64-ucrt-x86_64-gcc
pacman -S mingw-w64-ucrt-x86_64-clang
```

#### 使用 MinGW 编译

```bash
# 设置 PATH
export PATH="/c/msys64/ucrt64/bin:$PATH"

# 编译 MoonBit (使用 C 后端)
moon build cmd/server --target c

# 使用 GCC 编译生成的 C 代码
gcc -o server.exe server.c -lws2_32
```

#### 优点

- ✅ 完整的 POSIX 兼容
- ✅ 支持大部分 Unix 程序
- ✅ 免费开源

#### 缺点

- ⚠️ 需要额外安装软件
- ⚠️ 环境配置复杂
- ⚠️ 编译速度较慢

---

### 方案 3: WSL (Windows Subsystem for Linux)

在 Windows 上运行完整的 Linux 环境。

#### 安装 WSL

```powershell
# PowerShell (管理员)
wsl --install
```

#### 在 WSL 中编译

```bash
# 进入 WSL
wsl

# 安装 MoonBit
curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash

# 编译 MoonBit 项目
cd /mnt/d/Project/moonflow
moon build cmd/server --target native

# 运行
./cmd/server
```

#### 优点

- ✅ 完全的 Linux 环境
- ✅ 原生支持所有 Unix 程序
- ✅ 可以直接运行 MoonBit 原生后端

#### 缺点

- ⚠️ 需要 WSL 2
- ⚠️ 占用磁盘空间 (~10GB)
- ⚠️ 需要重启电脑

---

### 方案 4: Docker 容器

使用 Docker 容器进行编译。

#### 安装 Docker Desktop

https://www.docker.com/products/docker-desktop/

#### 创建 Dockerfile

```dockerfile
FROM debian:bookworm-slim

# 安装 MoonBit
RUN curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash

# 复制源代码
COPY . /app
WORKDIR /app

# 编译
RUN moon build cmd/server --target native

# 启动
CMD ["./cmd/server"]
```

#### 构建和运行

```bash
# 构建镜像
docker build -t moonflow-server .

# 运行容器
docker run -p 8080:8080 moonflow-server
```

#### 优点

- ✅ 环境隔离
- ✅ 可复现构建
- ✅ 跨平台

#### 缺点

- ⚠️ 需要 Docker
- ⚠️ 容器管理复杂
- ⚠️ 调试困难

---

## 推荐方案

### 对于开发环境

| 场景 | 推荐方案 |
|------|----------|
| **快速原型** | WebAssembly 后端 (`--target wasm`) |
| **生产部署** | Linux/macOS 原生编译 |
| **Windows 开发** | WSL2（唯一可行方案） |
| **跨平台构建** | Docker 容器 |

### 决策树

```
需要 moonbitlang/async？
  │
  ├── 否 ──→ 可以使用任何后端
  │
  └── 是 ──→ 操作系统？
              │
              ├── Windows ──→ WSL2 (唯一可行)
              │             或 MSYS2 (需要额外配置)
              │
              ├── macOS ──→ 原生编译
              │
              └── Linux ──→ 原生编译
```

---

## 测试步骤

### 1. 安装 LLVM 后端 (Nightly)

```powershell
# PowerShell
$env:MOONBIT_INSTALL_VERSION = "nightly"
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm https://cli.moonbitlang.com/install/powershell.ps1 | iex
```

### 2. 验证安装

```bash
moon --version
# 应该是 nightly 版本
```

### 3. 编译 MoonBit 项目

```bash
cd d:\Project\moonflow\core
moon build cmd/server --target llvm
```

### 4. 运行服务器

```bash
./cmd/server.exe
# 或
./cmd/server
```

---

## 环境要求

### 最低要求

| 组件 | 要求 |
|------|------|
| Windows | Windows 10 (64-bit) 或更高 |
| 内存 | 4GB RAM |
| 磁盘 | 2GB 可用空间 |
| LLVM | 包含在 MoonBit nightly 中 |

### 推荐配置

| 组件 | 推荐 |
|------|------|
| Windows | Windows 11 |
| 内存 | 8GB+ RAM |
| 磁盘 | SSD |
| 网络 | 稳定连接 (下载工具链) |

---

## 常见问题

### Q1: LLVM 后端是否稳定？

A: LLVM 后端正在积极开发中，nightly 版本可能存在 bug。建议用于开发测试，生产环境使用稳定版本。

### Q2: 编译失败怎么办？

A: 按顺序检查:
1. `moon --version` 是否为 nightly
2. 是否有足够的磁盘空间
3. 是否有网络连接下载 LLVM
4. 尝试清理并重新安装

### Q3: 性能如何？

A: LLVM 后端生成优化的机器码，性能接近原生 C 代码。

### Q4: 如何调试？

A: 使用 LLDB 或 IDE 调试器，MoonBit 支持 CodeView 调试信息。

---

## 最终结论

### Windows 原生编译 `moonbitlang/async` 的可能性

**结论: ❌ 在 Windows 上无法原生编译 `moonbitlang/async`**

原因:
1. `moonbitlang/async` 依赖 Unix 特定头文件 (`sys/socket.h`, `spawn.h`)
2. 这些头文件在任何 Windows 后端都不可用
3. LLVM 后端无法绕过这个限制

### MoonFlow 项目在 Windows 上的选择

| 选项 | 可行性 | 说明 |
|------|--------|------|
| **WSL2** | ✅ 推荐 | 完全的 Linux 环境，支持所有功能 |
| **Docker** | ✅ 推荐 | 跨平台构建，环境隔离 |
| **MSYS2** | ⚠️ 可行 | 需要额外配置，兼容性有限 |
| **直接 Windows 原生** | ❌ 不可行 | `moonbitlang/async` 不支持 |

### MoonFlow 架构建议

```
前端 (Windows): 可行
  └── React + TypeScript
  └── WebAssembly 执行引擎

后端 (需要 moonbitlang/async):
  ├── WSL2: ✅ 完全支持
  ├── Docker: ✅ 完全支持
  └── Linux/macOS: ✅ 完全支持
```

---

## 下一步行动

### 立即可行

1. [x] ~~安装 MoonBit nightly 版本~~
2. [x] ~~测试 LLVM 后端编译~~
3. [x] 验证 `moonbitlang/async` 编译失败
4. [ ] 决定架构方案

### 架构决策

A. **WSL2 方案** (推荐)
   - 安装 WSL2
   - 在 WSL 中开发和测试
   - 保持跨平台能力

B. **Docker 方案** (适合 CI/CD)
   - 创建 Dockerfile
   - 在容器中编译和运行
   - 适合持续集成

C. **混合方案** (推荐用于生产)
   - 前端: Windows 原生开发
   - 后端: Docker 部署

---

## 参考资料

- MoonBit 官方文档: https://www.moonbitlang.com/docs/
- WSL2 安装指南: https://docs.microsoft.com/windows/wsl/install
- Docker Desktop: https://www.docker.com/products/docker-desktop/
- MSYS2: https://www.msys2.org/

---

**维护者**: MoonFlow Team
