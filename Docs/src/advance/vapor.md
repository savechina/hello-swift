# 🌐 Vapor Web 框架

## 开篇故事

想象你要开一家餐厅。你可以自己砌砖盖房、布置厨房、设计菜单、雇服务员——这需要几个月时间。或者，你可以直接租一个装修完毕的商用厨房，里面炉灶、冰箱、排风系统一应俱全，你只需要专注于做菜和定菜单。

Vapor 就是 Swift 世界里的那个"商用厨房"。

HTTP 请求像源源不断的订单，路由（Routes）是前台服务员，把每张单子送到对应的厨师手里。中间件（Middleware）是厨房里的质检员，检查食材新鲜度、记录每道菜的制作日志。Content 协议是标准化餐具规格，确保每个盘子都能放进洗碗机。你不需要操心底层 TCP 连接怎么处理、HTTP 报文怎么解析——Vapor 全都帮你搞定了。

本章要教你的，就是如何在 Swift 里用 Vapor 快速搭建一个 RESTful API 服务。

## 本章适合谁

如果你满足以下任一情况，这一章就是为你准备的：

- 你想用 Swift 编写 Web API 后端服务，而不是只写 iOS/macOS 客户端
- 你听过 Vapor 这个名字，但不清楚它和 Spring Boot / Express.js 有什么区别
- 你需要了解路由定义、JSON 请求/响应体处理、中间件链路这些 Web 框架核心概念
- 你想看看 Swift 在服务器端开发中的实际表现

本章面向已经掌握 Swift 基础语法并了解异步编程（async/await）的开发者。如果你还没有接触过并发编程，建议先回顾 [并发编程](../basic/concurrency.md) 章节。

## 你会学到什么

完成本章后，你将掌握以下内容：

- **路由定义（Routes）**：GET / POST 路由的声明方式，路径参数提取（Path Parameter）
- **Content 协议**：如何用 `Content` protocol 声明请求/响应模型，实现 JSON 自动编解码
- **中间件（Middleware）**：`AsyncMiddleware` 协议的工作原理，日志中间件的编写方式

## 前置要求

在开始之前，请确保你已掌握以下内容：

- Swift 6.0 语法：结构体声明、协议遵守（Protocol Conformance）、属性定义
- 异步编程：`async`/`await`、`try`/`throw` 的错误传递
- JSON 处理：理解 Codable 协议的工作原理（参考 [JSON 处理](./json.md)）
- macOS 12+ 或 Linux (Ubuntu 22.04+) 运行环境

如果你对这些内容还不太熟悉，建议先回顾基础部分（协议 → 并发编程 → JSON 处理），然后再回来。

## 第一个例子

我们先来看一个最基础的例子。目标很明确：创建一个 Vapor 应用，定义一个 GET 路由，当访问 `/api/hello` 时返回一段字符串。

这段代码来自 `AdvanceSample/Sources/AdvanceSample/VaporSample.swift` 第 1 到 11 行。

```swift
import Vapor

let app = Application(.testing)
defer { app.shutdown() }

app.get("api", "hello") { req -> String in
    return "Hello from Vapor!"
}
```

三件事：创建 Application 实例、注册一个 GET 路由、处理返回字符串。注意 `defer { app.shutdown() }` —— 这确保应用退出时资源被正确释放。

在真实项目中，你通常会用 `.production` 或 `.development` 环境，而不是 `.testing`。这里的 `.testing` 让 Vapor 在后台静默运行，不占用终端端口，非常适合示例代码演示。

如果想让服务真正监听端口，可以这样启动：

```swift
try app.start()
print("Vapor server started on http://localhost:\(app.http.server.address?.port ?? 8080)")

// 运行一段时间后优雅关闭
try await app.asyncShutdown()
```

## 原理解析

Vapor 是一个异步 Web 框架，底层基于 SwiftNIO 构建。理解它的核心组件，你就能举一反三。

### Application

`Application` 是整个 Vapor 应用的入口和生命周期管理器。它持有 HTTP 服务器、路由注册表、中间件链、服务容器等一切资源。

```swift
let app = Application(.testing)
defer { app.shutdown() }
```

