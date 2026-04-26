# 变量与表达式

## 开篇故事

想象你有一个工具箱，里面装着各种工具：螺丝刀、锤子、尺子。你给每个工具贴上标签，下一次需要时就知道去哪里找。Swift 中的**变量**就像这些贴标签的工具箱 - 它们帮你存储和管理程序中的数据。**表达式**则是你使用这些工具完成的工作。

在 Swift 中，变量声明有一个非常特别的设计：默认情况下，所有变量都是**不可变**的。这就像你写在纸上的数字 - 写完后就不能改变。如果你想改，需要重新写一张纸。这个设计让代码更安全、更容易理解。

---

## 本章适合谁

如果你是 Swift 初学者，想理解如何存储数据、进行计算和控制程序流程，本章适合你。这是所有编程的基础，即使你是第一次接触编程也能理解。

---

## 你会学到什么

完成本章后，你可以：

1. 使用 `let` 关键字声明不可变变量
2. 使用 `var` 关键字声明可变变量
3. 理解 Swift 类型推断机制
4. 使用字符串插值构建动态文本
5. 区分常量 (let) 和变量 (var) 的使用场景

---

## 前置要求

本章是 Swift 的第一章，不需要任何前置知识。

---

## 第一个例子

让我们从最简单的变量声明开始。打开 `Sources/BasicSample/ExpressionSample.swift`，找到以下代码：

```swift
let name = "Swift"
let version = "6.0"
print("Hello, \(name) \(version)!")
```

**发生了什么？**

- `let name = "Swift"` - 声明一个不可变常量，值为 "Swift"
- `let version = "6.0"` - 声明另一个常量
- `\(name)` - 字符串插值，将变量值嵌入字符串

**输出**:
```
Hello, Swift 6.0!
```

---

## 原理解析

### 1. 不可变变量 (let)

Swift 默认让变量不可变：

```swift
let x = 5
// x = 6  // ❌ 编译错误！x 是不可变的
```

**为什么 Swift 要这样设计？**

1. **安全性**：防止意外的数据修改
2. **并发安全**：不可变数据可以安全地在线程间共享
3. **编译器优化**：不可变值让编译器能做更多优化

**类比**：
> 就像你写在纸上的数字 - 写完后就不能改变。如果你想改，需要拿一张新纸重写。

### 2. 可变变量 (var)

当你需要修改变量时，使用 `var`：

```swift
var counter = 0
counter = 1  // ✅ 可以修改
counter += 1 // ✅ 也可以这样累加
```

**注意**：只在需要修改时使用 `var`，这是 Swift 的最佳实践。

### 3. 类型推断 vs 显式类型

Swift 会自动推断类型：

```swift
let inferred = 42        // Int
let explicit: Double = 3.14  // 显式指定 Double
let message = "Hello"    // String
```

**何时需要显式类型？**
- 编译器无法推断时
- 你想覆盖默认推断（如 `Int` → `Double`）
- 提高代码可读性

### 4. 字符串插值

```swift
let name = "Alice"
let age = 30
print("\(name) is \(age) years old")
// 输出: Alice is 30 years old

// 插值中可以写表达式
print("Next year, \(name) will be \(age + 1)")
// 输出: Next year, Alice will be 31
```

### 5. 变量遮蔽 (Shadowing)

Swift 允许在嵌套作用域中重新声明同名变量：

```swift
let x = 5
if true {
    let x = 10  // 新 x 遮蔽了旧 x
    print("Inside: \(x)")  // 10
}
print("Outside: \(x)")  // 5
```

---

## 常见错误

### 错误 1: 试图修改 let 声明的常量

```swift
let maxCount = 100
maxCount = 200 // ❌ 编译错误！
```

**编译器输出**:
```
error: cannot assign to value: 'maxCount' is a 'let' constant
```

**修复方法**：
```swift
var maxCount = 100
maxCount = 200 // ✅ 使用 var
```

### 错误 2: 类型不匹配

```swift
let number: Int = 3.14 // ❌ 编译错误！
```

**编译器输出**:
```
error: cannot convert value of type 'Double' to specified type 'Int'
```

**修复方法**：
```swift
let number: Double = 3.14 // ✅ 类型匹配
```

### 错误 3: 未初始化就使用

```swift
let value: Int
print(value) // ❌ 编译错误！
```

**修复方法**：
```swift
let value: Int = 0 // ✅ 声明时初始化
```

---

## Swift vs Rust/Python 对比

| 概念         | Python               | Rust                   | Swift                    | 关键差异                  |
| ------------ | -------------------- | ---------------------- | ------------------------ | ------------------------- |
| 不可变声明   | 无（约定用大写）     | `let x = 5`            | `let x = 5`              | Swift/Rust 语法一致       |
| 可变声明     | `x = 5` (总是可变)   | `let mut x = 5`        | `var x = 5`              | Swift 用 `var`，Rust 用 `mut` |
| 类型注解     | `x: int = 5`         | `let x: i32 = 5`       | `let x: Int = 5`         | Swift 首字母大写          |
| 字符串插值   | `f"{x}"`             | `format!("{x}")`       | `"\(x)"`                 | Swift 用 `\(x)`           |
| 常量关键字   | 无                   | `const` (编译时)       | `let` (运行时)           | Swift `let` 是运行时常量  |

---

## 动手练习

### 练习 1: 预测输出

