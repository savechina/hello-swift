//
//  HelloSampleTest.swift
//  hello-swift
//
//  Created by RenYan Wei on 2024/12/18.
//

import AlgoSample
import BasicSample
import HelloSample
import Testing

struct HelloSampleTest {

    @Test func sample() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        BasicSample.expressionSample()

        BasicSample.conditionSample()

        BasicSample.stringSample()

    }

    @Test func expressionSampleTest() async throws {

        //
        BasicSample.earlyExitSample()

        //defer statement
        BasicSample.deferSample()

        BasicSample.availabilitySample()

    }

    @Test func collectionSampleTest() async throws {

        BasicSample.collectionSample()

        BasicSample.setsSample()

        BasicSample.dictionarySample()
    }

    @Test func datatimeSampleTest() async throws {
        BasicSample.datatimeSample()
    }

    @Test func structSampleTest() async throws {
        BasicSample.structSample()
    }

    @Test func simpleAddTest() async throws {
        let sum = AlgoSample.AddTwo(x: 1, y: 2)

        print("sum:", sum)

        #expect(sum == 3, "sum is not equal 3")

    }

    @Test func subscriptSampleTest() async throws {
        BasicSample.subscriptSample()
    }

    @Test func functionSampleTest() async throws {
        BasicSample.functionSample()
    }

    @Test func classSampleTest() async throws {
        BasicSample.classSample()
    }

    @Test func enumsSampleTest() async throws {
        BasicSample.enumsSample()
    }

    @Test func loggerSampleTest() async throws {

        BasicSample.loggerOSLogSample()

        BasicSample.loggingSample()

        BasicSample.logBeaverSample()

    }

    @Test func asyncSampleTest() async throws {

        try BasicSample.asyncTaskSample()

    }

    @Test func simpleThreadSampleTest() async throws {

        BasicSample.simpleThreadSample()

    }

    @Test func actorSampleTest() async throws {

        await BasicSample.actorSample()

        await BasicSample.batchAcotrSample()

    }

    @Test func asyncStreamSampleTest() async throws {

        try await BasicSample.asyncStreamSample()

    }

    @Test func uuidSampleTest() async throws {

        BasicSample.uuidSample()
    }

}
