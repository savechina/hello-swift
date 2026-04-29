@propertyWrapper
struct Clamped<Value: Comparable> {
    var wrappedValue: Value {
        didSet {
            wrappedValue = min(max(wrappedValue, range.lowerBound), range.upperBound)
        }
    }
    var projectedValue: Clamped { self }
    let range: ClosedRange<Value>
    
    init(wrappedValue: Value, _ range: ClosedRange<Value>) {
        self.range = range
        self.wrappedValue = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }
}

@propertyWrapper
struct Logged<Value> {
    var wrappedValue: Value {
        didSet {
            print("  [Logged] Changed to: \(wrappedValue)")
        }
    }
    
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
        print("  [Logged] Initialized: \(wrappedValue)")
    }
}

struct Player {
    @Clamped(0...100) var score: Int = 50
    @Logged var name: String = "Unknown"
}

func propertyWrapperSample() {
    print("--- propertyWrapperSample start ---")
    
    var player = Player()
    
    player.score = 150
    print("Score after 150: \(player.score)")
    
    player.score = -10
    print("Score after -10: \(player.score)")
    
    player.name = "Alice"
    player.name = "Bob"
    
    print("Projected range: \(player.$score.projectedValue.range)")
    
    print("--- propertyWrapperSample end ---")
}
