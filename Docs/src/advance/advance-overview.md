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

> **平台要求**:
> - SwiftData: macOS 14.0+ (Sonoma)
> - SwiftNIO: macOS 12.0+ 或 Linux (Ubuntu 22.04+)
> - 文件操作 async APIs: macOS 12.0+

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

---

## 🎓 实践项目

**建议练习**:
1. 编写一个读取 JSON API 响应并保存到 SwiftData 数据库的应用
2. 实现一个从 .env 加载配置并写入日志文件的工具
3. 创建一个 SwiftNIO Echo Server，支持多客户端并发连接
4. 为你的代码库编写 XCTest 测试覆盖核心逻辑
5. 实现一个 CLI 工具，调用 git 命令获取仓库信息

---

## ➡️ 下一步

完成高级进阶后，继续学习 **[实战精选](../awesome/awesome.md)** 部分，你将看到：

- 第三方库集成示例
- LeetCode 题目实现
- 工程化的最佳实践

---

**准备好了吗？让我们开始 [JSON 处理](./json.md) 的学习！** 🚀