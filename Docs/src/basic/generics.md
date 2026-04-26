# 泛型

## 开篇故事

想象你有一个万能工具箱。这个箱子里有扳手、螺丝刀、钳子，但每个工具都能适配不同尺寸的螺母和螺丝。你不需要为每种尺寸买一套工具，一套就够了。

Swift 中的**泛型**（Generics）就是这个万能工具。你可以写一段代码，让它适用于多种类型，而不是为每种类型复制一份。当你使用 `Array<Int>`、`Array<String>` 或 `Array<Double>` 时，其实底层都是同一份 `Array` 实现，只是填入了不同的类型参数。

Swift 的标准库几乎完全建立在泛型之上。`Array`、`Dictionary`、`Optional`、`Result` 都是泛型类型。理解泛型不只是写更少的代码，更是理解 Swift 的类型系统如何做到既灵活又安全。

---

## 本章适合谁

如果你已经理解了 Swift 的类型系统和协议基础，想理解如何编写能复用于多种类型的代码，本章适合你。如果你从 Java、C++ 或 Rust 过来，你会发现 Swift 的泛型语法和它们有相似之处，但协议约束系统有自己的独特设计。

---

## 你会学到什么

完成本章后，你可以：

1. 使用 `<T>` 语法定义泛型函数和泛型类型
2. 使用类型约束（Type Constraint）限制泛型参数必须符合特定协议
3. 使用 `where` 子句对泛型添加多重约束
4. 理解 Swift 标准库中的泛型设计（Array、Dictionary、Optional、Result）
5. 在泛型与协议之间做出正确的选择

---

## 前置要求

确保你已经阅读了 [协议](protocols.md) 一章，理解协议定义和协议约束的概念。本章的类型约束会大量用到 `Equatable`、`Comparable`、`Hashable` 等协议。

---

## 第一个例子

打开 `Sources/BasicSample/GenericSample.swift`（该文件当前作为泛型相关示例的容器），来看泛型函数最基本的形式：

```swift
// 交换两个值的泛型函数
func swapTwoValues<T>(_ a: inout T, _ b: inout T) {
    let temporaryA = a
    a = b
    b = temporaryA
}

var x = 10
var y = 20
swapTwoValues(&x, &y)
print("x = \(x), y = \(y)")  // x = 20, y = 10

var name1 = "Alice"
var name2 = "Bob"
swapTwoValues(&name1, &name2)
print("\(name1), \(name2)")  // Bob, Alice
```

**发生了什么？**

- `<T>` 声明了一个**类型参数**（Type Parameter），T 是占位符
- 调用时 Swift 根据实际参数推导出 T 的具体类型
- `inout` 允许函数修改传入的参数
- 同一个函数可以处理 `Int`、`String` 或任何其他类型

**输出**：
```
x = 20, y = 10
Bob, Alice
```

---

## 原理解析

### 1. 泛型函数

泛型函数在函数名后使用 `<T>` 声明类型参数。T 可以替换为任何类型：

```swift
// 检查数组是否包含指定元素
func contains<T: Equatable>(_ array: [T], _ target: T) -> Bool {
    for item in array {
        if item == target {
            return true
        }
    }
    return false
}

print(contains([1, 2, 3, 4, 5], 3))  // true — T = Int
print(contains(["apple", "banana"], "cherry"))  // false — T = String
```

**泛型命名惯例**：
- `T` — 通用的类型参数
- `Element` — 集合中的元素
- `Key`、`Value` — 字典的键值对
- 单字母简短，描述性名称清晰，根据上下文选择

### 2. 泛型类型

不仅仅是函数，结构体、类、枚举都可以是泛型的：

```swift
// 泛型栈 — Stack
struct Stack<Element> {
    private var items: [Element] = []

    mutating func push(_ item: Element) {
        items.append(item)
    }

    mutating func pop() -> Element? {
        items.popLast()
    }

    func peek() -> Element? {
        items.last
    }

    var isEmpty: Bool {
        items.isEmpty
    }
}

// 使用 — 可以显式指定或让编译器推断
var intStack = Stack<Int>()
intStack.push(1)
intStack.push(2)
print(intStack.pop() ?? 0)  // 2

var stringStack = Stack<String>()  // T = String
stringStack.push("hello")
stringStack.push("world")
print(stringStack.peek() ?? "empty")  // "world"
```

