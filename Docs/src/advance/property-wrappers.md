# 属性包装器 (Property Wrappers)

## 开篇故事

想象你收到一份生日礼物，拆开外面的包装盒后，里面是一个普通的马克杯。但别急，包装盒上有个自动感温贴纸，只要环境温度超过 35 度，它就会变红提醒你。盒子底部还装了一个小型除湿器，能保证杯子里的茶不会受潮发霉。

你看，马克杯本身没有任何变化，它还是那个马克杯。但包装盒给它加上了温度监控和防潮功能，让普通的杯子变得智能起来。

属性包装器（Property Wrapper）就是编程世界里的这种礼物盒。它不改变属性本身的数据类型和存储方式，但在属性读写的时候"额外做一些事情"：限制范围、自动修剪、记录日志、校验格式等等。你只需要在属性前面加一个 `@` 前缀，就能复用这些行为。

本章要教你的，就是如何打造自己的"智能包装盒"，让属性自带能力。

## 本章适合谁

如果你满足以下任一情况，这一章就是为你准备的：

- 你发现自己反复在 `didSet` 里写相同的校验逻辑，想要 DRY（Don't Repeat Yourself）
- 你用过 SwiftUI 的 `@State`、`@Binding`，想知道背后的原理
- 你想创建可复用的属性模式，在一个地方定义，全局使用
- 你对泛型（Generics）有基本了解，想看看泛型在实际工程中的应用

本章面向已经会写基础 Swift 语法和泛型基本概念的开发者。

## 你会学到什么

完成本章后，你将掌握以下内容：

- **@propertyWrapper 属性**：如何声明一个属性包装器结构体
- **wrappedValue**：包装值，属性的实际存储和访问入口
- **projectedValue**：投影值，用 `$` 前缀访问的额外通道
- **泛型包装器**：让 `@Clamped<Value: Comparable>` 支持任意可比较类型
- **包装器组合**：在同一个属性上叠加多个包装器
- **常见陷阱**：初始化匹配、投影类型混淆、包装顺序问题

## 前置要求

在开始之前，请确保你已掌握以下内容：

- Swift 基础语法：变量声明、结构体（Struct）、属性（Property）
- 属性观察器（Property Observers）：`didSet` 和 `willSet` 的用法
- 泛型基础（Generics）：类型参数 `<T>` 和类型约束 `where T: Comparable`
- 闭包范围（ClosedRange）：`0...100` 这样的区间语法

如果你对这些内容还不太熟悉，建议先回顾基础部分（结构体与类 → 泛型 → 错误处理），然后再回来。

> **⚠️ 环境要求**: macOS 12+ 或 Linux，Swift 6.0+。属性包装器是 Swift 5.1 引入的特性，在 Swift 6.0 中行为稳定。

## 第一个例子

我们先来看一个最直观的例子：用 `@Clamped` 包装器确保玩家的分数永远在 0-100 之间，不管你赋什么值。

代码文件位于 `AdvanceSample/Sources/AdvanceSample/PropertyWrapperSample.swift` 第 1-14 行：

```swift
@propertyWrapper
struct Clamped<Value: Comparable> {
    var wrappedValue: Value {
        didSet {
            wrappedValue = min(max(wrappedValue, range.lowerBound), range.upperBound)
        }
    }
    var projectedValue: Clamped { self }
    let range: ClosedRange<Value>
    
    init(wrappedValue: Value, _ range: ClosedRange<Value>) {
        self.range = range
        self.wrappedValue = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }
}
```

使用方式：

```swift
struct Player {
    @Clamped(0...100) var score: Int = 50
}

var player = Player()

player.score = 150
print(player.score)  // 输出: 100

player.score = -10
print(player.score)  // 输出: 0
```

不管你给 `score` 赋什么值，它都会被自动限制在 0 到 100 的范围内。赋值 150 变成 100，赋值 -10 变成 0。包装器在幕后默默完成了裁剪逻辑，你调用时完全感觉不到它的存在——这正是好包装器的标志。

## 原理解析

属性包装器的核心机制可以拆解成以下几个关键概念。

### @propertyWrapper 属性

在结构体前面加上 `@propertyWrapper`，编译器就会把它识别为属性包装器。这个结构体必须包含一个名为 `wrappedValue` 的属性，它是包装器与被包装属性之间的桥梁。

```swift
@propertyWrapper
struct Logged<Value> {
    var wrappedValue: Value {
        didSet {
            print("  [Logged] Changed to: \(wrappedValue)")
        }
    }
    
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
        print("  [Logged] Initialized: \(wrappedValue)")
    }
}
```

`Logged` 包装器每次属性值变化时都会打印日志。使用方式：

