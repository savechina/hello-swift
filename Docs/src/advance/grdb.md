# GRDB SQLite 数据库

## 开篇故事

想象你经营一家小型游戏竞技场。每天都有玩家来注册、比赛、获得积分。刚开始只有几个人，你拿一张纸就能记住所有人的名字和分数。但一个月后，玩家超过几百人，有人要求查自己的历史成绩，有人想看看排行榜前三名是谁——那张纸已经乱成一团。

GRDB 就像一位专业的赛场记分员。你不需要自己画表格、写 SQL、管理文件指针。你只需要告诉 GRDB："我有玩家，他们有名字和分数"，GRDB 就会帮你建好 SQLite 数据库、创建表结构、处理插入和查询。更棒的是，它用纯 Swift 的协议 (Protocol) 来定义数据模型，写出来的代码和写普通 Swift 结构体一样自然。

你不需要离开 Swift 的世界去学另一门数据库语言。GRDB 让 SQL 数据库操作变成 Swift 类型安全的体验。

---

## 本章适合谁

你正在用 Swift 开发需要本地 SQLite 数据库的跨平台应用（macOS、Linux 均可）。你不想手写原始 SQL 语句，也不想引入 CoreData 那样重量级的框架，希望用轻量、类型安全的方式管理关系型数据。

如果你之前用过 `FileManager` 存 JSON 文件但发现查询效率太低，或者你听说过 SQLite 但不知道如何在 Swift 中优雅地使用它，GRDB 就是为你准备的。

---

## 你会学到什么

完成本章后，你可以：

1. 使用 `FetchableRecord` 和 `PersistableRecord` 协议 (Protocol) 定义可持久化的数据模型
2. 使用 `QueryInterface` 编写类型安全的查询、过滤和排序
3. 执行原始 SQL 语句 (Raw SQL) 进行更新和删除操作
4. 管理 `DatabaseQueue` 的线程安全访问

---

## 前置要求

- 掌握 Swift 基础语法，尤其是结构体 (struct)、协议 (protocol) 和可选类型 (Optional)
- 理解 `do`/`try`/`catch` 错误处理模式
- 理解 `CustomStringConvertible` 协议用于调试输出
- **macOS 12+ 或 Linux (Ubuntu 20.04+)**。GRDB 支持跨平台 SQLite 访问
- Swift 6.0+ 编译器
- 已完成本章之前的基础教程章节

> **提示**: GRDB 是一个第三方 SPM (Swift Package Manager) 依赖。在 `Package.swift` 中添加 `.product(name: "GRDB", package: "GRDB.swift")` 即可使用。本章示例代码位于 `AdvanceSample/Sources/AdvanceSample/GRDBSample.swift`。

---

## 第一个例子

打开代码文件 `AdvanceSample/Sources/AdvanceSample/GRDBSample.swift`，这是 GRDB 最基础的使用方式：

```swift
import GRDB

// 1. 定义数据模型
struct Player: FetchableRecord, PersistableRecord, CustomStringConvertible {
    var id: Int64?
    var name: String
    var score: Int
    
    var description: String {
        "Player(id: \(id ?? -1), name: \(name), score: \(score))"
    }
}

// 2. 创建数据库队列（内存数据库，退出即丢失）
let dbQueue = try DatabaseQueue()

// 3. 在 write 闭包中执行所有数据库操作
try dbQueue.write { db in
    // 创建表
    try db.create(table: "player") { t in
        t.autoIncrementedPrimaryKey("id")
        t.column("name", .text).notNull()
        t.column("score", .integer).notNull().defaults(to: 0)
    }
    
    // 插入记录
    var alice = Player(name: "Alice", score: 100)
    try alice.insert(db)
    print("Inserted: \(alice)")
    
    var bob = Player(name: "Bob", score: 200)
    try bob.insert(db)
    print("Inserted: \(bob)")
    
    // 查询所有记录
    let players = try Player.fetchAll(db)
    print("All players: \(players)")
    
    // 条件查询：分数大于 150 的玩家，按分数降序，取第一个
    let topPlayer = try Player
        .filter(Column("score") > 150)
        .order(Column("score").desc)
        .fetchOne(db)
    print("Top scorer: \(topPlayer?.name ?? "none")")
}
```

