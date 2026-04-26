# 并发编程

## 开篇故事

想象你在一家餐厅的后厨工作。厨师长（主线程）负责摆盘和最终检查。但切菜、炒菜、洗碗这些活不能全让厨师长干。你需要帮手。

在 Swift 过去，我们用 Thread（线程）和 Semaphore（信号量）"人肉管理"这些帮手。就像厨师长站在厨房门口大喊"A去切菜，B去炒菜"。但这有个问题。如果两人都同时去拿同一把刀，就会打架。这叫做"数据竞争"。

Swift 的并发编程是现代化的厨房管理系统。你只需要说"帮我准备这道菜"，系统自动分配人手，还能保证不会有人拿到同一把刀。

`Sources/BasicSample/ConcurrencySample.swift` 中有完整的并发示例。让我们从最基础的 async/await 开始。

---

## 本章适合谁

如果你写过网络请求、文件读写，或者任何需要等待外部资源的操作，你就能从并发编程中受益。本章适合有一定 Swift 基础的学习者。如果你是第一次接触 Swift，建议先完成 [错误处理](error-handling.md) 和 [闭包](closures.md)。

---

## 你会学到什么

完成本章后，你可以：

1. 使用 `async`/`await` 语法编写异步代码
2. 理解 async let 实现并行绑定
3. 使用 `Task` 创建和管理后台任务
4. 用 `TaskGroup` 实现动态并行计算
5. 掌握 `actor` 和 `Sendable` 实现线程安全

---

## 前置要求

你需要先理解 Swift 的闭包 (closure)、错误处理 (error handling) 和可选类型 (optional)。如果还没学过，请先阅读 [错误处理](error-handling.md) 和 [闭包](closures.md)。

---

## 第一个例子

打开 `Sources/BasicSample/ConcurrencySample.swift`，我们从最简单的异步函数开始：

```swift
func fetchUser(id: Int) async throws -> String {
    try await Task.sleep(for: .seconds(1))  // 模拟网络延迟
    return "User \(id)"
}

// 调用异步函数需要 await
Task {
    let user = try await fetchUser(id: 1)
    print(user)  // User 1
}
```

**发生了什么？**

- `async` 标记函数是异步的，意味着它可以在执行过程中暂停
- `await` 表示"暂停当前代码，等这个异步操作完成再继续"
- `throws` 表示函数可能抛出错误

**关键区别**：和传统的回调方式不同，**代码写起来就像同步代码一样**。`await` 暂停后，继续往下执行。没有回调地狱 (callback hell)。

---

## 原理解析

### 1. async/await 基本概念

异步函数的调用看起来就是普通的函数调用：

```swift
@available(macOS 13.0, *)
func generateSlideshow(forGallery gallery: String) async throws {
    let photos = try await listPhotos(inGallery: gallery)  // 等待获取照片

    for photo in photos {
        await Task.yield()  // 让出线程，允许其他任务运行
        print("photo:", photo)
    }
}
```

**关键点**：
- `async` 函数只能在另一个 `async` 函数或 `Task` 中被调用
- `await` 是标记，告诉编译器"这里有暂停的可能"
- 代码从上到下阅读，就像普通的同步代码

### 2. async let — 并行绑定

当你需要同时启动多个独立任务时，`async let` 让绑定是异步的，但后续再 `await`：

```swift
async let user1 = fetchUser(id: 1)
async let user2 = fetchUser(id: 2)
async let user3 = fetchUser(id: 3)

do {
    let users = try await [user1, user2, user3]
    print("Fetched users: \(users)")
    // 三个请求是同时发出的，不是等第一个完第二个才开始
} catch {
    print("Error: \(error)")
}
```

这三个请求是**并行**的。如果每个请求需要 1 秒，三个并行总共还是 1 秒左右（忽略网络开销）。

如果每个请求顺序执行则需要 3 秒。

`async let` 的妙处在于：声明后任务立即开始，你可以先做其他事，等真的需要结果时再 `await`。

### 3. Task — 创建并发任务

`Task` 是并发编程的基本单元：

```swift
// 创建一个新任务
let task = Task {
    print("Running in background")
    let result = try await fetchUser(id: 42)
    return result
}

// 等待任务完成并获取结果
let user = try await task.value
```

