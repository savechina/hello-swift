//
//  ExampleProtocol.swift
//  hello-swift
//
//  Created by RenYan Wei on 2024/12/15.
//

/// protocol ExampleProtocol
protocol ExampleProtocol {
    var simpleDescription: String { get }
    mutating func adjust()
}

/// SimpleClass implement ExampleProtocol
class SimpleClass: ExampleProtocol {
    var simpleDescription: String = "A very simple class."
    var anotherProperty: Int = 69105
    func adjust() {
        simpleDescription += "  Now 100% adjusted."
    }
}

/// SimpleStructure
struct SimpleStructure: ExampleProtocol {
    var simpleDescription: String = "A simple structure"
    mutating func adjust() {
        simpleDescription += " (adjusted)"
    }
}
/// Int extension ExampleProtocol
extension Int: ExampleProtocol {
    var simpleDescription: String {
        return "The number \(self)"
    }
    mutating func adjust() {
        self += 42
    }
}
