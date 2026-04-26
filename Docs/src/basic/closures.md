# 闭包

## 开篇故事

假设你在一个外卖平台上下了单。你填了地址、选了餐厅、付了款。但在等待的过程中，你并没有闲着。你继续工作、看书、聊天。等外卖到了，平台会通知你。

这就是闭包的精髓。你把一段代码"包好"交给系统，系统在合适的时候执行它。闭包可以记住它在创建时的环境，就像一个外卖订单记住了你的地址和菜品。

Swift 的闭包非常类似 JavaScript 的箭头函数或 Python 的 lambda，但它有更强的类型系统和作用域控制。

---

## 本章适合谁

本章适合已经掌握基本函数语法的 Swift 学习者。如果你能写出简单的函数定义，已经了解参数和返回值，就可以开始学闭包。如果你刚从其他语言转过来了，闭包是你一定会遇到的概念。

---

## 你会学到什么

完成本章后，你可以：

1. 使用闭包表达式语法 `{ (params) -> ReturnType in body }`
2. 理解尾随闭包 (trailing closure) 语法糖
3. 掌握闭包的值捕获 (value capturing) 机制
4. 区分逃逸闭包 (@escaping) 和非逃逸闭包
5. 使用高级函数 map、filter、reduce、sorted、compactMap

---

## 前置要求

先完成 [函数](functions.md) 章节，了解函数类型 (function type) 和基本参数。本章会多次用到函数类型的概念。

---

## 第一个例子

在 `Sources/BasicSample/FunctionSample.swift` 中，我们已经看到了嵌套函数和函数返回的案例。这里展示闭包最核心的写法：

```swift
// 完整语法
let greet = { (name: String) -> String in
    return "Hello, \(name)!"
}

// 调用闭包
print(greet("Alice"))
// 输出: Hello, Alice!
```

**发生了什么？**

