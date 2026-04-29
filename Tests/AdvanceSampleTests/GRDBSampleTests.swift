import XCTest
@testable import AdvanceSample

final class GRDBSampleTests: XCTestCase {
    func testPlayerDescription() {
        let player = Player(id: 1, name: "Alice", score: 100)
        let desc = player.description
        XCTAssertTrue(desc.contains("Alice"))
        XCTAssertTrue(desc.contains("100"))
    }
    
    func testPlayerDefaultScore() {
        let player = Player(name: "Bob", score: 0)
        XCTAssertEqual(player.score, 0)
    }
}
