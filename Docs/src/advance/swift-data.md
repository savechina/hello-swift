# SwiftData 持久化

## 开篇故事

想象你运营一家图书馆。读者不断借书还书，你需要记录每本书的流向。如果没有账本，几天后你根本不知道哪些书还在架子上，哪些被借走了。

SwiftData 就像一位非常勤快的图书管理员。你只需要告诉他每本书叫什么名字、哪个类别，他会在背后自动建好索引、管好账本。你只需要用简单的 Swift 类描述数据，SwiftData 就帮你搞定存储、查询、排序所有这些繁琐的事。

你不需要写 SQL，不需要管表结构。你定义一个 `class`，加上一个 `@Model` 标签，剩下的事 SwiftData 全包了。

---

## 本章适合谁

你正在或用 Swift 开发需要本地持久化数据的应用。你不想手写 SQL，也不想用 CoreData 繁琐的 `.xcdatamodel` 文件配置，希望用纯代码的方式管理本地数据库。

如果你熟悉 `UserDefaults` 但发现它存不了复杂对象，或者你已经用 FileManager 存 JSON 文件但遇到了性能瓶颈，SwiftData 就是为你准备的。

---

## 你会学到什么

完成本章后，你可以：

1. 使用 `@Model` 宏 (Macro) 声明可持久化的数据类
2. 配置 `ModelContainer` 管理 SQLite 存储路径和选项
3. 使用 `ModelContext` 执行增删改查 (CRUD) 操作
4. 用 `FetchDescriptor` 和 `SortDescriptor` 排序并取回数据
5. 用 `#Predicate` 宏写出类型安全的过滤条件
6. 用 `@ModelActor` 实现并发安全的后台数据导入
7. 用 `@Relationship` 管理一对多、多对多关联和级联删除

---

## 前置要求

- 掌握 Swift 基础语法，尤其是类 (class) 和属性 (property)
- 理解 `async`/`await` 异步编程模型
- 理解 `do`/`try`/`catch` 错误处理模式
- **macOS 14.0+ (Sonoma) 是硬性要求**。SwiftData 是 Apple 在 iOS 17 / macOS 14 引入的 API，低版本系统不可用

> **⚠️ 重要提醒**: 本章所有代码需要 macOS 14.0 或更高版本。在 Package.swift 中需要设置 `platforms: [.macOS(.v14)]`，在代码中需要加 `@available(macOS 14, *)` 标注。

---

## 第一个例子

打开代码文件 `AdvanceSample/Sources/AdvanceSample/SwiftDataSample.swift` 第 12-26 行，这是 SwiftData 最基础的模型定义：

```swift
@available(macOS 14, *)
@Model
final class ServerLog {
    var id: UUID
    var timestamp: Date
    var endpoint: String
    var responseCode: Int

    init(endpoint: String, responseCode: Int) {
        self.id = UUID()
        self.timestamp = Date()
        self.endpoint = endpoint
        self.responseCode = responseCode
    }
}
```

对比普通 Swift 类，你只做了一件事：加上 `@Model`。SwiftData 编译器插件会自动把这个类转换成可持久化的数据模型。每个属性都会自动映射到 SQLite 底层的列。

接下来创建容器和上下文，把数据存进去：

```swift
let config = ModelConfiguration(
    url: databaseURL,
    cloudKitDatabase: .none
)
let container = try ModelContainer(
    for: ServerLog.self,
    configurations: config
)
let context = ModelContext(container)

let newLog = ServerLog(endpoint: "/index", code: 200)
context.insert(newLog)
try await context.save()
```

运行结果：

```
🚀 正在初始化临时数据库：/var/folders/.../server_logs_XXXX.sqlite
log request XXXX-XXXX-XXXX
fetch count: 3
log: XXXX, 2025-12-20 10:30:00, /index, 200
log: XXXX, 2025-12-20 10:30:01, /status, 404
log: XXXX, 2025-12-20 10:30:02, /home/list, 200
```

---

## 原理解析

### 1. @Model 宏与属性映射

`@Model` 是 Swift 5.9 引入的宏 (Macro)。编译器会自动为标记的 `final class` 生成底层持久化支持代码。

**支持什么属性类型？**

