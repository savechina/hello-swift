// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import AdvanceSample
import ArgumentParser
import BasicSample
import Foundation

enum SampleType: String, CaseIterable {
    case BasicSample
    case AdvanceSample
}

@main
struct HelloSample: ParsableCommand {
    mutating func run() throws {
        print("Hello, world!")

        for sample in SampleType.allCases {
            print("SampleType:", sample)
        }

        print("SampleType.AdvanceSample:", SampleType.AdvanceSample.rawValue)

        //BasicSample
        print("--- basic sample start ... ---")

        expressionSample()

        stringSample()

        structSample()

        print("--- basic sample end . ---\n")

        //AdvanceSample
        print("--- advance sample start ... ---")

        AdvanceSample.advanceSample()

        AdvanceSample.jsonSample()
        print("--- advance sample end . ---\n")

    }
}
