# 测试框架与质量保证

## 开篇故事

你刚装修完房子，装修公司说"质量没问题"。但你心里犯嘀咕：水管真的不漏水？电路真的安全？门窗真的密封？

于是你决定自己测试：

- 打开水龙头，看水流是否正常
- 开关插座，看电路是否稳定
- 关上窗户，听外面噪音是否隔绝

软件开发也需要这种"自己测试"的精神。测试框架就是你的"验收工具"——运行代码、检查结果、发现问题。

本章教你的，是 Swift 内置的 XCTest 框架。它不需要额外安装，`swift test` 就能运行。学会它，你就能为自己的代码写"验收报告"。

## 本章适合谁

如果你满足以下任一情况，这一章就是为你准备的：

- 你想学会写单元测试，但不知道从哪开始
- 你听说 XCTest 但不确定怎么用 async 测试
- 你想知道 XCTAssertEqual、XCTAssertTrue 这些断言怎么用
- 你想让代码更可靠，减少"改一个地方，崩三个功能"的噩梦

## 你会学到什么

完成本章后，你将掌握以下内容：

- **XCTestCase**：测试类的基本结构，setUp/tearDown 生命周期
- **断言方法**：XCTAssertEqual、XCTAssertTrue、XCTAssertThrowsError 等
- **异步测试**：async test 方法，await 在测试中的用法
- **性能测试**：measure {} 测量代码执行时间
- **运行测试**：swift test、--filter、测试报告解读

## 前置要求

在开始之前，请确保你已掌握以下内容：

- Swift 基础：函数、类、可选类型
- 错误处理：do-catch-try 模式
- async/await：基本异步函数用法

运行环境要求：

- macOS 12.0+ 或 Linux
- Swift 6.0+
- 测试文件位于 `Tests/<TargetName>Tests/`

## 第一个例子

先看一个最基础的测试：验证字符串拼接是否正确。

这段代码来自 `AdvanceSample/Tests/AdvanceSampleTests/TestingSampleTests.swift`。

```swift
import XCTest
@testable import AdvanceSample

final class StringTests: XCTestCase {
    
    func testStringConcatenation() {
        let first = "Hello"
        let second = "World"
        let result = first + " " + second
        
        XCTAssertEqual(result, "Hello World")
    }
}
```

运行测试：

```bash
swift test --filter StringTests
```

输出：

```
Test Case 'StringTests.testStringConcatenation' passed (0.001 seconds)
```

## 原理解析

### XCTestCase：测试的容器

所有测试类继承 `XCTestCase`：

```swift
import XCTest

final class MyTests: XCTestCase {
    // 每个测试方法以 func test... 命名
    func testSomething() {
        // 测试代码...
    }
}
```

**关键约定**：

- 类名通常以 `Tests` 结尾（如 `StringTests`）
- 测试方法名必须以 `test` 开头（如 `testStringConcatenation()`）
- 测试方法无参数、无返回值

### 断言方法一览

XCTest 提供丰富的断言方法：

| 断言 | 用途 | 示例 |
|------|------|------|
| XCTAssertEqual | 比较两个值相等 | `XCTAssertEqual(1 + 1, 2)` |
| XCTAssertNotEqual | 比较两个值不等 | `XCTAssertNotEqual(1, 2)` |
| XCTAssertTrue | 验证条件为 true | `XCTAssertTrue(5 > 3)` |
| XCTAssertFalse | 验证条件为 false | `XCTAssertFalse(1 > 2)` |
| XCTAssertNil | 验证值为 nil | `XCTAssertNil(optionalValue)` |
| XCTAssertNotNil | 验证值不为 nil | `XCTAssertNotNil(optionalValue)` |
| XCTAssertGreaterThan | 验证大于 | `XCTAssertGreaterThan(5, 3)` |
| XCTAssertLessThan | 验证小于 | `XCTAssertLessThan(1, 5)` |
| XCTAssertThrowsError | 验证抛出错误 | `XCTAssertThrowsError(try throwIfNegative(-1))` |
| XCTAssertNoThrow | 验证不抛出错误 | `XCTAssertNoThrow(try safeOperation())` |

### setUp/tearDown：测试生命周期

每个测试方法独立运行。如果需要共享初始化逻辑，用 setUp/tearDown：

```swift
final class DatabaseTests: XCTestCase {
    
    var database: Database!
    
    // 每个测试前执行
    override func setUp() {
        super.setUp()
        database = Database()
        database.connect()
    }
    
    // 每个测试后执行
    override func tearDown() {
        database.disconnect()
        database = nil
        super.tearDown()
    }
    
    func testInsert() {
        database.insert(record: "test")
        XCTAssertEqual(database.count, 1)
    }
    
    func testDelete() {
        database.insert(record: "test")
        database.delete(record: "test")
        XCTAssertEqual(database.count, 0)
    }
}
```

**执行顺序**：

```
setUp() → testInsert() → tearDown()
setUp() → testDelete() → tearDown()
```

每个测试前后都执行 setUp/tearDown，保证测试隔离。

