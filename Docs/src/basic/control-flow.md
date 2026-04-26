# 控制流

## 开篇故事

你每天早上醒来，大脑就在运行控制流。如果室外温度低于 10 度，你穿外套。如果今天是星期一到星期五，你去上班。否则，你休息。你会反复做同一件事直到满足某个条件，比如刷牙刷了两分钟才停下。

程序也是如此。代码不一定从上到下逐行执行。有时你要根据条件走不同的分支，有时你要反复做一件事直到某个条件满足，有时你要提前结束一段逻辑。Swift 提供了丰富的控制流工具来描述所有这些场景。

---

## 本章适合谁

你已经学完变量与数据类型，理解了 `let`、`var` 和各种集合类型。这一章带你学会让程序做出决策和重复执行任务。如果你写过任何语言的条件判断或循环，你会在这里看到 Swift 的独到设计。

---

## 你会学到什么

完成本章后，你可以：

1. 使用 `if/else` 进行条件分支判断
2. 使用 `switch/case` 处理多路分支，包括范围匹配和元组匹配
3. 使用 `for-in` 遍历数组、字典和各种范围
4. 使用 `while` 和 `repeat-while` 编写循环
5. 使用 `guard` 做前置条件检查和早期退出

---

## 前置要求

完成 [基础数据类型](datatype.md) 的学习。本章会大量使用 `Bool`、比较运算符和 `String`。

---

## 第一个例子

打开 `Sources/BasicSample/ControlFlowSample.swift`，找到 `controlFlowConditionSample()` 函数里的这段代码：

```swift
let temperature = 25
if temperature < 0 {
    print("Freezing!")
} else if temperature < 20 {
    print("Chilly")
} else {
    print("Comfortable")
}
```

**发生了什么？**

- `temperature < 0` 是一个布尔表达式，结果为 `true` 或 `false`
- 三个分支互斥，只会执行其中一个
- `25` 不小于 `0` 也不小于 `20`，所以走 `else` 分支

**输出**:
```
Comfortable
```

---

## 原理解析

### 1. if/else 条件分支

Swift 的 `if` 要求条件必须是布尔值，不能像 C/Python 那样用非零整数替代 `true`：

```swift
let score = 85

if score >= 90 {
    print("A")
} else if score >= 80 {
    print("B")
} else if score >= 70 {
    print("C")
} else {
    print("F")
}
```

**Swift 的一个细节**：`if` 后面不需要括号，但大括号 `{}` 是必须的。这是强制的，不能省略。

**三元条件运算符**也是可选的写法：

```swift
let status = score >= 60 ? "Pass" : "Fail"
```

### 2. switch/case 多路分支

Swift 的 `switch` 比 C 语言强大得多：不需要写 `break`，必须是穷尽的（覆盖所有情况），而且可以匹配各种模式。

```swift
let fruit = "apple"
switch fruit {
case "apple":
    print("🍎 Apple")
case "banana":
    print("🍌 Banana")
case "cherry":
    print("🍒 Cherry")
default:
    print("Unknown fruit")
}
```

**关键差异**：
- **不需要 break**：Swift 的 `case` 执行完后自动退出，不会"穿透"到下一个 case。如果你确实需要穿透，用 `fallthrough`。
- **必须穷尽**：每个可能的值都要被覆盖。字符串有无限可能，所以必须有 `default`。如果枚举只有三个 case，你写了三个 case 就够了，不需要 `default`。

### 3. switch 模式匹配

Swift 的 `switch` 可以匹配范围、元组等各种模式：

```swift
// 范围匹配
let year = 2024
switch year {
case 2000..<2010:
    print("2000s")
case 2010..<2020:
    print("2010s")
case 2020...2100:
    print("2020s or later")
default:
    print("Ancient times")
}

// 元组匹配
let point = (3, 0)
switch point {
case (0, 0):
    print("Origin")
case (_, 0):
    print("On x-axis")
case (0, _):
    print("On y-axis")
case (-2...2, -2...2):
    print("Inside the box")
default:
    print("Outside")
}
// 输出: On x-axis （_ 是通配符，匹配任意值）
```

### 4. for-in 遍历范围

Swift 提供两种范围运算符：

```swift
// 闭区间 ... (包含结束值)
print("1...3:")
for i in 1...3 { print(i) }
// 输出: 1, 2, 3

// 半开区间 ..< (不包含结束值)
print("1..<3:")
for i in 1..<3 { print(i) }
// 输出: 1, 2

// stride 步进迭代
print("Stride 0 to 10 by 3:")
for i in stride(from: 0, to: 10, by: 3) {
    print(i)
}
// 输出: 0, 3, 6, 9
```

