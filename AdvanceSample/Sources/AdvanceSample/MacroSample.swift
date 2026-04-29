import Foundation

struct TodoItem: Codable, Equatable {
    var title: String
    var completed: Bool = false
    var createdAt: Date = Date()
}

func macroSample() {
    print("--- macroSample start ---")
    
    var todo = TodoItem(title: "Learn Swift Macros")
    print("Todo: \(todo.title), completed: \(todo.completed)")
    
    todo.completed = true
    print("Updated: \(todo.title), completed: \(todo.completed)")
    
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    if let data = try? encoder.encode(todo),
       let json = String(data: data, encoding: .utf8) {
        print("Encoded JSON: \(json)")
    }
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    if let data = try? encoder.encode(todo),
       let decoded = try? decoder.decode(TodoItem.self, from: data) {
        print("Decoded: \(decoded)")
        print("Round-trip equal: \(todo == decoded)")
    }
    
    print("--- macroSample end ---")
}
