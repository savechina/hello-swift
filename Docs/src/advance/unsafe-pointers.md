# Unsafe Pointers (不安全指针)

## 开篇故事

想象你在银行工作。通常，你通过柜员（Swift 的安全 API）存取款——安全、有记录、不会出错。但有时你需要进入金库（Unsafe Pointer）直接操作现金——更快、更灵活，但如果操作不当，可能丢失金钱或触发警报。

Swift 的 Unsafe Pointer 就是金库钥匙：强大但危险，只在必要时使用。

## 本章适合谁

- 需要与 C API 交互的 Swift 开发者
- 追求极致性能的系统级程序员
- 想理解 Swift 内存模型底层的工程师

## 你会学到什么

- `UnsafePointer`、`UnsafeMutablePointer`、`UnsafeRawPointer` 的区别
- `MemoryLayout` 获取类型大小和对齐
- 使用 `withUnsafeBufferPointer` 安全地临时访问指针
- C 函数互操作的指针传递

## 前置要求

- macOS 12+ / Linux
- Swift 6.0+
- 已完成系统编程章节

## 第一个例子

```swift
var array: [Int] = [10, 20, 30, 40, 50]

// 安全地临时访问指针
array.withUnsafeBufferPointer { buffer in
    guard let base = buffer.baseAddress else { return }
    print("First element: \(base.pointee)")  // 10
    
    var sum = 0
    for i in 0..<buffer.count {
        sum += buffer[i]
    }
    print("Sum: \(sum)")  // 150
}
```

## 原理解析

### 指针类型家族

| 类型 | 可变性 | 类型安全 | 用途 |
|------|--------|----------|------|
| `UnsafePointer<T>` | 只读 | 是 | 读取已知类型数据 |
| `UnsafeMutablePointer<T>` | 读写 | 是 | 修改已知类型数据 |
| `UnsafeRawPointer` | 只读 | 否 | 操作原始内存字节 |
| `UnsafeMutableRawPointer` | 读写 | 否 | 分配和操作原始内存 |

### 安全访问模式

Swift 提供 `withUnsafe...` 系列方法，确保指针只在闭包作用域内有效：

```swift
var value: Int32 = 42
withUnsafePointer(to: &value) { ptr in
    print("Value: \(ptr.pointee)")
}
// ptr 在此处失效，不能再使用
```

### MemoryLayout

```swift
print("Int size: \(MemoryLayout<Int>.size)")      // 8 bytes (64-bit)
print("Int stride: \(MemoryLayout<Int>.stride)")  // 8 bytes (对齐后)
print("Int alignment: \(MemoryLayout<Int>.alignment)")  // 8 bytes

struct Point {
    var x: Double
    var y: Double
}
print("Point size: \(MemoryLayout<Point>.size)")  // 16 bytes
```

- **size**：实际数据大小
- **stride**：数组中元素的间距（含填充）
- **alignment**：内存对齐要求

## 常见错误

| 错误 | 原因 | 解决方案 |
|------|------|----------|
| `EXC_BAD_ACCESS` | 访问已释放或无效内存 | 确保指针在作用域内有效 |
| `unaligned access` | 访问未对齐的内存地址 | 使用 `assumingMemoryBound(to:)` 正确绑定类型 |
| 内存泄漏 | `allocate` 后未 `deallocate` | 使用 `defer { ptr.deallocate() }` |

## Swift vs Rust/Python 对比

| Swift | Rust | Python |
|-------|------|--------|
| `UnsafePointer<T>` | `*const T` | `ctypes.POINTER` |
| `UnsafeMutablePointer<T>` | `*mut T` | `ctypes.pointer` |
| `withUnsafePointer` | 不安全块（unsafe block） | 无直接等价 |
| 手动管理 | 手动管理（但编译器检查） | GC 自动管理 |

## 动手练习 Level 1

使用 `withUnsafePointer` 获取一个 `Double` 变量的地址，并打印其值。

```swift
var temperature: Double = 36.6
// 你的代码：使用 withUnsafePointer 打印 temperature
```

