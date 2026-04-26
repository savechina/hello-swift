# 函数

## 开篇故事

想象你在一家餐厅工作。顾客点菜后，厨房里的厨师按照固定配方烹饪，然后把完整的菜品端上桌。每个配方就是一个**函数**：它接收食材（输入），经过一系列步骤加工，最后产出菜品（输出）。

在编程中，函数让你把重复的逻辑封装成可复用的"配方"。当你需要同一道菜时，不需要重新发明配方，只需要调用它即可。Swift 的函数设计兼具灵活性和安全性，让你可以自由组合参数与返回值。

---

## 本章适合谁

如果你希望学会如何组织代码、减少重复、写出可读性强的程序，本章适合你。无论你是第一次写函数，还是从其他语言转来学习 Swift 的函数特性，本章都会帮你快速上手。

---

## 你会学到什么

完成本章后，你可以：

1. 使用 `func` 关键字定义和调用函数
2. 理解外部参数名（external name）和省略符 `_` 的使用
3. 为参数设置默认值，声明可变参数列表
4. 使用 `inout` 参数和元组实现多返回值
5. 把函数当作值传递，包括嵌套函数和闭包返回

---

## 前置要求

本章前置知识：阅读过 [变量与表达式](expression.md)，熟悉 `let`、`var` 和基本类型。

---

## 第一个例子

打开 `Sources/BasicSample/FunctionSample.swift`，找到最简单的函数定义：

```swift
func greet(person: String, from location: String) -> String {
    "Hello \(person)! I'm from \(location)."
}

print(greet(person: "Alice", from: "Beijing"))
// 输出: Hello Alice! I'm from Beijing.
```

**发生了什么？**

- `func greet(person: String, from location: String)` — 定义函数，参数名前面带有一个标签
- `-> String` — 指定返回类型为 `String`
- 最后一行隐式返回结果（省略了 `return` 关键字）

---

## 原理解析

### 1. 参数标签与外部名称

Swift 函数参数的默认行为是每个参数都有一个**外部名称**（标签），调用时必须使用：

```swift
func greet(person: String, from location: String) -> String {
    "Hello \(person) from \(location)"
}

// 调用时必须带上标签
greet(person: "Alice", from: "Beijing")
```

这让调用代码像句子一样可读。如果你希望调用时不需要标签，用 `_` 来省略：

```swift
func sum(_ a: Int, _ b: Int) -> Int {
    a + b
}

sum(3, 5)  // 不需要标签
```

### 2. 默认参数值

Swift 允许为参数设置默认值，调用时可以直接省略：

```swift
func greet(person: String, greeting: String = "Hello") -> String {
    "\(greeting), \(person)!"
}

print(greet(person: "Bob"))                      // Hello, Bob!
print(greet(person: "Charlie", greeting: "Hi"))  // Hi, Charlie!
```

**注意**：默认值让函数调用更灵活，但带默认值的参数通常放在参数列表末尾。

### 3. 可变参数（Variadic Parameters）

当参数数量不确定时，使用 `...` 来声明可变参数：

```swift
func arithmeticMean(_ numbers: Double...) -> Double {
    let total = numbers.reduce(0, +)
    return total / Double(numbers.count)
}

arithmeticMean(1, 2, 3, 4, 5)      // 3.0
arithmeticMean(3.0, 8.25, 18.75)   // 10.0
```

函数内部，`numbers` 是一个 `Array<Double>`，你可以对它做任何数组操作。

### 4. In-out 参数

默认情况下，函数参数是值传递（只读副本）。如果你需要在函数内部修改传入的变量，使用 `inout`：

```swift
func swapTwoInts(_ a: inout Int, _ b: inout Int) {
    let temp = a
    a = b
    b = temp
}

var x = 3
var y = 107
swapTwoInts(&x, &y)
print("After: x=\(x), y=\(y)")  // x=107, y=3
```

关键点：
- 函数定义里参数标记 `inout`
- 调用时变量前面加 `&`，表明地址传递
- 传入的必须是有实际内存位置的 `var`，不能是 `let`

### 5. 多返回值：元组

Swift 允许函数返回多个值，使用元组（tuple）：

```swift
func minMax(array: [Int]) -> (min: Int, max: Int)? {
    guard !array.isEmpty else { return nil }
    var currentMin = array[0]
    var currentMax = array[0]
    for value in array.dropFirst() {
        if value < currentMin { currentMin = value }
        else if value > currentMax { currentMax = value }
    }
    return (currentMin, currentMax)
}

if let bounds = minMax(array: [8, -6, 2, 109, 3, 71]) {
    print("Min: \(bounds.min), Max: \(bounds.max)")
}
// 输出: Min: -6, Max: 109
```