### 异步测试（async test）

Swift 6.0 的 XCTest 支持 async 测试方法：

```swift
final class AsyncTests: XCTestCase {
    
    // async 测试方法
    func testAsyncOperation() async throws {
        let result = await performAsyncWork()
        XCTAssertEqual(result, "completed")
    }
    
    // async + throwing 测试方法
    func testAsyncThrowing() async throws {
        let value = try await fetchFromNetwork()
        XCTAssertGreaterThan(value, 0)
    }
}
```

**关键要点**：

- 测试方法标记 `async`（可选加 `throws`）
- 可以用 `await` 调用 async 函数
- 不需要手动等待，测试框架自动处理

### 性能测试（measure）

测量代码执行时间：

```swift
func testPerformance() {
    measure {
        // 被测量的代码
        let _ = calculateSum()
    }
}

func calculateSum() -> Int {
    var sum = 0
    for i in 0..<10000 {
        sum += i
    }
    return sum
}
```

输出类似：

```
Test Case 'AsyncTests.testPerformance' measured [Time, seconds] average: 0.002
```

measure 会多次运行代码块，计算平均时间。

### @testable import

测试文件需要导入被测试模块：

```swift
@testable import AdvanceSample  // 可以访问 internal 成员
```

`@testable` 让测试可以访问 `internal` 访问级别的成员，而不是只有 `public`。

## 常见错误

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| `Test method not found` | 方法名不以 test 开头 | 重命名为 `test...` |
| `Module not found` | 未导入被测试模块 | 添加 `@testable import` |
| `Async test hangs` | await 死锁或超时 | 加 XCTWaiter 或 timeout |
| `setUp crash` | 初始化失败 | 检查 setUp 中的依赖 |
| `Assertion failed` | 测试条件不满足 | 检查预期值与实际值 |

### 错误示例 1：方法命名错误

```swift
// ❌ 错误 - 方法名不以 test 开头
func checkString() {
    XCTAssertEqual("a", "a")
}

// ✅ 正确
func testStringCheck() {
    XCTAssertEqual("a", "a")
}
```

### 错误示例 2：未导入模块

```swift
// ❌ 错误 - 编译器找不到 AdvanceSample
final class MyTests: XCTestCase {
    func testFunction() {
        let result = advanceSample()  // Error: use of unresolved identifier
    }
}

// ✅ 正确
@testable import AdvanceSample

final class MyTests: XCTestCase {
    func testFunction() {
        let result = advanceSample()  // OK
    }
}
```

### 错误示例 3：异步死锁

```swift
// ❌ 错误 - 异步任务卡住
func testAsyncBad() async {
    let future = someOperation()
    // 如果 future 永不完成，测试卡住
    let result = await future.value
}

// ✅ 正确 - 加超时检查
func testAsyncGood() async throws {
    let future = someOperation()
    
    // 使用 Task.sleep 模拟超时检测
    try await withTimeout(seconds: 5) {
        let result = await future.value
        XCTAssertEqual(result, expected)
    }
}
```

## Swift vs Rust/Python 对比

| 概念 | Swift (XCTest) | Rust (cargo test) | Python (pytest) |
|------|----------------|-------------------|-----------------|
| 测试框架 | XCTest | Built-in + #[test] | pytest (第三方) |
| 测试类 | XCTestCase | 自由函数 | 自由函数或类 |
| 断言 | XCTAssertEqual 等 | assert_eq! 等 | assert 等 |
| 异步测试 | async func | tokio::test | asyncio |
| 性能测试 | measure {} | criterion (第三方) | pytest-benchmark |
| 运行命令 | swift test | cargo test | pytest |
| 过滤测试 | --filter Name | --test name | -k name |

**关键差异**：

- Swift XCTest 是 Apple 官方框架，macOS/Linux 通用
- Rust 测试内置在 cargo，无需额外依赖
- Python pytest 是第三方，功能更丰富（fixtures、parametrize）

## 动手练习 Level 1

**任务**：为以下函数写测试。

```swift
func add(a: Int, b: Int) -> Int {
    return a + b
}

func isEven(number: Int) -> Bool {
    return number % 2 == 0
}
```

要求：
1. 创建 `MathTests: XCTestCase` 类
2. 写 `testAdd()` 验证 1+1=2
3. 写 `testIsEven()` 验证偶数判断

<details>
<summary>点击查看参考答案</summary>

```swift
import XCTest
@testable import AdvanceSample

final class MathTests: XCTestCase {
    
    func testAdd() {
        XCTAssertEqual(add(1, 1), 2)
        XCTAssertEqual(add(-1, 1), 0)
        XCTAssertEqual(add(0, 0), 0)
    }
    
    func testIsEven() {
        XCTAssertTrue(isEven(2))
        XCTAssertTrue(isEven(0))
        XCTAssertFalse(isEven(1))
        XCTAssertFalse(isEven(-3))
    }
}
```

</details>

## 动手练习 Level 2

**任务**：写一个异步测试，验证 async 函数返回值。