创建后必须调用 `start()` 启动服务，程序退出前必须调用 `shutdown()` 释放资源。`defer` 是确保即使中间抛出异常，shutdown 也会被执行。

### Routes（路由）

路由的作用是将 HTTP 请求映射到处理函数。Vapor 用路径片段（Path Segments）声明路由：

```swift
// GET /api/hello
app.get("api", "hello") { req -> String in
    return "Hello from Vapor!"
}

// GET /api/users/:id
app.get("api", "users", ":id") { req -> String in
    guard let id = req.parameters.get("id") else {
        throw Abort(.badRequest, reason: "Missing user ID")
    }
    return "User ID: \(id)"
}
```

`:id` 是路径参数（Path Parameter），通过 `req.parameters.get("id")` 提取。如果参数缺失，抛出 `Abort(.badRequest)` 会直接返回 400 状态码。

### Content Protocol（内容协议）

HTTP POST 请求通常携带 JSON 请求体。Vapor 用 `Content` 协议实现自动编解码。你需要定义遵守 `Content` 的结构体：

```swift
struct UserRequest: Content {
    let name: String
    let email: String
}

struct UserResponse: Content {
    let id: String
    let name: String
    let email: String
}

// POST /api/users
app.post("api", "users") { req -> UserResponse in
    let userReq = try req.content.decode(UserRequest.self)
    return UserResponse(id: UUID().uuidString, name: userReq.name, email: userReq.email)
}
```

`Content` 协议自动继承了 `Codable`，所以解码逻辑和 JSON 章节学到的 Codable 完全一致。`req.content.decode(Type.self)` 会把 HTTP Body 的 JSON 解码成你的模型。返回值是 `UserResponse` 的话，Vapor 会自动把它编码成 JSON 作为 HTTP Response Body 返回。

### Middleware（中间件）

中间件是请求处理链上的拦截器。它在请求到达路由处理函数**之前**和**之后**执行自定义逻辑。典型的中间件场景：日志记录、认证校验、CORS 处理、限流。

```swift
struct LoggingMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        print("[Middleware] \(request.method.rawValue) \(request.url.path)")
        let response = try await next.respond(to: request)
        print("[Middleware] Response: \(response.status.code)")
        return response
    }
}
```

`AsyncMiddleware` 协议要求实现 `respond(to:chainingTo:)` 方法。关键理解点：`next.respond(to: request)` 才会把请求传递给链路中的下一个环节（可能是另一个中间件，也可能是最终的路由处理函数）。在这行代码之前，你可以做任何前置处理；在这行之后，你可以查看或修改最终的 Response。

使用方法：

```swift
// 将中间件应用到特定路由组
app.grouped(LoggingMiddleware()).get("api", "protected") { req -> String in
    return "Protected resource"
}
```

`grouped()` 创建一个路由组，组内的所有请求都会经过 `LoggingMiddleware` 处理。这是细粒度中间件绑定方式。你也可以用 `app.middleware.use(LoggingMiddleware())` 将中间件注册为全局中间件。

## 常见错误

以下是最容易踩到的三个坑。

| 错误 | 症状 | 原因 | 修复方式 |
|------|------|------|---------|
| 路由冲突（409 Route Collision） | `Vapor.RouteRegistrationError` | 两条路由注册了相同的方法+路径 | 检查 `app.get/post` 路径是否有重复 |
| 缺少 Content 声明 | 编译报错：`does not conform to Content` | 自定义结构体没有遵守 Content 协议 | 在结构体声明后加 `: Content` |
| 中间件顺序错误 | 认证中间件没有执行 | 注册中间件的顺序不对 | 全局中间件按 `app.middleware.use()` 的调用顺序排列，先 auth 后 log |
| 路径参数未提取 | 路由匹配了但拿到 nil | 路径声明写了 `:id` 但 `req.parameters.get()` 用了别的名字 | 确保 `parameters.get("id")` 和路径段 `":id"` 名称一致 |
| 忘记 shutdown | 测试跑完后进程不退出、端口一直被占用 | 创建 `Application` 后没有 `defer { app.shutdown() }` | 使用 `defer` 块保证资源释放 |

## Swift vs Rust/Python 对比

