// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// System Programming Sample
// Demonstrates: Process execution, Signal handling, Cross-platform considerations
// Cross-platform: macOS (Darwin) and Linux (Glibc)

import Foundation

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

/// System programming sample demonstrating Process execution
public func systemProgrammingSample() {
    startSample(functionName: "systemProgrammingSample")
    
    print("系统编程示例")
    print("本示例演示如何使用 Process 执行外部命令、处理输出、管理进程")
    print("")
    
    // Example 1: Basic Process execution
    print("--- 示例 1: Process 执行外部命令 ---")
    executeCommand(command: "/bin/ls", arguments: ["-la"])
    
    print("")
    
    // Example 2: Capture stdout/stderr
    print("--- 示例 2: 捕获命令输出 ---")
    captureCommandOutput(command: "/bin/echo", arguments: ["Hello from Process!"])
    
    print("")
    
    // Example 3: Cross-platform path differences
    print("--- 示例 3: 跨平台路径差异 ---")
    demonstratePlatformPaths()
    
    print("")
    
    // Example 4: Signal handling concepts
    print("--- 示例 4: Signal 处理概念 ---")
    demonstrateSignalHandling()
    
    endSample(functionName: "systemProgrammingSample")
}

/// Process execution sample
/// Demonstrates basic command execution
public func processExecutionSample() {
    startSample(functionName: "processExecutionSample")
    
    print("Process 执行示例")
    
    // Execute git version command (if available)
    executeCommand(command: "/usr/bin/git", arguments: ["--version"])
    
    // Execute swiftenv or swift --version
    executeCommand(command: "/usr/bin/swift", arguments: ["--version"])
    
    endSample(functionName: "processExecutionSample")
}

// MARK: - Process Execution

/// Execute an external command
/// - Parameters:
///   - command: Path to executable
///   - arguments: Command arguments
func executeCommand(command: String, arguments: [String]) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: command)
    process.arguments = arguments
    
    print("执行命令: \(command) \(arguments.joined(separator: " "))")
    
    do {
        try process.run()
        process.waitUntilExit()
        
        let status = process.terminationStatus
        if status == 0 {
            print("命令执行成功 (status: \(status))")
        } else {
            print("命令执行失败 (status: \(status))")
        }
    } catch {
        print("执行命令错误: \(error)")
        print("提示: 请确认命令路径 '\(command)' 存在")
    }
}

/// Execute command and capture output
/// - Parameters:
///   - command: Path to executable
///   - arguments: Command arguments
/// - Returns: Tuple of (stdout, stderr, status)
@discardableResult
func captureCommandOutput(command: String, arguments: [String]) -> (String, String, Int32) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: command)
    process.arguments = arguments
    
    // Setup stdout pipe
    let stdoutPipe = Pipe()
    process.standardOutput = stdoutPipe
    
    // Setup stderr pipe
    let stderrPipe = Pipe()
    process.standardError = stderrPipe
    
    print("执行并捕获: \(command) \(arguments.joined(separator: " "))")
    
    do {
        try process.run()
        process.waitUntilExit()
        
        // Read stdout
        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
        
        // Read stderr
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        let stderr = String(data: stderrData, encoding: .utf8) ?? ""
        
        print("stdout: \(stdout.trimmingCharacters(in: .whitespacesAndNewlines))")
        if !stderr.isEmpty {
            print("stderr: \(stderr.trimmingCharacters(in: .whitespacesAndNewlines))")
        }
        
        return (stdout, stderr, process.terminationStatus)
    } catch {
        print("执行错误: \(error)")
        return ("", error.localizedDescription, -1)
    }
}

// MARK: - Cross-Platform Considerations

/// Demonstrate platform-specific path differences
func demonstratePlatformPaths() {
    let fileManager = FileManager.default
    
    print("macOS 标准目录:")
    
    // macOS sandbox paths (may differ in CLI vs sandboxed app)
    if let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
        print("Documents: \(documents.path)")
    }
    
    if let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
        print("Caches: \(caches.path)")
    }
    
    if let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
        print("Application Support: \(appSupport.path)")
    }
    
    // Temporary directory
    let tempDir = fileManager.temporaryDirectory
    print("Temporary: \(tempDir.path)")
    
    // Current directory (works on all platforms)
    let currentDir = fileManager.currentDirectoryPath
    print("Current: \(currentDir)")
    
    print("")
    print("⚠️ Linux 平台注意事项:")
    print("- 无 Documents/Caches/Application Support 沙箱路径")
    print("- 使用 currentDirectoryPath 或 homeDirectoryPath")
    print("- 临时目录: /tmp 或 NSTemporaryDirectory()")
    
    #if os(Linux)
    print("")
    print("当前运行在 Linux 平台")
    print("HOME: \(ProcessInfo.processInfo.environment["HOME"] ?? "unknown")")
    #endif
}

// MARK: - Signal Handling

/// Demonstrate Signal handling concepts
/// NOTE: Actual signal handling requires C interop and is platform-specific
func demonstrateSignalHandling() {
    print("Signal 处理概念:")
    print("")
    
    print("常见 Signal 类型:")
    print("SIGINT (2)  - Ctrl+C 中断信号")
    print("SIGTERM (15) - 终止请求 (优雅关闭)")
    print("SIGHUP (1)   - 终端挂起")
    print("SIGKILL (9)  - 强制终止 (无法捕获)")
    print("")
    
    print("Swift Signal 处理方式:")
    print("1. Darwin: signal() 函数 (C 互操作)")
    print("2. Linux: sigaction() (Glibc)")
    print("3. 跨平台: DispatchSourceSignal (Foundation)")
    print("")
    
    // DispatchSourceSignal example (conceptual)
    print("--- DispatchSourceSignal 模式 ---")
    print("let source = DispatchSource.makeSignalSource(signal: SIGINT)")
    print("source.setEventHandler { print(\"收到 SIGINT\") }")
    print("source.resume()")
    print("")
    
    print("⚠️ 注意: Signal 处理应在主线程设置")
    print("⚠️ 注意: 避免 Signal handler 中执行复杂操作")
}

// MARK: - Process Timeout Handling

/// Execute command with timeout
/// - Parameters:
///   - command: Path to executable
///   - arguments: Command arguments
///   - timeout: Timeout in seconds
func executeWithTimeout(command: String, arguments: [String], timeout: TimeInterval) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: command)
    process.arguments = arguments
    
    print("执行命令 (超时: \(timeout)s): \(command)")
    
    do {
        try process.run()
        
        // Wait with timeout using Thread
        let startTime = Date()
        while process.isRunning && Date().timeIntervalSince(startTime) < timeout {
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        if process.isRunning {
            print("超时，终止进程")
            process.terminate()
            process.waitUntilExit()
            print("进程已终止 (status: \(process.terminationStatus))")
        } else {
            print("命令完成 (status: \(process.terminationStatus))")
        }
    } catch {
        print("执行错误: \(error)")
    }
}