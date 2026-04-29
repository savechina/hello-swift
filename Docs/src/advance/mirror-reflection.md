# Mirror Reflection (Mirror 反射)

## 开篇故事

想象你有一面魔镜，照任何物体都能告诉你它的组成部分：这个杯子有把手、杯身、杯底。Swift 的 `Mirror` 就是这面魔镜——它能在运行时告诉你任何类型的结构。

但魔镜只能"看"，不能"改"。你可以知道属性名和值，但不能修改它们。

## 本章适合谁

- 需要调试和日志功能的 Swift 开发者
- 想实现序列化/反序列化的工程师
- 对 Swift 运行时类型检查感兴趣的进阶程序员

## 你会学到什么

- `Mirror(reflecting:)` 的基本用法
- `children` 遍历类型属性
- `displayStyle` 区分 struct/class/enum/tuple
- 反射的性能限制和适用场景

## 前置要求

- macOS 12+ / Linux
- Swift 6.0+
- 已完成 Result Builders 章节

## 第一个例子

```swift
struct User {
    let name: String
    var age: Int
    var email: String?
}

let user = User(name: "Alice", age: 30, email: "alice@example.com")

let mirror = Mirror(reflecting: user)
print("Type: \(mirror.displayStyle ?? .unknown)")  // struct

for child in mirror.children {
    if let label = child.label {
        print("  \(label): \(child.value)")
    }
}
// name: Alice
// age: 30
// email: alice@example.com
```

## 原理解析

### Mirror 核心属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `children` | `Children` | 子元素集合（label + value） |
| `displayStyle` | `DisplayStyle?` | 类型类别（struct/class/enum/tuple/collection/optional） |
| `subjectType` | `Any.Type` | 被反射的类型 |

### 支持 displayStyle

```swift
let status = Status.active
let statusMirror = Mirror(reflecting: status)
print("Enum: \(statusMirror.displayStyle)")  // Optional(Swift.Mirror.DisplayStyle.enum)

let tuple = (x: 10, y: 20)
let tupleMirror = Mirror(reflecting: tuple)
print("Tuple: \(tupleMirror.displayStyle)")  // Optional(Swift.Mirror.DisplayStyle.tuple)
```

### 反射的限制

- **只读**：无法通过 Mirror 修改属性值
- **性能**：反射比直接访问慢 10-100 倍
- **不递归**：`children` 只返回直接子元素，不深入嵌套

## 常见错误

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| `child.label` 为 nil | 某些类型（如 tuple）的 label 可能为空 | 使用 `child.label ?? "unknown"` |
| 反射大对象性能差 | Mirror 遍历所有属性 | 限制反射深度或使用自定义序列化 |
| 尝试修改反射值 | Mirror 是只读的 | 使用 KeyPath 或自定义协议 |

## Swift vs Rust/Python 对比

| Swift | Rust | Python |
|-------|------|--------|
| `Mirror(reflecting:)` | `std::any::type_name` | `inspect.getmembers()` |
| 只读反射 | 有限反射（无运行时类型信息） | 完整反射（可读写） |
| 编译期类型信息 | 编译期擦除 | 运行时完整类型信息 |

## 动手练习 Level 1

使用 Mirror 反射一个 `Point(x: 3, y: 4)` 结构体，打印所有属性名和值。

```swift
struct Point {
    let x: Int
    let y: Int
}
// 你的代码
```

## 动手练习 Level 2

创建一个 `describe(_ object: Any) -> String` 函数，使用 Mirror 生成对象的可读描述。

```swift
func describe(_ object: Any) -> String {
    // 使用 Mirror 生成类似 "TypeName(prop1: value1, prop2: value2)" 的字符串
}
```

## 动手练习 Level 3

构建一个简单的 JSON 序列化器，使用 Mirror 将任意结构体转换为 JSON 字符串（仅支持 String、Int、Double、Bool）。

<details>
<summary>点击查看答案</summary>

```swift
func toJson(_ object: Any) -> String {
    let mirror = Mirror(reflecting: object)
    var pairs: [String] = []
    
    for child in mirror.children {
        guard let label = child.label else { continue }
        
        let valueStr: String
        switch child.value {
        case let s as String:
            valueStr = "\"\(s)\""
        case let i as Int:
            valueStr = "\(i)"
        case let d as Double:
            valueStr = "\(d)"
        case let b as Bool:
            valueStr = b ? "true" : "false"
        default:
            valueStr = "\"\(child.value)\""
        }
        pairs.append("\"\(label)\": \(valueStr)")
    }
    
    return "{\(pairs.joined(separator: ", "))}"
}

struct Product {
    let name: String
    let price: Double
    let inStock: Bool
}

let product = Product(name: "Swift Book", price: 29.99, inStock: true)
print(toJson(product))
// {"name": "Swift Book", "price": 29.99, "inStock": true}
```

</details>

## 故障排查 FAQ

**Q: Mirror 能修改属性值吗？**
A: 不能。Mirror 是只读的。如果需要读写，使用 `WritableKeyPath` 或自定义协议。

**Q: 反射的性能影响有多大？**
A: 比直接属性访问慢 10-100 倍。在 hot path 中避免使用。调试和序列化场景可接受。

**Q: Mirror 能反射 private 属性吗？**
A: 可以。Mirror 不受访问控制限制，能看到所有属性。

**Q: 如何限制反射深度（避免无限递归）？**
A: 在递归函数中添加 `depth` 参数，超过阈值时停止。

**Q: Mirror 支持泛型类型吗？**
A: 支持。`Mirror(reflecting:)` 接受 `Any`，泛型实例会被正确反射。

## 小结

- `Mirror` 提供运行时类型检查能力，适用于调试和序列化
- `children` 遍历属性，`displayStyle` 区分类型类别
- Mirror 是只读的，性能有限，不适合 hot path
- Python 的 `inspect` 提供更完整的反射（可读写），Swift 更注重安全

## 术语表

| 中文 | 英文 | 说明 |
|------|------|------|
| 反射 | Reflection | 运行时检查类型结构的能力 |
| 显示样式 | Display Style | 类型的外观类别 |
| 子元素 | Children | 类型的直接属性集合 |
| 只读 | Read-Only | 只能读取不能修改 |

## 知识检查

1. 为什么 Mirror 的 `children` 不递归返回嵌套属性？
2. `displayStyle` 有哪些可能的值？
3. 在什么场景下应该避免使用 Mirror？

<details>
<summary>点击查看答案与解析</summary>

1. 防止无限递归（如循环引用）和性能问题。需要递归时手动调用 `Mirror(reflecting: child.value)`。
2. `.struct`、`.class`、`.enum`、`.tuple`、`.collection`、`.optional`、`.set`、`.dictionary`。
3. 性能敏感的 hot path、需要修改属性值的场景、大型对象的完整序列化（应使用 Codable）。

</details>

## 继续学习

**下一章**: 返回 [Advance 阶段回顾](review-advance.md) — 测试你学到的知识

**返回**: [Advance 概览](advance-overview.md)