**泛型枚举**：

```swift
// Swift 标准库的 Optional 就是泛型枚举
enum Maybe<Wrapped> {
    case none
    case some(Wrapped)
}

let number: Maybe<Int> = .some(42)
let nothing: Maybe<String> = .none
```

### 3. 类型约束（Type Constraints）

泛型参数可以限制必须遵守某个协议或继承某个类：

```swift
// 约束 T 必须遵守 Equatable
func findIndex<T: Equatable>(of valueToFind: T, in array: [T]) -> Int? {
    for (index, value) in array.enumerated() {
        if value == valueToFind {
            return index
        }
    }
    return nil
}

print(findIndex(of: 9, in: [0, 3, 6, 9, 12]))  // Optional(3)
print(findIndex(of: "hello", in: ["hi", "hello", "hey"]))  // Optional(1)
```

**常见约束协议**：

| 协议 | 约束要求 | 用途 |
|------|---------|------|
| `Equatable` | `==` 运算符 | 相等性检查 |
| `Comparable` | `<`、`>`、`<=`、`>=` | 排序和比较 |
| `Hashable` | `hash(into:)` | 作为字典键 |
| `CustomStringConvertible` | `description` 属性 | 字符串表示 |
| `Codable` | `Encodable` + `Decodable` | JSON 编解码 |

### 4. Where 子句

`where` 子句允许添加更复杂的约束条件：

```swift
// 要求 T 遵守 Equatable，且 U 遵守 Comparable
func compareAndSort<T: Equatable, U: Comparable>(
    _ a: T, _ b: T,
    _ x: U, _ y: U
) -> (T, U) {
    let sorted = (x < y) ? (x, y) : (y, x)
    let equal = (a == b) ? a : b
    return (equal, sorted.0)
}

// 更典型的 where 用法：关联类型约束
func printAll<S: Sequence>(items: S) where S.Element: CustomStringConvertible {
    for item in items {
        print(item.description)
    }
}

printAll(items: [1, 2, 3])           // S.Element = Int
printAll(items: ["a", "b", "c"])    // S.Element = String
```

**where 子句还可以约束关联类型**：

```swift
// 检查两个 Sequence 是否包含相同元素
func sequencesMatch<S1: Sequence, S2: Sequence>(
    _ s1: S1, _ s2: S2
) -> Bool where S1.Element == S2.Element, S1.Element: Equatable {
    let array1 = Array(s1)
    let array2 = Array(s2)
    return array1 == array2
}

print(sequencesMatch([1, 2, 3], [1, 2, 3]))  // true
```

### 5. 关联类型在协议中的泛型应用

协议中的 `associatedtype` 本质上是**协议层面的泛型**。它与泛型参数不同但互补：

```swift
// 用 associatedtype 定义数据源协议
protocol DataSource {
    associatedtype Item
    func fetch() -> [Item]
    var count: Int { get }
}

struct User { let name: String }

struct UserDataSource: DataSource {
    typealias Item = User  // 关联类型的具体化
    var users: [User] = [User(name: "Alice"), User(name: "Bob")]
    func fetch() -> [User] { users }
    var count: Int { users.count }
}

// 用泛型函数使用这个 DataSource
func printDataSource<D: DataSource>(_ source: D)
    where D.Item: CustomStringConvertible {
    for item in source.fetch() {
        print(item)
    }
    print("Total: \(source.count)")
}
```

**泛型参数 vs 关联类型 选择**：

| 场景 | 用泛型参数 | 用关联类型 |
|------|-----------|-----------|
| 类型由调用者指定 | ✅ | |
| 类型由实现者指定 | | ✅ |
| 同一类型需要多种实现 | | ✅ |
| 函数/类型定义参数 | ✅ | |
| 协议能力定义 | | ✅ |

