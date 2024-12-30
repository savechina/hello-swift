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
    startSample(functionName: "LoggerSample loggerOSLogSample")

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
    
    endSample(functionName: "LoggerSample loggerOSLogSample")

}

public func loggingSample() {
    startSample(functionName: "LoggerSample loggingSample")


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

    // 设置 swift-log 的默认日志处理程序
    LoggingSystem.bootstrap { label in
        SwiftyBeaver.LogHandler(
            "SwiftyBeaver",
            destinations: [
                ConsoleDestination(),
                FileDestination(
                    logFileURL: URL(fileURLWithPath: "Logs/hello.log")),
            ])
    }

    let logger2 = Logger(label: "SwiftyBeaver")

    logger2.info("use BeaverHandler logging log an info  message")
    
    logger2.error("use BeaverHandler logging log an error message")
    
    endSample(functionName: "LoggerSample loggingSample")

}

public func logBeaverSample() {
    startSample(functionName: "LoggerSample logBeaverSample")


    // 创建 SwiftyBeaver 实例 (确保在应用启动时初始化)
    let beaver = SwiftyBeaver.self

    //创建终端日志输出
    let console = ConsoleDestination()
    beaver.addDestination(console)

    beaver.info("Beaver logging an info messang")

    beaver.error("Beaver logging an error messang")
    // 创建 日志文件输出目的
    let filelog = FileDestination(
        logFileURL: URL(fileURLWithPath: "Logs/hello.log"))
    beaver.addDestination(filelog)

    beaver.info("Beaver logging an info messang append log file.")
    
    endSample(functionName: "LoggerSample logBeaverSample")
}
