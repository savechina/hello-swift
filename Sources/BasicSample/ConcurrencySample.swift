//
//  ConcurrencySample.swift
//  hello-swift
//
//  Created by RenYan Wei on 2024/12/29.
//

import Foundation

@available(macOS 13.0, *)
func listPhotos(inGallery name: String) async throws -> [String] {
    try await Task.sleep(for: .milliseconds(2))
    return ["IMG001", "IMG99", "IMG0404"]
}

@available(macOS 13.0, *)
func generateSlideshow(forGallery gallery: String) async throws {
    let photos = try await listPhotos(inGallery: gallery)

    for photo in photos {

        // ... render a few seconds of video for this photo ...
        await Task.yield()
        print("photo:", photo)
    }
}
@available(macOS 13.0, *)
func fetchUser(id: Int) async throws -> String {
    // 模拟网络请求
    try await Task.sleep(
        nanoseconds: UInt64(Double.random(in: 0.5...1.5) * 1_000_000_000))  // 模拟耗时操作
    return "User \(id)"
}

@available(macOS 13.0, *)
func userSample() async {
    async let user1 = fetchUser(id: 1)
    async let user2 = fetchUser(id: 2)
    async let user3 = fetchUser(id: 3)

    do {
        let users = try await [user1, user2, user3]
        print("Fetched users: \(users)")
    } catch {
        print("Error fetching users: \(error)")
    }
}

@available(macOS 13.0, *)
public func asyncTaskSample() throws {

    startSample(functionName: "ConcurrencySample asyncTaskSample")

    //创建异步任务
    Task {
        try await generateSlideshow(forGallery: "A Rainy Weekend")
    }

    // Async fetch user
    Task {
        await userSample()
    }

    Thread.sleep(forTimeInterval: 2)
    endSample(functionName: "ConcurrencySample asyncTaskSample")

}

public func simpleThreadSample() {

    startSample(functionName: "ConcurrencySample simpleThreadSample")

    // 创建并启动一个新线程
    let thread = Thread {
        print("Thread started")
        // 模拟耗时任务
        Thread.sleep(forTimeInterval: 2)
        print("Thread completed")
    }
    thread.start()

    //sleep await finish
    Thread.sleep(forTimeInterval: 2)

    // 使用信号量进行等待线程结束。
    // 创建一个信号量，初始值为0
    let semaphore = DispatchSemaphore(value: 0)

    // 创建并启动一个新线程
    let thread2 = Thread {
        print("Thread2 started")
        // 模拟耗时任务
        Thread.sleep(forTimeInterval: 2)
        print("Thread2 completed")
        // 任务完成后发送信号
        semaphore.signal()
    }

    // 启动线程
    thread2.start()

    // 等待线程完成
    semaphore.wait()

    print("Main thread: Thread has finished execution")

    // 创建并启动一个新线程
    let thread3 = Thread {
        print("Thread3 started")
        // 模拟耗时任务
        Thread.sleep(forTimeInterval: 2)
        print("Thread3 completed")
    }

    thread3.start()

    //使用 循环等待 线程结束
    while true {
        if thread3.isFinished {
            break
        }
        Thread.sleep(forTimeInterval: 2)
    }

    endSample(functionName: "ConcurrencySample simpleThreadSample")

}
