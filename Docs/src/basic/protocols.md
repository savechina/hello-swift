# 协议

## 开篇故事

想象你开了一家餐厅。你不需要知道每个厨师来自哪里，受过什么训练，甚至不需要他们是正式员工还是临时工。你只需要确保：每个厨师都能按照菜谱做菜，都能在规定时间完成出餐，都能保证菜品卫生。

Swift 中的**协议**（Protocol）就是这份"菜谱"。它定义了一组要求，任何类型只要满足这些要求，就能被接受。结构体可以遵守协议，类可以遵守协议，枚举甚至可以扩展已有类型来遵守协议。

协议是 Swift 区别于其他语言的核心特性之一。Swift 倡导**面向协议编程**（Protocol-Oriented Programming, POP），而不是传统的类继承体系。这种设计让代码更灵活、更可组合、更容易测试。

---

## 本章适合谁

如果你理解了类、继承和值类型的概念，想理解 Swift 更灵活的抽象方式，本章适合你。如果你来自 Java 或 C#，你会发现 Swift 的协议比接口更强大。如果你来自 Rust，你会发现 Swift 协议和 Trait 有很多相似之处，但也有自己的特点。

---

## 你会学到什么

完成本章后，你可以：

1. 使用 `protocol` 关键字定义协议并让类型遵守
2. 理解协议方法、属性要求和 `mutating` 关键字
3. 使用协议扩展（Protocol Extension）提供默认实现
4. 掌握协议组合（Protocol Composition）和 `some` 关键字
5. 理解面向协议编程（POP）与类继承的区别

---

## 前置要求

确保你已经阅读了 [类与对象](classes-objects.md) 一章，理解类、结构体、继承和 Swift 的基本类型系统。本章讨论的协议概念是在这些基础之上的更高级抽象。

---

## 第一个例子

打开 `Sources/BasicSample/ExampleProtocol.swift`，看最基础的定义：

```swift
protocol ExampleProtocol {
    var simpleDescription: String { get }
    mutating func adjust()
}
```

**发生了什么？**

- `protocol` 关键字定义协议
- `var simpleDescription: String { get }` 声明一个只读属性要求
- `mutating func adjust()` 声明一个会修改自身的方法要求

不同的类型可以以自己的方式遵守这个协议：

```swift
/// 结构体遵守协议
struct SimpleStructure: ExampleProtocol {
    var simpleDescription: String = "A simple structure"
    mutating func adjust() {
        simpleDescription += " (adjusted)"
    }
}

/// 类遵守协议
class SimpleClass: ExampleProtocol {
    var simpleDescription: String = "A very simple class."
    func adjust() {  // 注意：类不需要 mutating
        simpleDescription += "  Now 100% adjusted."
    }
}
```

**使用示例**：

```swift
var structure = SimpleStructure()
print(structure.simpleDescription)
structure.adjust()
print(structure.simpleDescription)

let classInstance = SimpleClass()
print(classInstance.simpleDescription)
classInstance.adjust()
print(classInstance.simpleDescription)
```

**输出**：
```
A simple structure
A simple structure (adjusted)
A very simple class.
A very simple class.  Now 100% adjusted.
```

---

## 原理解析

### 1. 协议定义与基本遵守

协议定义类型必须满足的一组要求。一个类型可以同时遵守多个协议：

```swift
protocol Describable {
    var description: String { get }
}

protocol Identifiable {
    var id: Int { get set }
}

// 同时遵守两个协议
struct Product: Describable, Identifiable {
    let name: String
    var id: Int
    var description: String { "Product #\(id): \(name)" }
}

let product = Product(name: "Widget", id: 42)
print(product.description)  // "Product #42: Widget"
```

**协议要求包括**：
- 实例属性和类型属性（`var`、`static var`）
- 实例方法和类型方法（`func`、`static func`）
- 下标（`subscript`）
- 协议本身也可以继承其他协议

### 2. mutating 关键字

`mutating` 是协议方法要求中的一个特殊关键字。它告诉编译器：这个方法会修改调用它的实例。

