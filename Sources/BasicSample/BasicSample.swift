//
//  BasicSample.swift
//  hello-swift
//  BasicSample module
//  Created by RenYan Wei on 2024/12/16.
//

import Foundation

/// basic express sample
public func expressionSample() {
    //define variable number
    var n = 42
    n = 50

    //
    let m = 42

    n = n + m

    //print
    print("sum(n+m):", n)

    let label = "The width is "
    let width = 94
    let widthLabel = label + String(width)

    print(widthLabel)
}

/// basic string sample
public func stringSample() {
    print("\nbasic string sample start ...")
    let apples = 3
    let oranges = 5
    let appleSummary = "I have \(apples) apples."
    let fruitSummary = "I have \(apples + oranges) pieces of fruit."

    print("appleSummary:", appleSummary)

    print("fruitSummary:", fruitSummary)

    //string function return result
    let result = greet(person: "Bob", day: "Tuesday")

    print(result)

    print("basic string sample end.\n")

}

/// greet say hello
/// - Parameters:
///   - person: person name
///   - day: today
/// - Returns:  result
func greet(person: String, day: String) -> String {
    return "Hello \(person), today is \(day)."
}

public func structSample() {
    //simpleClass implement ExampleProtocol
    let simple = SimpleClass()
    simple.adjust()

    let aDescription = simple.simpleDescription
    print(aDescription)

    //simpleStruct
    var simpleStruct = SimpleStructure()
    simpleStruct.adjust()

    let bDescription = simpleStruct.simpleDescription
    print(bDescription)

    // Prints "The number 7"
    print(7.simpleDescription)
}
