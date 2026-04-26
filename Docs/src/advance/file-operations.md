# 文件操作

## 开篇故事

想象你在一座大型图书馆里工作。图书馆有不同的区域，每种区域存放不同类型的书籍。有的区域存放珍本古籍，需要恒温恒湿。有的区域存放普通阅览书籍。还有的区域专门放读者暂借的书籍，还完就清空。

文件系统在计算机里的角色就像这座图书馆。操作系统帮你管理不同的目录，每个目录有不同的用途。有的目录备份到云，有的目录磁盘满了会清空，还有的目录应用卸载时就一起消失。

Swift 提供了 `FileManager`（文件管理器）来帮你和这座图书馆打交道。

---

## 本章适合谁

如果你需要保存数据到磁盘，或者从磁盘读取数据，就需要文件操作。具体场景包括：

- 缓存网络请求的图片或 JSON 数据
- 保存用户设置和偏好
- 写入日志文件供后续分析
- 处理大文件时逐行读取，避免内存爆炸

本章适合所有需要持久化数据的 Swift 开发者。无论你是写 macOS 命令行工具还是 iOS 应用，文件操作都是基础能力。

---

## 你会学到什么

完成本章后，你可以：

1. 使用 `FileManager` 获取 Documents、Caches、Temp、ApplicationSupport 等系统路径
2. 理解 `TemporaryFile` 类的 RAII 自动清理模式
3. 使用 `AsyncLineSequence` 异步逐行读取大文件
4. 识别路径不存在、权限不足、跨平台差异等常见错误
5. 将 Swift 的文件操作与 Rust、Python 做对比

---

## 前置要求

你需要先掌握：

- Swift 基础语法（变量、函数、枚举）
- `do/catch/try` 错误处理模式
- `async/await` 基础概念

如果还不会，请先学习 [基础数据类型](../basic/datatype.md)、[错误处理](../basic/error-handling.md) 和 [并发编程](../basic/concurrency.md)。

> **平台要求**：`AsyncLineSequence`（异步流式读取）需要 macOS 12.0+。其余 API 在所有版本的 macOS 和 iOS 上都可用。

---

## 第一个例子

打开 `AdvanceSample/Sources/AdvanceSample/FileOperationSample.swift`。我们从一个完整的文件管理器路径示例开始。

```swift
import Foundation

public func fileManagerPathSample() {
    let fileManager = FileManager.default

    // 1. 获取 Document 目录（用户文档，iCloud 会备份）
    if let documentsURL = fileManager.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first {
        print("Document 目录: \(documentsURL.path)")
    }

    // 2. 获取Library/Caches 目录（临时缓存，空间不足时可能清理）
    if let cacheURL = fileManager.urls(
        for: .cachesDirectory,
        in: .userDomainMask
    ).first {
        print("Cache 目录: \(cacheURL.path)")
    }

    // 3. 获取Library/Application Support 目录（存放配置、数据库）
    if let appSupportURL = fileManager.urls(
        for: .applicationSupportDirectory,
        in: .userDomainMask
    ).first {
        print("Application Support 目录: \(appSupportURL.path)")
    }

    // 4. 获取 Temporary 目录（完全临时，应用退出后可能消失）
    let tempPath = NSTemporaryDirectory()
    print("Temp 目录: \(tempPath)")
}
```

**发生了什么？**

- `FileManager.default` 获取共享的文件管理器实例
- `urls(for:in:)` 返回一个 URL 数组，`first` 取第一个路径
- 不同目录用途各异，选择合适的目录能让系统更好管理存储空间

**输出**（路径因机器而异）：
```
Document 目录: /Users/username/Library/Containers/.../Data/Documents
Cache 目录: /Users/username/Library/Containers/.../Library/Caches
Application Support 目录: /Users/username/Library/Containers/.../Data/Application Support
Temp 目录: /private/var/folders/.../T/
```

---

## 原理解析

### 1. 四大系统目录

