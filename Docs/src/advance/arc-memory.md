# 自动引用计数 (ARC) 与内存管理

## 开篇故事

想象你借了一本图书馆的书。管理员在借书记录上画一道竖线：今天只有你一个人借了这本书，计数为 1。过了一天，你的同事也来借了同一本，管理员又画一道竖线——计数变成 2。还书的时候，管理员每看到一个人归还，就划掉一道竖线。当竖线数量归零时，管理员知道"没有任何人在使用了"，这本书就可以放回书架或者销毁。

这段图书馆的故事，本质上就是 Swift 的**自动引用计数 (Automatic Reference Counting, ARC)** 的工作原理。每一个类 (class) 的实例在内存中都有一个"引用计数器"。每当你创建一个强引用 (strong reference)，计数器加一；每次引用消失，计数器减一。当计数器归零时，系统自动释放这块内存，调用 `deinit`。

但 ARC 并非永远聪明。想象这样一本书：你在书的借阅卡上写着自己的名字，书上也在借阅卡上写着你的名字——两个记录互相指向对方，谁都不先划掉，书就永远无法归还。这就是**循环引用 (retain cycle)**，也是本章最核心的问题。学会用 `weak` 和 `unowned` 打破循环，是每个 Swift 开发者的必修课。

示例代码位于 `AdvanceSample/Sources/AdvanceSample/ARCSample.swift`。

---

## 本章适合谁

如果你写过以下任何一种代码，理解 ARC 对你来说不是可选知识，而是必学技能：

- 使用过 `class` 类型并在对象间建立了互相引用的关系
- 写过闭包 (closure)，尤其是捕获了 `self` 的闭包
- 用过代理模式 (delegate pattern)、观察者模式 (observer pattern)、或任何回调机制
- 遇到过内存泄漏 (memory leak) 或程序莫名崩溃
- 想要深入理解 Swift 的内存模型，写出更高效、更安全的生产代码

本章适合已经掌握 Swift 基础语法、了解 `class` 和 `struct` 区别的开发者。

---

## 你会学到什么

完成本章后，你可以：

1. 理解 ARC 的引用计数机制以及它何时释放对象
2. 区分强引用 (strong)、弱引用 (weak)、无主引用 (unowned) 的使用场景
3. 识别循环引用 (retain cycle) 并用 `weak` 或 `unowned` 打破它
4. 掌握闭包中的捕获列表 (capture list)：`[weak self]`、`[unowned self]`、`[value]`
5. 使用 `deinit` 调试对象生命周期，验证实例是否被正确释放

---

## 前置要求

- 掌握 Swift 基础语法，特别是 `class` 类型、可选类型 (optional) 和 `init` 构造器
- 理解引用类型 (reference type) 和值类型 (value type) 的区别
- 了解闭包 (closure) 的基本语法
- 已阅读[高级进阶概览](./advance-overview.md)章节

---

## 第一个例子

打开 `AdvanceSample/Sources/AdvanceSample/ARCSample.swift`，先看最核心的 Person/Pet 示例：

```swift
class Person {
    let name: String
    var pet: Pet?

    init(name: String) {
        self.name = name
        print("  Person \(name) initialized")
    }

    deinit {
        print("  Person \(name) deinitialized")
    }
}

class Pet {
    let name: String
    weak var owner: Person?

    init(name: String) {
        self.name = name
        print("  Pet \(name) initialized")
    }

    deinit {
        print("  Pet \(name) deinitialized")
    }
}
```

**关键点**：`Pet` 的 `owner` 属性被标记为 `weak`。这正是打破循环引用的关键。

接下来看这些对象如何被创建和释放：

```swift
func arcSample() {
    print("--- arcSample start ---")

    var person: Person? = Person(name: "Alice")
    var pet: Pet? = Pet(name: "Fluffy")

    person?.pet = pet
    pet?.owner = person
    print("Cycle created (pet.owner is weak, so no retain cycle)")

    person = nil
    print("After person = nil")

    pet = nil
    print("After pet = nil")

    // ... closure example below
}
```

