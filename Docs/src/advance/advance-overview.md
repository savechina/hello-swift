# 高级进阶 (Advance)

## 📖 学习内容概览

欢迎完成 Swift 基础部分的学习！**高级进阶** 部分将带你深入 Swift 的生态系统与工程化实践。从 JSON 处理到异步网络编程，从系统编程到测试框架，这些知识将帮助你编写生产级别的 Swift 代码。

---

## 🎯 你将学到什么

完成本部分学习后，你将能够：

1. **处理 JSON 数据** - 使用 JSONSerialization、JSONDecoder/Encoder 和 SwiftyJSON
2. **操作文件系统** - 使用 FileManager 进行文件读写、目录遍历、临时文件管理
3. **持久化数据** - 使用 SwiftData @Model、ModelContainer、ModelActor 构建 CRUD 应用
4. **管理环境配置** - 使用 swift-dotenv 管理 `.env` 环境变量
5. **构建网络服务** - 使用 SwiftNIO 创建 TCP 服务器，理解 EventLoop、Channel
6. **集成 async/await** - 将 SwiftNIO Future 与现代 Swift 并发模型结合
7. **系统级编程** - 使用 Process 执行命令，处理 Signal，跨平台部署
8. **编写测试** - 使用 XCTest 编写单元测试、异步测试、性能基准
9. **构建 Web API** - 使用 Vapor 创建 REST API、路由、中间件
10. **操作 SQLite 数据库** - 使用 GRDB 进行类型安全的 SQL 查询
11. **并发安全编程** - 使用 Actor 和 Sendable 构建线程安全代码
12. **高级 Swift 特性** - Property Wrappers、ARC、Opaque Types、Unsafe Pointers、Macros、Result Builders、Mirror Reflection

---

## 📚 章节列表

### Phase 1: 数据处理与持久化

| 章节 | 说明 | 难度 | 预计时间 |
|------|------|------|---------|
| [JSON 处理](./json.md) | JSONSerialization, JSONDecoder/Codable, SwiftyJSON | 🟡 中等 | 45 分钟 |
| [文件操作](./file-operations.md) | FileManager, 临时文件, AsyncLineSequence 流式读取 | 🟡 中等 | 40 分钟 |
| [SwiftData 持久化](./swift-data.md) | @Model, ModelContainer, ModelActor, #Predicate | 🔴 困难 | 60 分钟 |
| [环境配置](./environment.md) | ProcessInfo, swift-dotenv, 动态成员查找 | 🟢 简单 | 30 分钟 |

### Phase 2: 网络与系统编程

| 章节 | 说明 | 难度 | 预计时间 |
|------|------|------|---------|
| [SwiftNIO 网络基础](./swift-nio-basics.md) | EventLoop, Channel, ByteBuffer, Echo Server | 🔴 困难 | 50 分钟 |
| [SwiftNIO async/await](./swift-nio-async.md) | Future 桥接, NIOLoopBoundBox, NIOAsyncChannel | 🔴 困难 | 40 分钟 |
| [系统编程](./system-programming.md) | Process 执行, Signal 处理, 跨平台路径 | 🟡 中等 | 35 分钟 |
| [测试框架](./testing.md) | XCTest, async 测试, measure 性能基准 | 🟢 简单 | 25 分钟 |

### Phase 3: Web 与数据库

| 章节 | 说明 | 难度 | 预计时间 |
|------|------|------|---------|
| [Vapor Web 框架](./vapor.md) | 路由, 中间件, Content 协议, REST API | 🔴 困难 | 45 分钟 |
| [GRDB SQL 数据库](./grdb.md) | Record 协议, QueryInterface, 事务, 关联 | 🔴 困难 | 45 分钟 |

### Phase 4: 并发深入

| 章节 | 说明 | 难度 | 预计时间 |
|------|------|------|---------|
| [Actors 并发模型](./actors-basics.md) | actor 定义, 隔离域, await 调用 | 🟡 中等 | 30 分钟 |
| [Sendable 并发安全](./sendable-deep.md) | Sendable 协议, @Sendable 闭包, 编译器检查 | 🟡 中等 | 30 分钟 |

### Phase 5: Swift 高级特性

