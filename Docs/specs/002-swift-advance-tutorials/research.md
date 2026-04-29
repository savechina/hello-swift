# Research: Swift Advance Tutorial Phase 3

**Date**: 2026-04-28
**Feature**: 002-swift-advance-tutorials

## Overview

Gap analysis against hello-rust (41 advance chapters) identified critical missing topics for Swift backend/system programming. Phase 3 expands coverage from 8 chapters to 20 chapters.

## Gap Analysis Summary

### hello-rust Coverage (41 chapters)

| Category | Chapters | Topics |
|----------|----------|--------|
| Async | 6 | tokio, futures, mio, rayon, cyclerc, async |
| Data | 4 | json, csv, rkyv, serialization |
| Database | 3 | diesel, sqlx, database |
| Error-handling | 1 | error-chain, anyhow |
| System | 13 | cli, dotenv, process, bytes, tempfile, memmap, sysinfo, IPC, UDS, cow, includedir, directory, rust-eliminates |
| Testing | 6 | test, mock, rspec, macros, getset, typealias |
| Web | 4 | axum, hyper, grpc, ollama |
| Tools | 2 | objectstore, services |
| Core Language | 4 | smart-pointers, iterators, atomic-types, advanced-traits |

### hello-swift Current Coverage (8 chapters)

| Phase | Chapters | Topics |
|-------|----------|--------|
| Phase 1 | 4 | JSON, File Operations, SwiftData, Environment |
| Phase 2 | 4 | SwiftNIO Basics, SwiftNIO Async, System Programming, Testing |

### Critical Gaps Identified

| Gap | hello-rust Coverage | Swift Equivalent | Priority |
|-----|---------------------|------------------|----------|
| Web Frameworks | axum, hyper | Vapor, Hummingbird | P0 |
| SQL Database | diesel, sqlx | GRDB, SQLite.swift | P0 |
| Actors/Sendable | tokio async | Swift Actors | P0 |
| Property Wrappers | Rust macros | Swift @propertyWrapper | P1 |
| ARC Memory | - (Rust ownership) | Swift ARC | P1 |
| Opaque Types | impl Trait | Swift some/any | P1 |
| Unsafe Pointers | unsafe Rust | Swift UnsafePointer | P2 |
| Macros | procedural macros | Swift Macros | P2 |
| Result Builders | - | Swift @resultBuilder | P2 |
| Reflection | - | Swift Mirror | P3 |

## Research Findings

### 1. Vapor Web Framework

**Official Documentation**: https://docs.vapor.codes/

**Key Features**:
- SwiftNIO-based async HTTP server
- Fluent ORM for database operations
- Middleware support for authentication, logging
- WebSocket support via swift-nio-transport-services

**Best Practices (from Vapor docs + GitHub examples)**:
- Use `app.routes()` for route grouping
- Use `app.middleware()` for request interception
- Use `Fluent` for type-safe database queries
- Use `Content` protocol for JSON encoding/decoding

**Sample Implementation Pattern**:
```swift
// VaporSample.swift - Minimal REST API
import Vapor

func vaporSample() {
    let app = Application()
    
    app.get("hello") { req in
        return "Hello, Vapor!"
    }
    
    app.post("users") { req async throws -> User in
        let user = try req.content.decode(User.self)
        // Fluent save
        return user
    }
    
    try app.run()
}
```

**Integration with hello-swift**: Add as nested package dependency, create VaporSample.swift demonstrating basic REST API.

### 2. GRDB SQLite Database

**Official Documentation**: https://github.com/groue/GRDB.swift

**Key Features**:
- Record protocol for type-safe models
- QueryInterface DSL for SQL generation
- Associations (BelongsTo, HasMany, HasOne)
- Transaction support with `db.inTransaction {}`
- Raw SQL fallback with `SQLRequest`

**Best Practices (from GRDB README + examples)**:
- Use `FetchableRecord` + `PersistableRecord` protocols
- Use `QueryInterfaceRequest` for chainable queries
- Use `Association` for JOIN operations
- Use `DatabasePool` for concurrent access