```swift
@Model
final class Item {
    var id: UUID           // ✅ 支持
    var name: String       // ✅ 支持
    var count: Int         // ✅ 支持
    var price: Double      // ✅ 支持
    var isActive: Bool     // ✅ 支持
    var createdAt: Date    // ✅ 支持
    var data: Data         // ✅ 支持 (BLOB)
    var tags: [String]     // ✅ 支持 (需要 Transformable)
    var status: ItemStatus // ✅ 支持 (RawRepresentable enum)
}
```

**不支持的类型**会报编译错误：

```swift
@Model
final class BadModel {
    var closure: () -> Void     // ❌ 编译错误：不支持函数类型
    var anyValue: Any           // ❌ 编译错误：不支持 Any
    var url: URL                // ❌ 编译错误：需要自行转换
}
```

每个非可选属性都必须是可持久化的。如果属性是可选类型 `String?`，对应数据库列允许为 NULL。

### 2. ModelContainer 配置

`ModelContainer` 是 SwiftData 的核心，它负责：
- 管理底层 SQLite 文件连接（或内存数据库）
- 加载数据模型 schema
- 自动创建表结构

**本地文件存储：**

```swift
let dbURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("app.sqlite")

let config = ModelConfiguration(
    url: dbURL,                        // 文件路径
    cloudKitDatabase: .none,           // 不使用 iCloud
    allowsSaveForward: true            // 允许 schema 向前兼容
)

let container = try ModelContainer(
    for: ServerLog.self,               // 注册模型类型
    configurations: config
)
```

**内存数据库（测试用）：**

```swift
let config = ModelConfiguration(
    isStoredInMemoryOnly: true         // 不落盘，退出即丢失
)
let container = try ModelContainer(
    for: ServerLog.self,
    configurations: config
)
```

### 3. ModelContext CRUD 操作

`ModelContext` 是操作数据库的"工作区"，类似 ORM 的 Session。它提供了完整的增删改查：

**创建 (Insert)：**

```swift
let newLog = ServerLog(endpoint: "/api/data", responseCode: 201)
context.insert(newLog)
try context.save()  // 同步保存
// 或
try await context.save()  // 异步保存
```

**读取 (Fetch)：**

```swift
let descriptor = FetchDescriptor<ServerLog>()
let allLogs = try context.fetch(descriptor)
```

**更新 (Update)：**

SwiftData 直接修改对象的属性，然后在 context 中 save 即可：

```swift
if let log = allLogs.first {
    log.responseCode = 500          // 直接修改
    try context.save()               // 自动追踪变更
}
```

**删除 (Delete)：**

```swift
// 删除单个对象
context.delete(log)
try context.save()

// 批量删除
try context.delete(
    model: ServerLog.self,
    where: #Predicate { $0.responseCode >= 500 }
)
```

### 4. FetchDescriptor 与 SortDescriptor

`FetchDescriptor` 是数据查询的描述符，相当于 SQL 的 WHERE + ORDER BY + LIMIT：

```swift
// 按时间倒序，最多取 10 条
let sort = SortDescriptor(\.timestamp, order: .reverse)
let descriptor = FetchDescriptor<ServerLog>(
    sortBy: [sort],
    fetchLimit: 10
)

// 过滤：只查状态码为 200 的请求
descriptor.predicate = #Predicate<ServerLog> { $0.responseCode == 200 }

let recentOK = try context.fetch(descriptor)
```

**FetchDescriptor 完整参数：**

| 参数 | 作用 | 说明 |
|------|------|------|
| `predicate` | 过滤条件 | `#Predicate` 宏生成 |
| `sortBy` | 排序规则 | `SortDescriptor` 数组，按顺序生效 |
| `fetchLimit` | 最大返回数 | 类似 SQL 的 LIMIT |
| `fetchOffset` | 偏移量 | 分页使用，类似 SQL 的 OFFSET |

### 5. #Predicate 宏过滤

`#Predicate` 是类型安全的过滤表达式，编译器会检查属性名和类型是否匹配。这是它相比传统 `NSPredicate` 的最大优势：写错了在编译期就会报错。

