# Result Builders

## 开篇故事

想象你在搭积木。每次拿起一块积木，说"这块放这里"，最终搭成一座城堡。Swift 的 Result Builder 就是这种"声明式搭建"的机制——你列出组件，Builder 自动组合它们。

SwiftUI 的 `VStack { Text("Hello"); Button("Tap me") { } }` 就是 Result Builder 的经典应用。

## 本章适合谁

- 使用 SwiftUI 想理解底层原理的开发者
- 想创建声明式 DSL（领域特定语言）的工程师
- 对 Swift 高级语法特性感兴趣的进阶程序员

## 你会学到什么

- `@resultBuilder` 属性的使用方法
- `buildBlock`、`buildOptional`、`buildEither` 的作用
- 理解 SwiftUI `ViewBuilder` 的工作原理
- 创建自定义 DSL

## 前置要求

- macOS 12+ / Linux
- Swift 6.0+
- 已完成 Macros 章节

## 第一个例子

```swift
@resultBuilder
struct StringBuilder {
    static func buildBlock(_ components: String...) -> String {
        components.joined(separator: "\n")
    }
}

func buildString(@StringBuilder builder: () -> String) -> String {
    builder()
}

let result = buildString {
    "Line 1: Hello"
    "Line 2: World"
    "Line 3: Swift"
}
print(result)
// Line 1: Hello
// Line 2: World
// Line 3: Swift
```

## 原理解析

### 核心方法

| 方法 | 作用 | 对应语法 |
|------|------|----------|
| `buildBlock` | 组合多个组件 | 普通语句序列 |
| `buildOptional` | 处理可选组件 | `if` 语句 |
| `buildEither(first:)` / `buildEither(second:)` | 处理分支 | `if/else` 语句 |
| `buildArray` | 处理循环 | `for` 循环 |
| `buildExpression` | 转换单个表达式 | 每个输入值 |
| `buildFinalResult` | 最终转换 | 返回值 |

### 条件分支支持

```swift
@resultBuilder
struct StringBuilder {
    static func buildBlock(_ components: String...) -> String {
        components.joined(separator: "\n")
    }
    
    static func buildOptional(_ component: String?) -> String {
        component ?? ""
    }
    
    static func buildEither(first: String) -> String { first }
    static func buildEither(second: String) -> String { second }
}

let result = buildString {
    "Always included"
    if true {
        "Conditionally included"
    }
    if false {
        "Not included"
    } else {
        "Else branch"
    }
}
```

### SwiftUI ViewBuilder 原理

```swift
// SwiftUI 的 VStack 内部使用 ViewBuilder
VStack {
    Text("Hello")       // buildExpression
    Button("Tap") { }   // buildExpression
    if showExtra {      // buildOptional / buildEither
        Text("Extra")
    }
}
// ViewBuilder.buildBlock 组合所有 View
```

## 常见错误

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| `Static member 'buildBlock' cannot be used on instance` | 方法必须是 `static` | 确保所有 build 方法都是 `static` |
| `Type 'X' has no member 'buildEither'` | 缺少分支处理方法 | 添加 `buildEither(first:)` 和 `buildEither(second:)` |
| 嵌套条件编译失败 | 缺少 `buildOptional` 嵌套支持 | 确保 `buildOptional` 返回类型与 `buildBlock` 一致 |

## Swift vs Rust/Python 对比

| Swift | Rust | Python |
|-------|------|--------|
| `@resultBuilder` | 宏（`macro_rules!`） | 装饰器（`@decorator`） |
| `buildBlock` | 宏展开 | `__enter__`/`__exit__` (context manager) |
| 编译时组合 | 编译时展开 | 运行时执行 |

## 动手练习 Level 1

创建一个 `HTMLBuilder`，将多个 HTML 标签字符串包裹在 `<div>` 中。

```swift
@resultBuilder
struct HTMLBuilder {
    static func buildBlock(_ components: String...) -> String {
        // 你的代码
    }
}
```

## 动手练习 Level 2

扩展 `HTMLBuilder`，支持 `if` 条件（`buildOptional`）和 `if/else` 分支（`buildEither`）。

```swift
func render(@HTMLBuilder content: () -> String) -> String {
    "<html><body>" + content() + "</body></html>"
}
```

## 动手练习 Level 3

构建一个简易测试框架 DSL，支持 `test` 块和 `expect` 断言。

<details>
<summary>点击查看答案</summary>

```swift
@resultBuilder
struct TestBuilder {
    static func buildBlock(_ components: [String]...) -> [String] {
        components.flatMap { $0 }
    }
    
    static func buildOptional(_ component: [String]?) -> [String] {
        component ?? []
    }
}

func testSuite(@TestBuilder tests: () -> [String]) {
    let results = tests()
    for result in results {
        print(result)
    }
}

func test(_ name: String, _ body: () -> Bool) -> [String] {
    let passed = body()
    return ["\(passed ? "✅" : "❌") \(name)"]
}

testSuite {
    test("Addition") { 1 + 1 == 2 }
    test("String") { "hello".count == 5 }
}
```

</details>

## 故障排查 FAQ

**Q: Result Builder 和函数式编程的 `reduce` 有什么区别？**
A: Result Builder 在编译时转换语法结构（DSL），`reduce` 在运行时聚合数据。

**Q: 为什么 SwiftUI 要用 Result Builder 而不是数组？**
A: DSL 语法更自然（不需要 `[Text("A"), Button("B")]`），且支持 `if/for` 等控制流。

**Q: `buildExpression` 是必须的吗？**
A: 不是。如果输入类型和输出类型一致，可以省略。它用于在组合前转换单个表达式。

**Q: Result Builder 可以嵌套吗？**
A: 可以。一个 builder 方法可以调用另一个 builder，实现嵌套 DSL。

## 小结

- `@resultBuilder` 将声明式语法转换为函数调用
- `buildBlock` 组合、`buildOptional` 处理 `if`、`buildEither` 处理 `if/else`
- SwiftUI 的 `ViewBuilder` 是 Result Builder 最重要的实际应用
- 自定义 Builder 可以创建领域特定语言（DSL）

## 术语表

| 中文 | 英文 | 说明 |
|------|------|------|
| 结果构建器 | Result Builder | 将声明式语法转换为函数调用的机制 |
| 声明式 | Declarative | 描述"做什么"而非"怎么做" |
| 领域特定语言 | DSL | 针对特定领域设计的简洁语法 |
| 构建块 | Build Block | 组合多个组件的核心方法 |

## 知识检查

1. `buildOptional` 和 `buildEither` 分别对应什么 Swift 语法？
2. 为什么 `buildBlock` 的参数是 `...`（variadic）？
3. SwiftUI 的 `ViewBuilder` 如何处理 `ForEach` 循环？

<details>
<summary>点击查看答案与解析</summary>

1. `buildOptional` 对应 `if`（无条件分支），`buildEither` 对应 `if/else`（二选一分支）。
2. Variadic 参数允许接收任意数量的组件，实现灵活的组件组合。
3. `ViewBuilder` 通过 `buildArray` 方法处理 `ForEach`，将多个 View 数组元素组合为单一 View。

</details>

## 继续学习

**下一章**: [Mirror Reflection](mirror-reflection.md) — 运行时类型检查

**返回**: [Advance 概览](advance-overview.md)
