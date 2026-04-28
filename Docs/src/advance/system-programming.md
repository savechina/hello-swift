# 系统编程与进程管理

## 开篇故事

想象你是一家餐厅的经理。除了管理厨房，你还需要协调外卖平台、供应商、清洁服务。你不是亲自做菜，而是"调度"各种外部服务。

系统编程就是这种"经理角色"。你的 Swift 程序是核心业务，但你需要：

- 调用 git 命令获取代码版本
- 启动 npm 构建前端资源
- 执行 shell 脚本处理数据文件
- 监听 Ctrl+C 信号优雅关闭

本章教你的，就是如何在 Swift 里当好这个"经理"——执行外部命令、管理进程、处理信号，同时保证 macOS 和 Linux 双平台兼容。

## 本章适合谁

如果你满足以下任一情况，这一章就是为你准备的：

- 你需要构建 CLI 工具，调用外部命令（如 git、docker、npm）
- 你想让程序优雅关闭，响应 Ctrl+C (SIGINT)
- 你关心跨平台部署，想让代码跑在 macOS 和 Linux
- 你想知道 Process、Signal、POSIX 这些概念怎么用

## 你会学到什么

完成本章后，你将掌握以下内容：

- **Process 类**：Foundation 的进程执行 API，捕获 stdout/stderr
- **信号处理**：SIGINT/SIGTERM 捕获，优雅关闭模式
- **跨平台路径**：macOS Documents/Caches vs Linux /tmp/home
- **ProcessInfo**：系统信息、环境变量、平台检测
- **超时处理**：避免进程无限等待的实用模式

## 前置要求

在开始之前，请确保你已掌握以下内容：

- Swift 基础：do-catch 错误处理、可选类型
- 基础命令行知识：知道 ls、echo、pwd 等命令
- Foundation 基础：FileManager、Pipe 的基本概念

运行环境要求：

- macOS 12.0+ 或 Linux（Ubuntu 22.04+）
- Swift 6.0+
- 基础 shell 命令（ls、echo、pwd）

## 第一个例子

先看一个最基础的例子：执行 `/bin/ls` 命令，列出当前目录。

这段代码来自 `AdvanceSample/Sources/AdvanceSample/ProcessSample.swift`。

```swift
import Foundation

// 创建 Process 实例
let process = Process()
process.executableURL = URL(fileURLWithPath: "/bin/ls")
process.arguments = ["-la"]  // 参数列表

// 执行并等待完成
do {
    process.run()
    process.waitUntilExit()
    
    if process.terminationStatus == 0 {
        print("命令执行成功")
    } else {
        print("命令失败，状态码: \(process.terminationStatus)")
    }
} catch {
    print("执行错误: \(error)")
}
```

运行这段代码，输出类似：

```
命令执行成功
```

## 原理解析

### Process：进程执行的核心类

Foundation 的 `Process` 类封装了进程创建和管理的全过程：

**关键属性**：

- `executableURL`：可执行文件路径（URL 类型）
- `arguments`：命令参数数组 `[String]`
- `standardOutput`：stdout 输出管道（Pipe）
- `standardError`：stderr 输出管道（Pipe）
- `terminationStatus`：进程退出码（0 成功，非 0 失败）

**关键方法**：

- `run()`：启动进程（非阻塞）
- `waitUntilExit()`：等待进程完成（阻塞）
- `terminate()`：强制终止进程（SIGKILL）

### 捕获 stdout/stderr

默认情况下，子进程继承父进程的 stdout/stderr。要捕获输出，需要用 `Pipe`：

```swift
let process = Process()
process.executableURL = URL(fileURLWithPath: "/bin/echo")
process.arguments = ["Hello from Process"]

// 创建输出管道
let stdoutPipe = Pipe()
process.standardOutput = stdoutPipe

// 创建错误管道
let stderrPipe = Pipe()
process.standardError = stderrPipe

process.run()
process.waitUntilExit()

// 读取输出
let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
let stdout = String(data: stdoutData, encoding: .utf8) ?? ""

print("输出: \(stdout)")  // "输出: Hello from Process"
```