```swift
struct Player {
    @Logged var name: String = "Unknown"
}

var player = Player()
// 输出: [Logged] Initialized: Unknown

player.name = "Alice"
// 输出: [Logged] Changed to: Alice

player.name = "Bob"
// 输出: [Logged] Changed to: Bob
```

### wrappedValue 存储

`wrappedValue` 是包装器的核心属性。当你这样写：

```swift
@Clamped(0...100) var score: Int = 50
```

编译器实际上会生成类似这样的代码：

```swift
private var _score = Clamped(wrappedValue: 50, 0...100)
var score: Int {
    get { _score.wrappedValue }
    set { _score.wrappedValue = newValue }
}
```

访问 `player.score` 时，你实际上访问的是 `_score.wrappedValue`。赋值时，`didSet` 观察者会触发裁剪逻辑。

### projectedValue 和 $ 语法

`projectedValue` 是包装器提供的第二个通道，用 `$` 前缀访问。它让你在不绕过包装器的前提下拿到包装器本身的元信息。

```swift
struct Player {
    @Clamped(0...100) var score: Int = 50
}

let player = Player()
print(player.$score.projectedValue.range)  // 输出: ClosedRange(0...100)
```

`$score` 访问的是 `projectedValue`，在这里例子中，`projectedValue` 返回 `Clamped` 自身（`self`），所以你可以继续访问 `.range` 获取限制范围的上下界。

> **为什么需要 projectedValue？** 假设你想在运行时动态读取属性的约束条件（比如 UI 上显示一个分数条的上下限），projectedValue 就是为此而生的。

### 泛型包装器

`Clamped<Value: Comparable>` 用泛型让同一个包装器支持任意可比较的类型。`Int`、`Double`、`Float`，甚至自定义的比较类型，只要遵守 `Comparable` 协议就能用。

```swift
@Clamped(0.0...1.0) var opacity: Double = 0.5
@Clamped(1...10) var volume: Int = 5
```

一个包装器定义，多处类型复用。泛型是属性包装器能保持通用性的关键。

### 包装器组合

你可以在同一个属性上叠加多个包装器，但要注意顺序。Swift 按照从上到下的顺序依次应用：

```swift
struct UserProfile {
    @Logged
    @Clamped(0...100)
    var level: Int = 1
}
```

外层是 `Logged`，内层是 `Clamped`。每次修改 `level` 时，先经过 `Clamped` 裁剪，再经过 `Logged` 记录。组合顺序不同，行为也不同。

## 常见错误

以下是最容易踩到的坑。

| 错误 | 症状 | 解决方案 |
|------|------|----------|
| 初始化参数不匹配 | 编译错误：`Extra argument in call` | `init(wrappedValue: ..., ...)` 中第一个参数必须是 `wrappedValue`，这是 Swift 的语法约定。如果你定义的包装器 init 不叫这个名字，编译器无法将 `@Wrapper(arg) var x: T = default` 翻译成正确的调用 |
| projectedValue 类型混淆 | 运行时拿到预期外的类型 | `projectedValue` 的返回类型由你定义，不一定等于 `wrappedValue` 的类型。明确声明返回类型，不要依赖推断 |
| 包装器顺序导致行为异常 | 外层包装器的逻辑没有生效 | 多个包装器组合时，最上面的是最外层。`@A @B var x` 等价于 `x = A(wrappedValue: B(...))`，A 包裹 B |
| 泛型约束缺失 | 编译错误：`cannot find 'min' in scope` | `Comparable` 约束不能少。没有 `Comparable`，`min` 和 `max` 无法使用 |
| 值类型 vs 引用类型混淆 | 包装器修改了但外部看不到 | 包装器本身是 `struct`（值类型）还是 `class`（引用类型）会影响 `projectedValue` 的行为。大多数场景下用 `struct` 即可 |

## Swift vs Python/Rust 对比

不同语言对于"给属性附加行为"有不同的设计思路，放在一起对比会更有感觉：

| 特性 | Swift (Property Wrapper) | Python (Descriptor) | Rust |
|------|-------------------------|---------------------|------|
| 声明方式 | `@propertyWrapper struct` | 实现 `__get__`/`__set__` 方法的类 | **无直接等价物** |
| 使用方式 | `@Clamped var x: Int` | `x = Clamped()` 在类内声明 | 手动在 getter/setter 中实现逻辑 |
| 投影值 | `$x` projectedValue | 无内建投影概念 | 无 |
| 类型安全 | 编译期检查 | 运行期检查 | 编译期检查（手动实现） |
| 泛型支持 | 原生泛型 `<Value: Comparable>` | 泛型通过 `typing.Generic` | 原生泛型 `<T>` |
| 组合方式 | 多个 `@` 叠加 | 多个 Descriptor 叠加困难 | 通过嵌套 `impl` 块或宏 |

