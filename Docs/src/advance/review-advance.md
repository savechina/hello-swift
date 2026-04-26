# 阶段复习：高级进阶

完成高级进阶部分的四个章节后，让我们通过本复习章节巩固所学知识。

---

## 📋 知识回顾

### 1. JSON 处理

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

### 2. 文件操作

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

### 3. SwiftData 持久化

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

### 4. 环境配置

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

### 练习 2: 环境配置 + 文件日志

**任务**: 从 .env 加载 API 密钥，读取文件，记录操作日志。

**步骤**:
1. Dotenv.configure() 加载配置
2. 获取 API_KEY 值
3. 使用 FileManager 写入日志文件到 Application Support
4. 使用 AsyncLineSequence 读取日志验证

<details>
<summary>点击查看提示</summary>

```swift
// 1. 加载配置
try Dotenv.configure()
let apiKey = Dotenv.apiKey?.stringValue

// 2. 获取 Application Support 目录
let appSupport = FileManager.default.urls(
    for: .applicationSupportDirectory,
    in: .userDomainMask
).first!

// 3. 写入日志
let logFile = appSupport.appendingPathComponent("operations.log")
try logData.write(to: logFile)

// 4. 流式读取
for try await line in logFile.lines {
    print("Log: \(line)")
}
```

</details>

---

## ✅ 知识检查

### 问题 1

**Swift 中解析 JSON 有哪三种主要方法？各自的优缺点是什么？**

<details>
<summary>点击查看答案</summary>

| 方法 | 优点 | 缺点 |
|------|------|------|
| JSONSerialization | Foundation 内置，无需额外依赖 | 返回 `Any`，需要手动类型转换，易出错 |
| JSONDecoder/Codable | 类型安全，编译期检查，自动映射 | 需要定义 Codable 类型，灵活性较低 |
| SwiftyJSON | 动态访问，深层嵌套简化，容错性强 | 第三方依赖，性能略低 |

</details>

---

### 问题 2

**FileManager 的 Documents、Caches、Temp 目录有什么区别？**

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

### 问题 3

**SwiftData 的 @ModelActor 模式解决了什么问题？如何正确使用？**

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

### 问题 4

**为什么不应该硬编码 API 密钥？swift-dotenv 如何帮助解决这个问题？**

<details>
<summary>点击查看答案</summary>

**原因**:
- 安全性：密钥泄露后被滥用
- 灵活性：开发/测试/生产环境使用不同密钥
- 代码共享：公开代码时密钥不应暴露

**swift-dotenv 方案**:
- 将密钥存储在 `.env` 文件
- `.env` 文件添加到 `.gitignore`
- 使用 `Dotenv.configure()` 加载
- 通过 `Dotenv.apiKey` 访问
- 不同环境使用不同的 `.env.production` / `.env.development`

</details>

---

## 📈 自我评估

完成以下检查项，评估你的掌握程度：

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
- [ ] 理解为什么不应该硬编码敏感配置

---

## ➡️ 下一步

完成高级进阶复习后，继续学习 **[实战精选](../awesome/awesome.md)** 部分，你将：

- 学习第三方库集成
- 实现 LeetCode 题目
- 掌握工程化最佳实践

---

**返回**: [高级进阶概览](./advance-overview.md)