### 进程超时处理

有些命令可能卡住（如网络请求失败）。用超时机制保护：

```swift
func executeWithTimeout(command: String, args: [String], timeout: TimeInterval) -> Bool {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: command)
    process.arguments = args
    
    process.run()
    
    let startTime = Date()
    while process.isRunning && Date().timeIntervalSince(startTime) < timeout {
        Thread.sleep(forTimeInterval: 0.1)
    }
    
    if process.isRunning {
        print("超时，终止进程")
        process.terminate()
        return false
    }
    
    return process.terminationStatus == 0
}
```

### 跨平台路径差异

macOS 和 Linux 的目录结构不同：

| 目录类型 | macOS | Linux |
|---------|-------|-------|
| Documents | ~/Documents | 无（需手动创建） |
| Caches | ~/Library/Caches | /tmp 或 ~/.cache |
| Application Support | ~/Library/Application Support | ~/.config 或 ~/.local/share |
| Temporary | /tmp 或 NSTemporaryDirectory() | /tmp |
| Current | FileManager.currentDirectoryPath | 相同 |

**跨平台建议**：

- 用 `FileManager.currentDirectoryPath`（所有平台可用）
- 用 `FileManager.temporaryDirectory`（所有平台可用）
- 用 `ProcessInfo.processInfo.environment["HOME"]`（所有平台可用）
- 避免硬编码 `/Users/...` 或 `/home/...`

```swift
func getPlatformPath() -> String {
    let fileManager = FileManager.default
    
    #if os(macOS)
    // macOS 有标准沙箱路径
    if let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
        return documents.path
    }
    #elseif os(Linux)
    // Linux 用 HOME 或当前目录
    let home = ProcessInfo.processInfo.environment["HOME"] ?? "/tmp"
    return home
    #endif
    
    // 默认：当前目录
    return fileManager.currentDirectoryPath
}
```

### Signal 处理（概念）

Signal 是操作系统发送给进程的"通知"。常见信号：

| Signal | 编号 | 含义 | 可捕获 |
|--------|------|------|--------|
| SIGINT | 2 | Ctrl+C 中断 | ✅ |
| SIGTERM | 15 | 优雅终止请求 | ✅ |
| SIGHUP | 1 | 终端挂起 | ✅ |
| SIGKILL | 9 | 强制终止 | ❌ |

**Foundation 的 DispatchSourceSignal**：

```swift
import Dispatch

// 监听 SIGINT（Ctrl+C）
let sigintSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)

// 阻止默认行为（立即退出）
signal(SIGINT, SIG_IGN)

sigintSource.setEventHandler {
    print("收到 SIGINT，准备优雅关闭...")
    // 执行清理逻辑
    cleanupResources()
    exit(0)
}

sigintSource.resume()
```

## 常见错误

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| `executableURL not found` | 命令路径不存在 | 用 `/usr/bin/which` 查找实际路径 |
| `Process.run() failed` | 权限不足或命令无效 | 检查 executableURL 是否可执行 |
| `Pipe read blocks` | 未调用 waitUntilExit 或进程卡住 | 加超时机制 |
| `Cross-platform path missing` | Linux 无 Documents 目录 | 用 currentDirectoryPath 替代 |
| `Signal handler crash` | Handler 中执行复杂操作 | Handler 应只设置标志，主循环处理 |

### 错误示例 1：路径不存在

```swift
// ❌ 错误 - 可能不存在
process.executableURL = URL(fileURLWithPath: "git")

// ✅ 正确 - 使用绝对路径
process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
```

### 错误示例 2：阻塞读取

```swift
// ❌ 错误 - 进程可能卡住
process.run()
let data = pipe.fileHandleForReading.readDataToEndOfFile()  // 无限等待

// ✅ 正确 - 加超时
process.run()
let deadline = Date() + 5.0  // 5秒超时
while process.isRunning && Date() < deadline {
    Thread.sleep(forTimeInterval: 0.1)
}
if process.isRunning {
    process.terminate()
}
```