`Task.detached` 创建的是不继承当前上下文的独立任务：

```swift
let detached = Task.detached {
    // 这个任务不继承当前任务的优先级、本地存储等
    print("Independent task")
}
```

**类比**：
> `Task` 就像你给厨师长派个帮手，帮手继承了厨师长的工作环境。`Task.detached` 则是另招一个新人，从头开始。

### 4. TaskGroup — 动态并行

当你不知道需要创建多少任务时（比如处理文件列表中的每个文件），用 TaskGroup：

```swift
// 来自 ConcurrencySample.swift 的 BatchCounter 示例
await withTaskGroup(of: Void.self) { group in
    for i in 1...1_000_000 {
        group.addTask {
            await counter.increment()
        }
    }
    // 退出闭包时，自动等待所有任务完成
}
```

- `withTaskGroup` 创建一个任务组
- `addTask` 向组中添加任务
- 闭包结束时自动 `await` 所有任务完成

这比手动管理 100 万个 Task 方便得多。Swift 底层会帮你调度，充分利用多核 CPU。

### 5. @MainActor — 主线程隔离（MainActor）

在 iOS/macOS 应用中，更新 UI 必须在主线程上：

```swift
@MainActor
func updateUI() {
    // 这个方法保证在主线程执行
    label.text = "Updated!"
    imageView.image = newImage
}

// 在后台任务中调用：
Task {
    let data = try await fetchFromNetwork()
    // 回到主线程更新 UI
    await MainActor.run {
        updateUI()
    }
}
```

`@MainActor` 是 Swift 对主线程的标注。被它标注的函数/类只能在主线程调用。编译器会确保这一点，不需要你手动检查。

### 6. Sendable — Swift 6.0 严格并发

Swift 6.0 引入了 **Strict Concurrency**（严格并发），核心是 `Sendable` 协议：

```swift
// 不可变数据天然安全
struct Config: Sendable {
    let apiKey: String
    let timeout: Int
}

// 引用类型需要显式标注
actor UserCache: Sendable {
    private var cache: [String: String] = [:]

    func get(_ key: String) -> String? {
        cache[key]
    }
}
```

`Sendable` 意味着"这个类型的值可以安全地跨线程传递"。Swift 6.0 编译器会在编译时检查所有跨线程数据传递，从根本上杜绝数据竞争。

**传统方式** vs **Swift 6.0**:
- **传统方式**：运行时崩溃（数据竞争），需要你用锁、信号量等手动避免
- **Swift 6.0**：编译时检查，不符合 Sendable 的代码无法通过编译，把数据竞争消灭在编译阶段

### 7. async/await vs 传统回调 Completion Handler 的写法：

```swift
// 传统回调方式
func fetchUser(id: Int, completion: (Result<String, Error>) -> Void) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        // ...
    }
}
```

```swift
// async/await 方式
func fetchUser(id: Int) async throws -> String {
    let (data, _) = try await URLSession.shared.data(from: url)
    return String(data: data, encoding: .utf8)!
}
```

对比之下，**async/await 方式**：
- 代码更简洁，没有嵌套的回调
- 错误处理用 `try/catch`，更直观
- 调试友好，断点可以正常设置
- 避免了回调地狱 (callback hell)

### 8. AsyncSequence — 异步序列

对于需要持续接收的数据（比如传感器读数、实时消息），用 `AsyncSequence`：

```swift
// 来自 ConcurrencySample.swift 的 SensorManager
class SensorManager {
    func startMonitoring() -> AsyncStream<String> {
        let (stream, continuation) = AsyncStream.makeStream(of: String.self)

        Task {
            let dataPoints = ["25°C", "26°C", "27°C"]
            for point in dataPoints {
                try await Task.sleep(for: .seconds(1))
                continuation.yield(point)  // 发送数据
            }
            continuation.finish()  // 结束流
        }

        return stream
    }
}

// 消费端 — for-await 循环
for await value in sensorStream {
    print("Received: \(value)")
}
```

`AsyncSequence` 和普通的 `Sequence` 类似，只是迭代时要用 `for await`。这非常适合需要流式处理数据的场景。

