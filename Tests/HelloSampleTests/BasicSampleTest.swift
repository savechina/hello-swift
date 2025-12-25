//
//  BasicSampleTest.swift
//  hello-swift
//
//  Created by weirenyan on 2025/12/24.
//

import BasicSample
import Foundation
import Testing

struct BasicSampleTest {

    @Test func sampleTest() async throws {
        print("advance sample test")
        #expect(1 == 1)
    }

    @Test("VisibleSample 验证同模块可见性")
    func testInternalAccessVisibleSample() async throws {
        let account = BasicSample.BankAccount(initialDeposit: 100.0)

        // ✅ 访问 Public 属性
        #expect(account.balance == 100.0)

        // ❌ 访问 Internal 属性 (默认级别)
        // 在同一个 Target 内，auditFlag 是可见的
        //account.internalAuditFlag = true
        //#expect(account.internalAuditFlag == true)

        // ❌ 编译错误：无法访问 private 成员
        // account.transactionPIN = 1234

        // ❌ 编译错误：无法访问 fileprivate 成员 (除非测试代码和类写在同一个 .swift 文件里)
        // print(account.fileSystemKey)
    }

    @Test("VisibleSample 验证 Public 与 Private Set")
    func testPublicInterfaceVisibleSample() async throws {
        let account = BankAccount(initialDeposit: 50.0)

        // ✅ 正常调用 Public 方法
        account.deposit(amount: 50.0)

        // ✅ 读取 Public 属性
        #expect(account.balance == 100.0)

        // ❌ 编译错误：虽然能读，但不能从外部写，因为定义了 private(set)
        // account.balance = 200.0
    }

    @Test("VisibleSample 验证 Extension 提供的功能")
    func testPINResetVisibleSample() async throws {
        let account = BankAccount(initialDeposit: 0)

        // ✅ 通过 Public Extension 方法修改 Private 成员
        let success = account.resetPIN(oldPIN: 8888, newPIN: 1234)
        #expect(success == true)
    }

    @Test func testVisibaleVerifySample() async throws {
        visibaleVerifySample()
    }

    @Test func testModuleSample() async throws {

        MyModule.Network.HTTP.get("https://apple.com")
        MyModule.Model.User.get("Wee")
        MyModule.Storage.Local.save()
    }

    @Test func testConfigAccess() {

        // A. 获取 Bundle 的根目录 URL (推荐)
        let bundleURL = Bundle.module.bundleURL
        print("Bundle 路径: \(bundleURL.path)")

        // 获取 config.json 的完整 URL
        guard
            let url = Bundle.module.url(
                forResource: "config",
                withExtension: "json",
                subdirectory: "Config"
            )
        else {
            Issue.record("无法在 Bundle.module 中找到 config.json")
            return
        }

        print("文件物理路径: \(url.path)")

    }

    @Test func accessProjectRootConfig() throws {
        // 1.获取当前测试文件所在的路径
        let currentPath = URL(fileURLWithPath: #file)

        print("currentPath: \(currentPath)")

        // 2.获取当前源文件的绝对路径
        let currentFilePath = URL(fileURLWithPath: #filePath)

        print("currentFilePath: \(currentFilePath)")

        // 3. 根据目录层级向上回溯到工程根目录
        // 假设路径是: MyProject/Tests/MyProjectTests/MyTest.swift
        let projectRoot =
            currentFilePath
            .deletingLastPathComponent()  // 到 MyProjectTests/
            .deletingLastPathComponent()  // 到 Tests/
            .deletingLastPathComponent()  // 到 MyProject/ 根目录

        print("projectRoot: \(projectRoot)")

        let configURL = projectRoot.appendingPathComponent("Config")

        // 3. 检查文件是否存在
        #expect(FileManager.default.fileExists(atPath: configURL.path))
    }

}
