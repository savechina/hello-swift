# 基础数据类型

## 开篇故事

去超市购物时，你会用不同的容器装东西：塑料袋装水果，玻璃罐装酱料，纸盒装鸡蛋。每种容器装不同类型、不同数量的东西。Swift 的**数据类型**也是这个道理。

`Int` 和 `Double` 像标了容量的瓶子，`String` 像可以无限拉长的绳子，`Array` 是排队的一列物品，`Set` 是一袋不重复的糖果，`Dictionary` 是你手机通讯录里的名字和号码对应表。理解了这些容器，你就能在程序中存储和操作任何数据。

---

## 本章适合谁

你已经学完变量与表达式，知道 `let` 和 `var` 的区别。这一章带你深入 Swift 的类型系统。如果你从未接触过强类型语言，或者好奇 Swift 和 Python/Rust 在类型方面的差异，这一章很适合你。

---

## 你会学到什么

完成本章后，你可以：

1. 区分和使用 Swift 的数值类型（Int、Float、Double）和布尔类型（Bool）
2. 创建和操作 String、Array、Set、Dictionary 四种集合类型
3. 使用元组 (Tuple) 组合多个返回值
4. 理解类型推断与显式类型标注的区别和适用场景
5. 使用可选类型 (Optional) 安全地处理缺失值

---

## 前置要求

完成 [变量与表达式](expression.md) 的学习。本章会大量使用 `let`、`var` 和字符串插值。

---

## 第一个例子

打开 `Sources/BasicSample/DatatypeSample.swift`，找到 `collectionSample()` 函数里的这段代码：

```swift
let array = [1, 2, 3, 4, 5]
var sum = Int32()
for i in array {
    sum = sum + Int32(i)
}
print("sum: \(sum)")
```

**发生了什么？**

- `[1, 2, 3, 4, 5]` 创建了一个包含 5 个整数的数组，类型推断为 `[Int]`
- `Int32()` 创建了初值为 0 的 32 位整数
- `Int32(i)` 把数组中的每个 `Int` 转换为 `Int32` 再累加

**输出**:
```
sum: 15
```

---

## 原理解析

### 1. 数值类型家族

Swift 提供了完整的数值类型，每种类型有明确的位宽：

```swift
// 有符号整数
let age: Int = 30          // 平台自然位宽 (32位或64位)
let small: Int8 = -128     // 8位，范围 -128...127
let precise: Int32 = 100   // 32位

// 无符号整数
let count: UInt = 1000     // 无符号平台自然位宽
let byte: UInt8 = 255      // 8位，范围 0...255

// 浮点数
let pi: Float = 3.14           // 32位，约7位有效数字
let e: Double = 2.718281828    // 64位（Swift 默认浮点类型）

// 布尔值
let isSwiftFun: Bool = true
let isBoring: Bool = false
```

**核心规则**：不同类型之间不能直接运算。你需要显式转换：

```swift
let x: Int = 5
let y: Double = 3.14
// let z = x + y  // ❌ 错误！Int 和 Double 不能相加
let z = Double(x) + y  // ✅ 正确，z 的类型是 Double
```

### 2. String：字符串操作

字符串在 Swift 中是值类型，行为可预期：

```swift
let greeting = "Hello"
let name = "Swift"
let full = greeting + ", " + name + "!"  // 拼接

let age = 25
let info = "\(name) is \(age) years old"  // 插值

print("Length: \(full.count)")   // 字符数量
print("Is empty: \(full.isEmpty)")  // false
print("Contains Hello: \(full.contains("Hello"))")  // true
```

常见操作：
- `+` 拼接两个字符串
- `\(...)` 字符串插值，可以嵌入变量和表达式
- `.count` 字符数量
- `.isEmpty` 检查是否为空
- `.contains()` 子串查找

### 3. Array：有序集合

数组保存一组相同类型的值，顺序固定：

```swift
// 创建
var shoppingList: [String] = ["Eggs", "Milk"]  // 显式类型
let numbers = [1, 2, 3, 4, 5]                  // 类型推断

// 初始化空数组
var emptyArray = [Int]()
var repeating = Array(repeating: 0.0, count: 3)  // [0.0, 0.0, 0.0]

// 添加元素
shoppingList.append("Flour")
shoppingList += ["Butter", "Sugar"]

// 访问
let first = shoppingList[0]           // "Eggs"
let count = shoppingList.count        // 5
let isEmpty = shoppingList.isEmpty    // false

// 遍历（带索引）
for (index, value) in shoppingList.enumerated() {
    print("Item \(index + 1): \(value)")
}
```

### 4. Set：无序不重复集合

