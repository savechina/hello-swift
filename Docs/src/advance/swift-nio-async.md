# SwiftNIO async/await 集成

## 开篇故事

你刚学会骑自行车，现在教练让你骑摩托车。自行车靠体力蹬踏，摩托车靠油门控制。虽然都是"两轮交通工具"，但操作方式完全不同。

SwiftNIO 就像自行车——它有自己的 EventLoopFuture/Promise 体系。Swift async/await 就像摩托车——它用 Task、await 关键字管理异步。两者都是异步编程，但语法不同。

本章教你的，就是如何把这两套"交通工具"结合起来，让 SwiftNIO 跑在 async/await 的"摩托车"上。你不必扔掉 SwiftNIO 的知识，而是学会用更现代的方式驾驭它。

## 本章适合谁

如果你满足以下任一情况，这一章就是为你准备的：

- 你已经掌握上一章的 SwiftNIO 基础（EventLoop、Channel、ByteBuffer）
- 你习惯了 Swift async/await 语法，觉得 Future/Promise 很繁琐
- 你想在新项目中用 async/await，但又需要 SwiftNIO 的网络能力
- 你遇到了 "Blocking operation on EventLoop" 错误，想知道正确做法

## 你会学到什么

完成本章后，你将掌握以下内容：

- **Future → async 转换**：如何把 EventLoopFuture 变成 awaitable
- **Task 与 EventLoop 桥接**：在 async 函数中安全使用 SwiftNIO
- **NIOLoopBoundBox**：跨 Actor 安全访问 EventLoop-bound 值
- **NIOAsyncChannel**：SwiftNIO 2.0+ 的现代 async/await API
- **避免阻塞 EventLoop**：正确的异步等待方式

## 前置要求

在开始之前，请确保你已掌握以下内容：

- Swift async/await：Task、async 函数、await 关键字、TaskGroup
- SwiftNIO 基础：EventLoop、EventLoopFuture、Channel（上一章内容）
- Swift 并发安全：Sendable 协议、Actor 隔离概念

运行环境要求：

- macOS 12.0+ 或 Linux（Ubuntu 22.04+）
- Swift 6.0+（Strict Concurrency 模式）
- swift-nio 2.92.0+（支持 NIOAsyncChannel）

## 第一个例子

先看一个经典问题：你有一个 SwiftNIO 的 Future，但你想在 async 函数里 await 它。

这段代码来自 `AdvanceSample/Sources/AdvanceSample/SwiftNIOSample.swift`。

```swift
import NIOCore
import NIOPosix

// SwiftNIO 的 Future 方式
let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let eventLoop = group.next()

let future = eventLoop.submit {
    return "Result from EventLoop"
}

// 传统方式：阻塞等待
let result = try future.wait()  // ⚠️ 会阻塞当前线程

// 现代方式：async/await 桥接
func getResult() async throws -> String {
    // 需要特殊桥接方式...
}
```

## 原理解析

### EventLoopFuture vs async/await

SwiftNIO 的 `EventLoopFuture<T>` 是传统的异步容器：

- 创建时不立即完成，等待 EventLoop 执行
- 通过 `.whenSuccess {}`、`.whenFailure {}` 回调处理结果
- `.wait()` 会阻塞当前线程，**不能在 EventLoop 线程调用**

Swift async/await 是现代异步模型：

- `await` 暂停当前函数，不阻塞线程
- `Task { }` 创建异步任务
- 编译器自动管理挂起和恢复

**核心矛盾**：

- SwiftNIO 的很多 API 返回 `EventLoopFuture`
- async 函数需要 `await`，而不是 `.wait()`
- 直接 `.wait()` 在 async 函数里**会阻塞底层线程**，违反 async 设计

### 桥接策略 1：withCheckedContinuation

Foundation 提供了 `withCheckedContinuation`，可以把任何回调式 API 转成 async：

```swift
import NIOCore

// 把 Future 转成 async
extension EventLoopFuture {
    func asyncValue() async throws -> Value {
        try await withCheckedThrowingContinuation { continuation in
            self.whenComplete { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// 使用示例
func connectAsync() async throws -> Channel {
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    let bootstrap = ServerBootstrap(group: group)
    
    let channelFuture = bootstrap.bind(host: "127.0.0.1", port: 8080)
    
    // 使用桥接，不阻塞线程
    return try await channelFuture.asyncValue()
}
```