```swift
// 等值查询
let p1 = #Predicate<ServerLog> { $0.responseCode == 200 }

// 范围查询
let p2 = #Predicate<ServerLog> {
    $0.responseCode >= 400 && $0.responseCode < 500
}

// 字符串匹配
let p3 = #Predicate<ServerLog> {
    $0.endpoint.contains("api")
}

// 日期范围
let lastWeek = Date().addingTimeInterval(-7 * 24 * 3600)
let p4 = #Predicate<ServerLog> { $0.timestamp >= lastWeek }

// 组合条件
let p5 = #Predicate<ServerLog> {
    $0.responseCode == 200 && $0.timestamp >= lastWeek
}
```

### 6. @ModelActor 并发安全

SwiftData 的对象不是线程安全的。跨Actor传递 `@Model` 对象会触发 `Sendable` 检查失败。解决方式之一是使用 `@ModelActor`：

```swift
@available(macOS 14, *)
@ModelActor
actor MetricsDataService {
    // 自动提供 modelContext 和 modelContainer

    func recordMetric(name: String, time: Double) throws {
        let metric = ServiceMetrics(serviceName: name, responseTime: time)
        modelContext.insert(metric)
        try modelContext.save()
    }

    func getAverageResponseTime(for name: String) throws -> Double {
        let predicate = #Predicate<ServiceMetrics> {
            $0.serviceName == name
        }
        let descriptor = FetchDescriptor<ServiceMetrics>(
            predicate: predicate
        )
        let results = try modelContext.fetch(descriptor)
        guard !results.isEmpty else { return 0.0 }
        return results.reduce(0.0) { $0 + $1.responseTime }
            / Double(results.count)
    }
}
```

`@ModelActor` 的作用类似于自动生成了一个隔离Actor，它保证：
- 所有数据库操作都在同一个 serial queue 上执行
- 不会发生并发写入冲突
- 从外部通过 `await` 调用的方式访问，天然线程安全

### 7. @Relationship 级联删除

一对多关系使用 `@Relationship` 标记，支持删除策略配置：

```swift
@Model
final class Author {
    var name: String
    @Relationship(deleteRule: .cascade)
    var books: [Book]

    init(name: String) {
        self.name = name
        self.books = []
    }
}

@Model
final class Book {
    var title: String
    var author: Author?
    init(title: String) { self.title = title }
}
```

| `deleteRule` | 效果 |
|---|---|
| `.nullify` | 被关联对象的引用设为 nil |
| `.cascade` | 级联删除所有被关联对象 |
| `.noAction` | 不采取任何操作（可能导致悬空引用） |
| `.deny` | 如果被关联对象存在，则阻止删除 |

### 8. Lightweight Migration (轻量迁移)

开发过程中你经常会给模型加字段。SwiftData 支持自动的轻量迁移，不需要手动写迁移逻辑：

**场景：** 给已有 `ServerLog` 加上 `duration: TimeInterval` 字段。

```swift
// 旧 schema
@Model final class ServerLog {
    var endpoint: String
    var responseCode: Int
}

// 新 schema：添加字段
@Model final class ServerLog {
    var endpoint: String
    var responseCode: Int
    var duration: Double = 0.0   // 新增字段带默认值
}
```

只需要：
1. 新增属性提供默认值
2. `ModelConfiguration` 设置 `allowsSaveForward: true`

SwiftData 会自动迁移已有数据。如果旧行缺少新列，会用默认值填充。

> **限制：** 字段改名、字段类型变更、删除字段等复杂操作需要手动编写 `MappingModel`。轻量迁移只支持"加可选字段或带默认值字段"这类简单变更。

---

## 常见错误

> 以下错误来源于大量开发者在 SwiftData 实际项目踩坑后的总结，按出现频率排列。

### 错误 1: 忘记在 ModelContainer 中注册模型

**症状：** 编译通过，运行后 `fetch` 返回空数组，不报任何错误。

```swift
// ❌ 只注册了 ServerLog，但代码中查询了 ServiceMetrics
let container = try ModelContainer(for: ServerLog.self)
let descriptor = FetchDescriptor<ServiceMetrics>() // 编译不报错！
let results = try context.fetch(descriptor)        // 返回 []
```

**修复：** 在 `ModelContainer` 的 `for:` 参数列出所有模型：

```swift
// ✅
let container = try ModelContainer(
    for: ServerLog.self, ServiceMetrics.self
)
```

### 错误 2: 在不同 Context 之间传递模型对象

**症状：** 运行崩溃 (crash)，报错 `Fault: Object belongs to a different context`。