### 6. Swift 标准库中的泛型

Swift 标准库几乎全部使用泛型实现。几个最核心的例子：

**Array**：
```swift
// Array 的简化定义
struct Array<Element> {
    // 所有操作都基于 Element 类型
}
let numbers: Array<Int> = [1, 2, 3]  // 通常直接写 [Int]
```

**Dictionary**：
```swift
// Dictionary 需要两个类型参数
struct Dictionary<Key: Hashable, Value> {
    // Key 必须遵守 Hashable
}
let dict: Dictionary<String, Int> = ["one": 1, "two": 2]
```

**Optional**：
```swift
// Optional 是最常见的泛型枚举
enum Optional<Wrapped> {
    case none
    case some(Wrapped)
}
let x: Optional<Int> = .some(42)
let y: Int? = 42  // 语法糖，等价于 Optional<Int>
```

**Result**：
```swift
// Result 用于错误处理
enum Result<Success, Failure: Error> {
    case success(Success)
    case failure(Failure)
}

func divide(_ a: Double, _ b: Double) -> Result<Double, divisionError> {
    if b == 0 {
        return .failure(DivisionError.byZero)
    }
    return .success(a / b)
}

enum DivisionError: Error { case zero, negative }
```

### 7. 泛型 vs 协议 — 什么时候用什么

这是 Swift 开发者最常遇到的选择问题：

```swift
// 方案 A: 泛型函数
func process<T: Equatable>(_ value: T) {
    print("Processing: \(value)")
}

// 方案 B: 协议参数
func process(_ value: Equatable) {  // ❌ 不能直接用协议
    print("Processing: \(value)")
}

// 方案 B 的正确写法 — 配合 some
func process(_ value: some Equatable) {
    print("Processing: \(value)")
}
```

**选择指南**：

| 需求 | 用泛型 | 用 some Protocol | 用 Protocol 类型 |
|------|--------|-----------------|-----------------|
| 需要知道具体类型 | ✅ | ✅ | |
| 性能优先 | ✅ | ✅ | |
| 允许多种具体类型混用 | | | ✅ |
| 编译期类型确定 | ✅ | | |
| 作为返回类型 | ✅ | ✅ | ✅ |
| 返回值可能不同类 | | | ✅ |

**经验法则**：
- 函数参数优先用 `some Protocol`（Swift 5.1+）
- 结构体/类的类型参数用泛型
- 需要存放混合类型的集合用协议类型（有性能开销）

---

## 常见错误

### 错误 1: 泛型参数没有类型约束

```swift
func findItem<T>(_ array: [T], _ target: T) -> Bool {
    for item in array {
        if item == target {  // ❌ T 没有遵守 Equatable
            return true
        }
    }
    return false
}
```

**编译器输出**：
```
error: binary operator '==' cannot be applied to two 'T' operands
note: equality operator '==' is declared in protocol 'Equatable'
```

**修复方法**：
```swift
func findItem<T: Equatable>(_ array: [T], _ target: T) -> Bool {
    for item in array {
        if item == target {  // ✅ T 遵守 Equatable
            return true
        }
    }
    return false
}
```

### 错误 2: 泛型约束过于严格

```swift
func printElements<T: Sequence>(items: T) where T.Element: Comparable {
    // 只为了打印，却要求元素可比较
    for item in items {
        print(item)
    }
}

printElements(items: [1, 2, 3])  // ✅
// printElements(items: [SomeNonComparableType()]) // ❌
```

**修复方法** — 只约束实际需要的：

```swift
func printElements<T: Sequence>(items: T) where T.Element: CustomStringConvertible {
    // 只要求能转字符串，更宽松更灵活
    for item in items {
        print(item.description)
    }
}
```

**泛型约束法则**：约束应该是满足功能需求的**最弱约束**。越弱的约束 = 越多的类型可用 = 越好的复用性。

### 错误 3: 试图用泛型约束两个不相关的参数