运行结果：

```
--- grdbSample start ---
Inserted: Player(id: 1, name: Alice, score: 100)
Inserted: Player(id: 2, name: Bob, score: 200)
All players: [Player(id: 1, name: Alice, score: 100), Player(id: 2, name: Bob, score: 200)]
Top scorer: Bob
--- grdbSample end ---
```

整个流程只需要三步：定义模型 → 创建数据库 → 在 `write` 闭包中操作。GRDB 自动把 `Player` 结构体的属性映射到 SQLite 表的列。

---

## 原理解析

### 1. DatabaseQueue 与线程安全

`DatabaseQueue` 是 GRDB 的核心访问入口。它内部维护一个串行队列 (Serial Queue)，保证所有数据库操作按顺序执行，不会发生并发写入冲突。

```swift
// 内存数据库（测试用，进程退出数据丢失）
let dbQueue = try DatabaseQueue()

// 文件数据库（持久化到磁盘）
let dbURL = URL(fileURLWithPath: "/tmp/game.sqlite")
let fileQueue = try DatabaseQueue(path: dbURL.path)
```

**为什么用 `write` 闭包？** GRDB 的设计理念是"作用域内安全"。`dbQueue.write { db in ... }` 确保闭包内的所有操作共享同一个数据库连接，并且自动管理事务 (Transaction)。闭包结束时自动提交事务，如果抛出异常则自动回滚。

### 2. FetchableRecord 与 PersistableRecord 协议

这两个协议是 GRDB 的 ORM (对象关系映射) 核心：

| 协议 | 作用 | 提供的方法 |
|------|------|-----------|
| `FetchableRecord` | 从数据库行中解码记录 | `fetchAll(db)`, `fetchOne(db, key:)` |
| `PersistableRecord` | 将记录编码并写入数据库 | `insert(db)`, `update(db)`, `delete(db)` |

```swift
struct Player: FetchableRecord, PersistableRecord {
    var id: Int64?          // 可选主键，插入后自动填充
    var name: String        // 映射到 "name" 列
    var score: Int          // 映射到 "score" 列
}
```

GRDB 默认将属性名直接映射为同名的数据库列。`id: Int64?` 是可选的，插入后 GRDB 会自动回填自增主键的值。

### 3. 创建表与 Column 定义

GRDB 提供类型安全的表创建 API：

```swift
try db.create(table: "player") { t in
    t.autoIncrementedPrimaryKey("id")    // 自增主键
    t.column("name", .text).notNull()    // TEXT 类型，不允许 NULL
    t.column("score", .integer).notNull().defaults(to: 0)  // 默认值为 0
}
```

**支持的列类型：**

| Swift 类型 | SQLite 类型 | 示例 |
|-----------|------------|------|
| `String` | `.text` | `t.column("name", .text)` |
| `Int` / `Int64` | `.integer` | `t.column("score", .integer)` |
| `Double` | `.double` | `t.column("price", .double)` |
| `Bool` | `.boolean` | `t.column("active", .boolean)` |
| `Data` | `.blob` | `t.column("image", .blob)` |
| `Date` | `.date` | `t.column("created", .date)` |

**列修饰符 (Modifier)：**

```swift
t.column("email", .text).unique()           // 唯一约束
t.column("age", .integer).check { $0 >= 0 } // 检查约束
t.column("role", .text).defaults(to: "user") // 默认值
t.column("bio", .text).notNull()            // 非空约束
```

### 4. QueryInterface 查询接口

`QueryInterface` 是 GRDB 的类型安全查询构建器，让你用 Swift 代码代替原始 SQL：

**查询全部：**
```swift
let players = try Player.fetchAll(db)
```

**按主键查询：**
```swift
let alice = try Player.fetchOne(db, key: 1)  // id = 1
```

