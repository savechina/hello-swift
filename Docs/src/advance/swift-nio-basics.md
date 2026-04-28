# SwiftNIO 异步网络基础

## 开篇故事

想象你在经营一家快递公司。传统的做法是：每个快递员负责一个客户，从取件到送达全程跟踪，客户越多，快递员越多。这种方式效率低下——快递员大部分时间在等客户签字、等交通灯、等收件人出现。

现代快递公司改用"分拣中心"模式：快递员只负责取件和送达两个动作，中间的运输、分拣由专职团队处理。一个快递员可以同时服务多个客户，效率翻倍。

SwiftNIO 就是 Swift 世界里的"分拣中心"。它用 EventLoop（事件循环）管理所有网络连接，一个线程可以处理成千上万的并发请求。你不需要为每个连接创建一个线程，SwiftNIO 会自动帮你调度。

本章要教你的，就是如何用 SwiftNIO 构建这种高效率的网络应用。

## 本章适合谁

如果你满足以下任一情况，这一章就是为你准备的：

- 你需要构建 TCP 或 HTTP 服务器（如聊天服务器、API 服务器）
- 你想理解 Vapor、Hummingbird 等 Web 框架底层原理
- 你对异步网络编程感兴趣，想知道 EventLoop、Channel 怎么工作
- 你想让代码同时跑在 macOS 和 Linux 上，跨平台部署

本章面向已经掌握 Swift async/await 基础的开发者。你需要知道 Task、async 函数的基本用法。

## 你会学到什么

完成本章后，你将掌握以下内容：

- **EventLoop**（事件循环）：SwiftNIO 如何在单线程上处理多个连接
- **Channel**（通道）：网络连接的生命周期和管道模型
- **ChannelHandler**（处理器）：如何编写入站/出站数据处理逻辑
- **ByteBuffer**（字节缓冲区）：零拷贝读写、切片操作、高效内存管理
- **ServerBootstrap**（服务器启动器）：创建 TCP 服务器的完整流程
- **跨平台部署**：swift-nio 在 macOS 和 Linux 上的行为差异

## 前置要求

在开始之前，请确保你已掌握以下内容：

- Swift async/await：Task、async 函数、await 关键字
- Swift 并发基础：理解 Task.sleep 与 Thread.sleep 的区别
- 网络基础：知道 TCP、端口的概念
- 错误处理：do-catch-try 模式

运行环境要求：

- macOS 12.0+ 或 Linux（Ubuntu 22.04+）
- Swift 6.0+
- swift-nio 已在 Package.swift 中声明依赖

## 第一个例子

我们先来看一个最基础的例子：创建一个 Echo Server。它的功能很简单——收到什么消息，就原样发回去。就像你对着山谷喊话，山谷回声一样。

这段代码来自 `AdvanceSample/Sources/AdvanceSample/SwiftNIOSample.swift`。

```swift
import NIOCore
import NIOPosix

// 创建 Echo Server 的核心代码
let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

let bootstrap = ServerBootstrap(group: group)
    .childChannelInitializer { channel in
        // 给每个连接添加 EchoHandler
        channel.pipeline.addHandler(EchoHandler())
    }

// 绑定端口并启动
let channel = try bootstrap.bind(host: "127.0.0.1", port: 8080).wait()
print("Server started on port \(channel.localAddress?.port ?? 0)")
```

运行这段代码后，你可以用 telnet 连接测试：

```bash
telnet 127.0.0.1 8080
# 输入任意文字，服务器会原样返回
```

## 原理解析

### EventLoop：SwiftNIO 的心脏

EventLoop 是 SwiftNIO 的核心概念。它就像一个永不停止的循环，不断检查"有没有新事件发生"。

```
while true {
    for connection in activeConnections {
        if connection.hasData {
            handleData(connection)
        }
        if connection.hasError {
            handleError(connection)
        }
    }
}
```

**关键特性**：

