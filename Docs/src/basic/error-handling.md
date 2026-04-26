# 错误处理

## 开篇故事

想象你在一家餐厅点了一道菜。厨房收到订单后，开始准备。但在做菜的过程中，厨师发现食材用完了，或者火候不对。这时候他需要做两件事。

第一，他必须告诉服务员出了什么问题，让服务员转告客人。第二，如果他已经切了一些菜，必须把工作台清理干净。

Swift 的错误处理机制就是做这两件事的。它让函数能够告诉你"我遇到了一个无法处理的状况"，同时确保资源被正确释放。

---

## 本章适合谁

如果你写过网络请求、文件读写，或者任何可能失败的操作，你的代码就需要错误处理。本章适合所有 Swift 开发者，无论你是刚开始学编程，还是已经从其他语言转过来了。

---

## 你会学到什么

完成本章后，你可以：

1. 定义遵循 Error 协议 (Error protocol) 的自定义错误类型
2. 使用 do-try-catch 模式 (do-try-catch pattern) 捕获和处理错误
3. 理解 throws 关键字 (throws keyword) 的作用范围
4. 区分try? (optional) 和 try! (force unwrap) 的使用场景
5. 使用 defer 块 (defer block) 进行资源清理，以及 rethrows 传播错误

---

## 前置要求

你需要先掌握 Swift 的枚举 (enum) 和基本函数语法。如果还没学过，请先阅读 [基础数据类型](datatype.md) 和 [函数](functions.md)。

---

## 第一个例子

打开 `Sources/BasicSample/ErrorsSample.swift`，让我们从零开始构建一个完整的错误处理示例。

```swift
enum FileError: Error {
    case fileNotFound(name: String)
    case permissionDenied
    case diskFull
}

func openFile(_ name: String) throws -> String {
    if name.isEmpty {
        throw FileError.fileNotFound(name: name)
    }
    return "Contents of \(name)"
}

do {
    let content = try openFile("data.txt")
    print(content)
} catch FileError.fileNotFound(let name) {
    print("File '\(name)' does not exist")
} catch {
    print("Unknown error: \(error)")
}
```

**发生了什么？**

- `enum FileError: Error` — 定义一个错误类型，遵循 Error 协议
- `throws` — 标记函数可能抛出错误，调用者必须用 `try` 处理
- `do { ... } catch` — 捕获错误的代码块

**输出**:
```
Contents of data.txt
```

---

## 原理解析

### 1. Error 协议与枚举

Swift 的错误处理核心是 `Error` 协议。它是一个空协议，任何遵循它的类型都可以作为错误抛出。用枚举表达错误状态是最好的实践：

```swift
enum NetworkError: Error {
    case badURL(String)
    case timeout(seconds: Int)
    case noConnection
}
```

每个 case 可以携带关联值 (associated value)，提供额外的上下文信息。比如 `timeout(seconds: 30)` 能告诉你超时了几秒。

**类比**：
> 错误就像餐厅菜单上的 "已售罄" 标记。每种情况对应不同的菜品，关联值就是售罄的原因和数量。

### 2. throws 与 try / do-catch

在函数声明中加上 `throws`，表示它会抛错：

```swift
func divide(_ a: Int, by b: Int) throws -> Double {
    guard b != 0 else {
        throw ArithmeticError.divisionByZero
    }
    return Double(a) / Double(b)
}
```

调用时必须在 do-catch 块中用 `try`：

```swift
do {
    let result = try divide(10, by: 2)  // ✅ 正常
    print("Result: \(result)")
} catch ArithmeticError.divisionByZero {
    print("Cannot divide by zero!")
} catch {
    print("Unexpected error: \(error)")
}
```

注意 catch 块可以有多个。Swift 会依次匹配，第一个匹配的就执行。最后的 `catch` 不跟模式，充当兜底。

### 3. try? vs try!

当错误对你不重要，你只关心结果时，用 `try?`。它会返回 Optional：

```swift
let content = try? openFile("data.txt")
// content 的类型是 String?
// 如果抛错，content 为 nil
```

`try!` 告诉编译器"我确定不会报错"。如果真的出错了，程序直接崩溃：

