# 阶段复习：高级进阶

完成高级进阶部分的八个章节后，让我们通过本复习章节巩固所学知识。

---

## 📋 知识回顾

### Phase 1: 数据处理与持久化

#### 1. JSON 处理

**核心概念**:
- **JSONSerialization**: Foundation 传统方法，返回 `Any` 类型，需要手动转换
- **JSONDecoder/Codable**: 类型安全的现代方法，自动映射到 Swift 类型
- **SwiftyJSON**: 第三方库，动态成员查找简化深层访问
- **CodingKeys**: 自定义 JSON 键名与 Swift 属性名的映射

**关键要点**:
- Codable 是 `Encodable + Decodable` 的组合
- 避免使用 `try!` 强制解包，使用 `do/catch/try` 处理错误
- 可选字段使用 `decodeIfPresent` 或可选类型属性

---

#### 2. 文件操作

**核心概念**:
- **FileManager**: 文件系统操作的核心类
- **标准目录**: Documents（用户数据）、Caches（缓存）、Temp（临时）、Application Support（配置）
- **TemporaryFile**: RAII 模式，`deinit` 自动清理
- **AsyncLineSequence**: 异步流式读取大文件

**关键要点**:
- Documents 和 Application Support 会备份，Caches 和 Temp 不备份
- 使用 `FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)` 获取路径
- Linux 平台无 Documents/Caches 概念，使用 `currentDirectoryPath`
- `@available(macOS 12.0, *)` 检查 async API 可用性

---

#### 3. SwiftData 持久化

**核心概念**:
- **@Model**: 数据模型宏，自动生成持久化代码
- **ModelContainer**: 数据库容器，配置存储位置
- **ModelContext**: 操作上下文，执行 CRUD
- **FetchDescriptor**: 查询配置，包含 predicate 和 sort
- **#Predicate**: 查询条件宏，编译期检查
- **@ModelActor**: Actor 模式，后台线程安全操作

**关键要点**:
- SwiftData requires macOS 14.0+
- 必须提供初始化器（`@Model` 要求）
- 跨 Actor 传递 `PersistentIdentifier`，不能传递模型对象
- 使用 `ModelConfiguration(isStoredInMemoryOnly: true)` 测试模式

---

#### 4. 环境配置

**核心概念**:
- **ProcessInfo.processInfo.environment**: 读取系统环境变量
- **swift-dotenv**: 加载 `.env` 文件
- **Dotenv.configure()**: 初始化并加载配置
- **动态成员查找**: `Dotenv.apiKey` 直接访问

**关键要点**:
- API 密钥等敏感信息不要硬编码
- `.env` 文件不要提交到 Git（添加到 `.gitignore`）
- 开发/生产环境切换使用不同的 `.env` 文件
- 使用 `Dotenv["KEY"]` 或 `Dotenv.key?.stringValue` 访问值

---

### Phase 2: 网络与系统编程

#### 5. SwiftNIO 网络基础

**核心概念**:
- **EventLoop**: 单线程事件循环，管理多个网络连接
- **Channel**: 网络连接抽象，由 Pipeline 和 Handler 组成
- **ChannelHandler**: 入站/出站数据处理单元
- **ByteBuffer**: 高效字节容器，零拷贝设计
- **ServerBootstrap**: TCP 服务器启动器

**关键要点**:
- 一个 EventLoop 可以管理数千连接，避免线程爆炸
- ChannelHandler 分为 InboundHandler 和 OutboundHandler
- ByteBuffer 的 slice 操作不复制数据（零拷贝）
- 不要在 EventLoop 线程使用 Thread.sleep（会阻塞所有连接）

---

#### 6. SwiftNIO async/await 集成

**核心概念**:
- **Future → async 桥接**: withCheckedContinuation 转换回调式 API
- **NIOLoopBoundBox**: 跨 Actor 安全访问 EventLoop-bound 值
- **NIOAsyncChannel**: SwiftNIO 2.40+ 原生 async/await API
- **Sendable 约束**: Channel 不是 Sendable，需要包装

**关键要点**:
- 不要在 async 函数中调用 `future.wait()`（会阻塞底层线程）
- NIOLoopBoundBox 保证在正确的 EventLoop 上操作 Channel
- NIOAsyncChannel 提供 AsyncSequence 接口，简化代码
- Actor 内部不能用 Channel，需要用 NIOLoopBoundBox 包装

---

#### 7. 系统编程

**核心概念**:
- **Process**: Foundation 进程执行类，捕获 stdout/stderr
- **Pipe**: 进程间通信的数据流
- **Signal**: SIGINT/SIGTERM 捕获，优雅关闭
- **跨平台路径**: macOS Documents/Caches vs Linux HOME/tmp

