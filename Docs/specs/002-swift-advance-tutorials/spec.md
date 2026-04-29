# Feature Specification: Swift Advance Tutorial Content Generation

**Feature Branch**: `002-swift-advance-tutorials`
**Created**: 2026-04-26
**Status**: Draft
**Input**: User description: Swift advance tutorial covering JSON processing, file operations, SwiftData persistence, environment config, referencing ../hello-rust/docs/src language style and tutorial template

## Clarifications

以下澄清问题用于确定教程扩展范围，所有问题已得到用户确认：

### Session 2026-04-28 (Post-Phase 2 Implementation)

- Q: quickstart.md 是否需要同步 Phase 2 内容？ → A: 更新 quickstart.md 以反映 Phase 2：新增源文件列表、SwiftNIO 设置说明、6 小时预估、标记 Phase 1 完成

---

### Session 2026-04-28 (Phase 3 Scope Decisions)

Gap analysis against hello-rust (41 advance chapters) revealed critical missing topics. User decisions:

- Q: 是否添加 Vapor Web 框架章节？ → A: 是 - HIGH 优先级，Swift 后端生态核心框架
- Q: 是否添加 GRDB SQL 数据库章节？ → A: 是 - HIGH 优先级，跨平台 SQLite ORM
- Q: Actors/Sendable 深度如何覆盖？ → A: A+B - 两个章节（Actors 基础 + Sendable/并发安全深入）
- Q: 是否添加 Mock 测试章节？ → A: 否 - 跳过（原 Q4 决策已定最小覆盖）
- Q: Swift 专有特性覆盖哪些？ → A: 全部 - Property Wrappers、ARC 内存管理、Opaque Types、Unsafe Pointers、Macros、Result Builders、Mirror Reflection

---

### Q1: 新增主题优先级

**问题**: hello-rust 有 45 个 advance 章节，hello-swift 仅 4 个。应优先添加哪些主题？

**选项**:
- A: 跨平台优先 — SwiftNIO + Swift System + Process（支持 macOS/Linux）
- B: macOS 优先 — AppKit、Cocoa、CoreFoundation C 互操作
- C: 网络优先 — Vapor/Hummingbird Web 框架 + 数据库 (GRDB/SQLite)

**用户选择**: A — 跨平台优先

**决策**: 新增章节将优先覆盖 SwiftNIO（2 章）、Swift System Package、Process 进程管理，确保 macOS 和 Linux 双平台支持。

---

### Q2: SwiftNIO 深度

**问题**: SwiftNIO 是复杂框架，教程应覆盖多深？

**选项**:
- A: 入门级 — 1 章（基础概念 + 简单 Echo Server）
- B: 中级 — 2 章（基础 + async/await 集成）
- C: 深入级 — 3+ 章（完整 EventLoop、ChannelPipeline、HTTP Server）

**用户选择**: B — 中级（2 章）

**决策**: SwiftNIO 将分两章：基础篇（Channel/ByteBuffer/EventLoop）和集成篇（Swift async/await + NIOLoopBoundBox）。

---

### Q3: macOS 版本覆盖

**问题**: SwiftData 等特性要求 macOS 14+，教程如何处理版本兼容？

**选项**:
- A: 严格 macOS 14+ — 所有代码示例假设 macOS 14+
- B: macOS 12+ 为主，14+ 特性单独标注 — 兼顾更广泛读者

**用户选择**: B — macOS 12+ 为主，14+ 特性标注

**决策**: 代码示例主要面向 macOS 12+（Monterey），SwiftData 等特性明确标注 macOS 14+ (Sonoma) 要求。

---

### Q4: 测试章节覆盖

**问题**: hello-rust 有 6 个测试章节，Swift 应覆盖多深？

**选项**:
- A: 最小覆盖 — 1 章（XCTest 基础 + 异步测试）
- B: 完整覆盖 — 3+ 章（XCTest + Mock/Stub + CI/CD）

**用户选择**: A — 最小覆盖

**决策**: 测试部分仅 1 章，覆盖 XCTest 基础、async 测试方法，建立基本测试习惯。

---

### Q5: 源代码策略

**问题**: 新增章节是否需要新增源代码文件？

**选项**:
- A: 仅文档 — 利用现有 AdvanceSample 源代码
- B: 新增 4-6 个源文件 — SwiftNIOSample、SystemSample、ProcessSample、TestingSample