**Sample Implementation Pattern**:
```swift
// GRDBSample.swift - Basic SQLite operations
import GRDB

struct Player: Record, FetchableRecord, PersistableRecord {
    var id: Int64?
    var name: String
    var score: Int
}

func grdbSample() throws {
    let dbQueue = DatabaseQueue()
    
    try dbQueue.write { db in
        try db.create(table: "player") { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("name", .text).notNull()
            t.column("score", .integer).notNull()
        }
        
        var player = Player(name: "Alice", score: 100)
        try player.insert(db)
        
        let players = try Player.fetchAll(db)
        print(players)
    }
}
```

**Integration with hello-swift**: Add GRDB dependency, create GRDBSample.swift demonstrating CRUD operations.

### 3. Swift Actors

**Swift Documentation**: https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html

**Key Concepts**:
- Actor isolation (protected state)
- `await` required for actor method calls
- `actor` vs `class` difference (implicit isolation)
- `nonisolated` keyword for public methods

**Best Practices (from Swift docs + SwiftBySundell)**:
- Use actors for shared mutable state
- Mark synchronous methods `nonisolated` when safe
- Use `Task.sleep` not `Thread.sleep` in actors
- Combine with `Sendable` for cross-actor data

**Sample Implementation Pattern**:
```swift
// ActorSample.swift - Bank account actor
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
    
    nonisolated func description() -> String {
        "Account \(accountNumber)"
    }
}

func actorSample() async {
    let account = BankAccount(accountNumber: 1, initialBalance: 1000)
    await account.deposit(amount: 500)
    let success = await account.withdraw(amount: 200)
    print("Withdrawal: \(success)")
}
```

### 4. Sendable Protocol

**Swift Documentation**: https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html#ID553

**Key Concepts**:
- Types crossing concurrency boundaries MUST be Sendable
- Implicitly Sendable: value types, `@Sendable` closures
- Non-Sendable: classes (reference types), mutable state
- Compiler enforces Sendable in Swift 6 strict mode

**Best Practices**:
- Use value types (structs) for concurrent data
- Mark closures `@Sendable` for Task usage
- Avoid capturing non-Sendable in closures
- Use `@unchecked Sendable` sparingly with justification

**Sample Implementation Pattern**:
```swift
// ConcurrencyDeepSample.swift - Sendable examples
struct UserData: Sendable { // Implicitly Sendable
    let name: String
    let age: Int
}

class NonSendableClass {
    var value: Int = 0
}

func sendableSample() async {
    let data = UserData(name: "Alice", age: 30)
    
    // ✅ Sendable data - allowed
    Task {
        print(data.name)
    }
    
    // ❌ Non-Sendable class - compiler error
    // let obj = NonSendableClass()
    // Task { print(obj.value) } // Error!
    
    // ✅ @Sendable closure
    let closure: @Sendable () -> Void = {
        print(data.age)
    }
    Task(operation: closure)
}
```

### 5. Property Wrappers

**Swift Documentation**: https://docs.swift.org/swift-book/LanguageGuide/Properties.html#ID612

**Key Concepts**:
- `@propertyWrapper` attribute
- `wrappedValue` for underlying storage
- `projectedValue` for additional operations ($ prefix)
- Composition via nested wrappers

**Built-in Examples**: @State, @Binding (SwiftUI), @Published (Combine)

