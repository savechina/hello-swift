//
//  ClassSample.swift
//  hello-swift
//
//  Created by RenYan Wei on 2024/12/25.
//

import Foundation

///define Matrix
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

/// MediaItem BaseClass
class MediaItem {
    var name: String
    init(name: String) {
        self.name = name
    }
}

/// Movie
class Movie: MediaItem {
    var director: String
    init(name: String, director: String) {
        self.director = director
        //调用父类构造函数
        super.init(name: name)
    }
}

/// Song
class Song: MediaItem {
    var artist: String
    init(name: String, artist: String) {
        self.artist = artist

        //调用父类构造函数
        super.init(name: name)
    }
}

///Base Shape class
class Shape {
    var description: String {
        "Shape"
    }

    var area: Double { 0.0 }
}

/// Rectangle subclass
class Rectangle: Shape {
    var width: Double
    var height: Double

    init(width: Double, height: Double) {

        self.width = width
        self.height = height
    }

    // 计算属性：area 的 getter
    override var area: Double {
        get {
            return width * height
        }
        set(newArea) {
            // 当设置 area 时，重新计算 width 和 height
            height = newArea / width
        }
    }

    override var description: String { "Rectangle" }
}

/// Circle subclass
class Circle: Shape {
    var radius: Double

    init(radius: Double) {
        self.radius = radius
    }

    // 只读计算属性
    override var area: Double {
        return .pi * radius * radius
    }

    override var description: String { "Rectangle" }
}

/// BlackjackCard and Nested Type structure
struct BlackjackCard {

    // nested Suit enumeration
    enum Suit: Character {
        case spades = "♠"
        case hearts = "♡"
        case diamonds = "♢"
        case clubs = "♣"
    }

    // nested Rank enumeration
    enum Rank: Int {
        case two = 2
        case three, four, five, six, seven, eight, nine, ten
        case jack, queen, king, ace
        struct Values {
            let first: Int, second: Int?
        }
        var values: Values {
            switch self {
            case .ace:
                return Values(first: 1, second: 11)
            case .jack, .queen, .king:
                return Values(first: 10, second: nil)
            default:
                return Values(first: self.rawValue, second: nil)
            }
        }
    }

    // BlackjackCard properties and methods
    let rank: Rank, suit: Suit
    var description: String {
        var output = "suit is \(suit.rawValue),"
        output += " value is \(rank.values.first)"
        if let second = rank.values.second {
            output += " or \(second)"
        }
        return output
    }
}