**用户选择**: B — 新增 4-6 个源文件

**决策**: 将在 `AdvanceSample/Sources/AdvanceSample/` 下新增：
- `SwiftNIOSample.swift` — SwiftNIO Echo Server 示例
- `SystemSample.swift` — Swift System Package 跨平台示例
- `ProcessSample.swift` — Process 执行外部命令示例
- `TestingSample.swift` — XCTest 测试模式示例（位于 Tests/ 目录）

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 掌握 JSON 数据处理 (Priority: P1)

作为有 Swift 基础的开发者，我希望能深入学习 JSON 数据处理的三种方式（JSONSerialization、JSONDecoder/Codable、SwiftyJSON），包括解析嵌套结构、处理可选字段、自定义 CodingKeys，以便能够熟练处理 API 响应和配置文件。

**Why this priority**: JSON 是现代应用开发中最常用的数据交换格式。掌握多种 JSON 处理方式是后端服务和 API 集成的核心技能，直接影响开发效率。

**Independent Test**: 学完 JSON 章节后，读者可以独立编写代码解析复杂 JSON 结构（嵌套对象、可选字段、自定义键名映射），并通过 `swift build` 编译运行。

**Acceptance Scenarios**:

1. **Given** 读者完成基础部分学习，**When** 阅读 JSON 处理章节，**Then** 能够使用 JSONDecoder 解码包含嵌套结构的 API 响应
2. **Given** 读者学习了 Codable 协议，**When** 需要处理 JSON 字段名与 Swift 属性名不一致的情况，**Then** 能够使用 CodingKeys 进行自定义映射
3. **Given** 读者学习了 SwiftyJSON，**When** 需要快速访问 JSON 结构中的深层字段，**Then** 能够使用 SwiftyJSON 的动态成员查找简化代码

---

### User Story 2 - 掌握文件操作与 I/O (Priority: P2)

作为需要处理持久化数据的开发者，我希望能学习 Swift 文件操作（FileManager 路径管理、临时文件创建、流式读取），包括目录遍历、错误处理、RAII 自动清理，以便编写安全可靠的文件 I/O 代码。

**Why this priority**: 文件操作是应用开发的基础能力，涉及数据持久化、日志记录、配置管理等场景。正确的路径管理和错误处理直接影响应用稳定性。

**Independent Test**: 读者能够使用 FileManager 获取标准目录路径、创建临时文件并自动清理、使用 AsyncLineSequence 流式读取大文件。

**Acceptance Scenarios**:

1. **Given** 读者学习了 FileManager，**When** 需要存储用户数据，**Then** 能够正确获取 Documents/Caches/Application Support 目录路径
2. **Given** 读者学习了 TemporaryFile 类，**When** 需要处理临时数据，**Then** 能够创建临时文件并在使用后自动清理
3. **Given** 读者学习了流式读取，**When** 需要处理大型日志文件，**Then** 能够使用 AsyncLineSequence 逐行异步读取而不阻塞主线程

---

### User Story 3 - 掌握 SwiftData 数据持久化 (Priority: P3)

作为需要构建数据持久化层的开发者，我希望能学习 SwiftData 框架（@Model、ModelContainer、ModelContext、ModelActor），包括定义数据模型、执行 CRUD 操作、使用 #Predicate 查询，以便构建类型安全的本地数据库应用。

**Why this priority**: SwiftData 是 Apple 在 2023 年推出的现代 ORM 框架，替代 Core Data，提供更简洁的 Swift 语法。这是 macOS/iOS 开发者的关键技能。

**Independent Test**: 读者能够定义 @Model 数据类、初始化 ModelContainer、使用 ModelContext 执行插入/查询/删除操作。

**Acceptance Scenarios**:

1. **Given** 读者学习了 SwiftData 基础，**When** 需要定义数据模型，**Then** 能够使用 @Model 宏创建持久化类
2. **Given** 读者学习了 ModelActor，**When** 需要在并发环境中安全操作数据库，**Then** 能够使用 ModelActor 保证线程安全
3. **Given** 读者学习了 FetchDescriptor，**When** 需要查询特定数据，**Then** 能够使用 #Predicate 和 SortDescriptor 构建复杂查询

---

