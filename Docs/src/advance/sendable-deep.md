# Sendable 深入理解

## 📦 开篇故事

想象你在做跨境电商。你要把包裹从中国寄到美国，途中要经过海关、航空货运、快递分拣中心，每个环节都有不同的人在搬运你的包裹。

什么样的包裹能安全到达？——**密封完好的标准化箱子**。里面装的是衣服、书本这类不会自己变的东西。即使两个包裹同时上路，各自的内容也不会互相影响。

什么样的包裹会出问题？——**一个开着盖的活体动物箱**。里面的兔子会在途中跑出来，可能跑到另一个箱子里去。如果两个人同时打开箱子检查，兔子状态就不可控了。

Swift 中的 `Sendable` 协议就是海关的检查标准：**只有"密封好、内容安全"的数据才能被送到不同的并发任务中去。** 值类型（struct、enum）天然密封，引用类型（class）如果有可变状态就是"开着盖的箱子"。Swift 6 的严格并发检查（Strict Concurrency Checking）就是海关，它会拦住所有不安全的包裹。

---

## 👤 本章适合谁

你正在使用 **Swift 6.0 的严格并发检查模式**（`-strict-concurrency=complete`），编译器频繁报 `Sendable` 相关的警告或错误。你想理解：

- 为什么你的 struct 自动就是 `Sendable`，而 class 不是
- `@Sendable` 闭包标注到底在约束什么
- 如何系统性地修复 `non-Sendable capture` 错误

如果你刚接触 Swift 并发，建议先阅读基础部分的 **[并发编程](../basic/concurrency.md)** 章节，理解 `async/await`、`Task` 和 `Actor` 的基本用法后再回来。

---

## 🎯 你会学到什么

完成本章后，你可以：

- **理解 `Sendable` 协议的本质**：什么样的类型可以安全地跨并发边界传递
- **掌握 `@Sendable` 闭包标注**：如何声明一个闭包可以在不同线程安全执行
- **系统性修复 Sendability 错误**：识别非 Sendable 捕获、值类型隐式发送、`@unchecked Sendable` 等场景

---

## 📋 前置要求

- **macOS 12.0+ 或 Linux**（Ubuntu 22.04+）
- **Swift 6.0+**：本章基于 Swift 6 的严格并发检查
- 理解 `async`/`await` 异步编程模型
- 理解 `Task` 的创建和并发执行
- 建议已阅读基础部分 **[并发编程](../basic/concurrency.md)** 章节，了解 Actor 的基本概念

> **⚠️ 平台提醒**: `Sendable` 是 Swift 5.5 引入、Swift 6 强化的标准库协议，所有平台通用。但严格的编译期检查只在 Swift 6 的 `complete` 模式下才会全面生效。

---

## 🚀 第一个例子

打开代码文件 `AdvanceSample/Sources/AdvanceSample/ConcurrencyDeepSample.swift`，这是一个最简单的 `Sendable` 使用场景：

```swift
struct UserData: Sendable {
    let name: String
    let age: Int
}
```

`UserData` 是一个值类型（struct），所有属性都是不可变（`let`）且本身也是 `Sendable` 的类型（`String` 和 `Int`）。所以它天然可以安全地在并发任务之间传递。

接下来创建两个并发任务，同时读取同一份 `UserData`：

```swift
func sendableSample() async {
    let data = UserData(name: "Alice", age: 30)

    let task1 = Task {
        print("Task 1 sees: \(data.name), age \(data.age)")
        return data.age
    }

    let task2 = Task {
        try await Task.sleep(for: .milliseconds(10))
        print("Task 2 also sees: \(data.name)")
        return data.name
    }

    let age = await task1.value
    let name = await task2.value
    print("Results: \(name) is \(age)")
}
```

运行结果：

```
--- sendableSample start ---
Task 1 sees: Alice, age 30
Task 2 also sees: Alice
Results: Alice is 30
--- sendableSample end ---
```