**关键要点**:
- Process.run() 非阻塞，waitUntilExit() 阻塞等待
- 使用 Pipe 捕获子进程输出
- Linux 没有 Documents 目录，使用 HOME 或 currentDirectoryPath
- Signal Handler 应只设置标志，主循环处理清理逻辑

---

#### 8. 测试框架

**核心概念**:
- **XCTestCase**: 测试类基类，setUp/tearDown 生命周期
- **断言方法**: XCTAssertEqual、XCTAssertTrue、XCTAssertThrowsError 等
- **async 测试**: 测试方法标记 async，使用 await
- **measure {}**: 性能测试，测量执行时间

**关键要点**:
- 测试方法必须以 `test` 开头
- setUp 在每个测试前执行，tearDown 在每个测试后执行
- @testable import 可访问 internal 成员
- swift test --filter 只运行部分测试

---

## 🧪 综合练习

### 练习 1: JSON + 文件 + SwiftData

**任务**: 编写一个应用，读取 JSON API 响应，解析数据，写入临时文件，并存储到 SwiftData。

**步骤**:
1. 使用 JSONDecoder 解析 API 返回的用户 JSON
2. 将解析结果写入临时文件（用于调试）
3. 使用 @Model 定义 User 模型
4. ModelContext.insert() 存储到数据库

<details>
<summary>点击查看提示</summary>

```swift
// 1. 解析 JSON
let decoder = JSONDecoder()
let users = try decoder.decode([User].self, from: jsonData)

// 2. 写入临时文件
let tempFile = try TemporaryFile(content: String(data: jsonData, encoding: .utf8)!)

// 3. 定义 @Model
@Model
class User {
    var id: UUID
    var name: String
    var email: String
    
    init(name: String, email: String) {
        self.id = UUID()
        self.name = name
        self.email = email
    }
}

// 4. 存储到数据库
for user in users {
    modelContext.insert(user)
}
```

</details>

---

### 练习 2: SwiftNIO Echo Server + Process 测试

**任务**: 创建 SwiftNIO Echo Server，使用 Process 执行 telnet 测试连接。

**步骤**:
1. ServerBootstrap 创建 TCP 服务器监听 8080
2. EchoHandler 收到消息原样返回
3. Process 执行 telnet 连接测试

<details>
<summary>点击查看提示</summary>

```swift
// 1. 创建 Echo Server
let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let bootstrap = ServerBootstrap(group: group)
    .childChannelInitializer { channel in
        channel.pipeline.addHandler(EchoHandler())
    }
let server = try bootstrap.bind(host: "127.0.0.1", port: 8080).wait()

// 2. EchoHandler 实现
final class EchoHandler: ChannelInboundHandler {
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        context.write(data, promise: nil)
    }
    func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }
}

// 3. Process 测试
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/telnet")
process.arguments = ["127.0.0.1", "8080"]
process.run()
```

</details>

---

### 练习 3: XCTest 测试覆盖

**任务**: 为 Process 执行函数编写 XCTest 测试。

**步骤**:
1. 测试正常命令执行（如 /bin/ls）
2. 测试错误命令路径
3. 测试输出捕获
4. async 测试异步执行

<details>
<summary>点击查看提示</summary>

```swift
final class ProcessTests: XCTestCase {
    
    func testExecuteLs() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/ls")
        process.arguments = ["-la"]
        
        process.run()
        process.waitUntilExit()
        
        XCTAssertEqual(process.terminationStatus, 0)
    }
    
    func testCaptureOutput() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/echo")
        process.arguments = ["test"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        XCTAssertTrue(output.contains("test"))
    }
    
    func testAsyncExecute() async throws {
        let result = await withCheckedContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/ls")
            process.run()
            process.waitUntilExit()
            continuation.resume(returning: process.terminationStatus)
        }
        XCTAssertEqual(result, 0)
    }
}
```

</details>

---

## ✅ 知识检查

### Phase 1 问题

**问题 1: Swift 中解析 JSON 有哪三种主要方法？各自的优缺点是什么？**

<details>
<summary>点击查看答案</summary>

| 方法 | 优点 | 缺点 |
|------|------|------|
| JSONSerialization | Foundation 内置，无需额外依赖 | 返回 `Any`，需要手动类型转换，易出错 |
| JSONDecoder/Codable | 类型安全，编译期检查，自动映射 | 需要定义 Codable 类型，灵活性较低 |
| SwiftyJSON | 动态访问，深层嵌套简化，容错性强 | 第三方依赖，性能略低 |

</details>

---

**问题 2: FileManager 的 Documents、Caches、Temp 目录有什么区别？**

