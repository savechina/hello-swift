# Swift 术语表

本表汇总基础部分所有英文术语及对应的中文翻译。

## 基础语法

| English                  | 中文         | 说明                                             |
| ------------------------ | ------------ | ------------------------------------------------ |
| Constant                 | 常量         | 使用 `let` 声明，不可修改                          |
| Variable                 | 变量         | 使用 `var` 声明，可以修改                          |
| Type Inference           | 类型推断     | 编译器自动判断变量类型                             |
| String Interpolation     | 字符串插值   | 在字符串中嵌入表达式 `\(...)`                     |
| Shadowing                | 遮蔽         | 在嵌套作用域重新声明同名变量                       |

## 数据类型

| English                  | 中文         | 说明                                             |
| ------------------------ | ------------ | ------------------------------------------------ |
| Optional                 | 可选类型     | 用 `?` 表示，值可为空（nil）                       |
| Optional Binding         | 可选绑定     | 使用 `if let` 安全解包                             |
| Array                    | 数组         | 有序集合，允许重复                                 |
| Set                      | 集合         | 无序集合，不允许重复                               |
| Dictionary               | 字典         | 键值对集合                                         |
| Tuple                    | 元组         | 组合多个值为一个复合值                             |

## 控制流

| English                  | 中文         | 说明                                             |
| ------------------------ | ------------ | ------------------------------------------------ |
| Condition                | 条件         | if/else 中的布尔表达式                             |
| Exhaustive               | 穷举         | switch 必须覆盖所有可能情况                        |
| Pattern Matching         | 模式匹配     | 在 switch/case 中匹配值的结构                      |
| Guard Statement          | Guard 语句   | 用于提前退出，条件不满足时执行                     |

## 函数与闭包

| English                  | 中文         | 说明                                             |
| ------------------------ | ------------ | ------------------------------------------------ |
| Parameter Label          | 参数标签     | 调用时使用的参数名称                               |
| Variadic Parameter       | 可变参数     | 接受零个或多个相同类型的值                         |
| Inout Parameter          | 输入输出参数 | 允许函数修改传入的参数                             |
| Closure                  | 闭包         | 可以捕获上下文的匿名函数                           |
| Escaping Closure         | 逃逸闭包     | 在函数返回后仍被调用的闭包（@escaping）             |
| Trailing Closure         | 尾随闭包     | 函数最后一个参数为闭包时的简化语法                 |

## 类型系统

| English                  | 中文         | 说明                                             |
| ------------------------ | ------------ | ------------------------------------------------ |
| Value Type               | 值类型       | 赋值时复制（Struct, Enum, Tuple）                  |
| Reference Type           | 引用类型     | 赋值时引用同一对象（Class）                        |
| Property Observer        | 属性观察器   | willSet / didSet，在属性修改前后执行               |
| Mutating Method          | 可变方法     | 值类型中修改自身属性的方法                         |
| Inheritance              | 继承         | 子类获得父类的属性和方法                           |
| ARC                      | 自动引用计数 | Automatic Reference Counting，自动管理内存         |
| Weak Reference           | 弱引用       | 不增加引用计数的引用                               |

## 协议与泛型

| English                  | 中文         | 说明                                             |
| ------------------------ | ------------ | ------------------------------------------------ |
| Protocol                 | 协议         | 定义接口规范，类型必须实现                         |
| Protocol Extension       | 协议扩展     | 为协议提供默认实现                               |
| Associated Type          | 关联类型     | 在协议中定义的占位类型                             |
| Protocol Composition     | 协议组合     | 同时遵循多个协议（`ProtocolA & ProtocolB`）       |
| Opaque Type              | 不透明类型   | 使用 `some` 隐藏具体类型                           |
| Generic                  | 泛型         | 编写可适用于多种类型的代码                         |
| Type Constraint          | 类型约束     | 限制泛型参数必须遵循的协议或基类                   |
| Where Clause             | Where 子句   | 定义额外的类型约束条件                             |

## 错误处理

| English                  | 中文         | 说明                                             |
| ------------------------ | ------------ | ------------------------------------------------ |
| Throwing Function        | 抛出函数     | 使用 `throws` 标记的函数                           |
| Defer Block              | 延迟执行块   | 在作用域退出时执行                                 |
| Result Type              | 结果类型     | 用 `enum Result<Success, Failure>` 包装结果        |
| Catch                    | 捕获         | 处理抛出的错误                                     |

## 并发编程

| English                  | 中文         | 说明                                             |
| ------------------------ | ------------ | ------------------------------------------------ |
| Async/Await              | 异步/等待    | Swift 语言级并发语法                               |
| Task                     | 任务         | 异步执行单元                                       |
| TaskGroup                | 任务组       | 动态创建的并发任务集合                             |
| Actor                    | 参与者       | 保护共享状态免受数据竞争的引用类型                 |
| Actor Isolation          | 参与者隔离   | 确保对 Actor 内部状态的访问是串行的                 |
| Main Actor               | 主参与者     | 与主线程关联的 Actor（@MainActor）                |
| Sendable                 | 可发送       | 可安全跨越并发边界的类型协议                       |
| Data Race                | 数据竞争     | 多个线程同时访问共享数据且至少一个在写入           |
| Strict Concurrency       | 严格并发     | Swift 6.0 引入的编译时数据竞争检测                 |
| AsyncSequence            | 异步序列     | 异步生成元素的序列                                   |

---

**说明**: 术语翻译参考 Apple 官方 Swift 中文文档和社区通用译法。