```swift
protocol Toggleable {
    var isOn: Bool { get set }
    mutating func toggle()  // 会修改自身
}

// 结构体需要 mutating
struct LightSwitch: Toggleable {
    var isOn: Bool = false
    mutating func toggle() {
        isOn = !isOn
    }
}

// 类不需要 mutating（类方法默认可以修改属性）
class Lamp: Toggleable {
    var isOn: Bool = false
    func toggle() {  // 不需要 mutating
        isOn = !isOn
    }
}
```

**为什么需要 mutating？**

因为 Swift 中结构体和枚举是值类型，默认方法不能修改自身属性。`mutating` 明确标记"这个方法会替换掉 self"。对于类来说，它是引用类型，方法本来就可以修改属性，所以不需要 `mutating`。

### 3. 协议扩展与默认实现

协议的真正威力在于**协议扩展**（Protocol Extension）。你可以为协议方法提供默认实现，让遵守者可以选择不覆盖：

```swift
protocol Animal {
    func makeSound() -> String
    func greet() -> String
}

// 给 greet 提供默认实现
extension Animal {
    func greet() -> String {
        return "The animal says: \(makeSound())"
    }
}

struct Dog: Animal {
    func makeSound() -> String { "Woof" }
    // greet() 使用默认实现
}

struct Cat: Animal {
    func makeSound() -> String { "Meow" }
    // 覆盖默认实现
    func greet() -> String {
        return "Cat: \(makeSound())! *purrs*"
    }
}

print(Dog().greet())  // "The animal says: Woof"
print(Cat().greet())   // "Cat: Meow! *purrs*"
```

**协议扩展 vs 类继承**：

| 特性 | 类继承 | 协议扩展 |
|------|--------|----------|
| 支持的类型 | 仅类 | 类、结构体、枚举 |
| 多继承 | 不支持（单继承） | 可以实现多个协议 |
| 已有类型扩展 | 不能扩展没有源码的类 | 可以扩展任何类型 |
| 默认实现 | 在父类提供 | 在协议扩展提供 |
| 分发方式 | 动态分发（虚函数表） | 静态分发（更快） |

### 4. 协议作为类型（多态）

协议本身也是一个类型。这意味着你可以把协议用于变量声明、函数参数、数组元素等：

```swift
protocol Drawable {
    func draw() -> String
}

struct Circle: Drawable {
    func draw() -> String { "  ○  " }
}

struct Square: Drawable {
    func draw() -> String { "  ■  " }
}

// 协议作为数组元素类型
let shapes: [Drawable] = [Circle(), Square(), Circle()]

for shape in shapes {
    print(shape.draw())
}
```

这就是 Swift 的**协议多态**（Protocol Polymorphism）。它和类继承的多态效果一样，但不依赖继承体系。

来自项目中的实际应用：

```swift
// ExampleProtocol.swift 中对 Int 的扩展
extension Int: ExampleProtocol {
    var simpleDescription: String {
        return "The number \(self)"
    }
    mutating func adjust() {
        self += 42
    }
}

// 现在所有整数都实现了 ExampleProtocol
let x: ExampleProtocol = 7
print(x.simpleDescription)  // "The number 7"
```

### 5. associatedtype 关联类型

关联类型让协议可以定义一个"占位符类型"，具体类型由遵守者决定：

```swift
protocol Container {
    associatedtype Item
    var count: Int { get }
    subscript(i: Int) -> Item { get }
    mutating func append(_ item: Item)
}

struct IntStack: Container {
    typealias Item = Int  // 关联类型设为 Int
    var items: [Int] = []
    var count: Int { items.count }
    subscript(i: Int) -> Int { items[i] }
    mutating func append(_ item: Int) {
        items.append(item)
    }
}

struct StringStack: Container {
    typealias Item = String  // 关联类型设为 String
    var items: [String] = []
    var count: Int { items.count }
    subscript(i: Int) -> String { items[i] }
    mutating func append(_ item: String) {
        items.append(item)
    }
}
```

**关联类型 vs 泛型**：
- 泛型参数在定义时指定（如 `Array<Int>`）
- 关联类型由类型的实现决定，使用者不需要显式指定