```swift
// ❌ obj 属于 contextA，却在 contextB 里修改
let obj = try contextA.fetch(descriptor).first!
contextB.insert(obj)        // 直接崩溃
```

**修复：** 用唯一标识（如 `UUID`）重新获取对象：

```swift
// ✅ 传 ID，在目标 context 中重新查询
let objID = obj.id
let freshObj = try contextB.fetch(
    FetchDescriptor(predicate: #Predicate { $0.id == objID })
).first!
```

### 错误 3: #Predicate 中使用不支持的类型

**症状：** 运行时 `EXC_BAD_ACCESS` 崩溃，不报清晰的错误信息。

```swift
// ❌ 自定义 struct 不能直接在 #Predicate 中使用
struct Status { var code: Int }
let p = #Predicate<ServerLog> { $0.status == Status(code: 200) }
```

**修复：** 只用 SwiftData 原生支持的类型（Int, String, Date 等）：

```swift
// ✅
let p = #Predicate<ServerLog> { $0.responseCode == 200 }
```

### 错误 4: 跨 Actor 传递 @Model 对象

**症状：** 编译报错 `Instance of non-Sendable type 'ServerLog' in main-sendable closure`。

```swift
// ❌ @Model 对象不是 Sendable，不能跨 Actor 边界传递
func process(log: ServerLog) async {  // 编译错误
    actor.insert(log)
}
```

**修复：** 改用 `@ModelActor` 或在不同 Actor 间只传基本类型（ID）：

```swift
// ✅ 用 @ModelActor 内部操作
await metricsService.recordMetric(name: "API", time: 100)
```

### 错误 5: @Model 类缺少显式初始化器

**症状：** 编译报错 `'required' initializer in'@Model' class`。

```swift
// ❌ 没有写 init，编译器要求你提供
@Model
final class Config {
    var key: String
    var value: Int
    // 缺少 init！
}
```

**修复：** 提供至少一个 `init` 方法初始化所有非可选属性：

```swift
// ✅
@Model
final class Config {
    var key: String
    var value: Int

    init(key: String, value: Int) {
        self.key = key
        self.value = value
    }
}
```

---

## Swift vs Rust/Python 对比

| 维度 | Swift (SwiftData) | Rust (SQLx / Diesel) | Python (SQLAlchemy) |
|------|-------------------|----------------------|---------------------|
| 声明方式 | `@Model` 宏 + final class | 结构体 + `#[derive(Queryable)]` 或 `sqlx::query!` | `declarative_base()` 子类 |
| schema 管理 | 自动建表，轻量迁移 | 手动 `migrations/` SQL 文件或 `diesel migration generate` | `alembic` 迁移工具 |
| 查询方式 | `FetchDescriptor` + `#Predicate` | 类型安全 builder API 或原生 SQL | Query API / ORM 方法链 |
| 类型安全 | 编译期强检查 | 编译期强检查 (SQLx compile-time) | 运行期检查 |
| 并发安全 | `@ModelActor` 隔离 | Diesel pool / SQLx 连接池 | Session 线程本地 |
| 后端存储 | SQLite（默认） | SQLite / PostgreSQL / MySQL | 几乎所有数据库 |
| 学习曲线 | 低（纯 Swift 代码） | 高（需要理解连接池、生命周期） | 中（API 丰富但概念多） |

**核心差异：** SwiftData 是 Apple 官方方案，专为 Apple 平台本地持久化设计，牺牲了跨库灵活性换取了极简 API。Rust 的 SQLx 在编译期就检查 SQL 语法正确性，适合后端服务。Python 的 SQLAlchemy 是目前最成熟的 ORM 之一，生态最广。

如果你开发的是 macOS/iOS 本地应用，SwiftData 是首选。如果你在写后端服务，Rust + SQLx 或 Python + SQLAlchemy 更合适。

---

## 动手练习 Level 1

**目标：** 定义一个 `@Model` 并插入一条数据。

定义一个 `Student` 模型，包含 `name: String`、`age: Int`、`enrolled: Date`。用 `ModelContainer` 和 `ModelContext` 将三个学生数据存入数据库。

```swift
// 在 AdvanceSample/Sources/AdvanceSample/SwiftDataSample.swift 中实现

@available(macOS 14, *)
@Model
final class Student {
    var name: String
    var age: Int
    var enrolled: Date

    init(name: String, age: Int) {
        self.name = name
        self.age = age
        self.enrolled = Date()
    }
}
```