两个 `Task` 并发执行，各自读取 `data` 的内容。因为 `UserData` 是 `Sendable`，编译器知道这是安全的——两个任务拿到的是各自独立的数据副本（值语义），不存在数据竞争。

---

## 🔬 原理解析

### 1. Sendable 协议是什么

`Sendable` 是 Swift 标准库中的一个标记协议（marker protocol）：

```swift
public protocol Sendable {
}
```

它没有任何方法要求，作用纯粹是**告诉编译器**："这个类型的实例可以安全地从并发执行域（actor、Task、线程）传递到另一个。"

当一个类型遵循 `Sendable` 时，编译器会验证它确实满足安全条件。如果不满足，编译报错。

### 2. 隐式 Sendable（Implicit Sendability）

不是所有类型都需要显式写 `: Sendable`。以下类型**自动**被视为 `Sendable`，编译器自动帮你加上了这个标签：

| 类型 | 自动 Sendable？ | 条件 |
|------|----------------|------|
| `struct` | ✅ 是 | 所有存储属性都是 Sendable |
| `enum`（无关联值） | ✅ 是 | 所有关联值类型都是 Sendable |
| `tuple` | ✅ 是 | 所有元素类型都是 Sendable |
| `let` 不可变属性 | ✅ 是 | 属性本身不可变且类型 Sendable |
| `final class` | ❌ 否 | 必须有 `@unchecked Sendable` 或手动声明（即使所有属性是 let） |
| `class`（非 final） | ❌ 否 | 子类可修改父类状态，永远不自动 Sendable |

这就是为什么前面的 `UserData` struct 即使不写 `: Sendable` 编译器也知道它是 Sendable，但加上显式标注可以让意图更明确。

### 3. @Sendable 闭包标注

闭包会**捕获**它所在作用域里的变量。当闭包被送到另一个并发任务中执行时，如果捕获的变量不是 `Sendable`，就会发生数据竞争。

`@Sendable` 标注强制编译器检查闭包捕获的所有外部变量是否满足 Sendable：

```swift
let closure: @Sendable () -> String = {
    return "Sendable closure captured: \(data.name)"
}
let result = Task(operation: closure)
print(await result.value)
// 输出: Sendable closure captured: Alice
```

`Task(operation:)` 本身就要求传入一个 `@Sendable` 闭包。如果 `data` 不是 Sendable 类型，这段代码编译就会报错。

### 4. 编译器的强制检查

在 Swift 6 严格模式下，以下场景编译器会报错：

- **非 Sendable 类型在 Task 闭包内被捕获**：`non-Sendable type 'XXX' captured by sendable closure`
- **非 Sendable 类型作为 Sendable 函数的参数传递**
- **非 Sendable 类型从 Actor 隔离域传出**

编译器不会放过任何一个可能的数据竞争隐患。

### 5. @unchecked Sendable（ unchecked 发送）

有些类型你确信是线程安全的（比如内部用了锁），但编译器无法自动推断。这时可以用 `@unchecked Sendable` 手动告诉编译器"我保证安全"：

```swift
class ThreadSafeCounter: @unchecked Sendable {
    private var _count: Int = 0
    private let lock = NSLock()

    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return _count
    }

    func increment() {
        lock.lock()
        defer { lock.unlock() }
        _count += 1
    }
}
```

⚠️ **警告**：`@unchecked Sendable` 等于关闭了编译器的 Sendable 检查。如果你保证错误，运行时不会有任何提示，直接导致数据竞争和未定义行为。只在确实理解并发安全的情况下使用。

### 6. 非 Sendable 的典型场景

回到源代码中的对比：

```swift
class NonSendableCounter {
    var count: Int = 0
}
```

这是一个普通的 class，有可变属性 `var count`。如果两个 Task 同时修改它，就会发生数据竞争：

```swift
let counter = NonSendableCounter()

let t1 = Task { counter.count += 1 }   // ⚠️ 编译警告
let t2 = Task { counter.count += 1 }   // ⚠️ 编译警告

await t1.value
await t2.value
print(counter.count)                   // 可能是 1 或 0 或 2 — 不可预测
```