Swift 的属性包装器是三者中最优雅的。Python 的 Descriptor 历史悠久但语法冗长，Rust 没有内建等价物，开发者通常在闭包或宏中手动实现类似逻辑。

## 动手练习 Level 1

**目标**：创建一个 `@NonEmpty` 属性包装器，确保 `String` 类型的属性永远不会变成空字符串。

要求：
1. 定义泛型约束为 `String` 类型的包装器
2. 如果尝试赋空字符串 `""`，自动恢复为上一次的值或默认值
3. 在 `didSet` 中打印警告信息

<details>
<summary>点击查看答案</summary>

```swift
@propertyWrapper
struct NonEmpty {
    private var _value: String
    var wrappedValue: String {
        get { _value }
        set {
            if newValue.isEmpty {
                print("  [NonEmpty] 警告: 不能设置为空字符串，保持原值")
            } else {
                _value = newValue
            }
        }
    }
    
    init(wrappedValue: String) {
        if wrappedValue.isEmpty {
            fatalError("NonEmpty: 初始值不能为空")
        }
        _value = wrappedValue
    }
}

struct UserProfile {
    @NonEmpty var username: String = "guest"
}

var user = UserProfile()
user.username = "alice"    // 正常赋值
user.username = ""         // 输出: 警告: 不能设置为空字符串，保持原值
print(user.username)       // 输出: alice
```
</details>

## 动手练习 Level 2

**目标**：创建一个 `@Trimmed` 属性包装器，自动去除字符串首尾的空白字符。

要求：
1. 赋值时自动调用 `.trimmingCharacters(in: .whitespacesAndNewlines)`
2. 初始化时也自动裁剪
3. 支持泛型，约束为 `String`

<details>
<summary>点击查看答案</summary>

```swift
@propertyWrapper
struct Trimmed {
    var wrappedValue: String {
        didSet {
            wrappedValue = wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    init(wrappedValue: String) {
        self.wrappedValue = wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct Article {
    @Trimmed var title: String
}

let article = Article(title: "  Swift 属性包装器教程  ")
print("《\(article.title)》")
// 输出: 《Swift 属性包装器教程》
```
</details>

## 动手练习 Level 3

**目标**：创建一个 `@ValidatedEmail` 属性包装器，使用正则表达式校验邮箱格式。

要求：
1. 使用 Swift 5.7+ 的 `Regex` 类型匹配邮箱格式
2. 如果格式不合法，抛出 `ValidationError` 错误
3. `projectedValue` 返回验证结果状态（isValid: Bool）

<details>
<summary>点击查看答案</summary>

```swift
@propertyWrapper
struct ValidatedEmail {
    struct ValidationError: Error, CustomStringConvertible {
        let message: String
        var description: String { message }
    }
    
    private static let emailRegex = /^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
    
    private var _value: String
    var isValid: Bool { Self.emailRegex.wholeMatch(in: _value) != nil }
    
    var wrappedValue: String {
        get { _value }
        set {
            guard Self.emailRegex.wholeMatch(in: newValue) != nil else {
                print("  [ValidatedEmail] 非法邮箱格式: \(newValue)")
                return
            }
            _value = newValue
        }
    }
    
    var projectedValue: Bool { isValid }
    
    init(wrappedValue: String) {
        _value = wrappedValue
    }
}

struct Account {
    @ValidatedEmail var email: String = ""
}

var account = Account()
account.email = "alice@example.com"     // 合法，赋值成功
account.email = "not-an-email"          // 非法，被拒绝
print("邮箱合法: \(account.$email)")     // 输出: 邮箱合法: true
```
</details>

## 故障排查 FAQ

**Q1：`@propertyWrapper` 只能用在 `struct` 上吗？**

不是。属性包装器可以声明在 `struct`、`class`、`enum` 上。但绝大多数场景下用 `struct` 就足够了。包装器本身应该是轻量的值类型。

**Q2：`wrappedValue` 和 `projectedValue` 的类型可以不同吗？**

可以。这是非常常见的做法。比如 `@Clamped` 的 `wrappedValue` 是 `Value`（比如 `Int`），而 `projectedValue` 是 `Clamped<Value>` 结构体自身或者一个自定义的状态类型。`$score` 拿到的不一定是 `Int`。

**Q3：属性包装器可以用在函数参数上吗？**

可以，但有语法限制。Swift 5.7+ 支持在函数参数前加包装器，但参数必须用 `_` 做外部标签：

```swift
func setScore(@Clamped(0...100) _ score: Int) {
    print(score)  // 自动被裁剪
}
```

**Q4：为什么我的包装器 `didSet` 没有在初始化时触发？**

Swift 的行为约定：`didSet` 在 **赋值** 时触发，但不在初始化时触发。如果需要在初始化时也执行验证或转换逻辑，直接在 `init(wrappedValue:)` 里写。

**Q5：多个 `@propertyWrapper` 叠加时，如何判断谁先谁后？**

