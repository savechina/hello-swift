# 🎭 Actors基础 (Actors Basics)

## 开篇故事

想象一家银行的金库。金库里堆满了现金和珠宝，但只有一位出纳员（Teller）可以同时进出。第二位顾客想取钱？没关系，排队等候。不会出现两个出纳员同时伸手进同一个保险箱，你多取 100、我少记 100 的情况。

Swift 里的 Actor（参与者）就是这个"只能一人进出"的金库。当你有多个任务（Task）同时读写同一份数据时，Actor 保证每次只有一个任务能访问里面的状态。它不是锁（Lock），不是信号量（Semaphore），它是编译器帮你强制执行的安全边界。

在并发编程里，这种"同一时刻只允许一个访问者"的机制叫 **互斥（Mutual Exclusion）**。Actor 把互斥变成语言级别的原生特性，你不需要手动加锁解锁，编译器替你做了。

本章要教你的，就是如何用 Actor 给你的共享数据穿上一件防弹衣。

## 本章适合谁

如果你满足以下任一情况，这一章就是为你准备的：

- 你在写并发代码（Concurrency），多个 Task 会读写同一个可变状态
- 你曾经遇到过数据竞争（Data Race），两个线程同时改一个变量导致结果错乱
- 你听说过 Swift Actor 但不太清楚它和 Class 有什么区别
- 你想用比 `NSLock` 更 Swift 的方式保证线程安全

本章面向已经理解 `async`/`await` 的开发者。如果你还不熟悉异步编程，建议先回顾基础部分的并发编程章节。

## 你会学到什么

完成本章后，你将掌握以下内容：

- **Actor 定义**（Actor Definition）：用 `actor` 关键字声明一个带隔离状态的类型
- **Actor 隔离**（Actor Isolation）：理解为什么访问 actor 内部的属性和方法必须用 `await`
- **跨隔离调用**（Crossing Isolation Boundary）：掌握 `nonisolated` 属性的使用场景
- **Actor vs Class**：什么时候用 Actor，什么时候用 Class

## 前置要求

在开始之前，请确保你已掌握以下内容：

- macOS 12.0+ / Linux（Ubuntu 22.04+）
- Swift 6.0+ 编译器
- `async` / `await` 异步编程基础（来自 BasicSample 的并发章节）
- Swift 的类（Class）和结构体（Struct）的基础概念
- 基本的并发概念：任务（Task）、线程（Thread）

如果你对这些内容还不太熟悉，建议先回顾 `ConcurrencySample` 中的 `async/await` 示例，然后再回来。

## 第一个例子

我们从一个真实的银行场景开始。创建 `BankAccount` actor，进行存款和取款操作。

这段代码来自 `AdvanceSample/Sources/AdvanceSample/ActorSample.swift`。

```swift
// 定义一个 BankAccount actor
actor BankAccount {
    let accountNumber: Int
    var balance: Double
    
    init(accountNumber: Int, initialBalance: Double) {
        self.accountNumber = accountNumber
        self.balance = initialBalance
    }
    
    // 存款：修改隔离状态
    func deposit(amount: Double) {
        balance += amount
    }
    
    // 取款：返回 Bool 表示是否成功（余额不足时返回 false）
    func withdraw(amount: Double) -> Bool {
        guard balance >= amount else { return false }
        balance -= amount
        return true
    }
    
    // 查询余额
    func getBalance() -> Double {
        return balance
    }
    
    // nonisolated 属性：不参与隔离，可以直接访问
    nonisolated var description: String {
        "Account #\(accountNumber)"
    }
}
```

创建实例并调用方法：

```swift
func actorSample() async {
    // 创建 actor 实例（注意：actor 的创建不需要 await）
    let account = BankAccount(accountNumber: 1, initialBalance: 1000)
    print("Created: \(account)")
    
    // 调用 actor 方法必须加 await —— 因为你在跨越隔离边界
    await account.deposit(amount: 500)
    let balance = await account.getBalance()
    print("After deposit: \(balance)")  // 输出: 1500.0
    
    // 取款返回 Bool，余额充足时成功
    let success = await account.withdraw(amount: 200)
    print("Withdraw 200: \(success ? "success" : "failed")")  // 输出: success
    
    // 余额不足时取款失败
    let overdrawn = await account.withdraw(amount: 9999)
    print("Withdraw 9999: \(overdrawn ? "success" : "failed")")  // 输出: failed
    
    let finalBalance = await account.getBalance()
    print("Final balance: \(finalBalance)")  // 输出: 1300.0
}
```

