//
//  AlgoSample.swift
//  hello-swift
//
//  Created by RenYan Wei on 2024/12/19.
//

import Algorithms
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

func calculatePiBBP(steps: Int) -> Double {
    // 使用 lazy 避免创建中间数组，直接进行归约计算
    let pi = (0..<steps).lazy.map { k -> Double in
        let kf = Double(k)
        // 16^-k
        let p16 = pow(16.0, -kf)
        // 修改点：使用 ldexp 替代 pow(16.0, -kf)
        // ldexp(1.0, x) 等价于 1.0 * 2^x
        // 16^-k 等价于 2^-(4*k)
        //let p16 = ldexp(1.0, -4 * k)

        return p16
            * (4.0 / (8.0 * kf + 1.0) - 2.0 / (8.0 * kf + 4.0) - 1.0
                / (8.0 * kf + 5.0) - 1.0 / (8.0 * kf + 6.0))
    }.reduce(0.0, +)

    return pi
}

public func calculatePiBBPNormal(steps: Int) -> Double {
    // 正常从 0 到 steps 迭代
    let pi = (0..<steps).reduce(0.0) { (currentSum, k) in
        let kf = Double(k)

        // 关键优化点：使用 ldexp(1.0, -4 * k) 替代 pow(16.0, -kf)
        // 16^-k 等于 2^-(4*k)。ldexp 直接在二进制位上修改指数，无精度损失。
        let p16 = scalbn(1.0, -4 * k)

        let term =
            p16
            * (4.0 / (8.0 * kf + 1.0) - 2.0 / (8.0 * kf + 4.0) - 1.0
                / (8.0 * kf + 5.0) - 1.0 / (8.0 * kf + 6.0))

        return currentSum + term
    }

    return pi
}

public func calculatePiDecimal(steps: Int) -> Decimal {
    var pi: Decimal = 0

    for k in 0..<steps {
        let k_d = Decimal(k)

        // 1. 计算 16^-k (即 1 / 16^k)
        let sixteen = Decimal(16)
        //        var p16: Decimal = 1
        //        for _ in 0..<k {
        //            p16 /= sixteen
        //        }
        let p16 = pow(sixteen, -k)

        // 2. 计算括号内的部分: [4/(8k+1) - 2/(8k+4) - 1/(8k+5) - 1/(8k+6)]
        let term1 = Decimal(4) / (Decimal(8) * k_d + 1)
        let term2 = Decimal(2) / (Decimal(8) * k_d + 4)
        let term3 = Decimal(1) / (Decimal(8) * k_d + 5)
        let term4 = Decimal(1) / (Decimal(8) * k_d + 6)

        let bracket = term1 - term2 - term3 - term4

        // 3. 累加
        pi += p16 * bracket
    }

    return pi
}

public func calculatePiSample() {
    // 使用样例
    let iterations = 1_000_000_000
    let result = calculatePi(steps: iterations)
    print("迭代 \(iterations) 次的结果: \(result)")
    print("系统标准 PI 值: \(Double.pi)")
}

public func calculatePiBBPSample() {
    // 使用样例
    let iterations = 11
    let result = calculatePiBBP(steps: iterations)
    print("迭代 \(iterations) 次的结果: \(result)")
    print("系统标准 PI 值: \(Double.pi)")
}

func calculatePiDecimalSample() {
    let steps = 35
    let result = calculatePiDecimal(steps: steps)

    print("迭代次数: \(steps)")
    print("计算结果: \(result)")
    print("系统标准: \(Decimal.pi)")
    print("是否相等: \(result == Decimal.pi)")
}
