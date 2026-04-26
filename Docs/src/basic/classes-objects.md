# 类与对象

## 开篇故事

想象你有一座积木工厂。你设计了一个基础积木模板，上面有凸起的点和连接槽。然后你在这个模板基础上，做出了不同形状的积木：带轮子的、带窗户的、带门的。它们都继承了基础积木的连接方式，但各自有不同的功能。

Swift 中的**类**（Class）就跟这个模板工厂一样。你定义一个基础类，然后让其他类**继承**它的特性，再添加自己的独有功能。

在 Swift 中，类是**引用类型**（Reference Type）。这意味着当你把类实例赋值给另一个变量时，你传递的是指向同一个实例的"遥控器"，而不是拷贝整个实例。这跟结构体（Struct）的值类型语义完全不同。

---

## 本章适合谁

如果你已经理解了变量、数据类型和函数，想深入学习 Swift 的面向对象编程，本章适合你。无论你是从 Python、Java 还是 Rust 过来，本章会帮你理解 Swift 类的独特设计。

---

## 你会学到什么

完成本章后，你可以：

1. 使用 `class` 关键字定义类并使用继承
2. 理解指定初始化器（Designated Initializer）和便捷初始化器（Convenience Initializer）
3. 使用 `deinit` 管理资源清理和 ARC 内存管理
4. 掌握引用类型与值类型的区别以及身份运算符 `===` 和 `!==`
5. 使用 `is`、`as?`、`as!` 进行类型检查和类型转换

---

## 前置要求

确保你已经阅读了 [基础数据类型](datatype.md) 一章，理解 Swift 的基本类型系统和变量声明。本章中的类示例会用到字符串、数值和闭包等知识点。

---

## 第一个例子

打开 `Sources/BasicSample/ClassSample.swift`，找到以下代码：

```swift
/// MediaItem 基类
class MediaItem {
    var name: String
    init(name: String) {
        self.name = name
    }
}

/// Movie 继承 MediaItem
class Movie: MediaItem {
    var director: String
    init(name: String, director: String) {
        self.director = director
        super.init(name: name)
    }
}

/// Song 也继承 MediaItem
class Song: MediaItem {
    var artist: String
    init(name: String, artist: String) {
        self.artist = artist
        super.init(name: name)
    }
}
```

**发生了什么？**

- `MediaItem` 是基类，所有媒体项目的共同抽象，包含 `name` 属性
- `Movie` 继承 `MediaItem`，额外增加了 `director`（导演）属性
- `Song` 同样继承 `MediaItem`，增加了 `artist`（艺术家）属性
- 子类初始化器必须先初始化自己的属性，再调用 `super.init` 初始化父类

**使用示例**：

```swift
let movie = Movie(name: "Blade Runner", director: "Ridley Scott")
let song = Song(name: "Imagine", artist: "John Lennon")
print("\(movie.name) directed by \(movie.director)")
print("\(song.name) by \(song.artist)")
```

**输出**：
```
Blade Runner directed by Ridley Scott
Imagine by John Lennon
```

---

## 原理解析

### 1. 类定义与继承

Swift 中的继承使用冒号语法。子类自动获得父类的所有属性和方法：

```swift
class Shape {
    var description: String {
        "Shape"
    }
    var area: Double { 0.0 }
}

class Rectangle: Shape {
    var width: Double
    var height: Double

    init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }

    override var area: Double {
        get {
            return width * height
        }
        set(newArea) {
            height = newArea / width
        }
    }

    override var description: String { "Rectangle" }
}
```

**关键点**：
- 子类用 `class Rectangle: Shape` 语法继承
- 子类必须用 `override` 关键字标记对父类的重写
- Swift 不会默认允许重写，必须显式声明，这比 Java 或 C++ 更安全

### 2. 指定初始化器 vs 便捷初始化器

每个类至少有一个**指定初始化器**（Designated Initializer），负责确保所有属性都被正确初始化。Swift 还支持**便捷初始化器**（Convenience Initializer）：

