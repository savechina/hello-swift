# 枚举

## 开篇故事

想象你是一个气象站的预报员。天气有几种固定的状态：晴天、雨天、雪天、多云。但你不能简单用一个字符串表示，因为类型拼写错误会让程序崩溃。

Swift 的**枚举**（enum）就是为这种场景而生的。它限制值只能从一组预定义的选项中选择，让编译器帮你检查所有可能性。不仅如此，Swift 的枚举比其他语言更强大：它可以携带额外数据，可以定义行为方法，甚至可以递归定义数据结构。

---

## 本章适合谁

如果你希望用类型安全的方式管理一组相关的选择，或者想理解 Swift 枚举为什么被称为"最像数据结构的枚举"，本章适合你。从简单的状态标识到复杂的模式匹配，枚举是 Swift 编程中最重要的基础之一。

---

## 你会学到什么

完成本章后，你可以：

1. 使用 `enum` 关键字定义基本枚举类型
2. 理解关联值（associated values）和原始值（raw values）的区别
3. 使用 `CaseIterable` 协议和 `allCases` 遍历所有枚举值
4. 用 `switch` 语句对枚举进行穷尽匹配
5. 使用 `indirect` 关键字定义递归枚举

---

## 前置要求

本章前置知识：阅读过 [函数](functions.md)，熟悉函数基本定义和 `switch` 语句的概念。

---

## 第一个例子

打开 `Sources/BasicSample/EnumSample.swift`，找到最简单的枚举定义：

```swift
enum CompassPoint {
    case north, south, east, west
}

var direction = CompassPoint.north
direction = .south  // 类型已知时可省略前缀
print("Direction: \(direction)")
// 输出: Direction: south
```

**发生了什么？**

- `enum CompassPoint` — 定义一个枚举类型
- `case north, south, east, west` — 列出所有可能的值
- `CompassPoint.north` — 通过点语法访问枚举值，类似命名空间

---

## 原理解析

### 1. 基本枚举定义

Swift 枚举的每个值称为**成员**（member）。枚举成员不属于整数或字符串，它们是独立的类型：

```swift
enum Planet {
    case mercury, venus, earth, mars, jupiter
}

let homePlanet = Planet.earth
```

与 C 语言不同，Swift 的枚举值没有隐式的整数编号。每个值就是一个纯粹的类型安全的选项。

### 2. 关联值（Associated Values）

Swift 枚举的每个成员可以携带不同类型和数量的数据，这称为**关联值**：

```swift
enum Barcode {
    case upc(Int, Int, Int, Int)
    case qrCode(String)
}

var productBarcode = Barcode.upc(8, 85909, 51226, 3)
productBarcode = .qrCode("ABCDEFGHIJKLMNOP")
```

同一个枚举的不同成员可以携带完全不同的数据结构，这在做 API 返回结果建模时非常有用：

```swift
enum NetworkResult {
    case success(String)
    case failure(Error)
}

func fetchData() -> NetworkResult {
    .success("data from server")
}
```

### 3. 原始值（Raw Values）

如果你的枚举成员需要一个固定的基础值，可以用**原始值**。原始值类型在枚举定义中声明：

```swift
enum Season: String {
    case spring = "春暖花开"
    case summer = "夏日炎炎"
    case autumn = "秋高气爽"
    case winter = "冬日寒寒"
}

print(Season.summer.rawValue)
// 输出: 夏日炎炎

if let fall = Season(rawValue: "秋高气爽") {
    print("Found: \(fall)")
    // 输出: Found: autumn
}
```

注意 `rawValue` 反向查找返回的是可选值，因为传入的值可能不在枚举定义中。

### 4. CaseIterable 协议

让枚举遵守 `CaseIterable` 协议后，Swift 会生成 `allCases` 属性：

```swift
enum Planet: CaseIterable {
    case mercury, venus, earth, mars, jupiter
}

for planet in Planet.allCases {
    print("Planet: \(planet)")
}
```

这在需要遍历所有选项的场景（比如构建选择菜单、初始化默认状态）非常实用。

### 5. Switch 穷尽匹配

`switch` 语句在匹配枚举时要求覆盖所有情况。如果漏了某个 case，编译器会报错：

```swift
let homePlanet = Planet.earth

switch homePlanet {
case .mercury:
    print("Closest to the Sun")
case .venus:
    print("Hottest planet")
case .earth:
    print("Our home")
case .mars:
    print("The Red Planet")
case .jupiter:
    print("Largest planet")
}
```

**为什么不需要 `default`？**

因为枚举只有这五个值，编译器能静态验证你覆盖了所有可能。省略 `default` 让新增枚举值时不会遗漏处理逻辑。

### 6. 递归枚举（Indirect）

当枚举的成员包含自身类型时，需要使用 `indirect` 关键字：

