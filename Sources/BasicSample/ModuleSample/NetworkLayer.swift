//
//  NetworkLayer.swift
//  hello-swift
//
//  Created by weirenyan on 2025/12/24.
//
extension MyModule {
    public enum Network {
        public struct HTTP {
            public static func get(_ url: String) { print("Getting \(url)") }
        }
        public struct TCP {
            public static func connect() { print("Connecting...") }
        }
    }
}
