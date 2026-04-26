//
//  ControlFlowSample.swift
//  hello-swift
//
//  Created by RenYan Wei on 2026/04/26.
//

import Foundation

/// if/else and switch/case
public func controlFlowConditionSample() {
    startSample(functionName: "ControlFlowSample controlFlowConditionSample")

    let temperature = 25
    if temperature < 0 {
        print("Freezing!")
    } else if temperature < 20 {
        print("Chilly")
    } else {
        print("Comfortable")
    }

    let fruit = "apple"
    switch fruit {
    case "apple":
        print("🍎 Apple")
    case "banana":
        print("🍌 Banana")
    case "cherry":
        print("🍒 Cherry")
    default:
        print("Unknown fruit")
    }

    endSample(functionName: "ControlFlowSample conditionSample")
}

/// for-in loops with ranges, arrays, dictionaries
public func controlFlowLoopSample() {
    startSample(functionName: "ControlFlowSample controlFlowLoopSample")

    print("Closed range 1...3:")
    for i in 1...3 { print(i) }

    print("Half-open range 1..<3:")
    for i in 1..<3 { print(i) }

    print("Stride:")
    for i in stride(from: 0, to: 10, by: 3) { print(i) }

    let names = ["Alice", "Bob", "Charlie"]
    print("Array:")
    for name in names { print("Hello, \(name)!") }

    let scores = ["Math": 95, "English": 88]
    print("Dictionary:")
    for (subject, score) in scores {
        print("\(subject): \(score)")
    }

    endSample(functionName: "ControlFlowSample loopSample")
}

/// guard statement and labeled loops
public func controlFlowGuardSample() {
    startSample(functionName: "ControlFlowSample controlFlowGuardSample")

    func greet(_ name: String?) {
        guard let name = name else {
            print("No name provided")
            return
        }
        print("Hello, \(name)!")
    }

    greet("Alice")
    greet(nil)

    outerLoop: for i in 1...3 {
        for j in 1...3 {
            if j == 2 { break outerLoop }
            print("(\(i), \(j))")
        }
    }

    endSample(functionName: "ControlFlowSample guardAndLabeledLoopSample")
}

/// while and repeat-while
public func controlFlowWhileSample() {
    startSample(functionName: "ControlFlowSample controlFlowWhileSample")

    var counter = 0
    while counter < 3 {
        print("Counter: \(counter)")
        counter += 1
    }

    var total = 0
    repeat {
        total += 1
    } while total < 3
    print("Total after repeat-while: \(total)")

    endSample(functionName: "ControlFlowSample whileLoopSample")
}