### 9. withCheckedContinuation — 桥接旧 API

当你要用旧有的 Completion Handler 包装成 async 函数：

```swift
func loadResource(url: URL) async throws -> Data {
    // 旧 API：URLSession.dataTask 使用回调
    try await withCheckedThrowingContinuation { continuation in
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                continuation.resume(throwing: error)
            } else if let data = data {
                continuation.resume(returning: data)
            }
        }
        task.resume()
    }
}
```

`withCheckedContinuation` 把你的回调"桥接"成 async 函数。编译器会检查是否 resume 了，如果忘记调用 resume 会崩溃（开发阶段提醒）。

---

## 常见错误

### 错误 1: 忘记 await

```swift
func fetch() async -> String { "data" }

let data = fetch() // ❌ 编译错误！
```

**编译器输出**:
```
error: call to async initializer 'fetch()' in a synchronous function
```

**修复方法**:
```swift
let data = await fetch() // ✅ 加上 await
```

### 错误 2: 在非 async 函数中调用 async 函数

```swift
func syncFunction() {
    let data = await fetch() // ❌ 不能在同步函数中使用 await
}
```

**编译器输出**:
```
error: 'async' call in a function that does not support concurrency
```

**修复方法**: 把外层函数也标记为 async，或者用 `Task` 包装：

```swift
func syncFunction() {
    Task {
        let data = await fetch()
    }
}
```

### 错误 3: 数据竞争（违反 Sendable）

```swift
class Counter {
    var count = 0

    func increment() {
        count += 1  // 多线程调用会出问题
    }
}

// Swift 6.0 编译器报错
Task.detached {
    await counter.increment() // 可能报错
}
```

**编译器输出**:
```
error: reference to class 'Counter' is not concurrency-safe
```

**修复方法**: 使用 `actor` 替代 class：

```swift
actor Counter {
    var count = 0

    func increment() {
        count += 1  // ✅ 安全，actor 保证串行访问
    }
}
```

---

## Swift vs Rust/Python 对比

| 概念 | Python | Rust | Swift | 关键差异 |
|------|--------|------|-------|----------|
| 异步函数 | `async def` | `async fn` | `async` 函数 | 语法几乎一样 |
| 等待操作 | `await` | `await` | `await` | 完全一致 |
| 协程/任务 | `asyncio.Task` | `tokio::Task` | `Task` | 都类似 |
| 并行绑 | 不支持 | 直接 `join` TaskGroup` | `async let` | Python 需手动 |
| 共享数据 | GIL（锁） | `Arc<Mutex<T>>` | `Actor` + `Sendable` | Swift 编译时检查 |
| 数据竞争保护 | 无 | 所有权系统 + Sendable | Sendable + Strict Concurrency | Swift 6.0 编译时 |
| 异步流 | `async for` | `Stream` trait | `AsyncSequence` | 都有 |

---

## 动手练习

### 练习 1: async let 并行加载

写一个函数，同时发起 3 个模拟网络请求（每个延迟 1 秒），总共只需约 1 秒。用 `async let` 实现。

<details>
<summary>点击查看答案</summary>

```swift
func mockFetch(id: Int) async -> String {
    await Task.sleep(for: .seconds(1))
    return "Result \(id)"
}

func runParallel() async {
    async let r1 = mockFetch(id: 1)
    async let r2 = mockFetch(id: 2)
    async let r3 = mockFetch(id: 3)

    let results = await [r1, r2, r3]
    print("All done: \(results)")
}
// 总耗时约 1 秒（并行），而非 3 秒（串行）
```

</details>

### 练习 2: 用 actor 实现线程安全计数器

写一个 `actor` 实现计数器，包含 `increment()` 和 `getCount()` 方法。创建 10 个并发任务各调用 increment 100 次，最后打印结果。

<details>
<summary>点击查看答案</summary>

```swift
actor ThreadSafeCounter {
    private var value = 0

    func increment() {
        value += 1
    }

    func getCount() -> Int {
        value
    }
}

