import XCTest
@testable import AdvanceSample

final class VaporSampleTests: XCTestCase {
    func testUserRequestDecoding() throws {
        let json = """
        {"name": "Alice", "email": "alice@example.com"}
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let decoder = JSONDecoder()
        let request = try decoder.decode(UserRequest.self, from: data)
        XCTAssertEqual(request.name, "Alice")
        XCTAssertEqual(request.email, "alice@example.com")
    }
    
    func testUserResponseEncoding() throws {
        let response = UserResponse(id: "123", name: "Bob", email: "bob@example.com")
        let encoder = JSONEncoder()
        let data = try encoder.encode(response)
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))
        XCTAssertTrue(json.contains("Bob"))
        XCTAssertTrue(json.contains("bob@example.com"))
    }
}