macOS/iOS 的文件系统有四个核心目录，每个用途不同：

| 目录 | 英文 | 用途 | 备份 | 清理时机 |
|------|------|------|------|---------|
| Documents | `.documentDirectory` | 用户可见的重要文件 | iCloud 备份 | 用户/App 卸载 |
| Caches | `.cachesDirectory` | 缓存数据，可重新下载的网络请求结果 | 不备份 | 磁盘空间不足时 |
| Temporary | `NSTemporaryDirectory()` | 完全临时文件，用完即删 | 不备份 | 应用退出后 |
| Application Support | `.applicationSupportDirectory` | 数据库、配置文件 | iCloud 备份 | App 卸载 |

选择原则：用户生成文件放 Documents，缓存放 Caches，数据库放 Application Support。

### 2. TemporaryFile 与 RAII 自动清理

```swift
public class TemporaryFile {
    public let url: URL

    public init(content: String) throws {
        self.url = FileManager.default.temporaryDirectory
            .appendingPathComponent("temp-\(UUID().uuidString).txt")
        try content.data(using: .utf8)?.write(to: self.url)
    }

    deinit {
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
```

`deinit` 是 Swift 的析构函数。当对象不再被引用、内存被回收时，`deinit` 自动执行。这种模式在 Rust 里叫 RAII（Resource Acquisition Is Initialization），确保临时文件不会泄露。

**类比**：就像图书馆的"暂借书架"。读者还书后，工作人员自动把书放回原处。你不需要手动记得放回去。

### 3. AsyncLineSequence 流式读取

```swift
public func readLines() async throws -> AsyncLineSequence<URL.AsyncBytes> {
    return url.lines
}

// 使用
for try await line in try await temp.readLines() {
    print("读取到: \(line)")
}
```

`url.lines` 创建一个异步序列，逐行加载文件。每次只读一行到内存，适合处理 GB 级别的日志文件。

---

## 常见错误

### 错误 1: 路径不存在

```swift
let url = URL(fileURLWithPath: "/nonexistent/data.txt")
let content = try String(contentsOf: url) // ❌ 运行时异常
```

**修复方法**：先检查文件是否存在：

```swift
guard FileManager.default.fileExists(atPath: url.path) else {
    print("文件不存在，跳过读取")
    return
}
```

### 错误 2: 权限不足

尝试写入 Bundle 内部目录。Bundle 是只读的（只读文件系统），应用只能写 Documents、Caches、Temporary 等沙盒目录：

```swift
// ❌ 错误示例：写入 Bundle 资源目录
let bundlePath = Bundle.main.resourcePath
```

**修复方法**：始终写入沙盒目录（Documents、Caches 等）。iOS 的沙盒机制（sandbox）禁止写入应用包内部。

### 错误 3: Linux 平台差异

`FileManager` 的 `.documentDirectory`、`.cachesDirectory` 和 `.applicationSupportDirectory` 在 Linux 上不可用。Linux 没有 macOS 的 Documents/Caches 目录结构：

```swift
// 这段代码在 Linux 上返回空数组：
let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
// docs 是 [] —— 没有匹配结果
```

**解决方法**：在 Linux 上使用标准的 POSIX 路径，可以用环境变量或 `NSFileManager.default.homeDirectoryForCurrentUser`：

```swift
#if os(Linux)
let homeDir = fileManager.homeDirectoryForCurrentUser.path
#else
let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
#endif
```

> **跨平台提示**：如果你的代码需要同时跑在 macOS 和 Linux 上，用 `#if os()` 条件编译来区分。

---

## Swift vs Rust/Python 对比