```swift
class Person {
    var firstName: String
    var lastName: String
    var age: Int

    // 指定初始化器 — 必须初始化所有属性
    init(firstName: String, lastName: String, age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
    }

    // 便捷初始化器 — 委托给指定初始化器
    convenience init(firstName: String, lastName: String) {
        self.init(firstName: firstName, lastName: lastName, age: 0)
    }
}

let alice = Person(firstName: "Alice", lastName: "Wong") // 使用便捷初始化器
let bob = Person(firstName: "Bob", lastName: "Lee", age: 30) // 使用指定初始化器
```

**初始化规则**：
1. 指定初始化器必须初始化本类声明的所有属性，然后调用父类的初始化器
2. 便捷初始化器必须委托给同一个类的另一个初始化器
3. 子类不会自动继承父类的初始化器，除非满足特定条件

### 3. 重写（Override）

子类可以重写父类的属性、方法和下标。Swift 要求使用 `override` 关键字：

```swift
class Circle: Shape {
    var radius: Double

    init(radius: Double) {
        self.radius = radius
    }

    // 重写父类的只读计算属性
    override var area: Double {
        return .pi * radius * radius
    }

    override var description: String { "Circle" }
}

let circle = Circle(radius: 5.0)
print("\(circle.description) area = \(circle.area)")
// 输出: Circle area = 78.53981633974483
```

**注意事项**：
- `override` 是必须的，不加 `override` 的匹配方法签名会报编译错误
- 重写后方法的访问级别不能比父类更严格
- 可以用 `final` 关键字阻止子类重写

### 4. deinit 与 ARC 内存管理

Swift 使用**自动引用计数**（Automatic Reference Counting, ARC）管理内存。当类的引用计数归零时，`deinit` 会被自动调用：

```swift
class DatabaseConnection {
    let connectionString: String

    init(connectionString: String) {
        self.connectionString = connectionString
        print("Connected to \(connectionString)")
    }

    deinit {
        print("Disconnected from \(connectionString)")
        // 清理数据库连接等资源
    }
}

func createConnection() {
    let db = DatabaseConnection(connectionString: "localhost:5432/mydb")
    print("Working with database...")
}
// 函数结束后 db 引用归零，deinit 自动调用

createConnection()
```

**输出**：
```
Connected to localhost:5432/mydb
Working with database...
Disconnected from localhost:5432/mydb
```

**ARC 核心规则**：
- 每次有新的引用指向一个类实例，引用计数 +1
- 每次引用离开作用域或被设为 nil，引用计数 -1
- 引用计数归零时，ARC 自动调用 `deinit` 并释放内存
- 结构体和枚举是值类型，不受 ARC 管理

### 5. 引用类型 vs 值类型

这是 Swift 最重要的概念之一。类是**引用类型**，结构体和枚举是**值类型**：

```swift
class MyClass {
    var value = 0
}

struct MyStruct {
    var value = 0
}

// 值类型：赋值时拷贝
var a = MyStruct(value: 10)
var b = a            // 拷贝一份新的
b.value = 20         // 修改 b
print(a.value)        // 10 — a 没有被影响

// 引用类型：赋值时共享
let x = MyClass()
x.value = 10
let y = x            // y 指向同一个实例
y.value = 20         // 修改 y
print(x.value)        // 20 — x 也被影响了！
```

**选择建议**：

| 场景 | 推荐类型 | 原因 |
|------|---------|------|
| 需要共享状态、身份语义 | 类 (Class) | 引用语义天然支持共享 |
| 数据模型、值语义 | 结构体 (Struct) | 拷贝安全，线程安全 |
| 继承和多态 | 类或协议 | 类支持继承，协议支持 POP |
| 不需要生命周期管理 | 结构体或枚举 | 无需 ARC、deinit |

### 6. 身份运算符 === 和 !==

引用类型有"身份"概念。两个变量可能指向同一个实例，也可能指向内容相同但不同的实例：