不运行代码，预测下面代码的输出：

```swift
let x = 5
let y = x + 3
print("y = \(y)")
```

<details>
<summary>点击查看答案</summary>

**输出**:
```
y = 8
```

**解析**:
1. `x = 5` - 声明常量 x
2. `y = x + 3` - x + 3 = 8
3. 字符串插值输出

</details>

### 练习 2: 修复错误

下面的代码有编译错误，请修复：

```swift
let counter = 0
counter = counter + 1
print("Counter: \(counter)")
```

<details>
<summary>点击查看修复方法</summary>

**修复**:
```swift
var counter = 0  // 改用 var
counter = counter + 1
print("Counter: \(counter)")
```

**原因**: `let` 声明的常量不能被修改，需要使用 `var`。

</details>

### 练习 3: 字符串插值

使用字符串插值，打印以下信息：
- 你的名字
- 你的年龄
- 明年你的年龄

<details>
<summary>点击查看参考实现</summary>

```swift
let name = "Alice"
let age = 25
print("\(name) is \(age) years old. Next year, \(name) will be \(age + 1).")
```

</details>

---

## 故障排查 FAQ

### Q: 什么时候应该使用 `let`，什么时候应该使用 `var`？

**A**: 遵循这个原则：

- **默认使用 `let`** - 99% 的情况不需要修改
- **需要修改时使用 `var`** - 计数器、累加器、状态标志
- **可以重新声明时优先遮蔽** - 转换类型或复用名称

### Q: Swift 的 `let` 和 Rust 的 `let` 有什么区别？

**A**: 基本一致，都是默认不可变。主要区别在于：
- Swift 的 `let` 是**运行时常量**（值在运行时确定）
- Rust 的 `const` 是**编译时常量**（值在编译时确定）
- Swift 没有 Rust 的 `const` 等价物

### Q: 为什么 Swift 不像 Python 那样总是可变？

**A**: Swift 借鉴了函数式编程的理念：

- **安全性**：防止意外的数据修改
- **并发安全**：不可变数据可以在线程间安全共享
- **编译器优化**：不可变值让编译器能做更多优化

---

## 小结

**核心要点**：

1. **`let` 声明不可变常量** - 这是 Swift 的默认设置
2. **`var` 声明可变变量** - 只在需要修改时使用
3. **Swift 自动推断类型** - `let x = 5` 推断为 `Int`
4. **字符串插值用 `\(变量)`** - 在字符串中嵌入表达式
5. **变量遮蔽允许复用名称** - 在不同作用域可以重新声明

**关键术语**：

- **Constant**: 常量 (`let` 声明)
- **Variable**: 变量 (`var` 声明)
- **Type Inference**: 类型推断（编译器自动判断类型）
- **String Interpolation**: 字符串插值（`\(...)` 语法）
- **Shadowing**: 遮蔽（嵌套作用域重新声明同名变量）

---

## 术语表

| English              | 中文         |
| -------------------- | ------------ |
| Constant             | 常量         |
| Variable             | 变量         |
| Immutable            | 不可变       |
| Mutable              | 可变         |
| Type Inference       | 类型推断     |
| String Interpolation | 字符串插值   |
| Shadowing            | 遮蔽         |

---

完整示例：`Sources/BasicSample/ExpressionSample.swift`

---

## 知识检查

**问题 1** 🟢 (基础概念)

```swift
let x = 10
let y = x * 2
print(y)
```

A) 编译错误  
B) 10  
C) 20  
D) 运行时错误

<details>
<summary>答案与解析</summary>

**答案**: C) 20

**解析**: x=10, y=10*2=20。Int 类型可以直接运算。
</details>

**问题 2** 🟡 (最佳实践)

以下哪种写法更符合 Swift 风格？

```swift
// A
var name = "Alice"
// name 从不被修改

// B
let name = "Alice"
```

<details>
<summary>答案与解析</summary>

**答案**: B) `let name = "Alice"`

**解析**: 如果变量从不被修改，使用 `let` 而不是 `var`。这表达了你的意图并让编译器能做优化。

**原则**:
> 默认用 `let`，需要修改时才改用 `var`

</details>

**问题 3** 🟡 (类型推断)

```swift
let pi = 3.14159
let radius = 5
let area = pi * Double(radius)
```

`area` 的类型是什么？

<details>
<summary>答案与解析</summary>

**答案**: `Double`

**解析**: `pi` 推断为 `Double`，`Double(radius)` 将 Int 转为 Double，Double * Double = Double。

</details>

---

## 延伸阅读

学习完变量与表达式后，你可能还想了解：

- [Swift 官方文档 - The Basics](https://docs.swift.org/swift-book/documentation/the-basics/) - 基础语法深入
- [Swift by Sundell - Let vs Var](https://www.swiftbysundell.com/) - 最佳实践

**选择建议**:
- 初学者 → 继续学习 [基础数据类型](datatype.md)
- 有经验的程序员 → 跳到 [控制流](control-flow.md)

> 💡 **记住**：不可变性是 Swift 的默认设置 - 如果你不特别告诉它"这个要改变"，Swift 会让它保持不变。这是为了你的安全！

---

## 继续学习

- 下一步：[基础数据类型](datatype.md) - 深入理解 Swift 类型系统
- 相关：[函数](functions.md) - 学习如何组织代码
- 进阶：[控制流](control-flow.md) - 条件判断和循环
