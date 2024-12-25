//
//  File.swift
//  hello-swift
//
//  Created by RenYan Wei on 2024/12/23.
//

import Foundation

public func collectionSample() {
    startSample(functionName: "DatatypeSample collectionSample")
    //array
    let array = [1, 2, 3, 4, 5, 6, 7, 8]

    var sum = Int32()

    for i in array {
        print("index:", i)
        sum = sum + Int32(i)
    }

    print("sum:", sum)

    var someInts: [Int] = []
    print("someInts is of type [Int] with \(someInts.count) items.")
    // Prints "someInts is of type [Int] with 0 items."

    someInts.append(3)

    print("array append after count: \(someInts.count) ")

    // someInts now contains 1 value of type Int
    someInts = []
    // someInts is now an empty array, but is still of type [Int]
    print("array reset after count: \(someInts.count) ")

    let threeDoubles = Array(repeating: 0.0, count: 3)
    // threeDoubles is of type [Double], and equals [0.0, 0.0, 0.0]

    let anotherThreeDoubles = Array(repeating: 2.5, count: 3)
    // anotherThreeDoubles is of type [Double], and equals [2.5, 2.5, 2.5]

    let sixDoubles = threeDoubles + anotherThreeDoubles
    // sixDoubles is inferred as [Double], and equals [0.0, 0.0, 0.0, 2.5, 2.5, 2.5]

    print("sixDoubles", sixDoubles)

    var shoppingList = ["Eggs", "Milk"]

    print("The shopping list contains \(shoppingList.count) items.")
    // Prints "The shopping list contains 2 items."

    if shoppingList.isEmpty {
        print("The shopping list is empty.")
    } else {
        print("The shopping list isn't empty.")
    }
    // Prints "The shopping list isn't empty."

    shoppingList.append("Flour")
    // shoppingList now contains 3 items, and someone is making pancakes

    shoppingList += ["Baking Powder"]
    // shoppingList now contains 4 items
    shoppingList += ["Chocolate Spread", "Cheese", "Butter"]
    // shoppingList now contains 7 items

    let firstItem = shoppingList[0]
    // firstItem is equal to "Eggs"
    print("firstItem:", firstItem)

    //    Iterating Over an Array
    for (index, value) in shoppingList.enumerated() {
        print("Item \(index + 1): \(value)")
    }
    // Item 1: Six eggs
    // Item 2: Milk
    // Item 3: Flour
    // Item 4: Baking Powder
    // Item 5: Bananas

    endSample(functionName: "DatatypeSample collectionSample")
}

public func setsSample() {

    startSample(functionName: "DatatypeSample setsSample")

    //Sets
    var letters = Set<Character>()
    print("letters is of type Set<Character> with \(letters.count) items.")

    letters.insert("a")
    // letters now contains 1 value of type Character
    //    letters = []
    // letters is now an empty set, but is still of type Set<Character>
    print(
        "letters is of type Set<Character> insert after with \(letters.count) items."
    )

    var favoriteGenres: Set = ["Rock", "Classical", "Hip hop"]

    if favoriteGenres.isEmpty {
        print("As far as music goes, I'm not picky.")
    } else {
        print("I have particular music preferences.")
    }
    // Prints "I have particular music preferences."

    for genre in favoriteGenres {
        print("\(genre)")
    }
    // Classical
    // Jazz
    // Hip hop

    if let removedGenre = favoriteGenres.remove("Rock") {
        print("\(removedGenre)? I'm over it.")
    } else {
        print("I never much cared for that.")
    }
    // Prints "Rock? I'm over it."

    //set operate
    let oddDigits: Set = [1, 3, 5, 7, 9]
    let evenDigits: Set = [0, 2, 4, 6, 8]
    let singleDigitPrimeNumbers: Set = [2, 3, 5, 7]
    print("oddDigits:", oddDigits)
    print("evenDigits:", evenDigits)
    print("singleDigitPrimeNumbers:", singleDigitPrimeNumbers)

    let a = oddDigits.union(evenDigits).sorted()
    print("union:", a)
    // [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    let b = oddDigits.intersection(evenDigits).sorted()
    print("intersection:", b)
    // []

    let c = oddDigits.subtracting(singleDigitPrimeNumbers).sorted()
    print("subtracting:", c)
    // [1, 9]
    let d = oddDigits.symmetricDifference(singleDigitPrimeNumbers).sorted()
    // [1, 2, 9]
    print("symmetricDifference:", d)

    endSample(functionName: "DatatypeSample setsSample")

}

