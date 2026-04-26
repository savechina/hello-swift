# Hello Swift
 English | [简体中文](README_zh.md)

[**Hello Swift Tutorial**](https://renyan.org/hello/swift) | [**GitHub Pages**](https://savechina.github.io/hello-swift/)

A comprehensive sample project and tutorial for learning the Swift programming language, from basic syntax to advanced production-grade applications.

## 📖 Online Tutorial

- 🌐 **Official Tutorial**: [renyan.org/hello/swift](https://renyan.org/hello/swift)
- 📚 **GitHub Pages**: [savechina.github.io/hello-swift](https://savechina.github.io/hello-swift/)

## 🚀 Quick Start

```bash
# Clone the project
git clone https://github.com/savechina/hello-swift.git
cd hello-swift

# Build and run
swift run hello --help

# Run specific sample modules
swift run hello basic        # Basic Swift samples
swift run hello advance      # Advanced samples
swift run hello awesome      # Awesome samples
swift run hello algo         # Algorithm samples

# Run tests
swift test
```

## 📦 Project Modules

### Basic

Core Swift syntax and concepts for beginners:

| Module | Content |
|--------|---------|
| [Variables & Expressions](Docs/src/basic/basic.md) | Variable binding, mutability, operators, string interpolation |
| [Control Flow](Docs/src/basic/basic.md) | if/else, switch/case, for-in loops, range iteration |
| [Data Types](Docs/src/basic/basic.md) | Integers, floats, booleans, strings, arrays, sets, dictionaries |
| [Functions](Docs/src/basic/basic.md) | Function declaration, tuples, variadic parameters, nested functions, closures |
| [Enums](Docs/src/basic/basic.md) | Enum definitions, associated values, raw values, pattern matching |
| [Structs & Classes](Docs/src/basic/basic.md) | Struct/value types, class/reference types, inheritance, computed properties, subscripts |
| [Protocols](Docs/src/basic/basic.md) | Protocol definitions, class/struct extensions, protocol-oriented programming |
| [Access Control](Docs/src/basic/basic.md) | public, internal, fileprivate, private, open, extension visibility |
| [Generics](Docs/src/basic/basic.md) | Generic functions and types |
| [Error Handling](Docs/src/basic/basic.md) | Error types, do/catch/try patterns |
| [Concurrency](Docs/src/basic/basic.md) | async/await, actors, AsyncStream, withTaskGroup, Thread + semaphores |
| [Date/Time & UUID](Docs/src/basic/basic.md) | ContinuousClock, Date formatting, UUID v3/v4/v7 |
| [Logging](Docs/src/basic/basic.md) | os.Logger, swift-log, SwiftyBeaver integration |
| [Module System](Docs/src/basic/basic.md) | Extension-based namespace pattern (MyModule) |

### Advance

Deep dive into advanced Swift features and ecosystem:

| Module | Content |
|--------|---------|
| [JSON Processing](Docs/src/advance/advance.md) | JSONSerialization, JSONDecoder/Encoder, SwiftyJSON |
| [File Operations](Docs/src/advance/advance.md) | FileManager, temporary files, directory traversal |
| [System Services](Docs/src/advance/advance.md) | SystemConfiguration, network reachability, metrics |
| [Async Programming](Docs/src/advance/advance.md) | Task, async/await with SwiftNIO |
| [Environment Config](Docs/src/advance/advance.md) | swift-dotenv, .env file integration |

### Algorithm & Practice

| Module | Content |
|--------|---------|
| [Algorithms](Docs/src/getting-started.md) | Two Sum, Pi calculation (BigNum precision) |
| [LeetCode Solutions](Docs/src/getting-started.md) | LeetCode problem implementations |
| [Awesome Examples](Docs/src/awesome/awesome.md) | Third-party library integrations and tool demos |

## 🛠️ Tech Stack

- **Swift 6.0**
- **CLI**: swift-argument-parser
- **Algorithms**: swift-algorithms, swift-numerics, swift-bignum
- **Logging**: swift-log, SwiftyBeaver
- **Collections**: swift-collections
- **JSON/Data**: SwiftyJSON
- **Networking/Async**: swift-nio
- **Config**: swift-dotenv

## 📋 Project Structure

```
hello-swift/
├── Sources/
│   ├── HelloSample/          # @main CLI entry point (ArgumentParser)
│   ├── BasicSample/          # Core Swift fundamentals (12 files)
│   │   └── ModuleSample/     # Namespace pattern demo
│   └── AlgoSample/           # Algorithm implementations
├── Tests/
│   ├── HelloSampleTests/     # Integration tests
│   └── AlgoSampleTests/      # Algorithm tests
├── AdvanceSample/            # Nested SPM package (SwiftyJSON, swift-nio, dotenv)
├── AwesomeSample/            # Nested SPM package (third-party integrations)
├── LeetCodeSample/           # Nested SPM package (LeetCode solutions)
├── Docs/                     # mdBook tutorial documentation (Chinese)
├── Config/                   # Test resources
```

## 📝 License

MIT License