- `{ (name: String) -> String in ... }` — { 包裹的闭包，类型声明紧跟参数，in 分隔签名和函数体
- `name: String` — 闭包的输入参数
- `-> String` — 闭包的返回类型
- `in` — 标记闭包签名结束，函数体开始

---

## 原理解析

### 1. 闭包表达式语法

闭包是"匿名函数"的另一种说法。完整的闭包表达式长这样：

```swift
let numbers = [3, 1, 4, 1, 5]

// sorted 需要一个闭包参数
let descending = numbers.sorted(by: { (a: Int, b: Int) -> Bool in
    return a > b
})
print(descending) // [5, 4, 3, 1, 1]
```

这个闭包告诉 sorted 如何比较两个元素。返回值是 Bool：true 表示 a 排在 b 前面。

**类比**：
> 闭包就像你给外包团队的说明书。你写清楚"拿到什么数据，返回什么结果"，对方按说明执行。

### 2. 简化写法

Swift 的闭包可以用多种方式简化：

```swift
// 1. 参数类型推断（编译器能猜出类型）
let asc1 = numbers.sorted(by: { a, b in a > b })

// 2. 单行表达式自动返回（省略 return）
let asc2 = numbers.sorted(by: { $0 > $1 })

// 3. 尾随闭包 — 闭包是最后一个参数时可以放在括号外面
let asc3 = numbers.sorted { $0 > $1 }

// 4. 如果闭包是唯一参数，括号也可以省略
let asc4 = numbers.sorted(by: >)
```

一步步来，每个简化都省掉了一些字符。

### 3. 捕获值 (Capturing)

闭包最大的特色是它能记住创建时的变量：

```swift
func makeMultiplier(factor: Int) -> (Int) -> Int {
    { number in
        return number * factor  // 捕获了 factor
    }
}

let double = makeMultiplier(factor: 2)
let triple = makeMultiplier(factor: 3)

print(double(5))  // 10
print(triple(5))  // 15
```

`factor` 在 `makeMultiplier` 返回后并没有消失。它被闭包捕获了，一直存在于内存中。

再看一个更生动的例子：

```swift
// functionAsReturnTypeSample() 在 FunctionSample.swift 中
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

`runningTotal` 在每次调用之间保持状态。这就是捕获的能力：闭包携带了自己的变量，就像一个背包。

### 4. 尾随闭包 (Trailing Closure)

当闭包是函数的最后一个参数时，Swift 允许把闭包移到括号外：

```swift
// 普通写法
let result = numbers.sorted(by: { (a, b) -> Bool in a > b })

// 尾随闭包
let result = numbers.sorted { (a, b) -> Bool in a > b }
```

如果参数只有闭包，连括号都能省：

```swift
let result = numbers.sorted { $0 > $1 }
```

这是 Swift 中最常见的模式之一。很多 API 都用尾随闭包，比如异步操作、动画、网络请求回调。

### 5. 逃逸闭包 (@escaping)

有些闭包不会在函数返回前执行，而是"逃到"外面去：

```swift
// 非逃逸：闭包在函数内执行完
func processNow(operation: () -> Void) {
    operation()  // 在函数内部执行
}

// 逃逸：闭包保存到变量中
var completionHandlers: [() -> Void] = []

func registerHandler(_ handler: @escaping () -> Void) {
    completionHandlers.append(handler)  // 闭包保存在数组里
}

registerHandler {
    print("This will run later!")
}
```

`@escaping` 告诉编译器这个闭包的生命周期比函数调用更长。逃逸闭包需要特别注意循环引用 (retain cycle)。

**何时逃逸？** 当闭包被保存（赋值给变量、放入数组、传给后台线程）时就需要 @escaping。

### 6. 自动闭包 (@autoclosure)

`@autoclosure` 自动把表达式包装成闭包：

```swift
var enabled = false

// XCTAssertEqual 内部使用了 @autoclosure
func myAssert(_ condition: @autoclosure () -> Bool, _ message: String) {
    if !enabled { return }  // 闭包根本没执行
    if !condition() {
        print("Assertion failed: \(message)")
    }
}

myAssert(2 + 2 == 5, "Math is broken")
// 因为 enabled 为 false，条件表达式根本没被计算
```

这叫做"延迟计算"(lazy evaluation)。只有闭包真正被调用时，表达式才会执行。这在单元测试和调试时非常有用。

### 7. 类型别名 (Type Aliases)

闭包类型写长了很烦人。可以用 typealias 取个名字：

```swift
typealias CompletionHandler<T> = (Result<T, Error>) -> Void

func fetchData(completion: CompletionHandler<Data>) {
    // ...
}
```

在 `greet(person:from:)` 这类函数中，返回类型也是函数类型，也可以用 typealias 简化。

### 8. 高阶函数 (Higher-Order Functions)

Swift 标准库提供了大量接收闭包的工具函数。这些通常叫做"高阶函数"，因为它们把函数作为参数。

**map** — 把一个数组的每个元素转换成另一种：

```swift
let words = ["hello", "world", "swift"]
let lengths = words.map { $0.count }
print(lengths)  // [5, 5, 5]
```

**filter** — 保留满足条件的元素：

```swift
let numbers = [1, 2, 3, 4, 5, 6]
let evens = numbers.filter { $0 % 2 == 0 }
// [2, 4, 6]
```

**reduce** — 把所有元素合并成一个：

```swift
let sum = numbers.reduce(0, +)  // 21
// 等价于: numbers.reduce(0) { $0 + $1 }

// 拼接字符串
let sentence = words.reduce("") { $0 + " " + $0 }
// 或者用 compactMap 消除 nil
```

**compactMap** — 过滤 nil 并同时映射：

```swift
let strings = ["1", "abc", "42", "xyz"]
let numbers = strings.compactMap { Int($0) }
// [1, 42] — "abc" 和 "xyz" 转 Int 失败，被过滤掉
```

**sorted** — 排序：

```swift
let sorted = words.sorted { $0 > $1 }  // 降序
// ["world", "swift", "hello"]
```

链式组合能力，这些方法返回的还是数组，所以可以连续调用：

```swift
let result = numbers
    .filter { $0 % 2 == 0 }
    .map { $0 * $0 }
    .sorted()
print(result)  // [4, 16, 36]
```

先筛选偶数，再平方，最后排序。每一步都是前一步的结果。

---

## 常见错误

### 错误 1: 尾随闭包语法

```swift
let names = ["a", "bb", "ccc"]
let lengths = names.map() { $0.count } // ❌ 编译错误
```

**编译器输出**:
```
error: trailing closure must be passed as the only argument to call
```

**修复方法**:
```swift
let lengths = names.map { $0.count } // ✅ 去掉 ()
```

如果闭包不是唯一参数，括号要保留：

```swift
let result = reduce(numbers, 0) { $0 + $1 } // ✅ 正确
```

### 错误 2: 闭包循环引用

```swift
class DataManager {
    var items: [String] = []
    
    func load() {
        fetch { [weak self] data in
            self?.items.append(contentsOf: data)
        }
    }
}
```

**编译器输出**:
```
warning: capturing 'self' strongly in this closure is likely to result in a retention cycle
```

**修复方法**:
```swift
fetch { [weak self] data in
    self?.items.append(contentsOf: data)
}
// 使用 [weak self] 打破强引用环
```

### 错误 3: 逃逸闭包需要标注

```swift
var handlers: [() -> Void] = []

func addHandler(_ h: () -> Void) {
    handlers.append(h) // ❌ 不匹配
}
```

**编译器输出**:
```
error: closure is sending non-escaping parameter out of function
```

**修复方法**:
```swift
func addHandler(_ h: @escaping () -> Void) {
    handlers.append(h) // ✅ 加了 @escaping
}
```

---

## Swift vs Rust/Python 对比

| 概念 | Python | Rust | Swift | 关键差异 |
|------|--------|------|-------|----------|
| 匿名函数 | `lambda` | `|args\| { ... }` | `{ ... in ... }` | Python lambda 只能单行 |
| 捕获 | 自动捕获 | 明确模式（move/borrow） | 自动强捕获 | Rust 需要 `move` 关键字 |
| 逃逸闭包 | 不需要（引用计数管理） | `move` | `@escaping` | Swift 需要标注逃逸闭包 |
| 尾随闭包 | 不支持（参数必须是最后一个） | 不支持 | 支持 | Swift 独有的语法糖 |
| 自动闭包 | 不支持 | 不支持 | `@autoclosure` | Swift 独有，用于断言等场景 |
| map/filter/reduce | `map/filter/reduce` 函数 | `iter().map()...` | 数组方法 `.map{}...` | Swift 是实例方法 |

---

## 动手练习

### 练习 1: 用 map 转换数据

给定一个整数数组 `[1, 2, 3, 4, 5]`，用闭包将每个元素平方，再选出大于 4 的结果。

<details>
<summary>点击查看答案</summary>

```swift
let numbers = [1, 2, 3, 4, 5]
let result = numbers
    .map { $0 * $0 }
    .filter { $0 > 4 }
print(result)  // [9, 16, 25]
```

</details>

### 练习 2: 闭包捕获

写一个函数 `makeAccumulator()` 返回一个闭包，每次调用返回的闭包时，累加传入的值并返回总和。

<details>
<summary>点击查看答案</summary>

```swift
func makeAccumulator() -> (Int) -> Int {
    var total = 0
    return { value in
        total += value
        return total
    }
}

let acc = makeAccumulator()
print(acc(10))  // 10
print(acc(20))  // 30
print(acc(5))   // 35
```

**解析**: `total` 被闭包捕获，每次调用都在前一次的基础上累加。

</details>

### 练习 3: reduce 实现字符串拼接

用 `reduce` 把 `["Hello", " ", "World", "!"]` 拼成一个字符串。

<details>
<summary>点击查看答案</summary>

```swift
let parts = ["Hello", " ", "World", "!"]
let result = parts.reduce("", +)
print(result)  // Hello World!

// 等价于:
let result2 = parts.reduce("") { $0 + $1 }
```

</details>

---

## 故障排查 FAQ

### Q: 闭包和函数有什么区别？

**A**: 概念上几乎相同，区别在于：

- **函数**有名字，用 `func` 声明，在模块级别定义
- **闭包**是匿名的，用 `{}` 包裹，通常在函数内部定义
- **闭包能捕获外部变量**，函数不能（函数只接收参数）

实际使用中，当需要一个简短的行为描述时，用闭包。当需要复用、逻辑复杂时，用函数。

### Q: 什么时候闭包需要 @escaping？

**A**: 闭包被保存到函数结束之外的地方时就需要：

```swift
// ✅ 非逃逸 — 函数内执行完
func doAndPrint(action: () -> Void) {
    action()
}

// ❌ 编译错误 — 闭包逃出函数
var savedAction: () -> Void

func saveClosure(action: () -> Void) { // 需要 @escaping
    savedAction = action
}

// ✅ 修复：加上 @escaping
func saveClosure(action: @escaping () -> Void) {
    savedAction = action
}
```

简单记忆：如果闭包被赋值给变量、传入数组、传到后台线程，就加 @escaping。

### Q: `$0`, `$1` 是什么？

**A**: 它们是 Swift 闭包的简化用法。当闭包参数名可以省略时，Swift 按位置命名参数：

- `$0` — 第一个参数
- `$1` — 第二个参数
- `$2` — 第三个参数（极少使用）

```swift
numbers.filter { $0 > 5 }  // $0 就是每个元素
dict.sorted { $0.key < $1.key }  // $0 和 $1 都是键值对
```

太长的闭包不要用 `$0`，可读性差。只用在一两行的简短闭包中。

---

## 小结

**核心要点**：

1. **闭包是匿名函数** — `{ (params) -> ReturnType in body }`
2. **尾随闭包是语法糖** — 最后一个闭包可以移到括号外
3. **闭包可以捕获值** — 记住创建时的环境，类似于"携带状态的代码块"
4. **逃逸闭包需标注** — `@escaping` 声明生命周期超出函数
5. **高阶函数组合能力** — 用 map/filter/reduce 链式处理数据

**关键术语**：

- **Closure**: 闭包（一段能捕获外部变量的匿名代码块）
- **Trailing Closure**: 尾随闭包（将闭包移到函数参数括号之外）
- **Capturing**: 捕获（闭包记住并使用外部变量）
- **Escaping Closure**: 逃逸闭包（在函数返回后仍然有效的闭包）
- **Higher-Order Function**: 高阶函数（接收函数作为参数的函数）

---

## 术语表

| English | 中文 |
|---------|------|
| Closure | 闭包 |
| Trailing Closure | 尾随闭包 |
| Capturing | 捕获 |
| Escaping | 逃逸 |
| Autoclosure | 自动闭包 |
| Type Alias | 类型别名 |
| Higher-Order Function | 高阶函数 |
| Retention Cycle | 循环引用 |
| Shorthand Argument | 简写参数名 |
| Capture List | 捕获列表 |
| Lazy Evaluation | 延迟计算 |
| CompactMap | 可选映射 |

---

完整示例：`Sources/BasicSample/FunctionSample.swift`（见 functionAsReturnTypeSample）

---

## 知识检查

**问题 1** 🟢 (基础概念)

```swift
let names = ["Alice", "Bob", "Charlie"]
let lengths = names.map { $0.count }
```

`lengths` 的值是什么？

A) `["Alice", "Bob", "Charlie"]`  
B) `[5, 3, 7]`  
C) `[5, 3, 7]` 的字符串形式  
D) 编译错误

<details>
<summary>答案与解析</summary>

**答案**: B) [5, 3, 7]

**解析**: `$0.count` 对每个字符串取长度。Alice=5, Bob=3, Charlie=7。返回的是 `[Int]`。

</details>

**问题 2** 🟡 (闭包捕获)

```swift
func makeCounter() -> () -> Int {
    var count = 0
    return {
        count += 1
        return count
    }
}

let c1 = makeCounter()
let c2 = makeCounter()
print(c1())  // A
print(c1())  // B
print(c2())  // C
```

A, B, C 的值分别是什么？

<details>
<summary>答案与解析</summary>

**答案**: A=1, B=2, C=1

**解析**: 每次调用 `makeCounter()` 都会创建一个新的 `count` 变量。`c1` 和 `c2` 各持有独立的闭包，捕获了各自的环境。

</details>

**问题 3** 🟡 (逃逸闭包)

```swift
var handlers: [() -> Void] = []

func add(_ h: @escaping () -> Void) {
    handlers.append(h)
}
```

为什么需要 `@escaping`？

<details>
<summary>答案与解析</summary>

**答案**: 因为闭包 `h` 被添加到了全局数组 `handlers` 中。它的生命周期超越了 `add` 函数的调用。

**解析**: 默认闭包是非逃逸的，只在函数体内有效。一旦闭包被保存到别处（变量、数组、线程），Swift 需要 @escaping 标记来知道这个闭包会存活更久，进而检查循环引用等问题。
</details>

---

## 延伸阅读

学完闭包后，你可能还想了解：

- [Swift 官方文档 - Closures](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/closures/) — 闭包语言参考
- [Swift API Design Guidelines - Closures](https://www.swift.org/documentation/api-design-guidelines/) — 闭包命名的最佳实践

**选择建议**:
- 初学者 → 继续学习 [控制流](control-flow.md)
- 有经验开发者 → 跳到 [并发编程](concurrency.md)

> 记住：闭包就是"带状态的代码块"。它能记住创建时的变量，在需要时用。掌握闭包后，你会发现 Swift 的 API 变得异常灵活。

---

## 继续学习

- 下一步：[并发编程](concurrency.md)
- 相关：[控制流](control-flow.md) — 闭包在条件表达式中的使用
- 进阶：[协议](protocols.md) — 用闭包替代协议方法的组合模式
