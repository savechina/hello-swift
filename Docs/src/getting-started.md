# 快速开始

## 环境准备
- 安装 Swift 6.0+ 工具链：
  - macOS：通过 Xcode 16+ 安装（包含 Swift 6.0）
  - Linux/Windows：从 [Swift 官网](https://www.swift.org) 下载对应版本
- 安装 Git
- （可选）安装 [mdBook](https://rust-lang.github.io/mdBook/) 用于本地预览文档

## 克隆仓库
```bash
git clone https://github.com/savechina/hello-swift.git
cd hello-swift
```

## 构建项目
使用 Swift Package Manager 构建：
```bash
swift build
```

## 运行 CLI 工具
项目提供 `hello` 命令行工具（基于 swift-argument-parser）：
```bash
# 查看所有可用子命令
swift run hello --help

# 运行不同模块示例
swift run hello basic    # 基础 Swift 语法示例
swift run hello advance  # 高级 Swift 特性示例
swift run hello awesome  # 第三方库集成示例
swift run hello algo     # 算法示例
```

## 运行测试
```bash
swift test

# 运行指定测试模块
swift test --filter HelloSampleTests
```

## 本地预览文档
教程文档使用 mdBook 构建：
```bash
# 安装 mdBook（如果未安装）
cargo install mdbook

# 启动本地服务，访问 http://localhost:3000
mdbook serve Docs/
```

## 项目结构概览
```
hello-swift/
├── Sources/
│   ├── HelloSample/        # CLI 入口（@main，ArgumentParser）
│   ├── BasicSample/        # 12 个基础 Swift 语法示例
│   └── AlgoSample/         # 算法实现
├── AdvanceSample/           # 嵌套 SPM 包（SwiftyJSON、swift-nio、dotenv）
├── AwesomeSample/           # 嵌套 SPM 包（第三方集成示例）
├── LeetCodeSample/         # 嵌套 SPM 包（LeetCode 题解）
├── Docs/                   # mdBook 教程源码（Docs/src/）和生成结果（Docs/book/）
├── Tests/                  # XCTest 测试套件
└── Package.swift           # 根 SPM 配置（Swift 6.0）
```

## 下一步
- 阅读 [基础概述](./basic/basic-overview.md) 开始学习 Swift 语法
- 查看 [高级概述](./advance/advance-overview.md) 了解生产级 Swift 实践
- 探索 [实战精选](./awesome/awesome.md) 学习第三方库集成
