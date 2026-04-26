//
//  EnumSample.swift
//  hello-swift
//
//  Created by RenYan Wei on 2026/04/26.
//

import Foundation

/// Basic enum definition
public func basicEnumSample() {
    startSample(functionName: "EnumSample basicEnumSample")

    enum CompassPoint {
        case north, south, east, west
    }

    var direction = CompassPoint.north
    direction = .south
    print("Direction: \(direction)")

    endSample(functionName: "EnumSample basicEnumSample")
}

/// Switch + CaseIterable
public func switchEnumSample() {
    startSample(functionName: "EnumSample switchEnumSample")

    enum Planet: CaseIterable {
        case mercury, venus, earth, mars, jupiter
    }

    let homePlanet = Planet.earth

    switch homePlanet {
    case .mercury:
        print("Closest to the Sun")
    case .venus:
        print("Hottest planet")
    case .earth:
        print("Our home")
    case .mars:
        print("The Red Planet")
    case .jupiter:
        print("Largest planet")
    }

    for planet in Planet.allCases {
        print("Planet: \(planet)")
    }

    endSample(functionName: "EnumSample switchEnumSample")
}

/// Associated values
public func associatedValueSample() {
    startSample(functionName: "EnumSample associatedValueSample")

    enum Barcode {
        case upc(Int, Int, Int, Int)
        case qrCode(String)
    }

    var productBarcode = Barcode.upc(8, 85909, 51226, 3)
    productBarcode = .qrCode("ABCDEFGHIJKLMNOP")

    switch productBarcode {
    case .upc(let numSys, let mfr, let prod, let check):
        print("UPC: \(numSys), \(mfr), \(prod), \(check)")
    case .qrCode(let code):
        print("QR Code: \(code)")
    }

    endSample(functionName: "EnumSample associatedValueSample")
}

/// Result type pattern
public func resultPatternSample() {
    startSample(functionName: "EnumSample resultPatternSample")

    enum NetworkResult {
        case success(String)
        case failure(Error)
    }

    struct SampleError: Error, LocalizedError {
        var errorDescription: String? { "network timeout" }
    }

    func fetchData() -> NetworkResult {
        .success("data from server")
    }

    switch fetchData() {
    case .success(let data):
        print("Got data: \(data)")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }

    endSample(functionName: "EnumSample resultPatternSample")
}

/// Raw values
public func rawValueSample() {
    startSample(functionName: "EnumSample rawValueSample")

    enum Season: String {
        case spring = "春暖花开"
        case summer = "夏日炎炎"
        case autumn = "秋高气爽"
        case winter = "冬日寒寒"
    }

    print("Summer rawValue: \(Season.summer.rawValue)")
    print("From rawValue lookup: \(Season(rawValue: "秋高气爽")?.rawValue ?? "not found")")

    if let fall = Season(rawValue: "秋高气爽") {
        print("Found: \(fall)")
    }

    endSample(functionName: "EnumSample rawValueSample")
}

/// Recursive enum with indirect
public func recursiveEnumSample() {
    startSample(functionName: "EnumSample recursiveEnumSample")

    indirect enum ArithmeticExpression {
        case number(Int)
        case addition(ArithmeticExpression, ArithmeticExpression)
        case multiplication(ArithmeticExpression, ArithmeticExpression)
    }

    func evaluate(_ expression: ArithmeticExpression) -> Int {
        switch expression {
        case .number(let value):
            return value
        case .addition(let left, let right):
            return evaluate(left) + evaluate(right)
        case .multiplication(let left, let right):
            return evaluate(left) * evaluate(right)
        }
    }

    let five = ArithmeticExpression.number(5)
    let four = ArithmeticExpression.number(4)

    let sum = ArithmeticExpression.addition(five, four)
    let product = ArithmeticExpression.multiplication(sum, ArithmeticExpression.number(2))

    print("Result: \(evaluate(product))")

    endSample(functionName: "EnumSample recursiveEnumSample")
}

public func mainEnumSample() {
    basicEnumSample()
    switchEnumSample()
    associatedValueSample()
    resultPatternSample()
    rawValueSample()
    recursiveEnumSample()
}