不同的服务端语言有不同的 Web 框架。放在一起对比会更直观：

| 特性 | Swift (Vapor) | Rust (Axum) | Python (FastAPI) |
|------|------|------|------|
| 应用启动 | `Application(.testing).start()` | `axum::serve(listener, app).await` | `uvicorn.run(app)` |
| GET 路由 | `app.get("api", "hello") { ... }` | `Router::get("/api/hello", handler)` | `@app.get("/api/hello") async def ...` |
| 路径参数 | `req.parameters.get("id")` | `Path(id): Path<String>` | `async def func(id: str)` |
| JSON Body | `try req.content.decode(UserRequest.self)` | `Json(user): Json<UserRequest>` | `user: UserRequest` |
| 请求/响应模型 | `struct: Content` (=Codable) | `struct: Serialize + Deserialize` | `class: BaseModel (Pydantic)` |
| 中间件 | `AsyncMiddleware` 协议 | `tower::Layer` 组合式 | `@app.middleware("http")` |
| 异步模型 | Swift Concurrency (async/await) | Tokio 运行时 + async | asyncio |
| 底层引擎 | SwiftNIO (非阻塞 I/O) | hyper / tokio | uvicorn (ASGI) |
| 类型安全 | 编译期检查 | 编译期检查 | 运行期检查 |

Swift 的 Vapor 和 Rust 的 Axum 在设计理念上高度一致：路由声明 + 类型安全请求/响应模型 + 组合式中间件。Python 的 FastAPI 更倾向于用装饰器语法，开发速度快但缺少编译期保证。

## 动手练习 Level 1

**目标**：添加一个 DELETE 端点。

现在你已经有了 GET /api/hello、GET /api/users/:id 和 POST /api/users。你的任务是添加一个 `DELETE /api/users/:id` 端点：

1. 在 `app` 上注册 DELETE 路由：`app.delete("api", "users", ":id")`
2. 提取路径参数 `id`
3. 返回字符串 `"Deleted user: \(id)"`
4. 如果 `id` 缺失，抛出 `Abort(.badRequest, reason: "Missing user ID")`

<details>
<summary>点击查看答案</summary>

```swift
app.delete("api", "users", ":id") { req -> String in
    guard let id = req.parameters.get("id") else {
        throw Abort(.badRequest, reason: "Missing user ID")
    }
    return "Deleted user: \(id)"
}
```

注意：`delete` 方法和 `get/post` 的调用方式完全一致，只是 HTTP Method 不同。Vapor 会为每种 HTTP Method 提供对应的方法名。
</details>

## 动手练习 Level 2

**目标**：添加请求验证中间件。

在 POST /api/users 之前，你需要验证请求体中 `name` 字段非空且 `email` 包含 `@`。编写一个 `ValidationMiddleware`：

1. 创建一个结构体 `ValidationMiddleware`，遵守 `AsyncMiddleware`
2. 在 `respond(to:chainingTo:)` 方法中，先检查请求方法是否为 POST
3. 对 POST 请求，打印 `[Validation] Checking request body...`
4. 调用 `next.respond(to: request)` 继续链路
5. 打印 `[Validation] Request passed`

<details>
<summary>点击查看答案</summary>

```swift
struct ValidationMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        if request.method == .POST {
            print("[Validation] Checking request body...")
            // 实际项目里这里应该 decode body 并验证
            // 但 middleware 里直接 decode 会消耗 body，
            // 所以简单示例只做日志记录
        }
        let response = try await next.respond(to: request)
        if request.method == .POST {
            print("[Validation] Request passed")
        }
        return response
    }
}

// 使用
app.grouped(ValidationMiddleware()).post("api", "users", use: createUserHandler)
```

注意：在真实项目中，中间件里解码 body 会导致 body 被消费，下游路由无法再读取。Vapor 提供了 `Request.BodyStream` 的缓冲机制来解决这个问题。实际验证通常放在路由处理函数内部，而不是中间件里。
</details>

## 动手练习 Level 3

**目标**：构建一个完整的 "Todo" 资源 CRUD API。

用 Vapor 实现以下四个端点：