### User Story 4 - 掌握环境配置管理 (Priority: P4)

作为需要管理敏感配置的开发者，我希望能学习环境变量管理（ProcessInfo.processInfo、swift-dotenv），包括读取系统环境变量、加载 .env 文件、动态成员查找，以便安全管理 API 密钥和配置参数。

**Why this priority**: 环境配置是生产级应用的关键能力，涉及安全性（API 密钥不应硬编码）和灵活性（开发/生产环境切换）。

**Independent Test**: 读者能够使用 ProcessInfo 读取系统环境变量、使用 swift-dotenv 加载 .env 文件、在代码中安全访问配置值。

**Acceptance Scenarios**:

1. **Given** 读者学习了 ProcessInfo，**When** 需要读取 PATH 等系统变量，**Then** 能够使用 ProcessInfo.processInfo.environment 获取
2. **Given** 读者学习了 swift-dotenv，**When** 需要从 .env 文件加载配置，**Then** 能够使用 Dotenv.configure() 和动态成员查找访问值

---

### User Story 5 - 掌握 SwiftNIO 异步网络编程 (Priority: P5)

作为需要构建高性能网络服务的开发者，我希望能学习 SwiftNIO 框架（Channel、EventLoop、ByteBuffer、异步编程模式），包括创建 TCP/HTTP 服务器、处理并发连接、与 Swift async/await 集成，以便构建跨平台（macOS/Linux）的现代网络应用。

**Why this priority**: SwiftNIO 是 Swift 生态中核心的异步网络框架，被 Vapor、Hummingbird 等主流 Web 框架采用。掌握 SwiftNIO 是构建后端服务的关键技能，且完全支持 macOS 和 Linux 跨平台。

**Independent Test**: 读者能够使用 SwiftNIO 创建简单的 Echo Server、理解 ChannelPipeline 和 EventLoop 的工作原理、使用 NIOLoopBoundBox 在 async/await 中安全集成 SwiftNIO。

**Acceptance Scenarios**:

1. **Given** 读者学习了 SwiftNIO 基础，**When** 需要创建 TCP 服务器，**Then** 能够使用 ServerBootstrap 和 ChannelHandler 处理入站连接
2. **Given** 读者学习了 ByteBuffer，**When** 需要处理网络数据，**Then** 能够正确读写缓冲区数据并处理粘包问题
3. **Given** 读者学习了 SwiftNIO async/await 集成，**When** 需要在现代 Swift 并发模型中使用 SwiftNIO，**Then** 能够使用 NIOAsyncChannel 和 NIOLoopBoundBox 进行桥接

---

### User Story 6 - 掌握系统编程与进程管理 (Priority: P6)

作为需要构建系统级工具的开发者，我希望能学习 Swift 系统编程（Swift System Package、Process 进程管理、Signal 信号处理、POSIX/Glibc 跨平台），包括执行外部命令、处理进程生命周期、实现跨平台系统调用，以便编写可在 macOS 和 Linux 运行的 CLI 工具和守护进程。

**Why this priority**: 系统编程是构建生产级 CLI 工具的基础，涉及进程管理、信号处理、文件描述符操作等底层能力。Swift System Package 提供跨平台抽象，消除 macOS (Darwin) 和 Linux (Glibc) 的系统调用差异。

**Independent Test**: 读者能够使用 Process 执行外部命令并捕获输出、使用 Signal 处理 SIGINT/SIGTERM、了解 Swift System Package 的跨平台路径和文件操作 API。

**Acceptance Scenarios**:

1. **Given** 读者学习了 Process，**When** 需要调用外部工具（如 git、npm），**Then** 能够使用 Process 正确设置参数、捕获 stdout/stderr、处理执行错误
2. **Given** 读者学习了 Signal 处理，**When** 需要优雅关闭守护进程，**Then** 能够捕获 SIGINT/SIGTERM 并执行清理逻辑
3. **Given** 读者学习了 Swift System Package，**When** 需要跨平台文件操作，**Then** 能够使用 SystemPackage FilePath 替代 FileManager 实现平台无关代码

---

### User Story 7 - 掌握测试框架与质量保证 (Priority: P7)

作为需要构建高质量代码的开发者，我希望能学习 Swift 测试框架（XCTest 基础、异步测试、性能测试、Mock/Stub 模式），包括编写单元测试、测试异步代码、测量性能基准，以便建立可靠的测试习惯和持续集成流程。