**运行输出**：

```
--- arcSample start ---
  Person Alice initialized
  Pet Fluffy initialized
Cycle created (pet.owner is weak, so no retain cycle)
  Person Alice deinitialized
After person = nil
  Pet Fluffy deinitialized
After pet = nil
```

**发生了什么？**

1. `Person Alice` 被创建，引用计数 = 1（`person` 变量持有它）
2. `Pet Fluffy` 被创建，引用计数 = 1（`pet` 变量持有它）
3. `person?.pet = pet`：`person` 的 `pet` 属性强引用了 `Fluffy`，`Fluffy` 的计数 = 2
4. `pet?.owner = person`：`pet` 的 `owner` 是 **弱引用**，`Alice` 的计数 **不增加**（仍然 = 1）
5. `person = nil`：`person` 变量放弃持有，`Alice` 的计数 = 0 → **触发 `deinit`**
6. `Alice` 释放后，它对 `Fluffy` 的强引用也消失，`Fluffy` 的计数 = 1
7. `pet = nil`：`pet` 变量放弃持有，`Fluffy` 的计数 = 0 → **触发 `deinit`**

如果 `owner` 不是 `weak` 而是默认的强引用，步骤 4 中 `Alice` 的计数会变成 2。步骤 5 后 `Alice` 的计数 = 1（`pet.owner` 还强引用着），不会释放。同样 `pet` 也不会释放——两个对象就永远留在了内存中，这就是**内存泄漏**。

---

## 原理解析

### 1. ARC 工作机制

Swift 不使用垃圾回收 (garbage collection)，而是使用自动引用计数。编译器在编译时自动在合适的位置插入引用计数操作：

- 当一个引用开始持有某个对象时，编译器插入 `retain`（计数加一）
- 当一个引用不再持有某个对象时，编译器插入 `release`（计数减一）
- 当计数归零时，实例被销毁，`deinit` 被自动调用

ARC 是**自动**的：你不需要手动调用 retain 或 release。但它只作用于 `class`——`struct` 和 `enum` 是值类型，不走引用计数。

### 2. 强引用、弱引用、无主引用

| 引用类型 | 关键字 | 是否增加计数 | 返回类型 | 何时使用 |
|---------|--------|-------------|---------|---------|
| 强引用 | 默认（无修饰符） | 是 | `Type` | 对象拥有关系（如 `Person.pet`） |
| 弱引用 | `weak` | 否 | `Type?`（可选） | 父→子中的子→父反向引用 |
| 无主引用 | `unowned` | 否 | `Type`（非可选） | 子对象的生命周期一定不短于父对象 |

**`weak` 的核心特性**：

- 必须声明为可选类型 (`Type?`)
- 当引用对象被释放时，**自动设为 `nil`**——不会变成悬空指针
- 因此访问 `weak` 变量永远是安全的

**`unowned` 的核心特性**：

- 声明为非可选类型 (`Type`)
- 当引用对象被释放时，**不会自动设为 `nil`**
- 如果访问已经被释放的 `unowned` 引用，程序会**崩溃**（runtime crash）
- 适合"子对象的生存期一定不短于父对象"的场景，例如信用卡 `CreditCard` 和客户 `Customer` 的关系——信用卡不可能在没有客户的情况下独立存在

### 3. 闭包中的捕获列表 (Capture List)

闭包会捕获它访问的所有外部变量。对于引用类型，闭包默认使用**强引用**捕获，这同样会导致循环引用：

```swift
class DataProcessor {
    var data: [Int] = []

    lazy var processData: () -> Void = {
        self.data.append(42)  // 闭包强引用 self → 循环引用！
    }
}
```

解决方案：在闭包参数前使用捕获列表。有三种写法：