**条件过滤 + 排序：**
```swift
let topPlayer = try Player
    .filter(Column("score") > 150)           // WHERE score > 150
    .order(Column("score").desc)             // ORDER BY score DESC
    .fetchOne(db)                            // LIMIT 1
```

**QueryInterface 常用操作：**

| 方法 | 对应 SQL | 说明 |
|------|---------|------|
| `.filter(...)` | `WHERE` | 过滤条件 |
| `.order(...)` | `ORDER BY` | 排序规则 |
| `.limit(n)` | `LIMIT n` | 限制返回数量 |
| `.select(...)` | `SELECT` | 选择特定列 |
| `.fetchAll(db)` | 执行查询返回数组 | 多条记录 |
| `.fetchOne(db)` | 执行查询返回单条 | 零条或一条 |

### 5. 原始 SQL 执行

对于复杂的更新和删除操作，GRDB 支持直接执行原始 SQL：

```swift
// UPDATE: 使用参数化查询（防 SQL 注入）
try db.execute(
    sql: "UPDATE player SET score = ? WHERE name = ?",
    arguments: [300, "Alice"]
)

// DELETE: 同样使用参数化查询
try db.execute(
    sql: "DELETE FROM player WHERE name = ?",
    arguments: ["Bob"]
)
```

> **安全提醒**: 永远使用 `arguments:` 参数绑定值，不要字符串拼接。参数化查询可以防止 SQL 注入攻击。

### 6. CustomStringConvertible 调试输出

实现 `CustomStringConvertible` 协议让调试时可以直接打印可读的记录信息：

```swift
struct Player: FetchableRecord, PersistableRecord, CustomStringConvertible {
    var id: Int64?
    var name: String
    var score: Int
    
    var description: String {
        "Player(id: \(id ?? -1), name: \(name), score: \(score))"
    }
}

let p = Player(name: "Test", score: 50)
print(p)  // Player(id: -1, name: Test, score: 50)
```

---

## 常见错误

> 以下错误来源于大量开发者在 GRDB 实际项目中的踩坑总结，按出现频率排列。

### 错误 1: 表结构不匹配 (Schema Mismatch)

**症状：** 运行时崩溃 `SQLite error 1: no such column: email`。

```swift
// ❌ 表定义时没有 "email" 列，但模型结构体有
struct Player: FetchableRecord, PersistableRecord {
    var id: Int64?
    var name: String
    var email: String  // 表中没有这个列！
    var score: Int
}
```

**修复：** 确保模型属性与表列一一对应：

```swift
// ✅ 创建表时也要加上 email 列
try db.create(table: "player") { t in
    t.autoIncrementedPrimaryKey("id")
    t.column("name", .text).notNull()
    t.column("email", .text)
    t.column("score", .integer).notNull().defaults(to: 0)
}
```

### 错误 2: DatabaseQueue vs DatabasePool 混淆

**症状：** 高并发场景下出现 `database is locked` 错误。

```swift
// ❌ DatabaseQueue 是串行队列，多个写操作会排队阻塞
let dbQueue = try DatabaseQueue(path: "/tmp/app.sqlite")

// 多线程同时写入 → 后续操作等待前一个完成
Task { try dbQueue.write { db in ... } }
Task { try dbQueue.write { db in ... } }  // 会被阻塞
```

**修复：** 如果需要并发读 + 串行写，使用 `DatabasePool`：

```swift
// ✅ DatabasePool 支持 WAL 模式，允许多个并发读、一个写
let dbPool = try DatabasePool(path: "/tmp/app.sqlite")

// 并发读取（不会互相阻塞）
Task { try dbPool.read { db in ... } }
Task { try dbPool.read { db in ... } }

// 写入仍然串行化（保证数据一致性）
Task { try dbPool.write { db in ... } }
```

| 类型 | 读并发 | 写并发 | 适用场景 |
|------|--------|--------|---------|
| `DatabaseQueue` | 否 | 否 | 单线程、测试、简单 CLI |
| `DatabasePool` | 是 (WAL 模式) | 否 | 服务端、高并发读 |

### 错误 3: 忘记开启 WAL 模式

