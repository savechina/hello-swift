// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// SwiftNIO Echo Server Sample
// Demonstrates: ServerBootstrap, ChannelHandler, ByteBuffer, EventLoop
// Cross-platform: macOS and Linux

import Foundation
import NIOCore
import NIOPosix

/// SwiftNIO Echo Server sample
/// Creates a simple TCP server that echoes back received data
public func swiftNIOSample() {
    startSample(functionName: "swiftNIOSample")
    
    print("SwiftNIO Echo Server 示例")
    print("本示例演示如何使用 SwiftNIO 创建简单的 TCP Echo 服务器")
    print("")
    
    // Example 1: Basic Echo Server (synchronous demonstration)
    print("--- 示例 1: EchoHandler ChannelHandler ---")
    print("EchoHandler 处理入站数据并将相同数据写回客户端")
    
    do {
        // Create a simple echo server that runs briefly for demonstration
        let server = try createEchoServer(port: 0) // Use port 0 for automatic port assignment
        print("Echo Server 创建成功，端口: \(server.port)")
        
        // Server runs for 2 seconds then shuts down
        Thread.sleep(forTimeInterval: 2)
        server.shutdown()
        print("Echo Server 已关闭")
    } catch {
        print("创建 Echo Server 失败: \(error)")
    }
    
    print("")
    
    // Example 2: ByteBuffer operations
    print("--- 示例 2: ByteBuffer 数据读写 ---")
    demonstrateByteBuffer()
    
    print("")
    
    // Example 3: EventLoop basics
    print("--- 示例 3: EventLoop 事件循环 ---")
    demonstrateEventLoop()
    
    endSample(functionName: "swiftNIOSample")
}

// MARK: - Echo Server Implementation

/// Simple Echo Server wrapper
struct EchoServer {
    let channel: Channel
    let port: Int
    let group: EventLoopGroup
    
    func shutdown() {
        group.shutdownGracefully { error in
            if let error = error {
                print("Shutdown error: \(error)")
            }
        }
    }
}

/// Create a simple Echo Server
/// - Parameter port: Port number (0 for automatic assignment)
/// - Returns: EchoServer wrapper
func createEchoServer(port: Int) throws -> EchoServer {
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    
    let bootstrap = ServerBootstrap(group: group)
        .serverChannelOption(ChannelOptions.backlog, value: 256)
        .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
        .childChannelInitializer { channel in
            channel.pipeline.addHandler(EchoHandler())
        }
        .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
    
    let channel = try bootstrap.bind(host: "127.0.0.1", port: port).wait()
    let actualPort = channel.localAddress?.port ?? 0
    
    return EchoServer(channel: channel, port: actualPort, group: group)
}

/// Echo Handler - echoes back received data
final class EchoHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias InboundOut = ByteBuffer
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        // Echo the received data back to the client
        context.write(data, promise: nil)
    }
    
    func channelReadComplete(context: ChannelHandlerContext) {
        // Flush all written data
        context.flush()
    }
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("EchoHandler error: \(error)")
        context.close(promise: nil)
    }
}

// MARK: - ByteBuffer Demonstration

/// Demonstrate ByteBuffer read/write operations
func demonstrateByteBuffer() {
    // Create an allocator and buffer
    let allocator = ByteBufferAllocator()
    var buffer = allocator.buffer(capacity: 256)
    
    // Write string data
    buffer.writeString("Hello SwiftNIO!")
    print("写入数据: 'Hello SwiftNIO!'")
    print("Buffer 容量: \(buffer.capacity)")
    print("可读字节: \(buffer.readableBytes)")
    
    // Read data
    if let readString = buffer.readString(length: buffer.readableBytes) {
        print("读取数据: '\(readString)'")
    }
    
    // Write integer
    buffer.writeInteger(42 as Int32)
    print("写入整数: 42")
    
    // Read integer
    if let readInt = buffer.readInteger(as: Int32.self) {
        print("读取整数: \(readInt)")
    }
    
    // Demonstrate slice (zero-copy)
    buffer.writeString("SliceDemo")
    let slice = buffer.getSlice(at: buffer.readerIndex, length: 8)
    print("Slice 操作 (零拷贝): \(slice?.readableBytes ?? 0) bytes")
}

// MARK: - EventLoop Demonstration

/// Demonstrate EventLoop basic operations
func demonstrateEventLoop() {
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 2)
    
    // Get next available EventLoop
    let eventLoop = group.next()
    print("EventLoop 创建成功")
    
    // Submit a task to EventLoop
    let future = eventLoop.submit {
        return "Task executed on EventLoop"
    }
    
    do {
        let result = try future.wait()
        print("EventLoop 任务结果: \(result)")
    } catch {
        print("EventLoop 任务错误: \(error)")
    }
    
    // Schedule a delayed task
    let scheduled = eventLoop.scheduleTask(in: .milliseconds(100)) {
        return "Delayed task completed"
    }
    
    do {
        let delayedResult = try scheduled.futureResult.wait()
        print("延迟任务结果: \(delayedResult)")
    } catch {
        print("延迟任务错误: \(error)")
    }
    
    // Cleanup
    group.shutdownGracefully { error in
        if let error = error {
            print("EventLoopGroup shutdown error: \(error)")
        }
    }
    print("EventLoopGroup 已关闭")
}

// MARK: - Async/Await Integration (Swift 6.0)

/// Demonstrate SwiftNIO async/await integration
/// NOTE: This shows the pattern for modern Swift concurrency
public func swiftNIOAsyncSample() {
    startSample(functionName: "swiftNIOAsyncSample")
    
    print("SwiftNIO async/await 集成示例")
    print("")
    
    // Note: Full async integration requires NIOLoopBoundBox or NIOAsyncChannel
    // This demonstrates the conceptual pattern
    
    print("--- Pattern 1: Task 与 EventLoop 桥接 ---")
    print("使用 Task { } 包装 SwiftNIO Future")
    print("示例: let result = await future.get() // 转换 Future 到 async")
    
    print("")
    
    print("--- Pattern 2: NIOLoopBoundBox ---")
    print("NIOLoopBoundBox 提供跨 Actor 安全访问 EventLoop-bound 值")
    print("用于在 async 函数中安全操作 SwiftNIO 资源")
    
    print("")
    
    print("--- Pattern 3: 避免阻塞 EventLoop ---")
    print("⛔ 错误: Thread.sleep() 在 EventLoop 线程")
    print("✅ 正确: Task.sleep() 或 eventLoop.scheduleTask()")
    
    endSample(functionName: "swiftNIOAsyncSample")
}