```swift
// 写法 1: [weak self] — 最常用，安全
lazy var processData: () -> Void = { [weak self] in
    self?.data.append(42)  // self 是可选的，需要 ? 解包
}

// 写法 2: [unowned self] — 适合 self 一定存活时
lazy var processData: () -> Void = { [unowned self] in
    self.data.append(42)  // self 不是可选的，直接用
}

// 写法 3: [value] — 值类型的捕获（值拷贝）
var localValue = 42
let closure = { [localValue] in
    print("  Closure captured: \(localValue)")
}
closure()  // 输出: Closure captured: 42
```

**值类型捕获的意义**：如果不使用捕获列表 `{}`，闭包会"随用随读"变量的当前值；使用 `[localValue]` 会把变量在闭包定义时的值**拷贝**进去，之后的修改不会影响闭包内读取到的值。这在异步回调和定时器等场景中非常有价值。

---

## 常见错误

| 错误 | 原因 | 后果 | 解决方案 |
|------|------|------|---------|
| 循环引用 (Retain Cycle) | 两个 class 互相强引用 | 内存泄漏，`deinit` 不执行 | 一方改用 `weak` 或 `unowned` |
| 闭包捕获 `self` 导致循环 | `lazy var` 闭包强引用 `self`，`self` 持有闭包 | 内存泄漏 | 使用 `[weak self]` 捕获列表 |
| `unowned` 引用在对象释放后被访问 | 对象已经 `deinit`，但仍有代码访问 `unowned` 引用 | 运行时崩溃 (`EXC_BAD_ACCESS`) | 改用 `weak`，或确保对象生命周期更长 |
| 结构体中使用 `weak` | 值类型不走引用计数，`weak` 仅适用于 class | 编译错误 | 改用 `class` 或移除 `weak` |
| `delegate` 未用 `weak` | 最常见的 retain cycle 来源 | 内存泄漏 | `delegate` 协议必须声明为 `weak var delegate` |

---

## Swift vs Rust/Python 对比

| 特性 | Swift (ARC) | Rust (Ownership/Borrowing) | Python (GC) |
|------|------------|----------------------------|------------|
| 内存管理方式 | 编译时插入 retain/release | 所有权系统 + 借用检查器 | 运行时标记-清除垃圾回收 |
| 运行时开销 | 较小的引用计数操作 | 无运行时开销 | GC 暂停 (stop-the-world) |
| 循环引用 | 可能发生，需手动用 `weak`/`unowned` 打破 | 编译期直接拒绝（借用检查器） | 可能发生，依赖 GC 的循环检测 |
| 引用类型 | `class` 走 ARC，`struct` 走值类型 | 单一所有权，`Rc<T>` 可共享 | 所有对象都是引用 |
| 指针安全 | `weak` 自动 nil 化，`unowned` 需手动保证 | 借用检查器在编译期保证安全 | 依赖 GC，无编译期保证 |
| 内存释放时机 | 确定性的（计数归零立即释放） | 确定性的（离开作用域立即释放） | 不确定的（GC 何时运行不可控） |

**Swift 的独特优势**：ARC 比 Python 的 GC 更快更确定（没有 GC 暂停），又比 Rust 更容易上手（不需要学习所有权的复杂规则）。但你需要保持警惕：编译器不会像 Rust 的借用检查器那样阻止你写出循环引用——这是开发者自己的责任。

---

## 动手练习 Level 1

创建一个 `TreeNode` 类，要求：

- 每个节点有 `name: String`
- 有 `children: [TreeNode]`（强引用）
- 有 `parent: TreeNode?`（**弱引用**）
- 实现 `deinit`，打印节点名称来验证释放

<details>
<summary>点击查看答案</summary>

