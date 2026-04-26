# 环境配置

## 开篇故事

想象你进入一栋大楼，每一扇门背后有不同的区域。前台给你一叠门禁卡——每张卡上的编号决定了你能打开哪扇门。编号 "admin" 能打开所有门，编号 "guest" 只能进大厅。

环境变量 (environment variables) 就是这样的门禁卡。你的程序运行时，操作系统传递给它一组键值对，程序读到不同的值就能做出不同的行为。连接数据库的密码、调用第三方 API 的密钥、甚至程序应该用中文还是英文显示——全都可以通过环境变量控制。

在 Swift 中，最基础的读取方式是通过 `ProcessInfo`，但它的功能有限。如果要从 `.env` 文件批量加载配置，你需要 `swift-dotenv` 这样的第三方库。

`AdvanceSample/Sources/AdvanceSample/DotenvySample.swift` 中有完整的示例代码。让我们从最简单的开始。

---

## 本章适合谁

如果你写过以下任何一种代码，环境配置对你来说不是可选知识，而是必学技能：

- 在代码里硬编码了 API 密钥或数据库密码
- 开发时需要切换 "开发环境" 和 "生产环境"
- 多人协作时因为每个人的本地配置不同导致运行结果不一致

本章适合有一定 Swift 基础的学习者。你需要理解可选类型 (optional) 和基本的文件读写概念。

---

## 你会学到什么

完成本章后，你可以：

1. 使用 `ProcessInfo.processInfo` 读取操作系统级别的环境变量
2. 使用 `swift-dotenv` 加载 `.env` 文件中的配置
3. 理解动态成员查找 (dynamic member lookup) 的语法糖 `@dynamicMemberLookup`
4. 明白为什么绝不应该把密钥写死在源代码里
5. 排查常见的环境变量读取错误

---

## 前置要求

- 掌握 Swift 基础语法，尤其是可选类型 (optional) 和 `if let` 安全解包
- 理解 `.env` 文件的基本格式：每行一条 `KEY=VALUE`
- 了解如何在命令行中设置环境变量（如 `export MY_VAR=hello`）
- 已阅读 [JSON 处理](./json.md) 和 [文件操作](./file-operations.md) 章节

---

## 第一个例子

打开 `AdvanceSample/Sources/AdvanceSample/DotenvySample.swift`，先看通过 `ProcessInfo` 读取环境变量的代码：

```swift
import Foundation

public func processInfoEnvSample() {
    startSample(functionName: "DotenvySample processInfoEnvSample")

    // 读取单个环境变量
    if let path = ProcessInfo.processInfo.environment["PATH"] {
        print("系统 PATH 变量: \(path)")
    } else {
        print("未找到该环境变量")
    }

    // 遍历所有环境变量
    let allEnv = ProcessInfo.processInfo.environment
    for (key, value) in allEnv {
        print("\(key): \(value)")
    }

    endSample(functionName: "DotenvySample processInfoEnvSample")
}
```

**发生了什么？**

- `ProcessInfo.processInfo` 是 Swift 标准库提供的单例，封装了当前进程的信息
- `.environment` 返回一个 `[String: String]` 字典，包含所有环境变量
- 返回的是可选值，因为变量可能不存在

**关键区别**：`ProcessInfo` 只能读取程序启动时已有的环境变量。它不会自动加载 `.env` 文件。要让 `.env` 生效，需要借助第三方库。

---

## 原理解析

### 1. ProcessInfo vs Dotenv.configure()

`ProcessInfo.processInfo.environment` 读取的是操作系统传入的环境变量。这些变量在进程启动时就已经确定，程序中无法修改它们。

`Dotenv.configure()` 则完全不同。它会：

1. 在当前工作目录查找 `.env` 文件
2. 解析文件中的每一行（忽略注释和空行）
3. 将解析出的键值对写入进程内存（通过 `setenv` 底层调用）

```swift
import SwiftDotenv

try Dotenv.configure()  // 加载 .env 文件
print(Dotenv.apiKey)    // 使用动态成员查找读取 API_KEY
```

### 2. 动态成员查找 (Dynamic Member Lookup)

`Dotenv.apiKey` 看起来像是在访问一个普通属性，实际上并不是。这是 `@dynamicMemberLookup` 特性带来的语法糖。

在没有语法糖的情况下，等价的写法是：

```swift
let key = Dotenv["API_KEY"]  // 下标访问
print(key?.stringValue)
```

