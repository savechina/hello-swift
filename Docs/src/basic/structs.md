# 结构体

## 开篇故事

想象你正在整理名片柜。每张名片记录一个人的信息：姓名、电话、邮箱。你把这张名片复印一份给朋友，朋友在上面改了电话号码。那张复印名片会更新，你原始的名片会跟着变吗？

不会。因为名片是**复印件**，修改复印件不会影响原件。这就是 Swift 中**结构体**（struct）的核心行为——值类型（value type）的语义：赋值和传递时，数据会被完整复制，彼此独立。理解这一点，你就掌握了 Swift 内存模型的一半。

---

## 本章适合谁

如果你希望学会如何自定义数据容器，管理一组相关字段，并理解 Swift 中值类型与引用类型的区别，本章适合你。结构体是 Swift 编程中最常用的自定义类型。

---

## 你会学到什么

完成本章后，你可以：

1. 使用 `struct` 关键字定义自定义数据结构
2. 区分存储属性（stored properties）和计算属性（computed properties）
3. 使用属性观察器（`willSet` / `didSet`）监听属性变化
4. 理解值类型（value type）的"按值复制"语义
5. 掌握 `mutating` 关键字在结构体方法中的使用规则

---

## 前置要求

本章前置知识：阅读过 [枚举](enums.md)，了解基本类型和函数定义。

---

## 第一个例子

打开 `Sources/BasicSample/ClassSample.swift` 中的 `Matrix` 结构体，找到最基础的定义：

```swift
struct Matrix {
    let rows: Int, columns: Int
    var grid: [Double]
}
```

**发生了什么？**

- `struct Matrix` — 定义一个结构体类型
- `let rows` — 不可变存储属性
- `var grid` — 可变存储属性
- 结构体自带**逐成员初始化器**（memberwise initializer），无需手动编写

完整使用方式：

```swift
let m = Matrix(rows: 3, columns: 3)
print("Matrix size: \(m.rows) x \(m.columns)")
```

---

## 原理解析

### 1. 基本结构体定义

结构体通过 `struct` 关键字定义，包含**属性**（数据）和**方法**（行为）：

```swift
struct Matrix {
    let rows: Int, columns: Int
    var grid: [Double]

    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: 0.0, count: rows * columns)
    }

    subscript(row: Int, column: Int) -> Double {
        get {
            grid[(row * columns) + column]
        }
        set {
            grid[(row * columns) + column] = newValue
        }
    }
}
```

结构体 `Matrix` 用一个一维的 `Double` 数组模拟二维矩阵，通过计算 `row * columns + column` 定位索引。`subscript` 语法让你可以用 `matrix[row, column]` 来访问元素。

### 2. 存储属性 vs 计算属性

**存储属性**直接保存值，**计算属性**不存储值，而是通过 `get`（可选 `set`）计算得到：

```swift
struct Rectangle {
    var width: Double
    var height: Double

    // 计算属性：不存储，通过 width 和 height 算出
    var area: Double {
        width * height
    }
}

let rect = Rectangle(width: 10, height: 5)
print(rect.area)  // 50.0
```

计算属性本质上是一对 `get`/`set` 方法，它不占用结构体的存储开销。

### 3. 属性观察器（willSet / didSet）

Swift 允许在属性值改变前后插入回调逻辑：

```swift
struct StepTracker {
    var steps: Int = 0 {
        willSet(newSteps) {
            print("About to change from \(steps) to \(newSteps)")
        }
        didSet {
            if steps > oldValue {
                print("Total steps now: \(steps)")
            }
        }
    }
}

var tracker = StepTracker()
tracker.steps = 100
tracker.steps += 1
```

- `willSet` — 修改前触发，`newValue` 是即将设置的值
- `didSet` — 修改后触发，`oldValue` 是旧的值

### 4. 值类型语义（Copy on Assignment）

结构体是**值类型**。赋值、传参时，数据会被完整复制：

```swift
struct Point {
    var x: Double, y: Double
}

var p1 = Point(x: 0, y: 0)
var p2 = p1   // p2 是 p1 的副本
p2.x = 100

print(p1.x)  // 0  — p1 没有受影响
print(p2.x)  // 100
```

这与类（class）的引用语义不同。类赋值时只复制引用，修改一处会影响所有引用。结构体则像复印件：彼此独立。

### 5. Mutating 方法

结构体的 `func` 方法默认不修改属性。如果要修改，必须加 `mutating` 关键字：

```swift
struct Counter {
    var count: Int = 0

    mutating func increment() {
        count += 1
    }

    static func zero() -> Counter {
        Counter(count: 0)
    }
}

var c = Counter()
c.increment()
print(c.count)  // 1
```

`mutating` 告诉 Swift：这个方法会修改 `self`。编译器会给这个方法一个可变的 `self` 副本并赋值回去。如果是 `let` 声明的结构体实例，则不允许调用 `mutating` 方法。

