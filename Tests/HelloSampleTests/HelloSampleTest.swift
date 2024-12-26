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

    @Test func collectionSampleTest() async throws {

        BasicSample.collectionSample()

        BasicSample.setsSample()

        BasicSample.dictionarySample()
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

}
