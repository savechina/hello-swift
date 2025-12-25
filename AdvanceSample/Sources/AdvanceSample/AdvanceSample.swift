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

    if #available(macOS 14.0, *) {
        Task {
            await metricsDataServiceSample()
        }
        Thread.sleep(forTimeInterval: 2)
    }

}

/// jsonSample
public func jsonSample() {
    startSample(functionName: "jsonSample")
    //use JSONSerialization process json data
    print("use JSONSerialization process json data")
    let jsonString = "{\"name\":\"John\", \"age\":30}"

    let json = try! JSONSerialization.jsonObject(
        with: jsonString.data(using: .utf8)!,
        options: .allowFragments
    )
    //
    print("JSONSerialization:", json)

    //use JSONDecoder process json data
    print("use JSONDecoder process json data")

    // 1. Define a struct that matches the JSON keys
    struct User: Codable {
        let name: String
        let age: Int
    }

    let jsonContext = "{\"name\":\"John\", \"age\":30}"

    // 2. Convert the String to Data
    if let jsonData = jsonContext.data(using: .utf8) {
        let decoder = JSONDecoder()

        do {
            // 3. Decode the data into the User struct
            let user = try decoder.decode(User.self, from: jsonData)

            print("Name: \(user.name)")  // Output: John
            print("Age: \(user.age)")  // Output: 30
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }

    //use SwiftyJSON process json data
    print("use SwiftyJSON process json data")
    //json data context
    let jsonData = "{\"name\":\"John\", \"age\":30}"

    print(jsonData)

    //parse json data
    let result = try! SwiftyJSON.JSON(data: jsonData.data(using: .utf8)!)

    //
    print("SwiftyJSON.JSON:", result)

    endSample(functionName: "jsonSample")
}