### 错误示例 3：Signal Handler 复杂操作

```swift
// ❌ 错误 - Handler 中执行耗时操作
sigintSource.setEventHandler {
    saveLargeFile()  // 可能耗时几秒
    exit(0)
}

// ✅ 正确 - Handler 只设置标志
var shouldExit = false
sigintSource.setEventHandler {
    shouldExit = true  // 只设置标志
}

// 主循环检查标志
while !shouldExit {
    // 正常工作...
}
cleanupResources()
exit(0)
```

## Swift vs Rust/Python 对比

| 概念 | Swift (Foundation) | Rust (std::process) | Python (subprocess) |
|------|--------------------|----------------------|----------------------|
| 进程执行 | Process | Command | subprocess.run |
| 输出捕获 | Pipe | Stdio::piped | capture_output=True |
| 参数传递 | arguments: [String] | .args([...]) | args=[...] |
| 状态码 | terminationStatus | .status.code() | .returncode |
| 超时控制 | 手动循环检查 | .timeout() | timeout=N |
| Signal | DispatchSourceSignal | ctrlc crate | signal.signal() |
| 跨平台路径 | FileManager + ProcessInfo | std::env | os.path |

**关键差异**：

- Swift 的 Process 超时需手动实现（循环检查 isRunning）
- Rust 的 Command 提供 `.timeout()` 方法（更优雅）
- Python 的 subprocess.run 有 `timeout=` 参数（最简洁）

## 动手练习 Level 1

**任务**：写一个函数执行 `/usr/bin/git --version`，捕获并打印输出。

要求：
1. 使用 Process 和 Pipe
2. 打印 stdout 内容
3. 打印 terminationStatus

<details>
<summary>点击查看参考答案</summary>

```swift
func getGitVersion() {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
    process.arguments = ["--version"]
    
    let stdoutPipe = Pipe()
    process.standardOutput = stdoutPipe
    
    do {
        process.run()
        process.waitUntilExit()
        
        let data = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        print("Git 版本: \(output.trimmingCharacters(in: .whitespacesAndNewlines))")
        print("状态码: \(process.terminationStatus)")
    } catch {
        print("错误: \(error)")
    }
}
```

</details>

## 动手练习 Level 2

**任务**：写一个跨平台的"获取用户目录"函数。

要求：
1. macOS 返回 Documents 目录
2. Linux 返回 HOME 目录
3. 使用 #if os() 编译条件

<details>
<summary>点击查看参考答案</summary>

```swift
func getUserDirectory() -> String {
    let fileManager = FileManager.default
    
    #if os(macOS)
    if let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
        return documents.path
    }
    #elseif os(Linux)
    if let home = ProcessInfo.processInfo.environment["HOME"] {
        return home
    }
    #endif
    
    // 默认回退
    return fileManager.currentDirectoryPath
}
```

</details>

## 动手练习 Level 3

**任务**：实现一个带超时的 Process 执行器。

要求：
1. 函数签名：`func execute(command: String, args: [String], timeout: TimeInterval) -> (stdout: String, success: Bool)`
2. 超时后自动 terminate()
3. 返回 stdout 内容和成功状态

<details>
<summary>点击查看参考答案</summary>

```swift
func execute(command: String, args: [String], timeout: TimeInterval) -> (stdout: String, success: Bool) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: command)
    process.arguments = args
    
    let stdoutPipe = Pipe()
    process.standardOutput = stdoutPipe
    
    process.run()
    
    let startTime = Date()
    while process.isRunning && Date().timeIntervalSince(startTime) < timeout {
        Thread.sleep(forTimeInterval: 0.1)
    }
    
    if process.isRunning {
        process.terminate()
        process.waitUntilExit()
        return ("", false)
    }
    
    let data = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
    let stdout = String(data: data, encoding: .utf8) ?? ""
    
    return (stdout, process.terminationStatus == 0)
}
```

</details>

## 故障排查 FAQ