```swift
indirect enum ArithmeticExpression {
    case number(Int)
    case addition(ArithmeticExpression, ArithmeticExpression)
    case multiplication(ArithmeticExpression, ArithmeticExpression)
}

func evaluate(_ expression: ArithmeticExpression) -> Int {
    switch expression {
    case .number(let value):
        return value
    case .addition(let left, let right):
        return evaluate(left) + evaluate(right)
    case .multiplication(let left, let right):
        return evaluate(left) * evaluate(right)
    }
}

let five = ArithmeticExpression.number(5)
let four = ArithmeticExpression.number(4)
let sum = ArithmeticExpression.addition(five, four)
let product = ArithmeticExpression.multiplication(sum, ArithmeticExpression.number(2))

print("Result: \(evaluate(product))")
// 输出: Result: 18
```

`indirect` 告诉 Swift 编译器把这个成员存储在堆上，避免无限递归的内存布局问题。这是实现语法树和表达式树的典型模式。

### 7. Optional 类型本身就是枚举

Swift 的 `Optional<T>` 其实就是一个标准库定义的枚举：

```swift
enum Optional<T> {
    case none
    case some(T)
}
```

`nil` 就是 `.none`，而 `optionalValue!` 就是 `.some(wrapped)` 的简写。理解这一点后，你就能明白为什么 Swift 的可选类型在 `switch` 中表现和枚举完全一致。

---

## 常见错误

### 错误 1: Switch 未覆盖所有情况

```swift
enum Color { case red, green, blue }

let color = Color.red
switch color {
case .red:
    print("Red")
case .green:
    print("Green")
// ❌ 漏了 .blue
}
```

**编译器输出**:

```
error: switch must be exhaustive and consider all possible cases
```

**修复方法**:

```swift
// 补全所有 case
case .blue:
    print("Blue")
```

### 错误 2: 忘记 indirect 关键字

```swift
enum Expression {
    case number(Int)
    case add(Expression, Expression)  // ❌
}
```

**编译器输出**:

```
error: enum case 'add' is indirectlyrecursive through 'Expression'
```

**修复方法**:

```swift
indirect enum Expression {  // ✅
    case number(Int)
    case add(Expression, Expression)
}
```

### 错误 3: RawValue 类型不匹配

```swift
enum Size: Int {
    case small = "S"      // ❌
    case medium = "M"
}
```

**编译器输出**:

```
error: raw value for enum case must be of type 'Int'
```

**修复方法**:

```swift
enum Size: String {       // ✅ 改为 String
    case small = "S"
    case medium = "M"
}
```

---

## Swift vs Rust/Python 对比

| 概念 | Python | Rust | Swift | 关键差异 |
|---|---|---|---|---|
| 基本枚举 | `Enum` class 子类 | `enum Name { A, B }` | `enum Name { case A, B }` | Swift 需要 `case` 关键字 |
| 关联值 | 无（用 dataclass 模拟） | `enum E { A(i32), B(String) }` | `enum E { case a(Int), b(String) }` | Rust 和 Swift 都有关联值 |
| 原始值 | `auto()` 或手动赋值 | `enum E: Type { A = val }` | `enum E: Type { case A = "val" }` | 语法相似，Swift 更严格 |
| 穷尽检查 | 无运行时保证 | `non-exhaustive pattern` 警告 | 编译时报错 | Swift 的编译器检查最严格 |
| 递归枚举 | 无直接支持 | `Box` 间接引用 | `indirect` 关键字 | Swift 内置支持，无需手动装箱 |
| 枚举方法 | 可以定义 | `impl` 块 | 直接在 enum 内定义 | Swift 更简洁 |
| Optional enum | `Optional[T]` 在 typing 模块中 | `Option<T>` | 标准库 `enum Optional<T>` | Swift/Rust 的 Optional 设计一致 |

---

## 动手练习

### 练习 1: 预测枚举匹配

不运行代码，预测下面代码的输出：

```swift
enum TrafficLight { case red, yellow, green }

let light = TrafficLight.yellow
switch light {
case .red:
    print("Stop")
case .yellow:
    print("Slow down")
case .green:
    print("Go")
}
```

<details>
<summary>点击查看答案</summary>

**输出**:

```
Slow down
```

**解析**: `light` 的值是 `.yellow`，命中第二个 case 分支。

</details>

### 练习 2: 定义一个关联值枚举

定义一个 `Shape` 枚举，包含 `circle`（带半径 Double）和 `rectangle`（带 width 和 height 两个 Double）。写一个 `area()` 方法计算面积。

<details>
<summary>点击查看参考实现</summary>

```swift
enum Shape {
    case circle(radius: Double)
    case rectangle(width: Double, height: Double)

    func area() -> Double {
        switch self {
        case .circle(let radius):
            return .pi * radius * radius
        case .rectangle(let width, let height):
            return width * height
        }
    }
}

let c = Shape.circle(radius: 5.0)
print(c.area())  // 78.539...
```

</details>

### 练习 3: RawValue 查找

定义一个枚举 `Language`，原始值为字符串（中文表示：日语、英语、法语）。写代码通过 `rawValue: "法语"` 反向查找对应枚举值并打印。

<details>
<summary>点击查看参考实现</summary>

