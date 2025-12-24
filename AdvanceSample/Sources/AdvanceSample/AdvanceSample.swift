// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import SwiftyJSON

/// print  start sample tips
/// - Parameter functionName: sample functionName
public func startSample(functionName: String) {
    print("---- advance \(functionName) ...start ----")
}

/// print  end sample tips
/// - Parameter functionName: sample functionName
public func endSample(functionName: String) {
    print("---- advance \(functionName) ...end ----\n")
}

/// advanceSample
public func advanceSample() {
    print("advance sample .first pods.")

    jsonSample()

    fileManagerPathSample()

    temporaryFileSample()
}

/// jsonSample
public func jsonSample() {
    startSample(functionName: "jsonSample")
    //use JSONSerialization process json data
    let jsonString = "{\"name\":\"John\", \"age\":30}"

    let json = try! JSONSerialization.jsonObject(
        with: jsonString.data(using: .utf8)!,
        options: .allowFragments
    )
    //
    print("JSONSerialization:", json)

    //use SwiftyJSON process json data
    //json data context
    let jsonData = "{\"name\":\"John\", \"age\":30}"

    print(jsonData)

    //parse json data
    let result = try! SwiftyJSON.JSON(data: jsonData.data(using: .utf8)!)

    //
    print("SwiftyJSON.JSON:", result)

    endSample(functionName: "jsonSample")
}
