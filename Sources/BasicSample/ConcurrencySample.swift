//
//  ConcurrencySample.swift
//  hello-swift
//
//  Created by RenYan Wei on 2024/12/29.
//

import Foundation

@available(macOS 13.0, *)
func listPhotos(inGallery name: String) async throws -> [String] {
    try await Task.sleep(for: .milliseconds(2))
    return ["IMG001", "IMG99", "IMG0404"]
}

@available(macOS 13.0, *)
func generateSlideshow(forGallery gallery: String) async throws {
    let photos = try await listPhotos(inGallery: gallery)

    for photo in photos {

        // ... render a few seconds of video for this photo ...
        await Task.yield()
        print("photo:", photo)
    }
}
@available(macOS 13.0, *)
func fetchUser(id: Int) async throws -> String {
    // 模拟网络请求
    try await Task.sleep(
        nanoseconds: UInt64(Double.random(in: 0.5...1.5) * 1_000_000_000)
    )  // 模拟耗时操作
    return "User \(id)"
}

@available(macOS 13.0, *)
func userSample() async {
    async let user1 = fetchUser(id: 1)
    async let user2 = fetchUser(id: 2)
    async let user3 = fetchUser(id: 3)

    do {
        let users = try await [user1, user2, user3]
        print("Fetched users: \(users)")
    } catch {
        print("Error fetching users: \(error)")
    }
}

@available(macOS 13.0, *)
public func asyncTaskSample() throws {

    startSample(functionName: "ConcurrencySample asyncTaskSample")

    //创建异步任务
    Task {
        try await generateSlideshow(forGallery: "A Rainy Weekend")
    }

    // Async fetch user
    Task {
        await userSample()
    }

    Thread.sleep(forTimeInterval: 2)
    endSample(functionName: "ConcurrencySample asyncTaskSample")

}

public func simpleThreadSample() {

    startSample(functionName: "ConcurrencySample simpleThreadSample")

    // 创建并启动一个新线程
    let thread = Thread {
        print("Thread started")
        // 模拟耗时任务
        Thread.sleep(forTimeInterval: 2)
        print("Thread completed")
    }
    thread.start()

    //sleep await finish
    Thread.sleep(forTimeInterval: 2)

    // 使用信号量进行等待线程结束。
    // 创建一个信号量，初始值为0
    let semaphore = DispatchSemaphore(value: 0)

    // 创建并启动一个新线程
    let thread2 = Thread {
        print("Thread2 started")
        // 模拟耗时任务
        Thread.sleep(forTimeInterval: 2)
        print("Thread2 completed")
        // 任务完成后发送信号
        semaphore.signal()
    }

    // 启动线程
    thread2.start()

    // 等待线程完成
    semaphore.wait()

    print("Main thread: Thread has finished execution")

    // 创建并启动一个新线程
    let thread3 = Thread {
        print("Thread3 started")
        // 模拟耗时任务
        Thread.sleep(forTimeInterval: 2)
        print("Thread3 completed")
    }

    thread3.start()

    //使用 循环等待 线程结束
    while true {
        if thread3.isFinished {
            break
        }
        Thread.sleep(forTimeInterval: 2)
    }

    endSample(functionName: "ConcurrencySample simpleThreadSample")

}

@available(macOS 13.0, *)
public func actorSample() async {  // 1. 函数声明为 async，以便在内部使用 await
    startSample(functionName: "actorSample")

    actor Counter {
        private var value = 0

        func increment() {
            value += 1
        }

        func getValue() -> Int {
            return value
        }
    }

    let counter = Counter()

    // 2. 将 Task 的返回值类型明确，Task 会捕获闭包的返回值
    let task = Task.detached {
        await counter.increment()
        return await counter.getValue()  // 在任务末尾返回计算后的值
    }

    // 3. 使用 await 等待任务运行结束并获取其 value 属性
    let finalValue = await task.value

    print("counter 最终结果: \(finalValue)")

    endSample(functionName: "actorSample")
}

@available(macOS 13.0, *)
actor BatchCounter {
    private var count = 0

    func increment() {
        count += 1
    }

    func getCount() -> Int {
        return count
    }
}

@available(macOS 13.0, *)
func runParallelCalculation() async {
    let counter = BatchCounter()
    let totalTasks = 1_000_000

    print("开始并行计算 \(totalTasks) 个任务...")
    let startTime = CFAbsoluteTimeGetCurrent()

    // 1. 使用 withTaskGroup 创建结构化并发组
    await withTaskGroup(of: Void.self) { group in
        for i in 1...totalTasks {
            // 2. 将任务添加到组中并行执行
            group.addTask {
                await counter.increment()
                // 模拟一些计算开销
                if i % 2500 == 0 {
                    print("已派发任务: \(i)")
                }
            }
        }

        // 隐式等待：当 group 作用域结束时，所有 addTask 都会被 await 完成
    }

    // 3. 获取最终计算结果
    let finalResult = await counter.getCount()
    let duration = CFAbsoluteTimeGetCurrent() - startTime

    print("--- 结果 ---")
    print("预期结果: \(totalTasks)")
    print("实际结果: \(finalResult)")
    print("耗时: \(String(format: "%.4f", duration)) 秒")
}

@available(macOS 13.0, *)
public func batchAcotrSample() async {
    startSample(functionName: "batchAcotrSample")

    // 调用计算任务
    let handle = Task {
        await runParallelCalculation()
    }

    await handle.value

    endSample(functionName: "batchAcotrSample")
}

/// 传感器异步任务流
@available(macOS 13.0, *)
class SensorManager {
    // 定义一个 AsyncStream，它会产生 String 类型的数据
    func startMonitoring() -> AsyncStream<String> {

        // 使用 makeStream 静态方法可以方便地分离“流”和“继续符(Continuation)”
        let (stream, continuation) = AsyncStream.makeStream(of: String.self)

        // 模拟后台任务生产数据
        Task {
            let dataPoints = [
                "25°C", "25.2°C", "27.2°C", "23.5°C", "26°C", "24.5°C", "27°C",
            ]

            for point in dataPoints {
                try? await Task.sleep(for: .seconds(1))

                // yield 相当于 Go 的 channel <- data，将数据放入通道
                print("--- 生产者：发送数据 \(point) ---")
                continuation.yield(point)
            }

            // 完成数据生产，关闭流
            continuation.finish()
        }

        // 当外部取消监听时，执行清理逻辑
        continuation.onTermination = { termination in
            switch termination {
            case .finished:
                print("流正常结束")
            case .cancelled:
                print("流被取消了")
            @unknown default:
                break
            }
        }

        return stream
    }
}

@available(macOS 13.0, *)
public func asyncStreamSample() async throws {
    startSample(functionName: "asyncStreamSample")

    // --- 消费端 ---
    let handler = Task {
        let manager = SensorManager()

        let sensorStream = manager.startMonitoring()

        print("消费者：开始等待数据...")

        // 使用 for-await 循环消费数据，当流 finish 后循环会自动退出
        for await value in sensorStream {
            print("消费者：收到实时温度 -> \(value)")
        }

        print("消费者：所有数据处理完毕，任务结束。")
    }

    await handler.value

    endSample(functionName: "asyncStreamSample")
}