**症状：** `DatabasePool` 并发读取时仍然出现锁竞争。

GRDB 默认使用传统的 journal 模式。开启 WAL (Write-Ahead Logging) 模式才能发挥 `DatabasePool` 的并发读优势：

```swift
var config = Configuration()
config.readonly = false
// WAL 模式在 DatabasePool 中默认开启，但显式指定更安全
let dbPool = try DatabasePool(path: "/tmp/app.sqlite", configuration: config)
```

### 错误 4: 在 write 闭包外使用 db 连接

**症状：** 编译报错 `Cannot use 'db' outside of closure scope` 或运行时崩溃。

```swift
var dbRef: Database?
try dbQueue.write { db in
    dbRef = db  // ❌ 不要保存 db 引用
}
// dbRef 已失效！
```

**修复：** 所有数据库操作必须在 `write` / `read` 闭包内完成：

```swift
// ✅ 在闭包内完成所有操作
try dbQueue.write { db in
    let players = try Player.fetchAll(db)
    for player in players {
        // 处理数据
    }
}
```

### 错误 5: id 类型不匹配

**症状：** 插入成功但 `id` 始终为 `nil`，或者查询时报类型错误。

```swift
// ❌ 主键声明为 Int 但表使用 autoIncrementedPrimaryKey (Int64)
struct Player: FetchableRecord, PersistableRecord {
    var id: Int?       // 应该是 Int64?
    var name: String
}
```

**修复：** 自增主键始终使用 `Int64?`：

```swift
// ✅
struct Player: FetchableRecord, PersistableRecord {
    var id: Int64?
    var name: String
}
```

---

## Swift vs Rust/Python 对比

| 维度 | Swift (GRDB) | Rust (Diesel / SQLx) | Python (SQLAlchemy) |
|------|-------------|---------------------|---------------------|
| 声明方式 | 结构体 + `FetchableRecord` / `PersistableRecord` 协议 | 结构体 + `#[derive(Queryable, Insertable)]` 或 `sqlx::query!` 宏 | `declarative_base()` 子类 |
| Schema 管理 | 代码内 `db.create(table:)` 手动定义 | `diesel migration generate` 生成 SQL 迁移文件 | `alembic` 迁移工具 |
| 查询方式 | `QueryInterface` 链式 API | Diesel: 类型安全 DSL; SQLx: 编译期 SQL 检查 | Query API / 方法链 |
| 类型安全 | 编译期强检查 | 编译期强检查 (SQLx 宏) | 运行期检查 |
| 线程安全 | `DatabaseQueue` 串行 / `DatabasePool` 并发读 | 连接池 (r2d2 / deadpool) | Session 非线程安全 |
| 后端存储 | SQLite（专用） | SQLite / PostgreSQL / MySQL | 几乎所有数据库 |
| 原始 SQL | `db.execute(sql:arguments:)` | `sqlx::query!()` 或 `diesel::sql_query` | `session.execute(text(...))` |
| 学习曲线 | 低（纯 Swift API） | 高（需要理解生命周期、连接池） | 中（概念丰富但文档好） |

**核心差异：** GRDB 专注于 SQLite 单一后端，API 设计完全遵循 Swift 的协议驱动风格。Rust 的 Diesel 支持多数据库但需要复杂的 schema 定义和迁移工具。Python 的 SQLAlchemy 是最成熟的 ORM 之一，生态最广但也最重。

如果你的应用只需要 SQLite 并且希望用最 Swift 的方式操作数据库，GRDB 是最佳选择。如果你需要 PostgreSQL 或多数据库支持，Rust + SQLx 或 Python + SQLAlchemy 更合适。

---

## 动手练习 Level 1

**目标：** 给 `Player` 模型增加 `email` 列，并实现按邮箱查询。

在 `GRDBSample.swift` 的基础上：
1. 给表定义加上 `email` 列（TEXT 类型）
2. 给 `Player` 结构体加上 `email: String` 属性
3. 插入一条带邮箱的记录
4. 用 `QueryInterface` 按邮箱查询该玩家

