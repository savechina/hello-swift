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

## Vapor Web 框架术语

| 中文 | 英文 | 说明 |
|------|------|------|
| 路由 | Route | URL 路径到处理函数的映射 |
| 中间件 | Middleware | 拦截请求/响应的处理器链 |
| 内容协议 | Content | Vapor 的 JSON 编解码协议 |
| 应用实例 | Application | Vapor 服务器的核心对象 |
| 异步中间件 | AsyncMiddleware | 支持 async/await 的中间件 |
| 异步响应器 | AsyncResponder | 中间件链中的下一个处理器 |
| 参数提取 | Parameters | 从 URL 路径中提取动态值 |
| Fluent ORM | Fluent | Vapor 的数据库 ORM 框架 |

---

## GRDB 数据库术语

| 中文 | 英文 | 说明 |
|------|------|------|
| 数据库队列 | DatabaseQueue | 单线程 SQLite 连接管理器 |
| 数据库池 | DatabasePool | 多线程 SQLite 连接池 |
| 可获取记录 | FetchableRecord | 从数据库行解码为 Swift 类型的协议 |
| 可持久化记录 | PersistableRecord | 将 Swift 类型写入数据库的协议 |
| 查询接口 | QueryInterface | 类型安全的 SQL 查询 DSL |
| 关联 | Association | 表之间的关系定义（BelongsTo/HasMany） |
| 事务 | Transaction | 原子性的数据库操作组 |
| WAL 模式 | WAL Mode | Write-Ahead Logging，提高并发性能 |

---

## 并发深入术语

| 中文 | 英文 | 说明 |
|------|------|------|
| 参与者 | Actor | Swift 并发模型中的隔离单元，保证数据安全 |
| 隔离域 | Isolation Domain | Actor 保护的状态范围 |
| 非隔离 | Nonisolated | 不受 Actor 隔离限制的方法 |
| 可发送 | Sendable | 可安全跨并发边界传递的类型 |
| 严格并发 | Strict Concurrency | Swift 6 的编译时并发安全检查 |
| 闭包捕获 | Closure Capture | 闭包引用外部变量的行为 |
| 未检查发送 | @unchecked Sendable | 手动声明 Sendable（编译器不验证） |

---

## Swift 高级特性术语

| 中文 | 英文 | 说明 |
|------|------|------|
| 属性包装器 | Property Wrapper | 包装属性 get/set 的自定义类型 |
| 包装值 | Wrapped Value | 属性包装器存储的实际值 |
| 投影值 | Projected Value | 属性包装器暴露的额外接口（$ 前缀） |
| 自动引用计数 | ARC | Swift 的内存管理机制 |
| 强引用 | Strong Reference | 增加对象引用计数的引用 |
| 弱引用 | Weak Reference | 不增加引用计数，自动置 nil |
| 无主引用 | Unowned Reference | 不增加引用计数，不会自动置 nil |
| 循环引用 | Retain Cycle | 两个对象互相强引用导致无法释放 |
| 不透明类型 | Opaque Type | `some Protocol`，隐藏具体返回类型 |
| 存在类型 | Existential Type | `any Protocol`，运行时类型擦除 |
| 类型擦除 | Type Erasure | 将具体类型转换为协议类型 |
| 动态分发 | Dynamic Dispatch | 运行期查找方法实现 |
| 不安全指针 | Unsafe Pointer | 绕过 Swift 类型安全检查的指针 |
| 内存布局 | Memory Layout | 类型在内存中的大小、间距、对齐 |
| 悬垂指针 | Dangling Pointer | 指向已释放内存的指针 |
| 宏 | Macro | 编译时代码生成机制 |
| 附加宏 | Attached Macro | 附加到已有类型上的宏（如 @Model） |
| 独立宏 | Freestanding Macro | 不依赖类型的独立表达式（如 #warning） |
| 宏展开 | Macro Expansion | 编译器将宏替换为实际代码的过程 |
| 结果构建器 | Result Builder | 将声明式语法转换为函数调用的机制 |
| 声明式 | Declarative | 描述"做什么"而非"怎么做" |
| 构建块 | Build Block | 组合多个组件的核心方法 |
| 反射 | Reflection | 运行时检查类型结构的能力 |
| 显示样式 | Display Style | Mirror 中类型的外观类别 |
| 只读 | Read-Only | 只能读取不能修改 |

---

**返回**: [高级进阶](./advance-overview.md)