**Q: Process.run() 报错 "The file doesn't exist"**

A: 命令路径错误。用终端 `which` 命令查找实际路径：

```bash
which git
# 输出: /usr/bin/git
```

Swift 中使用该路径。

---

**Q: Pipe readDataToEndOfFile 无限阻塞**

A: 进程没有退出或输出量很大。解决方案：

1. 确保 `waitUntilExit()` 被调用
2. 加超时机制（见 Level 3 练习）
3. 用 `readData(ofLength:)` 分批读取

---

**Q: Linux 上 Documents 目录不存在**

A: Linux 没有 macOS 的沙箱目录。使用替代：

```swift
#if os(Linux)
let home = ProcessInfo.processInfo.environment["HOME"] ?? "/tmp"
let documents = home + "/Documents"  // 手动创建
FileManager.default.createDirectory(atPath: documents, withIntermediateDirectories: true)
#endif
```

---

**Q: Signal Handler 不生效**

A: 检查两点：

1. 调用 `signal(SIGINT, SIG_IGN)` 阻止默认行为
2. Handler 在正确的队列上设置（通常 `.main`）

---

**Q: Process.terminate() 后进程仍在运行**

A: `terminate()` 发送 SIGTERM，进程可能忽略。用 `kill()` 强制终止：

```swift
if process.isRunning {
    process.terminate()
    Thread.sleep(forTimeInterval: 1.0)
    if process.isRunning {
        process.kill()  // SIGKILL，无法忽略
    }
}
```

## 小结

本章你学会了系统编程的核心技能：

- **Process 执行**：Foundation API、参数传递、状态检查
- **输出捕获**：Pipe、stdout/stderr 分离
- **超时控制**：循环检查 isRunning、自动 terminate
- **跨平台路径**：macOS vs Linux 的目录差异
- **Signal 处理**：SIGINT/SIGTERM 捕获、优雅关闭模式

系统编程是 CLI 工具的基础能力。掌握 Process 和 Signal，你就能构建生产级的命令行应用。

## 术语表

| 中文 | 英文 | 说明 |
|------|------|------|
| 进程 | Process | 运行中的程序实例 |
| 子进程 | Child process | 由父进程启动的进程 |
| 状态码 | Termination status | 进程退出返回的数值（0 成功） |
| 管道 | Pipe | 进程间通信的数据流 |
| Signal | Signal | 操作系统发送给进程的通知 |
| 捕获 | Catch | 接收并处理 Signal |
| 优雅关闭 | Graceful shutdown | 先清理资源再退出 |
| 沙箱 | Sandbox | macOS 的应用隔离目录 |

## 知识检查

1. Process 的 `waitUntilExit()` 和 `terminate()` 有什么区别？

2. 为什么 Linux 没有 Documents/Caches 目录？

3. Signal Handler 中应该避免什么操作？

<details>
<summary>点击查看答案与解析</summary>

1. **waitUntilExit() 是等待，terminate() 是终止**：
   - `waitUntilExit()` 阻塞当前线程，等待子进程自然结束
   - `terminate()` 立即向子进程发送 SIGTERM，请求终止
   - 两者独立：terminate() 后仍需 waitUntilExit() 确认退出

2. **Linux 没有 macOS 的沙箱机制**：
   - macOS 应用运行在沙箱中，有固定的 Documents/Caches/Application Support 目录
   - Linux 是传统文件系统，只有 /tmp、/home/user、当前目录等通用路径
   - 跨平台代码应避免依赖沙箱路径，用 currentDirectoryPath 或 HOME 替代

3. **Signal Handler 中避免复杂操作**：
   - Signal Handler 在中断上下文执行，不是正常线程环境
   - 执行耗时操作（如文件保存、网络请求）可能导致死锁或崩溃
   - 正确做法：只设置标志变量，主循环检测标志后执行清理

</details>

## 继续学习

**下一章**: [测试框架与质量保证](./testing.md) - 学习 XCTest、异步测试、性能基准

**返回**: [高级进阶概览](./advance-overview.md)