```swift
let content = try! openFile("data.txt")
// content 的类型是 String（非 Optional）
// 如果抛错 → 运行时崩溃！
```

何时用哪个？
- `try?` — 结果可以接受为空。比如读取可选配置文件
- `try!` — 你 100% 确定不会出错。比如加载打包在 app 里的资源文件

### 4. 自定义错误与关联值

带关联值的错误能传递更多信息：

```swift
enum ValidationError: Error {
    case tooShort(minLength: Int)
    case containsInvalidCharacters(CharacterSet)
    case alreadyUsed(String)
}

func validateUsername(_ name: String) throws {
    if name.count < 3 {
        throw ValidationError.tooShort(minLength: 3)
    }
}
```

**最佳实践**：用 `localizedDescription` 定制用户可读的错误消息：

```swift
extension ValidationError: CustomStringConvertible {
    var description: String {
        switch self {
        case .tooShort(let min):
            return "用户名至少需要 \(min) 个字符"
        case .containsInvalidCharacters(let chars):
            return "包含非法字符"
        case .alreadyUsed(let name):
            return "'\(name)' 已经被使用了"
        }
    }
}
```

### 5. rethrows — 传播闭包错误

当你的函数接收一个可能抛错的闭包时，用 `rethrows` 而不是 `throws`：

```swift
func mapValues(_ array: [Int], transform: (Int) throws -> Int) rethrows -> [Int] {
    var result: [Int] = []
    for value in array {
        let transformed = try transform(value)
        result.append(transformed)
    }
    return result
}

// 闭包不抛错时，调用不需要 try
let doubled = try mapValues([1, 2, 3]) { $0 * 2 }

// throws 函数也能接收不抛闭包调用
// rethrows 自动适配两种情况
```

`rethrows` 的妙处在于，只有当传入的闭包本身会抛错时，调用才需要 `try`。这比 `throws` 更灵活。

### 6. defer — 作用域退出清理

`defer` 块在当前作用域退出（不管正常退出还是抛错退出）时执行：

```swift
func processFile() throws -> String {
    let file = openResource()
    defer {
        closeResource(file)  // 不管成功还是抛错，都会执行
    }
    
    let content = try readFile(file)
    return content  // 作用域退出，defer 先执行
}
```

多个 defer 从后往前执行 (LIFO):

```swift
func multiDefer() {
    defer { print("A") }
    defer { print("B") }
    defer { print("C") }
    // 输出: C, B, A
}
```

**类比**：就像餐厅关门前的打扫流程。不管今晚生意好坏，关门时必须清理。defer 就是你的打扫清单。

### 7. Result 类型 vs throws vs Optional

Swift 的 `Result<Success, Failure>` 枚举是处理错误的另一种方式：

```swift
enum Result<Success, Failure: Error> {
    case success(Success)
    case failure(Failure)
}
```

用 Result 作为返回值而不是 throw：

```swift
func fetchData(completion: (Result<Data, NetworkError>) -> Void) {
    // 网络请求完成后调用
    if success {
        completion(.success(data))
    } else {
        completion(.failure(.noConnection))
    }
}
```

什么时候用什么？

- **throws** — 同步函数，调用者应该用 do-catch 处理（最常见）
- **Result** — 异步回调，因为回调签名无法加 throws
- **Optional** — 失败很常见，不需要了解失败原因（比如 JSON 解码）

---

## 常见错误

### 错误 1: 忘记 try

```swift
func loadConfig() throws -> String {
    throw ConfigError.missing
}

let config = loadConfig() // ❌ 编译错误！
```

**编译器输出**:
```
error: call can throw but is not marked with 'try'
```

**修复方法**:
```swift
do {
    let config = try loadConfig() // ✅ 用 try
} catch {
    print("Failed to load config")
}
```

### 错误 2: 错误类型没有遵循 Error 协议

```swift
enum MyError {  // ❌ 没有遵循 Error
    case somethingBad
}
```

**编译器输出**:
```
error: type 'MyError' does not conform to protocol 'Error'
```

**修复方法**:
```swift
enum MyError: Error {  // ✅ 加上 Error
    case somethingBad
}
```

### 错误 3: 在 throw 之后写代码