**`to` vs `through`**：`stride(from:to:by:)` 是半开区间（不包含 `to` 的值）；如果你想要闭区间，使用 `stride(from:through:by:)`。

### 5. for-in 遍历数组和字典

```swift
// 遍历数组
let names = ["Alice", "Bob", "Charlie"]
for name in names {
    print("Hello, \(name)!")
}

// 带索引遍历
for (index, name) in names.enumerated() {
    print("Person \(index + 1): \(name)")
}

// 遍历字典
let scores = ["Math": 95, "English": 88]
for (subject, score) in scores {
    print("\(subject): \(score)")
}

// 只遍历键或值
for subject in scores.keys { print(subject) }
for score in scores.values { print(score) }
```

### 6. while 和 repeat-while

`while` 先检查条件，`repeat-while` 先执行至少一次再检查：

```swift
// while
var counter = 0
while counter < 3 {
    print("Counter: \(counter)")
    counter += 1
}
// 输出: 0, 1, 2

// repeat-while
var total = 0
repeat {
    total += 1
} while total < 3
print("Total: \(total)")
// 输出: 3
```

**区别**：`repeat-while` 保证循环体至少执行一次。C 语言里的 `do-while` 在 Swift 里叫 `repeat-while`。

### 7. guard：早期退出

`guard` 是一种"守卫"语句，当条件不满足时提前退出当前作用域：

```swift
func greet(_ name: String?) {
    guard let name = name else {
        print("No name provided")
        return
    }
    // name 在这里已经是 unwrapped 的 String
    print("Hello, \(name)!")
}

greet("Alice")     // Hello, Alice!
greet(nil)         // No name provided
```

`guard` 的核心思想："我不关心正确的路径，我只关心出错时该怎么办"。这比嵌套 `if let` 清晰得多：

```swift
// 不推荐：嵌套 if let
func greetBad(_ name: String?) {
    if let name = name {
        print("Hello, \(name)!")
    } else {
        print("No name provided")
    }
}

// 推荐：guard 提前退出
func greetGood(_ name: String?) {
    guard let name = name else {
        print("No name provided")
        return
    }
    print("Hello, \(name)!")
}
```

### 8. 标签语句 (Labeled Statements)

Swift 支持给循环打标签，这样可以在嵌套循环中精确控制 `break` 和 `continue` 跳出的层级：

```swift
outerLoop: for i in 1...3 {
    for j in 1...3 {
        if j == 2 { break outerLoop }  // 跳出外层循环
        print("(\(i), \(j))")
    }
}
// 输出: (1, 1)
// j == 2 时直接跳出 outerLoop，不会继续 i=2 或 i=3 的迭代
```

这个特性在 Python 中没有对应物。Python 你需要设置标志变量或者用函数提前 return 才能跳出多层循环。

---

## 常见错误

### 错误 1: switch 没有覆盖所有情况

```swift
let number = 5
switch number {
case 1:
    print("one")
case 2:
    print("two")
// 缺少 default 或其他 case 覆盖 3, 4, 5, ...
}
```

**编译器输出**:
```
error: switch must be exhaustive
```

**修复方法**:
```swift
switch number {
case 1:
    print("one")
case 2:
    print("two")
default:
    print("other")  // ✅ 覆盖其余所有情况
}
```

### 错误 2: if 条件不是布尔值

```swift
let count = 5
if count {  // ❌ 错误！
    print("has items")
}
```

**编译器输出**:
```
error: condition for 'if' must be of type 'Bool'
```

**修复方法**:
```swift
if count > 0 {  // ✅ 显式布尔表达式
    print("has items")
}
```

### 错误 3: switch case 中缺少可执行语句

```swift
let x = 3
switch x {
case 3:  // ❌ 空 case
case 4:
    print("three or four")
}
```

**编译器输出**:
```
error: case label in a non-exhaustive switch does not cover all possible values
```

**修复方法**： Swift 不允许空 case（除非用 `fallthrough` 或 `@unknown default`）：

```swift
switch x {
case 3:
    fallthrough  // ✅ 显式声明穿透到下一个 case
case 4:
    print("three or four")
default:
    break  // 也可以什么都不做
}
```

---

## Swift vs Rust/Python 对比

