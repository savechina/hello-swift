# Swift Macros

## 开篇故事

想象你有一个机器人助手，每天早晨帮你准备咖啡。你不需要每次都告诉它"拿杯子、倒水、加咖啡粉、启动机器"——你只需要说"准备咖啡"，机器人自动完成所有步骤。

Swift Macros 就是这个机器人：你写一行代码，编译器在编译时自动生成大量重复代码。

## 本章适合谁

- 使用 SwiftData、Observation 等框架的开发者
- 想减少重复代码（boilerplate）的工程师
- 对编译时代码生成感兴趣的进阶开发者

## 你会学到什么

- `@attached` 和 `@freestanding` 宏的区别
- 使用 `-Xfrontend -dump-macro-expansions` 查看宏展开
- SwiftData `@Model` 宏的工作原理
- SwiftSyntax 在宏实现中的角色

## 前置要求

- macOS 12+ / Linux
- Swift 6.0+
- 已完成 Property Wrappers 章节

## 第一个例子

```swift
import Foundation

struct TodoItem: Codable, Equatable {
    var title: String
    var completed: Bool = false
    var createdAt: Date = Date()
}

var todo = TodoItem(title: "Learn Swift Macros")
print("Todo: \(todo.title), completed: \(todo.completed)")

todo.completed = true
print("Updated: \(todo.title), completed: \(todo.completed)")
```

`Codable` 和 `Equatable` 本身就是编译器内置的宏——你声明遵循协议，编译器自动生成 `encode/decode` 和 `==` 方法。

## 原理解析

### 宏的分类

| 类型 | 语法 | 示例 | 用途 |
|------|------|------|------|
| `@attached` | `@Model` | SwiftData 模型 | 附加到已有类型上，添加成员 |
| `@freestanding` | `#selector` | Objective-C 选择器 | 独立表达式，不依赖类型 |

### @Model 宏展开

```swift
// 你写的代码
@Model
class TodoItem {
    var title: String
    var completed: Bool = false
}

// 编译器自动生成（简化版）
class TodoItem {
    var title: String
    var completed: Bool = false
    
    // @Model 自动生成的代码
    static var all: FetchDescriptor<TodoItem> { FetchDescriptor<TodoItem>() }
    var persistentModelID: PersistentIdentifier { get }
}
```

### 查看宏展开

```bash
# 查看宏生成的代码
swift build -Xfrontend -dump-macro-expansions
```

### SwiftSyntax

宏的实现基于 SwiftSyntax 库，它提供 AST（抽象语法树）操作能力：

```swift
// 宏实现的基本流程
// 1. 解析输入类型的 AST
// 2. 生成新的语法节点
// 3. 返回扩展后的代码
```

## 常见错误

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| `Macro expansion failed` | 宏定义与使用不匹配 | 检查宏的适用范围（class/struct） |
| Xcode 缓存未刷新 | 宏定义修改后 IDE 未重新展开 | Clean Build Folder (⇧⌘K) |
| `@Model` 类没有无参初始化器 | SwiftData 要求默认构造 | 为所有属性提供默认值 |

## Swift vs Rust/Python 对比

| Swift | Rust | Python |
|-------|------|--------|
| `@Model` (attached macro) | `#[derive(Model)]` (proc_macro) | `@dataclass` (decorator) |
| `#warning` (freestanding) | `compile_error!` | 无直接等价（运行时装饰器） |
| 编译时展开 | 编译时展开 | 运行时执行 |

## 动手练习 Level 1

创建一个遵循 `Codable` 和 `CustomStringConvertible` 的 `Book` 结构体，包含 `title`、`author`、`year` 属性。

```swift
struct Book: Codable, CustomStringConvertible {
    // 你的代码
}
```

## 动手练习 Level 2

使用 `#file` 和 `#line` 内置宏创建一个简单的日志函数，自动输出文件名和行号。

```swift
func log(_ message: String, file: String = #file, line: Int = #line) {
    // 你的代码
}
```

## 动手练习 Level 3

构建一个 `@Observable` 风格的属性包装器，当属性变化时自动打印通知。

<details>
<summary>点击查看答案</summary>

```swift
@propertyWrapper
struct Observable<Value> {
    var wrappedValue: Value {
        didSet {
            print("🔔 Property changed from \(oldValue) to \(wrappedValue)")
        }
    }
    
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

class Settings {
    @Observable var volume: Int = 50
    @Observable var brightness: Double = 0.8
}

let settings = Settings()
settings.volume = 70     // 🔔 Property changed from 50 to 70
settings.brightness = 1.0 // 🔔 Property changed from 0.8 to 1.0
```

</details>

## 故障排查 FAQ

**Q: 宏和属性包装器有什么区别？**
A: 属性包装器在运行时起作用（包装属性的 get/set）；宏在编译时起作用（生成代码）。

**Q: 自定义宏需要什么条件？**
A: 需要单独的宏目标（macro target），依赖 SwiftSyntax 库，在 Xcode 15+ 或 Swift 5.9+ 中使用。

**Q: `@Model` 和 `@Observable` 有什么区别？**
A: `@Model` 用于 SwiftData 持久化；`@Observable` 用于 SwiftUI 状态观察。两者都是 attached macro。

**Q: 宏会影响编译速度吗？**
A: 会。每个宏展开都需要额外的编译时间。大型项目中大量使用宏可能增加 10-20% 编译时间。

**Q: 如何调试宏生成的代码？**
A: 使用 `swift build -Xfrontend -dump-macro-expansions` 查看展开结果，或在 Xcode 中右键 → "Expand Macro"。

## 小结

- Macros 在编译时生成代码，减少手写重复代码
- `@attached` 附加到类型上，`@freestanding` 独立使用
- `Codable`、`Equatable`、`@Model` 都是宏的实际应用
- 使用 `-dump-macro-expansions` 可以查看宏生成的代码

## 术语表

| 中文 | 英文 | 说明 |
|------|------|------|
| 宏 | Macro | 编译时代码生成机制 |
| 附加宏 | Attached Macro | 附加到已有类型上的宏 |
| 独立宏 | Freestanding Macro | 不依赖类型的独立表达式 |
| 抽象语法树 | AST | 代码的结构化表示 |
| 宏展开 | Macro Expansion | 编译器将宏替换为实际代码的过程 |

## 知识检查

1. `@Model` 是 attached macro 还是 freestanding macro？为什么？
2. 如何查看 Swift 宏展开后的代码？
3. 宏和属性包装器的执行时机有什么不同？

<details>
<summary>点击查看答案与解析</summary>

1. `@Model` 是 attached macro，因为它附加到 class 上，自动生成 `persistentModelID` 等成员。
2. 使用 `swift build -Xfrontend -dump-macro-expansions` 或在 Xcode 中右键选择 "Expand Macro"。
3. 宏在编译时执行（生成代码）；属性包装器在运行时执行（包装属性访问）。

</details>

## 继续学习

**下一章**: [Result Builders](result-builders.md) — 构建声明式 DSL

**返回**: [Advance 概览](advance-overview.md)