返回类型 `(min: Int, max: Int)?` 中，`?` 表示可选的元组（可能返回 `nil`）。通过 `bounds.min` 和 `bounds.max` 可以按名称访问元素。

### 6. 函数作为值和嵌套函数

Swift 中函数也是值，可以赋值给变量、作为返回值：

```swift
func makeIncrementer(forIncrement amount: Int) -> () -> Int {
    var runningTotal = 0
    func incrementer() -> Int {
        runningTotal += amount
        return runningTotal
    }
    return incrementer
}

let incrementByTen = makeIncrementer(forIncrement: 10)
print(incrementByTen())  // 10
print(incrementByTen())  // 20
print(incrementByTen())  // 30
```

`makeIncrementer` 返回一个内部定义的函数，每次调用都会累加。这是闭包（closure）的基础概念，在后续章节还会继续深入。

---

## 常见错误

### 错误 1: 忘记参数标签

```swift
func greet(person: String, from location: String) -> String {
    "Hi \(person) from \(location)"
}

greet("Alice", "Beijing")  // ❌
```

**编译器输出**:

```
error: missing argument labels 'person:from:' in call
```

**修复方法**:

```swift
greet(person: "Alice", from: "Beijing")  // ✅ 补充标签
```

### 错误 2: inout 参数传入了不可变的 let

```swift
func swapTwoInts(_ a: inout Int, _ b: inout Int) { /* ... */ }

let x = 3, y = 5
swapTwoInts(&x, &y)  // ❌
```

**编译器输出**:

```
error: cannot pass immutable value as inout argument: 'x' is a 'let' constant
```

**修复方法**:

```swift
var x = 3, y = 5  // 改为 var
swapTwoInts(&x, &y)  // ✅
```

### 错误 3: 可变参数后面不能有其他参数

```swift
func bad(_ numbers: Double..., extra: String) -> Void { }  // ❌
```

**编译器输出**:

```
error: a parameter may not be marked inout or followed by a parameter that is marked inout, or marked with the ellipsis ('...')
```

**修复方法**:

```swift
func correct(extra: String, _ numbers: Double...) -> Void { }  // 把 ... 放最后
```

---

## Swift vs Rust/Python 对比

| 概念 | Python | Rust | Swift | 关键差异 |
|---|---|---|---|---|
| 函数定义 | `def name(x):` | `fn name(x: Type) -> Ret` | `func name(x: Type) -> Ret` | Swift/Rust 返回类型用箭头 |
| 参数标签 | 无，位置参数 | 无 | `func name(label param: Type)` | Swift 默认有外部标签 |
| 省略标签 | `*args` | N/A | `_` 前缀 | Swift 用 `_` 隐藏外部名 |
| 默认参数 | `def f(x=1):` | 无（用 builder 模式） | `func f(x: Int = 1)` | Rust 不支持直接写默认值 |
| 可变参数 | `*args` | 通过宏 `println!` 等 | `...` 后缀 | Rust 使用不同的范式 |
| In-out 参数 | 无（只能返回新值） | `&mut` 引用 | `inout` + `&` 调用 | Swift 的 inout 语义最明确 |
| 多返回值 | `return (a, b)`（元组） | `(a, b)`（元组） | `(a: T, b: U)`（命名元组） | Swift 元组可以命名元素 |
| 函数作为值 | `f = lambda x: x` | 闭包 `|x| x` | `func` 定义 或闭包 `{ x in x }` | 三者都支持一等函数 |

---

## 动手练习

### 练习 1: 预测输出

不运行代码，预测下面代码的输出：

```swift
func multiply(_ a: Int, _ b: Int) -> Int {
    a * b
}

let result = multiply(7, 6)
print("Result: \(result)")
```

<details>
<summary>点击查看答案</summary>

**输出**:

```
Result: 42
```

**解析**: `multiply(7, 6)` 计算 7 乘 6，结果为 42。

</details>

### 练习 2: 写一个带默认参数的函数

写一个名为 `describe` 的函数，接收姓名（person）和爱好（hobby），其中 hobby 有默认值 `"reading"`。调用时只用传姓名。

<details>
<summary>点击查看参考实现</summary>

```swift
func describe(person: String, hobby: String = "reading") -> String {
    "\(person) enjoys \(hobby)."
}

print(describe(person: "Alice"))                     // Alice enjoys reading.
print(describe(person: "Bob", hobby: "swimming"))    // Bob enjoys swimming.
```

</details>

### 练习 3: In-out 实现翻倍函数

写一个 `inout` 函数 `doubleInPlace(_ value: inout Int)`，把传入的整数值翻一倍。

<details>
<summary>点击查看参考实现</summary>

```swift
func doubleInPlace(_ value: inout Int) {
    value = value * 2
}

var number = 21
doubleInPlace(&number)
print(number)  // 42
```