## 动手练习 Level 2

编写一个函数 `sumArray(_ array: [Int]) -> Int`，使用 `withUnsafeBufferPointer` 和指针运算计算数组总和（不使用 for-in 循环）。

```swift
func sumArray(_ array: [Int]) -> Int {
    // 使用 baseAddress 和指针运算
}
```

## 动手练习 Level 3

实现一个简单的内存分配器：使用 `UnsafeMutableRawPointer.allocate` 分配内存，写入一个 `Int32` 值，读取后释放。

<details>
<summary>点击查看答案</summary>

```swift
func memoryAllocSample() {
    let ptr = UnsafeMutableRawPointer.allocate(
        byteCount: MemoryLayout<Int32>.size,
        alignment: MemoryLayout<Int32>.alignment
    )
    defer { ptr.deallocate() }
    
    // 绑定类型并写入
    let typedPtr = ptr.bindMemory(to: Int32.self, capacity: 1)
    typedPtr.pointee = 42
    
    // 读取
    print("Allocated value: \(typedPtr.pointee)")
}

memoryAllocSample()
```

</details>

## 故障排查 FAQ

**Q: 什么时候必须用 Unsafe Pointer？**
A: 调用 C 函数（如 `memcpy`、`fread`）、性能关键的 tight loop、自定义内存分配器。

**Q: `withUnsafePointer` 和直接取地址有什么区别？**
A: Swift 没有 `&variable` 取地址语法。`withUnsafePointer` 是唯一的临时获取指针的方式，且保证作用域安全。

**Q: 指针在闭包外还能用吗？**
A: 不能。`withUnsafePointer` 返回后指针失效。存储指针到外部变量会导致悬垂指针（dangling pointer）。

**Q: `bindMemory` 和 `assumingMemoryBound` 有什么区别？**
A: `bindMemory` 改变内存的类型绑定（原始内存 → 类型化内存）；`assumingMemoryBound` 假设内存已经绑定到某类型（不改变绑定）。

**Q: Unsafe Pointer 在 Linux 上行为一致吗？**
A: 基本一致。但注意对齐要求可能因平台而异（ARM vs x86_64）。

## 小结

- Unsafe Pointer 提供底层内存访问能力，适用于 C 互操作和性能优化
- 始终优先使用 `withUnsafe...` 安全访问模式
- `MemoryLayout` 是理解类型内存布局的关键工具
- 指针操作必须手动管理生命周期，避免内存泄漏和悬垂指针

## 术语表

| 中文 | 英文 | 说明 |
|------|------|------|
| 不安全指针 | Unsafe Pointer | 绕过 Swift 类型安全检查的指针 |
| 内存布局 | Memory Layout | 类型在内存中的大小、间距、对齐 |
| 类型绑定 | Type Binding | 将原始内存关联到具体类型 |
| 悬垂指针 | Dangling Pointer | 指向已释放内存的指针 |
| 内存泄漏 | Memory Leak | 分配的内存未被释放 |

## 知识检查

1. `withUnsafeBufferPointer` 和 `withUnsafePointer` 的使用场景有什么区别？
2. 为什么 `stride` 可能大于 `size`？
3. `bindMemory(to:capacity:)` 和 `assumingMemoryBound(to:)` 何时选择哪一个？

<details>
<summary>点击查看答案与解析</summary>

1. `withUnsafeBufferPointer` 用于数组/集合，提供 `baseAddress` 和 `count`；`withUnsafePointer` 用于单个变量。
2. 当类型需要内存对齐时，stride 会包含填充字节。例如 `struct { UInt8; Int64 }` 的 size 是 9，但 stride 是 16（8 字节对齐）。
3. 内存是原始分配的（`UnsafeMutableRawPointer.allocate`）时用 `bindMemory`；内存已经绑定到某类型但需要临时以另一类型访问时用 `assumingMemoryBound`。

</details>

## 继续学习

**下一章**: [Swift Macros](macros.md) — 编译时代码生成

**返回**: [Advance 概览](advance-overview.md)