<details>
<summary>点击查看答案</summary>

| 目录 | 用途 | 备份 | 清理 |
|------|------|------|------|
| Documents | 用户文档、重要数据 | iTunes 备份 | 不会自动清理 |
| Caches | 缓存数据、下载临时文件 | 不备份 | 系统空间不足时可能清理 |
| Temp | 短期临时文件 | 不备份 | 系统重启或定期清理 |
| Application Support | 应用配置、数据库 | iTunes 备份 | 不会自动清理 |

</details>

---

**问题 3: SwiftData 的 @ModelActor 模式解决了什么问题？如何正确使用？**

<details>
<summary>点击查看答案</summary>

**解决的问题**: 
- SwiftData 模型对象不是 `Sendable`，无法直接跨 Actor 传递
- 主线程数据库操作会阻塞 UI

**正确使用方法**:
1. 定义 `@ModelActor` actor 类
2. 在 actor 内使用 `modelContext` 执行操作
3. 返回 `PersistentIdentifier` 而不是模型对象
4. 在调用端通过 ID 加载模型

```swift
@ModelActor
actor DataImporter {
    func importUsers(from data: Data) throws -> [PersistentIdentifier] {
        let users = try JSONDecoder().decode([User].self, from: data)
        for user in users {
            modelContext.insert(user)
        }
        try modelContext.save()
        return users.map { $0.id }
    }
}
```

</details>

---

### Phase 2 问题

**问题 4: 为什么不能在 EventLoop 线程调用 Thread.sleep？正确的替代方法是什么？**

<details>
<summary>点击查看答案</summary>

**原因**:
- EventLoop 是单线程，管理数千连接
- Thread.sleep 阻塞整个线程，所有连接的处理都会卡住
- 这违反了 SwiftNIO 的非阻塞设计原则

**正确替代**:
- 使用 `eventLoop.scheduleTask(in: .seconds(1)) { }`
- 使用 Swift Concurrency 的 `Task.sleep(nanoseconds:)`
- 使用 continuation 桥接 async 函数

</details>

---

**问题 5: NIOLoopBoundBox 的作用是什么？如何使用？**

<details>
<summary>点击查看答案</summary>

**作用**:
- 包装 EventLoop-bound 值（如 Channel），使其符合 Sendable
- 保证跨 Actor 访问时在正确的 EventLoop 上操作

**使用方法**:
```swift
let box = NIOLoopBoundBox(channel, eventLoop: eventLoop)

// 跨 Actor 使用
try await box.withValue { channel in
    // 这里在 channel 的 EventLoop 上执行
    channel.writeAndFlush(data, promise: nil)
}
```

</details>

---

**问题 6: Process 的 run() 和 waitUntilExit() 有什么区别？**

<details>
<summary>点击查看答案</summary>

| 方法 | 作用 | 阻塞性 |
|------|------|--------|
| run() | 启动子进程 | 非阻塞，立即返回 |
| waitUntilExit() | 等待子进程完成 | 阻塞，直到进程退出 |
| terminate() | 发送 SIGTERM | 非阻塞，请求终止 |

**关键点**:
- run() 后进程独立运行，父进程继续执行
- waitUntilExit() 阻塞父进程，等待子进程
- 正确顺序：run() → (可选操作) → waitUntilExit()

</details>

---

**问题 7: XCTestCase 的 setUp 和 tearDown 在什么时候执行？**

<details>
<summary>点击查看答案</summary>

**执行时机**:
- setUp: 在**每个**测试方法执行前调用
- tearDown: 在**每个**测试方法执行后调用
- 执行顺序: setUp → testMethod → tearDown → setUp → nextTestMethod → tearDown

**关键点**:
- 每个测试前后都执行，保证测试隔离
- setUp 用于初始化共享资源
- tearDown 用于清理资源，防止测试间影响

</details>

---

### Phase 3 问题

**问题 8: Vapor 的路由和中间件是如何工作的？**

<details>
<summary>点击查看答案</summary>

**路由**:
- `app.get("api", "hello") { req in ... }` 将 URL 路径映射到处理函数
- 支持 GET/POST/PUT/DELETE 等 HTTP 方法
- 路径参数通过 `req.parameters.get("id")` 提取

**中间件**:
- 实现 `AsyncMiddleware` 协议，`respond(to:chainingTo:)` 方法
- 在请求到达路由前或响应返回前拦截
- 使用 `app.grouped(middleware)` 创建中间件组

</details>

---

**问题 9: GRDB 的 FetchableRecord 和 PersistableRecord 有什么区别？**

<details>
<summary>点击查看答案</summary>