### 桥接策略 2：NIOLoopBoundBox（推荐）

SwiftNIO 2.0+ 提供了 `NIOLoopBoundBox`，专门解决跨 Actor/Task 访问问题：

```swift
import NIOCore

// NIOLoopBoundBox 保证跨 Actor 安全
final class ConnectionManager: Actor {
    private let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    private var channels: [NIOLoopBoundBox<Channel>] = []
    
    func createConnection() async throws -> Channel {
        let eventLoop = eventLoopGroup.next()
        let bootstrap = ClientBootstrap(group: eventLoopGroup)
            .channelInitializer { channel in
                channel.pipeline.addHandler(MyHandler())
            }
        
        let channel = try await bootstrap.connect(
            host: "127.0.0.1",
            port: 8080
        ).get()  // NIO 2.0+ 支持 .get() 桥接
        
        // 用 NIOLoopBoundBox 包装，保证 Sendable
        let boxedChannel = NIOLoopBoundBox(channel, eventLoop: eventLoop)
        channels.append(boxedChannel)
        
        return channel
    }
}
```

### 桥接策略 3：NIOAsyncChannel（最新）

SwiftNIO 2.40+ 提供了全新的 `NIOAsyncChannel`，完全基于 async/await 设计：

```swift
import NIOCore
import NIOPosix

// 使用 NIOAsyncChannel 创建 async 服务器
func startAsyncServer() async throws {
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    
    let serverChannel = try await ServerBootstrap(group: group)
        .bind(host: "127.0.0.1", port: 8080)
        .map { channel in
            // 创建 NIOAsyncChannel
            NIOAsyncChannel(
                wrappingChannelSynchronously: channel,
                configuration: .init()
            )
        }.get()
    
    // async 方式处理连接
    try await withThrowingDiscardingTaskGroup { group in
        for try await connection in serverChannel.inboundStream {
            group.addTask {
                try await handleConnection(connection)
            }
        }
    }
}

func handleConnection(_ connection: NIOAsyncChannel) async throws {
    for try await data in connection.inboundStream {
        // async 方式处理数据
        try await connection.outboundStream.write(data)
    }
}
```

### 错误陷阱：阻塞 EventLoop

这是最常见的错误，也是最危险的：

```swift
// ❌ 绝对错误！
func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    Task {
        // Task 默认不在 EventLoop 上
        // await 会暂停 Task，但不影响 EventLoop
        
        // 但如果在 Task 里调用 wait()...
        let result = try someFuture.wait()  // 💥 阻塞 EventLoop！
    }
}

// ✅ 正确做法
func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    // 把工作提交到 EventLoop，让它调度
    context.eventLoop.execute {
        // 这里在 EventLoop 上，可以安全操作 Channel
    }
    
    // 或者用 async 桥接
    let future = someOperation(context)
    Task {
        try await future.asyncValue()  // 不阻塞，正确等待
    }
}
```

## 常见错误

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| `Blocking operation on EventLoop` | 在 EventLoop 线程调用 wait() 或 Thread.sleep | 使用 Task.sleep 或 continuation 桥接 |
| `Actor isolation crossing` | Channel 不符合 Sendable，跨 Actor 访问 | 用 NIOLoopBoundBox 包装 |
| `Future.wait() in async function` | wait() 阻塞底层线程，违反 async 设计 | 用 continuation 或 NIOAsyncChannel |
| `NIOAsyncChannel not found` | swift-nio 版本过低 | 升级到 2.40.0+ |
| `Task detached from EventLoop` | Task.detached 不继承 EventLoop context | 用 Task { } 继承 context |

### 错误示例 1：wait() 在 EventLoop

```swift
// ❌ 错误
final class MyHandler: ChannelInboundHandler {
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        // channelRead 在 EventLoop 上执行
        let future = context.channel.write(data)
        try! future.wait()  // 💥 阻塞整个 EventLoop！
    }
}

// ✅ 正确
final class MyHandler: ChannelInboundHandler {
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        // 用 promise 或回调
        context.writeAndFlush(data).whenComplete { result in
            switch result {
            case .success:
                print("Written")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
```

### 错误示例 2：Channel 跨 Actor