- **单线程处理多连接**：一个 EventLoop 可以管理数千个连接，避免线程爆炸
- **非阻塞 I/O**：没有数据时不等待，立即处理其他连接
- **任务提交**：可以用 `submit {}` 向 EventLoop 提交任务

```swift
let eventLoop = group.next()

// 向 EventLoop 提交任务
let future = eventLoop.submit {
    return "Task result"
}

// 获取结果（阻塞等待）
let result = try future.wait()
```

### Channel：网络连接的管道

Channel 代表一个网络连接（TCP 连接）。它不是简单的 socket，而是由多个 Handler 组成的管道（Pipeline）。

```
入站数据流向：Socket → ByteHandler → DecodeHandler → BusinessHandler
出站数据流向：BusinessHandler → EncodeHandler → ByteHandler → Socket
```

**Channel 生命周期**：

1. `channelRegistered`：Channel 注册到 EventLoop
2. `channelActive`：连接建立成功
3. `channelRead`：收到数据
4. `channelReadComplete`：一批数据读完
5. `channelInactive`：连接关闭
6. `channelUnregistered`：Channel 从 EventLoop 移除

### ChannelHandler：数据处理单元

ChannelHandler 是你编写业务逻辑的地方。分为两类：

- **InboundHandler**：处理入站数据（如解码、业务逻辑）
- **OutboundHandler**：处理出站数据（如编码、发送）

```swift
final class EchoHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer  // 输入类型
    typealias InboundOut = ByteBuffer // 输出类型
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        // 把收到的数据原样写回
        context.write(data, promise: nil)
    }
    
    func channelReadComplete(context: ChannelHandlerContext) {
        // 刷新缓冲区，实际发送数据
        context.flush()
    }
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("Error: \(error)")
        context.close(promise: nil)
    }
}
```

### ByteBuffer：高效的字节容器

ByteBuffer 是 SwiftNIO 的核心数据结构，用于存储网络数据。它比 Data 或 [UInt8] 更高效。

**关键特性**：

- **零拷贝切片**：slice 操作不复制数据，只移动指针
- **自动扩容**：写入超过容量时自动扩展
- **读写指针分离**：readerIndex 和 writerIndex 独立管理

```swift
let allocator = ByteBufferAllocator()
var buffer = allocator.buffer(capacity: 256)

// 写入数据
buffer.writeString("Hello")
buffer.writeInteger(42 as Int32)

// 读取数据
let text = buffer.readString(length: 5)  // "Hello"
let number = buffer.readInteger(as: Int32.self)  // 42

// 切片（零拷贝）
buffer.writeString("SliceDemo")
let slice = buffer.getSlice(at: 0, length: 9)
// slice 和 buffer 共享底层内存
```

## 常见错误

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| `Blocking operation on EventLoop` | 在 EventLoop 线程执行 Thread.sleep 或同步 I/O | 使用 Task.sleep 或 eventLoop.scheduleTask |
| `Channel closed before write completed` | 写入数据后立即关闭连接 | 使用 writeAndFlush 的 promise 等待完成后再 close |
| `ByteBuffer readIndex out of bounds` | 读取超过可读范围 | 检查 buffer.readableBytes 后再读取 |
| `EventLoopGroup shutdown leak` | 未调用 shutdownGracefully | 在应用退出前调用 group.shutdownGracefully |
| `ChannelHandler type mismatch` | InboundIn 类型与 Pipeline 不匹配 | 确保 Handler 的 typealias 与上游输出类型一致 |

### 错误示例 1：阻塞 EventLoop

```swift
// ❌ 错误写法
func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    Thread.sleep(forTimeInterval: 1.0)  // 阻塞 EventLoop！
    context.write(data, promise: nil)
}

// ✅ 正确写法
func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    context.eventLoop.scheduleTask(in: .seconds(1)) {
        context.write(data, promise: nil)
    }
}
```

### 错误示例 2：过早关闭连接

```swift
// ❌ 错误写法
context.write(data, promise: nil)
context.close(promise: nil)  // 数据可能还没发送完

// ✅ 正确写法
context.writeAndFlush(data).whenComplete { _ in
    context.close(promise: nil)
}
```

