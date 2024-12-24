//
//  File.swift
//  hello-swift
//
//  Created by RenYan Wei on 2024/12/23.
//

import Foundation

public func collectionSample() {

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

}

public func setsSample() {
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

}

public func dictionarySample() {
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
}

public func subscriptSample() {
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

    //define Matrix
    struct Matrix {
        let rows: Int, columns: Int
        var grid: [Double]
        init(rows: Int, columns: Int) {
            self.rows = rows
            self.columns = columns
            grid = Array(repeating: 0.0, count: rows * columns)
        }
        func indexIsValid(row: Int, column: Int) -> Bool {
            return row >= 0 && row < rows && column >= 0 && column < columns
        }
        subscript(row: Int, column: Int) -> Double {
            get {
                assert(
                    indexIsValid(row: row, column: column), "Index out of range"
                )
                return grid[(row * columns) + column]
            }
            set {
                assert(
                    indexIsValid(row: row, column: column), "Index out of range"
                )
                grid[(row * columns) + column] = newValue
            }
        }
    }

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

}
