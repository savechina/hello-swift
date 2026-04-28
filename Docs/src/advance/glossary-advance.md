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
| EventLoop | EventLoop | SwiftNIO 事件循环，单线程管理多连接 |
| Echo Server | Echo Server | 收到消息原样返回的测试服务器 |

---

## F-I

| 中文 | 英文 | 说明 |
|------|------|------|
| 描述符 | FetchDescriptor | SwiftData 查询配置对象 |
| 文件管理器 | FileManager | Foundation 文件系统操作类 |
| 强制解包 | Force Unwrap | 使用 `!` 强制获取可选值（危险操作） |
| Future | EventLoopFuture | SwiftNIO 异步结果容器 |
| @Model | @Model | SwiftData 数据模型宏 |
| ModelActor | ModelActor | SwiftData 并发安全的 Actor 模式 |
| ModelContainer | ModelContainer | SwiftData 数据库容器 |
| ModelContext | ModelContext | SwiftData 操作上下文 |
| 迁移 | Migration | 数据模型变更时的迁移策略 |
| 不可变性 | Immutability | 常量声明后不可修改的特性 |
| InboundHandler | InboundHandler | SwiftNIO 入站数据处理器 |
| NIOLoopBoundBox | NIOLoopBoundBox | 跨 Actor 安全访问 EventLoop-bound 值 |

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
| 进程 | Process | Foundation 进程执行类 |
| 属性包装器 | Property Wrapper | 包装属性访问的自定义类型 |
| Pipeline | ChannelPipeline | SwiftNIO Channel 处理器链 |
| Promise | EventLoopPromise | Future 的写入端 |

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
| Signal | Signal | 操作系统发送给进程的通知 |
| SIGINT | SIGINT | Ctrl+C 中断信号（可捕获） |
| SIGTERM | SIGTERM | 优雅终止信号（可捕获） |
| ServerBootstrap | ServerBootstrap | SwiftNIO 服务器启动器 |
| setUp/tearDown | setUp/tearDown | XCTestCase 测试生命周期方法 |

---

## U-Z

| 中文 | 英文 | 说明 |
|------|------|------|
| URL | URL | 文件路径或网络地址的表示 |
| 值类型 | Value Type | struct、enum 等复制语义的类型 |
| 等待 | await | 异步函数等待结果的运算符 |
| SwiftyJSON | SwiftyJSON | 第三方 JSON 解析库，简化访问 |
| XCTest | XCTest | Swift 内置测试框架 |
| XCTestCase | XCTestCase | XCTest 测试类基类 |
| XCTAssertEqual | XCTAssertEqual | XCTest 相等断言 |
| XCTAssertThrowsError | XCTAssertThrowsError | XCTest 抛出错误断言 |
| ByteBuffer | ByteBuffer | SwiftNIO 高效字节容器，零拷贝设计 |

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

## SwiftNIO 术语

| 中文 | 英文 | 说明 |
|------|------|------|
| 通道 | Channel | SwiftNIO 网络连接抽象 |
| 事件循环组 | EventLoopGroup | SwiftNIO 多线程事件循环管理器 |
| 非阻塞 | Non-blocking | 不等待 I/O 完成，立即返回 |
| 桥接 | Bridging | Future 与 async/await 的连接方式 |
| Continuation | Continuation | async/await 的底层挂起/恢复机制 |
| EventLoop 绑定 | EventLoop-bound | 值绑定到特定 EventLoop，只能在其上操作 |
| 零拷贝 | Zero-copy | ByteBuffer slice 不复制数据的设计 |

---

## 系统编程术语

| 中文 | 英文 | 说明 |
|------|------|------|
| 子进程 | Child process | 由父进程启动的进程 |
| 状态码 | Termination status | 进程退出返回的数值（0 成功） |
| 管道 | Pipe | 进程间通信的数据流 |
| 捕获 | Catch | 接收并处理 Signal |
| 优雅关闭 | Graceful shutdown | 先清理资源再退出 |
| 沙箱 | Sandbox | macOS 的应用隔离目录 |
| stdout | stdout | 标准输出流 |
| stderr | stderr | 标准错误流 |

---

## 测试框架术语

| 中文 | 英文 | 说明 |
|------|------|------|
| 测试类 | XCTestCase | 包含多个测试方法的类 |
| 测试方法 | Test method | 以 test 开头的函数 |
| 断言 | Assertion | 检查预期结果的语句 |
| 生命周期 | Lifecycle | setUp → test → tearDown 的执行顺序 |
| 异步测试 | Async test | 标记 async 的测试方法 |
| 性能测试 | Performance test | measure {} 测量执行时间 |
| 测试隔离 | Test isolation | 每个测试独立运行，不影响其他 |
| 测试过滤 | Test filter | --filter 只运行部分测试 |

---

## 平台术语

| 中文 | 英文 | 说明 |
|------|------|------|
| macOS 14+ | macOS 14+ | SwiftData 所需最低版本 |
| macOS 12+ | macOS 12+ | FileManager async APIs 所需版本 |
| Linux | Linux | Swift 支持的平台，部分特性受限 |
| 应用支持目录 | Application Support Directory | 存储应用配置和数据库的目录 |
| 跨平台 | Cross-platform | macOS 和 Linux 双平台支持 |
| Darwin | Darwin | macOS 内核，信号处理 API |
| Glibc | Glibc | Linux C 库，POSIX API |

---

**返回**: [高级进阶](./advance-overview.md)