从上到下，最上面的是最外层。`@A @B var x` 意味着 `_x` 的类型是 `A<B<T>>`。A 的 `wrappedValue` 是 B 包装器，B 的 `wrappedValue` 才是最终的实际值。理解这层嵌套关系后，行为就容易预测了。

**Q6：属性包装器能访问所属的类型（Type）吗？**

不行。属性包装器本身不持有对包含它的结构体或类的引用。如果你需要跨属性通信（比如属性 A 的变化触发属性 B 的更新），需要用其他方式，比如 `ObservableObject` + `@Published`。

**Q7：`@Clamped` 里用了 `didSet`，初始化时赋值会被裁剪吗？**

会的。因为 `init(wrappedValue:)` 里手动执行了一次 `min(max(...))` 裁剪。`didSet` 只在后续赋值时触发。好的包装器应该在初始化和赋值两个路径上都执行相同的逻辑。

## 小结

- 属性包装器（Property Wrapper）是给属性加行为的"智能包装盒"，不改变数据类型本身
- `wrappedValue` 是属性的实际值，`projectedValue` 用 `$` 前缀访问，提供额外的元信息通道
- 泛型约束（`<Value: Comparable>`）让包装器通用化，一个定义支持多种类型
- 多个包装器可以叠加，但要注意顺序：最上面的是最外层

## 术语表

| 英文 | 中文 | 说明 |
|------|------|------|
| Property Wrapper | 属性包装器 | 通过 `@propertyWrapper` 声明的结构体，为属性附加额外行为 |
| wrappedValue | 包装值 | 包装器的核心属性，直接映射到被包装属性的读写操作 |
| projectedValue | 投影值 | 包装器提供的额外通道，通过 `$` 前缀访问，返回自定义类型 |
| Comparable | 可比较协议 | Swift 标准库协议，支持 `<`、`>`、`<=`、`>=` 比较操作 |
| ClosedRange | 闭区间 | Swift 中的闭区间类型，写作 `0...100`，包含上下界 |
| didSet | 属性观察者 | 属性值变化后触发的代码块，是包装器实现自动验证的关键 |
| Generic Type Constraint | 泛型类型约束 | 对泛型参数的限制，如 `Value: Comparable`，确保类型具备特定能力 |

## 知识检查

用三个问题检验你是否真正掌握了本节内容。

**问题一**：当你写 `@Clamped(0...100) var score: Int = 50` 时，Swift 编译器实际生成的代码结构是什么？

<details>
<summary>查看答案</summary>

编译器会生成一个私有包装器实例 `_score`，以及一个计算属性 `score`：

```swift
private var _score = Clamped(wrappedValue: 50, 0...100)
var score: Int {
    get { _score.wrappedValue }
    set { _score.wrappedValue = newValue }
}
```

你访问 `score` 时，实际上在访问 `_score.wrappedValue`。赋值时，`didSet` 观察者执行裁剪逻辑。
</details>

**问题二**：`player.$score` 和 `player.score` 有什么区别？它们的类型分别是什么？

<details>
<summary>查看答案</summary>

- `player.score` 类型是 `Int`，返回的是 `wrappedValue`，也就是属性的实际值
- `player.$score` 类型是 `Clamped<Int>`，返回的是 `projectedValue`。在代码中，`projectedValue` 返回 `self`，所以你可以通过 `$score.range` 访问 `ClosedRange<Int>` 类型的限制范围

简单记：没有 `$` 是值，有 `$` 是包装器本体。
</details>

**问题三**：如果我要写一个 `@Debounced` 包装器，让属性变化 1 秒后才真正触发更新，这个包装器需要包含什么关键元素？

<details>
<summary>查看答案</summary>

```swift
@propertyWrapper
struct Debounced<Value> {
    var wrappedValue: Value {
        didSet {
            Task {
                try await Task.sleep(for: .seconds(1))
                // 1 秒后才执行实际逻辑
            }
        }
    }
    let onChange: (Value) -> Void
    
    init(wrappedValue: Value, onChange: @escaping (Value) -> Void) {
        self.wrappedValue = wrappedValue
        self.onChange = onChange
    }
}
```

关键元素：`wrappedValue` 的 `didSet` 使用 `Task.sleep` 做延迟，一个回调闭包 `onChange` 在延迟后执行实际逻辑。这展示了属性包装器如何和 Swift 并发编程 (Concurrency) 结合。
</details>

## 继续学习

属性包装器让你用声明式语法控制属性的行为。Swift 进阶中还有很多类似的声明式工具，它们都用 `@` 前缀，背后的设计思想是相通的。

继续学习下一节：[异步编程与 SwiftNIO](./swift-nio-async.md)，你将了解如何用 `Task` 和 `async/await` 在异步环境中工作。