加上 `@dynamicMemberLookup` 后，编译器自动把 `.apiKey` 转换为 `["API_KEY"]`（自动转大写加下划线），让代码更简洁。

### 3. 安全考量

**永远不要** 把 API 密钥、数据库密码等敏感信息写死在源代码里。原因很简单：

- 源代码会被提交到版本管理系统（如 Git），一旦推送就可能泄露
- 多个开发者共用同一份代码，但各自的本地配置应该不同

正确的做法：把配置写在 `.env` 文件中，然后把这个文件加入 `.gitignore`。每个人维护自己本地的 `.env`，不会冲突也不会泄露。

---

## 常见错误

### 错误一：.env 文件不存在

```
can't load .env config
```

这是最常见的报错。`Dotenv.configure()` 找不到 `.env` 文件时会抛出错误。

**原因**：`.env` 文件不在当前工作目录下。`Dotenv.configure()` 从进程的工作目录开始搜索，而不是从你的源代码目录。

**解决方法**：在命令行运行 `swift run` 时确认 `.env` 在项目根目录。如果是 Xcode 运行，检查 Scheme 设置中的 "Working Directory"。

### 错误二：格式错误，值用了引号

```
# 错误写法
API_KEY="my-secret-key"

# 正确写法
API_KEY=my-secret-key
```

`swift-dotenv` 默认不会去掉引号。如果你写了 `API_KEY="hello"`，读出来的值是 `"hello"`（带引号），而不是 `hello`。

### 错误三：动态成员查找返回 nil

```swift
print(Dotenv.apiKey)  // nil
```

`Dotenv.apiKey` 返回 `nil` 的可能原因：

1. `.env` 文件没有加载成功（检查 `Dotenv.configure()` 是否抛出错误）
2. `.env` 中的键名不是 `API_KEY`（`.apiKey` 会自动转为 `API_KEY`，如果实际键名不同就找不到）
3. 值类型为 `.null` 而非字符串

### 错误四：环境变量冲突

如果系统环境变量和 `.env` 文件中有同名键，系统环境变量的优先级更高。`Dotenv.configure()` 不会覆盖已有的值。

---

## Swift vs Rust/Python 对比

| 特性 | Swift (swift-dotenv) | Rust (dotenvy) | Python (python-dotenv) |
|------|---------------------|----------------|------------------------|
| 安装方式 | SPM 依赖 | `Cargo.toml` 依赖 | `pip install python-dotenv` |
| 加载函数 | `Dotenv.configure()` | `dotenvy::dotenv()` | `load_dotenv()` |
| 读取方式 | `Dotenv.apiKey` / `Dotenv["API_KEY"]` | `dotenvy::get("API_KEY")` | `os.environ.get("API_KEY")` |
| 类型系统 | 强类型，需要 `.stringValue` 转换 | 强类型，返回 `Result` | 弱类型，返回字符串或 None |
| 动态成员查找 | 支持（`@dynamicMemberLookup`） | 不支持 | 不支持 |
| 是否覆盖已有变量 | 否 | 否 | 可选（`override=True`） |

**Swift 的独特优势**：`@dynamicMemberLookup` 让你用属性访问语法读取环境变量，代码更优雅。这是 Swift 语言特性带来的便利，Rust 和 Python 都没有。

---

## 动手练习 Level 1

使用 `ProcessInfo` 读取系统环境变量 `HOME`（你的主目录路径），打印出来。

<details>
<summary>点击查看答案</summary>

```swift
import Foundation

if let home = ProcessInfo.processInfo.environment["HOME"] {
    print("主目录: \(home)")
} else {
    print("未找到 HOME 环境变量")
}
```
</details>

---

## 动手练习 Level 2

在项目根目录创建 `.env` 文件，写入以下内容：

```
DATABASE_URL=postgres://localhost:5432/mydb
DEBUG_MODE=true
```

使用 `Dotenv.configure()` 加载后读取 `DATABASE_URL`。

<details>
<summary>点击查看答案</summary>

```swift
import SwiftDotenv

do {
    try Dotenv.configure()
    if let dbUrl = Dotenv["DATABASE_URL"]?.stringValue {
        print("数据库连接: \(dbUrl)")
    }
} catch {
    print("加载 .env 失败: \(error)")
}
```
</details>

---

## 动手练习 Level 3

使用动态成员查找语法读取 `DEBUG_MODE` 环境变量。提示：`.debugMode` 会自动映射为 `DEBUG_MODE`。

<details>
<summary>点击查看答案</summary>