| 概念 | Python | Rust | Swift | 关键差异 |
|------|--------|------|-------|----------|
| if/else | `if x > 0:` | `if x > 0 { }` | `if x > 0 { }` | Python 用缩进；Rust/Swift 用大括号 |
| 条件类型 | 任意 Truthy 值 | `bool` | `Bool` | Swift 严格要求 Bool，不接受整数 |
| switch | 无（用 if/elif） | `match` | `switch` | Python 3.10 有 match，但能力有限 |
| break 关键字 | 需要 | 不需要 | 不需要 | Swift/Rust 的 case 不穿透 |
| 范围遍历 | `range(1, 4)` | `1..=3` 或 `1..3` | `1...3` 或 `1..<3` | 三种语言范围语法各不相同 |
| 遍历数组 | `for x in lst:` | `for x in &vec` | `for x in array` | 语法几乎一致 |
| 带索引遍历 | `enumerate(lst)` | `iter.enumerate()` | `array.enumerated()` | Swift 返回 `(index, element)` 元组 |
| while 循环 | `while cond:` | `while cond { }` | `while cond { }` | 语义完全一致 |
| do-while | 无 | `loop { }` | `repeat { } while` | Python 没有 do-while |
| guard / 早期退出 | 无 | `?` 和 `if let` | `guard` | Swift 独有 guard 语句 |
| 跳出外层循环 | 无（需标志变量） | 标签循环 `outer: loop` | 标签循环 `outerLoop:` | Swift/Rust 都支持标签 |

---

## 动手练习

### 练习 1: 预测输出

```swift
for i in 1...5 {
    if i % 2 == 0 {
        continue
    }
    print(i)
}
```

输出什么？

<details>
<summary>点击查看答案</summary>

**输出**:
```
1
3
5
```

**解析**: `i % 2 == 0` 时遇到偶数，`continue` 跳过本次循环，不执行后面的 `print`。奇数时正常输出。

</details>

### 练习 2: FizzBuzz

打印 1 到 15，但如果是 3 的倍数打印 "Fizz"，5 的倍数打印 "Buzz"，同时是 3 和 5 的倍数打印 "FizzBuzz"，其他打印数字本身。

<details>
<summary>点击查看参考实现</summary>

```swift
for i in 1...15 {
    if i % 15 == 0 {
        print("FizzBuzz")
    } else if i % 3 == 0 {
        print("Fizz")
    } else if i % 5 == 0 {
        print("Buzz")
    } else {
        print(i)
    }
}
```

注意：`i % 15 == 0` 的检查必须放在最前面，否则会被单独的 3 或 5 的分支截获。

</details>

### 练习 3: guard 提前退出

写一个函数 `calculateBMI(weight:height:)`，要求 weight 和 height 都为正数。如果任一参数非正，用 guard 提前返回 `nil`：

<details>
<summary>点击查看参考实现</summary>

```swift
func calculateBMI(weight: Double, height: Double) -> Double? {
    guard weight > 0 else {
        print("Weight must be positive")
        return nil
    }
    guard height > 0 else {
        print("Height must be positive")
        return nil
    }
    return weight / (height * height)
}

print(calculateBMI(weight: 70, height: 1.75) ?? "N/A")  // 22.857...
print(calculateBMI(weight: -5, height: 1.75) ?? "N/A")   // nil
```

</details>

---

## 故障排查 FAQ

### Q: switch 为什么必须有 default？

**A**: 因为 Swift 是强类型语言，编译器需要确保每个可能的值都有对应的分支。字符串类型有无限个可能的值，如果你只写了几个具体的 case，编译器就无法确定没写到的值该怎么办。

对于枚举类型，如果写了所有 case，就不需要 `default`。编译器知道枚举的所有可能值。

### Q: for-in 循环中能不能修改集合？

**A**: 不能直接修改正在遍历的集合。Swift 在遍历时会锁定集合状态。如果你想修改，需要遍历一个副本或者收集要修改的索引再操作：

```swift
var numbers = [1, 2, 3, 4, 5]
// ❌ 错误
// for n in numbers {
//     numbers.append(n * 2)  // 运行时错误
// }

// ✅ 正确：遍历副本
for n in numbers {
    numbers.append(n * 2)
}
```

### Q: guard 和 if let 什么时候用哪个？

**A**: 

- **guard**: 用于"前置条件不满足就退出"的场景。它让 happy path（正常执行路径）保持浅层缩进。适合函数开头的参数校验。
- **if let**: 用于"值存在时才执行某段逻辑"的场景。happy path 在 `if` 的大括号内。适合中间流程的条件判断。