**Why this priority**: 测试是现代软件开发的必备技能。Swift 内置 XCTest 框架，配合 `swift test` 命令即可运行，无需额外依赖。本章节以最小覆盖为目标，快速建立测试习惯。

**Independent Test**: 读者能够使用 XCTest 编写基本单元测试、使用 XCTestCase 的 async 测试方法、了解 `swift test --filter` 的使用方式。

**Acceptance Scenarios**:

1. **Given** 读者学习了 XCTest 基础，**When** 需要验证函数逻辑，**Then** 能够创建 XCTestCase 子类并使用 XCTAssert 系列断言
2. **Given** 读者学习了异步测试，**When** 需要测试 async 函数，**Then** 能够正确使用 async test 方法避免竞态条件

---

### User Story 8 - 掌握 Vapor Web 框架 (Priority: P8)

作为需要构建 Swift 后端服务的开发者，我希望能学习 Vapor 框架（路由、控制器、中间件、Fluent ORM），包括创建 REST API、处理请求/响应、数据库集成，以便构建生产级 Swift Web 应用。

**Why this priority**: Vapor 是 Swift 生态中最流行的 Web 框架，被众多生产项目采用。掌握 Vapor 是成为 Swift 后端开发者的关键技能。

**Independent Test**: 读者能够使用 Vapor 创建简单 REST API、配置路由和中间件、使用 Fluent 进行数据库 CRUD 操作。

**Acceptance Scenarios**:

1. **Given** 读者学习了 Vapor 基础，**When** 需要创建 REST API，**Then** 能够定义路由处理器并返回 JSON 响应
2. **Given** 读者学习了 Fluent ORM，**When** 需要持久化数据，**Then** 能够定义 Model 并执行 CRUD 操作
3. **Given** 读者学习了中间件，**When** 需要添加认证逻辑，**Then** 能够创建自定义中间件拦截请求

---

### User Story 9 - 掌握 GRDB SQL 数据库 (Priority: P9)

作为需要跨平台数据持久化的开发者，我希望能学习 GRDB 框架（SQLiteDatabase、Record、Associations、QueryInterface），包括定义数据模型、执行 SQL 查询、处理关联关系，以便在 macOS 和 Linux 构建类型安全的 SQLite 应用。

**Why this priority**: GRDB 是 Swift 生态中成熟的 SQLite ORM，支持 macOS 和 Linux 跨平台。相比 SwiftData（仅 macOS/iOS），GRDB 提供更广泛的适用性。

**Independent Test**: 读者能够使用 GRDB 定义 Record 类、执行 SQL 查询和事务、处理表关联。

**Acceptance Scenarios**:

1. **Given** 读者学习了 GRDB 基础，**When** 需要定义数据表，**Then** 能够使用 Record 协议创建类型安全的模型
2. **Given** 读者学习了 QueryInterface，**When** 需要查询数据，**Then** 能够使用链式 API 构建 SQL 查询
3. **Given** 读者学习了 Associations，**When** 需要处理关联表，**Then** 能够定义 BelongsTo/HasMany 关系并自动 JOIN

---

### User Story 10 - 掌握 Actors 并发模型 (Priority: P10)

作为需要编写并发安全代码的开发者，我希望能学习 Swift Actors（actor 定义、隔离域、Actor isolation、Task sleep），包括理解 actor 与 class 的区别、实现线程安全、处理 actor 消息传递，以便在 Swift 6 并发模型中正确使用 actors。

**Why this priority**: Actors 是 Swift 6 并发模型的核心特性，提供编译器保证的线程安全。掌握 actors 是现代 Swift 并发编程的基础。

**Independent Test**: 读者能够定义 actor 类型、理解 actor isolation 规则、使用 await 调用 actor 方法。

**Acceptance Scenarios**:

1. **Given** 读者学习了 actor 基础，**When** 需要保护共享状态，**Then** 能够将 class 替换为 actor 并理解隔离域
2. **Given** 读者学习了 actor isolation，**When** 需要访问 actor 属性，**Then** 能够正确使用 await 跨越隔离边界
3. **Given** 读者学习了 actor 与 class 的区别，**When** 需要选择并发抽象，**Then** 能够判断何时使用 actor vs class

---