三步流程：创建 actor → `await` 调用方法 → 获取结果。和调用普通 Class 的区别只在于 `await` 关键字，但编译器在背后为你做了完全不同的事情。

## 原理解析

### actor 关键字

`actor` 是 Swift 5.5 引入的核心并发特性。它和 `class` 一样是引用类型（Reference Type），但内部状态默认处于 **隔离域（Isolated Domain）**。同一时刻，只有一个执行上下文（Execution Context）能读写 actor 的内部数据。

```
  ┌─────────────────────────────────┐
  │         BankAccount actor        │
  │  ┌───────────────────────────┐  │
  │  │   isolated state:          │  │
  │  │   accountNumber: Int       │  │
  │  │   balance: Double          │  │
  │  │                            │  │
  │  │   deposit()  ← 串行队列     │  │
  │  │   withdraw() ← 串行队列     │  │
  │  │   getBalance() ← 串行队列   │  │
  │  └───────────────────────────┘  │
  │                                  │
  │  description ← nonisolated 可直接│
  └─────────────────────────────────┘
           ▲         ▲
      Task A     Task B
     (await 调用)  (排队等待)
```

### Actor 隔离（Actor Isolation）

Actor 内部的属性和方法默认为 `isolated`。当你从 actor 外部（比如一个 `Task`）访问这些成员时，你在 **跨越隔离边界（Crossing Isolation Boundary）**。Swift 要求你用 `await` 标注这个跨越。

```swift
// ❌ 编译错误：Actor-isolated instance member cannot be referenced from a non-isolated context
let b = account.getBalance()

// ✅ 正确：用 await 跨越隔离边界
let b = await account.getBalance()
```

`await` 不是可选的修饰符。它告诉编译器和运行时："这个调用可能等待，因为另一个 Task 可能正在操作同一个 actor。"

### nonisolated

不是所有属性都需要隔离。`nonisolated` 标注的成员不参与 actor 的互斥机制，可以在 `await` 之外直接访问。一般用于：

- 只读计算属性（不涉及 `var` 可变状态的读取）
- 调试用信息（比如 `description`）
- 常量（`let`）已经不可变，不需要保护

```swift
// description 是 nonisolated 的，因为 accountNumber 是 let，读取时不需要互斥
nonisolated var description: String {
    "Account #\(accountNumber)"
}

// 这行代码不需要 await
print("Created: \(account)")  // 自动调用 description
```

### Actor vs Class

| 特性 | Actor | Class |
|---|---|---|
| 类型 | 引用类型 | 引用类型 |
| 状态保护 | 编译器强制（Actor Isolation） | 手动（NSLock / os_unfair_lock） |
| 跨线程访问 | 安全，串行化（Serialized） | 不安全，需要手动同步 |
| 方法调用 | 外部调用必须 `await` | 直接调用 |
| 重入性（Reentrancy） | 存在（下文会讲） | N/A |
| 声明关键字 | `actor` | `class` |

一句话总结：如果一段可变状态会被多个 Task 并发访问，用 Actor 比用 Class + 手动加锁更安全、更简洁。

## 常见错误

以下是最容易踩到的坑：

| 错误 | 症状 | 原因 | 修复 |
|---|---|---|---|
| 遗漏 `await` | 编译错误："Actor-isolated instance member cannot be referenced from a non-isolated context" | 从 actor 外部调用方法没加 `await` | 在所有 actor 方法调用前加 `await` |
| **可重入性陷阱（Reentrancy）** | 逻辑错误：余额被扣成负数 | actor 在一个 `await` 点让出控制权，另一个调用进入导致状态被篡改 | 把 `await` 放在尽可能少的地方，或者在操作结束前不跨越 await 点 |
| 阻塞等待 | 死锁（Deadlock）| 在 actor 的方法内部调用另一个 `await`，而这个 await 又依赖同一个 actor 的响应 | 避免在 actor 方法内调用自己或其他 actor 的 await 方法 |
| 隔离域混淆 | 编译错误："Main actor-isolated property cannot be referenced from a non-isolated context" | 把 `@MainActor` 标注的类型当成普通 actor 使用 | 区分普通 actor 和 `@MainActor`，后者只能在 Main Thread 上运行 |

重点讲讲 **可重入性（Reentrancy）**。Actor 在遇到 `await` 时会释放控制权，允许其他调用进入：

```swift
// 危险：如果 doSomethingElse() 里有 await，另一个 withdraw 可能在它之前执行
actor RiskyBankAccount {
    var balance: Double
    
    func riskyWithdraw(amount: Double) async -> Bool {
        if balance >= amount {
            await someExternalService.verify()  // ← 这里 await 了！
            balance -= amount  // ← 另一个 withdraw 可能已经改过 balance
            return true
        }
        return false
    }
}
```