选择的标准在于：你是想在"出错时退出"（guard）还是"成功时进入"（if let）。

---

## 小结

**核心要点**:

1. **if/else 做条件分支** — 条件必须是 Bool，大括号不可省
2. **switch 自动 break，必须穷尽** — 支持范围、元组等模式匹配
3. **for-in 遍历数组、字典、范围** — `enumerate()` 带索引
4. **while 先检查，repeat-while 先执行** — 后者至少执行一次
5. **guard 提前退出** — 参数校验利器，保持代码扁平

**关键术语**:

- **Conditional Branching**: 条件分支（if/else）
- **Pattern Matching**: 模式匹配（switch case）
- **Range**: 范围（`...` 和 `..<`）
- **Early Exit**: 早期退出（guard）
- **Labeled Statement**: 标签语句（`name: for`）

---

## 术语表

| English | 中文 |
|---------|------|
| Control Flow | 控制流 |
| Conditional Statement | 条件语句 |
| Branch | 分支 |
| Loop | 循环 |
| Switch Case | 开关语句 |
| Pattern Matching | 模式匹配 |
| Range | 范围 |
| Labeled Statement | 标签语句 |
| Guard | 守卫语句 |
| Early Exit | 早期退出 |
| Exhaustive | 穷尽的 |
| Fallthrough | 穿透 |

---

完整示例：`Sources/BasicSample/ControlFlowSample.swift`

---

## 知识检查

**问题 1** 🟢 (基础概念)

```swift
for i in 1..<4 {
    print(i)
}
```

输出什么？

<details>
<summary>答案与解析</summary>

**答案**:
```
1
2
3
```

**解析**: `1..<4` 是半开区间，包含 1 但不包含 4。所以遍历 1, 2, 3。

</details>

**问题 2** 🟡 (switch 模式匹配)

```swift
let point = (1, 0)
switch point {
case (0, 0):
    print("Origin")
case (_, 0):
    print("On x-axis")
case (0, _):
    print("On y-axis")
default:
    print("Other")
}
```

输出什么？

<details>
<summary>答案与解析</summary>

**答案**: `On x-axis`

**解析**: `point` 是 `(1, 0)`。第一个 case `(0, 0)` 不匹配。第二个 case `(_, 0)` 匹配 —— 第一个位置是通配符任意值都行，第二个位置是 0。case 从上到下匹配，第一个命中就不再尝试后面的。

</details>

**问题 3** 🔴 (guard + 嵌套循环)

```swift
func process(data: [Int]?) {
    guard let data = data else {
        print("No data")
        return
    }
    searchLoop: for item in data {
        for divisor in 2...item {
            if item % divisor == 0 && divisor != item {
                print("\(item) is not prime")
                break searchLoop
            }
        }
        print("\(item) is prime")
    }
}
process(data: [7, 8])
```

输出什么？

<details>
<summary>答案与解析</summary>

**答案**: `7 is prime`

**解析**: 
- `data` 是 `[7, 8]`，guard 通过
- 遍历 `item = 7`：内层循环 divisor 从 2 到 6，没有任何数能整除 7，所以打印 `7 is prime`
- 遍历 `item = 8`：内层循环 divisor = 2 时，`8 % 2 == 0` 且 `2 != 8`，进入 if 分支。打印 `8 is not prime`，然后 `break searchLoop` 跳出整个外层循环
- 最终结果：`7 is prime`，然后 `8 is not prime`，循环结束

</details>

---

## 延伸阅读

学完控制流后，你可能还想了解：

- [Swift 官方文档 - Control Flow](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/controlflow/) - 控制流完整参考
- [Swift 官方文档 - Pattern Matching](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/patternmatching/) - 模式匹配深入

**选择建议**:
- 刚学完条件循环 → 继续学习 [函数](functions.md) - 把逻辑组织成可复用单元
- 已有其他语言经验 → 跳到 [枚举](enums.md) - Swift 枚举是你需要重点关注的内容

> 💡 **记住**：Swift 的控制流设计哲学是"让正确的写法自然，让错误的写法不可能"。强制 Bool 条件、必须穷尽的 switch、自动 break 的 case —— 这些设计减少了你能犯的错误。

---

## 继续学习

- 下一步：[函数](functions.md) - 学习如何组织代码
- 相关：[枚举](enums.md) - Swift 最强大的类型之一
- 进阶：[错误处理](error-handling.md) - 用 guard 处理异常场景