### User Story 11 - 掌握 Sendable 与并发安全深入 (Priority: P11)

作为需要构建复杂并发系统的开发者，我希望能深入理解 Swift 6 Sendable 协议（Sendable 类型、@Sendable closure、async let、TaskGroup 错误处理），包括编译器 Sendable 检查、解决并发安全问题、使用高级并发模式，以便在 Swift 6 严格并发模式下编写正确代码。

**Why this priority**: Sendable 是 Swift 6 严格并发检查的核心。理解 Sendable 规则是避免并发错误的关键，直接关系到生产代码的安全性。

**Independent Test**: 读者能够识别 Sendable 类型、理解编译器 Sendable 错误并修复、使用 @Sendable closure 安全传递闭包。

**Acceptance Scenarios**:

1. **Given** 读者学习了 Sendable 协议，**When** 需要跨 Task 传递数据，**Then** 能够识别哪些类型天然 Sendable
2. **Given** 读者学习了 @Sendable closure，**When** 需要在 Task 中使用闭包，**Then** 能够正确标记并发安全闭包
3. **Given** 读者学习了编译器 Sendable 检查，**When** 遇到 Sendability 错误，**Then** 能够根据错误信息修复代码

---

### User Story 12 - 掌握 Property Wrappers (Priority: P12)

作为需要封装可复用属性逻辑的开发者，我希望能学习 Swift Property Wrappers（@propertyWrapper、wrappedValue、projectedValue），包括定义自定义包装器、组合包装器、理解 SwiftUI 内置包装器原理，以便创建可复用的属性模式。

**Why this priority**: Property Wrappers 是 Swift 5.1 引入的核心特性，被 SwiftUI (@State, @Binding)、Combine (@Published) 等广泛使用。理解包装器机制是进阶 Swift 开发的必备知识。

**Independent Test**: 读者能够定义自定义 property wrapper、理解 wrappedValue/projectedValue 的作用、组合多个包装器。

**Acceptance Scenarios**:

1. **Given** 读者学习了 @propertyWrapper，**When** 需要封装属性逻辑，**Then** 能够定义自定义包装器如 @Clamped 或 @Logged
2. **Given** 读者学习了 projectedValue，**When** 需要暴露包装器内部状态，**Then** 能够使用 $ 前缀访问 projected value
3. **Given** 读者学习了包装器组合，**When** 需要多层包装，**Then** 能够正确叠加多个包装器

---

### User Story 13 - 掌握 ARC 内存管理 (Priority: P13)

作为需要优化内存性能的开发者，我希望能深入理解 Swift ARC（引用计数、strong/weak/unowned、循环引用检测、闭包捕获规则），包括手动内存管理场景、使用 Instruments 诊断内存问题，以便编写高效的 Swift 代码。

**Why this priority**: ARC 是 Swift 内存管理的核心机制。理解引用类型生命周期和循环引用是避免内存泄漏的关键技能。

**Independent Test**: 读者能够识别循环引用场景、正确使用 weak/unowned 打破循环、理解闭包捕获列表。

**Acceptance Scenarios**:

1. **Given** 读者学习了 ARC 基础，**When** 需要理解引用生命周期，**Then** 能够预测对象何时被释放
2. **Given** 读者学习了循环引用，**When** 需要避免内存泄漏，**Then** 能够识别双向引用并使用 weak 打破循环
3. **Given** 读者学习了闭包捕获，**When** 需要控制捕获行为，**Then** 能够使用捕获列表明确引用语义

---

### User Story 14 - 掌握 Opaque/Existential Types (Priority: P14)

作为需要隐藏类型细节的开发者，我希望能学习 Swift 类型抽象（some 关键字、any 关键字、opaque return types、protocol existential），包括理解 some vs any 的区别、协议类型性能差异，以便设计灵活且高效的 API。

**Why this priority**: Opaque types (some) 和 Existential types (any) 是 Swift 5.7+ 引入的关键类型系统特性。理解两者区别是设计现代 Swift API 的基础。

**Independent Test**: 读者能够使用 some 返回隐藏具体类型、理解 any 的性能开销、正确选择 some vs any。

**Acceptance Scenarios**:

1. **Given** 读者学习了 opaque types，**When** 需要隐藏返回类型，**Then** 能够使用 some Protocol 返回类型
2. **Given** 读者学习了 existential types，**When** 需要存储异构类型，**Then** 能够使用 [any Protocol] 数组
3. **Given** 读者学习了 some vs any，**When** 需要设计 API，**Then** 能够根据性能需求选择正确的类型抽象

---

### User Story 15 - 掌握 Unsafe Pointers (Priority: P15)

作为需要与 C API 交互或优化性能的开发者，我希望能学习 Swift Unsafe Pointers（UnsafePointer、UnsafeMutablePointer、UnsafeRawPointer、Memory Layout），包括指针运算、内存绑定、与 C 互操作，以便在必要时编写底层代码。

**Why this priority**: Unsafe pointers 是 Swift 与 C API 交互的关键机制，也是性能优化场景的底层工具。理解 unsafe 操作是进阶系统编程的必备知识。

**Independent Test**: 读者能够使用 UnsafePointer 读取内存、理解 MemoryLayout 获取类型大小、与 C 函数互操作。

**Acceptance Scenarios**:

1. **Given** 读者学习了 UnsafePointer，**When** 需要读取 C 数组，**Then** 能够使用指针运算遍历内存
2. **Given** 读者学习了 MemoryLayout，**When** 需要分配内存，**Then** 能够计算类型大小并手动管理内存
3. **Given** 读者学习了 C 互操作，**When** 需要调用 C API，**Then** 能够正确传递指针参数

---

### User Story 16 - 掌握 Swift Macros (Priority: P16)

作为需要减少重复代码的开发者，我希望能学习 Swift Macros（@freestanding、@attached、Macro expansion、SwiftSyntax），包括定义自定义宏、使用内置宏（@Model、@Observable），以便自动化代码生成并提升开发效率。

**Why this priority**: Macros 是 Swift 5.9 引入的革命性特性，被 SwiftData (@Model)、Observation (@Observable) 等广泛采用。理解宏机制是现代 Swift 开发的新趋势。

**Independent Test**: 读者能够理解宏的展开过程、使用 SwiftData @Model 宏、了解宏定义的基本结构。

**Acceptance Scenarios**:

1. **Given** 读者学习了 Macros 基础，**When** 需要理解宏展开，**Then** 能够使用 -dmacro-expansion 查看生成代码
2. **Given** 读者学习了 @attached 宏，**When** 需要自动生成成员，**Then** 能够理解 @Model 如何生成属性
3. **Given** 读者学习了 SwiftSyntax，**When** 需要定义自定义宏，**Then** 能够了解宏定义的 AST 操作原理

---

### User Story 17 - 掌握 Result Builders (Priority: P17)

作为需要构建 DSL 的开发者，我希望能学习 Swift Result Builders（@resultBuilder、buildBlock、buildOptional、buildEither），包括定义自定义 builder、理解 SwiftUI ViewBuilder 原理，以便创建声明式 DSL。

**Why this priority**: Result Builders 是 SwiftUI ViewBuilder 的底层机制，也是创建声明式 API 的核心工具。理解 builder 机制有助于理解 SwiftUI 和构建自定义 DSL。

**Independent Test**: 读者能够定义简单的 result builder、理解 ViewBuilder 如何组合视图、使用 builder 创建 DSL。

**Acceptance Scenarios**:

1. **Given** 读者学习了 @resultBuilder，**When** 需要定义 DSL，**Then** 能够创建 builder 组合多个值
2. **Given** 读者学习了 buildOptional，**When** 需要处理条件分支，**Then** 能够支持 if/else 语法
3. **Given** 读者学习了 ViewBuilder，**When** 需要理解 SwiftUI，**Then** 能够理解 View body 的隐式组合机制

---

### User Story 18 - 掌握 Mirror Reflection (Priority: P18)

作为需要动态分析类型结构的开发者，我希望能学习 Swift Reflection（Mirror、children、displayStyle、自定义反射），包括遍历属性、动态类型检查、反射限制，以便在调试和工具场景中使用反射。

**Why this priority**: Mirror 是 Swift 提供的轻量级反射机制，适用于调试、日志、序列化等场景。理解反射能力与限制是进阶工具开发的辅助知识。

**Independent Test**: 读者能够使用 Mirror 遍历类型属性、理解 displayStyle 区分类型类别、了解反射的性能限制。

**Acceptance Scenarios**:

1. **Given** 读者学习了 Mirror 基础，**When** 需要遍历属性，**Then** 能够使用 children 获取所有成员
2. **Given** 读者学习了 displayStyle，**When** 需要区分类型类别，**Then** 能够判断 struct/class/enum/tuple
3. **Given** 读者学习了反射限制，**When** 需要修改属性，**Then** 能够理解 Mirror 仅支持读取不支持写入

---

### Edge Cases

**Phase 1-2 (已覆盖)**:
- 读者的 macOS 版本低于 14.0，不支持 SwiftData 和部分 FileManager 新特性
- JSON 解析遇到非标准格式（如日期字符串、空值处理）
- 临时文件在进程异常终止时未能自动清理
- .env 文件不存在或格式错误
- FileManager 在 Linux 平台路径差异（无 Documents/Caches 目录）
- SwiftData ModelContainer 在内存模式与文件模式配置差异

**Phase 3 (新增)**:
- Vapor 依赖 Fluent 数据库时连接池耗尽或迁移失败
- GRDB 在 Linux 平台 SQLite 版本差异（Wal mode 支持受限）
- Actor 与 class 混用时的数据竞争（Sendable 检查失败）
- Property Wrapper 组合顺序错误导致预期值错误
- ARC 循环引用在闭包捕获 self 时隐蔽发生
- Opaque type 与 Protocol 关联类型约束冲突
- Unsafe Pointer 内存未正确释放导致泄漏
- Macro 定义在 Xcode 编译时缓存未刷新
- Result Builder 不支持复杂嵌套条件分支
- Mirror 反射大对象时的性能开销

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 系统（Docs 文档）必须为每个 Advance 模块提供独立的 mdBook 章节文件
- **FR-002**: 每个章节必须遵循 hello-rust 模板结构：开篇故事、本章适合谁、你会学到什么、前置要求、第一个例子、原理解析、常见错误、动手练习（3级）、故障排查 FAQ、小结、术语表、知识检查、继续学习

> **Note**: Constitution III specifies "12-section template". The hello-rust template uses 15 sections (adding Swift vs Rust/Python对比表 and expanded 动手练习 levels). This expansion is approved for advance content to improve cross-language learning outcomes.

- **FR-003**: 所有代码示例必须能从 `AdvanceSample/Sources/AdvanceSample/` 中对应文件编译通过
- **FR-004**: 文档必须以中文（简体）为主，Swift 专有术语需附带英文对照（如：模型宏 (@Model)、模型容器 (ModelContainer)）
- **FR-005**: SUMMARY.md 必须按照逻辑学习路径排列 Advance 章节，反映章节间的依赖关系
- **FR-006**: 每章必须包含 Swift vs Rust/Python 对比速查表（针对从 hello-rust 迁移的读者）
- **FR-007**: 每章必须包含至少 3 个可执行代码示例、至少 3 道知识检查题（带折叠答案）
- **FR-008**: 教程必须覆盖以下 Advance 模块：
  - **Phase 1 (已完成)**: JSON 处理、文件操作、SwiftData 持久化、环境配置 (4 章)
  - **Phase 2 (已完成)**: SwiftNIO 异步网络 (2 章)、系统编程 (1 章)、测试框架 (1 章)
  - **Phase 3 (新增)**:
    - **Web/Database**: Vapor Web 框架 (1 章)、GRDB SQL 数据库 (1 章)
    - **Concurrency**: Actors 并发模型 (2 章：基础 + Sendable 深入)
    - **Swift-Specific**: Property Wrappers、ARC 内存管理、Opaque Types、Unsafe Pointers、Macros、Result Builders、Mirror Reflection (7 章)
  - **总计**: 20 个 Advance 章节
- **FR-009**: `mdbook build Docs/` 必须零错误零警告通过
- **FR-010**: 每章的"常见错误"章节必须覆盖至少 3 个真实编译器错误信息或运行时错误（附修复方法）
- **FR-011**: 必须更新 `advance-overview.md` 以包含 SwiftData 章节（当前缺失）
- **FR-012**: 必须将空文件 `advance.md` 替换为完整的章节导航页或拆分为独立章节文件

### Key Entities