Swift 标准库中大量使用关联类型。比如 `Sequence` 协议就有 `Element` 关联类型，所以 `for-in` 循环能适用于 `Array`、`Dictionary`、`String` 等所有序列类型。

### 6. 协议组合

Sometimes you want a value to conform to multiple protocols simultaneously. Swift uses the `&` operator for protocol composition:

```swift
protocol Named {
    var name: String { get }
}

protocol Aged {
    var age: Int { get }
}

struct Person: Named, Aged {
    let name: String
    let age: Int
}

// 协议组合作为参数类型
func printInfo(_ person: Named & Aged) {
    print("\(person.name), age \(person.age)")
}

let bob = Person(name: "Bob", age: 30)
printInfo(bob)  // "Bob, age 30"
```

协议组合不创建新类型，它只是一个临时的"同时满足多个协议"约束。

### 7. some 关键字（不透明类型）

Swift 5.1 引入了 `some` 关键字，让函数可以返回"符合某个协议的某个具体类型"，而不暴露具体类型：

```swift
protocol Shape {
    func area() -> Double
}

struct Triangle: Shape {
    let base: Double
    let height: Double
    func area() -> Double { base * height / 2 }
}

// some Shape = 返回某个遵守 Shape 的具体类型，但调用者不知道是什么
func makeDefaultShape() -> some Shape {
    Triangle(base: 10, height: 5)
}

// 调用者只能用 Shape 定义的接口
let shape = makeDefaultShape()
print(shape.area())  // 25.0
// print(shape.base)  // ❌ 编译错误！调用者不知道底层类型
```

**`some` vs 协议类型的区别**：

```swift
// 协议类型 — 可以是任意遵守协议的类型的混合
func describe1() -> Shape {  // 返回类型可以是任何 Shape
    Triangle(base: 10, height: 5)
}
// 每次调用可以返回不同类型

// some 关键字 — 必须是某个具体类型
func describe2() -> some Shape {  // 返回类型固定，但隐藏
    Triangle(base: 10, height: 5)
}
// 每次调用必须返回相同的具体类型
// 编译器能在编译期知道具体类型，可以做更好的优化
```

`some` 关键字在 SwiftUI 中大量使用，`View` 协议返回值的标准写法就是 `some View`。

### 8. 面向协议编程 vs 类继承

| 维度 | 类继承 | 面向协议编程（POP） |
|------|--------|-------------------|
| 适用类型 | 仅类 | 类、结构体、枚举 |
| 多重继承 | 不支持 | 通过多协议实现 |
| 默认行为 | 父类方法 | 协议扩展默认实现 |
| 已有类型扩展 | 不能 | 可以（扩展 Int、String 等） |
| 内存模型 | 引用类型 | 可选值类型或引用类型 |
| 分发 | 动态（运行时） | 静态（编译时，更快） |
| 测试性 | 需要 mock 父类 | 更容易 mock（值类型） |

Swift 标准库几乎完全基于协议构建：`Equatable`、`Comparable`、`Hashable`、`Sequence`、`Collection`、`Codable` ...... 这些协议让你的自定义类型一键获得丰富的功能。

---

## 常见错误

### 错误 1: 结构体中忽略 mutating 关键字

```swift
protocol Counter {
    func increment()
}

struct SimpleCounter: Counter {
    var count = 0
    func increment() {  // ❌ 缺少 mutating
        count += 1
    }
}
```

**编译器输出**：
```
error: cannot assign to property: 'self' is immutable
note: protocol requires function 'increment()' with 'mutating' modifier
```

**修复方法**：
```swift
struct SimpleCounter: Counter {
    var count = 0
    mutating func increment() {  // ✅ 加 mutating
        count += 1
    }
}
```

### 错误 2: 协议作为返回类型时混用不同类型

```swift
protocol Shape {
    func draw() -> String
}

struct Circle: Shape { func draw() -> String { "○" } }
struct Square: Shape { func draw() -> String { "■" } }

func randomShape() -> Shape {
    if Bool.random() {
        return Circle()
    } else {
        return Square()   // ✅ 这可以 — 返回协议类型允许混用
    }
}
```