Swift 6 严格模式会直接拦下这段代码。**修复方式**：改用 `actor` 保护状态，或者确保不跨 Task 访问。

---

## ❌ 常见错误

> 以下错误来源于大量开发者在实际项目中踩坑后的总结，按出现频率排列。

### 错误 1: 非 Sendable 类型在 @Sendable 闭包中被捕获

**症状：** 编译报错 `Capture of 'xxx' with non-Sendable type 'yyy' in a @Sendable closure`

```swift
class Config {
    var apiKey: String = ""
}

func runTask() async {
    let config = Config()  // Config 是 class，不是 Sendable

    Task {
        // ⚠️ 编译错误：config 是非 Sendable 的，闭包不能捕获它
        print("Using key: \(config.apiKey)")
    }
}
```

**修复：** 用 Sendable 的值类型替代 class，或在 Task 外部提取需要的值：

```swift
// 方案 A：改为 struct（值类型自动 Sendable）
struct Config {
    let apiKey: String
}

// 方案 B：在闭包外部提取值
func runTask() async {
    let config = Config()
    let key = config.apiKey  // String 是 Sendable

    Task {
        print("Using key: \(key)")  // ✅ 只捕获了 key（String），安全
    }
}
```

### 错误 2: Sendability 违反：非 Sendable 参数传入 Sendable 函数

**症状：** 编译报错 `Sending 'xxx' risks causing data races`

```swift
func processUserData(_ data: some Sendable) {
    // 要求参数必须 Sendable
}

class MutableUser {
    var name: String = ""
}

let user = MutableUser()
processUserData(user)  // ⚠️ 编译错误：MutableUser 不是 Sendable
```

**修复：** 将 class 改为 struct，或确保参数类型遵循 Sendable：

```swift
struct ImmutableUser: Sendable {
    let name: String
}

let user = ImmutableUser(name: "Alice")
processUserData(user)  // ✅ ImmutableUser 是 Sendable
```

### 错误 3: Actor 数据竞争：从外部直接访问 Actor 内部的可变状态

**症状：** 编译报错 `Actor-isolated property 'xxx' cannot be referenced from non-isolated context`

```swift
actor DataStore {
    var items: [String] = []

    func add(_ item: String) {
        items.append(item)
    }
}

let store = DataStore()
Task {
    store.items.append("hello")  // ⚠️ 编译错误：不能直接写 Actor 内部状态
}
```

**修复：** 通过 Actor 的方法间接访问：

```swift
Task {
    await store.add("hello")  // ✅ 通过 Actor 方法，自动 await 隔离
}
```

---

## ⚔️ Swift vs Rust/Python 对比

| 维度 | Swift (Sendable) | Rust (Send trait) | Python |
|------|-----------------|-------------------|--------|
| 并发安全机制 | `Sendable` 协议 + 编译器检查 | `Send` trait + 借用检查器（Borrow Checker） | 无内置机制，靠开发者自觉（GIL 部分保护） |
| 值类型可发送 | struct/enum 自动推断 | 几乎所有类型默认 `Send`（不含 `Rc`/`RefCell`） | 无值类型/引用类型区分 |
| 引用类型可发送 | class 需显式标注 `@unchecked Sendable` | 需手动实现 `Send`（`unsafe impl`） | 一切皆引用，多线程共享但无保护 |
| 闭包发送 | `@Sendable` 标注 + 捕获变量检查 | `move` 闭包 + `Send` bound | `lambda` 可跨线程，但需手动同步 |
| 检查时机 | 编译期（Swift 6 严格模式） | 编译期（强制，无例外） | 运行期（`threading` 模块自行处理） |
| 数据竞争保证 | 编译拦截大部分场景 | 编译期零数据竞争保证 | 无保证（GIL 仅保护 CPython 字节码执行） |

