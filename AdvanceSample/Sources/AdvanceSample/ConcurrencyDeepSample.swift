struct UserData: Sendable {
    let name: String
    let age: Int
}

class NonSendableCounter {
    var count: Int = 0
}

func sendableSample() async {
    print("--- sendableSample start ---")
    
    let data = UserData(name: "Alice", age: 30)
    
    let task1 = Task {
        print("Task 1 sees: \(data.name), age \(data.age)")
        return data.age
    }
    
    let task2 = Task {
        try await Task.sleep(for: .milliseconds(10))
        print("Task 2 also sees: \(data.name)")
        return data.name
    }
    
    let age = await task1.value
    let name = await task2.value
    print("Results: \(name) is \(age)")
    
    let closure: @Sendable () -> String = {
        return "Sendable closure captured: \(data.name)"
    }
    let result = Task(operation: closure)
    print(await result.value)
    
    print("--- sendableSample end ---")
}