```swift
enum Language: String {
    case japanese = "日语"
    case english = "英语"
    case french = "法语"
}

if let lang = Language(rawValue: "法语") {
    print("Found: \(lang), value: \(lang.rawValue)")
}
```

</details>

---

## 故障排查 FAQ

### Q: 关联值和原始值可以同时用吗？

**A**: 不行。一个枚举要么有关联值，要么有原始值，不能混用。原始值适合简单标识场景，关联值适合需要携带数据的场景。

### Q: 为什么枚举不需要 `default` 分支？

**A**: 编译器能静态确认枚举的所有成员都被覆盖。这意味着将来有人新增了枚举值时，你的代码不会悄悄走 `default`，而是直接在编译时报错提醒你处理。

### Q: `indirect` 关键字的性能影响大吗？

**A**: `indirect` 让 Swift 在堆上分配内存，相比栈上有略微开销，但在实际使用中完全可以忽略。这是实现递归数据结构的必要代价，和 Rust 的 `Box` 类似。

---

## 小结

**核心要点**:

1. **`enum` 定义枚举类型** — 成员通过 `case` 声明，彼此独立
2. **关联值** — 让每个成员携带不同的附加数据
3. **原始值** — 让枚举有基础类型（String/Int），支持 `rawValue` 读写
4. **`CaseIterable`** — 自动生成 `allCases` 列表，方便遍历
5. **Switch 穷尽匹配** — 编译器确保所有 cases 都被覆盖

**关键术语**:

- **Enum**: 枚举（一组类型安全的命名值）
- **Associated Value**: 关联值（枚举成员附加的数据）
- **Raw Value**: 原始值（枚举成员的基础固定值）
- **CaseIterable**: 协议（自动生成 `allCases`）
- **Indirect**: 间接存储（支持递归枚举）
- **Exhaustive Matching**: 穷尽匹配（覆盖所有枚举情况）

---

## 术语表

| English | 中文 |
|---|---|
| Enumeration | 枚举 |
| Associated Value | 关联值 |
| Raw Value | 原始值 |
| CaseIterable | 可遍历协议 |
| All Cases | 所有成员 |
| Indirect | 间接存储 |
| Exhaustive Matching | 穷尽匹配 |
| Pattern Matching | 模式匹配 |
| Optional Enumeration | 可选枚举 |
| Member | 枚举成员 |

完整示例：`Sources/BasicSample/EnumSample.swift`

---

## 知识检查

**问题 1** 🟢（基础概念）

```swift
enum Direction { case up, down, left, right }
let d: Direction = .down
```

`.down` 的类型是什么？

A) `String`
B) `Int`
C) `Direction`
D) `Void`

<details>
<summary>答案与解析</summary>

**答案**: C) `Direction`

**解析**: 枚举成员 `.down` 的类型就是它所属的枚举类型 `Direction`。枚举值不是字符串也不是整数。
</details>

**问题 2** 🟡（关联值理解）

```swift
enum Shape { case circle(Double), rectangle(width: Double, height: Double) }
```

以下哪个赋值正确？

A) `Shape.circle(5)`
B) `Shape.rectangle(width: 3.0, height: 4.0)`
C) A 和 B 都对

<details>
<summary>答案与解析</summary>

**答案**: C) A 和 B 都对

**解析**: 两个都是有效的关联值调用。`circle` 关联一个值，`rectangle` 关联两个命名元素。Swift 会根据调用上下文自动匹配。
</details>

**问题 3** 🔴（递归枚举）

```swift
indirect enum Expr {
    case value(Int)
    case add(Expr, Expr)
    case mul(Expr, Expr)
}
```

如果要表示表达式 `(3 + 5) * 2`，下列写法正确的是？

<details>
<summary>答案与解析</summary>

**答案**:

```swift
let expr = Expr.mul(
    Expr.add(Expr.value(3), Expr.value(5)),
    Expr.value(2)
)
```

**解析**: 递归枚举把子表达式作为关联值嵌入父节点。`add` 节点包含两个 `value`，外层 `mul` 把 `add` 的结果乘以 2。这就是抽象语法树（AST）的典型表示方式。
</details>

---

## 延伸阅读

学习完枚举后，你可能还想了解：

- [Swift 官方文档 — Enumerations](https://docs.swift.org/swift-book/documentation/the-basics/#Enumeration-Basics) — 枚举完整语法
- [Swift by Sundell — Enums](https://www.swiftbysundell.com/articles/swift-enums/) — 枚举在实战中的最佳实践

**选择建议**:

- 初学者 → 继续学习 [结构体](structs.md)
- 有经验的程序员 → 跳到 [协议](protocols.md)

> 记住：Swift 的枚举是真正的数据类型，不是简单的整数别名。它可以携带数据、定义方法、实现协议——这是 Swift 类型安全的基石。

---

## 继续学习

- 下一步：[结构体](structs.md) — 值类型的数据模型
- 相关：[函数](functions.md) — 把函数返回结果用枚举建模
- 进阶：[错误处理](error-handling.md) — Result 枚举与 do-catch
