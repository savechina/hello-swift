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
    
    static func buildArray(_ components: [String]) -> String {
        components.joined(separator: "\n")
    }
}

func buildString(@StringBuilder builder: () -> String) -> String {
    builder()
}

func resultBuilderSample() {
    print("--- resultBuilderSample start ---")
    
    let result = buildString {
        "Line 1: Hello"
        "Line 2: World"
        "Line 3: Swift"
    }
    print("Built string:\n\(result)")
    
    let conditional = buildString {
        "Always included"
        if true {
            "Conditionally included"
        }
    }
    print("Conditional string:\n\(conditional)")
    
    let items = ["Apple", "Banana", "Cherry"]
    let list = buildString {
        for item in items {
            "- \(item)"
        }
    }
    print("List:\n\(list)")
    
    print("--- resultBuilderSample end ---")
}
