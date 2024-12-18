// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import SwiftyJSON

/// advanceSample
public func advanceSample() {
    print("advance sample .first pods.")
}

/// jsonSample
public func jsonSample() {

    //use JSONSerialization process json data
    var jsonString = "{\"name\":\"John\", \"age\":30}"

    let json = try! JSONSerialization.jsonObject(
        with: jsonString.data(using: .utf8)!,
        options: .allowFragments
    )
    //
    print("JSONSerialization:", json)

    //use SwiftyJSON process json data
    //json data context
    var jsonData = "{\"name\":\"John\", \"age\":30}"

    print(jsonData)

    //parse json data
    let result = try! SwiftyJSON.JSON(data: jsonData.data(using: .utf8)!)

    //
    print("SwiftyJSON.JSON:", result)
}
