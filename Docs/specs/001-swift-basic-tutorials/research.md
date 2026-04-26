# Research & Design Decisions: Swift Basic Tutorial

**Feature**: 001-swift-basic-tutorials
**Date**: 2026-04-26

## Decision 1: Chapter Template Structure

**Decision**: Each chapter follows the hello-rust template with 12 mandatory sections:
1. 📖 开篇故事 (opening story/scenario)
2. 本章适合谁 (audience)
3. 你会学到什么 (learning objectives, 5 items)
4. 前置要求 (prerequisites with cross-links)
5. 第一个例子 (minimal working example)
6. 原理解析 (core concepts, numbered sections)
7. 常见错误 (compiler errors with output + fixes)
8. 动手练习 (3+ exercises with `<details>` answers)
9. 故障排查 FAQ (3+ Q&A)
10. 小结 + 术语表 (key points + bilingual glossary)
11. 知识检查 (3+ quiz questions with `<details>` answers)
12. 延伸阅读 (links to official docs, next chapters)

**Rationale**: This is the proven pattern from hello-rust's `expression.md` (699 lines) which provides rich, layered learning with multiple interaction points.

**Alternatives considered**:
- Minimal API-doc style: rejected — doesn't match tutorial intent
- Short-form guide: rejected — violates SC-001 (500+ chars requirement)

---

## Decision 2: Language Contrast Table Format

**Decision**: Each chapter includes a "Swift vs Rust vs Python/Java" comparison table for key concepts.

**Rationale**: Many hello-rust readers are familiar with Rust concepts (ownership, traits, lifetimes) and need Swift-equivalent understanding. Swift's POP vs Rust's trait-based generics vs Python's duck typing is a common confusion point.

**Alternatives considered**:
- Swift-only: rejected — loses value for migrating audience
- Swift vs Python only: rejected — loses Rust-to-Swift bridge

---

## Decision 3: Code Source Location

**Decision**: All inline code in docs references `Sources/BasicSample/*.swift` files. When no matching file exists (FunctionSample, EnumSample), new sample files are created first.

**Rationale**: Constitution Principle I requires "all code examples from real project code." Tutorial examples must compile via `swift build`.

---

## Decision 4: Difficulty & Time Estimates

**Decision**: Following hello-rust's difficulty system (🟢 simple, 🟡 medium, 🔴 difficult) with estimated time per chapter:

| Chapter                                | Difficulty | Time    |
| ------------------------------------- | -------- | ------- |
| 变量与表达式                            | 🟢 简单   | 30 分钟  |
| 基础数据类型                            | 🟢 简单   | 45 分钟  |
| 控制流                                  | 🟢 简单   | 30 分钟  |
| 函数                                    | 🟡 中等   | 45 分钟  |
| 枚举                                    | 🟡 中等   | 45 分钟  |
| 结构体                                  | 🟡 中等   | 45 分钟  |
| 类与对象                                | 🟡 中等   | 60 分钟  |
| 协议                                    | 🟡 中等   | 60 分钟  |
| 泛型                                    | 🟡 中等   | 45 分钟  |
| 错误处理                                | 🟡 中等   | 45 分钟  |
| 闭包                                    | 🟡 中等   | 45 分钟  |
| 并发编程                                | 🔴 困难   | 60 分钟  |

**Total**: 12 chapters, ~9 hours (within SC-005's 8-hour target if readers skip advanced sections)

---

## Decision 5: SUMMARY.md Structure

**Decision**: Hierarchical structure mirroring hello-rust, with nested sub-sections where applicable (e.g., 枚举 → associated values, raw values; 并发 → async/await, Actor, TaskGroup).

**Rationale**: Matches established navigation pattern. Readers expect the same organizational depth as hello-rust's 22-chapter basic section.

---

## Decision 6: Chinese Technical Term Translation

**Decision**: Use established Swift Chinese terminology:

| English           | 中文            |
| ----------------- | --------------- |
| Variable          | 变量            |
| Constant          | 常量            |
| Optional          | 可选类型        |
| Protocol          | 协议            |
| Struct            | 结构体          |
| Class             | 类              |
| Enum              | 枚举            |
| Closure           | 闭包            |
| Generic           | 泛型            |
| Extension         | 扩展            |
| Concurrency       | 并发            |
| Actor             | 参与者          |
| Sendable          | 可发送          |
| Async/Await       | 异步/等待       |
| Property Wrapper  | 属性包装器      |
| Access Control    | 访问控制        |
| Error Handling    | 错误处理        |
| Value Type        | 值类型          |
| Reference Type    | 引用类型        |
| Protocol-Oriented | 协议面向编程    |

**Rationale**: Matches Apple's official Swift localization and common Swift community usage in Chinese.