public func dictionarySample() {
    startSample(functionName: "DatatypeSample dictionarySample")

    //map
    var namesOfIntegers: [Int: String] = [:]
    // namesOfIntegers is an empty [Int: String] dictionary
    namesOfIntegers[16] = "sixteen"
    print("Dictionary count:", namesOfIntegers.count)
    // namesOfIntegers now contains 1 key-value pair
    namesOfIntegers = [:]
    // namesOfIntegers is once again an empty dictionary of type [Int: String]
    print("Dictionary reset after count:", namesOfIntegers.count)

    //second dictionary
    let map = ["name": "John", "age": "18"]

    print("map:", map)

    print("map[name]=", map["name"]!)

    //airports dictionary
    var airports: [String: String] = [
        "YYZ": "Toronto Pearson", "DUB": "Dublin",
    ]

    print("The airports dictionary contains \(airports.count) items.")
    // Prints "The airports dictionary contains 2 items."

    if airports.isEmpty {
        print("The airports dictionary is empty.")
    } else {
        print("The airports dictionary isn't empty.")
    }
    // Prints "The airports dictionary isn't empty."

    airports["LHR"] = "London"
    // the airports dictionary now contains 3 items

    //    Iterating Over a Dictionary

    for (airportCode, airportName) in airports {
        print("\(airportCode): \(airportName)")
    }
    // LHR: London Heathrow
    // YYZ: Toronto Pearson

    for airportCode in airports.keys {
        print("Airport code: \(airportCode)")
    }
    // Airport code: LHR
    // Airport code: YYZ

    for airportName in airports.values {
        print("Airport name: \(airportName)")
    }
    // Airport name: London Heathrow
    // Airport name: Toronto Pearson

    endSample(functionName: "DatatypeSample dictionarySample")

}

public func subscriptSample() {
    startSample(functionName: "DatatypeSample subscriptSample")

    struct TimesTable {
        let multiplier: Int
        subscript(index: Int) -> Int {
            return multiplier * index
        }
    }
    let threeTimesTable = TimesTable(multiplier: 3)
    print("six times three is \(threeTimesTable[6])")
    // Prints "six times three is 18"

    //dictionary use subscript access item
    var numberOfLegs = ["spider": 8, "ant": 6, "cat": 4]
    numberOfLegs["bird"] = 2

    //Matrix
    var matrix = Matrix(rows: 2, columns: 2)
    print("matrix:", matrix)

    matrix[0, 1] = 1.5
    matrix[1, 0] = 3.2

    print("matrix new value:", matrix)

    // let someValue = matrix[2, 2]
    // open above comment.
    //    This triggers an assert, because [2, 2] is outside of the matrix bounds.

    //define Planet enum and use subscript
    enum Planet: Int {
        case mercury = 1
        case venus, earth, mars, jupiter, saturn, uranus, neptune
        static subscript(n: Int) -> Planet {
            return Planet(rawValue: n)!
        }
    }
    let mars = Planet[4]
    print(mars)

    endSample(functionName: "DatatypeSample subscriptSample")
}

/// compare min and max value in array
/// - Parameter array: array data
/// - Returns: an tuple arrary min and max value
func minMax(array: [Int]) -> (min: Int, max: Int) {
    var currentMin = array[0]
    var currentMax = array[0]
    for value in array[1..<array.count] {
        if value < currentMin {
            currentMin = value
        } else if value > currentMax {
            currentMax = value
        }
    }
    return (currentMin, currentMax)
}

/// Variadic Parameters
/// - Parameter numbers: numbers d
/// - Returns: avg result
func arithmeticMean(_ numbers: Double...) -> Double {
    var total: Double = 0
    for number in numbers {
        total += number
    }
    return total / Double(numbers.count)
}

/// greeting default
/// - Parameter person: person
/// - Returns: greeting context
func greeting(for person: String) -> String {
    "Hello, " + person + "!"
}

/// greeting implicitly return value
/// - Parameter person: person
/// - Returns: greeting context
func anotherGreeting(for person: String) -> String {
    return "Hello, " + person + "!"
}

///
/// an Nested Functions
/// - Parameter backward: is backward
/// - Returns: StepFunction. stepForward or stepBackward function
func chooseStepFunction(backward: Bool) -> (Int) -> Int {
    func stepForward(input: Int) -> Int { return input + 1 }
    func stepBackward(input: Int) -> Int { return input - 1 }

    return backward ? stepBackward : stepForward
}

/// functionSample
public func functionSample() {

    startSample(functionName: "DatatypeSample functionSample")

    //function multiple return value.
    let bounds = minMax(array: [8, -6, 2, 109, 3, 71])
    print("min is \(bounds.min) and max is \(bounds.max)")
    // Prints "min is -6 and max is 109"

    print("Variadic Parameters:")
    //    Variadic Parameters
    let ra = arithmeticMean(1, 2, 3, 4, 5)
    // returns 3.0, which is the arithmetic mean of these five numbers
    print(ra)
    let rb = arithmeticMean(3, 8.25, 18.75)
    // returns 10.0, which is the arithmetic mean of these three numbers
    print(rb)

    print(greeting(for: "Dave"))
    // Prints "Hello, Dave!"
    print(anotherGreeting(for: "Dave"))
    // Prints "Hello, Dave!"

    print(" Nested Functions:")
    //
    var currentValue = -4
    let moveNearerToZero = chooseStepFunction(backward: currentValue > 0)
    // moveNearerToZero now refers to the nested stepForward() function
    while currentValue != 0 {
        print("\(currentValue)... ")
        currentValue = moveNearerToZero(currentValue)
    }
    print("zero!")
    // -4...
    // -3...
    // -2...
    // -1...
    // zero!

    endSample(functionName: "DatatypeSample functionSample")

}


