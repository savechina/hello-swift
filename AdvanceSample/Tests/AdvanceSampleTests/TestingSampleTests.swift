// XCTest Testing Patterns Sample
// Demonstrates: XCTestCase, async tests, XCTAssert patterns

import XCTest
@testable import AdvanceSample

final class TestingSampleTests: XCTestCase {
    
    // MARK: - Basic XCTestCase Tests
    
    /// Basic test demonstrating XCTAssert patterns
    func testBasicAssertion() {
        // XCTAssertEqual - compare two values
        let expected = "Hello"
        let actual = "Hello"
        XCTAssertEqual(expected, actual, "Strings should be equal")
        
        // XCTAssertTrue - verify condition is true
        let isValid = true
        XCTAssertTrue(isValid, "Value should be true")
        
        // XCTAssertFalse - verify condition is false
        let isEmpty = false
        XCTAssertFalse(isEmpty, "Value should be false")
        
        // XCTAssertNotNil - verify value is not nil
        let optionalValue: String? = "exists"
        XCTAssertNotNil(optionalValue, "Optional should have value")
        
        // XCTAssertNil - verify value is nil
        let nilValue: String? = nil
        XCTAssertNil(nilValue, "Optional should be nil")
    }
    
    /// Test demonstrating comparison assertions
    func testComparisonAssertions() {
        // XCTAssertGreaterThan
        let larger = 10
        let smaller = 5
        XCTAssertGreaterThan(larger, smaller, "First value should be greater")
        
        // XCTAssertLessThan
        XCTAssertLessThan(smaller, larger, "First value should be less")
        
        // XCTAssertGreaterThanOrEqual
        XCTAssertGreaterThanOrEqual(larger, smaller, "First value should be >= second")
        
        // XCTAssertLessThanOrEqual
        XCTAssertLessThanOrEqual(smaller, larger, "First value should be <= second")
    }
    
    /// Test demonstrating floating point comparisons
    func testFloatingPointAssertions() {
        // XCTAssertEqual with accuracy for floating point
        let computed = 3.14159
        let expected = 3.14
        XCTAssertEqual(computed, expected, accuracy: 0.01, "Values should be equal within accuracy")
    }
    
    // MARK: - Async Test Methods
    
    /// Async test demonstrating async/await testing
    func testAsyncOperation() async throws {
        // Async test - marked with async
        let result = await performAsyncWork()
        XCTAssertEqual(result, "completed", "Async result should match")
    }
    
    /// Test with async throwing
    func testAsyncThrowing() async throws {
        // Can use try in async test
        let value = try await performThrowingAsyncWork()
        XCTAssertEqual(value, 42, "Async throwing result should match")
    }
    
    /// Helper async function for testing
    private func performAsyncWork() async -> String {
        // Simulate async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
        return "completed"
    }
    
    /// Helper throwing async function
    private func performThrowingAsyncWork() async throws -> Int {
        try await Task.sleep(nanoseconds: 50_000_000)
        return 42
    }
    
    // MARK: - Error Testing
    
    /// Test demonstrating error assertion
    func testErrorThrowing() throws {
        // XCTAssertThrowsError - verify function throws
        XCTAssertThrowsError(try throwIfNegative(-1), "Should throw for negative input")
        
        // XCTAssertNoThrow - verify function doesn't throw
        XCTAssertNoThrow(try throwIfNegative(1), "Should not throw for positive input")
    }
    
    /// Helper throwing function
    private func throwIfNegative(_ value: Int) throws {
        if value < 0 {
            throw NSError(domain: "Test", code: -1)
        }
    }
    
    // MARK: - Performance Tests
    
    /// Performance test measuring execution time
    func testPerformance() {
        // measure block - runs multiple times
        measure {
            // Code to measure
            let _ = performCalculation()
        }
    }
    
    /// Helper calculation function
    private func performCalculation() -> Int {
        var sum = 0
        for i in 0..<1000 {
            sum += i
        }
        return sum
    }
    
    // MARK: - Setup and Teardown
    
    /// Called before each test method
    override func setUp() {
        super.setUp()
        // Initialize test resources
    }
    
    /// Called after each test method
    override func tearDown() {
        // Cleanup test resources
        super.tearDown()
    }
    
    /// Called once before all tests
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Initialize shared resources
    }
    
    /// Called once after all tests
    override func tearDownWithError() throws {
        // Cleanup shared resources
        try super.tearDownWithError()
    }
}