| Method | Path | 描述 | 请求体 | 响应体 |
|--------|------|------|--------|--------|
| POST | /api/todos | 创建 Todo | `TodoRequest(title: String)` | `TodoResponse(id, title, done)` |
| GET | /api/todos | 列出所有 Todo | 无 | `[TodoResponse]` |
| GET | /api/todos/:id | 获取单个 Todo | 无 | `TodoResponse` |
| DELETE | /api/todos/:id | 删除 Todo | 无 | `String` |

提示：用一个 `var todos: [TodoResponse] = []` 数组模拟数据库。

<details>
<summary>点击查看答案</summary>

```swift
// 1. 定义 Content 模型
struct TodoRequest: Content {
    let title: String
}

struct TodoResponse: Content {
    let id: String
    let title: String
    let done: Bool
}

// 2. 模拟数据库
var todos: [TodoResponse] = []

// 3. 创建 Application
let app = Application(.testing)
defer { app.shutdown() }

// 4. POST /api/todos
app.post("api", "todos") { req -> TodoResponse in
    let reqBody = try req.content.decode(TodoRequest.self)
    let todo = TodoResponse(
        id: UUID().uuidString,
        title: reqBody.title,
        done: false
    )
    todos.append(todo)
    return todo
}

// 5. GET /api/todos
app.get("api", "todos") { req -> [TodoResponse] in
    return todos
}

// 6. GET /api/todos/:id
app.get("api", "todos", ":id") { req -> TodoResponse in
    guard let id = req.parameters.get("id"),
          let todo = todos.first(where: { $0.id == id }) else {
        throw Abort(.notFound, reason: "Todo not found")
    }
    return todo
}

// 7. DELETE /api/todos/:id
app.delete("api", "todos", ":id") { req -> String in
    guard let id = req.parameters.get("id") else {
        throw Abort(.badRequest, reason: "Missing todo ID")
    }
    guard let index = todos.firstIndex(where: { $0.id == id }) else {
        throw Abort(.notFound, reason: "Todo not found")
    }
    todos.remove(at: index)
    return "Deleted todo: \(id)"
}
```

关键点：
- `Abort(.notFound)` 会返回 404 状态码，这是 REST API 的标准做法
- 返回数组类型 `[TodoResponse]` 时，Vapor 自动将它编码为 JSON 数组
- 内存中数组 `var todos` 在应用重启后会丢失数据，生产环境应该使用数据库
</details>

## 故障排查 FAQ

**Q1：`Application(.testing)` 启动后为什么访问不到服务？**

`.testing` 模式下，Vapor 不会启动实际的 TCP 监听。它只注册路由，让你可以用 `app.test(.GET, "api/hello")` 做单元测试。如果要真正监听端口，使用 `.development` 或 `.production` 并调用 `try app.start()`。

**Q2：`req.content.decode()` 时报 `content.source` 错误怎么办？**

这说明请求没有 Content-Type header 或 body 为空。确保客户端发送请求时设置了 `Content-Type: application/json`，并且请求体是合法的 JSON。

**Q3：中间件里打印的 `[Middleware]` 日志没有出现？**

检查中间件是否正确绑定。如果用 `app.grouped()...` 注册，中间件只作用于该组内的路由。如果希望全局生效，改用 `app.middleware.use(MyMiddleware())`。

**Q4：路径参数 `:id` 匹配的是 `nil`？**

确认路径声明和参数提取使用的是同一个名字。路径写 `":id"` 就必须用 `req.parameters.get("id")`。名字大小写也要一致。另外，Vapor 的路径匹配是按注册顺序进行的，如果前面的路由已经匹配了这个路径，后面的可能就不会执行。

**Q5：`Abort(.badRequest)` 和直接 `throw` 有什么区别？**

`Abort` 是 Vapor 特有的错误类型，它直接映射到 HTTP 状态码。`Abort(.badRequest)` 返回 400，`Abort(.notFound)` 返回 404。如果你 throw 一个普通 Error，Vapor 会默认返回 500 Internal Server Error。

**Q6：Vapor 可以跑在 Linux 服务器上吗？**

可以。Vapor 完全支持 Linux (Ubuntu 20.04/22.04)。事实上，Vapor 的主要部署场景就是 Linux 服务器 + Docker 容器化部署。只需要保证 Swift 6.0+ 工具链已安装即可。

