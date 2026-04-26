# Feature Specification: Swift Advance Tutorial Content Generation

**Feature Branch**: `002-swift-advance-tutorials`
**Created**: 2026-04-26
**Status**: Draft
**Input**: User description: Swift advance tutorial covering JSON processing, file operations, SwiftData persistence, environment config, referencing ../hello-rust/docs/src language style and tutorial template

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

### Edge Cases

- 读者的 macOS 版本低于 14.0，不支持 SwiftData 和部分 FileManager 新特性
- JSON 解析遇到非标准格式（如日期字符串、空值处理）
- 临时文件在进程异常终止时未能自动清理
- .env 文件不存在或格式错误
- FileManager 在 Linux 平台路径差异（无 Documents/Caches 目录）
- SwiftData ModelContainer 在内存模式与文件模式配置差异

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
- **FR-008**: 教程必须覆盖以下 4 个 Advance 模块：JSON 处理、文件操作、SwiftData 持久化、环境配置
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

- **SC-001**: Advance 部分包含至少 4 个完整的教程章节，每章不少于 500 个中文字符
- **SC-002**: 所有章节的代码示例 100% 能够通过 `swift build` 编译通过
- **SC-003**: `mdbook build Docs/` 零错误零警告，所有内部链接有效
- **SC-004**: 每章至少包含 3 道知识检查题（带折叠答案）和 3 个代码示例
- **SC-005**: 一个完成基础部分的读者能够在 4 小时内完成 Advance 部分学习（按每章预计时间累加）
- **SC-006**: 文档中的"常见错误"章节覆盖至少 3 个真实错误信息（编译器或运行时）
- **SC-007**: advance-overview.md 包含完整的章节列表（含 SwiftData），每章节有预计时间和难度标识

## Assumptions

- 读者已完成基础部分学习，具备 Swift 语法、控制流、函数、类/结构体、协议、错误处理基础知识
- 教程运行环境为 macOS 14.0+（SwiftData 和部分 FileManager 特性要求），或 Linux（部分特性受限）
- 代码示例位于现有的 `AdvanceSample/Sources/AdvanceSample/` 目录下，不创建新的模块
- hello-rust 教程的语言风格（中文为主、emoji 标题、折叠答案、工业界场景、与其他语言对比表）将作为模板直接使用
- 教程不涉及 iOS GUI 开发内容，仅聚焦命令行和后端服务场景
- SwiftNIO 和 System Services 暂不纳入本教程范围（源代码未实现）
- SUMMARY.md 的结构参照 hello-rust 的层级化组织方式（含难度和预计时间）