**核心差异：** Rust 的 Send 是所有并发安全的基石，编译器 100% 保证数据竞争不会发生。Swift 的 Sendable 是一个渐进式改进——Swift 5.5/5.10 下可以警告但不报错，Swift 6 严格模式才全面启用。Python 完全没有并发安全机制，需要手动使用锁。

如果你在 Swift 中习惯了 `Sendable` 的安全感，切换到 Python 多线程时需要格外小心。Rust 开发者会觉得 Swift 的 Sendable 很熟悉，但 Rust 的保证更彻底。

---

## 🏋️ 动手练习 Level 1

**目标：** 将一个 struct 变成真正的 Sendable 类型

下面这段代码定义了一个 `UserProfile` struct，但包含了一个非 Sendable 的属性。修复它使整个 struct 成为 Sendable：

```swift
// ❌ 问题：closure 不是 Sendable 类型
struct UserProfile {
    let name: String
    let age: Int
    var onLoad: () -> Void  // 函数类型不是 Sendable
}
```

**提示：** Sendable 类型的所有存储属性必须都是 Sendable。想想哪些属性不是 Sendable 的，如何修改？

<details>
<summary>查看参考答案</summary>

```swift
// ✅ 方案：移除非 Sendable 的属性
struct UserProfile: Sendable {
    let name: String
    let age: Int
    // onLoad 函数类型不是 Sendable，不能作为存储属性
}

// 如果确实需要回调行为，可以用 Actor 或 enum 封装：
actor UserProfileHandler {
    private let profile: UserProfile

    init(profile: UserProfile) {
        self.profile = profile
    }

    func onProfileLoaded() {
        print("\(profile.name) loaded")
    }
}
```

核心原则：struct 中不能有函数类型的存储属性（包括闭包），因为它们不是 Sendable。

</details>

---

## 🏋️ 动手练习 Level 2

**目标：** 修复 @Sendable 闭包捕获错误

以下代码尝试在 Task 中捕获一个 class 实例，但 class 不是 Sendable：

```swift
class AppConfig {
    var serverURL: String = "https://api.example.com"
}

func fetchConfig() async {
    let config = AppConfig()

    Task {
        // ⚠️ 编译错误：config 是非 Sendable 的 class
        let url = config.serverURL
        print("Fetching from: \(url)")
    }
}
```

修复这段代码，让 Task 能安全地访问 `serverURL` 的值。

<details>
<summary>查看参考答案</summary>

```swift
// 方案 A：在 Task 外部提取值（最简单）
func fetchConfig() async {
    let config = AppConfig()
    let url = config.serverURL  // String 是 Sendable，可以安全捕获

    Task {
        print("Fetching from: \(url)")  // ✅ 只捕获 String
    }
}

// 方案 B：将 class 改为 struct（如果不需要引用语义）
struct AppConfig {
    let serverURL: String
}

func fetchConfig() async {
    let config = AppConfig(serverURL: "https://api.example.com")

    Task {
        print("Fetching from: \(config.serverURL)")  // ✅ struct 是 Sendable
    }
}
```

关键区别：方案 A 只提取了需要的值（`String`），方案 B 把整个类型变成了 Sendable。

</details>

---

## 🏋️ 动手练习 Level 3

**目标：** 用 Sendable + Actor 构建一个线程安全的配置管理器

实现一个 `ThreadSafeConfigManager`：
1. 用 `actor` 包裹可变配置状态
2. 配置数据本身用 `Sendable` struct 表示
3. 支持 `get()` 和 `set()` 方法
4. 支持多个 Task 并发读写

<details>
<summary>查看参考答案</summary>

```swift
// Sendable 配置数据（值类型）
struct ConfigEntry: Sendable {
    let key: String
    let value: String
}

// Actor 保护状态
actor ThreadSafeConfigManager {
    private var store: [String: String] = [:]

    func set(_ entry: ConfigEntry) {
        store[entry.key] = entry.value
    }

    func get(key: String) -> String? {
        return store[key]
    }

    func getAll() -> [ConfigEntry] {
        return store.map { ConfigEntry(key: $0.key, value: $1.value) }
    }
}

// 使用示例
func runConfigSample() async {
    let manager = ThreadSafeConfigManager()

    // 并发写入和读取
    async let setDb = manager.set(ConfigEntry(key: "database", value: "sqlite"))
    async let setCache = manager.set(ConfigEntry(key: "cache", value: "redis"))

    await setDb
    await setCache

    let db = await manager.get(key: "database")
    let all = await manager.getAll()

    print("Database config: \(db ?? "not found")")
    print("All entries: \(all.count)")
}
```