**Sample Implementation Pattern**:
```swift
// PropertyWrapperSample.swift - Custom wrappers
@propertyWrapper
struct Clamped<Value: Comparable> {
    var wrappedValue: Value {
        didSet { wrappedValue = min(max(wrappedValue, range.lowerBound), range.upperBound) }
    }
    var projectedValue: Clamped { self }
    var range: ClosedRange<Value>
    
    init(wrappedValue: Value, _ range: ClosedRange<Value>) {
        self.wrappedValue = min(max(wrappedValue, range.lowerBound), range.upperBound)
        self.range = range
    }
}

@propertyWrapper
struct Logged<Value> {
    var wrappedValue: Value {
        didSet { print("Changed to: \(wrappedValue)") }
    }
    
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
        print("Initialized: \(wrappedValue)")
    }
}

struct Example {
    @Clamped(0...100) var score: Int = 50
    @Logged var name: String = "Alice"
}

func propertyWrapperSample() {
    var ex = Example()
    ex.score = 150 // Clamped to 100
    ex.name = "Bob" // Logs change
    print(ex.$score.projectedValue.range) // Access projected
}
```

### 6. ARC Memory Management

**Swift Documentation**: https://docs.swift.org/swift-book/LanguageGuide/AutomaticReferenceCounting.html

**Key Concepts**:
- Strong references (default, increments count)
- `weak` references (optional, nil when freed)
- `unowned` references (non-optional, crash if freed)
- Closures capture self (use `[weak self]`)

**Common Pitfalls**:
- Two-way strong references = retain cycle
- Closures capturing self strongly
- Using `unowned` when `weak` is safer

**Sample Implementation Pattern**:
```swift
// ARCSample.swift - Memory management examples
class Person {
    let name: String
    var pet: Pet? // Strong reference
    
    init(name: String) { self.name = name }
    deinit { print("Person \(name) deinitialized") }
}

class Pet {
    let name: String
    weak var owner: Person? // Weak to break cycle
    
    init(name: String) { self.name = name }
    deinit { print("Pet \(name) deinitialized") }
}

func arcSample() {
    var person: Person? = Person(name: "Alice")
    var pet: Pet? = Pet(name: "Fluffy")
    
    // Create cycle
    person?.pet = pet
    pet?.owner = person
    
    // ✅ Cycle broken by weak reference
    person = nil // Both deinit
    pet = nil
    
    // Closure capture
    let closure = { [weak person] in
        guard let person else { return }
        print(person.name)
    }
}
```

### 7. Opaque/Existential Types

**Swift Documentation**: https://docs.swift.org/swift-book/LanguageGuide/OpaqueTypes.html

**Key Concepts**:
- `some Protocol` = opaque return type (caller sees protocol, callee sees concrete)
- `any Protocol` = existential type (type erasure, dynamic dispatch)
- Performance: opaque is zero-cost, existential has runtime overhead

**Sample Implementation Pattern**:
```swift
// OpaqueTypeSample.swift - some vs any
protocol Shape {
    func area() -> Double
}

struct Circle: Shape {
    let radius: Double
    func area() -> Double { .pi * radius * radius }
}

struct Square: Shape {
    let side: Double
    func area() -> Double { side * side }
}

// Opaque return type - concrete type preserved
func makeShape() -> some Shape {
    Circle(radius: 5)
}

// Existential type - type erased
func makeShapes() -> [any Shape] {
    [Circle(radius: 5), Square(side: 10)]
}

func opaqueTypeSample() {
    let shape = makeShape() // some Shape
    print(shape.area())
    
    let shapes = makeShapes() // [any Shape]
    for s in shapes { print(s.area()) }
}
```

### 8. Unsafe Pointers

**Swift Documentation**: https://docs.swift.org/swift-book/LanguageGuide/UnsafePointers.html

**Key Concepts**:
- `UnsafePointer<T>` - read-only pointer
- `UnsafeMutablePointer<T>` - mutable pointer
- `UnsafeRawPointer` - typeless pointer
- `withUnsafePointer(to:) {}` - safe temporary access

**Best Practices**:
- Prefer safe APIs over unsafe
- Use `withUnsafePointer` for scoped access
- Document memory safety assumptions
- Bind memory before typed access

