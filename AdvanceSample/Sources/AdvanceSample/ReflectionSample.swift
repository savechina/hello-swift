struct User {
    let name: String
    var age: Int
    var email: String?
}

enum Status {
    case active
    case inactive
    case pending
}

func reflectionSample() {
    print("--- reflectionSample start ---")
    
    let user = User(name: "Alice", age: 30, email: "alice@example.com")
    
    let mirror = Mirror(reflecting: user)
    
    print("Type: \(mirror.displayStyle ?? .unknown)")
    print("Children count: \(mirror.children.count)")
    
    for child in mirror.children {
        if let label = child.label {
            print("  \(label): \(child.value)")
        }
    }
    
    let status = Status.active
    let statusMirror = Mirror(reflecting: status)
    print("Enum displayStyle: \(statusMirror.displayStyle ?? .unknown)")
    
    let tuple = (x: 10, y: 20)
    let tupleMirror = Mirror(reflecting: tuple)
    print("Tuple displayStyle: \(tupleMirror.displayStyle ?? .unknown)")
    for child in tupleMirror.children {
        if let label = child.label {
            print("  \(label): \(child.value)")
        }
    }
    
    let array = [1, 2, 3]
    let arrayMirror = Mirror(reflecting: array)
    print("Array displayStyle: \(arrayMirror.displayStyle ?? .unknown)")
    print("Array children: \(arrayMirror.children.count)")
    
    print("--- reflectionSample end ---")
}
