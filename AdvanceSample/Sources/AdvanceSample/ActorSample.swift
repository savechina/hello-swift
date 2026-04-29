actor BankAccount {
    let accountNumber: Int
    var balance: Double
    
    init(accountNumber: Int, initialBalance: Double) {
        self.accountNumber = accountNumber
        self.balance = initialBalance
    }
    
    func deposit(amount: Double) {
        balance += amount
    }
    
    func withdraw(amount: Double) -> Bool {
        guard balance >= amount else { return false }
        balance -= amount
        return true
    }
    
    func getBalance() -> Double {
        return balance
    }
    
    nonisolated var description: String {
        "Account #\(accountNumber)"
    }
}

func actorSample() async {
    print("--- actorSample start ---")
    
    let account = BankAccount(accountNumber: 1, initialBalance: 1000)
    print("Created: \(account)")
    
    await account.deposit(amount: 500)
    let balance = await account.getBalance()
    print("After deposit: \(balance)")
    
    let success = await account.withdraw(amount: 200)
    print("Withdraw 200: \(success ? "success" : "failed")")
    
    let overdrawn = await account.withdraw(amount: 9999)
    print("Withdraw 9999: \(overdrawn ? "success" : "failed")")
    
    let finalBalance = await account.getBalance()
    print("Final balance: \(finalBalance)")
    
    print("--- actorSample end ---")
}