```swift
class User {
    let id: Int
    init(id: Int) { self.id = id }
}

let user1 = User(id: 1)
let user2 = User(id: 1)
let user3 = user1

print(user1 === user2)  // false — 两个不同的实例 (内容相同)
print(user1 === user3)  // true  — 同一个实例
print(user1 !== user2)  // true  — user1 和 user2 不是同一个实例
```

**身份运算符 vs 相等运算符**：
- `===` 检查两个引用是否指向**同一个实例**（指针比较）
- `==` 检查两个值是否**逻辑相等**（需要实现 `Equatable` 协议）

### 7. 类型检查与类型转换

Swift 使用 `is`、`as?`、`as!` 进行类型检查和转换：

```swift
let library: [MediaItem] = [
    Movie(name: "Inception", director: "Christopher Nolan"),
    Song(name: "Bohemian Rhapsody", artist: "Queen"),
    Movie(name: "Interstellar", director: "Christopher Nolan")
]

// is — 类型检查
var movieCount = 0
var songCount = 0
for item in library {
    if item is Movie {
        movieCount += 1
    } else if item is Song {
        songCount += 1
    }
}
print("Library contains \(movieCount) movies and \(songCount) songs")

// as? — 条件类型转换（返回 Optional）
for item in library {
    if let movie = item as? Movie {
        print("Movie: \(movie.name), director: \(movie.director)")
    }
}

// as! — 强制类型转换（可能崩溃！）
let firstItem = library[0]
let definitelyMovie = firstItem as! Movie  // 如果实际不是 Movie 会崩溃
```

**类型转换安全建议**：
- 优先使用 `as?`，它返回 Optional，失败时是 nil 而不是崩溃
- 只在确定类型匹配时使用 `as!`
- `as` 用于已知安全的编译时转换，如 Bridging Cast（Swift 类型与 Foundation 类型之间）

### 8. 弱引用与无主引用

ARC 的一个常见问题是**强引用循环**。当两个类实例互相持有对方的强引用时，它们的引用计数永远不会归零，导致内存泄漏：

```swift
// 问题示例：强引用循环
class Department {
    let name: String
    var courses: [Course] = []    // 强引用
    init(name: String) { self.name = name }
    deinit { print("\(name) deinitialized") }
}

class Course {
    let title: String
    weak var department: Department?  // 弱引用，不增加引用计数
    init(title: String) { self.title = title }
    deinit { print("\(title) deinitialized") }
}

// 使用弱引用打破循环
let dept = Department(name: "Computer Science")
let course = Course(title: "Data Structures")
dept.courses.append(course)
course.department = dept  // weak 引用，不阻止 dept 被释放
```

**weak vs unowned**：

| 关键字 | 引用计数 | 可以为 nil | 使用场景 |
|--------|----------|------------|----------|
| `weak` | 不增加 | ✅ 可以 | 生命周期可能比持有者短 |
| `unowned` | 不增加 | ❌ 不可以 | 生命周期与持有者相同 |
| 默认 (强引用) | 增加 | 取决于类型 | 一般情况 |

---

## 常见错误

### 错误 1: 子类没有在父类属性初始化前调用 super.init

```swift
class Parent {
    let value: Int
    init(value: Int) { self.value = value }
}

class Child: Parent {
    let extra: String
    init(value: Int, extra: String) {
        super.init(value: value)  // ❌ 先调 super.init，但 extra 还没初始化
        self.extra = extra
    }
}
```

**编译器输出**：
```
error: 'self' used in property access 'value' before super init initializes self
```

**修复方法**：
```swift
class Child: Parent {
    let extra: String
    init(value: Int, extra: String) {
        self.extra = extra        // ✅ 先初始化子类属性
        super.init(value: value)   // 再调用父类初始化器
    }
}
```

### 错误 2: 不使用 override 关键字重写父类方法

```swift
class Shape {
    func draw() { print("Drawing shape") }
}

class Circle: Shape {
    func draw() { print("Drawing circle") } // ❌ 缺少 override
}
```