这里 `ConfigEntry` struct 是 Sendable 的，可以自由进出 Actor 边界。Actor 内部的可变 `store` 字典被隔离保护，外部只能通过 `await` 方法安全访问。

</details>

---

## 🔧 故障排查 FAQ

**Q1: 我的 struct 明明没有可变属性，为什么编译器还说它不是 Sendable？**

检查 struct 中是否包含非 Sendable 类型的属性。常见的非 Sendable 类型包括：闭包 `() -> Void`、class 实例、`UnsafePointer`、`DispatchQueue`。即使属性是 `let` 不可变，只要类型本身不是 Sendable，整个 struct 就不是 Sendable。

**Q2: @Sendable 和不加 @Sendable 的 Task 闭包有什么区别？**

`Task` 初始化器本身要求一个 `@Sendable` 闭包，所以即使你不显式写 `@Sendable`，闭包也会被编译器当作 Sendable 闭包来处理。显式标注主要用于自定义函数接受闭包参数的场景：

```swift
func runAsync(_ operation: @Sendable () async -> Int) async {
    let result = await operation()
    print(result)
}
```

**Q3: Swift 5.x 和 Swift 6 下的 Sendable 行为有什么不同？**

Swift 5.10 及之前：`Sendable` 检查默认是警告（warning），可以忽略，编译仍然通过。Swift 6 默认开启严格并发检查：`Sendable` 违反变成编译错误（error），必须修复。如果你的项目在 Swift 6 下从警告突然变错误，这就是原因。

**Q4: 我可以让 class 自动成为 Sendable 吗？**

`final class` 且所有存储属性都是 `let` 不可变 + Sendable 类型时，你可以显式标注 `: Sendable`，编译器会验证。但 class 永远不会"自动"成为 Sendable（不像 struct/enum）。这是因为 class 本质是可变的引用类型，子类可以添加可变状态。如果需要引用语义且 Sendable，建议改用 `actor`。

**Q5: @unchecked Sendable 到底什么时候用？**

当你确信一个类型是线程安全的，但编译器无法推断时。典型场景：

- 内部使用了 `NSLock`/`os_unfair_lock` 等同步原语
- 使用了 C 库的线程安全 API
- 第三方库类型的适配

但 **绝大多数情况不需要 `@unchecked Sendable`**。优先用 struct、Actor 来解决。`@unchecked` 是最后的手段。

**Q6: 为什么 Task.sleep 需要 try await？**

`Task.sleep(for:)` 是 `async throws` 函数，可能因 Task 被取消而抛出 `CancellationError`。在实际代码中通常用 `try await` 处理，或者用 `try? await` 忽略取消错误：

```swift
try? await Task.sleep(for: .milliseconds(10))  // 取消时不报错
```

---

## 📌 小结

- `Sendable` 是 Swift 的并发安全标记协议：值类型（struct、enum）在所有属性 Sendable 时自动遵循，class 需要显式处理
- `@Sendable` 闭包标注确保闭包捕获的所有外部变量都是 Sendable 的，防止跨线程数据竞争
- 数据竞争问题的根本解决模式：值类型优先 → Actor 包裹可变状态 → `@unchecked Sendable` 作为最后手段
- Swift 6 的严格并发检查将所有 Sendable 违规从警告升级为错误，强制开发者在编译期解决并发安全问题

---

## 📖 术语表