public func classSample() {
    startSample(functionName: "DatatypeSample classSample")

    //    nested type
    let theAceOfSpades = BlackjackCard(rank: .ace, suit: .spades)
    print("theAceOfSpades: \(theAceOfSpades.description)")
    // Prints "theAceOfSpades: suit is ♠, value is 1 or 11"

    let heartsSymbol = BlackjackCard.Suit.hearts.rawValue
    // heartsSymbol is "♡"
    print("heartsSymbol:", heartsSymbol)

    let rect = Rectangle(width: 10, height: 5)
    print("Rectangle area:", rect.area)  // 使用 getter，输出 50

    rect.area = 100  // 使用 setter，新的 area
    print("Rectangle height:", rect.height)  // 输出 10.0，计算得到的 height

    let circle = Circle(radius: 5)
    print("Circle area:", circle.area)  // 使用 getter，输出圆的面积
    
    //Class 继承 类型检查
    let library = [
        Movie(name: "Casablanca", director: "Michael Curtiz"),
        Song(name: "Blue Suede Shoes", artist: "Elvis Presley"),
        Movie(name: "Citizen Kane", director: "Orson Welles"),
        Song(name: "The One And Only", artist: "Chesney Hawkes"),
        Song(name: "Never Gonna Give You Up", artist: "Rick Astley")
    ]
    // the type of "library" is inferred to be [MediaItem]

    var movieCount = 0
    var songCount = 0


    for item in library {
        if item is Movie {
            movieCount += 1
        } else if item is Song {
            songCount += 1
        }
    }


    print("Media library contains \(movieCount) movies and \(songCount) songs")
    // Prints "Media library contains 2 movies and 3 songs"
    
    for item in library {
        if let movie = item as? Movie {
            print("Movie: \(movie.name), dir. \(movie.director)")
        } else if let song = item as? Song {
            print("Song: \(song.name), by \(song.artist)")
        }
    }

    // Movie: Casablanca, dir. Michael Curtiz
    // Song: Blue Suede Shoes, by Elvis Presley
    // Movie: Citizen Kane, dir. Orson Welles
    // Song: The One And Only, by Chesney Hawkes
    // Song: Never Gonna Give You Up, by Rick Astley
    
    endSample(functionName: "DatatypeSample classSample")

}

public func enumsSample() {
    startSample(functionName: "DatatypeSample enumsSample")
    
    //simple enum
    enum SampleType {
        case basicSample
        case advancedSample
    }

    // Example usage:

    let mySample = SampleType.basicSample

    switch mySample {
    case .basicSample:
        print("This is a basic sample.")
    case .advancedSample:
        print("This is an advanced sample.")
    }

    print(SampleType.advancedSample.hashValue)

    // You can also add associated values to your enums:

    enum SampleWithData {
        case basicSample(String)  // Basic sample with a description
        case advancedSample(Int, Double)  // Advanced sample with an ID and a value
    }

    let sample1 = SampleWithData.basicSample("Simple data processing")
    let sample2 = SampleWithData.advancedSample(123, 3.14159)

    switch sample1 {
    case .basicSample(let description):
        print("Basic sample: \(description)")
    case .advancedSample(let id, let value):
        print("Advanced sample: ID: \(id), Value: \(value)")
    }

    // or, for more concise syntax with Swift 5.7 and later:
    switch sample2 {
    case .basicSample(let description):
        print("Basic sample: \(description)")
    case let .advancedSample(id, value):
        print("Advanced sample: ID: \(id), Value: \(value)")
    }

    // Even more concise with pattern matching and value binding:
    switch sample2 {
    case .basicSample(let description):
        print("Basic sample: \(description)")
    case .advancedSample(let id, let value):  // labeled tuple pattern matching
        print("Advanced sample: ID: \(id), Value: \(value)")
    }

    //if you have specific needs for raw values (like for persistence)

    enum SampleWithRawValue: String, CaseIterable {
        case basicSample = "basic"
        case advancedSample = "advanced"
    }

    let rawValue = SampleWithRawValue.basicSample.rawValue  // "basic"
    let allCases = SampleWithRawValue.allCases  // [.basicSample, .advancedSample]

    if let sampleFromRaw = SampleWithRawValue(rawValue: "advanced") {
        print("Created sample from raw value: \(sampleFromRaw)")  //prints: Created sample from raw value: advancedSample
    }

    //For Integer raw values

    enum IntEnum: Int, CaseIterable {
        case one = 1
        case two = 2
        case three = 3
    }

    print(IntEnum.two.rawValue)  //prints 2

    //If you don't assign raw values, Swift will automatically assign them starting from 0 (if Int) or the case name(if String)

    enum ImplicitRawValues: Int, CaseIterable {
        case first  // 0
        case second  // 1
        case third  // 2
    }

    enum ImplicitStringRawValues: String, CaseIterable {
        case first  // "first"
        case second  // "second"
    }

    print(ImplicitRawValues.first.rawValue)  //prints 0
    print(ImplicitStringRawValues.second.rawValue)  //prints "second"

    endSample(functionName: "DatatypeSample enumsSample")
}