**但如果用 some 关键字就不行**：

```swift
func randomShape() -> some Shape {  // ❌ some 要求返回具体同一类型
    if Bool.random() {
        return Circle()
    } else {
        return Square()  // 编译错误！
    }
}
```

**编译器输出**：
```
error: function declares an opaque return type, but the return statements
       in its body do not have matching underlying types
```

**修复方法**：用协议类型（`Shape`）而不是不透明类型（`some Shape`）：

```swift
func randomShape() -> Shape {  // ✅ 协议类型允许混用
    if Bool.random() {
        return Circle()
    } else {
        return Square()
    }
}
```

### 错误 3: 协议中含有 associatedtype 不能直接用作类型

```swift
protocol Container {
    associatedtype Item
    func count() -> Int
}

// ❌ 不能直接用作类型 — 编译器不知道 Item 是什么
let container: Container = ...
```

**编译器输出**：
```
error: protocol 'Container' can only be used as a generic constraint
       because it has Self or associated type requirements
```

**修复方法**：用泛型或 some 关键字约束：

```swift
// 泛型约束
func useContainer<C: Container>(_ c: C) {
    print(c.count())
}

// 或者 some 关键字
func makeContainer() -> some Container {
    // 返回某个具体的 Container 实现
}
```

---

## Swift vs Rust/Python 对比

| 概念 | Python | Rust | Swift | 关键差异 |
|------|--------|------|-------|----------|
| 协议/接口 | ABC（抽象基类）/ Protocol (typing) | Trait | Protocol | Swift 协议可以有默认实现 |
| 扩展已有类型 | 不能（需猴子补丁） | 可以（impl Trait for Type）| 可以（extension Type: Protocol） | Swift 和 Rust 都支持 |
| 多继承 | 支持 | 不支持（实现多个 Trait） | 不支持（遵守多个协议） | Swift 协议组合用 `&` |
| 关联类型 | 无 | Associated Type | `associatedtype` | Swift/Rust 高度相似 |
| 不透明返回 | 无 | `impl Trait` | `some Protocol` | 等价功能 |
| 分发方式 | 动态 | 静态（泛型）或动态（dyn） | 静态（泛型/some）或动态（协议） | Swift some 用静态分发 |
| mutating | self 总是可变 | `&mut self` | `mutating`（值类型） | 概念类似，语法不同 |

---

## 动手练习

### 练习 1: 协议的基本遵守

定义一个 `Mathable` 协议，要求有一个 `calculate()` → Double 方法。让 `Rectangle` 和 `Circle` 两个结构体遵守它，各自实现面积计算。

<details>
<summary>点击查看答案</summary>

```swift
protocol Mathable {
    func calculate() -> Double
}

struct Rectangle: Mathable {
    let width: Double
    let height: Double
    func calculate() -> Double {
        width * height
    }
}

struct Circle: Mathable {
    let radius: Double
    func calculate() -> Double {
        .pi * radius * radius
    }
}

let rect = Rectangle(width: 5, height: 3)
let circle = Circle(radius: 4)
print(rect.calculate())    // 15.0
print(circle.calculate())   // 50.26548245743669
```

</details>

### 练习 2: 协议扩展默认实现

扩展上题的 `Mathable` 协议，添加一个 `description()` 方法，默认返回 "Area: X" 格式的字符串。让 `Rectangle` 覆盖它，返回 "Rectangle: width x height"。

<details>
<summary>点击查看答案</summary>

```swift
extension Mathable {
    func description() -> String {
        "Area: \(calculate())"
    }
}

extension Rectangle {
    func description() -> String {
        "Rectangle: \(width) x \(height)"
    }
}

let rect = Rectangle(width: 5, height: 3)
let circle = Circle(radius: 4)
print(rect.description())   // "Rectangle: 5.0 x 3.0" (覆盖实现)
print(circle.description())  // "Area: 50.26548245743669" (默认实现)
```

</details>

### 练习 3: 关联类型容器

实现一个 `Stack` 类型，遵守以下协议协议定义了 `push`、`pop` 和 `peek` 方法：

