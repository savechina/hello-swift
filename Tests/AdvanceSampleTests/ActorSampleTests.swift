import XCTest
@testable import AdvanceSample

final class ActorSampleTests: XCTestCase {
    func testBankAccountDeposit() async {
        let account = BankAccount(accountNumber: 1, initialBalance: 100)
        await account.deposit(amount: 50)
        let balance = await account.getBalance()
        XCTAssertEqual(balance, 150.0, accuracy: 0.01)
    }
    
    func testBankAccountWithdrawSuccess() async {
        let account = BankAccount(accountNumber: 2, initialBalance: 200)
        let result = await account.withdraw(amount: 50)
        XCTAssertTrue(result)
        let balance = await account.getBalance()
        XCTAssertEqual(balance, 150.0, accuracy: 0.01)
    }
    
    func testBankAccountWithdrawFail() async {
        let account = BankAccount(accountNumber: 3, initialBalance: 50)
        let result = await account.withdraw(amount: 100)
        XCTAssertFalse(result)
        let balance = await account.getBalance()
        XCTAssertEqual(balance, 50.0, accuracy: 0.01)
    }
    
    func testBankAccountDescription() {
        let account = BankAccount(accountNumber: 42, initialBalance: 0)
        XCTAssertEqual(account.description, "Account #42")
    }
}