正确做法是把所有可变状态操作放在 await 之前完成：

```swift
actor SafeBankAccount {
    var balance: Double
    
    func safeWithdraw(amount: Double) async -> Bool {
        guard balance >= amount else { return false }
        balance -= amount  // 同步完成，没有 await
        // 现在才去 await 外部服务
        await someExternalService.logWithdraw(amount)
        return true
    }
}
```

## Swift vs Rust/Python 对比

不同语言的并发安全机制放在一起对比会更有感觉：

| 特性 | Swift (Actor) | Rust (Mutex) | Python (threading.Lock) |
|---|---|---|---|
| 定义方式 | `actor BankAccount { ... }` | `let account: Mutex<BankAccount>` | `lock = threading.Lock()` |
| 保护机制 | 编译器强制隔离 | 类型系统强制 `lock()` 才能访问 | 运行时约定，不遵守不会报错 |
| 访问语法 | `await account.withdraw(100)` | `account.lock().withdraw(100)` | `with lock: account.withdraw(100)` |
| 死锁预防 | 单 actor 串行队列，无嵌套锁 | 编译期检查，Rust 1.63+ 有 `Mutex` | 手动管理，容易死锁 |
| 可变状态 | actor 内部的 `var` | 锁包装的内部数据 | `with lock:` 块内的数据 |
| 性能开销 | 消息队列，任务挂起/唤醒 | 系统级锁，内核调度 | GIL + 线程锁，较慢 |
| 学习成本 | 低（关键字 + await） | 中（需要理解 Ownership） | 低（库级别 API） |

Swift Actor 的独特之处：**隔离是编译器强制的，不是约定**。你忘了 `await` 编译器不会让你编译通过。Rust 的 Mutex 也是编译期保证的，但需要理解 Ownership 和 Borrow Checker。Python 的 Lock 完全靠程序员自觉，漏了 `with lock:` 代码照样跑但可能出 bug。

## 动手练习 Level 1

**目标**：创建一个 `Counter` actor，支持递增和递减。

要求：

1. 定义 `Counter` actor，有一个 `var count: Int` 属性，初始值为 0
2. 实现 `increment()` 方法，让 count 加 1
3. 实现 `decrement()` 方法，让 count 减 1
4. 实现 `getCount() -> Int` 方法，返回当前值
5. 在一个 `Task` 中创建 Counter，递增 3 次，递减 1 次，打印最终值

<details>
<summary>点击查看答案</summary>

```swift
actor Counter {
    var count: Int = 0
    
    func increment() {
        count += 1
    }
    
    func decrement() {
        count -= 1
    }
    
    func getCount() -> Int {
        count
    }
}

func exercise1() async {
    let counter = Counter()
    await counter.increment()
    await counter.increment()
    await counter.increment()
    await counter.decrement()
    
    let result = await counter.getCount()
    print("最终值: \(result)")  // 输出: 2
}
```
</details>

## 动手练习 Level 2

**目标**：创建一个 `ThreadSafeArray` actor，提供数组的安全读写操作。

要求：

1. 定义 `ThreadSafeArray<T>` 泛型 actor，内部持有一个 `var items: [T]`
2. 实现 `append(_ item: T)` 方法，追加元素
3. 实现 `get(_ index: Int) -> T?` 方法，按索引获取，索引越界返回 `nil`
4. 实现 `count() -> Int` 方法
5. 用 `[Int]` 实例化它，追加 3 个数字，读取索引 1 的元素

<details>
<summary>点击查看答案</summary>

```swift
actor ThreadSafeArray<T> {
    private var items: [T] = []
    
    func append(_ item: T) {
        items.append(item)
    }
    
    func get(_ index: Int) -> T? {
        guard items.indices.contains(index) else { return nil }
        return items[index]
    }
    
    func count() -> Int {
        items.count
    }
}

func exercise2() async {
    let safeArray = ThreadSafeArray<Int>()
    await safeArray.append(10)
    await safeArray.append(20)
    await safeArray.append(30)
    
    let item = await safeArray.get(1)
    let count = await safeArray.count()
    
    print("索引 1 的值: \(item ?? -1)")  // 输出: 20
    print("数组长度: \(count)")          // 输出: 3
}
```

泛型 Actor 和泛型 Struct/Class 的声明方式完全一样，把 `<T>` 放在 `actor` 关键字后面即可。
</details>

