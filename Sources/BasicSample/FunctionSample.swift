//
//  FunctionSample.swift
//  hello-swift
//
//  Created by RenYan Wei on 2026/04/26.
//

import Foundation

/// Basic function definition and call
public func basicFunctionSample() {
    startSample(functionName: "FunctionSample basicFunctionSample")

    func greet(person: String, from location: String) -> String {
        "Hello \(person)! I'm from \(location)."
    }

    print(greet(person: "Alice", from: "Beijing"))
    // Prints "Hello Alice! I'm from Beijing."

    endSample(functionName: "FunctionSample basicFunctionSample")
}

/// Default parameter values
public func defaultParameterSample() {
    startSample(functionName: "FunctionSample defaultParameterSample")

    func greet(person: String, greeting: String = "Hello") -> String {
        "\(greeting), \(person)!"
    }

    print(greet(person: "Bob"))
    // Prints "Hello, Bob!"
    print(greet(person: "Charlie", greeting: "Hi"))
    // Prints "Hi, Charlie!"

    endSample(functionName: "FunctionSample defaultParameterSample")
}

/// Variadic parameters
public func variadicParameterSample() {
    startSample(functionName: "FunctionSample variadicParameterSample")

    func arithmeticMean(_ numbers: Double...) -> Double {
        let total = numbers.reduce(0, +)
        return total / Double(numbers.count)
    }

    print("Mean: \(arithmeticMean(1, 2, 3, 4, 5))")
    // Mean: 3.0
    print("Mean: \(arithmeticMean(3.0, 8.25, 18.75))")
    // Mean: 10.0

    endSample(functionName: "FunctionSample variadicParameterSample")
}

/// In-out parameters
public func inOutParameterSample() {
    startSample(functionName: "FunctionSample inOutParameterSample")

    func swapTwoInts(_ a: inout Int, _ b: inout Int) {
        let temp = a
        a = b
        b = temp
    }

    var x = 3
    var y = 107
    print("Before swap: x=\(x), y=\(y)")
    swapTwoInts(&x, &y)
    print("After swap: x=\(x), y=\(y)")

    endSample(functionName: "FunctionSample inOutParameterSample")
}

/// Function type as return value
public func functionAsReturnTypeSample() {
    startSample(functionName: "FunctionSample functionAsReturnTypeSample")

    func makeIncrementer(forIncrement amount: Int) -> () -> Int {
        var runningTotal = 0
        func incrementer() -> Int {
            runningTotal += amount
            return runningTotal
        }
        return incrementer
    }

    let incrementByTen = makeIncrementer(forIncrement: 10)
    print("Call 1: \(incrementByTen())")  // 10
    print("Call 2: \(incrementByTen())")  // 20
    print("Call 3: \(incrementByTen())")  // 30

    endSample(functionName: "FunctionSample functionAsReturnTypeSample")
}

/// Multiple return values with tuple
public func tupleReturnSample() {
    startSample(functionName: "FunctionSample tupleReturnSample")

    func minMax(array: [Int]) -> (min: Int, max: Int)? {
        guard !array.isEmpty else { return nil }
        var currentMin = array[0]
        var currentMax = array[0]
        for value in array.dropFirst() {
            if value < currentMin {
                currentMin = value
            } else if value > currentMax {
                currentMax = value
            }
        }
        return (currentMin, currentMax)
    }

    if let bounds = minMax(array: [8, -6, 2, 109, 3, 71]) {
        print("Min: \(bounds.min), Max: \(bounds.max)")
    }

    endSample(functionName: "FunctionSample tupleReturnSample")
}

/// Master function that calls all samples
public func mainFunctionSample() {
    basicFunctionSample()
    defaultParameterSample()
    variadicParameterSample()
    inOutParameterSample()
    functionAsReturnTypeSample()
    tupleReturnSample()
}