### 6. 静态属性和方法

用 `static` 定义属于类型本身而非实例的成员：

```swift
struct NetworkClient {
    static let defaultTimeout = 30.0

    static func createDefault() -> NetworkClient {
        // ...
    }
}

print(NetworkClient.defaultTimeout)  // 30.0
```

`static` 成员通过类型名访问，不依赖任何实例。这在定义常量、工厂方法时非常常见。

### 7. 结构体 vs 枚举：什么时候用哪个？

- **用枚举**：表示"一组互斥的选择"，例如方向、状态、结果类型
- **用结构体**：表示"一组数据的容器"，例如坐标、矩形、用户信息
- 两者都是值类型，都是 Swift 推荐的默认选择（而非类）

---

## 常见错误

### 错误 1: 在 let 结构体上调用 mutating 方法

```swift
struct Point {
    var x: Double, y: Double
    mutating func move(dx: Double, dy: Double) {
        x += dx
        y += dy
    }
}

let p = Point(x: 0, y: 0)
p.move(dx: 10, dy: 20)  // ❌
```

**编译器输出**:

```
error: cannot use mutating member on immutable value: 'p' is a 'let' constant
```

**修复方法**:

```swift
var p = Point(x: 0, y: 0)  // 改为 var
p.move(dx: 10, dy: 20)  // ✅
```

### 错误 2: 结构体方法中修改属性但缺少 mutating

```swift
struct Counter {
    var count = 0
    func increment() {
        count += 1  // ❌
    }
}
```

**编译器输出**:

```
error: cannot assign to property: 'count' is immutable
```

**修复方法**:

```swift
mutating func increment() {  // ✅ 加 mutating
    count += 1
}
```

### 错误 3: 试图修改结构体计算属性但没有 setter

```swift
struct Rectangle {
    var width: Double, height: Double
    var area: Double { width * height }
}

var r = Rectangle(width: 3, height: 4)
r.area = 50  // ❌
```

**编译器输出**:

```
error: cannot assign to property: 'area' is a get-only property
```

**修复方法**:

要么接受只读结果，要么给 `area` 加一个 `set` 方法。

---

## Swift vs Rust/Python 对比

| 概念 | Python | Rust | Swift | 关键差异 |
|---|---|---|---|---|
| 结构体定义 | `class Point: x, y` | `struct Point { x: f64, y: f64 }` | `struct Point { var x: Double }` | Python 类默认引用类型 |
| 赋值语义 | 引用复制 | Move / Copy（取决于 trait） | 完全复制（值类型） | Swift 默认复制 |
| 计算属性 | `@property` 装饰器 | 无（用 getter方法） | `var area: Double { get }` | Swift 语法最简洁 |
| 属性观察器 | 无 | 无 | `willSet` / `didSet` | 这是 Swift 独有的特性 |
| 可变方法修饰 | 无 | `&mut self` | `mutating func` | Rust 用 borrow checker 静态保证 |
| 自动初始化器 | `dataclass`（装饰器） | 手动或宏 `derive` | 自动逐成员初始化器 | Swift 编译器自动生成 |
| 静态成员 | `@staticmethod` + `@classmethod` | `impl Type { fn foo() }` | `static func/let` | 语法各有不同 |

---

## 动手练习

### 练习 1: 预测值类型行为

不运行代码，预测下面代码的输出：

```swift
struct Student {
    var name: String
    var score: Int
}

var s1 = Student(name: "Alice", score: 90)
var s2 = s1
s2.score = 100
print("\(s1.name): \(s1.score)")
print("\(s2.name): \(s2.score)")
```

<details>
<summary>点击查看答案</summary>

**输出**:

```
Alice: 90
Alice: 100
```

**解析**: `s2 = s1` 是副本赋值，修改 `s2.score` 不影响 `s1`。这就是值类型的行为。

</details>

### 练习 2: 写一个带计算属性的结构体

定义一个 `Circle` 结构体，包含 `radius` 属性。添加一个计算属性 `diameter`（等于半径 x2）。再添加一个 `perimeter`（周长 = 2 * pi * r）。

<details>
<summary>点击查看参考实现</summary>

```swift
struct Circle {
    var radius: Double

    var diameter: Double {
        radius * 2
    }

    var perimeter: Double {
        2 * .pi * radius
    }
}

let c = Circle(radius: 5)
print("Diameter: \(c.diameter)")    // 10
print("Perimeter: \(c.perimeter)")  // 31.4159...
```

</details>

### 练习 3: Mutating 实现 Toggle

定义一个 `Switch` 结构体，包含 `isOn: Bool`。写一个 `mutating func toggle()` 切换开关状态。

<details>
<summary>点击查看参考实现</summary>

```swift
struct Switch {
    var isOn: Bool

    mutating func toggle() {
        isOn.toggle()
    }
}

var power = Switch(isOn: false)
print(power.isOn)  // false
power.toggle()
print(power.isOn)  // true
```