| 概念 | Python | Rust | Swift | 关键差异 |
|------|--------|------|-------|----------|
| 文件系统接口 | `os.path` / `pathlib` | `std::fs` | `FileManager` | Python 路径是字符串，Swift 用 URL |
| 获取 Home 目录 | `os.path.expanduser("~")` | `home_dir()` | `homeDirectoryForCurrentUser` | 各有封装 |
| 创建临时文件 | `tempfile.NamedTemporaryFile()` | 无标准库方案 | `NSTemporaryDirectory()` + UUID | Python 最方便 |
| 读取文件内容 | `pathlib.Path.read_text()` | `std::fs::read_to_string()` | `String(contentsOf:encoding:)` | Rust 需手动打开 |
| 文件不存在处理 | 抛 `FileNotFoundError` | `Result<T, io::Error>` | `throws` + `do/catch` | Rust 需要手动解 Result |
| 自动清理资源 | `with` 语句（上下文管理器） | Drop trait（RAII） | deinit（引用计数） | Rust 编译期保证，Swift 运行期 |
| 逐行读取大文件 | `for line in f:` | `BufReader::lines()` | `url.lines` async | Swift 需要 macOS 12+ |

**一句话总结**：Python 最简洁，Rust 最安全（编译期保证），Swift 在两者之间平衡。

---

## 动手练习

### 练习 1: 获取 Documents 目录路径

写一个函数 `getDocumentsPath()`，返回 `String?`。使用 `FileManager` 获取 Documents 目录路径。如果获取失败，返回 `nil`。

<details>
<summary>点击查看答案</summary>

```swift
func getDocumentsPath() -> String? {
    let fileManager = FileManager.default
    if let url = fileManager.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first {
        return url.path
    }
    return nil
}

// 测试
if let path = getDocumentsPath() {
    print("Documents 路径: \(path)")
}
```

</details>

### 练习 2: 创建并读取临时文件

使用 `TemporaryFile` 类创建一个临时文件，写入 "Hello Swift File!"，然后读取并打印内容。观察程序退出时是否自动清理。

<details>
<summary>点击查看答案</summary>

```swift
do {
    let tempFile = try TemporaryFile(content: "Hello Swift File!")
    // 读取内容
    let content = try tempFile.readContent()
    print("文件内容: \(content)")
}
// out of scope → tempFile 引用计数归零 → deinit → 文件删除
```

</details>

### 练习 3: 异步逐行读取大文件

使用 `AsyncLineSequence` 逐行读取临时文件内容。创建一个有 3 行内容的临时文件，用 async for-in 循环逐行打印。提示：参考 `temporaryFileSample()` 函数的第三部分。

<details>
<summary>点击查看答案（隐藏代码）</summary>

```swift
func streamFileSample() async throws {
    let temp = try TemporaryFile(content:
        "第一行\n第二行\n第三行"
    )
    for try await line in try await temp.readLines() {
        print("行: \(line)")
    }
    // 退出作用域后临时文件自动删除
}
```

</details>

---

## 故障排查 FAQ

### Q1: 为什么 `urls(for: .documentDirectory, in: .userDomainMask)` 返回空数组？

**A**: 在某些命令行工具或沙盒受限环境中，Documents 目录可能不存在。确保你的应用有正确的沙盒权限，或者尝试使用 `.applicationSupportDirectory`。

### Q2: 临时文件没有被自动删除怎么办？

**A**: `deinit` 只在对象的引用计数归零时触发。如果你用 `var ref = TemporaryFile(...)` 保存了引用，确保让引用离开作用域或设置为 `nil`：

```swift
var ref: TemporaryFile? = try TemporaryFile(content: "test")
ref = nil // 释放引用 → 触发 deinit → 删除文件
```

### Q3: Linux 上运行报"Document directory not available"怎么办？

**A**: Linux 没有 macOS 的沙盒目录结构。使用 `#if os(Linux)` 条件编译，在 Linux 上改用标准的 `/tmp/` 或 `$HOME` 路径。

### Q4: 读取文件时报 "The file doesn't exist"。怎么办？

**A**: 检查三件事：路径是否正确拼写、文件是否真的存在（用 `fileManager.fileExists(atPath:)` 验证）、当前进程是否有读取权限。

### Q5: 为什么写入文件时得到 "You don't have permission"？

