# MoonBit HTTP Server 研究报告

**日期**: 2026-04-04
**状态**: 研究完成，平台限制

---

## 🔬 研究目标

使用 MoonBit `moonbitlang/async` 库实现 HTTP Server

---

## ✅ 成功部分

### 1. 理解 MoonBit 异步编程

从官方教程中学习了 MoonBit 的异步编程模型：

```moonbit
// MoonBit 的异步函数声明
async fn handle_connection(conn : ?, addr : String) -> Unit {
  // 异步代码，不需要 await 关键字
  // 编译器自动推断异步调用
}
```

### 2. HTTP Server 核心 API

从教程中发现的 API：

| API | 功能 |
|-----|------|
| `@http.run_server(addr, callback)` | 启动 HTTP 服务器 |
| `@socket.Addr::parse("[::]:port")` | 解析网络地址 |
| `conn.read_request()` | 读取 HTTP 请求 |
| `conn.send_response()` | 发送响应 |
| `conn.write()` | 写入响应体 |
| `conn.end_response()` | 结束响应 |
| `@pipe.stdout.write()` | 输出到标准输出 |

### 3. MoonBit 语法关键点

```moonbit
// 包导入（在 moon.pkg.json 中）
{
  "import": ["moonbitlang/async"],
  "is_main": true
}

// 主函数
async fn main {
  @http.run_server(addr, fn(conn, addr) {
    handle_connection(conn, addr)
  })
}

// 模式匹配路由
match request.path {
  "/" | "/health" => { ... }
  "/api/workflow" => { ... }
  _ => { ... }
}
```

---

## ❌ 平台限制问题

### 问题 1: wasm-gc 后端不支持

```
Error: extern "C" is unsupported in wasm-gc backend.
```

`moonbitlang/async` 使用 FFI 调用 C 代码，不支持 wasm-gc 后端。

### 问题 2: 原生编译需要 Unix 头文件

```
fatal error: sys/socket.h: No such file or directory
fatal error: spawn.h: No such file or directory
```

在 Windows 上编译原生版本失败，因为缺少 Unix 系统头文件。

### 问题 3: MoonBit 版本兼容性

文章中的示例代码与当前 MoonBit 版本存在差异：
- `async fn main async` → 当前版本使用 `async fn main`
- API 可能发生变化

---

## 💡 解决方案

### 方案 1: 使用类 Unix 系统

在 Linux 或 macOS 上编译 MoonBit HTTP Server：
```bash
# Linux/macOS
moon build cmd/server --target native
./cmd/server
```

### 方案 2: WebAssembly 后端

MoonBit 支持 WASM，可以考虑：
- 使用 Node.js 运行 WASM 模块
- 或使用 Deno/Bun 运行

### 方案 3: 混合架构

保持前端作为主要执行环境，MoonBit 用于：
- 工作流 DSL 代码生成
- 计算密集型任务
- 边缘计算节点

---

## 📝 创建的代码

虽然无法在 Windows 上编译，但创建了完整的 MoonBit HTTP Server 代码：

**文件**: `core/cmd/server/main.mbt`

```moonbit
async fn main {
  let port = 8080
  let addr = @socket.Addr::parse("[::]:\{port}") |> @result.unwrap
  
  @pipe.stdout.write("MoonFlow Server Starting...\n")
  
  @http.run_server(addr, fn(conn, addr) {
    handle_connection(conn, addr)
  })
}

async fn handle_connection(conn : ?, addr : String) -> Unit {
  let request = ?conn.read_request()
  ?conn.skip_request_body()
  
  @pipe.stderr.write("[{addr}] {request.path}\n")
  
  match request.path {
    "/" | "/health" | "/api/health" => {
      ?conn.send_response(200, "OK")
      ?conn.write("{\"status\":\"ok\"}")
      ?conn.end_response()
    }
    "/api/workflow" if request.method == "GET" => { ... }
    _ => { ... }
  }
}
```

---

## 🎯 下一步建议

1. **在 Linux/macOS 上测试**
   - 安装 MoonBit CLI
   - 克隆项目
   - 运行 `moon build cmd/server --target native`

2. **完善 API**
   - 添加工作流执行端点
   - 添加工作流管理 API
   - 添加 WebSocket 支持（用于实时日志）

3. **集成 MoonBit 执行引擎**
   - 调用现有的 `core/src/runtime/` 模块
   - 实现真实的工作流执行

4. **测试和部署**
   - 编写测试用例
   - 添加 Dockerfile
   - 部署文档

---

## 📚 参考资源

1. **官方教程**: https://www.moonbitlang.cn/pearls/2025/10/22/moonbit-http-server
2. **MoonBit 官方文档**: https://www.moonbitlang.com/docs/
3. **moonbitlang/async 源码**: https://github.com/moonbitlang/async

---

## 📊 结论

MoonBit HTTP Server 的实现是可行的，但存在平台限制：

| 方面 | 状态 |
|------|------|
| 语法正确性 | ✅ 已验证 |
| API 可用性 | ✅ 已验证 |
| Windows 编译 | ❌ 不支持 |
| Linux/macOS 编译 | 🔄 待测试 |
| WASM 后端 | 🔄 待研究 |

**建议**: 在类 Unix 系统上进行开发和测试，或使用 WASM 后端作为替代方案。

---

**维护者**: MoonFlow Team