```swift
protocol Storable {
    associatedtype Item
    mutating func push(_ item: Item)
    mutating func pop() -> Item?
    func peek() -> Item?
}
```

<details>
<summary>点击查看答案</summary>

```swift
struct Stack<Item>: Storable {
    private var items: [Item] = []

    mutating func push(_ item: Item) {
        items.append(item)
    }

    mutating func pop() -> Item? {
        items.popLast()
    }

    func peek() -> Item? {
        items.last
    }
}

// 使用
var stack = Stack<Int>()
stack.push(1)
stack.push(2)
stack.push(3)
print(stack.peek() ?? "nil")  // Optional(3)
print(stack.pop() ?? "nil")   // 3
print(stack.pop() ?? "nil")   // 2
```

</details>

---

## 故障排查 FAQ

### Q: 协议（Protocol）和类继承，我应该选哪个？

**A**: Swift 社区的共识是：优先考虑协议。

- **优先用协议 + 结构体** - 值类型 + 协议组合更安全、更可测试
- **需要共享状态或身份时** - 用类（比如 UIView 的子类化）
- **需要扩展已有库的类型** - 只能用协议，不能继承没有源码的类
- **多态需求** - 协议比继承更灵活，一个类型可以遵守多个协议

> Apple 自己的框架也越来越多地采用协议。SwiftUI 的 `View` 协议就是一个协议，而不是基类。

### Q: `some Protocol` 和 `protocol` 类型作为返回值有什么区别？

**A**: 关键区别在于类型确定性和性能：

- `some Protocol`（不透明类型）— 编译器知道具体类型，可以做内联优化，但所有返回路径必须是同一具体类型
- `protocol`（协议类型）— 运行时动态分发，允许不同返回路径，但有一点性能开销

如果你每次返回相同的类型，用 `some`。如果你需要返回不同类型的值，用协议类型。

### Q: associatedtype 和泛型参数有什么区别？

**A**: 它们解决的问题不同：

- **泛型参数** — 调用者决定。比如 `Array<Int>`，你告诉 Array 元素的类型
- **关联类型** — 实现者决定。比如你实现的 `Container`，你把 `Item` 设为什么就是什么，使用者不用管

类比思考：泛型参数像是菜单上点菜（客人选），关联类型像是套餐配什么菜（厨师定）。

---

## 小结

**核心要点**：

1. **协议定义类型要求** - 属性、方法、下标可以成为协议要求
2. **协议扩展提供默认实现** - 让遵守者可选覆盖，类似"继承"但不限制类型
3. **协议作为类型使用** - 实现多态，支持 `[Protocol]` 数组和协议参数
4. **`associatedtype` 定义占位类型** - 由遵守者决定具体类型
5. **`some Protocol` 是不透明返回类型** - 隐藏具体类型但保留编译期类型信息

**关键术语**：

- **Protocol**: 协议（定义一组要求）
- **Conformance**: 遵守（类型满足协议要求）
- **Protocol Extension**: 协议扩展（为协议提供默认实现）
- **Associated Type**: 关联类型（协议中的占位类型）
- **Protocol Composition**: 协议组合（同时满足多个协议）
- **Opaque Type**: 不透明类型（`some Protocol`）
- **Protocol-Oriented Programming**: 面向协议编程（POP）

---

## 术语表

| English | 中文 |
|---------|------|
| Protocol | 协议 |
| Conformance | 遵守 |
| Protocol Extension | 协议扩展 |
| Default Implementation | 默认实现 |
| Associated Type | 关联类型 |
| Protocol Composition | 协议组合 |
| Opaque Type | 不透明类型 |
| Protocol-Oriented Programming | 面向协议编程 |
|mutating | 可变（方法会修改 self） |
| Static Dispatch | 静态分发 |
| Dynamic Dispatch | 动态分发 |

完整示例：`Sources/BasicSample/ExampleProtocol.swift`

---

## 知识检查

**问题 1** 🟢 (基础概念)

```swift
protocol Greetable {
    func greet() -> String
}

struct Person: Greetable {
    let name: String
    func greet() -> String { "Hello, I'm \(name)" }
}

let p: Greetable = Person(name: "Alice")
print(p.greet())
```