<details>
<summary>查看参考答案</summary>

```swift
import GRDB

struct Player: FetchableRecord, PersistableRecord, CustomStringConvertible {
    var id: Int64?
    var name: String
    var email: String
    var score: Int
    
    var description: String {
        "Player(id: \(id ?? -1), name: \(name), email: \(email), score: \(score))"
    }
}

let dbQueue = try DatabaseQueue()

try dbQueue.write { db in
    try db.create(table: "player") { t in
        t.autoIncrementedPrimaryKey("id")
        t.column("name", .text).notNull()
        t.column("email", .text).notNull()
        t.column("score", .integer).notNull().defaults(to: 0)
    }
    
    var charlie = Player(name: "Charlie", email: "charlie@example.com", score: 150)
    try charlie.insert(db)
    
    // 按邮箱查询
    let found = try Player
        .filter(Column("email") == "charlie@example.com")
        .fetchOne(db)
    
    print("Found by email: \(found ?? nil)")
}
```

</details>

---

## 动手练习 Level 2

**目标：** 实现"排行榜"功能，用 `filter` + `order` + `limit` 查询得分最高的 N 名玩家。

插入 5 名玩家，分数各不相同。查询并打印得分前 3 名的玩家名单（按分数降序排列）。

<details>
<summary>查看参考答案</summary>

```swift
try dbQueue.write { db in
    try db.create(table: "player") { t in
        t.autoIncrementedPrimaryKey("id")
        t.column("name", .text).notNull()
        t.column("score", .integer).notNull().defaults(to: 0)
    }
    
    let players = [
        Player(name: "Alice", score: 100),
        Player(name: "Bob", score: 300),
        Player(name: "Charlie", score: 200),
        Player(name: "Diana", score: 400),
        Player(name: "Eve", score: 250),
    ]
    for var p in players {
        try p.insert(db)
    }
    
    // 排行榜前 3 名
    let top3 = try Player
        .order(Column("score").desc)
        .limit(3)
        .fetchAll(db)
    
    print("🏆 Top 3 Scorers:")
    for (i, p) in top3.enumerated() {
        print("  \(i + 1). \(p.name) - \(p.score) 分")
    }
}
// 输出:
// 🏆 Top 3 Scorers:
//   1. Diana - 400 分
//   2. Bob - 300 分
//   3. Eve - 250 分
```

</details>

---

## 动手练习 Level 3

**目标：** 构建完整的 `Book` 模型，实现 CRUD + 事务 (Transaction) 操作。

1. 定义 `Book` 结构体，包含 `id`、`title`、`author`、`price` 字段
2. 创建 `book` 表
3. 实现完整的增、查、改、删操作
4. 在一个事务中批量插入多本书，如果任何一本插入失败则全部回滚

<details>
<summary>查看参考答案</summary>

```swift
import GRDB

struct Book: FetchableRecord, PersistableRecord, CustomStringConvertible {
    var id: Int64?
    var title: String
    var author: String
    var price: Double
    
    var description: String {
        "Book(id: \(id ?? -1), title: \(title), author: \(author), price: \(price))"
    }
}

func bookSample() throws {
    let dbQueue = try DatabaseQueue()
    
    try dbQueue.write { db in
        // 1. 创建表
        try db.create(table: "book") { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("title", .text).notNull()
            t.column("author", .text).notNull()
            t.column("price", .double).notNull().defaults(to: 0.0)
        }
        
        // 2. 创建 (Create) - 批量插入（事务内自动回滚）
        var books = [
            Book(title: "Swift 编程", author: "张三", price: 59.9),
            Book(title: "GRDB 指南", author: "李四", price: 39.9),
            Book(title: "SQLite 实战", author: "王五", price: 49.9),
        ]
        for var book in books {
            try book.insert(db)
        }
        print("插入了 \(books.count) 本书")
        
        // 3. 读取 (Read)
        let allBooks = try Book.fetchAll(db)
        print("书库共有 \(allBooks.count) 本书")
        
        // 4. 更新 (Update) - 修改价格
        if var book = try Book.fetchOne(db, key: 1) {
            book.price = 45.0
            try book.update(db)
            print("更新后: \(book)")
        }
        
        // 5. 删除 (Delete) - 按条件删除
        try db.execute(
            sql: "DELETE FROM book WHERE price < ?",
            arguments: [40.0]
        )
        let remaining = try Book.fetchAll(db)
        print("删除低价书后剩余: \(remaining.count) 本")
    }
}
```

