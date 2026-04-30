# Feature Specification: Swift Basic Tutorial Content Generation

**Feature Branch**: `001-swift-basic-tutorials`
**Created**: 2026-04-26
**Status**: Draft
**Input**: User description: hello swift basic 参考 ../hello-rust/docs/src 语言风格及教程模板，生成swift 的教程 各个模块内容

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 学习 Swift 基础语法 (Priority: P1)

作为 Swift 编程初学者，我希望能通过结构化的中文教程学习 Swift 基础语法（变量、数据类型、控制流、函数等），每章包含真实可运行的代码示例、常见错误排查和动手练习，使我能循序渐进地掌握 Swift 编程。

**Why this priority**: 这是整个教程的核心价值主张——帮助初学者从零掌握 Swift。没有这部分内容，教程就没有存在的意义。

**Independent Test**: 学完基础部分后，读者可以独立编写包含变量声明、条件判断、循环、函数定义的 Swift 程序，并通过 `swift build` 编译运行。

**Acceptance Scenarios**:

1. **Given** 读者没有任何 Swift 经验，**When** 按照教程顺序学习变量与表达式章节，**Then** 能够独立写出声明常量/变量、字符串插值的代码并编译通过
2. **Given** 读者掌握了变量和类型，**When** 学习控制流章节，**Then** 能够使用 if/else、switch、for-in 编写条件判断和循环程序
3. **Given** 读者完成了基础部分所有章节，**Then** 能够通过 `swift test` 运行所有随附的测试代码

---

### User Story 2 - 理解 Swift 类型系统 (Priority: P2)

作为有其它语言经验的开发者，我希望能深入理解 Swift 的类型系统（枚举关联值、结构体与类的区别、面向协议编程、泛型），以便编写类型安全、可复用的代码。

**Why this priority**: Swift 的类型系统是其核心特色，区别于 Rust 的"所有权"，Swift 强调"面向协议编程"和"值语义"。这是中高级用户的核心需求。

**Independent Test**: 读者能够使用枚举建模状态机、使用协议定义接口、使用泛型编写通用函数。

**Acceptance Scenarios**:

1. **Given** 读者学习了枚举章节，**When** 阅读关联值示例，**Then** 能够使用枚举+associated value 建模多状态（如 Result<Success, Error>）
2. **Given** 读者学习了结构体和类，**Then** 能解释值类型与引用类型的区别并正确选择

---

### User Story 3 - 掌握 Swift 并发编程 (Priority: P3)

作为需要编写现代异步代码的开发者，我希望能学习 Swift 6.0 的并发特性（async/await、Actor、Task、TaskGroup），以便编写无数据竞争的并发程序。

**Why this priority**: Swift 6.0 引入了 Strict Concurrency 作为编译时保障，这是当前 Swift 开发者最关键的新特性之一。

**Independent Test**: 读者能使用 async/await 改造回调代码、使用 Actor 保护共享状态、使用 TaskGroup 并行处理。

**Acceptance Scenarios**:

1. **Given** 读者学习了并发基础，**When** 阅读 async/await 示例，**Then** 能够将基于闭包的异步代码改写为 async/await 风格
2. **Given** 读者学习 Sendable 约束，**Then** 能识别并修复跨越并发边界的非 Sendable 类型编译错误

---

### Edge Cases

- 读者的 macOS / Xcode 版本过低，不支持 Swift 6.0 Strict Concurrency 特性
- 教程中使用的第三方依赖（swift-log、swift-argument-parser）版本更新导致 API 变化
- 不同平台（macOS / Linux）对部分 Swift 标准库 API 支持不一致
- 部分教程章节对应的代码示例尚未在 BasicSample 中实现

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 系统（Docs 文档）必须为每一个 Swift 基础模块提供独立的 mdBook 章节文件
- **FR-002**: 每个章节必须包含：开篇故事/场景引入、你会学到什么、前置要求、第一个可运行代码示例、原理解析、常见错误与修复、动手练习、知识检查、术语表
- **FR-003**: 所有代码示例必须能从 `Sources/BasicSample/` 中对应文件编译通过
- **FR-004**: 文档必须以中文（简体）为主，Swift 专有术语需附带英文对照（如：选项类型 (Optional)、协议 (Protocol)）
- **FR-005**: SUMMARY.md 必须按照逻辑学习路径排列所有章节，并反映章节间的依赖关系（前置→后续）
- **FR-006**: 文档风格必须与 hello-rust 教程保持一致：使用 emoji 分隔标题层级、包含 `<details>` 折叠答案、提供"工业界应用"场景、每章末尾有知识检查和延伸阅读
- **FR-007**: 每个基础模块必须包含至少 3 个可执行代码示例、至少 3 道知识检查题
- **FR-008**: 每章必须包含"与其他语言对比"的速查表（针对从 hello-rust 迁移的读者）
- **FR-009**: 教程必须覆盖以下 12 个基础模块：变量与表达式、基础数据类型、控制流、函数、枚举、结构体、类与对象、协议、泛型、错误处理、闭包、并发编程
- **FR-010**: `mdbook build Docs/` 必须零错误零警告通过

### Key Entities

- **教程章节 (Tutorial Chapter)**: mdBook 中的单个 `.md` 文件，包含教学内容、代码示例、练习和测验
- **代码示例 (Code Sample)**: 位于 `Sources/BasicSample/` 的 Swift 源文件，对应文档中的教学示例
- **学习路径 (Learning Path)**: 章节间的逻辑顺序，定义前置知识和后续章节

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 基础部分包含至少 12 个完整的教程章节，每章不少于 500 个中文字符
- **SC-002**: 所有章节的代码示例 100% 能够通过 `swift build` 编译通过
- **SC-003**: `mdbook build Docs/` 零错误零警告，所有内部链接有效
- **SC-004**: 每章至少包含 3 道知识检查题（带折叠答案）和 3 个代码示例
- **SC-005**: 一个无 Swift 经验的初学者能够在 8 小时内完成基础部分学习（按每章预计时间累加）
- **SC-006**: 文档中的"常见错误"章节覆盖至少 3 个真实编译器错误信息（附修复方法）

## Assumptions

- 读者具备基本编程概念（变量、循环、函数），不假设任何 Swift 经验
- 教程运行环境为 macOS 或 Linux，具备 Swift 6.0+ 工具链
- 代码示例位于现有的 `Sources/BasicSample/` 目录下，不创建新的模块
- hello-rust 教程的语言风格（中文为主、emoji 标题、折叠答案、工业界场景、与其他语言对比表）将作为模板直接使用
- 教程不涉及 GUI / iOS 开发内容，仅聚焦命令行和基础语法
- SUMMARY.md 的结构参照 hello-rust 的层级化组织方式（含难度和预计时间）