```swift
func parseValue(_ str: String) throws -> Int {
    guard let value = Int(str) else {
        throw ParseError.invalid
    }
    return value
    print("Parsed!") // ❌ 不可达代码
}
```

**编译器输出**:
```
warning: code after 'throw' will never be executed
```

**修复方法**: 删掉 throw 后面的死代码，或者把 print 移到 throw 之前。

---

## Swift vs Rust/Python 对比

| 概念 | Python | Rust | Swift | 关键差异 |
|------|--------|------|-------|----------|
| 错误类型 | 继承 Exception | 实现 Error trait | 遵循 Error 协议 | Swift/Rust 相似 |
| 声明可能出错 | 无标记 | `Result<T, E>` 返回值 | `throws` 关键字 | Python 无编译时检查 |
| 尝试调用 | `try/except` | 手动匹配/`?` 操作符 | `try` + `do/catch` | 语法各有特色 |
| 直接抛出错误 | `raise` | `Err(e)?` / `panic!` | `throw` | Rust 没有 throw 关键字 |
| 清理资源 | `finally` | Drop trait (RAII) | `defer` 块 | 语义最接近的是 finally |
| 错误传递 | 异常自动上浮 | `?` 操作符 | `rethrows` | Rust 更简洁 |

---

## 动手练习

### 练习 1: 定义并抛出错误

定义一个 `AgeError` 枚举，包含 `tooYoung`（最小年龄）和 `tooOld`（最大年龄）两个 case。写一个 `validateAge(_ age: Int) throws` 函数，年龄小于 0 或大于 150 时抛出对应错误。

<details>
<summary>点击查看答案</summary>

```swift
enum AgeError: Error {
    case tooYoung(minAge: Int)
    case tooOld(maxAge: Int)
}

func validateAge(_ age: Int) throws {
    if age < 0 {
        throw AgeError.tooYoung(minAge: 0)
    }
    if age > 150 {
        throw AgeError.tooOld(maxAge: 150)
    }
}

// 测试
do {
    try validateAge(200)
} catch {
    print("Error: \(error)")
}
```

</details>

### 练习 2: defer 资源管理

写一个函数模拟打开文件和关闭文件。在 `defer` 中关闭文件，观察正常返回和抛错时 defer 是否都执行。

<details>
<summary>点击查看答案</summary>

```swift
enum FileError: Error {
    case emptyContent
}

func processFile() throws -> String {
    print("Opening file...")
    defer {
        print("Closing file...")
    }
    
    let content = ""
    if content.isEmpty {
        throw FileError.emptyContent
    }
    return content
}

// 正常情况
do {
    try processFile()
} catch {
    print("Caught error")
}
// 输出: Opening file... \n Closing file... \n Caught error

// defer 无论抛错还是正常返回都会执行
```

</details>

### 练习 3: try? 和 try! 的区别

下面的代码分别输出什么？

```swift
func mayFail(_ shouldFail: Bool) throws -> String {
    if shouldFail { throw FileError.emptyContent }
    return "OK"
}

let a = try? mayFail(true)
let b = try? mayFail(false)
print("a: \(String(describing: a))")
print("b: \(b!)")
```

<details>
<summary>点击查看答案</summary>

**输出**:
```
a: nil
b: OK
```

**解析**:
- `try? mayFail(true)` 抛错 → 返回 nil（Optional 包装）
- `try? mayFail(false)` 成功 → 返回 `Optional("OK")`
- `b!` 安全解包，因为确实成功了

</details>

---

## 故障排查 FAQ

### Q: try? 和 do-catch 应该怎么选？

**A**: 看你是否需要区分不同的错误类型：

- **用 `try?`** — 你只想得到"成功有值"或"失败为 nil"，不关心具体原因。比如解析一个可选的配置
- **用 `do-catch`** — 你需要对不同错误做出不同反应。比如网络请求可能超时、权限不足、服务器错误，每种处理方式都不同

### Q: rethrows 和 throws 有什么区别？

**A**: `rethrows` 更智能。它只在传入的闭包会抛错时才要求调用者处理错误：

