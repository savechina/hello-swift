//
//  AdvanceSampleTest.swift
//  hello-swift
//
//  Created by weirenyan on 2025/12/24.
//
import AdvanceSample
import Foundation
import Testing

struct AdvanceSampleTest {

    @Test func sampleTest() async throws {
        // Write your test here and use APIs like ` to check expected conditions.

        print("advance sample test")

        #expect(1 == 1)
    }

    @Test func fsHomeDirectoryTest() async throws {
        // 获取当前用户的家目录 (~/)
        AdvanceSample.fileManagerPathSample()
    }

    @Test func temporaryFileSampleTest() async throws {
        AdvanceSample.temporaryFileSample()
    }

    @Test func metricsDataServiceSampleTest() async throws {
        await AdvanceSample.metricsDataServiceSample()
    }

    @Test func logServicesSampleTest() async throws {
        await AdvanceSample.logServicesSample()
    }

    @Test func systemeEnvSampleTest() async throws {
        AdvanceSample.processInfoEnvSample()
    }

    @Test func dotenvySampleTest() async throws {
        AdvanceSample.dotenvSample()
    }

}