**A**: 你尝试写入没有权限的目录（比如 `/Applications`或应用 Bundle）。Swift 应用只能写入沙盒内的 Documents、Caches、Temporary等目录。

---

## 小结

**核心要点**：

1. **FileManager 有四大核心目录** — Documents 存用户文件，Caches 存缓存，Temporary 存临时文件，Application Support 存配置和数据库
2. **临时文件用 RAII 自动清理** — 利用 `deinit` 确保不泄露，无需手动删除
3. **大文件用 AsyncLineSequence 逐行读取** — 需要 macOS 12+，避免内存占满
4. **权限和路径是两类常见错误** — 先检查文件存在再读写，只写沙盒目录
5. **Linux 平台差异要注意** — 没有 Documents/Caches，用条件编译或 POSIX 路径

---

## 术语表

| English | 中文 | 说明 |
|---------|------|------|
| FileManager | 文件管理器 | macOS/iOS 提供的文件系统操作类 |
| URL (file URL) | 文件 URL | 以 `file://` 开头的统一资源定位符，比字符串路径更安全 |
| AsyncLineSequence | 异步行序列 | macOS 12+ 引入的逐行异步读取类型，适合大文件 |
| RAII | 资源获取即初始化 | 资源绑定到对象生命周期，对象释放时资源自动清理 |
| deinit | 析构函数 | 对象被销毁时自动调用的方法 |
| Temporary Directory | 临时目录 | 应用退出后可能清理的临时文件存储区 |
| Sandbox | 沙盒 | iOS/macOS 的安全隔离机制，限制应用可访问的文件范围 |
| UUID | 通用唯一识别码 | 用于生成唯一的临时文件名 |

---

## 知识检查

**问题 1** 🟢（基础概念）

以下哪个目录用于存放用户生成的文档且会被 iCloud 备份？

A) Caches  
B) Temporary  
C) Documents  
D) Application Support

<details>
<summary>答案与解析</summary>

**答案**: C) Documents

**解析**: `.documentDirectory`（Documents 目录）存放用户生成的重要文件，会被 iCloud 备份。Caches 不备份，Temporary 最不稳定，Application Support 存配置而非用户文档。

</details>

**问题 2** 🟡（最佳实践）

`TemporaryFile` 对象离开作用域后自动删除文件，依靠的是什么机制？

A) ARC 引用计数归零后触发 `deinit`  
B) 系统定时器定期扫描  
C) 编译器自动插入删除代码  
D) `deasync` 异步清理

<details>
<summary>答案与解析</summary>

**答案**: A) ARC 引用计数归零后触发 `deinit`

**解析**: Swift 使用自动引用计数（ARC）。当 `TemporaryFile` 的所有引用都消失时，ARC 将其内存回收，并调用 `deinit` 方法执行清理。

</details>

**问题 3** 🔴（跨平台）

以下代码在 Linux 上运行会有什么结果？

```swift
let docs = FileManager.default.urls(
    for: .documentDirectory, in: .userDomainMask
)
print(docs.count)
```

A) 打印 1  
B) 崩溃  
C) 打印 0  
D) 编译错误

<details>
<summary>答案与解析</summary>

**答案**: C) 打印 0

**解析**: Linux 没有 macOS 的 Documents 目录结构。`urls(for:in:)` 无匹配结果，返回空数组。Linux 上应该用标准的 POSIX 路径，例如 `homeDirectoryForCurrentUser`。

</details>

---

## 继续学习

- 下一步：[SwiftData 持久化](./swift-data.md) — 用 Model、ModelContainer 和 #Predicate 管理结构化数据
- 相关：[环境配置](./environment.md) — 使用 swift-dotenv 管理环境变量和配置文件
- 进阶：[并发编程](../basic/concurrency.md) — 后台线程中安全地读写文件

> 记住：文件操作的核心原则是"选对目录、处理错误、及时清理"。选对目录，系统会帮你管理空间。忽略错误，用户的文件就会丢。
