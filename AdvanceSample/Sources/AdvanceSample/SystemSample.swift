// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// System Sample - Cross-platform system programming concepts
// Demonstrates: Platform detection, Environment differences, System capabilities
// Cross-platform: macOS (Darwin) and Linux (Glibc)

import Foundation

/// System sample demonstrating cross-platform considerations
public func systemSample() {
    startSample(functionName: "systemSample")
    
    print("系统编程跨平台示例")
    print("本示例演示 macOS 和 Linux 平台差异及跨平台代码编写")
    print("")
    
    // Example 1: Platform detection
    print("--- 示例 1: 平台检测 ---")
    detectPlatform()
    
    print("")
    
    // Example 2: Environment variables
    print("--- 示例 2: 系统环境变量 ---")
    demonstrateEnvironmentVariables()
    
    print("")
    
    // Example 3: System information
    print("--- 示例 3: 系统信息 ---")
    demonstrateSystemInfo()
    
    print("")
    
    // Example 4: Resource limits
    print("--- 示例 4: 资源限制 ---")
    demonstrateResourceLimits()
    
    endSample(functionName: "systemSample")
}

// MARK: - Platform Detection

/// Detect current platform and show capabilities
func detectPlatform() {
    #if os(macOS)
    print("当前平台: macOS (Darwin)")
    print("可用特性: SwiftData, FileManager sandbox paths, Darwin signals")
    #elseif os(Linux)
    print("当前平台: Linux (Glibc)")
    print("可用特性: POSIX paths, Glibc signals, epoll")
    print("受限特性: SwiftData (仅 macOS/iOS)")
    #else
    print("当前平台: Unknown")
    #endif
    
    // Swift version
    print("Swift 版本: \(ProcessInfo.processInfo.operatingSystemVersionString)")
    
    // Architecture
    #if arch(x86_64)
    print("架构: x86_64 (64-bit)")
    #elseif arch(arm64)
    print("架构: arm64 (Apple Silicon)")
    #elseif arch(i386)
    print("架构: i386 (32-bit)")
    #endif
}

// MARK: - Environment Variables

/// Demonstrate system environment variables
func demonstrateEnvironmentVariables() {
    let env = ProcessInfo.processInfo.environment
    
    print("关键环境变量:")
    
    // Common variables (exist on all platforms)
    let commonVars = ["PATH", "HOME", "USER", "SHELL", "LANG", "PWD"]
    
    for varName in commonVars {
        if let value = env[varName] {
            print("\(varName): \(value)")
        } else {
            print("\(varName): (未设置)")
        }
    }
    
    print("")
    print("获取所有环境变量数量: \(env.count)")
    
    // ProcessInfo.processInfo.environment returns Dictionary<String, String>
    print("访问方式: ProcessInfo.processInfo.environment[\"KEY\"]")
    
    #if os(macOS)
    print("")
    print("macOS 特有变量:")
    if let tmpdir = env["TMPDIR"] {
        print("TMPDIR: \(tmpdir)")
    }
    #endif
}

// MARK: - System Information

/// Demonstrate system information access
func demonstrateSystemInfo() {
    let processInfo = ProcessInfo.processInfo
    
    print("系统信息:")
    print("主机名: \(processInfo.hostName)")
    print("操作系统版本: \(processInfo.operatingSystemVersionString)")
    print("进程名: \(processInfo.processName)")
    print("进程 ID: \(processInfo.processIdentifier)")
    print("物理内存: \(processInfo.physicalMemory / 1024 / 1024) MB")
    print("系统启动时间: \(processInfo.systemUptime) 秒")
    
    // Processor count
    print("处理器数量: \(processInfo.processorCount)")
    print("活跃处理器: \(processInfo.activeProcessorCount)")
    
    #if os(macOS)
    // macOS version check
    let version = processInfo.operatingSystemVersion
    print("macOS 版本: \(version.majorVersion).\(version.minorVersion).\(version.patchVersion)")
    
    // Check macOS 14+ for SwiftData
    if version.majorVersion >= 14 {
        print("✅ SwiftData 可用 (macOS 14+)")
    } else {
        print("⚠️ SwiftData 不可用 (需要 macOS 14+)")
    }
    #endif
}

// MARK: - Resource Limits

/// Demonstrate system resource limits
func demonstrateResourceLimits() {
    print("资源限制 (概念演示):")
    print("")
    
    print("常见系统限制:")
    print("- 最大打开文件数: ulimit -n")
    print("- 最大进程数: ulimit -u")
    print("- 内存限制: ulimit -m")
    print("- CPU 时间限制: ulimit -t")
    print("")
    
    print("Swift 中获取资源限制:")
    print("Darwin: getrlimit() C 函数")
    print("Linux: getrlimit() Glibc 函数")
    print("跨平台: Foundation 无直接 API，需 C 互操作")
    print("")
    
    print("示例代码:")
    print("var limit = rlimit()")
    print("getrlimit(RLIMIT_NOFILE, &limit)")
    print("print(\"最大文件数: <limit.rlim_cur>\")")
}

// MARK: - Cross-Platform File Operations

/// Demonstrate cross-platform file operation patterns
func demonstrateCrossPlatformFiles() {
    let fileManager = FileManager.default
    
    print("跨平台文件操作建议:")
    print("")
    
    // Pattern 1: Use currentDirectoryPath for cross-platform
    print("Pattern 1: 当前目录路径")
    print("fileManager.currentDirectoryPath - 所有平台可用")
    let current = fileManager.currentDirectoryPath
    print("当前目录: \(current)")
    
    // Pattern 2: Use temporaryDirectory
    print("")
    print("Pattern 2: 临时目录")
    print("fileManager.temporaryDirectory - 所有平台可用")
    let temp = fileManager.temporaryDirectory.path
    print("临时目录: \(temp)")
    
    // Pattern 3: Home directory
    print("")
    print("Pattern 3: 用户主目录")
    print("ProcessInfo.processInfo.environment[\"HOME\"] - 所有平台可用")
    let home = ProcessInfo.processInfo.environment["HOME"] ?? "unknown"
    print("主目录: \(home)")
    
    print("")
    print("⚠️ 避免使用:")
    print("- FileManager.urls(for: .documentDirectory, ...) - 仅 macOS/iOS sandbox")
    print("- FileManager.urls(for: .cachesDirectory, ...) - 仅 macOS/iOS sandbox")
    print("- 硬编码路径如 /Users/... 或 /home/...")
}