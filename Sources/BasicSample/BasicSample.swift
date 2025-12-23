//
//  BasicSample.swift
//  hello-swift
//  BasicSample module
//  Created by RenYan Wei on 2024/12/16.
//

import Foundation

/// print  start sample tips
/// - Parameter functionName: sample functionName
public func startSample(functionName: String) {
    print("---- basic \(functionName) ...start ----")
}

/// print  end sample tips
/// - Parameter functionName: sample functionName
public func endSample(functionName: String) {
    print("---- basic \(functionName) ...end ----\n")
}

/// basic express sample
public func expressionSample() {
    startSample(functionName: "expressionSample")

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

    let name = "world"
    if name == "world" {
        print("hello, world")
    } else {
        print("I'm sorry \(name), but I don't recognize you")
    }
    // Prints "hello, world", because name is indeed equal to "world".

    endSample(functionName: "expressionSample")
}

private func compareInt(_ a: Int, _ b: Int) -> Int {
    if a > b {
        return 1
    } else if a == b {
        return 0
    } else {
        return -1
    }
}

public func conditionSample() {

    //if condition
    var a = 3
    var b = 5

    var result = compareInt(a, b)

    print("a < b :(3,5) ", result)

    a = 6
    b = 3
    result = compareInt(a, b)

    print("a > b :(6,3) ", result)

    result = compareInt(2, 2)

    print("a = b :(2,2) ", result)

    //switch case
    let vegetable = "red pepper"
    switch vegetable {
    case "celery":
        print("Add some raisins and make ants on a log.")
    case "cucumber", "watercress":
        print("That would make a good tea sandwich.")
    case let x where x.hasSuffix("pepper"):
        print("Is it a spicy \(x)?")
    default:
        print("Everything tastes good in soup.")
    }

    //  for control flow
    let individualScores = [75, 43, 103, 87, 12]
    var teamScore = 0
    for score in individualScores {
        if score > 50 {
            teamScore += 3
        } else {
            teamScore += 1
        }
    }
    print("for teamScore", teamScore)

    //For-In Loops Dictionary
    let numberOfLegs = ["spider": 8, "ant": 6, "cat": 4]
    for (animalName, legCount) in numberOfLegs {
        print("\(animalName)s have \(legCount) legs")
    }

    //for range
    for index in 1...5 {
        print("\(index) times 5 is \(index * 5)")
    }
}


/// basic string sample
public func stringSample() {
    print("----basic string sample start ...----")
    let apples = 3
    let oranges = 5
    let appleSummary = "I have \(apples) apples."
    let fruitSummary = "I have \(apples + oranges) pieces of fruit."

    print("appleSummary:", appleSummary)

    print("fruitSummary:", fruitSummary)

    //string function return result
    let result = greet(person: "Bob", day: "Tuesday")

    print(result)

    let quotation = """
        The White Rabbit put on his spectacles.  "Where shall I begin,
        please your Majesty?" he asked.

        "Begin at the beginning," the King said gravely, "and go on
        till you come to the end; then stop."
        """

    print(quotation)

    let emptyString = ""  // empty string literal
    let anotherEmptyString = String()  // initializer syntax
    // these two strings are both empty, and are equivalent to each other

    if emptyString.isEmpty {
        print("Nothing to see here")
    }
    // Prints "Nothing to see here"

    print("compare emptyString", emptyString == anotherEmptyString)

    var variableString = "Horse"
    variableString += " and carriage"
    // variableString is now "Horse and carriage"

    let constantString = "Highlander"
    //    constantString += " and another Highlander"
    // this reports a compile-time error - a constant string cannot be modified

    print("constantString", constantString)

    print("----basic string sample end.----\n")

}

public func commentSample() {
    //this is a comment
    //simple line comment
    let i = Int32(16)

    print(i)

    /* This is also a comment
    but is written over multiple lines. */
    print("comment multiple lines")

    /* This is the start of the first multiline comment.
        /* This is the second, nested multiline comment. */
    This is the end of the first multiline comment. */

}

/// greet say hello
/// - Parameters:
///   - person: person name
///   - day: today
/// - Returns:  result
func greet(person: String, day: String) -> String {
    return "Hello \(person), today is \(day)."
}

/// Struct Sample use SimpleStructure and SimpleClass
public func structSample() {
    startSample(functionName: "structSample")

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

    endSample(functionName: "structSample")
}
