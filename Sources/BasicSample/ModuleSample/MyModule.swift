//
//  MyModule..swift
//  hello-swift
//
//  Created by weirenyan on 2025/12/24.
//

import Foundation

//子目录作用：整理磁盘文件，不影响代码逻辑，也不提供命名空间

public enum MyModule {}  // 根空间

extension MyModule {
    public enum Model {
        public struct User {
            public static func get(_ name: String) { print("User \(name)") }
        }
    }
}
