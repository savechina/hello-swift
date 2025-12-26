//
//  AlgoSample.swift
//  hello-swift
//
//  Created by RenYan Wei on 2024/12/19.
//

import Foundation
import Algorithms
import Numerics

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


/// 使用莱布尼茨公式计算 PI
/// - Parameter steps: 迭代次数，次数越多越精确
func calculatePi(steps: Int) -> Double {
    var piOverFour: Double = 0.0
    
    for n in 0..<steps {
        // 分母为 1, 3, 5, 7...
        let denominator = Double(2 * n + 1)
        // 符号交替发生变化
        if n % 2 == 0 {
            piOverFour += 1.0 / denominator
        } else {
            piOverFour -= 1.0 / denominator
        }
    }
    
    return piOverFour * 4.0
}


public func calculatePiSample(){
    // 使用样例
    let iterations = 10000_000_000
    let result = calculatePi(steps: iterations)
    print("迭代 \(iterations) 次的结果: \(result)")
    print("系统标准 PI 值: \(Double.pi)")
}