</details>

---

## 故障排查 FAQ

**Q1: `fetchAll` 返回空数组，但我明明插入了数据？**

首先确认插入操作是否成功。检查 `insert(db)` 调用后 `id` 属性是否被自动填充（如果不为 `nil` 说明插入成功）。其次确认查询和插入是否在同一个 `DatabaseQueue` 实例上操作。如果是文件数据库，检查路径是否正确，可能你在查一个空文件。

**Q2: 运行时报 `SQLite error 1: table player already exists`？**

`create(table:)` 默认在表已存在时报错。如果你希望表不存在才创建（幂等操作），加上 `ifNotExists: true` 参数：

```swift
try db.create(table: "player", ifNotExists: true) { t in ... }
```

**Q3: 如何给已有表添加新列？**

GRDB 支持 `ALTER TABLE` 添加列：

```swift
try db.alter(table: "player") { t in
    t.add(column: "email", .text)
}
```

注意：添加列后需要同步更新 `Player` 结构体定义，加上对应的属性。

**Q4: `DatabaseQueue` 可以用在多线程中吗？**

可以。`DatabaseQueue` 本身是线程安全的，它内部使用串行队列保证操作顺序。多个线程可以同时调用 `dbQueue.write { ... }`，GRDB 会自动排队执行。但你不应该保存 `db` 连接引用到闭包外使用。

**Q5: 如何查看 GRDB 实际执行的 SQL 语句？**

配置 `Configuration` 开启 SQL 日志：

```swift
var config = Configuration()
config.prepareDatabase { db in
    db.trace { event in
        print("SQL: \(event.expandedDescription)")
    }
}
let dbQueue = try DatabaseQueue(configuration: config)
```

这可以帮助你在调试时确认生成的 SQL 是否符合预期。

**Q6: 如何迁移已有数据（Schema 变更）？**

GRDB 不提供自动迁移，需要手动编写迁移逻辑：

```swift
// 方案 1：先检查表是否存在
let exists = try db.tableExists("player")
if !exists {
    try db.create(table: "player") { t in ... }
} else {
    // 表已存在，检查是否需要添加列
    try db.alter(table: "player") { t in
        t.add(column: "newField", .text)
    }
}
```

使用 `DatabaseMigrator` 可以更优雅地管理多版本迁移，详见 GRDB 官方文档的 Migrations 章节。

---

## 小结

- `FetchableRecord` 和 `PersistableRecord` 协议将 Swift 结构体与 SQLite 表无缝对接，实现类型安全的 ORM
- `QueryInterface` 提供链式 API (`filter` / `order` / `limit`) 替代原始 SQL 查询，编译期即可发现错误
- `DatabaseQueue` 保证单线程串行安全，`DatabasePool` 支持并发读取，根据场景选择合适的数据访问模式
- `db.execute(sql:arguments:)` 支持参数化原始 SQL 执行，有效防止 SQL 注入
- `write` 闭包自动管理事务，闭包正常结束提交，抛出异常自动回滚

---

## 术语表

| 中文 | 英文 | 说明 |
|------|------|------|
| 记录协议 | Record Protocols | `FetchableRecord` / `PersistableRecord`，声明结构体可持久化 |
| 数据库队列 | DatabaseQueue | GRDB 的核心访问入口，保证串行线程安全 |
| 数据库连接池 | DatabasePool | 支持并发读取的数据库访问模式，基于 WAL |
| 查询接口 | QueryInterface | GRDB 的类型安全链式查询构建器 |
| 自增主键 | Auto-Incremented Primary Key | 使用 `autoIncrementedPrimaryKey` 自动生成的唯一 ID |
| 事务 | Transaction | `write` 闭包内的原子操作，成功提交失败回滚 |
| 参数化查询 | Parameterized Query | 通过 `arguments:` 绑定值的 SQL 执行，防止注入 |
| 写入前日志 | WAL (Write-Ahead Logging) | SQLite 的日志模式，支持并发读取 |
| 数据库迁移 | Database Migration | Schema 变更时手动编写的数据结构升级逻辑 |

