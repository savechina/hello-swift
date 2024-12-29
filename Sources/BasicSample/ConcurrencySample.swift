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
    try await Task.sleep(nanoseconds: UInt64(Double.random(in: 0.5...1.5) * 1_000_000_000)) // 模拟耗时操作
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

    //创建异步任务
    Task {
        try await generateSlideshow(forGallery: "A Rainy Weekend")
    }

    // Async fetch user
    Task{
        await userSample()
    }
}
