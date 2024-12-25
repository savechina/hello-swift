//
//  LoggerSample.swift
//  hello-swift
//
//  Created by RenYan Wei on 2024/12/25.
//

import Foundation
import Logging
import OSLog
import os

public func loggerSample() {
    //    OS Logger
    if #available(macOS 11.0, *) {
        // 使用 Logger (macOS 11 及更高版本)

        let logger = Logger()
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

    os_log("os logger print log")
    
    //Logging log
    let logger = Logging.Logger(label: "logger handler")
    
    logger.info("Logging print log message")
}
