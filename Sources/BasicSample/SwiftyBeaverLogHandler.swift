//
//  SwiftyBeaverLogHandler.swift
//  hello-swift
//
//  Created by RenYan Wei on 2024/12/26.
//
import Foundation
import Logging
import SwiftyBeaver

import Logging
@_exported import SwiftyBeaver

extension SwiftyBeaver {
    public struct LogHandler: Logging.LogHandler {
        public let label: String
        public var metadata: Logger.Metadata
        public var logLevel: Logger.Level
        
        public init(_ label: String, destinations: [BaseDestination], level: Logger.Level = .trace, metadata: Logger.Metadata = [:]) {
            self.label = label
            self.metadata = metadata
            self.logLevel = level
            destinations.forEach { SwiftyBeaver.addDestination($0) }
        }
        
        public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
            get { self.metadata[key] }
            set(newValue) { self.metadata[key] = newValue }
        }
        
        public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
            let formattedMessage = "\(source.isEmpty ? "" : "[\(source)] ")\(message)"

            switch level {
            case .trace:
                SwiftyBeaver.verbose(formattedMessage, file: file, function: function, line: Int(line), context: metadata)
                
            case .debug:
                SwiftyBeaver.debug(formattedMessage, file: file, function: function, line: Int(line), context: metadata)
                
            case .info:
                SwiftyBeaver.info(formattedMessage, file: file, function: function, line: Int(line), context: metadata)
                
            case .notice, .warning:
                SwiftyBeaver.warning(formattedMessage, file: file, function: function, line: Int(line), context: metadata)
                
            case .error, .critical:
                SwiftyBeaver.error(formattedMessage, file: file, function: function, line: Int(line), context: metadata)
            }
        }
    }
}


//
//let beaver = SwiftyBeaver.self
//
//struct SwiftyBeaverLogHandler: LogHandler {
//    private var prettyMetadata: String?
//    public var metadata = Logging.Logger.Metadata()
//    public var logLevel: Logging.Logger.Level = .info
//    
//    public subscript(metadataKey metadataKey: String) -> Logging.Logger.Metadata
//        .Value?
//    {
//        get {
//            return metadata[metadataKey]
//        }
//        set(newValue) {
//            metadata[metadataKey] = newValue
//        }
//    }
//
//    public init() {
//    }
//
//    public mutating func log(
//        level: Logging.Logger.Level, message: Logging.Logger.Message,
//        metadata: Logging.Logger.Metadata?, source: String, file: String,
//        function: String, line: UInt
//    ) {
//        let mergedMetadata = metadata?.merging(
//            self.metadata, uniquingKeysWith: { (current, _) in current })
//
//        let metaString =
//            mergedMetadata?.isEmpty ?? true
//            ? "" : " \(self.prettyMetadata(from: mergedMetadata!))"
//
//        switch level {
//        case .trace:
//            beaver.verbose(
//                "\(message)\(metaString)", file: file, function: function,
//                line: Int(line))
//        case .debug:
//            beaver.debug(
//                "\(message)\(metaString)", file: file, function: function,
//                line: Int(line))
//        case .info:
//            beaver.info(
//                "\(message)\(metaString)", file: file, function: function,
//                line: Int(line))
//        case .notice:
//            beaver.info(
//                "\(message)\(metaString)", file: file, function: function,
//                line: Int(line))  // SwiftyBeaver 没有 notice 级别，使用 info 代替
//        case .warning:
//            beaver.warning(
//                "\(message)\(metaString)", file: file, function: function,
//                line: Int(line))
//        case .error:
//            beaver.error(
//                "\(message)\(metaString)", file: file, function: function,
//                line: Int(line))
//        case .critical:
//            beaver.error(
//                "\(message)\(metaString)", file: file, function: function,
//                line: Int(line))  // SwiftyBeaver 没有 fatal 级别，使用 error 代替
//        }
//    }
//
//    private func prettyMetadata(from metadata: Logging.Logger.Metadata)
//        -> String
//    {
//        return metadata.map { key, value in
//            return "\(key):\(value)"
//        }.joined(separator: " ")
//    }
//}