```swift
import SwiftDotenv

try Dotenv.configure()

// 使用动态成员查找（驼峰命名会自动转为大写加下划线）
let debugMode = Dotenv.debugMode?.stringValue
print("调试模式: \(debugMode ?? "未设置")")

// 等价于
// let debugMode = Dotenv["DEBUG_MODE"]?.stringValue
```
</details>

---

## 故障排查 FAQ

**Q1. 为什么 `Dotenv.configure()` 报错了？**

检查三点：`.env` 文件是否存在、文件路径是否正确、文件内容格式是否正确（每行 `KEY=VALUE`，不要用引号包裹值）。

**Q2. `ProcessInfo.processInfo.environment["MY_VAR"]` 返回 nil，但我明明设过了。**

确认你在哪个终端设置了变量。`export MY_VAR=hello` 只对当前终端会话有效。如果你另开了一个终端窗口或者直接用 Xcode 运行，Xcode 看不到那个变量。

**Q3. .env 文件应该加入版本控制吗？**

不应该。在 `.gitignore` 中添加 `.env`。如果需要团队协作，可以提交一个 `.env.example` 作为模板，里面只写变量名不写真实值。

**Q4. Swift 程序运行时可以修改环境变量吗？**

可以改，用 `setenv()`，但 **不推荐**。环境变量应该在整个程序生命周期内保持不变。如果需要在运行时切换配置，考虑使用一个自定义的配置类，而不是修改环境变量。

**Q5. `Dotenv.apiKey` 和 `Dotenv["API_KEY"]` 有什么区别？**

功能上没有任何区别。`.apiKey` 是语法糖，编译器内部会自动转为 `["API_KEY"]` 下标访问。命名规则是：驼峰转大写+下划线，`mySecretValue` → `MY_SECRET_VALUE`。

**Q6. 如何在 Xcode 中设置环境变量？**

编辑 Scheme → Run → Arguments → Environment Variables，在那里添加键值对。这种方式设置的环境变量只在通过 Xcode 运行时生效。

---

## 小结

- `ProcessInfo.processInfo.environment` 是标准库提供的环境变量读取方式，返回 `[String: String]` 字典
- `swift-dotenv` 可以从 `.env` 文件加载配置到进程内存，适合管理多组环境变量
- `@dynamicMemberLookup` 允许用属性访问语法读取环境变量，让代码更简洁
- 敏感信息（API 密钥、数据库密码）绝不应该写死在源代码中
- `.env` 文件应加入 `.gitignore`，避免泄露到版本控制系统

---

## 术语表

| 术语 | 说明 |
|------|------|
| `ProcessInfo` | Swift 标准库类，封装当前进程信息，包括环境变量、参数、主机名等 |
| `Dotenv` | 第三方库 swift-dotenv 提供的核心类型，用于加载和访问 `.env` 文件中的配置 |
| 动态成员查找 (Dynamic Member Lookup) | Swift 语言特性 (`@dynamicMemberLookup`)，允许在运行时动态解析属性名 |
| `@dynamicMemberLookup` | 属性标记，告诉编译器把属性访问转换为下标调用，如 `.apiKey` → `["API_KEY"]` |
| `.env` 文件 | 纯文本配置文件，每行一条键值对，格式为 `KEY=VALUE`，广泛用于环境变量管理 |

---

## 知识检查

**问题 1**: `ProcessInfo.processInfo.environment` 返回什么类型？

<details>
<summary>查看答案</summary>

`[String: String]` 字典（即 `ProcessInfo.Environment`，底层等价于 `[String: String]`）。
</details>

**问题 2**: `Dotenv.debugMode` 实际对应 `.env` 文件中的哪个键名？

<details>
<summary>查看答案</summary>

`DEBUG_MODE`。`@dynamicMemberLookup` 自动将驼峰命名转为大写加下划线格式。
</details>

**问题 3**: 为什么说把 API 密钥写死在代码里是危险的做法？

<details>
<summary>查看答案</summary>

因为源代码会被提交到版本管理系统（如 Git）。一旦推送到远程仓库（尤其是公开的 GitHub），任何人都能看到这些密钥，可能导致未授权访问和数据泄露。正确做法是放入 `.env` 文件并加入 `.gitignore`。
</details>

---

## 继续学习

完成了环境配置的学习，你已经掌握了 Swift 项目中管理敏感信息的正确方式。接下来可以：

- 阅读 [高级阶段复习](./review-advance.md) 巩固高级部分知识
- 回到 [高级进阶概览](./advance-overview.md) 查看还未完成的章节
