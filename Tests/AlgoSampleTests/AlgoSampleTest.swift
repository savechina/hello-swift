//
//  AlgoSampleTest.swift
//  hello-swift
//
//  Created by RenYan Wei on 2024/12/21.
//

import AlgoSample
import Foundation
import Testing

struct AlgoSampleTest {

    @Test func testExample() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.

        print("test algo sample usecase")

        let sum = multiply(2, 3)

        print("multiply sum:", sum)
    }

    @Test func testCalculatePiSample() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.

        print("test pi calculate ")

        calculatePiSample()

        //        print("multiply sum:", sum)
    }

    @Test func testCalculatePiBPPSample() async throws {

        print("test pi calculate ")

        calculatePiBBPSample()
    }

    @Test func testCalculatePiBPPSampleOrder() async throws {
        let steps = 11
        let result = calculatePiBBPNormal(steps: steps)
        print("迭代次数: \(steps)")
        print("计算结果: \(result)")
        print("系统标准: \(Double.pi)")
        print("是否相等: \(result == Double.pi)")
    }

    @Test func testCalculatePiDecimal() async throws {
        let steps = 35
        let result = calculatePiDecimal(steps: steps)

        print("迭代次数: \(steps)")
        print("计算结果: \(result)")
        print("系统标准: \(Decimal.pi)")
        print("是否相等: \(result == Decimal.pi)")
    }
    
    @Test func testCalculatePiBigFloat() async throws {
        calculatePiBigFloatSample()
    }
}