<details>
<summary>查看参考答案</summary>

```swift
@available(macOS 14, *)
func studentSample() async {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Student.self,
        configurations: config
    )
    let context = ModelContext(container)

    let s1 = Student(name: "Alice", age: 20)
    let s2 = Student(name: "Bob", age: 22)
    let s3 = Student(name: "Charlie", age: 21)

    context.insert(s1)
    context.insert(s2)
    context.insert(s3)
    try! context.save()

    let all = try! context.fetch(FetchDescriptor<Student>())
    print("Student count: \(all.count)") // 3
}
```

</details>

---

## 动手练习 Level 2

**目标：** 用 `FetchDescriptor` + `#Predicate` 过滤数据。

在上一个练习的基础上，只查询年龄大于等于 21 岁的学生，按姓名排序输出。

<details>
<summary>查看参考答案</summary>

```swift
let predicate = #Predicate<Student> { $0.age >= 21 }
let sort = SortDescriptor(\.name, order: .forward)
let descriptor = FetchDescriptor<Student>(
    predicate: predicate,
    sortBy: [sort]
)
let filtered = try! context.fetch(descriptor)
for s in filtered {
    print("\(s.name), \(s.age)") // Alice, Bob, Charlie (sorted)
}
```

</details>

---

## 动手练习 Level 3

**目标：** 用 `@ModelActor` 在后台线程安全地批量导入数据。

参考 `SwiftDataSample.swift` 中 `MetricsDataService` 的实现，创建一个 `StudentImportService`：
1. 定义 `@ModelActor actor StudentImportService`
2. 提供 `importStudents(_ names: [String]) async` 方法
3. 提供 `getStudentCount() async -> Int` 方法
4. 在外部通过 `Task` 并发调用多次 `importStudents`，验证不会崩溃

<details>
<summary>查看参考答案</summary>

```swift
@available(macOS 14, *)
@ModelActor
actor StudentImportService {
    func importStudents(_ names: [String]) {
        for name in names {
            let student = Student(name: name, age: Int.random(in: 18...25))
            modelContext.insert(student)
        }
        try! modelContext.save()
    }

    func getStudentCount() -> Int {
        let result = try! modelContext.fetch(FetchDescriptor<Student>())
        return result.count
    }
}

// 使用
@available(macOS 14, *)
func runImportSample() async {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Student.self,
        configurations: config
    )
    let service = StudentImportService(modelContainer: container)

    // 并发导入多批数据（@ModelActor 自动处理并发安全）
    await service.importStudents(["Alice", "Bob"])
    await service.importStudents(["Charlie", "Diana", "Eve"])

    let count = await service.getStudentCount()
    print("Total students: \(count)") // 5
}
```

</details>

---

## 故障排查 FAQ

**Q1: `fetch` 返回空数组，但我明明插入了数据？**

检查 `ModelContainer` 是否注册了你要查询的模型类型。`ModelContainer(for: SomeModel.self)` 中不声明的类型即使编译通过也无法查询。另外检查 `isStoredInMemoryOnly: true` 的容器在应用重启后数据会丢失。

**Q2: 修改了模型属性后，应用启动崩溃 `NSMigrationError`？**

SwiftData 的 schema 发生变化时，如果旧数据的 SQLite 文件与新模型不匹配就会崩溃。临时开发时可以删除旧的 `.sqlite` 文件重建，或者配置 `allowsSaveForward: true` 启用自动迁移。

**Q3: 在 `#Predicate` 中调用自定义方法报编译错误？**

`#Predicate` 宏只支持有限的操作集合。不能使用自定义函数、闭包、或者非标准库类型。如果查询逻辑太复杂，可以先用 `FetchDescriptor` 拉回数据，再用 Swift 代码在内存中过滤。

**Q4: 并发写入报 `cannot be used in a Sendable context` 错误？**

`@Model` 对象不是 `Sendable` 的，不能跨 `actor` 传递。解决方案：在同一个 `@ModelActor` 内操作数据，或者只传递基本类型（如 `UUID` ID），在目标 actor 里重新 fetch 对象。

**Q5: `ModelContainer` 初始化失败，报 `SQLite error`？**

