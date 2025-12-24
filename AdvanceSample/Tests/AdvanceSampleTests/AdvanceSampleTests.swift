import Testing

@testable import AdvanceSample

struct AdvanceSampleTests {

    @Test func exampleTest() async throws {

        print("test advance sample ")
    }

    @Test func fsHomeDirectoryTest() async throws {
        // 获取当前用户的家目录 (~/)
        AdvanceSample.fileManagerPathSample()
    }
}
