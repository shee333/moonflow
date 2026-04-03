# MoonBit 后端路线图

**状态**: 研究中
**最后更新**: 2026-04-03

---

## 目标

使用 MoonBit 实现完整的后端服务，替代 Node.js。

---

## 研究结果

### 可用的 MoonBit 技术

#### 1. `moonbitlang/async` - 异步编程库

```moonbit
import moonbitlang/async
import moonbitlang/async/http
import moonbitlang/async/tcp
```

**可用函数**:
- `@http.run_server` - 启动 HTTP 服务器
- `@socket.Addr::parse` - 解析网络地址
- `@tcp.Conn` - TCP 连接

**示例**:
```moonbit
let addr = @socket.Addr::parse("[::]:8080") |> @result.unwrap
@http.run_server(addr, fn(conn, _addr) {
  handle_connection(conn)
})
```

#### 2. `moonbitlang/core/json` - JSON 处理

**API** (待确认):
- `@json.stringify` - 序列化 JSON
- `@json.parse` - 解析 JSON

#### 3. `moonbitlang/core/pipe` - 标准输出

**API** (待确认):
- `@pipe.stdout.write` - 写入标准输出
- `@pipe.stderr.write` - 写入标准错误

#### 4. `moonbitlang/core/datetime` - 日期时间

**API** (待确认):
- `@datetime.now()` - 获取当前时间
- `@datetime.to_string` - 转换为字符串

---

## 已知问题

### 1. API 不确定性

- 不同版本的 `moonbitlang/async` API 可能变化
- 需要更多文档和示例

### 2. 字符串处理

- MoonBit 字符串是 UTF-16 编码
- 多行字符串需要特殊语法

### 3. HTTP 库限制

- 目前只有基础的 TCP 连接
- 需要手动实现 HTTP 协议解析
- 没有高级的 HTTP 路由框架

### 4. 包管理

- 某些包（如 `allwefantasy/requests`）不在 registry 中
- 需要寻找替代方案

---

## 实施方案

### 阶段 1: 基础 HTTP 服务器

```moonbit
package moonflow_server

import moonbitlang/async
import moonbitlang/async/http
import moonbitlang/async/tcp
import moonbitlang/async/pipe

pub fn start_server~(port~ : Int = 8080) -> Unit {
  let addr = @socket.Addr::parse("[::]:\{port}") |> @result.unwrap
  @pipe.stdout.write("MoonFlow Server Starting on port \{port}\n")
  @http.run_server(addr, fn(conn, _addr) {
    handle_request(conn)
  })
}

fn handle_request(conn : @tcp.Conn) -> Unit {
  let request = conn.read(4096) |> @result.unwrap_or("")
  if request.is_empty() {
    return
  }
  
  let response = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nHello"
  conn.write(response)
  conn.close()
}
```

### 阶段 2: 路由和请求处理

需要实现:
- HTTP 方法解析
- URL 路由
- 请求头解析
- 请求体读取

### 阶段 3: 工作流执行引擎

集成现有的 `core/src/runtime/` 模块。

---

## 参考资源

1. **MoonBit HTTP Server 教程**
   - https://www.moonbitlang.com/pearls/2025/10/22/moonbit-http-server
   - 详细的 async 编程指南

2. **MoonBit 官方文档**
   - https://www.moonbitlang.com/docs/
   - API 参考

3. **MoonBit async 库源码**
   - https://github.com/moonbitlang/async

---

## 时间估算

| 阶段 | 任务 | 复杂度 | 优先级 |
|------|------|--------|--------|
| 1 | 基础 HTTP 服务器 | 中 | P0 |
| 2 | 路由和请求处理 | 高 | P0 |
| 3 | 工作流执行集成 | 高 | P1 |
| 4 | LLM API 集成 | 中 | P1 |
| 5 | 测试和部署 | 中 | P2 |

---

## 替代方案

如果 MoonBit 后端实现过于复杂，可以考虑：

1. **WASM 后端**: 将 MoonBit 编译为 WebAssembly，在浏览器中运行
2. **边缘计算**: 使用 MoonBit WASM 实现边缘节点
3. **混合架构**: MoonBit 处理计算密集任务，Node.js 处理网络

---

## 下一步行动

1. [ ] 研究 `moonbitlang/async` 的准确 API
2. [ ] 创建简单的 HTTP 服务器原型
3. [ ] 验证 MoonBit 原生编译
4. [ ] 实现基础的路由系统
5. [ ] 集成工作流执行引擎

---

## 备注

- MoonBit 是新兴语言，生态系统仍在发展中
- 建议关注 MoonBit 官方更新
- 考虑参与社区贡献

---

**维护者**: MoonFlow Team