- **教程章节 (Tutorial Chapter)**: mdBook 中的单个 `.md` 文件，包含教学内容、代码示例、练习和测验
- **代码示例 (Code Sample)**: 位于 `AdvanceSample/Sources/AdvanceSample/` 的 Swift 源文件，对应文档中的教学示例
- **学习路径 (Learning Path)**: 章节间的逻辑顺序，定义前置知识和后续章节
- **SwiftData 模型 (SwiftData Model)**: 使用 @Model 宏定义的持久化数据类，对应 SwiftData 站点的教学示例

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Advance 部分包含 20 个完整的教程章节，每章不少于 500 个中文字符
- **SC-002**: 所有章节的代码示例 100% 能够通过 `swift build` 编译通过
- **SC-003**: `mdbook build Docs/` 零错误零警告，所有内部链接有效
- **SC-004**: 每章至少包含 3 道知识检查题（带折叠答案）和 3 个代码示例
- **SC-005**: 一个完成基础部分的读者能够在 12 小时内完成 Phase 1-2 学习（已实现），Phase 3 预计额外 8-10 小时
- **SC-006**: 文档中的"常见错误"章节覆盖至少 3 个真实错误信息（编译器或运行时）
- **SC-007**: advance-overview.md 包含完整的章节列表（含 Phase 3 所有 11 个新章节），每章节有预计时间和难度标识
- **SC-008**: Phase 2 新增源文件（SwiftNIOSample.swift、SystemSample.swift、ProcessSample.swift、TestingSample.swift）正确集成到 AdvanceSample 模块
- **SC-009**: SwiftNIO 示例代码在 macOS 和 Linux 双平台编译通过
- **SC-010**: Phase 3 新增源文件（VaporSample.swift、GRDBSample.swift、ActorSample.swift、ConcurrencyDeepSample.swift、PropertyWrapperSample.swift、ARCSample.swift、OpaqueTypeSample.swift、UnsafePointerSample.swift、MacroSample.swift、ResultBuilderSample.swift、ReflectionSample.swift）正确集成到 AdvanceSample 模块
- **SC-011**: Vapor 示例 REST API 能够通过 HTTP 请求验证（GET/POST 响应正确）
- **SC-012**: GRDB 示例 SQLite 操作能够执行 CRUD 并验证数据一致性
- **SC-013**: Actor 并发示例通过 Swift 6 严格并发检查（无 Sendability 错误）
- **SC-014**: Property Wrapper 示例能够组合多层包装并验证 projectedValue 正确工作
- **SC-015**: Unsafe Pointer 示例内存操作安全（无未定义行为或内存泄漏）

## Assumptions

- 读者已完成基础部分学习，具备 Swift 语法、控制流、函数、类/结构体、协议、错误处理基础知识
- 教程运行环境为 macOS 12.0+（Monterey）为主，SwiftData 等特性标注 macOS 14+ (Sonoma) 要求；Linux 平台部分特性受限（如 SwiftData 仅 macOS/iOS）
- 代码示例位于现有的 `AdvanceSample/Sources/AdvanceSample/` 目录下，Phase 3 新增源文件：
  - VaporSample.swift、GRDBSample.swift、ActorSample.swift、ConcurrencyDeepSample.swift
  - PropertyWrapperSample.swift、ARCSample.swift、OpaqueTypeSample.swift、UnsafePointerSample.swift
  - MacroSample.swift、ResultBuilderSample.swift、ReflectionSample.swift
- hello-rust 教程的语言风格（中文为主、emoji 标题、折叠答案、工业界场景、与其他语言对比表）将作为模板直接使用
- 教程不涉及 iOS GUI 开发内容，仅聚焦命令行和后端服务场景
- SwiftNIO 网络编程和 Swift System Package 系统编程纳入 Phase 2 扩展（已完成）
- Vapor Web 框架和 GRDB 数据库纳入 Phase 3（跨平台后端生态核心）
- Swift 6 并发深入（Actors/Sendable）纳入 Phase 3（Swift 6 严格并发检查核心特性）
- Swift 专有特性（Property Wrappers/ARC/Opaque Types/Unsafe Pointers/Macros/Result Builders/Mirror）纳入 Phase 3（Swift 语言进阶）
- SUMMARY.md 的结构参照 hello-rust 的层级化组织方式（含难度和预计时间）
- XCTest 测试章节以最小覆盖为目标（1 章），不深入 Mock/Stub 或 CI/CD 集成
