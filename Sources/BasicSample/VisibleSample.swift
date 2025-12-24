//
//  VisibleSample.swift
//  hello-swift
//
//  Created by weirenyan on 2025/12/24.
//

import Foundation

// MARK: - 1. Public 级别 (跨模块可见)
/// 银行账户类：任何引入此模块的代码都可以看到这个类
public class BankAccount {

    // 公共属性：任何人都可以读取余额
    public private(set) var balance: Double = 0.0

    // Internal 属性：默认级别。仅在同一个 App/Framework 内部可见。
    // 模拟银行内部的审查标记，外部用户不应看到
    var internalAuditFlag: Bool = false

    // Fileprivate 属性：仅限本文件内可见。
    // 模拟一种特殊的“文件内共享”数据，比如用于本文件内多个类协同工作的密钥
    fileprivate var fileSystemKey: String = "FILE-SECRET-123"

    // Private 属性：仅限本类大括号内可见（及本文件内的 extension）。
    // 模拟极其敏感的个人密码
    private var transactionPIN: Int = 8888

    public init(initialDeposit: Double) {
        self.balance = initialDeposit
    }

    // Public 方法：允许外部调用
    public func deposit(amount: Double) {
        balance += amount
        logTransaction(type: "存款")
    }

    // Private 方法：仅限内部逻辑使用
    private func logTransaction(type: String) {
        print("记录内部日志：执行了 \(type) 操作")
    }
}

// MARK: - 2. Fileprivate 作用演示 (同文件访问)
/// 这是一个审计工具类，定义在同一个文件内。
struct AuditTool {
    func audit(account: BankAccount) {
        // ❌ 无法访问 account.transactionPIN (因为它在类内是 private)

        // ✅ 可以访问 account.fileSystemKey
        // 因为 AuditTool 和 BankAccount 在同一个文件内
        print("审计工具正在使用文件密钥: \(account.fileSystemKey)")

        // ✅ 可以访问 account.internalAuditFlag
        // 因为在同一个模块内
        account.internalAuditFlag = true
    }
}

// MARK: - 3. Open 级别 (跨模块可继承)
/// 如果你希望这个类能被其他模块“继承”，必须使用 open。
/// 比如一个通用的基础服务类。
open class BaseService {
    public init() {}

    // open 方法允许子类在其他模块重写 (Override)
    open func start() {
        print("服务启动")
    }
}

// MARK: - 4. 扩展与访问控制
/// Swift 允许在同一个文件的 extension 中访问 private 成员
extension BankAccount {
    public func resetPIN(oldPIN: Int, newPIN: Int) -> Bool {
        // ✅ 虽然是 extension，但因为在同一个文件，可以访问 private 的 transactionPIN
        if self.transactionPIN == oldPIN {
            self.transactionPIN = newPIN
            return true
        }
        return false
    }
}

/// verify fileprivate access
func verifyFileSystemAccess() {
    let account = BankAccount(initialDeposit: 0)
    let tool = AuditTool()

    // ✅ 正常执行，因为 AuditTool 在同一文件内定义，能够访问 account 的 fileprivate 属性
    tool.audit(account: account)
}

public func visibaleVerifySample() {
    startSample(functionName: "VisibleSample visibaleVerifySample")

    verifyFileSystemAccess()

    let base = BaseService()

    base.start()

    let account = BasicSample.BankAccount(initialDeposit: 100.0)

    // ✅ 访问 Public 属性
    assert(account.balance == 100.0)

    // ✅ 访问 Internal 属性 (默认级别)
    // 在同一个 Target 内，auditFlag 是可见的
    account.internalAuditFlag = true
    assert(account.internalAuditFlag == true)

    // ❌ 编译错误：无法访问 private 成员
    //     account.transactionPIN = 1234

    // ✅ 访问 fileprivate 成员
    print(account.fileSystemKey)

    endSample(functionName: "VisibleSample visibaleVerifySample")
}
