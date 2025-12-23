import Foundation

/// Early Exit Sample
public func earlyExitSample() {
    startSample(functionName: "ExpressionSample earlyExitSample")
    //use guard check name is nil return
    func greet(person: [String: String]) {
        guard let name = person["name"] else {
            return
        }

        print("Hello \(name)!")

        guard let location = person["location"] else {
            print("I hope the weather is nice near you.")
            return
        }

        print("I hope the weather is nice in \(location).")
    }

    greet(person: [:])
    //return
    greet(person: ["name": "John"])
    // Prints "Hello John!"
    // Prints "I hope the weather is nice near you."
    greet(person: ["name": "Jane", "location": "Cupertino"])
    // Prints "Hello Jane!"
    // Prints "I hope the weather is nice in Cupertino."

    endSample(functionName: "ExpressionSample earlyExitSample")
}

/// defer statement sample
public func deferSample() {
    startSample(functionName: "ExpressionSample deferSample")

    func f(x: Int) {
        defer { print("First defer") }

        if x < 10 {
            defer { print("Second defer") }
            print("End of if")
        }

        print("End of function")
    }

    f(x: 5)

    // Prints "End of if".
    // Prints "Second defer".
    // Prints "End of function".
    // Prints "First defer".

    var score = 1
    if score < 10 {
        defer {
            print(score)
        }
        score += 5
    }
    // Prints "6".

    endSample(functionName: "ExpressionSample deferSample")
}

/// Checking API Availability Sample
public func availabilitySample() {
    startSample(functionName: "ExpressionSample availabilitySample")

    if #available(iOS 10, macOS 10.12, *) {
        // Use iOS 10 APIs on iOS, and use macOS 10.12 APIs on macOS
    } else {
        // Fall back to earlier iOS and macOS APIs
    }

    @available(macOS 10.12, *)
    struct ColorPreference {
        var bestColor = "blue"
    }

    func chooseBestColor() -> String {
        guard #available(macOS 10.12, *) else {
            return "gray"
        }
        let colors = ColorPreference()
        return colors.bestColor
    }

    let color = chooseBestColor()

    print("choose color: \(color)")

    endSample(functionName: "ExpressionSample availabilitySample")

}