**Q7：多个中间件注册时，执行顺序是怎样的？**

中间件按注册顺序**正向**执行（before 逻辑），按注册顺序**反向**执行（after 逻辑）。比如注册 A、B 两个中间件，执行流程是：A.before -> B.before -> handler -> B.after -> A.after。这和其他框架（如 Express.js、Koa）的洋葱模型是一致的。

## 小结

- Vapor 是 Swift 生态中最成熟的 Web 框架，底层基于 SwiftNIO 的异步 I/O 模型
- 路由声明用路径片段（Path Segments），参数用 `req.parameters.get()` 提取，HTTP Method 对应不同方法名
- `Content` 协议让请求/响应体的 JSON 编解码和 Codable 无缝对接，不需要额外配置
- 中间件（`AsyncMiddleware`）是请求链路中的拦截器，通过 `next.respond(to:)` 控制请求流转

## 术语表

| 中文 | 英文 | 说明 |
|------|------|------|
| 路由 | Route | HTTP 请求路径和处理函数的映射关系 |
| 中间件 | Middleware | 请求处理链上的拦截器，在 handler 前后执行自定义逻辑 |
| 内容协议 | Content Protocol | Vapor 中请求/响应体的编解码协议，继承自 Codable |
| 路径参数 | Path Parameter | URL 路径中的动态部分，如 `/users/:id` 中的 `id` |
| 异步响应器 | AsyncResponder | 中间件中代表下一个处理环节的接口类型 |
| 应用 | Application | Vapor 应用的入口和生命周期管理器 |
| Abort | Abort | Vapor 特有的错误类型，直接映射为 HTTP 状态码 |

## 知识检查

用三个问题检验你是否真正掌握了本节内容。

**问题一**：在 Vapor 中，如果你想让一个结构体能自动解析 JSON 请求体并编码为 JSON 响应体，这个结构体需要遵守什么协议？

<details>
<summary>查看答案</summary>

需要遵守 `Content` 协议。`Content` 协议内部继承了 `Codable`，所以解码/编码逻辑和 JSON 章节中学习的 Codable 完全一致。声明方式：`struct UserRequest: Content { ... }`。

</details>

**问题二**：以下 Vapor 中间件代码中，`next.respond(to: request)` 这行代码的含义是什么？如果删掉这行会发生什么？

```swift
struct LogMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        print("Request received")
        let response = try await next.respond(to: request)
        print("Response sent: \(response.status.code)")
        return response
    }
}
```

<details>
<summary>查看答案</summary>

`next.respond(to: request)` 的含义是：把请求传递给链路中的下一个处理者（可能是另一个中间件，也可能是最终的路由 handler）。如果删掉这行，请求链就在这里终止了——路由 handler 不会被执行，客户端会收到一个空的或超时的响应。中间件必须要么调用 `next.respond(to: request)`，要么自己返回一个 Response（比如 403 拒绝），否则整个请求就无法完成。

</details>

**问题三**：在 Vapor 中，`app.get("api", "users", ":id")` 和 `app.get("api", "users", "profile")` 哪个会先匹配到请求 `GET /api/users/profile`？

<details>
<summary>查看答案</summary>

这取决于路由注册的顺序。Vapor 按照路由注册的顺序进行匹配。如果 `:id` 先注册，`profile` 作为字符串字面量匹配在 `:id` 之后，那么 `:id` 会先匹配成功，把 `profile` 作为 `id` 参数的值。如果 `profile` 先注册，那么它会优先匹配成功。最佳实践是：始终先注册固定路径（字面量），再注册通配路径（路径参数），否则通配路径会吞噬后续的固定路径。

</details>

## 继续学习

Vapor 帮你处理了 HTTP 层面的请求和响应，数据已经从客户端到达了你的 Swift 代码中。下一步，你需要考虑如何把这些数据持久化存储。

继续学习下一节：[GRDB 数据库](./grdb.md)，你将学会如何用 SQLite 持久化存储 Vapor API 接收到的数据。

如果你想回顾高级进阶的整体路线图，可以返回 [高级概览](./advance-overview.md)。