**Sample Implementation Pattern**:
```swift
// UnsafePointerSample.swift - C interop example
func unsafePointerSample() {
    var array: [Int] = [1, 2, 3, 4, 5]
    
    // Safe scoped access
    array.withUnsafeBufferPointer { buffer in
        let base = buffer.baseAddress!
        print("First element: \(base.pointee)")
        
        // Pointer arithmetic
        for i in 0..<buffer.count {
            print(buffer[i])
        }
    }
    
    // Memory layout
    let size = MemoryLayout<Int>.size
    let stride = MemoryLayout<Int>.stride
    print("Int size: \(size), stride: \(stride)")
}
```

### 9. Swift Macros

**Swift Documentation**: https://docs.swift.org/swift-book/LanguageGuide/Macros.html

**Key Concepts**:
- Freestanding macros (`#macroName`)
- Attached macros (`@attachedMacro`)
- SwiftSyntax for macro implementation
- Macro expansion visible via `-dmacro-expansion`

**Built-in Examples**: @Model (SwiftData), @Observable (Observation)

**Sample Implementation Pattern**:
```swift
// MacroSample.swift - Using built-in macros
import SwiftData

@Model // Attached macro - generates persistence code
class TodoItem {
    var title: String
    var completed: Bool = false
    
    init(title: String) {
        self.title = title
    }
}

func macroSample() {
    // View expanded code: swift build -dmacro-expansion
    let item = TodoItem(title: "Learn macros")
    print(item.title)
}
```

**Note**: Custom macro implementation requires separate macro target. Tutorial focuses on using built-in macros, not implementing custom ones.

### 10. Result Builders

**Swift Documentation**: https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID63

**Key Concepts**:
- `@resultBuilder` attribute
- `buildBlock(_:)` for combining values
- `buildOptional(_:)` for if statements
- `buildEither(_:)` for if/else

**Built-in Examples**: ViewBuilder (SwiftUI), ArrayBuilder

**Sample Implementation Pattern**:
```swift
// ResultBuilderSample.swift - Custom DSL
@resultBuilder
struct StringBuilder {
    static func buildBlock(_ components: String...) -> String {
        components.joined(separator: "\n")
    }
    
    static func buildOptional(_ component: String?) -> String {
        component ?? ""
    }
    
    static func buildEither(first: String) -> String { first }
    static func buildEither(second: String) -> String { second }
}

func buildString(@StringBuilder builder: () -> String) -> String {
    builder()
}

func resultBuilderSample() {
    let result = buildString {
        "Line 1"
        "Line 2"
        if true {
            "Line 3"
        }
    }
    print(result) // "Line 1\nLine 2\nLine 3"
}
```

### 11. Mirror Reflection

**Swift Documentation**: https://developer.apple.com/documentation/swift/mirror

**Key Concepts**:
- `Mirror(reflecting:)` for runtime inspection
- `children` property for member enumeration
- `displayStyle` for type category (struct, class, enum)
- Read-only (cannot modify via Mirror)

**Best Practices**:
- Use for debugging, logging, serialization
- Avoid for production logic (slow, unsafe)
- Document reflection limitations

**Sample Implementation Pattern**:
```swift
// ReflectionSample.swift - Mirror examples
struct User {
    let name: String
    var age: Int
    var email: String?
}

func reflectionSample() {
    let user = User(name: "Alice", age: 30, email: "alice@example.com")
    
    let mirror = Mirror(reflecting: user)
    
    print("Type: \(mirror.displayStyle ?? .unknown)") // .struct
    
    for child in mirror.children {
        print("\(child.label ?? "unknown"): \(child.value)")
    }
    // name: Alice
    // age: 30
    // email: alice@example.com
}
```

## Decisions Summary

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Web Framework | Vapor | Largest ecosystem, Fluent ORM |
| SQL Database | GRDB | macOS/Linux cross-platform |
| Actors Depth | 2 chapters | Isolation + Sendable complex |
| Swift Features | All 7 features | Interrelated, better together |
| Mock Testing | Skip | Original Q4 minimal coverage |
| Chapter Template | 15-section | hello-rust expanded template |

## Next Steps

1. Generate tasks.md via `/speckit.tasks`
2. Implement Phase 3 chapters and source files
3. Run `/speckit.analyze` for consistency check