# Hello Swift
[English](README.md) | 简体中文

[**Hello Swift 教程**](https://renyan.org/hello/swift) | [**GitHub Pages**](https://savechina.github.io/hello-swift/)

一个全面的 Swift 编程语言示例项目和教程，从基础语法到高级生产级应用。

## 📖 在线教程

- 🌐 **官方教程**: [renyan.org/hello/swift](https://renyan.org/hello/swift)
- 📚 **GitHub Pages**: [savechina.github.io/hello-swift](https://savechina.github.io/hello-swift/)

## 🚀 快速开始

```bash
# 克隆项目
git clone https://github.com/savechina/hello-swift.git
cd hello-swift

# 构建并运行
swift run hello --help

# 运行指定的示例模块
swift run hello basic        # 基础 Swift 语法示例
swift run hello advance      # 高级 Swift 特性示例
swift run hello awesome      # 第三方库集成示例
swift run hello algo         # 算法示例

# 运行测试
swift test
```

## 📦 项目模块

### 基础部分 (Basic)

面向初学者的核心 Swift 语法和概念：

| 模块 | 内容 |
|------|------|
| [变量与表达式](Docs/src/basic/basic.md) | 变量绑定、不可变性、运算符、字符串插值 |
| [控制流](Docs/src/basic/basic.md) | if/else、switch/case、for-in 循环、范围迭代 |
| [数据类型](Docs/src/basic/basic.md) | 整数、浮点数、布尔值、字符串、数组、集合、字典 |
| [函数](Docs/src/basic/basic.md) | 函数声明、元组、可变参数、嵌套函数、闭包 |
| [枚举](Docs/src/basic/basic.md) | 枚举定义、关联值、原始值、模式匹配 |
| [结构体与类](Docs/src/basic/basic.md) | 值类型、引用类型、继承、计算属性、下标 |
| [协议](Docs/src/basic/basic.md) | 协议定义、类/结构体扩展、面向协议编程 |
| [访问控制](Docs/src/basic/basic.md) | public、internal、fileprivate、private、open、扩展可见性 |
| [泛型](Docs/src/basic/basic.md) | 泛型函数和类型 |
| [错误处理](Docs/src/basic/basic.md) | 错误类型、do/catch/try 模式 |
| [并发编程](Docs/src/basic/basic.md) | async/await、Actor、AsyncStream、withTaskGroup、Thread + 信号量 |
| [日期/时间与 UUID](Docs/src/basic/basic.md) | ContinuousClock、日期格式化、UUID v3/v4/v7 |
| [日志](Docs/src/basic/basic.md) | os.Logger、swift-log、SwiftyBeaver 集成 |
| [模块系统](Docs/src/basic/basic.md) | 基于扩展的命名空间模式 (MyModule) |

### 高级部分 (Advance)

深入探索高级 Swift 特性和生态系统：

| 模块 | 内容 |
|------|------|
| [JSON 处理](Docs/src/advance/advance.md) | JSONSerialization、JSONDecoder/Encoder、SwiftyJSON |
| [文件操作](Docs/src/advance/advance.md) | FileManager、临时文件、目录遍历 |
| [系统服务](Docs/src/advance/advance.md) | SystemConfiguration、网络可达性、指标 |
| [异步编程](Docs/src/advance/advance.md) | Task、async/await 与 SwiftNIO |
| [环境配置](Docs/src/advance/advance.md) | swift-dotenv、.env 文件集成 |

### 算法与实践

| 模块 | 内容 |
|------|------|
| [算法](Docs/src/getting-started.md) | Two Sum、Pi 计算（BigNum 精度） |
| [LeetCode 题解](Docs/src/getting-started.md) | LeetCode 问题实现 |
| [实战精选](Docs/src/awesome/awesome.md) | 第三方库集成和工具演示 |

## 🛠️ 技术栈

- **Swift 6.0**
- **CLI**: swift-argument-parser
- **算法**: swift-algorithms, swift-numerics, swift-bignum
- **日志**: swift-log, SwiftyBeaver
- **集合**: swift-collections
- **JSON/数据**: SwiftyJSON
- **网络/异步**: swift-nio
- **配置**: swift-dotenv

## 📋 项目结构

```
hello-swift/
├── Sources/
│   ├── HelloSample/          # @main CLI 入口 (ArgumentParser)
│   ├── BasicSample/          # 核心 Swift 基础 (12 个文件)
│   │   └── ModuleSample/     # 命名空间模式演示
│   └── AlgoSample/           # 算法实现
├── Tests/
│   ├── HelloSampleTests/     # 集成测试
│   └── AlgoSampleTests/      # 算法测试
├── AdvanceSample/            # 嵌套 SPM 包 (SwiftyJSON, swift-nio, dotenv)
├── AwesomeSample/            # 嵌套 SPM 包 (第三方集成)
├── LeetCodeSample/           # 嵌套 SPM 包 (LeetCode 题解)
├── Docs/                     # mdBook 教程文档 (中文)
├── Config/                   # 测试资源
```

## 📝 许可证

MIT License