```swift
func pair<T>(_ a: T, _ b: T) -> (T, T) {
    return (a, b)
}

pair(10, "hello")  // ❌ 两个参数都是 T，必须同一类型
```

**编译器输出**：
```
error: cannot convert value of type 'String' to expected argument type 'Int'
```

**修复方法** — 用两个类型参数：

```swift
func pair<T, U>(_ a: T, _ b: U) -> (T, U) {
    return (a, b)
}

pair(10, "hello")   // ✅ T=Int, U=String
pair(3.14, true)    // ✅ T=Double, U=Bool
```

**注意**：Swift 标准库已经有 `Tuple`，所以上面的 `pair` 函数实际上是多余的。这只是用来演示泛型参数的使用。

---

## Swift vs Rust/Python 对比

| 概念 | Python | Rust | Swift | 关键差异 |
|------|--------|------|-------|----------|
| 泛型函数 | 无（运行时类型） | `fn foo<T>(x: T)` | `func foo<T>(_ x: T)` | 语法高度一致 |
| 类型约束 | 无（duck typing） | Trait bound `T: Trait` | Protocol constraint `T: Protocol` | Swift/Rust 约束在编译期 |
| where 子句 | 无 | `where T: Trait` | `where T: Protocol` | Swift/Rust 几乎一致 |
| 泛型类型 | 无（运行时） | `struct Foo<T>` | `struct Foo<T>` | 语法一致 |
| Optional | 无（用 None） | `Option<T>` | `Optional<Wrapped>` (T?) | Swift 用语法糖 `?` |
| Result | 无（用异常） | `Result<T, E>` | `Result<Success, Failure>` | Swift 需要 Error 约束 |
| 分发方式 | 运行时 | 单态化（monomorphization） | 单态化（WITNESS TABLE） | Rust/Swift 都没有泛型开销 |

---

## 动手练习

### 练习 1: 泛型函数

编写一个泛型函数 `findMax`，接受一个数组，返回最大值。需要添加适当的类型约束：

```swift
// 提示：使用 Comparable 协议
func findMax<T>(in array: [T]) -> T? {
    // 你的实现
}
```

<details>
<summary>点击查看答案</summary>

```swift
func findMax<T: Comparable>(in array: [T]) -> T? {
    guard var maximum = array.first else { return nil }
    for item in array.dropFirst() {
        if item > maximum {
            maximum = item
        }
    }
    return maximum
}

print(findMax(in: [3, 1, 4, 1, 5, 9, 2, 6]))  // Optional(9)
print(findMax(in: ["banana", "apple", "cherry"]))  // Optional("cherry")
```

**关键点**：`<T: Comparable>` 确保了 `>` 运算符可用。

</details>

### 练习 2: 泛型类型

实现一个泛型 `Result` 类型（模拟 Swift 标准库），包含 `success` 和 `failure` 两个 case，以及一个 `get()` 方法：

```swift
enum SimpleResult<Success, Failure: Error> {
    // 你的实现
}
```

<details>
<summary>点击查看答案</summary>

```swift
enum SimpleResult<Success, Failure: Error> {
    case success(Success)
    case failure(Failure)

    func get() -> Result<Success, Failure> {
        switch self {
        case .success(let value):
            return .success(value)
        case .failure(let error):
            return .failure(error)
        }
    }
}

enum MathError: Error {
    case divisionByZero
    case negativeRoot
}

func safeDivide(_ a: Double, _ b: Double) -> SimpleResult<Double, MathError> {
    if b == 0 { return .failure(.divisionByZero) }
    return .success(a / b)
}

let result = safeDivide(10, 3)
switch result {
case .success(let value):
    print("Result: \(value)")
case .failure(let error):
    print("Error: \(error)")
}
```

</details>

### 练习 3: where 子句

编写一个函数，接受一个字典，打印所有键值对。要求 Key 可转字符串，Value 也可转字符串：

```swift
func printDictionary<K, V>(_ dict: [K: V]) where /* 你的约束 */ {
    // 你的实现
}
```