```swift
class TreeNode {
    let name: String
    var children: [TreeNode] = []
    weak var parent: TreeNode?

    init(name: String) {
        self.name = name
        print("  TreeNode '\(name)' initialized")
    }

    deinit {
        print("  TreeNode '\(name)' deinitialized")
    }

    func addChild(_ child: TreeNode) {
        children.append(child)
        child.parent = self
    }
}

// 测试
func testTreeNode() {
    let root = TreeNode(name: "Root")
    let child1 = TreeNode(name: "Child1")
    let child2 = TreeNode(name: "Child2")
    root.addChild(child1)
    root.addChild(child2)
    // root 释放时，children 也会释放，parent 是 weak，不会阻止释放
}
```

</details>

---

## 动手练习 Level 2

以下代码中存在**循环引用**。找出问题并用 `weak` 修复它：

```swift
protocol WeatherServiceDelegate: AnyObject {
    func didReceiveTemperature(_ temp: Double)
}

class WeatherService {
    var delegate: WeatherServiceDelegate?  // ← 问题在这里

    func fetchTemperature() {
        // 模拟从网络获取温度
        delegate?.didReceiveTemperature(25.0)
    }

    deinit {
        print("  WeatherService deinitialized")
    }
}

class ViewController {
    let service: WeatherService

    init() {
        service = WeatherService()
        service.delegate = self  // 循环引用！
    }

    deinit {
        print("  ViewController deinitialized")
    }
}

extension ViewController: WeatherServiceDelegate {
    func didReceiveTemperature(_ temp: Double) {
        print("  当前温度: \(temp)°C")
    }
}
```

<details>
<summary>点击查看答案</summary>

问题：`ViewController` 强引用 `WeatherService`，`WeatherService` 的 `delegate` 又强引用 `ViewController`，形成循环。

修复：把 `delegate` 改为 `weak`。注意协议必须声明为 `AnyObject`（只有 class 类型才能实现协议并支持 weak 属性）。

```swift
// 协议声明为 AnyObject 约束
protocol WeatherServiceDelegate: AnyObject {
    func didReceiveTemperature(_ temp: Double)
}

class WeatherService {
    weak var delegate: WeatherServiceDelegate?  // ← 关键修复

    func fetchTemperature() {
        delegate?.didReceiveTemperature(25.0)
    }

    deinit {
        print("  WeatherService deinitialized")
    }
}

// 其余代码不变
```

</details>

---

## 动手练习 Level 3

实现一个轻量级的**观察者模式 (Observer Pattern)**，要求：

- `Notifier` 类有一个 `addObserver(_:)` 方法，接收 `Observable` 协议类型的对象
- `Observable` 协议必须声明为 `AnyObject`，内部有一个 `notify(data:)` 方法
- 观察者应该使用**弱引用**存储，确保被观察的对象释放后，`Notifier` 不会阻止它被释放
- 实现 `removeObserver(_:)` 方法
- 实现 `notifyAll(data:)` 方法通知所有观察者

<details>
<summary>点击查看答案</summary>

```swift
protocol Observable: AnyObject {
    func notify(data: String)
}

class Notifier {
    // 使用 NSHashTable 自动处理 weak 引用（最优雅的方案）
    private var observers = NSHashTable<AnyObject>.weakObjects()

    func addObserver(_ observer: any Observable) {
        observers.add(observer)
    }

    func removeObserver(_ observer: any Observable) {
        observers.remove(observer)
    }

    func notifyAll(data: String) {
        for case let observer as Observable in observers.allObjects {
            observer.notify(data: data)
        }
    }
}

// 如果不想用 NSHashTable，也可以用数组手动清理：
// class NotifierManual {
//     private var observers: [WeakObservable] = []
//
//     func addObserver(_ observer: any Observable) {
//         observers.append(WeakObservable(object: observer))
//     }
//
//     func notifyAll(data: String) {
//         // 清理已释放的观察者
//         observers = observers.filter { $0.object != nil }
//         for wrapper in observers {
//             wrapper.object?.notify(data: data)
//         }
//     }
// }
//
// class WeakObservable {
//     weak var object: (any Observable)?
//     init(object: any Observable) { self.object = object }
// }

// 使用示例
class Logger: Observable {
    let name: String
    init(name: String) { self.name = name }
    func notify(data: String) {
        print("  [\(name)] 收到通知: \(data)")
    }
    deinit { print("  Logger '\(name)' deinitialized") }
}

func testObserver() {
    let notifier = Notifier()
    var logger1: Logger? = Logger(name: "Debug")
    var logger2: Logger? = Logger(name: "Info")

    notifier.addObserver(logger1!)
    notifier.addObserver(logger2!)

    notifier.notifyAll(data: "Hello Observers")

    logger1 = nil  // Logger 'Debug' deinitialized
    notifier.notifyAll(data: "Only Info logger now")  // 只剩 Info

    logger2 = nil  // Logger 'Info' deinitialized
}
```

