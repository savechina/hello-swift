//
//  AlgoSampleTest.swift
//  hello-swift
//
//  Created by RenYan Wei on 2024/12/21.
//

import AlgoSample
import Testing

struct AlgoSampleTest {

    @Test func testExample() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.

        print("test algo sample usecase")

        let sum = multiply(2, 3)

        print("multiply sum:", sum)
    }

}