<details>
<summary>点击查看答案</summary>

```swift
func printDictionary<K, V>(_ dict: [K: V])
    where K: CustomStringConvertible, V: CustomStringConvertible {
    for (key, value) in dict {
        print("\(key.description): \(value.description)")
    }
}

printDictionary([1: "apple", 2: "banana", 3: "cherry"])
// 输出（顺序不确定）：
// 1: apple
// 2: banana
// 3: cherry

// 也适用于自定义类型
struct User: CustomStringConvertible {
    let name: String
    var description: String { "User(\(name))" }
}
printDictionary(["id": User(name: "Alice")])
// 输出: id: User(Alice)
```

</details>

---

## 故障排查 FAQ

### Q: 泛型和协议扩展的默认实现有什么区别？

**A**: 它们解决不同层面问题：

- **泛型** 写一段代码适用于多种类型。比如 `swapTwoValues<T>()` 可以交换任意两个 `T` 类型的值
- **协议扩展** 为遵守协议的所有类型提供默认实现。比如为所有 `Collection` 提供 `average()` 方法

它们经常配合使用：泛型函数用协议约束参数，协议用关联类型定义抽象能力。

### Q: 什么时候用 `some Protocol` 而不是泛型？

**A**: 当你是**函数作者/类作者**时优先用 `some Protocol`，当你是**调用者**泛型。原因是：
- `some Protocol` 对调用者更简洁 — 他们不需要知道具体的类型参数
- `some Protocol` 的返回值隐藏具体类型，提供封装
- 泛型参数列表在复杂场景下会很冗长，`some` 更干净

```swift
// 泛型版本 — 调用者需要知道或推断 T
func makeValue<T: Shape>() -> T { ... }
let x = makeValue<Circle>()  // 必须指定类型

// some 版本 — 调用者不需要知道类型
func makeDefaultShape() -> some Shape { ... }
let x = makeDefaultShape()  // 编译器推断
```

### Q: Swift 的泛型性能如何？会像 Java 那样有类型擦除的开销吗？

**A**: Swift **不会类型擦除**。Swift 的泛型在编译时会**单态化**（monomorphization）：对每个使用的具体类型，编译器生成一份独立的实例化代码。这意味着：

- **零运行时开销** — 编译后的代码和手写 `Int` 版本一样快
- **编译时间增加** — 更多的泛型实例意味着更多编译工作
- **二进制增大** — 每个类型实例都有一份副本

这与 Java 的泛型（运行时擦除为 Object）和 Rust 的行为（也是单态化）不同。

---

## 小结

**核心要点**：

1. **`<T>` 是泛型类型参数** — 让函数和类型适用于多种类型
2. **类型约束 `T: Protocol` 限制可选类型** — 最常用的约束是 `Equatable`、`Comparable`
3. **`where` 子句添加多重或关联类型约束** — 泛型的强大表达能力
4. **标准库大量使用泛型** — `Array`、`Dictionary`、`Optional`、`Result` 都是泛型
5. **Swift 泛型是单态化的** — 编译时生成代码，没有运行时开销

**关键术语**：

- **Generics**: 泛型（参数化类型）
- **Type Parameter**: 类型参数（`<T>` 中的 T）
- **Type Constraint**: 类型约束（`T: Equatable`）
- **Where Clause**: where 子句（多重约束）
- **Monomorphization**: 单态化（编译时泛型实例化）
- **Associated Type**: 关联类型（协议中的占位类型）

---

## 术语表

| English | 中文 |
|---------|------|
| Generics | 泛型 |
| Type Parameter | 类型参数 |
| Type Constraint | 类型约束 |
| Protocol Conformance | 协议遵守 |
| Where Clause | where 子句 |
| Associated Type | 关联类型 |
| Monomorphization | 单态化 |
| Type Erasure | 类型擦除 |
| Generic Type | 泛型类型 |
| Generic Function | 泛型函数 |
| Constraint | 约束 |

完整示例：`Sources/BasicSample/GenericSample.swift`