```swift
func fetchUserID() async -> Int {
    await Task.sleep(nanoseconds: 100_000_000)  // 100ms
    return 42
}
```

要求：
1. 测试方法标记 `async`
2. await 调用 fetchUserID()
3. 验证返回值是 42

<details>
<summary>点击查看参考答案</summary>

```swift
func testFetchUserID() async {
    let userId = await fetchUserID()
    XCTAssertEqual(userId, 42)
}
```

</details>

## 动手练习 Level 3

**任务**：写一个性能测试，测量字符串拼接时间。

要求：
1. 使用 measure {}
2. 拼接 1000 个字符串
3. 检查输出中的平均时间

<details>
<summary>点击查看参考答案</summary>

```swift
func testStringConcatenationPerformance() {
    measure {
        var result = ""
        for i in 0..<1000 {
            result += "item\(i)"
        }
    }
}
```

</details>

## 故障排查 FAQ

**Q: swift test 报错 "No such module 'AdvanceSample'"**

A: 检查 Package.swift 的 testTarget 配置：

```swift
.testTarget(
    name: "AdvanceSampleTests",
    dependencies: ["AdvanceSample"]  // 必须声明依赖
),
```

---

**Q: 测试方法不被识别**

A: 确认三点：
1. 类继承 XCTestCase
2. 方法名以 `test` 开头
3. 方法无参数、无返回值

---

**Q: 异步测试超时卡住**

A: XCTest 异步测试默认无超时。用 XCTWaiter 或手动检测：

```swift
func testWithTimeout() async throws {
    let waiter = XCTWaiter(delegate: self)
    let expectation = XCTestExpectation(description: "Async complete")
    
    Task {
        await someAsyncWork()
        expectation.fulfill()
    }
    
    waiter.wait(for: [expectation], timeout: 5.0)
}
```

---

**Q: setUp 中创建的资源在测试后未清理**

A: 确保 tearDown 正确实现。如果 setUp 抛出异常，tearDown 仍会执行：

```swift
override func setUpWithError() throws {
    // throwing setUp
}

override func tearDownWithError() throws {
    // throwing tearDown（即使 setUp 失败也会执行）
}
```

---

**Q: 如何只运行部分测试？**

A: 用 `--filter` 参数：

```bash
swift test --filter MathTests  # 只运行 MathTests 类
swift test --filter testAdd    # 只运行 testAdd 方法
```

## 小结

本章你学会了 XCTest 的核心用法：

- **XCTestCase**：测试类结构、命名约定
- **断言方法**：Equal/True/Nil/ThrowsError 等断言
- **setUp/tearDown**：测试生命周期管理
- **async 测试**：async func + await 的测试方式
- **性能测试**：measure {} 测量执行时间
- **运行测试**：swift test、--filter 过滤

测试是现代软件开发的必备技能。XCTest 虽然功能相对简单，但它内置在 Swift 工具链，无需额外安装，适合快速建立测试习惯。

## 术语表

| 中文 | 英文 | 说明 |
|------|------|------|
| 测试类 | XCTestCase | 包含多个测试方法的类 |
| 测试方法 | Test method | 以 test 开头的函数 |
| 断言 | Assertion | 检查预期结果的语句 |
| 生命周期 | Lifecycle | setUp → test → tearDown 的执行顺序 |
| 异步测试 | Async test | 标记 async 的测试方法 |
| 性能测试 | Performance test | measure {} 测量执行时间 |
| 测试隔离 | Test isolation | 每个测试独立运行，不影响其他 |
| 测试过滤 | Test filter | --filter 只运行部分测试 |

## 知识检查

1. XCTestCase 的 setUp 和 tearDown 在什么时候执行？

2. XCTAssertEqual 和 XCTAssertTrue 有什么区别？

3. 为什么测试方法名必须以 test 开头？

<details>
<summary>点击查看答案与解析</summary>

1. **setUp 在每个测试方法前执行，tearDown 在每个测试方法后执行**：
   - 执行顺序：setUp → testMethod1 → tearDown → setUp → testMethod2 → tearDown
   - 每个测试前后都会调用，保证测试隔离
   - setUp 用于初始化共享资源，tearDown 用于清理

2. **XCTAssertEqual 比较两个值相等，XCTAssertTrue 检查条件为真**：
   - XCTAssertEqual(1+1, 2) 检查 1+1 是否等于 2（精确值比较）
   - XCTAssertTrue(5>3) 检查 5>3 是否为真（布尔条件）
   - XCTAssertEqual 适用于比较具体值，XCTAssertTrue 适用于逻辑条件

3. **XCTest 通过方法名前缀识别测试方法**：
   - XCTest 运行时扫描所有 XCTestCase 子类
   - 找到以 `test` 开头的方法，自动执行
   - 非 test 开头的方法被忽略，不作为测试运行
   - 这是 XCTest 的约定，便于框架自动发现测试

</details>

## 继续学习

**下一章**: [阶段复习：高级部分](./review-advance.md) - 综合测试高级部分知识

**返回**: [高级进阶概览](./advance-overview.md)