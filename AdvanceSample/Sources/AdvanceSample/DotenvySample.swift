//
//  DotEnvySample.swift
//  AdvanceSample
//
//  Created by weirenyan on 2025/12/25.
//
import Foundation
import SwiftDotenv

public func processInfoEnvSample() {
    JSONDecoder()

    
    startSample(functionName: "DotenvySample processInfoEnvSample")

    if let path = ProcessInfo.processInfo.environment["PATH"] {
        print("系统 PATH 变量: \(path)")
    } else {
        print("未找到该环境变量")
    }

    let allEnv = ProcessInfo.processInfo.environment
    for (key, value) in allEnv {
        print("\(key): \(value)")
    }

    endSample(functionName: "DotenvySample processInfoEnvSample")
}

public func dotenvSample() {
    startSample(functionName: "DotenvySample dotenvSample")
    do {
        // load in environment variables
        try Dotenv.configure()
    } catch {
        print("can't load .env config")
    }
    // access values
    print(Dotenv.apiKey)

    let key = Dotenv.apiKey  // using dynamic member lookup
    //    let key = Dotenv["API_KEY"]  // using regular subscripting

    print(".env : apiKey: \(key?.stringValue)")

    Dotenv.apiKey = .string("some-secret")
    Dotenv["API_KEY"] = .string("some-secret")

    print(".env : apiKey: \(Dotenv.apiKey)")

    // 1. 加载并获取字典
    let env = try Dotenv.values
    print(".env all env values: \(env)")

    endSample(functionName: "DotenvySample dotenvSample")
}