## Swift vs Rust/Python 对比

| 概念 | Swift (SwiftNIO) | Rust (tokio) | Python (asyncio) |
|------|-------------------|---------------|-------------------|
| 事件循环 | EventLoop | Runtime | Event Loop |
| 连接抽象 | Channel | TcpStream | StreamReader |
| 数据缓冲 | ByteBuffer | BytesMut | bytes |
| 处理器 | ChannelHandler | codec::Framed | Protocol |
| 任务提交 | eventLoop.submit {} | tokio::spawn | asyncio.create_task |
| Future/Promise | EventLoopFuture | Future | asyncio.Future |
| 异步等待 | future.wait() | .await | await |

**关键差异**：

- SwiftNIO 的 ByteBuffer 提供零拷贝切片，性能接近 Rust
- Swift 的 async/await 与 SwiftNIO 需要通过 NIOLoopBoundBox 桥接
- Python asyncio 是单线程，SwiftNIO 支持 MultiThreadedEventLoopGroup

## 动手练习 Level 1

**任务**：修改 EchoHandler，让它在返回数据前加上 "Echo: " 前缀。

例如：客户端发送 "Hello"，服务器返回 "Echo: Hello"。

```swift
// 提示：你需要读取 ByteBuffer 内容，修改后写回
func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    var buffer = unwrapInboundIn(data)
    if let text = buffer.readString(length: buffer.readableBytes) {
        var newBuffer = context.channel.allocator.buffer(capacity: 256)
        newBuffer.writeString("Echo: \(text)")
        context.write(wrapInboundOut(newBuffer), promise: nil)
    }
}
```

## 动手练习 Level 2

**任务**：创建一个简单的聊天服务器，支持以下功能：

1. 多个客户端连接
2. 一个客户端发送的消息，所有客户端都能收到
3. 客户端断开时通知其他客户端

**提示**：

- 需要一个共享的 `activeChannels: [Channel]` 数组
- 使用 `ChannelHandlerContext.channel` 记录连接
- 在 `channelActive` 时添加，`channelInactive` 时移除

## 动手练习 Level 3

**任务**：实现一个简单的 HTTP 服务器，返回固定响应：

```http
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: 13

Hello, World!
```

**提示**：

- HTTP 是基于 TCP 的文本协议
- 需要解析请求行（GET / HTTP/1.1）
- 响应必须包含正确的 Content-Length

<details>
<summary>点击查看 Level 3 参考代码</summary>

```swift
final class HTTPHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var request = unwrapInboundIn(data)
        if let requestText = request.readString(length: request.readableBytes) {
            // 简单检查是否是 HTTP GET 请求
            if requestText.hasPrefix("GET") {
                let response = "HTTP/1.1 200 OK\r\n" +
                    "Content-Type: text/plain\r\n" +
                    "Content-Length: 13\r\n\r\n" +
                    "Hello, World!"
                
                var buffer = context.channel.allocator.buffer(capacity: 256)
                buffer.writeString(response)
                context.writeAndFlush(wrapInboundOut(buffer), promise: nil)
            }
        }
    }
}
```

</details>

## 故障排查 FAQ

**Q: SwiftNIO 编译失败，提示找不到 NIOCore 模块**

A: 检查 Package.swift 是否正确声明 swift-nio 依赖：

```swift
.package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from: "2.92.0"))
```

并在 target dependencies 中添加：

```swift
.product(name: "NIOCore", package: "swift-nio"),
.product(name: "NIOPosix", package: "swift-nio")
```

---

**Q: 服务器启动后立即退出，没有等待连接**

A: SwiftNIO 的 bind 返回 Future，需要等待或保持 EventLoopGroup 运行：

```swift
let channel = try bootstrap.bind(host: "127.0.0.1", port: 8080).wait()
// 不要立即调用 group.shutdownGracefully
// 保持 channel 运行直到需要退出
```