Set 中的元素不重复，且无序。适合做去重和集合运算：

```swift
// 创建
var letters: Set<Character> = []
letters.insert("a")

var favoriteGenres: Set = ["Rock", "Classical", "Hip hop"]

// 集合运算
let oddDigits: Set = [1, 3, 5, 7, 9]
let evenDigits: Set = [0, 2, 4, 6, 8]

let allDigits = oddDigits.union(evenDigits)              // 并集: 0-9
let common = oddDigits.intersection(evenDigits)          // 交集: 空
let onlyOdd = oddDigits.subtracting([1, 3])              // 差集: [5, 7, 9]
let uniqueToBoth = oddDigits.symmetricDifference([2, 3, 5, 7])  // 对称差

// 检查和删除
if let removed = favoriteGenres.remove("Rock") {
    print("Removed: \(removed)")
}
```

### 5. Dictionary：键值对映射

Dictionary 通过唯一的键快速查找对应的值：

```swift
// 创建
var namesOfIntegers: [Int: String] = [:]
namesOfIntegers[16] = "sixteen"

var airports: [String: String] = [
    "YYZ": "Toronto Pearson",
    "DUB": "Dublin"
]

// 添加和修改
airports["LHR"] = "London"      // 新增
airports["YYZ"] = "Toronto"     // 修改已有键

// 访问（返回可选类型!）
let code = airports["LHR"]      // Optional("London")
let missing = airports["XXX"]   // nil

// 遍历
for (airportCode, airportName) in airports {
    print("\(airportCode): \(airportName)")
}

// 只遍历键或值
for code in airports.keys { print(code) }
for name in airports.values { print(name) }
```

**重要**：通过键访问字典时返回的是可选类型。键不存在时返回 `nil`，不会崩溃。

### 6. 元组 (Tuple)

元组把多个值组合成一个复合值：

```swift
// 无名元组
let http404 = (404, "Not Found")
print("Status: \(http404.0), Message: \(http404.1)")

// 命名元组（推荐！可读性更好）
let result = (statusCode: 200, description: "OK")
print("Status: \(result.statusCode)")

// 函数返回多个值（来自 DatatypeSample）
func minMax(array: [Int]) -> (min: Int, max: Int) {
    var currentMin = array[0]
    var currentMax = array[0]
    for value in array[1..<array.count] {
        if value < currentMin { currentMin = value }
        else if value > currentMax { currentMax = value }
    }
    return (currentMin, currentMax)
}

let bounds = minMax(array: [8, -6, 2, 109, 3, 71])
print("min is \(bounds.min), max is \(bounds.max)")
// 输出: min is -6, max is 109
```

### 7. 类型推断 vs 显式标注

Swift 编译器能自动推断大多数类型，但你也可以显式指定：

```swift
// 类型推断（编译器自动判断）
let name = "Swift"      // 推断为 String
let count = 42          // 推断为 Int
let pi = 3.14           // 推断为 Double

// 显式类型标注
let name2: String = "Swift"
let count2: Int = 42
let pi2: Double = 3.14
let smallNum: Int8 = 127
```

**何时需要显式标注？**
- 编译器无法推断（如空集合 `[Int]()`）
- 你想覆盖默认推断（如 `Float` 而不是 `Double`）
- 代码意图需要更清晰时

### 8. 可选类型 (Optional)

Swift 用可选类型安全地表示"值可能存在也可能不存在"：

```swift
// 声明
let maybeName: String? = "Alice"    // 有值
let nothing: String? = nil           // 无值

// 可选绑定（安全解包）
if let name = maybeName {
    print("Hello, \(name)!")   // 只在有值时执行
} else {
    print("No name provided")
}

// 处理 nil 的情况
if let name = nothing {
    print("Hello, \(name)!")
} else {
    print("No name provided")   // 会执行这个分支
}
```

**为什么需要可选类型？** 在 Python 中，缺失值是 `None`，访问一个不存在的键会抛异常。Swift 把"可能为空"这件事变成了类型系统的一部分。函数返回 `String?` 时，你必须处理 `nil` 的情况，这从编译阶段就消除了大量空指针错误。

---

## 常见错误

### 错误 1: 不同类型之间直接运算

```swift
let x: Int = 5
let y: Double = 3.0
let z = x + y  // ❌
```

**编译器输出**:
```
error: binary operator '+' cannot be applied to values of type 'Int' and 'Double'
```

**修复方法**:
```swift
let z = Double(x) + y  // ✅ 先把 Int 转为 Double
```

### 错误 2: 数组越界访问

```swift
let fruits = ["Apple", "Banana"]
print(fruits[5])  // ❌ 运行时崩溃！
```