检查数据库文件路径是否可写。如果用临时目录，确保路径已经创建。另外，如果用 Xcode 运行，检查沙盒权限。内存模式 (`isStoredInMemoryOnly: true`) 可以避免文件权限问题。

---

## 小结

- `@Model` 宏将普通的 `final class` 转换为可持久化数据模型，编译器自动处理底层存储细节
- `ModelContainer` 管理 SQLite 文件连接和模型 schema，可通过 `ModelConfiguration` 选择文件存储或内存存储
- `ModelContext` 是 CRUD 操作的工作单元，直接修改对象属性后调用 `save()` 即可自动追踪变更
- `FetchDescriptor` + `#Predicate` 提供类型安全的查询接口，支持过滤、排序、分页
- `@ModelActor` 将数据库操作封装在 Actor 隔离域内，天然解决并发安全问题

---

## 术语表

| 术语 | 英文 | 说明 |
|------|------|------|
| 数据模型 | @Model | 用宏标记的类，声明哪些数据需要持久化 |
| 数据容器 | ModelContainer | 管理底层存储和模型 schema 的核心对象 |
| 数据上下文 | ModelContext | 执行插入、查询、修改、删除等操作的工作单元 |
| 查询描述符 | FetchDescriptor | 声明要查询什么数据，包括过滤和排序条件 |
| 谓词 | #Predicate | 类型安全的过滤表达式宏，用于筛选数据 |
| 模型Actor | @ModelActor | 提供并发安全数据库操作的 Actor 抽象 |
| 关系 | @Relationship | 声明模型之间一对多或多对多关联的标记 |
| 轻量迁移 | Lightweight Migration | 自动处理简单 schema 变更（加字段）的机制 |
| 排序描述符 | SortDescriptor | 声明查询结果的排序方式 |

---

## 知识检查

**题目 1:** 下面哪个声明不会编译通过？为什么？

```swift
// A
@Model final class User {
    var name: String
    init(name: String) { self.name = name }
}

// B
@Model final class Item {
    var handler: () -> Void
}

// C
@Model final class Config {
    var key: String?
}
```

<details>
<summary>查看答案和解析</summary>

**答案是 B。** 闭包类型 `() -> Void` 不是 SwiftData 支持的可持久化类型。`@Model` 只支持基本类型（Int, String, Double, Bool, Date, Data, UUID 等）以及遵循 `RawRepresentable` 的枚举。A 和 C 都会正常编译，C 中可选类型是允许的。

</details>

**题目 2:** `ModelActor` 的 `modelContext` 和手动创建的 `ModelContext` 有什么区别，为什么推荐在 Actor 中使用 `@ModelActor`？

<details>
<summary>查看答案和解析</summary>

`@ModelActor` 自动生成的 `modelContext` 绑定在 Actor 的隔离域内，所有对这个 context 的操作都会经过 Actor 的 serial queue 调度，不会发生并发冲突。手动创建的 `ModelContext` 没有这种隔离保证，如果从多个线程同时操作同一个 context 会导致数据损坏。`@ModelActor` 相当于帮你自动处理了线程安全。

</details>

**题目 3:** 你给 `ServerLog` 模型增加了一个 `duration: Double` 字段后，已安装的应用启动时崩溃。列出至少两种修复办法。

<details>
<summary>查看答案和解析</summary>

两种修复办法：

1. **开发阶段**：删除旧的 SQLite 文件重建。用 `FileManager.default.removeItem(at: oldDBURL)` 或者让用户卸载重装。适用于还没有用户数据的开发/测试阶段。
2. **发布阶段**：启用轻量迁移。设置 `ModelConfiguration(allowsSaveForward: true)`，并为新增的 `duration` 字段提供默认值 `var duration: Double = 0.0`。SwiftData 会自动为新列填充默认值，已有的行不会丢失。

</details>

---

## 继续学习

完成本章后，你已经掌握了用纯 Swift 代码管理本地持久化数据的能力。下一步继续阅读 **[环境配置](./environment.md)** 章节，学习如何管理 `.env` 环境变量和运行时配置。

> **扩展阅读**: 想深入了解 SwiftData 和 SwiftUI 的结合？SwiftData 提供的 `@Query` 属性包装器可以在视图数据变化时自动刷新 UI，这是 SwiftUI + SwiftData 组合的核心特性。