```swift
// ❌ 错误 - Channel 不符合 Sendable
actor ConnectionPool {
    var activeChannels: [Channel] = []  // 💥 Channel 不是 Sendable
    
    func add(channel: Channel) {
        activeChannels.append(channel)  // 跨 Actor 传递非 Sendable
    }
}

// ✅ 正确 - 用 NIOLoopBoundBox 包装
actor ConnectionPool {
    var activeChannels: [NIOLoopBoundBox<Channel>] = []
    
    func add(channel: Channel, eventLoop: EventLoop) {
        let boxed = NIOLoopBoundBox(channel, eventLoop: eventLoop)
        activeChannels.append(boxed)  // NIOLoopBoundBox 是 Sendable
    }
    
    func writeToAll(data: ByteBuffer) async throws {
        for box in activeChannels {
            try await box.withValue { channel in
                // 在正确的 EventLoop 上操作
                channel.writeAndFlush(data, promise: nil)
            }
        }
    }
}
```

## Swift vs Rust/Python 对比

| 概念 | Swift (SwiftNIO + async) | Rust (tokio + async) | Python (asyncio) |
|------|---------------------------|----------------------|-------------------|
| Future 桥接 | continuation | async fn 自动兼容 | await 自动兼容 |
| 跨 Actor 安全 | NIOLoopBoundBox | Arc<Mutex> | 无 Actor 模型 |
| 线程安全容器 | @unchecked Sendable | Send trait | 无类型约束 |
| async 服务器 | NIOAsyncChannel | tokio::net::TcpListener | asyncio.start_server |
| 阻塞检测 | 编译警告 | blocking!() | 无自动检测 |
| 任务继承 context | Task 默认继承 | tokio::spawn | asyncio.create_task |

**关键差异**：

- Swift 的 Actor 模型比 Rust 的 Arc<Mutex> 更严格，需要显式 Sendable
- Python 的 asyncio 没有 Actor，跨线程访问靠人工约定
- SwiftNIO 的 NIOLoopBoundBox 是独有设计，解决 EventLoop + Actor 冲突

## 动手练习 Level 1

**任务**：为 `EventLoopFuture` 写一个 async 扩展方法。

要求：

1. 命名为 `asyncResult()`
2. 正确处理 success 和 failure
3. 用 `withCheckedThrowingContinuation`

```swift
extension EventLoopFuture {
    func asyncResult() async throws -> Value {
        // 你的实现...
    }
}
```

<details>
<summary>点击查看参考答案</summary>

```swift
extension EventLoopFuture {
    /// 将 EventLoopFuture 转换为 async/await 兼容
    func asyncResult() async throws -> Value {
        try await withCheckedThrowingContinuation { continuation in
            self.whenComplete { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
```

</details>

## 动手练习 Level 2

**任务**：写一个 async Echo Server，使用 NIOAsyncChannel。

要求：

1. 监听端口 9000
2. 每个连接用独立 Task 处理
3. 使用 `for try await` 读取入站数据

<details>
<summary>点击查看参考答案</summary>

```swift
import NIOCore
import NIOPosix

func startAsyncEchoServer() async throws {
    let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    
    let server = try await ServerBootstrap(group: group)
        .childChannelInitializer { channel in
            channel.pipeline.addHandler(EchoHandler())
        }
        .bind(host: "127.0.0.1", port: 9000)
        .asyncResult()
    
    print("Async Echo Server started on port 9000")
    
    // 保持服务器运行
    try await server.closeFuture.asyncResult()
}
```

</details>

## 动手练习 Level 3

**任务**：实现一个 Actor 管理的连接池，支持：

1. `addConnection(channel: Channel)`
2. `broadcast(message: String)` - 向所有连接发送消息
3. `removeConnection(channel: Channel)`
4. 正确使用 NIOLoopBoundBox 保证 Sendable

**提示**：Actor 需要跨 Actor 访问 EventLoop-bound 值，NIOLoopBoundBox.withValue 是关键。

## 故障排查 FAQ

**Q: Task.sleep 和 Thread.sleep 有什么区别？**

A: Task.sleep 暂停当前 Task，不阻塞底层线程；Thread.sleep 阻塞整个线程。在 EventLoop 上用 Thread.sleep 会卡住所有连接。用 Task.sleep 或 eventLoop.scheduleTask。

