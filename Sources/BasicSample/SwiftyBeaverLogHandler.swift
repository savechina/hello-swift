//
//  SwiftyBeaverLogHandler.swift
//  hello-swift
//  SwiftBeaver 实现 swift-log 的 LogHandler ,增强swift-log日志文件输出的特性，
//
//  Created by RenYan Wei on 2024/12/26.
//
import Foundation
import Logging
import SwiftyBeaver
@_exported import SwiftyBeaver

//扩展SwiftyBeaver
extension SwiftyBeaver {
    /// Logging.LogHandler
    public struct LogHandler: Logging.LogHandler {
        public let label: String
        public var metadata: Logger.Metadata
        public var logLevel: Logger.Level

        /// 初始化
        /// - Parameters:
        ///   - label: label name
        ///   - destinations: destinations array 可以支持多个 destination
        ///   - level: level 日志级别
        ///   - metadata: metadata 元数据
        public init(
            _ label: String, destinations: [BaseDestination],
            level: Logger.Level = .trace, metadata: Logger.Metadata = [:]
        ) {
            self.label = label
            self.metadata = metadata
            self.logLevel = level
            destinations.forEach { SwiftyBeaver.addDestination($0) }
        }

        public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
            get { self.metadata[key] }
            set(newValue) { self.metadata[key] = newValue }
        }

        public func log(
            level: Logger.Level, message: Logger.Message,
            metadata: Logger.Metadata?, source: String, file: String,
            function: String, line: UInt
        ) {
            let formattedMessage =
                "\(source.isEmpty ? "" : "[\(source)] ")\(message)"

            switch level {
            case .trace:
                SwiftyBeaver.verbose(
                    formattedMessage, file: file, function: function,
                    line: Int(line), context: metadata)

            case .debug:
                SwiftyBeaver.debug(
                    formattedMessage, file: file, function: function,
                    line: Int(line), context: metadata)

            case .info:
                SwiftyBeaver.info(
                    formattedMessage, file: file, function: function,
                    line: Int(line), context: metadata)

            case .notice, .warning:
                SwiftyBeaver.warning(
                    formattedMessage, file: file, function: function,
                    line: Int(line), context: metadata)

            case .error, .critical:
                SwiftyBeaver.error(
                    formattedMessage, file: file, function: function,
                    line: Int(line), context: metadata)
            }
        }
    }
}