</details>

---

## 故障排查 FAQ

### Q: Swift 的函数参数为什么默认有外部标签？

**A**: 让调用代码像自然语言一样可读：

```swift
greet(person: "Alice", from: "Beijing")
```

这句话本身就像英文句子。如果你觉得干扰，可以用 `_` 省略，但通常建议在语义不清晰时保留标签。

### Q: `inout` 和直接返回新值有什么区别？

**A**: 语义层面，`inout` 表示"修改已有状态"，适合交换、累加等场景。返回新值的方式更函数式，Swift 通常更推荐后者。两者性能差异在现代 Swift 编译器中几乎可以忽略。

### Q: 函数可以返回多个值吗？

**A**: 可以，使用元组。元组不仅返回多个值，还可以给每个元素命名，调用后用 `.元素名` 访问，非常直观。

---

## 小结

**核心要点**:

1. **`func` 定义函数** — 参数带外部标签（或用 `_` 省略），`-> Type` 指定返回类型
2. **默认参数值** — 用 `= defaultValue` 提供可选参数
3. **可变参数 `...`** — 接受任意数量同类型参数，内部以数组形式访问
4. **`inout` 参数** — 用 `&` 传入 `var` 变量，在函数内可以修改原始值
5. **元组返回多值** — `(min: Int, max: Int)` 让返回结果自带名称

**关键术语**:

- **Function**: 函数（用 `func` 定义的可复用代码块）
- **Parameter Label**: 参数标签（调用时使用的外部名称）
- **Default Parameter Value**: 默认参数值（调用时可选）
- **Variadic Parameter**: 可变参数（`...` 语法）
- **In-out Parameter**: 输入输出参数（允许修改传入变量）
- **Tuple**: 元组（组合多个值的轻量结构）

---

## 术语表

| English | 中文 |
|---|---|
| Function | 函数 |
| Parameter Label | 参数标签 |
| External Name | 外部名称 |
| Default Parameter Value | 默认参数值 |
| Variadic Parameter | 可变参数 |
| In-out Parameter | 输入输出参数 |
| Tuple | 元组 |
| Nested Function | 嵌套函数 |
| Closure | 闭包 |
| Return Type | 返回类型 |

完整示例：`Sources/BasicSample/FunctionSample.swift`

---

## 知识检查

**问题 1** 🟢（基础概念）

```swift
func add(_ a: Int, _ b: Int) -> Int { a + b }
let result = add(10, 32)
```

`result` 的值是多少？

A) `"1032"`
B) `42`
C) 编译报错
D) 运行时错误

<details>
<summary>答案与解析</summary>

**答案**: B) `42`

**解析**: 两个 Int 相加，10 + 32 = 42。参数使用 `_` 省略外部标签，直接传值即可。
</details>

**问题 2** 🟡（参数标签）

下面哪个调用是正确的？

```swift
func connect(to host: String, port: Int) { }
```

A) `connect("localhost", 8080)`
B) `connect(to: "localhost", port: 8080)`
C) `connect(host: "localhost", port: 8080)`

<details>
<summary>答案与解析</summary>

**答案**: B) `connect(to: "localhost", port: 8080)`

**解析**: Swift 中参数标签是 `to` 和 `port`，调用时必须使用对应标签。注意参数名称和本地标签可以不同。
</details>

**问题 3** 🔴（进阶理解）

```swift
func makeCounter() -> () -> Int {
    var count = 0
    return { count += 1; return count }
}

let counter = makeCounter()
print(counter(), counter(), counter())
```

输出是什么？

<details>
<summary>答案与解析</summary>

**答案**: `1 2 3`

**解析**: 函数返回一个闭包，闭包捕获了外部变量 `count`。每次调用闭包时，`count` 会累加。这体现了 Swift 闭包的捕获机制。
</details>

---

## 延伸阅读

学习完函数后，你可能还想了解：

- [Swift 官方文档 — Functions](https://docs.swift.org/swift-book/documentation/the-basics/) — 函数定义完整语法
- [Swift by Sundell — Closures](https://www.swiftbysundell.com/articles/understanding-closures/) — 闭包深度解析

**选择建议**:

- 初学者 → 继续学习 [枚举](enums.md)
- 有经验的程序员 → 跳到 [结构体](structs.md)

> 记住：Swift 的函数设计强调可读性。参数标签让你的调用像自然语言一样清晰，这是一项值得坚持的编码习惯。

---

## 继续学习

- 下一步：[枚举](enums.md) — 用 `enum` 定义类型安全的选项
- 相关：[结构体](structs.md) — 值类型数据模型
- 进阶：[协议](protocols.md) — 面向协议的编程范式