## 动手练习 Level 3

**目标**：构建一个 `Bank` 来管理多个账户，支持账户间转账。

要求：

1. 复用上面的 `BankAccount` actor
2. 定义 `Bank` 类，内部维护 `[Int: BankAccount]` 字典（用账户号映射）
3. 实现 `createAccount(accountNumber: Int, initialBalance: Double)` 方法
4. 实现 `transfer(from: Int, to: Int, amount: Double) async -> Bool` 方法：从源账户取钱，存到目标账户
5. 测试：创建两个账户，转账后检查余额变化

注意：转账涉及两个不同的 actor **交替操作**。`await` 取钱之后，可能在存钱之前另一个操作干扰了源账户。这里演示了多 actor 协调的复杂性。

<details>
<summary>点击查看答案</summary>

```swift
actor BankAccount {
    let accountNumber: Int
    var balance: Double
    
    init(accountNumber: Int, initialBalance: Double) {
        self.accountNumber = accountNumber
        self.balance = initialBalance
    }
    
    func deposit(amount: Double) {
        balance += amount
    }
    
    func withdraw(amount: Double) -> Bool {
        guard balance >= amount else { return false }
        balance -= amount
        return true
    }
    
    func getBalance() -> Double {
        balance
    }
    
    nonisolated var description: String {
        "Account #\(accountNumber)"
    }
}

class Bank {
    private var accounts: [Int: BankAccount] = [:]
    
    func createAccount(accountNumber: Int, initialBalance: Double) {
        accounts[accountNumber] = BankAccount(
            accountNumber: accountNumber,
            initialBalance: initialBalance
        )
    }
    
    func transfer(from: Int, to: Int, amount: Double) async -> Bool {
        guard let fromAccount = accounts[from],
              let toAccount = accounts[to] else {
            print("账户不存在")
            return false
        }
        
        // 先从源账户取款
        let withdrawn = await fromAccount.withdraw(amount: amount)
        guard withdrawn else {
            print("余额不足，转账失败")
            return false
        }
        
        // 再存入目标账户
        await toAccount.deposit(amount: amount)
        return true
    }
    
    func getBalance(accountNumber: Int) async -> Double? {
        guard let account = accounts[accountNumber] else { return nil }
        return await account.getBalance()
    }
}

func exercise3() async {
    let bank = Bank()
    bank.createAccount(accountNumber: 1, initialBalance: 1000)
    bank.createAccount(accountNumber: 2, initialBalance: 500)
    
    print("转账前:")
    if let b1 = await bank.getBalance(accountNumber: 1) {
        print("账户 1: \(b1)")
    }
    if let b2 = await bank.getBalance(accountNumber: 2) {
        print("账户 2: \(b2)")
    }
    
    let ok = await bank.transfer(from: 1, to: 2, amount: 300)
    print("转账 300: \(ok ? "成功" : "失败")")
    
    print("转账后:")
    if let b1 = await bank.getBalance(accountNumber: 1) {
        print("账户 1: \(b1)")  // 输出: 700.0
    }
    if let b2 = await bank.getBalance(accountNumber: 2) {
        print("账户 2: \(b2)")  // 输出: 800.0
    }
}
```

注意这里的 `transfer` 方法本身 **没有** 标记为 `actor`，它是一个普通方法。它内部通过 `await` 分别调用两个 actor 的方法来协调操作。真正的并发安全由每个 `BankAccount` actor 自身保证。
</details>

## 故障排查 FAQ

**Q1：为什么调用 actor 方法必须加 `await`，创建 actor 却不需要？**

创建 actor 只是分配内存空间（和创建 class 一样），此时还没有任何 Task 在访问它的内部状态。`await` 是跨越隔离边界时需要的，创建动作本身不涉及隔离。

**Q2：`nonisolated` 可以标注方法吗？**

可以。`nonisolated func someMethod() { ... }` 表示这个方法不从 actor 外部调用也需要 `await`。但要注意：`nonisolated` 方法不能访问 actor 内的 `var` 属性，只能访问 `let` 常量和其他 `nonisolated` 成员。

**Q3：Actor 里能不能用 `DispatchQueue` 或者其他同步原语？**

技术上可以，但不推荐。Actor 的设计目的就是取代手动同步原语。如果你在 actor 里又用了 `NSLock` 或 `DispatchSemaphore`，说明设计可能有问题。把状态保护交给 actor，不要在它里面再加一层锁。

**Q4：多个 actor 同时调用会不会死锁？**