---

**Q: ByteBuffer.readString 返回 nil**

A: 检查 readableBytes 是否足够，readString 会移动 readIndex：

```swift
if buffer.readableBytes >= expectedLength {
    let text = buffer.readString(length: expectedLength)
}
```

---

**Q: 如何在 Linux 上测试 SwiftNIO 服务器？**

A: SwiftNIO 完全支持 Linux。使用相同代码，编译后用 telnet 或 nc 测试：

```bash
swift build
.build/debug/your-server &
telnet 127.0.0.1 8080
```

---

**Q: ChannelPipeline.addHandler 报错类型不匹配**

A: 确保 Handler 的 InboundIn 类型与 Pipeline 中前一个 Handler 的输出类型一致：

```swift
// 如果上一个 Handler 输出 ByteBuffer
typealias InboundIn = ByteBuffer
```

## 小结

本章你学会了 SwiftNIO 的核心概念：

- **EventLoop**：单线程管理多连接，非阻塞事件循环
- **Channel**：网络连接抽象，由 Pipeline 和 Handler 组成
- **ChannelHandler**：入站/出站数据处理单元，编写业务逻辑的地方
- **ByteBuffer**：高效字节容器，零拷贝切片，读写指针分离
- **ServerBootstrap**：创建 TCP 服务器的启动器模式

SwiftNIO 是 Vapor、Hummingbird 等 Web 框架的基础。掌握它，你就能理解这些框架的底层原理，也能自己构建高性能网络服务。

## 术语表

| 中文 | 英文 | 说明 |
|------|------|------|
| 事件循环 | EventLoop | 单线程事件分发器，管理多个连接 |
| 通道 | Channel | 网络连接抽象，包含 Pipeline |
| 管道 | Pipeline | Handler 组成的处理链 |
| 处理器 | ChannelHandler | 数据处理单元，分入站/出站 |
| 字节缓冲区 | ByteBuffer | 高效内存容器，零拷贝设计 |
| 启动器 | Bootstrap | 服务器或客户端创建工具 |
| Future | EventLoopFuture | 异步结果容器 |
| Promise | EventLoopPromise | Future 的写入端 |
| 非阻塞 | Non-blocking | 不等待 I/O 完成，立即返回 |

## 知识检查

1. EventLoop 如何在单线程上处理多个网络连接？

2. ChannelPipeline 中 Handler 的排列顺序对数据处理有什么影响？

3. 为什么不应该在 ChannelHandler 中使用 Thread.sleep？

<details>
<summary>点击查看答案与解析</summary>

1. **EventLoop 使用非阻塞 I/O 和事件驱动模式**：它不断轮询所有活跃连接，检查是否有数据到达、连接关闭等事件。当某个连接有数据时，立即处理，不等待；没有数据时，跳过该连接，处理其他连接。这样单线程就能管理数千连接，避免了传统"一连接一线程"的资源浪费。

2. **顺序决定数据流向**：入站数据按 Pipeline 从头到尾经过每个 InboundHandler；出站数据从尾到头经过每个 OutboundHandler。例如：`ByteHandler → DecodeHandler → BusinessHandler`，入站数据先被 ByteHandler 处理（原始字节），再被 DecodeHandler 解码（结构化数据），最后到 BusinessHandler（业务逻辑）。顺序错误会导致类型不匹配。

3. **Thread.sleep 会阻塞整个 EventLoop**：一个 EventLoop 管理数千连接，如果某个 Handler 阻塞，所有连接都会被卡住。正确做法是使用 `eventLoop.scheduleTask(in: .seconds(1))` 或 Swift Concurrency 的 `Task.sleep`，让 EventLoop 继续处理其他连接，定时任务完成后才执行后续逻辑。

</details>

## 继续学习

**下一章**: [SwiftNIO async/await 集成](./swift-nio-async.md) - 学习如何将 SwiftNIO 与现代 Swift 并发模型结合

**返回**: [高级进阶概览](./advance-overview.md)