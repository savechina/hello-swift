//
//  Test.swift
//  hello-swift
//
//  Created by RenYan Wei on 2024/12/18.
//

import Testing
import HelloSample
import BasicSample
import AlgoSample

struct HelloSampleTest {

    @Test func sample() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        BasicSample.expressionSample()
        
        
        BasicSample.conditionSample()
    }
    
    @Test func simpleAdd() async throws{
        let sum = AlgoSample.AddTwo(x:1,y:2)
        
        print("sum:",sum)
    
    }

}
