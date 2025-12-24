//
//  FileOperationSample.swift
//
//  Created by weirenyan on 2025/12/24.
//

import Foundation

///file manager fetch comman path sample
public func fileManagerPathSample() {
    startSample(functionName: "FileOperationSample  fileManagerPathSample")

    let fileManager = FileManager.default

    // 1. 获取 Document 目录 (用户文档，iTunes 会备份)
    if let documentsURL = fileManager.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first {
        print("Document 目录: \(documentsURL.path)")
    }

    // 2. 获取 Library/Caches 目录 (临时缓存，系统空间不足时可能清理)
    if let cacheURL = fileManager.urls(
        for: .cachesDirectory,
        in: .userDomainMask
    ).first {
        print("Cache 目录: \(cacheURL.path)")
    }

    // 3. 获取 Library/Application Support 目录 (存放配置、数据库等，推荐使用)
    if let appSupportURL = fileManager.urls(
        for: .applicationSupportDirectory,
        in: .userDomainMask
    ).first {
        print("Application Support 目录: \(appSupportURL.path)")
    }

    // 4. 获取 Temporary 目录 (完全临时的文件)
    let tempPath = NSTemporaryDirectory()
    print("Temp 目录: \(tempPath)")

    // 5.获取当前工作目录 (Current Working Directory)
    let currentPath = fileManager.currentDirectoryPath
    print("当前运行目录: \(currentPath)")

    // 6.获取可执行文件所在的 Bundle 目录 (对于 App 来说是 .app 包内部)
    if let bundlePath = Bundle.main.resourcePath {
        print("Bundle 资源目录: \(bundlePath)")
    }

    // 7. 获取当前用户的家目录 (~/)
    let homeDirectory = fileManager.homeDirectoryForCurrentUser
    print("用户家目录: \(homeDirectory.path)")

    // 获取特定用户的家目录 (例如: /Users/username)
    // let userHome = FileManager.default.homeDirectory(forUser: "username")

    // 获取下载目录 (~/Downloads)
    if let downloadsURL = fileManager.urls(
        for: .downloadsDirectory,
        in: .userDomainMask
    ).first {
        print("下载目录: \(downloadsURL.path)")
    }

    // 获取桌面目录 (~/Desktop)
    if let desktopURL = fileManager.urls(
        for: .desktopDirectory,
        in: .userDomainMask
    ).first {
        print("桌面目录: \(desktopURL.path)")
    }

    // 获取文档目录 (~/Documents)
    if let documentsURL = fileManager.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first {
        print("文档目录: \(documentsURL.path)")
    }

    // 获取电影目录 (~/Movies)
    if let moviesURL = fileManager.urls(
        for: .moviesDirectory,
        in: .userDomainMask
    ).first {
        print("电影目录: \(moviesURL.path)")
    }

    // 获取可执行文件所在的路径
    let executablePath = CommandLine.arguments[0]
    print("Command位置: \(executablePath)")

    endSample(functionName: "FileOperationSample  fileManagerPathSample")
}

/// TemporaryFile
@available(macOS 12.0, *)
public class TemporaryFile {
    public let url: URL

    /// 初始化并写入初始内容
    public init(content: String) throws {
        self.url = FileManager.default.temporaryDirectory
            .appendingPathComponent("temp-\(UUID().uuidString).txt")

        try content.data(using: .utf8)?.write(to: self.url)
        print(" [IO] 临时文件已创建: \(url.path)")
    }

    // MARK: - 读取方法

    /// 1. 直接读取全部文本内容 (适用于小文件)
    public func readContent() throws -> String {
        // 确保文件依然存在
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw NSError(domain: "FileNotFound", code: 404, userInfo: nil)
        }

        return try String(contentsOf: url, encoding: .utf8)
    }

    /// 2. 异步流式读取行 (2025 推荐做法，适用于大文件或日志)
    public func readLines() async throws -> AsyncLineSequence<URL.AsyncBytes> {
        return url.lines
    }

    // MARK: - 清理逻辑

    deinit {
        // 检查文件是否存在再尝试删除
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
            print(" [IO] 临时文件已自动清理")
        }
    }
}

// 使用方式：temp file create and exit auto remove
public func temporaryFileSample() {
    startSample(functionName: "FileOperationSample  temporaryFileSample")

    //check avilable macos 12.0
    guard #available(macOS 12.0, *) else {
        return
    }

    Task {
        do {
            // 1. 创建并写入
            let temp = try TemporaryFile(
                content: "第一行内容\n第二行内容\n2025-12-24 数据"
            )

            // 2. 同步读取全部
            let allContent = try temp.readContent()
            print("--- 全部读取 ---\n\(allContent)")

            // 3. 异步逐行读取
            print("--- 逐行读取 ---")
            for try await line in try await temp.readLines() {
                print("读取到: \(line)")
            }

        } catch {
            print("操作失败: \(error)")
        }

    }

    Thread.sleep(forTimeInterval: 2)

    endSample(functionName: "FileOperationSample  temporaryFileSample")
}