输出是什么？

A) 编译错误 — 协议不能实例化  
B) "Hello, I'm Alice"  
C) "Greetable"  
D) 运行时错误

<details>
<summary>答案与解析</summary>

**答案**: B) "Hello, I'm Alice"

**解析**: 协议可以作为类型使用。`p` 的静态类型是 `Greetable`，但实际存储的是 `Person` 实例。调用 `greet()` 时会动态分发给 `Person` 的实现。这就是协议多态。

</details>

**问题 2** 🟡 (mutating 关键字)

```swift
protocol Flipable {
    var state: Bool { get set }
    func flip()
}

enum Switch: Flipable {
    case on, off
    var state: Bool { self == .on }
    func flip() {
        self = (self == .on) ? .off : .on  // 修改 self
    }
}
```

能编译通过吗？

A) 能  
B) 不能，flip 需要 mutating  
C) 不能，枚举不能用 computed property  
D) 不能，self 不能赋值

<details>
<summary>答案与解析</summary>

**答案**: B) 不能，flip 需要 mutating

**解析**: 枚举是值类型，修改 `self`（整体赋值）的方法需要标记 `mutating`。在协议中声明的方法也需要加 `mutating`：

```swift
protocol Flipable {
    var state: Bool { get set }
    mutating func flip()  // ✅ 加 mutating
}

enum Switch: Flipable {
    case on, off
    var state: Bool { self == .on }
    mutating func flip() {          // ✅ 结构体/枚举需要
        self = (self == .on) ? .off : .on
    }
}
```

</details>

**问题 3** 🔴 (协议与 some 的区别)

```swift
protocol Drawable {
    func draw() -> String
}

struct Line: Drawable {
    func draw() -> String { "———" }
}

struct Box: Drawable {
    func draw() -> String { "┌─┐\n└─┘" }
}

func createDrawing(useBox: Bool) -> some Drawable {
    if useBox {
        return Box()
    } else {
        return Line()
    }
}
```

能编译通过吗？

A) 能  
B) 不能 — some 要求所有返回路径是同一具体类型  
C) 不能 — 协议需要 associatedtype  
D) 能 — 会自动装箱

<details>
<summary>答案与解析</summary>

**答案**: B) 不能 — some 要求所有返回路径是同一具体类型

**解析**: `some Drawable` 是**不透明类型**，意味着返回值必须是某个**具体的、同一的类型**，只是隐藏了这个类型给调用者。if/else 返回 `Box` 和 `Line` 两个不同具体类型，违反了此约束。

**修复** — 改用协议类型（动态分发）：

```swift
func createDrawing(useBox: Bool) -> Drawable {  // ✅ 协议类型
    if useBox {
        return Box()
    } else {
        return Line()
    }
}
```

或者固定返回一种类型：

```swift
func createBox() -> some Drawable {   // ✅ 总是返回 Box
    Box()
}
```

</details>

---

## 延伸阅读

学习完协议后，你可能还想了解：

- [Swift 官方文档 - Protocols](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/protocols/) - 协议完整说明
- [WWDC 2015 - Protocol-Oriented Programming in Swift](https://developer.apple.com/videos/play/wwdc2015/408/) - Apple 官方 POP 讲座
- [Swift by Sundell - Protocol Extensions](https://www.swiftbysundell.com/articles/protocol-extensions-in-swift/) - 协议扩展最佳实践

**选择建议**:
- 初学者 → 继续学习 [泛型](generics.md)，理解类型安全的通用代码
- 想深入 Swift 设计哲学 → 阅读 [Swift 标准库协议体系](https://docs.swift.org/swift-book/documentation/the-swift-programminglanguage/protocols/)

> 💡 **记住**：Swift 的最佳实践是"协议优先"。能不用继承就不用继承。用协议定义能力，用扩展提供默认实现，用值类型保证安全。

---

## 继续学习

- 下一步：[泛型](generics.md) - 编写可复用的类型安全代码
- 相关：[类与对象](classes-objects.md) - 理解引用类型的继承体系
- 进阶：[错误处理](error-handling.md) - Protocol + 泛型的实战应用