**编译器输出**:
```
Fatal error: Index out of range
```

**修复方法**:
```swift
if fruits.count > 5 {
    print(fruits[5])
} else {
    print("Index out of bounds")
}
```

### 错误 3: 强制解包 nil 可选值

```swift
let dictionary = ["name": "Alice"]
let age = dictionary["age"]!  // ❌ 键 "age" 不存在
```

**编译器输出**:
```
Fatal error: unexpectedly found nil while unwrapping an optional value
```

**修复方法**:
```swift
if let age = dictionary["age"] {
    print("Age: \(age)")
} else {
    print("Age not found")
}
```

---

## Swift vs Rust/Python 对比

| 概念 | Python | Rust | Swift | 关键差异 |
|------|--------|------|-------|----------|
| 整数类型 | `int` (任意精度) | `i32`, `i64` 等 | `Int`, `Int8`, `Int32` | Swift 的 `Int` 是平台自适应位宽 |
| 浮点类型 | `float` (64位) | `f32`, `f64` | `Float`, `Double` | Swift 默认推 `Double` |
| 布尔类型 | `True`/`False` | `true`/`false` | `true`/`false` | Python 首字母大写 |
| 字符串 | `"hello"` | `"hello".to_string()` | `"hello"` | Python 字符串可变；Swift/Rust 默认不可变 |
| 数组/列表 | `list = [1, 2]` | `vec![1, 2]` | `[1, 2, 3]` | Swift 数组同类型；Python 列表可混 |
| 集合 | `set = {1, 2}` | `HashSet::new()` | `Set([1, 2])` | Swift 用字面量推导集合类型 |
| 字典/哈希表 | `dict = {"a": 1}` | `HashMap::new()` | `["a": 1]` | 三种语言的字典语法最接近 |
| 元组 | `(1, "a")` | `(1, "a".to_string())` | `(1, "a")` | Python 和 Swift 元组语法几乎相同 |
| 可选类型 | 用 `None` | `Option<T>` | `T?` | Swift 用 `?` 后缀最简洁 |
| 类型推断 | 动态类型 | `let x = 5` | `let x = 5` | Python 完全动态；Rust/Swift 静态推断 |

---

## 动手练习

### 练习 1: 类型判断

不运行代码，判断下面每个变量的类型：

```swift
let a = 42
let b = 3.14
let c = [1, 2, 3]
let d: Float = 2.5
let e = "hello"
```

<details>
<summary>点击查看答案</summary>

- `a`: `Int`
- `b`: `Double`
- `c`: `[Int]`
- `d`: `Float`（显式标注）
- `e`: `String`

</details>

### 练习 2: 字典操作

创建一个字典存储你的三门课成绩，然后计算平均分：

```swift
// 你的代码
```

<details>
<summary>点击查看参考实现</summary>

```swift
let scores = ["Math": 95, "English": 88, "Science": 92]
var total = 0
for score in scores.values {
    total += score
}
let average = Double(total) / Double(scores.count)
print("Average score: \(average)")
// 输出: Average score: 91.666...
```

注意：`Double(total) / Double(scores.count)` 中的转换是必须的，因为 `Int` 和 `Int` 相除还是 `Int`，小数部分会被截断。

</details>

### 练习 3: 可选绑定

给一个可能为 `nil` 的字典值做安全访问：

```swift
let config: [String: String]? = nil
// 安全地读取 "theme" 键

let config2: [String: String]? = ["theme": "dark"]
// 安全地读取 "theme" 键
```

<details>
<summary>点击查看参考实现</summary>

```swift
// 第一层：可选字典
if let config = config {
    // 第二层：可选值
    if let theme = config["theme"] {
        print("Theme: \(theme)")
    }
} else {
    print("Config is nil")  // 会执行这句
}

// 更简洁的写法：if let 链
if let config2 = config2, let theme = config2["theme"] {
    print("Theme: \(theme)")  // Theme: dark
}
```

</details>

---

## 故障排查 FAQ

### Q: `Int` 和 `Int32` 有什么区别？什么时候该用哪个？

**A**: `Int` 是当前平台的自然位宽，在 64 位机器上是 64 位，在 32 位机器上是 32 位。`Int32` 固定 32 位。

- **日常编程用 `Int`**：这是 Swift 的默认选择，性能最好
- **和 C/外部库交互时用固定位宽类型**：如 `Int32`、`UInt8`，确保二进制布局匹配
- **处理网络协议或文件格式时用固定位宽类型**：确保跨平台一致性

### Q: 为什么字典访问返回值要加 `?`？

