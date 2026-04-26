# 高级进阶 (Advance)

## 📖 学习内容概览

欢迎完成 Swift 基础部分的学习！**高级进阶** 部分将带你深入 Swift 的生态系统与工程化实践。从 JSON 处理到异步编程，从系统服务到第三方库集成，这些知识将帮助你编写生产级别的 Swift 代码。

---

## 🎯 你将学到什么

完成本部分学习后，你将能够：

1. **处理 JSON 数据** - 使用 JSONSerialization、JSONDecoder/Encoder 和 SwiftyJSON
2. **操作文件系统** - 使用 FileManager 进行文件读写、目录遍历、临时文件管理
3. **监控系统服务** - 网络可达性检测、系统配置信息查询
4. **编写异步程序** - 使用 Task、async/await 与 SwiftNIO 进行异步 I/O
5. **管理环境配置** - 使用 swift-dotenv 管理 `.env` 环境变量

---

## 📚 章节列表

| 章节 | 说明 | 难度 | 预计时间 |
|------|------|------|---------|
| [JSON 处理](./json.md) | JSONSerialization, JSONDecoder/Codable, SwiftyJSON | 🟡 中等 | 45 分钟 |
| [文件操作](./file-operations.md) | FileManager, 临时文件, AsyncLineSequence 流式读取 | 🟡 中等 | 40 分钟 |
| [SwiftData 持久化](./swift-data.md) | @Model, ModelContainer, ModelActor, #Predicate | 🔴 困难 | 60 分钟 |
| [环境配置](./environment.md) | ProcessInfo, swift-dotenv, 动态成员查找 | 🟢 简单 | 30 分钟 |

> **注意**: SwiftData 章节 requires macOS 14.0+。文件操作的流式读取特性 requires macOS 12.0+。

---

## 🔗 前置要求

**必须完成**:
- 基础部分所有章节（变量与表达式 → 并发编程）
- 理解 Swift 的 `async`/`await` 语法
- 理解 `do/catch/try` 错误处理模式

**建议具备**:
- 基本的文件系统和命令行操作经验
- 了解 JSON 数据结构

---

## 📈 学习路径

```
JSON 处理 → 文件操作 → SwiftData 持久化 → 环境配置
```

---

## ✅ 学习检查点

完成本部分后，你应该能够：

- [ ] 使用 JSONDecoder 和 SwiftyJSON 解析嵌套 JSON 数据
- [ ] 使用 FileManager 创建、读取、删除文件和目录
- [ ] 使用 SwiftData @Model 定义数据模型并执行 CRUD 操作
- [ ] 使用 swift-dotenv 管理 .env 环境变量

---

## 🎓 实践项目

**建议练习**:
1. 编写一个读取 JSON API 响应并保存到 SwiftData 数据库的应用
2. 实现一个从 .env 加载配置并写入日志文件的工具
3. 创建一个使用 ModelActor 后台导入数据的模块

---

## ➡️ 下一步

完成高级进阶后，继续学习 **[实战精选](../awesome/awesome.md)** 部分，你将看到：

- 第三方库集成示例
- LeetCode 题目实现
- 工程化的最佳实践

---

**准备好了吗？让我们开始 [JSON 处理](./json.md) 的学习！** 🚀