---

## 知识检查

**问题 1** 🟢 (基础概念)

```swift
func wrap<T>(_ value: T) -> T {
    return value
}

let x = wrap(42)
let y = wrap("hello")
```

`x` 和 `y` 的类型分别是什么？

A) x: Any, y: Any  
B) x: Int, y: String  
C) 编译错误 — 不能推断 T  
D) x: Int, y: Int

<details>
<summary>答案与解析</summary>

**答案**: B) x: Int, y: String

**解析**: Swift 的泛型参数通过调用时的实际参数推断。`wrap(42)` 时 T 推断为 `Int`，`wrap("hello")` 时 T 推断为 `String`。这是 Swift 泛型类型推断的基本能力。

</details>

**问题 2** 🟡 (类型约束)

```swift
func sum<T: Numeric>(_ values: [T]) -> T {
    return values.reduce(0, +)
}
```

`Numeric` 约束要求 T 必须实现什么？

A) `==` 运算符  
B) `+` 运算符和数字字面量转换  
C) `<` 和 `>` 运算符  
D) `hash(into:)` 方法

<details>
<summary>答案与解析</summary>

**答案**: B) `+` 运算符和数字字面量转换

**解析**: `Numeric` 协议要求类型支持加法运算和整数字面量初始化（`init(exactly:)`）。这确保 `reduce(0, +)` 中的 `0` 可以初始化为 T，且 `+` 可以计算。`Equatable` 需要 `==`，`Comparable` 需要 `< >`，`Hashable` 需要 `hash(into:)`。

</details>

**问题 3** 🔴 (泛型限制）

```swift
struct Pair<T> {
    let first: T
    let second: T
}

func describePairs(_ pairs: [Pair]) {  // ❌
    for p in pairs {
        print("\(p.first), \(p.second)")
    }
}
```

能编译通过吗？

A) 能  
B) 不能 — Pair 需要类型参数  
C) 不能 — 数组元素不能是泛型  
D) 不能 — describePairs 也需要泛型

<details>
<summary>答案与解析</summary>

**答案**: B) 不能 — Pair 需要类型参数

**解析**: `Pair` 是泛型类型，声明变量或参数时必须指定具体类型参数，或让编译器推断：

```swift
// 修复 1：明确指定类型
func describePairs(_ pairs: [Pair<Int>]) {
    for p in pairs {
        print("\(p.first), \(p.second)")
    }
}

// 修复 2：让函数也泛型
func describePairs<T>(_ pairs: [Pair<T>]) {
    for p in pairs {
        print("\(p.first), \(p.second)")
    }
}

// 修复 3：用 some（如果只需要调用 T 的某些接口）
func describePairs(_ pairs: [Pair<some CustomStringConvertible>]) {
    for p in pairs {
        print("\(p.first), \(p.second)")
    }
}
```

</details>

---

## 延伸阅读

学习完泛型后，你可能还想了解：

- [Swift 官方文档 - Generics](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/generics/) - 泛型完整说明
- [Swift 官方文档 - Generic Parameters and Arguments](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/generics/#Generic-Parameters-and-Arguments) - 泛型参数深入
- [Swift by Sundell - Generics](https://www.swiftbysundell.com/articles/generics-in-swift/) - 泛型最佳实践

**选择建议**:
- 初学者 → 继续学习 [错误处理](error-handling.md) 或回顾协议知识
- 想深入 Swift 泛型体系 → 阅读 Swift 标准库源码（开源在 GitHub）

> 💡 **记住**：泛型是 Swift 类型安全的核心支柱。标准库的每一个集合类型、每一个错误处理机制都以泛型为基础。写泛型代码时，约束应该尽量宽松，满足实际需求即可。

---

## 继续学习

- 回顾：[协议](protocols.md) - 理解协议约束是泛型的基础
- 相关：[类与对象](classes-objects.md) - 泛型也可用于类
- 进阶：[错误处理](error-handling.md) - `Result<Success, Failure>` 是泛型的经典应用