**编译器输出**：
```
error: method 'draw()' in non-final class 'Circle' must be explicitly declared with 'override'
```

**修复方法**：
```swift
class Circle: Shape {
    override func draw() { print("Drawing circle") } // ✅ 加上 override
}
```

### 错误 3: 强制类型转换失败导致运行时崩溃

```swift
let items: [MediaItem] = [Song(name: "Yesterday", artist: "The Beatles")]
let movie = items[0] as! Movie  // ❌ 运行时崩溃！Song 不是 Movie
```

**运行时崩溃输出**：
```
fatal error: unexpectedly found nil while unwrapping an Optional value
// 或
Could not cast value of type 'Song' to 'Movie'
```

**修复方法**：
```swift
if let movie = items[0] as? Movie {  // ✅ 使用条件转换
    print(movie.name)
} else {
    print("Not a movie")
}
```

---

## Swift vs Rust/Python 对比

| 概念 | Python | Rust | Swift | 关键差异 |
|------|--------|------|-------|----------|
| 类定义 | `class Foo:` | 无（用 struct + impl） | `class Foo { }` | Rust 没有类，只有结构体 |
| 继承 | 支持多继承 | 无（用 Trait） | 单继承 | Swift/Rust 都倾向组合优于继承 |
| 引用计数 | 自动（CPython 内部） | 手动（Rc/Arc） | 自动（ARC） | Swift ARC 编译期插入 retain/release |
| 可变性 | 默认可变 | 默认不可变（`let`/`mut`） | 引用可变（属性可标 var） | Python 类实例默认可变 |
| 析构函数 | `__del__` | `Drop` trait | `deinit` | Swift `deinit` 不接受参数 |
| 类型转换 | `isinstance()` | `dyn Trait` + `downcast` | `is`, `as?`, `as!` | Swift 提供安全的 Optional 转换 |
| 身份比较 | `is` | `Rc::ptr_eq` | `===`, `!==` | Python/Rust 都有对应方案 |

---

## 动手练习

### 练习 1: 创建类层次结构

设计一个动物类层次结构：
- 基类 `Animal`，包含名称和发出声音的方法
- 子类 `Dog` 和 `Cat`，各自实现不同的叫法
- 创建一个 `[Animal]` 数组，遍历并让每个动物发出声音

<details>
<summary>点击查看答案</summary>

```swift
class Animal {
    let name: String
    init(name: String) { self.name = name }
    func makeSound() -> String { "..." }
}

class Dog: Animal {
    override func makeSound() -> String { "Woof!" }
}

class Cat: Animal {
    override func makeSound() -> String { "Meow!" }
}

let animals: [Animal] = [Dog(name: "Buddy"), Cat(name: "Whiskers")]
for animal in animals {
    print("\(animal.name): \(animal.makeSound())")
}
// 输出:
// Buddy: Woof!
// Whiskers: Meow!
```

</details>

### 练习 2: 类型转换统计

给定一个混合数组包含 `Movie`、`Song` 和 `MediaItem`，使用类型转换统计每种类型的数量：

```swift
let items: [MediaItem] = [
    Movie(name: "A", director: "X"),
    Song(name: "B", artist: "Y"),
    Movie(name: "C", director: "Z"),
    MediaItem(name: "D"),
    Song(name: "E", artist: "W")
]
```

<details>
<summary>点击查看答案</summary>

```swift
var movieCount = 0, songCount = 0, baseCount = 0

for item in items {
    if item is Movie {
        movieCount += 1
    } else if item is Song {
        songCount += 1
    } else {
        baseCount += 1
    }
}

print("Movies: \(movieCount), Songs: \(songCount), Base: \(baseCount)")
// 输出: Movies: 2, Songs: 2, Base: 1
```

</details>

### 练习 3: 修复引用循环

下面的代码会导致内存泄漏，请用 `weak` 或 `unowned` 修复：