func testCounter() async {
    let counter = ThreadSafeCounter()

    // 10个并发任务，每个加100次
    let tasks = (1...10).map { _ in
        Task {
            for _ in 0..<1000 {
                await counter.increment()
            }
        }
    }

    await withTaskGroup(of: Void.self) { group in
        for task in tasks {
            group.addTask {
                await task.value
            }
        }
    }

    let final = await counter.getCount()
    print("Final count: \(final)")  // 应该是 10000
}
```

**解析**: 每个任务的 increment() 是 actor 的方法，actor 保证串行执行，所以即使并发也不会丢失数据。

</details>

### 练习 3: async/await vs Completion Handler 对比

把下面 Completion Handler 风格的函数改写成 async/await：

```swift
func oldStyleLoad(name: String, completion: @escaping (Data?) -> Void) {
    DispatchQueue.global().async {
        let url = Bundle.main.url(forResource: name, withExtension: "txt")!
        completion(try? Data(contentsOf: url))
    }
}
```

<details>
<summary>点击查看答案</summary>

```swift
func asyncLoadResource(name: String) async throws -> Data {
    try await withCheckedThrowingContinuation { continuation in
        DispatchQueue.global().async {
            let url = Bundle.main.url(forResource: name, withExtension: "txt")!
            if let data = try? Data(contentsOf: url) {
                continuation.resume(returning: data)
            } else {
                continuation.resume(throwing: CocoaError(.fileReadCorruptFile))
            }
        }
    }
}

// 调用方
let data = try await asyncLoadResource(name: "test")
print("Loaded \(data.count) bytes")
```

**解析**: 用 `withCheckedThrowingContinuation` 把回调包装成 async 函数，调用方可以直接用 `await`。
</details>

---

## 故障排查 FAQ

### Q: async/await 和 GCD (Grand Central Dispatch) 有什么区别？

**A**: GCD 是基于线程的，你需要手动管理线程切换；async/await 是基于任务的（Task），系统自动调度：

```swift
// GCD 方式
DispatchQueue.global().async {
    let data = fetchData()
    DispatchQueue.main.async {
        updateUI(data)
    }
}

// async/await 方式
func load() async {
    let data = await fetchData()  // 自动返回主线程
    updateUI(data)  // 自动回到主线程
}
```

async/await 的优点：
- **更少的线程切换**：系统自动选择最优线程
- **更好的错误处理**：用 try/catch
- **结构化并发**：Task 有生命周期管理，不会"忘记"等待
- **编译时安全**：Swift 6.0 强制检查数据竞争

### Q: Actor 和 class 有什么区别？

**A**: 
- **class** — 线程不安全。多个线程同时访问会导致数据竞争
- **actor** — 线程安全。actor 内部的方法每次只能被一个任务调用

```swift
class UnsafeCounter {
    var count = 0
    func increment() { count += 1 }  // ❌ 多线程不安全
}

