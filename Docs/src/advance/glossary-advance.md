# 高级进阶术语表

本文档收录 Swift 高级进阶部分的常用术语，供读者查阅参考。

---

## A-E

| 中文 | 英文 | 说明 |
|------|------|------|
| 数组 | Array | 有序集合，支持索引访问 |
| 异步 | async | 异步函数声明关键字 |
| Actor | Actor | Swift 并发模型中的隔离单元，保证数据安全 |
| 编码 | Encoding | 将 Swift 类型转换为外部格式（如 JSON） |
| Codable | Codable | 编码和解码协议的组合 (Encodable + Decodable) |
| CodingKeys | CodingKeys | 自定义 JSON 键名映射的枚举 |
| 容器 | Container | SwiftData 中管理数据模型实例的对象 |
| 缓存目录 | Caches Directory | 存储临时缓存文件，系统可能清理 |
| 文档目录 | Documents Directory | 存储用户文档，iTunes 会备份 |
| 动态成员查找 | Dynamic Member Lookup | 编译时动态访问属性的特性 |

---

## F-I

| 中文 | 英文 | 说明 |
|------|------|------|
| 描述符 | FetchDescriptor | SwiftData 查询配置对象 |
| 文件管理器 | FileManager | Foundation 文件系统操作类 |
| 强制解包 | Force Unwrap | 使用 `!` 强制获取可选值（危险操作） |
| @Model | @Model | SwiftData 数据模型宏 |
| ModelActor | ModelActor | SwiftData 并发安全的 Actor 模式 |
| ModelContainer | ModelContainer | SwiftData 数据库容器 |
| ModelContext | ModelContext | SwiftData 操作上下文 |
| 迁移 | Migration | 数据模型变更时的迁移策略 |
| 不可变性 | Immutability | 常量声明后不可修改的特性 |

---

## J-P

| 中文 | 英文 | 说明 |
|------|------|------|
| JSON 解码器 | JSONDecoder | Codable 协议的 JSON 解码工具 |
| JSON 编码器 | JSONEncoder | Codable 协议的 JSON 编码工具 |
| JSON 序列化 | JSONSerialization | Foundation 传统 JSON 解析工具 |
| 谓词 | Predicate | 数据库查询过滤条件表达式 |
| #Predicate | #Predicate | SwiftData 查询条件宏 |
| 进程信息 | ProcessInfo | 获取系统环境变量的单例 |
| 属性包装器 | Property Wrapper | 包装属性访问的自定义类型 |

---

## Q-T

| 中文 | 英文 | 说明 |
|------|------|------|
| 查询 | Query | SwiftData SwiftUI 数据请求 |
| RAII | RAII | 资源获取即初始化，用于自动清理 |
| 关系 | Relationship | SwiftData 模型间的关联关系 |
| 排序描述符 | SortDescriptor | 查询结果的排序配置 |
| Sendable | Sendable | 跨并发边界安全传递的协议 |
| 流式读取 | Streaming Read | 异步逐行读取大文件 |
| Task | Task | Swift 并发任务的执行单元 |
| 临时文件 | Temporary File | 系统自动清理的短期文件 |
| 临时目录 | Temporary Directory | 存放临时文件的系统目录 |

---

## U-Z

| 中文 | 英文 | 说明 |
|------|------|------|
| URL | URL | 文件路径或网络地址的表示 |
| 值类型 | Value Type | struct、enum 等复制语义的类型 |
| 等待 | await | 异步函数等待结果的运算符 |
| SwiftyJSON | SwiftyJSON | 第三方 JSON 解析库，简化访问 |

---

## 环境配置术语

| 中文 | 英文 | 说明 |
|------|------|------|
| 环境变量 | Environment Variable | 系统级配置参数 |
| .env 文件 | .env file | 项目级环境配置文件 |
| dotenv | dotenv | 加载 .env 文件的工具/库 |
| API 密钥 | API Key | 第三方服务的访问凭证 |

---

## SwiftData 术语

| 中文 | 英文 | 说明 |
|------|------|------|
| 模型宏 | @Model macro | 将 class 转换为持久化模型的宏 |
| 持久标识符 | PersistentIdentifier | SwiftData 对象的唯一 ID |
| 内存模式 | In-Memory Mode | 不写入磁盘的数据库配置 |
| SQLite | SQLite | SwiftData 默认的存储后端 |
| 级联删除 | Cascade Delete | 关系对象的自动删除规则 |

---

## 平台术语

| 中文 | 英文 | 说明 |
|------|------|------|
| macOS 14+ | macOS 14+ | SwiftData 所需最低版本 |
| macOS 12+ | macOS 12+ | FileManager async APIs 所需版本 |
| Linux | Linux | Swift 支持的平台，部分特性受限 |
| 应用支持目录 | Application Support Directory | 存储应用配置和数据库的目录 |

---

**返回**: [高级进阶](./advance-overview.md)