```swift
class Student {
    let name: String
    var school: School
    init(name: String, school: School) {
        self.name = name
        self.school = school
    }
}

class School {
    let name: String
    var students: [Student] = []
    init(name: String) { self.name = name }
}
```

<details>
<summary>点击查看答案</summary>

```swift
class Student {
    let name: String
    unowned let school: School  // ✅ 用 unowned：学生存续期间学校一定存在
    init(name: String, school: School) {
        self.name = name
        self.school = school
    }
}

class School {
    let name: String
    var students: [Student] = []
    init(name: String) { self.name = name }
}
```

**说明**：这里用 `unowned` 是合理的，因为 Student 引用 School 时，School 一定存活（先创建 School 再把学生加入）。如果用 `weak` 也可以，但每次访问都要解包 Optional。

</details>

---

## 故障排查 FAQ

### Q: 什么时候应该使用类而不是结构体？

**A**: 遵循 Swift 社区的共识：

- **默认使用结构体** - 大部分情况下值语义更安全、更简单
- **需要引用语义时使用类** - 需要共享同一份数据，或需要身份概念时
- **需要继承时使用类** - 虽然协议（Protocol）通常比继承更灵活
- **需要 deinit 时只能用类** - 结构体没有析构函数

> 参考项目中的选择：`ClassSample.swift` 中的 `MediaItem` 体系用类是因为需要多态和共享身份；而 `Matrix` 用结构体是因为它是纯数据模型。

### Q: `weak` 和 `unowned` 到底怎么选？

**A**: 问自己一个问题：被引用的对象可能先于引用者变成 nil 吗？

- **会** → 用 `weak`（声明为 `var weak var`，Optional 类型）
- **不会** → 用 `unowned`（声明为 `unowned let/var`，非 Optional，访问已释放的实例会崩溃）

常见场景：Delegate 用 `weak`，父子关系（子持有父）用 `unowned`。

### Q: 为什么 Swift 的类只支持单继承？

**A**: Swift 选择单继承是因为：

- **避免菱形问题** - 多继承的歧义和复杂性
- **协议（Protocol）提供多继承的效果** - 一个类型可以实现多个协议
- **组合优于继承** - 通过协议扩展（Protocol Extension）实现默认实现，比继承更灵活
- Rust 甚至完全没有继承，只用 Trait，证明了单继承 + Trait/协议是更干净的设计

---

## 小结

**核心要点**：

1. **类是引用类型** - 赋值和传参时共享同一个实例，而不是拷贝
2. **继承用冒号** - `class Child: Parent`，子类用 `override` 重写父类成员
3. **ARC 自动管理内存** - 引用计数归零时自动释放，`deinit` 用于清理资源
4. **`weak` 和 `unowned` 打破强引用循环** - 避免内存泄漏
5. **类型转换用 `is` 和 `as?`** - 安全地检查并转换类型，避免使用 `as!`

**关键术语**：

- **Class**: 类（引用类型）
- **Inheritance**: 继承（子类获得父类特性）
- **Designated Initializer**: 指定初始化器（主要初始化器）
- **Convenience Initializer**: 便捷初始化器（辅助初始化器）
- **ARC**: 自动引用计数（Automatic Reference Counting）
- **deinit**: 析构器（对象销毁时调用）
- **Type Casting**: 类型转换（运行时检查并转换类型）

---

## 术语表

| English | 中文 |
|---------|------|
| Class | 类 |
| Inheritance | 继承 |
| Subclass | 子类 |
| Superclass / Parent class | 父类 |
| Designated Initializer | 指定初始化器 |
| Convenience Initializer | 便捷初始化器 |
| Override | 重写 |
| ARC (Automatic Reference Counting) | 自动引用计数 |
| deinit | 析构器 |
| Reference Type | 引用类型 |
| Value Type | 值类型 |
| Identity Operator | 身份运算符 |
| Type Casting | 类型转换 |
| Weak Reference | 弱引用 |
| Unowned Reference | 无主引用 |
| Strong Reference Cycle | 强引用循环 |

