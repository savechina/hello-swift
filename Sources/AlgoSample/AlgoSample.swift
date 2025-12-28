//
//  AlgoSample.swift
//  hello-swift
//
//  Created by RenYan Wei on 2024/12/19.
//

import Algorithms
import BigNum
import Foundation
import Numerics

//import BigInt

public func algoSample() {

    calculatePiSample()

    calculatePiBBPSample()

    calculatePiDecimalSample()
}

/// simple add ,calc two number sum
/// 计算二个数之和
/// - Parameters:
///   - x: one x int
///   - y: two y int
/// - Returns: sum , x and y
public func AddTwo(x: Int, y: Int) -> Int {
    //计算两个数的和
    let z = x + y

    return z
}

/// 计算三个数之和
///
///
/// - Parameters:
///   - x: x one
///   - y: y two
///   - z: z three
/// - Returns: sum 计算结果
public func AddThree(x: Int, y: Int, z: Int) -> Int {
    //计算三个数的和
    let n = x + y + z

    return n
}

public func AddThreeNumber(x: Int, y: Int, z: Int) -> Int {
    return 0
}

/// numeric multiply
/// - Parameters:
///   - a: a number
///   - b: b number
/// - Returns: result two number multiply sum
public func multiply<T: Numeric>(_ a: T, _ b: T) -> T {
    return a * b
}