---

## 知识检查

**题目 1:** 下面这段代码有什么问题？如何修复？

```swift
struct User: FetchableRecord, PersistableRecord {
    var id: Int?
    var name: String
}

try dbQueue.write { db in
    try db.create(table: "user") { t in
        t.autoIncrementedPrimaryKey("id")
        t.column("name", .text).notNull()
    }
    
    var user = User(name: "Alice")
    try user.insert(db)
    print(user.id)  // 这里输出什么？
}
```

<details>
<summary>查看答案和解析</summary>

**问题：** `id` 的类型声明为 `Int?`，但 `autoIncrementedPrimaryKey` 返回的是 `Int64`。在某些 SQLite 实现中主键值可能超过 `Int` 的范围（32 位系统上限约 21 亿）。虽然在小数据量下可能"能跑"，但正确的做法是用 `Int64?`。

**修复：**

```swift
struct User: FetchableRecord, PersistableRecord {
    var id: Int64?    // ✅ 改为 Int64?
    var name: String
}
```

`print(user.id)` 在修复后会正确输出 `Optional(1)`（插入后自动回填）。

</details>

**题目 2:** `DatabaseQueue` 和 `DatabasePool` 有什么区别？在高并发的 Web 服务中应该选哪个？

<details>
<summary>查看答案和解析</summary>

`DatabaseQueue` 使用串行队列，所有操作（读和写）依次执行，不会产生并发，适合简单场景。`DatabasePool` 基于 SQLite 的 WAL (Write-Ahead Logging) 模式，支持多个并发读操作 + 一个写操作，大幅提升了读密集型场景的性能。

高并发 Web 服务中应该选择 `DatabasePool`，因为读操作通常远多于写操作。`DatabasePool` 允许多个读操作并行执行，不会因为一个读操作阻塞另一个读操作。

</details>

**题目 3:** 为什么 GRDB 中更新和删除操作用了原始 SQL (`db.execute(sql:arguments:)`) 而不是 `QueryInterface`？`QueryInterface` 能实现更新和删除吗？

<details>
<summary>查看答案和解析</summary>

GRDB 的 `QueryInterface` 主要用于**查询**（SELECT），更新 (UPDATE) 和删除 (DELETE) 需要使用 `Request` 的 `updateAll(db)` 和 `deleteAll(db)` 方法，或者直接执行原始 SQL。

实际上 `QueryInterface` 也可以实现更新和删除：

```swift
// 用 QueryInterface 更新
try Player
    .filter(Column("name") == "Alice")
    .updateAll(db, Column("score").set(to: 300))

// 用 QueryInterface 删除
try Player
    .filter(Column("name") == "Bob")
    .deleteAll(db)
```

但原始 SQL 在复杂场景下更灵活（如多表 JOIN 更新）。示例代码使用原始 SQL 是为了展示 GRDB 也支持直接执行 SQL 的能力。

</details>

---

## 继续学习

完成本章后，你已经掌握了用 GRDB 管理 SQLite 数据库的完整能力。下一步可以继续学习高级部分的其他章节：

- 返回 [高级进阶概览](./advance-overview.md) 查看完整学习路径
- 学习 [SwiftNIO 网络基础](./swift-nio-basics.md)，了解如何构建高性能异步网络服务

> **扩展阅读**: GRDB 官方文档提供了更多高级用法，包括数据库观察 (Database Observation)、全文搜索 (FTS5)、关联查询 (Associations) 等特性。访问 [GRDB.swift GitHub 仓库](https://github.com/groue/GRDB.swift) 获取完整文档。
