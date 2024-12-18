// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Foundation
import ArgumentParser
import BasicSample

import AdvanceSample


@main
struct HelloSample: ParsableCommand {
    mutating func run() throws {
        print("Hello, world!")

        //BasicSample
        print("basic sample start ...")
        expressionSample()

        stringSample()

        structSample()

        print("basic sample end .\n")

        //AdvanceSample
        print("advance sample start ...")

        AdvanceSample.advanceSample()

        AdvanceSample.jsonSample()
        print("advance sample end .\n")

    }
}