| 章节 | 说明 | 难度 | 预计时间 |
|------|------|------|---------|
| [Property Wrappers](./property-wrappers.md) | @propertyWrapper, wrappedValue, projectedValue | 🟡 中等 | 25 分钟 |
| [ARC 内存管理](./arc-memory.md) | 引用计数, strong/weak/unowned, 捕获列表 | 🟡 中等 | 25 分钟 |
| [Opaque/Existential 类型](./opaque-types.md) | some vs any, 类型擦除, 关联类型 | 🟢 简单 | 20 分钟 |
| [Unsafe Pointers](./unsafe-pointers.md) | 指针运算, MemoryLayout, C 互操作 | 🔴 困难 | 30 分钟 |
| [Swift Macros](./macros.md) | @attached, @freestanding, 宏展开 | 🔴 困难 | 30 分钟 |
| [Result Builders](./result-builders.md) | @resultBuilder, buildBlock, ViewBuilder 原理 | 🟡 中等 | 25 分钟 |
| [Mirror Reflection](./mirror-reflection.md) | Mirror, children, displayStyle, 反射限制 | 🟢 简单 | 20 分钟 |

> **平台要求**:
> - SwiftData: macOS 14.0+ (Sonoma)
> - SwiftNIO/Vapor/GRDB: macOS 12.0+ 或 Linux (Ubuntu 22.04+)
> - 文件操作 async APIs: macOS 12.0+
> - Swift Macros: Swift 5.9+ (Xcode 15+)

---

## 🔗 前置要求

**必须完成**:
- 基础部分所有章节（变量与表达式 → 并发编程）
- 理解 Swift 的 `async`/`await` 语法
- 理解 `do/catch/try` 错误处理模式

**建议具备**:
- 基本的文件系统和命令行操作经验
- 了解 JSON 数据结构
- 了解 TCP/IP 网络基础概念

---

## 📈 学习路径

```
Phase 1 (数据处理):
JSON 处理 → 文件操作 → SwiftData 持久化 → 环境配置

Phase 2 (网络与系统):
SwiftNIO 网络基础 → SwiftNIO async/await → 系统编程 → 测试框架

Phase 3 (Web 与数据库):
Vapor Web 框架 → GRDB SQL 数据库

Phase 4 (并发深入):
Actors 并发模型 → Sendable 并发安全

Phase 5 (Swift 高级特性):
Property Wrappers → ARC 内存管理 → Opaque Types → Unsafe Pointers → Macros → Result Builders → Mirror Reflection
```

---

## ✅ 学习检查点

完成本部分后，你应该能够：

- [ ] 使用 JSONDecoder 和 SwiftyJSON 解析嵌套 JSON 数据
- [ ] 使用 FileManager 创建、读取、删除文件和目录
- [ ] 使用 SwiftData @Model 定义数据模型并执行 CRUD 操作
- [ ] 使用 swift-dotenv 管理 .env 环境变量
- [ ] 使用 SwiftNIO 创建简单的 Echo Server
- [ ] 将 SwiftNIO Future 与 async/await 桥接
- [ ] 使用 Process 执行外部命令并捕获输出
- [ ] 使用 XCTest 编写单元测试和异步测试
- [ ] 使用 Vapor 创建 REST API 和中间件
- [ ] 使用 GRDB 执行类型安全的 SQL 查询
- [ ] 使用 Actor 构建线程安全的共享状态
- [ ] 理解 Sendable 协议并修复并发安全错误
- [ ] 使用 Property Wrappers 封装可复用属性逻辑
- [ ] 使用 weak/unowned 打破 ARC 循环引用
- [ ] 正确使用 some/any 进行类型抽象
- [ ] 使用 UnsafePointer 进行底层内存操作
- [ ] 理解 Swift Macros 的编译时代码生成机制
- [ ] 使用 Result Builders 创建声明式 DSL
- [ ] 使用 Mirror 运行时检查类型结构

---

## 🎓 实践项目

**建议练习**:
1. 编写一个读取 JSON API 响应并保存到 SwiftData 数据库的应用
2. 实现一个从 .env 加载配置并写入日志文件的工具
3. 创建一个 SwiftNIO Echo Server，支持多客户端并发连接
4. 为你的代码库编写 XCTest 测试覆盖核心逻辑
5. 实现一个 CLI 工具，调用 git 命令获取仓库信息
6. 使用 Vapor 构建一个 Todo List REST API，集成 GRDB 持久化
7. 创建一个 Actor 管理的并发安全缓存系统
8. 使用 Property Wrappers 实现输入验证框架
9. 使用 Result Builders 构建简易 HTML 生成 DSL

---

## ➡️ 下一步

完成高级进阶后，继续学习 **[实战精选](../awesome/awesome.md)** 部分，你将看到：

- 第三方库集成示例
- LeetCode 题目实现
- 工程化的最佳实践

---

**准备好了吗？让我们开始 [JSON 处理](./json.md) 的学习！** 🚀