单个 actor 不会产生死锁，因为它的消息队列是串行的（FIFO）。但多个 actor 之间互相 `await` 可能产生死锁，比如 Actor A 等 Actor B，Actor B 又在等 Actor A。避免方法：不要做循环依赖的跨 actor 调用。

**Q5：Actor 和 `@MainActor` 有什么区别？**

`@MainActor` 是一个标注了特定执行器的 actor —— 它绑定到主线程（Main Thread），常用于 UI 更新。普通 actor 不绑定到任何特定线程，Swift 运行时会自动调度。如果你在 UIKit/AppKit 环境下从后台 Task 更新 UI，编译器会报错，这时用 `@MainActor` 标注你的方法。

**Q6：actor 内部调用自己的方法要不要加 `await`？**

不需要。在 actor 内部调用自己的方法属于 **同隔离域调用（Same-Isolation Call）**，编译器知道不会有并发冲突。

```swift
actor BankAccount {
    var balance: Double = 0
    
    func deposit(amount: Double) {
        balance += amount
    }
    
    func depositTwice(amount: Double) {
        deposit(amount: amount)  // 不需要 await
        deposit(amount: amount)  // 不需要 await
    }
}
```

## 小结

- **Actor 是 Swift 的并发安全类型**，用 `actor` 关键字声明，内部状态默认隔离
- **访问隔离成员必须用 `await`**，这是编译器强制的跨越隔离边界操作
- **`nonisolated`** 让你标记不需要保护的成员（常量、只读计算属性），避免不必要的异步开销

## 术语表

| 中文 | 英文 | 说明 |
|------|------|------|
| 参与者 | Actor | Swift 5.5 引入的并发安全引用类型，保证内部状态互斥访问 |
| 隔离域 | Isolated Domain | Actor 内部状态的受保护区域，外部访问需跨越隔离边界 |
| 隔离边界 | Isolation Boundary | 从 actor 外部访问其隔离成员的边界线，跨越时须用 `await` |
| 非隔离 | Nonisolated | 标注不参与 actor 隔离的成员，可直接访问不需要 `await` |
| 可重入性 | Reentrancy | Actor 在 await 点释放控制权的现象，可能导致状态被其他调用篡改 |
| 串行化 | Serialization | 多个 Task 对同一 actor 的访问按顺序执行，而非并行 |
| 执行上下文 | Execution Context | 执行 actor 方法的运行时环境，同一时刻只有一个 |

## 知识检查

用三个问题检验你是否真正掌握了本节内容。

**问题一**：以下代码为什么编译失败？

```swift
actor Counter {
    var value: Int = 0
}

func main() {
    let c = Counter()
    print(c.value)  // ← 编译错误
}
```

<details>
<summary>查看答案</summary>

`value` 是 actor 隔离的实例成员，从 `main()` 这个非隔离上下文中访问需要 `await`。正确写法：

```swift
func main() async {
    let c = Counter()
    print(await c.value)  // 加 await 跨越隔离边界
}
```
</details>

**问题二**：`nonisolated` 标注的方法能不能修改 actor 内部的 `var` 属性？

<details>
<summary>查看答案</summary>

不能。`nonisolated` 表示该方法不参与 actor 的互斥机制，因此编译器不允许它访问或修改可变状态（`var`）。只能读取 `let` 常量和访问其他 `nonisolated` 成员。如果需要修改 `var`，方法必须是隔离的（不加 `nonisolated`）。
</details>

**问题三**：Actor 和加了 `NSLock` 的 Class 在功能上有什么区别？

<details>
<summary>查看答案</summary>

功能上等价：都保证了同一时刻只有一个线程读写共享状态。但区别在于：

1. **编译器强制 vs 开发者约定**：Actor 漏了 `await` 编译不过；Class + Lock 漏了 `lock()` 编译通过但运行会出错
2. **语法简洁度**：Actor 天然集成 `async`/`await`；Class + Lock 需要手动包装 `lock()` / `unlock()`
3. **死锁风险**：单 Actor 无嵌套锁不会死锁；Class + Lock 嵌套使用可能死锁
4. **重入性**：Actor 有可重入特性（await 时让出控制权）；Lock 是阻塞式等待
</details>

## 继续学习

Actor 是 Swift 并发模型的基石之一。理解了基础的 actor 隔离和 await 调用，你可以进一步深入了解：

- **[Sendable 深入](./sendable-deep.md)**：数据在 Task 和 Actor 之间传递时需要遵守 Sendable 协议，编译器会确保数据跨线程安全

如果还想回顾整个高级进阶的内容目录，查看 [高级概览](./advance-overview.md)。
