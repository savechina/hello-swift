import XCTest
@testable import AdvanceSample

final class ConcurrencySampleTests: XCTestCase {
    func testUserDataIsSendable() async {
        let data = UserData(name: "Alice", age: 30)
        
        let task = Task {
            return data.name
        }
        
        let result = await task.value
        XCTAssertEqual(result, "Alice")
    }
    
    func testSendableClosure() async {
        let data = UserData(name: "Bob", age: 25)
        
        let closure: @Sendable () -> Int = {
            return data.age
        }
        
        let task = Task(operation: closure)
        let result = await task.value
        XCTAssertEqual(result, 25)
    }
}