actor SafeCounter {
    var count = 0
    func increment() { count += 1 }  // ✅ 安全
}
```

简单记忆：需要线程安全时用 actor，其他用 class。

### Q: Sendable 是什么？我的类型都需要实现它吗？

**A**: `Sendable` 是标记"可以在线程安全地传递的类型。

- **值类型**（struct、enum）— 天然 Sendable（每次传递是拷贝）
- **引用类型**（class、actor）— 需要显式标注 @Sendable 并保证线程安全
- **只包含不可变数据的 struct** — 自动符合 Sendable

Swift 6.0 模式下，跨线程传递非 Sendable 类型会编译报错。

---

## 小结

**核心要点**：

1. **async/await 让异步代码可读性高** — 写起来像同步代码，但底层是异步的
2. **async let 实现并行** — 多个独立任务同时启动，最后 await
3. **Task 是并发基本单元** — 后台执行异步操作
4. **TaskGroup 管理大量任务** — 动态创建、自动等待
5. **Swift 6.0 编译时保证安全** — Sendable + actor 消灭数据竞争

**关键术语**：

- **Async/Await**: 异步编程关键字（标记异步函数和执行暂停）
- **Task**: 并发任务（异步执行的基本单位）
- **Actor**: 线程隔离类型（保证串行访问内部状态）
- **Sendable**: 可安全跨线程传递（标记线程安全类型）
- **TaskGroup**: 任务组（管理多个子任务的创建和等待）
- **AsyncSequence**: 异步序列（流式数据传输）
- **Continuation**: 延续（桥接回调到 async 的机制）

---

## 术语表

| English | 中文 |
|---------|------|
| Async/Await | 异步等待 |
| Task | 并发任务 |
| TaskGroup | 任务组 |
| Actor | 角色（线程安全类型） |
| @MainActor | 主线程隔离 |
| Sendable | 可安全传递 |
| Strict Concurrency | 严格并发（Swift 6.0） |
| AsyncSequence | 异步序列 |
| Continuation | 延续 |
| Data Race | 数据竞争 |
| Structured Concurrency | 结构化并发 |
| Completion Handler | 完成回调 |
| DispatchSemaphore | 信号量 |

---

完整示例：`Sources/BasicSample/ConcurrencySample.swift`（asyncTaskSample / actorSample / batchAcotrSample / asyncStreamSample / simpleThreadSample）

---

## 知识检查

**问题 1** 🟢 (基础概念)

`async` 函数的调用必须在什么环境中？

A) 任何函数中直接调用  
B) 另一个 async 函数或 Task 中  
C) 主线程中  
D) do-catch 块中

<details>
<summary>答案与解析</summary>

**答案**: B) 另一个 async 函数或 Task 中

**解析**: 异步函数只能在同样支持并发的上下文中调用。要么在另一个 async，要么用 Task 包装。直接在同步函数中调用 `await` 会导致编译错误。

</details>

**问题 2** 🟡 (设计决策)

有 10 个 HTTP 请求相互独立。如何最小化总耗时。应该用什么？

A) 顺序调用 10 次  
B) 用 async let 同时发出  
C) 用 10 个 Thread  
D) 用 GCD 的 DispatchQueue

<details>
<summary>答案与解析</summary>

**答案**: B) 用 async let 同时发出

**解析**: 所有请求相互独立，用 async let 可以立即全部发出，总耗时至最多请求的时间。Thread/GCD 需要手动管理线程，async let 更简洁。

</details>

**问题 3** 🔴 (actor 隔离）

```swift
actor BankAccount {
    private var balance: Double = 0

    func deposit(_ amount: Double) {
        balance += amount
    }

    func withdraw(_ amount: Double) {
        balance -= amount
    }

    func getBalance() -> Double {
        balance
    }
}

let account = BankAccount()
// 在 Task 中并发调用
await account.deposit(100)
await account.withdraw(30)
let bal = await account.getBalance()
print(bal)
```

`bal` 的值是什么？为什么是安全的？

<details>
<summary>答案与解析</summary>

**答案**: 70.0

**解析**: actor 内部的方法调用总是串行的，不会并发。所以 deposit 和 withdraw 不会同时执行，不存在数据竞争。`await` 等待方法完成后再获取结果，确保数据一致性。

</details>

---

## 延伸阅读

学完并发编程后，你可能还想了解：

- [Swift 官方文档 - Concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/) — 完整并发语言参考
- [Swift 5.5 Release Notes](https://www.swift.org/blog/swift-5.5-released/) — async/await 和 actor 首次引入
- [Swift Evolution SE-304 Structured Concurrency](https://github.com/apple/swift-evolution/blob/main/proposals/0304-structured-concurrency.md) — 结构化并发提案
- [Swift 6.0 Strict Concurrency](https://www.swift.org/blog/swift-6.0/) — 编译时数据竞争检查

**选择建议**:
- 初学者 → 继续学习 [错误处理](error-handling.md) 或 [闭包](closures.md)
- 有经验开发者 → 探索 [进阶 JSON 处理](../advance/advance.md) 中的 SwiftNIO 异步编程
- 准备生产级应用 → 阅读 Swift 并发安全指南和 Sendable 要求

> 记住：Swift 的并发设计哲学是"让正确的做法变得简单"。async/await 让异步代码像同步代码一样易读，actor 让线程安全像类一样简单，Swift 6.0 让数据竞争在编译时就消失。这是现代并发编程的未来方向。

---

## 继续学习

- 下一步：[错误处理](error-handling.md) — 异步操作中的错误处理模式
- 相关：[闭包](closures.md) — 回调式并发 vs async/await
- 进阶：[SwiftNIO](../advance/advance.md) — 高性能网络服务的并发实践