完整示例：`Sources/BasicSample/ClassSample.swift`

---

## 知识检查

**问题 1** 🟢 (基础概念)

```swift
class Counter {
    var count = 0
    func increment() { count += 1 }
}

let c1 = Counter()
let c2 = c1
c1.increment()
print(c2.count)
```

输出是什么？

A) 0  
B) 1  
C) 编译错误  
D) 运行时错误

<details>
<summary>答案与解析</summary>

**答案**: B) 1

**解析**: `c1` 和 `c2` 指向同一个 `Counter` 实例。`c1.increment()` 修改了共享实例的 `count` 属性，`c2` 看到的也是同样的值。这是引用类型的核心特性。

</details>

**问题 2** 🟡 (初始化顺序)

```swift
class Parent {
    let x: Int
    init(x: Int) { self.x = x }
}

class Child: Parent {
    let y: String
    init(x: Int, y: String) {
        super.init(x: x)  // 行 A
        self.y = y        // 行 B
    }
}
```

这段代码能通过编译吗？

A) 能  
B) 不能，行 A 和行 B 需要交换位置  
C) 不能，需要 convenience init  
D) 不能，x 必须用 var

<details>
<summary>答案与解析</summary>

**答案**: B) 不能，行 A 和行 B 需要交换位置

**解析**: Swift 的两阶段初始化规则要求：子类必须先初始化自己的属性（`self.y = y`），再调用父类初始化器（`super.init`）。所以行 A 和行 B 需要交换。交换后：

```swift
init(x: Int, y: String) {
    self.y = y           // 先初始化子类属性
    super.init(x: x)     // 再调用父类初始化器
}
```

</details>

**问题 3** 🔴 (ARC 与内存管理)

```swift
class Node {
    let value: Int
    var next: Node?

    init(value: Int) { self.value = value }
    deinit { print("Node \(value) freed") }
}

var n1 = Node(value: 1)
var n2 = Node(value: 2)
n1.next = n2
n2.next = n1  // 强引用循环

n1 = nil
n2 = nil
```

两个节点的 `deinit` 会被调用吗？

A) 会，两个都被正常释放  
B) 不会，强引用循环导致内存泄漏  
C) 只释放 n1  
D) 编译错误

<details>
<summary>答案与解析</summary>

**答案**: B) 不会，强引用循环导致内存泄漏

**解析**: `n1` 持有 `n2` 的强引用，`n2` 也持有 `n1` 的强引用，形成循环。即使外部引用被设为 nil，两个节点的引用计数仍然是 1，永远不会归零，ARC 不会释放它们。

**修复**：将其中一个引用改为 `weak`：

```swift
class Node {
    let value: Int
    weak var next: Node?   // ✅ 弱引用
    init(value: Int) { self.value = value }
    deinit { print("Node \(value) freed") }
}
```

</details>

---

## 延伸阅读

学习完类与对象后，你可能还想了解：

- [Swift 官方文档 - Classes and Structures](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/classesandstructures/) - 类与结构体的完整说明
- [Swift 官方文档 - Inheritance](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/inheritance/) - 继承深入
- [Swift Blog - ARC](https://www.swift.org/blog/automatic-reference-counting/) - ARC 内存管理原理

**选择建议**:
- 初学者 → 继续学习 [协议](protocols.md)，理解 Protocol-Oriented Programming
- 有面向对象编程经验 → 跳到 [泛型](generics.md)

> 💡 **记住**：Swift 默认推荐结构体，类是在需要引用语义时才选择的高级工具。不要滥用继承，优先考虑协议和组合。

---

## 继续学习

- 下一步：[协议](protocols.md) - 理解 Swift 的 Protocol-Oriented Programming 范式
- 相关：[泛型](generics.md) - 编写类型安全的通用代码
- 进阶：[错误处理](error-handling.md) - do/catch/try 错误传递机制
