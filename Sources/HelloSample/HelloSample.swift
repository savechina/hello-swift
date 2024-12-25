// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import AdvanceSample
import ArgumentParser
import BasicSample
import Foundation

enum SampleModule: String, CaseIterable {
    case BasicSample
    case AdvanceSample
    case AwesomeSample
    case AlgoSample
    case LeetCodeSample
}

@main
struct HelloSample: ParsableCommand {
    mutating func run() throws {
        print("Hello, world!")

        for sample in SampleModule.allCases {
            print("SampleType:", sample)
        }
        
//        AdvanceSample

        print("SampleType.AdvanceSample:", SampleModule.AdvanceSample.rawValue)

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