| 术语 | 英文 | 说明 |
|------|------|------|
| 可发送协议 | Sendable | 标记类型可以安全跨并发边界传递的协议 |
| 隐式可发送 | Implicit Sendability | struct/enum/tuple 自动被编译器视为 Sendable 的行为 |
| 闭包捕获 | Closure Capture | 闭包引用外部作用域变量的机制 |
| 严格并发检查 | Strict Concurrency Checking | Swift 6 编译选项，将并发安全违规升级为编译错误 |
| 未检查发送 | @unchecked Sendable | 手动声明 Sendable 但跳过编译器验证的方式 |
| 数据竞争 | Data Race | 多个并发任务同时读写同一可变状态导致的未定义行为 |
| Actor 隔离 | Actor Isolation | Actor 确保其内部状态只能被串行访问的机制 |
| 值语义 | Value Semantics | 每次传递都复制数据副本，不存在共享可变状态 |

---

## ✅ 知识检查

**题目 1:** 下面哪个类型是 Sendable 的？为什么？

```swift
// A
struct Point {
    let x: Int
    let y: Int
}

// B
class Counter {
    var value: Int = 0
}

// C
enum Status {
    case idle
    case running
    case completed
}
```

<details>
<summary>查看答案和解析</summary>

**A 和 C 是 Sendable，B 不是。**

- A（`Point` struct）：所有属性是 `let` 且类型为 `Int`（Sendable），自动 Sendable
- B（`Counter` class）：class 有可变 `var` 属性，不是 Sendable。引用语义 + 可变状态 = 数据竞争风险
- C（`Status` enum）：无关联值的 enum，自动生成 Sendable

</details>

**题目 2:** 下面代码会编译通过吗？如果不通过，会报什么错误？

```swift
func processUser(user: some Sendable) {
    print("Processing user")
}

class User {
    var name: String = ""
}

let u = User()
processUser(user: u)
```

<details>
<summary>查看答案和解析</summary>

**不会编译通过。**

错误信息类似：`Sending 'u' risks causing data races; 'User' is not Sendable`

`User` class 有可变属性 `var name`，不遵循 `Sendable`。`processUser` 要求参数必须是 `some Sendable`，类型不匹配。修复方式：将 `User` 改为 struct 或确保只传不可变数据。

</details>

**题目 3:** 以下 `@unchecked Sendable` 使用是否正确？如果不正确，有什么问题？

```swift
class SharedState: @unchecked Sendable {
    var items: [String] = []

    func add(_ item: String) {
        items.append(item)
    }

    func getAll() -> [String] {
        return items
    }
}

let state = SharedState()

Task {
    state.add("item1")
}
Task {
    state.add("item2")
}
```

<details>
<summary>查看答案和解析</summary>

**编译能通过，但运行时有数据竞争问题。**

`@unchecked Sendable` 告诉编译器"我保证这个类型线程安全"，但 `SharedState` 的 `items` 数组没有任何同步保护（锁、Actor 等）。两个 Task 同时调用 `add()` 会导致并发写入 `[String]`，这是经典的数据竞争。

`@unchecked Sendable` 只是让编译器闭嘴，不自动提供线程安全。正确的做法是把 `SharedState` 改为 `actor`，或在内部使用锁保护。

</details>

---

## ➡️ 继续学习

完成本章后，你已经掌握了 Swift 并发安全的核心概念。下一步：

- **[属性包装器](./property-wrappers.md)**：学习 `@Published`、`@AppStorage`、自定义 `@propertyWrapper`，理解属性如何在 SwiftUI 和并发场景中发挥更大作用
- **[高级进阶总览](./advance-overview.md)**：回顾整个高级部分的学习路径，规划下一步探索方向

> **扩展阅读**: 想了解 Swift 并发模型的完整设计哲学？参考 Apple 官方文档 **[Meet Swift Concurrency](https://developer.apple.com/videos/play/wwdc2021/10132/)** WWDC 2021 演讲，以及 Swift Evolution 提案 [SE-0302](https://github.com/apple/swift-evolution/blob/main/proposals/0302-concurrent-value-and-concurrent-closures.md)（Sendable 协议的原始提案）。