---

**Q: NIOLoopBoundBox.withValue 是什么？**

A: 它保证操作在正确的 EventLoop 上执行。Channel 只能在创建它的 EventLoop 上修改，withValue 自动切换到正确的 EventLoop。

```swift
try await box.withValue { channel in
    // 这里在 channel 的 EventLoop 上执行
    channel.writeAndFlush(data, promise: nil)
}
```

---

**Q: 为什么 Channel 不是 Sendable？**

A: Channel 绑定到特定 EventLoop，跨线程/Actor 访问会破坏 EventLoop 的单线程假设。NIOLoopBoundBox 包装后变成 Sendable，通过 withValue 保证安全访问。

---

**Q: NIOAsyncChannel 和普通 Channel 有什么区别？**

A: NIOAsyncChannel 提供 async/await 接口：
- `inboundStream` 是 AsyncSequence，可以用 `for try await`
- `outboundStream` 可以 `await write`
- 自动处理 EventLoop context

---

**Q: 如何在 swift-nio 版本 < 2.40 时使用 async？**

A: 用 continuation 桥接：

```swift
extension EventLoopFuture {
    func get() async throws -> Value {
        try await withCheckedThrowingContinuation { continuation in
            whenComplete { continuation.resume(with: $0) }
        }
    }
}
```

SwiftNIO 2.40+ 内置了 `.get()` 方法，支持 async。

## 小结

本章你学会了 SwiftNIO 与 Swift async/await 的集成：

- **Future → async 桥接**：withCheckedContinuation 把回调式转 async
- **NIOLoopBoundBox**：跨 Actor 安全访问 EventLoop-bound 值
- **NIOAsyncChannel**：SwiftNIO 2.40+ 的原生 async/await API
- **避免阻塞**：Task.sleep vs Thread.sleep 的关键区别
- **Sendable 约束**：为什么 Channel 不符合 Sendable，如何正确包装

现代 Swift 项目应该优先使用 async/await，SwiftNIO 提供的桥接方式让你不必放弃 SwiftNIO 的网络能力。

## 术语表

| 中文 | 英文 | 说明 |
|------|------|------|
| Continuation | Continuation | async/await 的底层挂起/恢复机制 |
| EventLoop 绑定 | EventLoop-bound | 值绑定到特定 EventLoop，只能在其上操作 |
| Actor 隔离 | Actor isolation | Actor 保护内部状态，外部需 Sendable |
| Sendable | Sendable | 可跨并发边界安全传递的类型 |
| 桥接 | Bridging | 两种异步模型的连接方式 |
| 阻塞 | Blocking | 等待操作完成，暂停线程 |
| 非阻塞 | Non-blocking | 不等待，立即返回或挂起 |

## 知识检查

1. 为什么不能在 EventLoop 线程调用 `future.wait()`？

2. NIOLoopBoundBox 如何保证跨 Actor 安全访问 Channel？

3. NIOAsyncChannel 相比传统 Channel 有什么优势？

<details>
<summary>点击查看答案与解析</summary>

1. **wait() 会阻塞整个 EventLoop**：EventLoop 是单线程，管理数千连接。调用 wait() 时，线程停在原地等待，所有其他连接的处理都被卡住。正确做法是用 continuation 桥接成 async，或用回调 `.whenComplete {}`，不阻塞线程。

2. **NIOLoopBoundBox 记录 EventLoop 并提供 withValue {}**：它包装 Channel 并记录绑定的 EventLoop。调用 withValue 时，如果当前不在正确的 EventLoop 上，会自动提交任务到该 EventLoop。这保证 Channel 只在其 EventLoop 上被修改，满足 Sendable 约束。

3. **NIOAsyncChannel 提供原生 async/await 接口**：
   - `inboundStream` 是 AsyncSequence，用 `for try await` 读取
   - 不需要手动处理 EventLoopFuture 或 continuation
   - 自动继承 EventLoop context，避免 context 丢失
   - 代码更简洁，符合现代 Swift 风格

</details>

## 继续学习

**下一章**: [系统编程与进程管理](./system-programming.md) - 学习 Process、Signal、跨平台系统调用

**返回**: [高级进阶概览](./advance-overview.md)