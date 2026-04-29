import GRDB

func grdbSample() throws {
    print("--- grdbSample start ---")
    
    let dbQueue = try DatabaseQueue()
    
    try dbQueue.write { db in
        try db.create(table: "player") { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("name", .text).notNull()
            t.column("score", .integer).notNull().defaults(to: 0)
        }
        
        var alice = Player(id: nil, name: "Alice", score: 100)
        try alice.insert(db)
        print("Inserted: \(alice)")
        
        var bob = Player(id: nil, name: "Bob", score: 200)
        try bob.insert(db)
        print("Inserted: \(bob)")
        
        let players = try Player.fetchAll(db)
        print("All players: \(players)")
        
        let topPlayer = try Player
            .filter(Column("score") > 150)
            .order(Column("score").desc)
            .fetchOne(db)
        print("Top scorer: \(topPlayer?.name ?? "none")")
        
        try db.execute(sql: "UPDATE player SET score = ? WHERE name = ?", arguments: [300, "Alice"])
        let updated = try Player.fetchOne(db, key: 1)
        print("Updated Alice: \(updated)")
        
        try db.execute(sql: "DELETE FROM player WHERE name = ?", arguments: ["Bob"])
        let remaining = try Player.fetchAll(db)
        print("Remaining players: \(remaining.count)")
    }
    
    print("--- grdbSample end ---")
}

struct Player: FetchableRecord, PersistableRecord, Codable, CustomStringConvertible {
    var id: Int64?
    var name: String
    var score: Int
    
    var description: String {
        "Player(id: \(id ?? -1), name: \(name), score: \(score))"
    }
}
