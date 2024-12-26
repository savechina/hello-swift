//
//  LoggerSample.swift
//  hello-swift
//
//  Created by RenYan Wei on 2024/12/25.
//

import Foundation
import Logging
import OSLog
import SwiftyBeaver
import os

public func loggerOSLogSample() {
    //    OS Logger.
    if #available(macOS 11.0, *) {
        // 使用 Logger (macOS 11 及更高版本)

        let logger = os.Logger()
        logger.info("This is a log message.")
        logger.error("This is an error message.")

        // 使用带有参数的日志记录
        let username = "exampleUser"
        logger.info("User logged in: \(username, privacy: .private)")  // private 表示该信息不应公开记录。

    } else {
        // 使用 os_log (macOS 10.12 及更高版本)
        os_log("This is a log message.", log: .default, type: .info)
        os_log("This is an error message.", log: .default, type: .error)

        // 使用带有格式化字符串的日志记录 (类似 printf)
        let username = "exampleUser"
        os_log("User logged in: %{public}@", username)  // public 表示该信息可以公开记录。
    }

    //use os_log
    os_log("os logger print log")
}

struct SwiftyBeaverLogHandler: LogHandler {
    private var prettyMetadata: String?
    public var metadata = Logging.Logger.Metadata()
    public var logLevel: Logging.Logger.Level = .info
    private var beaver: SwiftyBeaver.Type

    public subscript(metadataKey metadataKey: String) -> Logging.Logger.Metadata
        .Value?
    {
        get {
            return metadata[metadataKey]
        }
        set(newValue) {
            metadata[metadataKey] = newValue
        }
    }

    public init(beaver: SwiftyBeaver.Type) {
        self.beaver = beaver
    }

    public mutating func log(
        level: Logging.Logger.Level, message: Logging.Logger.Message,
        metadata: Logging.Logger.Metadata?, source: String, file: String,
        function: String, line: UInt
    ) {
        let mergedMetadata = metadata?.merging(
            self.metadata, uniquingKeysWith: { (current, _) in current })

        let metaString =
            mergedMetadata?.isEmpty ?? true
            ? "" : " \(self.prettyMetadata(from: mergedMetadata!))"

        switch level {
        case .trace:
            beaver.verbose(
                "\(message)\(metaString)", file: file, function: function,
                line: Int(line))
        case .debug:
            beaver.debug(
                "\(message)\(metaString)", file: file, function: function,
                line: Int(line))
        case .info:
            beaver.info(
                "\(message)\(metaString)", file: file, function: function,
                line: Int(line))
        case .notice:
            beaver.info(
                "\(message)\(metaString)", file: file, function: function,
                line: Int(line))  // SwiftyBeaver 没有 notice 级别，使用 info 代替
        case .warning:
            beaver.warning(
                "\(message)\(metaString)", file: file, function: function,
                line: Int(line))
        case .error:
            beaver.error(
                "\(message)\(metaString)", file: file, function: function,
                line: Int(line))
        case .critical:
            beaver.error(
                "\(message)\(metaString)", file: file, function: function,
                line: Int(line))  // SwiftyBeaver 没有 fatal 级别，使用 error 代替
        }
    }

    private func prettyMetadata(from metadata: Logging.Logger.Metadata)
        -> String
    {
        return metadata.map { key, value in
            return "\(key):\(value)"
        }.joined(separator: " ")
    }
}

public func loggingSample() {

    //Logging log
    var logger = Logger(label: "logger handler")

    //打印日志级别
    logger.info("Logging logLevel \(logger.logLevel)")

    //设置Logger Level
    logger.logLevel = .debug

    logger.info("Logging print log message")

    logger.trace("Logging ,This is an trace log message")

    logger.debug("Logging ,This is an debug log message")

    logger.error("Logging ,This is an error log message")

    // 创建 SwiftyBeaver 实例 (确保在应用启动时初始化)
    let beaver = SwiftyBeaver.self

    let console = ConsoleDestination()
    beaver.addDestination(console)

    // 设置 swift-log 的默认日志处理程序
    LoggingSystem.bootstrap { label in
        SwiftyBeaverLogHandler(beaver:beaver)
    }

    var logger2 = Logger(label: "logger handler file")
    
//    logger2.info("use BeaverHandler logging log message")
}