- `throws` — 函数一定可能抛错，调用者必须 `try`
- `rethrows` — 函数可能抛出闭包的错误。如果传入的闭包不抛错，调用者不需要 `try`

标准库中的 `map`, `flatMap` 等全是 `rethrows`。

### Q: Result 类型什么时候比 throws 更好？

**A**: Result 主要用在异步回调场景：

```swift
func fetchData(completion: (Result<Data, Error>) -> Void)
```

因为回调函数签名不能加 `throws`。对于普通的同步函数，直接用 `throws` + `do-catch` 更简洁。

---

## 小结

**核心要点**：

1. **错误用枚举表示** — 遵循 Error 协议，case 可携带关联值
2. **throws 标记危险函数** — 调用时必须用 try
3. **do-catch 捕获错误** — 可以匹配特定错误类型，最后用通用 catch 兜底
4. **defer 在作用域退出时执行** — 清理资源，LIFO 顺序
5. **try? 和 try! 是 try 的变体** — try? 返回 Optional，try! 可能崩溃

**关键术语**：

- **Error Protocol**: 错误协议（所有错误类型必须遵循）
- **Throw**: 抛出（将错误传递出去）
- **Catch**: 捕获（处理错误）
- **Rethrows**: 传播（传递闭包的错误）
- **Defer**: 延迟执行（作用域退出时运行清理代码）

---

## 术语表

| English              | 中文         |
| -------------------- | ------------ |
| Error Protocol       | 错误协议     |
| Throw                 | 抛出         |
| Catch                 | 捕获         |
| Rethrows              | 传播错误     |
| Defer                 | 延迟执行     |
| Associated Value      | 关联值       |
| Force Unwrap          | 强制解包     |
| Result Type           | 结果类型     |
| Try?                  | 可选式尝试   |
| CustomStringConvertible | 自定义字符串转换 |

---

完整示例：`Sources/BasicSample/ErrorsSample.swift`

---

## 知识检查

**问题 1** 🟢 (基础概念)

下面哪个关键字用于标记"可能抛出错误的函数"？

A) throws  
B) try  
C) catch  
D) defer

<details>
<summary>答案与解析</summary>

**答案**: A) throws

**解析**: `throws` 放在函数返回类型箭头 `->` 的前面，标记该函数可能抛出错误。调用者必须用 `try` 配合 `do-catch` 处理。

</details>

**问题 2** 🟡 (最佳实践)

```swift
func process() throws -> String {
    defer { print("A") }
    defer { print("B") }
    defer { print("C") }
    return "Done"
}
let _ = try? process()
```

输出顺序是什么？

A) A, B, C  
B) C, B, A  
C) Done, A, B, C  
D) Done, C, B, A

<details>
<summary>答案与解析</summary>

**答案**: B) C, B, A

**解析**: defer 块按 LIFO（后进先出）顺序执行。最后声明的 defer 最先执行。return 语句先触发 defer 链，然后再真正返回。

</details>

**问题 3** 🟡 (设计决策)

你的异步网络函数需要传递成功或失败结果给回调。应该用哪种方式？

A) throws  
B) Result  
C) Optional  
D) panic

<details>
<summary>答案与解析</summary>

**答案**: B) Result

**解析**: 回调函数签名无法用 `throws`。`Result<Data, Error>` 枚举是异步场景的标准做法，调用方可以区分成功和失败情况。

</details>

---

## 延伸阅读

学完错误处理后，你可能还想了解：

- [Swift 官方文档 - Error Handling](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/errorhandling/) — 错误处理语言参考
- [Swift 官方文档 - Defer Statement](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/statements/#Defer-Statement) — defer 语句详解

**选择建议**:
- 初学者 → 继续学习 [控制流](control-flow.md)
- 有经验开发者 → 跳到 [闭包](closures.md) 了解回调中的错误处理

> 记住：错误处理的核心是"让失败显式化"。Swift 不允许你忽略一个可能出错的函数调用。这是为了你的代码更安全！

---

## 继续学习

- 下一步：[闭包](closures.md) — 理解回调模式和错误传播
- 相关：[并发编程](concurrency.md) — async 函数中的错误处理
- 进阶：[协议](protocols.md) — 自定义错误类型的高级技巧
