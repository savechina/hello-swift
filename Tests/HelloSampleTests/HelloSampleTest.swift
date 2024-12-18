//
//  Test.swift
//  hello-swift
//
//  Created by RenYan Wei on 2024/12/18.
//

import Testing
import HelloSample
import BasicSample


struct HelloSampleTest {

    @Test func sample() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        BasicSample.expressionSample()
    }

}