</details>

---

## 故障排查 FAQ

**Q1. 如何确认我的代码是否存在循环引用？**

在 `deinit` 中加入 `print` 语句。如果预计某个对象在某个时间点应该被释放，但你没有看到 `deinit` 的打印输出，那大概率存在循环引用。另一种方式是使用 Xcode 的 Instrument 工具 → "Leaks" → "Allocations" 追踪内存变化。

**Q2. `weak` 和 `unowned` 应该用哪个？**

简单判断标准：
- 如果引用的对象**可能**在访问前就被释放了 → 用 `weak`（安全，返回可选值）
- 如果引用的对象**一定**在访问前不会被释放 → 用 `unowned`（更快，非可选）

在实际开发中，`weak` 更常用，因为它更安全。`unowned` 只在你有绝对把握时使用，一旦出错就是运行时崩溃。

**Q3. `struct` 可以使用 `weak` 吗？**

不行。`weak` 只适用于引用类型（`class`）。`struct` 是值类型，不涉及引用计数，自然也不存在 `weak` 的概念。如果你在 `struct` 中声明 `weak var`，编译器会报错。

**Q4. 为什么闭包捕获列表 `[weak self]` 中 `self` 变成了可选类型？**

`weak` 引用的本质就是可选类型。当被引用的对象被释放时，`weak` 引用会自动设为 `nil`。因此闭包内的 `self` 类型从 `SomeClass` 变成了 `SomeClass?`，你需要用 `self?.someMethod()` 或 `guard let self = self else { return }` 来安全使用。

**Q5. `unowned` 引用被访问后程序崩溃了，怎么办？**

崩溃信息通常是 `EXC_BAD_ACCESS` 或类似 "attempted to read an unowned reference but the object was already deallocated"。这说明你的假设错了——被 `unowned` 引用的对象已经被释放。最直接的修复方式是改为 `weak`，并在访问前做 nil 检查。如果你确认对象不应该被释放，那说明别的地方有逻辑错误导致对象被提前释放了。

**Q6. 闭包什么时候需要用 `[weak self]`，什么时候不需要？**

判断标准是：**闭包是否被持有并且和 `self` 之间可能形成循环**。如果闭包是临时使用的（如 `array.filter { ... }`），闭包执行完就会销毁，不需要 `[weak self]`。但如果闭包被存储为一个属性（如 `lazy var`）或者被异步任务持有，那就必须检查是否形成了强引用循环。

**Q7. Swift 的 ARC 和 Objective-C 的 ARC 有什么区别？**

本质上是一样的——都是基于引用计数的内存管理。区别在于 Swift 的 ARC 更严格：
- Swift 中 `protocol` 要实现 `weak` 必须声明 `: AnyObject` 约束
- Swift 引入了 `unowned(unsafe)`（与 Objective-C 的 `__unsafe_unretained` 对应）
- Swift 5.7+ 引入了 `borrowing` 和 `consuming` 关键字用于更细粒度的控制

---

## 小结