</details>

---

## 故障排查 FAQ

### Q: Swift 为什么推荐 struct 而非 class？

**A**: 值类型更安全。复制语义避免了意外的共享和副作用。Swift 标准库的类型（`Int`、`String`、`Array` 等）全部是结构体，这是有意的设计抉择。只有在需要继承或多态行为时才考虑 class。

### Q: `mutating func` 和类的方法有什么不同？

**A**: 结构体的 `self` 默认只读，所以修改属性的方法需要 `mutating`。类的 `self` 本来就是可变的（引用类型），不需要修饰符。

### Q: 属性观察器 `willSet` 和 `didSet` 有什么区别？

**A**: `willSet` 在赋值之前触发，`newValue` 是即将设定的值。`didSet` 在赋值之后触发，`oldValue` 是旧的值。通常用 `didSet` 来响应变化做后续操作（比如刷新 UI）。

---

## 小结

**核心要点**:

1. **`struct` 定义值类型** — 赋值时复制数据，彼此独立
2. **存储属性存数据** — `let` 不可变、`var` 可变
3. **计算属性通过 getter 算出** — 不存储，不占用内存
4. **属性观察器监听变化** — `willSet` / `didSet` 在修改前后触发
5. **`mutating` 允许修改 self** — 结构体的方法默认不修改属性

**关键术语**:

- **Struct**: 结构体（值类型自定义类型）
- **Stored Property**: 存储属性（实际存储数据的字段）
- **Computed Property**: 计算属性（通过计算得出，不存储）
- **Property Observer**: 属性观察器（`willSet`/`didSet`）
- **Value Type**: 值类型（赋值时复制）
- **Mutating**: 可变方法（允许修改 self）

---

## 术语表

| English | 中文 |
|---|---|
| Struct | 结构体 |
| Value Type | 值类型 |
| Stored Property | 存储属性 |
| Computed Property | 计算属性 |
| Property Observer | 属性观察器 |
| willSet | 设置前回调 |
| didSet | 设置后回调 |
| Mutating | 可变（修饰符） |
| Memberwise Initializer | 逐成员初始化器 |
| Static Member | 静态成员 |

完整示例：`Sources/BasicSample/ClassSample.swift`（`Matrix` 结构体部分）

---

## 知识检查

**问题 1** 🟢（基础概念）

```swift
struct Point { var x: Int, y: Int }
let p = Point(x: 1, y: 2)
```

`p.x = 5` 能编译通过吗？

A) 能
B) 不能

<details>
<summary>答案与解析</summary>

**答案**: B) 不能

**解析**: `p` 是用 `let` 声明的，整个结构体不可变，不能修改任何属性。改为 `var p` 即可。
</details>

**问题 2** 🟡（值类型理解）

```swift
struct Team { var name: String }
let t1 = Team(name: "Swift")
var t2 = t1
t2.name = "Rust"
```

`t1.name` 的值是什么？

<details>
<summary>答案与解析</summary>

**答案**: `"Swift"`

**解析**: `t2 = t1` 是值复制，`t2` 和 `t1` 完全独立。修改 `t2.name` 不影响 `t1.name`。
</details>

**问题 3** 🔴（进阶：计算属性与 didSet）

```swift
struct Celsius {
    var value: Double {
        didSet { value = max(0, value) }
    }
}

var temp = Celsius(value: -10)
print(temp.value)
```

输出是什么？为什么？

<details>
<summary>答案与解析</summary>

**答案**: `0.0`

**解析**: `didSet` 在赋值后触发，把 `value` 修正为 `max(0, -10)` 即 `0.0`。注意这实际上是 `didSet` 内部再次赋值，会引发二次 `didSet` 调用（但 `max(0, 0)` 不会改变值，不会无限递归）。这个例子展示了属性观察器的实际用法：数据校验与约束。
</details>

---

## 延伸阅读

学习完结构体后，你可能还想了解：

- [Swift 官方文档 — Structures and Classes](https://docs.swift.org/swift-book/documentation/the-basics/) — 结构体与类的完整对比
- [Swift by Sundell — Structs vs Classes](https://www.swiftbysundell.com/articles/swift-structs-vs-classes/) — 何时选择哪种类型

**选择建议**:

- 初学者 → 继续学习 [协议](protocols.md)
- 有经验的程序员 → 跳到 [泛型](generics.md)

> 记住：Swift 中一切以值类型为首选。结构体、枚举让你写出无副作用的代码。类是最后的手段，只有在继承和多态真正需要时才使用。

---

## 继续学习

- 下一步：[协议](protocols.md) — 面向协议的编程范式
- 相关：[枚举](enums.md) — 值类型兄弟，枚举表达选择
- 进阶：[类与继承](class-inheritance.md) — 引用类型与继承机制