**A**: 字典用键查询值时，键可能不存在。返回 `T?`（可选类型）让编译器强制你处理"找不到"的情况。

```swift
let dict = ["a": 1]
let value: Int? = dict["b"]   // nil
let forced = dict["b"]!       // 💥 崩溃！不要这样做
```

Python 用 `dict.get("b")` 返回 `None`，行为类似。但 Python 不会阻止你对 `None` 调用方法，Swift 会在编译阶段就拦住你。

### Q: 元组和结构体 (struct) 有什么区别？

**A**: 元组是临时的轻量组合，适合短场景返回值（如函数返回多个值）。结构体是正式类型，定义了字段名和方法，适合在代码中反复使用。

- 临时分组用 **元组**
- 需要复用、传递、扩展用 **结构体**

---

## 小结

**核心要点**:

1. **数值类型有明确位宽** — `Int`、`Int8`、`Float`、`Double`，不同类型不能直接运算
2. **String 是值类型** — 支持拼接 (`+`) 和插值 (`\(...)`  ）
3. **Array 有序可重复，Set 无序不重复，Dictionary 键值映射** — 三种各有适用场景
4. **元组组合多值** — 命名元组比 `tuple.0` 可读性好得多
5. **可选类型 `T?` 安全处理缺失值** — 用 `if let` 绑定解包，永远不要 `!` 强制解包

**关键术语**:

- **Type Inference**: 类型推断（编译器自动判断）
- **Optional**: 可选类型（值可能为 nil）
- **Optional Binding**: 可选绑定（`if let` 安全解包）
- **Tuple**: 元组（复合值类型）
- **Explicit Type Annotation**: 显式类型标注

---

## 术语表

| English | 中文 |
|---------|------|
| Integer | 整数 |
| Float | 单精度浮点数 |
| Double | 双精度浮点数 |
| Boolean | 布尔值 |
| String | 字符串 |
| Array | 数组 |
| Set | 集合 |
| Dictionary | 字典 |
| Tuple | 元组 |
| Optional | 可选类型 |
| Optional Binding | 可选绑定 |
| Type Inference | 类型推断 |
| Type Annotation | 类型标注 |
| Collection | 集合类型 |

---

完整示例：`Sources/BasicSample/DatatypeSample.swift`

---

## 知识检查

**问题 1** 🟢 (基础概念)

```swift
let numbers = [1, 2, 3]
let moreNumbers = numbers + [4, 5]
```

`moreNumbers` 的值和类型是什么？

<details>
<summary>答案与解析</summary>

**答案**: `[1, 2, 3, 4, 5]`，类型 `[Int]`

**解析**: 数组用 `+` 拼接，结果是新数组。原有 `numbers` 不变（因为用 `let` 声明）。

</details>

**问题 2** 🟡 (可选类型)

```swift
let dict = ["key": "value"]
print(dict["missing"] ?? "default")
```

输出是什么？

<details>
<summary>答案与解析</summary>

**答案**: `default`

**解析**: `dict["missing"]` 返回 `nil`，`??` 空值合并运算符在可选值为 `nil` 时提供默认值。等价于：

```swift
let result = dict["missing"] != nil ? dict["missing"]! : "default"
```

</details>

**问题 3** 🔴 (类型推断 + 转换)

```swift
let a = 5
let b = 3.0
let c = Double(a) + b
let d = a + Int(b)
```

`c` 和 `d` 的值和类型分别是什么？

<details>
<summary>答案与解析</summary>

**答案**: `c = 8.0`（`Double`），`d = 8`（`Int`）

**解析**:
- `Double(a)` 把 `5` 转为 `5.0`，`5.0 + 3.0 = 8.0`（Double）
- `Int(b)` 把 `3.0` 转为 `3`，`5 + 3 = 8`（Int）
- 关键是看运算中最高精度的类型来决定结果类型。

</details>

---

## 延伸阅读

学完基础数据类型后，你可能还想了解：

- [Swift 官方文档 - Basic Operators](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/basicoperators/) - 运算符深入
- [Swift 官方文档 - Collection Types](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/collectiontypes/) - 集合类型完整参考

**选择建议**:
- 想深入理解循环和条件判断 → 继续学习 [控制流](control-flow.md)
- 已有编程经验 → 跳到 [函数](functions.md)

> 💡 **记住**：Swift 是强类型语言。编译器比你更早知道类型错误，善用类型推断，但不要害怕显式标注。

---

## 继续学习

- 下一步：[控制流](control-flow.md) - 条件判断和循环
- 相关：[函数](functions.md) - 学习如何组织代码
- 进阶：[枚举](enums.md) - Swift 最强大的类型之一