- ARC 是 Swift 的内存管理机制，通过引用计数器决定何时释放 class 实例——计数归零即释放
- `weak` 引用不增加计数且会在对象释放后自动变为 `nil`，是打破循环引用的首选方式
- 闭包默认强引用外部变量，使用捕获列表 `[weak self]`、`[unowned self]`、`[value]` 来控制捕获行为

---

## 术语表

| 术语 | 说明 |
|------|------|
| ARC (自动引用计数, Automatic Reference Counting) | Swift 的内存管理方式，编译器自动在合适位置插入 retain/release 操作，计数归零时释放对象 |
| 强引用 (Strong Reference) | 默认引用方式，增加引用计数。声明时不加任何修饰符即为强引用 |
| 弱引用 (Weak Reference) | `weak` 修饰的引用，不增加计数，对象释放后自动设为 `nil`，必须用于可选类型 |
| 无主引用 (Unowned Reference) | `unowned` 修饰的引用，不增加计数，对象释放后不会自动设为 `nil`，访问已释放对象会崩溃 |
| 捕获列表 (Capture List) | 闭包参数前的方括号语法 `[weak self]`, `[unowned self]`, `[value]`，用于控制闭包如何捕获外部变量 |
| 循环引用 (Retain Cycle) | 两个或多个 class 实例互相强引用导致各自的引用计数永远大于零，内存无法释放 |
| deinit | class 的析构函数，在实例引用计数归零、被释放前自动调用，用于清理资源和调试验证 |

---

## 知识检查

**问题 1**: 以下代码的输出是什么？

```swift
class A {
    var b: B?
    deinit { print("A deinit") }
}

class B {
    weak var a: A?
    deinit { print("B deinit") }
}

var a: A? = A()
var b: B? = B()
a?.b = b
b?.a = a
a = nil
b = nil
```

<details>
<summary>查看答案</summary>

```
A deinit
B deinit
```

`b?.a` 是弱引用，不增加 `A` 的计数。`a = nil` 时 `A` 的计数归零 → 先触发 `A deinit`。`A` 释放后对 `B` 的强引用也消失了，`B` 的计数变为 1（只剩变量 `b` 持有）。`b = nil` 时 `B` 的计数归零 → 触发 `B deinit`。

</details>

**问题 2**: 如果把问题 1 中 `B` 的 `weak var a: A?` 改为 `var a: A?`（强引用），输出是什么？

<details>
<summary>查看答案</summary>

**没有任何输出**。`A` 和 `B` 互相强引用，形成了循环引用。`a = nil` 只是移除了外部变量对 `A` 的引用，但 `B.a` 还在强引用 `A`。同理 `b = nil` 也无法释放 `B`，因为 `A.b` 还在强引用 `B`。两个对象都不会被释放，`deinit` 不会被调用——这就是内存泄漏。

</details>

**问题 3**: 以下闭包中 `[localValue]` 的作用是什么？如果去掉 `[localValue]`，输出会有什么变化？

```swift
var localValue = 42
let closure = { [localValue] in
    print(localValue)
}
localValue = 100
closure()
```

<details>
<summary>查看答案</summary>

输出：**`42`**。

`[localValue]` 把 `localValue` 在闭包定义时的值（42）**值拷贝**到闭包中。之后 `localValue = 100` 的修改不会影响闭包内部的值。

如果去掉 `[localValue]` 改成普通闭包 `{ print(localValue) }`，闭包会读取 `localValue` 的**当前值**（因为 `localValue` 是值类型，闭包会捕获它的引用），输出变为 **`100`**。

</details>

---

## 继续学习

完成了 ARC 与内存管理的学习，你已经掌握了 Swift 中管理对象生命周期的核心技能。接下来可以：

- 阅读 [Opaque Types (不透明类型)](./opaque-types.md) 了解 Swift 类型系统的另一个高级特性
- 回到 [高级进阶概览](./advance-overview.md) 查看还未完成的章节