| 协议 | 作用 | 方法 |
|------|------|------|
| FetchableRecord | 从数据库行解码为 Swift 类型 | `init(row:)` |
| PersistableRecord | 将 Swift 类型写入数据库 | `encode(to:)`, `insert()`, `update()` |

通常同时遵循两个协议实现完整的 CRUD 能力。

</details>

---

**问题 10: Actor 和 Class 的主要区别是什么？**

<details>
<summary>点击查看答案</summary>

| 特性 | Actor | Class |
|------|-------|-------|
| 并发安全 | ✅ 编译器保证 | ❌ 需要手动同步 |
| 访问方式 | 需要 `await` | 直接访问 |
| 引用语义 | 值语义（隔离） | 引用语义 |
| 继承 | 不支持 | 支持 |
| 适用场景 | 共享可变状态 | 需要继承或引用语义 |

</details>

---

**问题 11: some 和 any 在什么场景下使用？**

<details>
<summary>点击查看答案</summary>

- **`some Protocol`**: 返回单一具体类型，隐藏实现细节，零性能开销。适用于 API 返回值、SwiftUI `body`。
- **`any Protocol`**: 存储异构集合，运行时类型擦除，有动态分发开销。适用于 `[any Shape]` 数组。

</details>

---

**问题 12: Property Wrapper 的 wrappedValue 和 projectedValue 有什么区别？**

<details>
<summary>点击查看答案</summary>

- **wrappedValue**: 属性的实际值，通过 `property` 访问
- **projectedValue**: 包装器暴露的额外接口，通过 `$property` 访问
- 典型例子：SwiftUI 的 `@State var count` → `count` 是值，`$count` 是 Binding

</details>

---

## 📈 自我评估

完成以下检查项，评估你的掌握程度：

### Phase 1 掌握度

- [ ] 能够使用 JSONDecoder 解析嵌套 JSON 并处理可选字段
- [ ] 能够使用 CodingKeys 自定义 JSON 键名映射
- [ ] 能够正确获取 Documents/Caches/Temp 目录路径
- [ ] 能够创建临时文件并理解 RAII 自动清理机制
- [ ] 能够使用 AsyncLineSequence 流式读取大文件
- [ ] 能够定义 @Model 数据类并提供初始化器
- [ ] 能够配置 ModelContainer 并执行 CRUD 操作
- [ ] 能够使用 #Predicate 和 FetchDescriptor 查询数据
- [ ] 能够使用 @ModelActor 在后台线程安全操作数据库
- [ ] 能够使用 ProcessInfo 读取系统环境变量
- [ ] 能够使用 swift-dotenv 加载 .env 文件

### Phase 2 掌握度

- [ ] 理解 EventLoop 如何在单线程管理多连接
- [ ] 能够创建 SwiftNIO Echo Server
- [ ] 能够使用 ByteBuffer 读写数据并理解零拷贝
- [ ] 能够将 EventLoopFuture 桥接到 async/await
- [ ] 理解 NIOLoopBoundBox 解决的问题
- [ ] 能够使用 Process 执行命令并捕获输出
- [ ] 理解 Signal 处理的注意事项
- [ ] 知道 macOS 和 Linux 的路径差异
- [ ] 能够编写 XCTestCase 测试类
- [ ] 能够使用 async 测试方法
- [ ] 能够使用 measure {} 性能测试

### Phase 3 掌握度

- [ ] 能够使用 Vapor 创建 REST API 和路由
- [ ] 理解 Vapor 中间件的工作原理
- [ ] 能够使用 GRDB 定义 Record 并执行 CRUD
- [ ] 理解 QueryInterface 的类型安全查询
- [ ] 能够定义 Actor 并理解隔离域
- [ ] 理解 Sendable 协议和编译器并发检查
- [ ] 能够定义自定义 Property Wrapper
- [ ] 理解 wrappedValue 和 projectedValue 的区别
- [ ] 能够使用 weak/unowned 打破 ARC 循环引用
- [ ] 理解 some vs any 的选择策略
- [ ] 能够使用 withUnsafeBufferPointer 安全访问指针
- [ ] 理解 MemoryLayout 的 size/stride/alignment
- [ ] 理解 Swift Macros 的编译时代码生成机制
- [ ] 能够定义自定义 Result Builder
- [ ] 理解 SwiftUI ViewBuilder 的工作原理
- [ ] 能够使用 Mirror 运行时检查类型结构

---

## ➡️ 下一步

完成高级进阶复习后，继续学习 **[实战精选](../awesome/awesome.md)** 部分，你将：

- 学习第三方库集成
- 实现 LeetCode 题目
- 掌握工程化最佳实践

---

**返回**: [高级进阶概览](./advance-overview.md)