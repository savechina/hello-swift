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
    case BasicSample = "basic"
    case AdvanceSample = "advance"
    case AwesomeSample = "awesome"
    case AlgoSample = "algo"
    case LeetCodeSample = "leet"
}

@main
struct HelloSample: ParsableCommand {

    // Customize your command's help and subcommands by implementing the
    // `configuration` property.
    static let configuration = CommandConfiguration(
        commandName: "hello",

        // Optional abstracts and discussions are used for help output.
        abstract: "A utility for learn swift example code.",

        // Commands can define a version for automatic '--version' support.
        version: "1.0.0",

        // Pass an array to `subcommands` to set up a nested tree of subcommands.
        // With language support for type-level introspection, this could be
        // provided by automatically finding nested `ParsableCommand` types.
        subcommands: [
            HelloInfo.self, BasicCommand.self, AdvanceCommand.self,
            AlgoCommand.self,
        ]

        // A default subcommand, when provided, is automatically selected if a
        // subcommand is not given on the command line.
        //        defaultSubcommand: HelloInfo.self)
    )

}

extension HelloSample {

    struct HelloInfo: ParsableCommand {

        static let configuration =
            CommandConfiguration(
                commandName: "info", abstract: "Print the info of the Samples.")

        //        // The `@OptionGroup` attribute includes the flags, options, and
        //        // arguments defined by another `ParsableArguments` type.
        //        @OptionGroup var options: Options

        @Argument(help: "Sample Name")
        var name: String

        //        mutating func run() {
        //
        ////            let result = options.values.reduce(0, +)
        ////            print(format(result, usingHex: options.hexadecimalOutput))
        //        }
        //

        mutating func run() throws {

            print("Hello, world!")

            //SampleModule name
            let moduleName = SampleModule(rawValue: name)

            switch moduleName {
            case .BasicSample:
                print("BasicSample is learn basic Swift example code.")
            case .some(.AdvanceSample):
                print("AdvanceSample provides advanced example code for Swift programming.")
            case .some(.AwesomeSample):
                print("AwesomeSample")
            case .some(.AlgoSample):
                print("AlgoSample")
            case .some(.LeetCodeSample):
                print("LeetCodeSample")
            case .none:
                print("none")
            }

            print("\nThis have some module:")
            for sample in SampleModule.allCases {
                print("SampleModule:", sample)
            }

        }

    }

    struct BasicCommand: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "basic", abstract: "the BasicSample of the Samples.")

        func run() throws {

            //BasicSample
            print("--- basic sample start ... ---")

            expressionSample()

            stringSample()

            structSample()

            print("--- basic sample end . ---\n")
        }
    }

    struct AdvanceCommand: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "advance",
            abstract: "the AdvanceSample of the Samples.")

        func run() throws {
            //AdvanceSample
            print(
                "SampleType.AdvanceSample:", SampleModule.AdvanceSample.rawValue
            )

            //AdvanceSample
            print("--- advance sample start ... ---")

            AdvanceSample.advanceSample()

            AdvanceSample.jsonSample()
            print("--- advance sample end . ---\n")
        }
    }

    struct AlgoCommand: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "algo",
            abstract: "the AlgoSample of the Samples.")
    }

}
