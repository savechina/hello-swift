# JSON 处理

## 开篇故事

想象你在一家国际餐厅点菜。菜单用法语写的，你对法语一窍不通。这时你掏出手机，用一个翻译 App 拍照扫描，屏幕上立刻显示出中文翻译。你终于知道自己点的是香煎鳕鱼还是炸薯条了。

JSON 在互联网世界里扮演的就是这个翻译角色。后端用 Python 写，前端用 JavaScript 跑，移动端用 Swift 开发。大家语言不同，但都能看懂 JSON。它就是把数据从"一种语言"翻译成"另一种语言"的那个 Universal Translator。

本章要教你的，就是如何用 Swift 读写这份"世界通用菜单"。

## 本章适合谁

如果你满足以下任一情况，这一章就是为你准备的：

- 你需要从网络 API 获取数据，而这些数据的格式是 JSON
- 你听说过 Codable 但不太确定怎么用
- 你曾经被 `try!` 坑过，想要知道更好的写法
- 你想知道 SwiftyJSON 到底好在哪里，是不是有必要引入

本章面向已经会写基础 Swift 语法的开发者。你不需要是高手，只要知道怎么声明变量、写个函数就行。

## 你会学到什么

完成本章后，你将掌握以下内容：

- **JSONSerialization**（Foundation 原生方法）：把 JSON 字符串转成字典和数组
- **JSONDecoder + Codable**（类型安全方式）：把 JSON 直接映射到 Swift 结构体
- **SwiftyJSON**（第三方库方式）：用链式语法访问嵌套 JSON，不必提前定义模型
- **CodingKeys**（键名映射）：当后端返回的字段名和你的 Swift 命名规范不一致时如何处理
- **常见陷阱**：如何避免 `try!` 导致的崩溃，如何处理可选字段，如何应对键名不匹配

## 前置要求

在开始之前，请确保你已掌握以下内容：

- Swift 基础语法：变量声明、函数定义、结构体（Struct）
- 错误处理：`do`、`catch`、`try` 的基本用法
- 集合类型：理解 Dictionary 和 Array 的区别
- 可选类型（Optional）：知道 `?` 和 `!` 的含义

如果你对这些内容还不太熟悉，建议先回顾基础部分（变量与表达式 → 错误处理），然后再回来。

## 第一个例子

我们先来看一个最基础的例子。目标很明确：从一个 JSON 字符串里提取出用户的名字和年龄。

这段代码来自 `AdvanceSample/Sources/AdvanceSample/AdvanceSample.swift` 第 54 到 75 行。

```swift
// 1. 定义一个和 JSON 键名匹配的结构体
struct User: Codable {
    let name: String
    let age: Int
}

let jsonContext = "{\"name\":\"John\", \"age\":30}"

// 2. 把 String 转成 Data
if let jsonData = jsonContext.data(using: .utf8) {
    let decoder = JSONDecoder()

    do {
        // 3. 把 Data 解码成 User 结构体
        let user = try decoder.decode(User.self, from: jsonData)

        print("Name: \(user.name)")  // 输出: John
        print("Age: \(user.age)")   // 输出: 30
    } catch {
        print("Error decoding JSON: \(error)")
    }
}
```

三步搞定：定义模型、转成 Data、调用 JSONDecoder.decode。Swift 通过 `Codable` 协议自动处理了映射逻辑，你不需要手写解析代码。

## 原理解析

Swift 提供了三种处理 JSON 的方式，各有优劣。

**方式一：JSONSerialization（Foundation 原生）**

这是最老派的做法。它把 JSON 字符串解析成一个 `[String: Any]` 字典。问题在于 `Any` 类型，你需要手动做类型转换，编译器帮不到你。

```swift
let json = try JSONSerialization.jsonObject(
    with: jsonString.data(using: .utf8)!,
    options: .allowFragments
)
// json 是 Any 类型，需要用 as? 做类型转换
if let dict = json as? [String: Any] {
    let name = dict["name"] as? String
}
```

优点：不需要提前定义任何模型，适合结构不明的 JSON。
缺点：类型不安全，运行时才知道哪里出问题。

**方式二：JSONDecoder + Codable（类型安全）**

这是 Swift 推荐的主流做法。你定义一个遵守 `Codable` 的结构体，`JSONDecoder` 自动帮你做映射。编译器会在编译期就检查字段是否匹配。

```swift
struct User: Codable {
    let name: String
    let age: Int
}
let user = try JSONDecoder().decode(User.self, from: jsonData)
```

优点：编译期检查，类型安全，代码简洁。
缺点：需要为每种 JSON 结构定义对应的模型。

**方式三：SwiftyJSON（第三方库）**

SwiftyJSON 用链式语法让你直接访问嵌套字段，不需要定义模型。

```swift
let result = try JSON(data: jsonData)
let name = result["name"].stringValue
let age = result["age"].intValue
```

优点：访问嵌套 JSON 时语法非常直观，`result["user"]["profile"]["bio"]` 这样一路点下去就行。
缺点：引入了一个额外的依赖包，类型检查依然不在编译期。

对比来看：日常开发用 Codable 就够了，后端字段经常变动的场景下 SwiftyJSON 更灵活。

## 常见错误

以下是最容易踩到的三个坑。

**错误一：滥用 `try!`**

在 `AdvanceSample.swift` 原文里，第 44 行和第 85 行都用了 `try!`。这在教程代码里没问题，但在真实项目里是定时炸弹。JSON 格式一旦和预期不符，程序直接崩溃。

```swift
// 危险写法
let json = try! JSONSerialization.jsonObject(with: data, options: [])

// 安全写法
do {
    let json = try JSONSerialization.jsonObject(with: data, options: [])
} catch {
    print("解析失败: \(error.localizedDescription)")
}
```

**错误二：忘了定义 CodingKeys**

后端返回的字段叫 `user_name`，你的 Swift 结构体里定义的是 `userName`。如果不做映射，解码会失败。

```swift
struct User: Codable {
    let userName: String

    enum CodingKeys: String, CodingKey {
        case userName = "user_name"
    }
}
```

**错误三：可选字段处理不当**

后端某些字段可能不传值。如果你把类型定义为非可选的 `String`，缺失该字段时解码会报错。

```swift
// 后端可能不传 bio 字段
struct User: Codable {
    let name: String
    let bio: String?  // 用可选类型，而不是非可选
}
```

## Swift vs Rust/Python 对比

不同语言都有自己的 JSON 处理方式，放在一起对比会更有感觉：

| 特性 | Swift (Codable) | Rust (serde) | Python (json) |
|---|---|---|---|
| 声明方式 | `struct User: Codable` | `#[derive(Serialize, Deserialize)]` | 没有类型声明 |
| 类型安全 | 编译期检查 | 编译期检查 | 运行期检查 |
| 键名映射 | `CodingKeys` 枚举 | `#[serde(rename = "...")]` | 手动用字典键访问 |
| 可选字段 | `let bio: String?` | `Option<String>` | 永远需要 `get()` 或 `in` 判断|
| 嵌套访问 | 需要嵌套模型或 SwiftyJSON | `user.profile.bio` | `data["user"]["profile"]["bio"]` |
| 错误处理 | `do/catch` | `Result<T, E>` | `try/except` |

Swift 的 Codable 和 Rust 的 serde 在思路上非常相似，都是通过派生（derive）或协议遵守（conform）来自动生成序列化代码。Python 的做法更灵活但更脆弱，所有检查都推迟到了运行期。

## 动手练习 Level 1

**目标**：用 JSONDecoder 解析一个简单的 JSON 对象。

假设你收到这样一段 JSON，里面是一本书的信息：

```json
{"title": "Swift 编程指南", "year": 2024, "author": "李白"}
```

你的任务是：

1. 定义一个 `Book` 结构体，遵守 `Codable`
2. 声明三个属性：`title`、`year`、`author`
3. 用 `JSONDecoder` 把上面的 JSON 解析成 `Book` 实例
4. 在控制台打印书名和作者

<details>
<summary>点击查看答案</summary>

```swift
struct Book: Codable {
    let title: String
    let year: Int
    let author: String
}

let json = """
{"title": "Swift 编程指南", "year": 2024, "author": "李白"}
"""

if let data = json.data(using: .utf8) {
    let book = try JSONDecoder().decode(Book.self, from: data)
    print("书名: \(book.title), 作者: \(book.author)")
}
```
</details>

## 动手练习 Level 2

**目标**：解析带嵌套结构的 JSON，并用 CodingKeys 处理命名不一致。

假设后端返回的 JSON 是这样的：

```json
{
    "user_name": "张三",
    "user_age": 28,
    "profile_pic": "https://example.com/photo.jpg"
}
```

但你想在 Swift 里使用驼峰命名（`userName`、`userAge`、`profilePic`），怎么做？

<details>
<summary>点击查看答案</summary>

```swift
struct UserProfile: Codable {
    let userName: String
    let userAge: Int
    let profilePic: String?

    enum CodingKeys: String, CodingKey {
        case userName = "user_name"
        case userAge = "user_age"
        case profilePic = "profile_pic"
    }
}
```

`profilePic` 定义为可选类型，因为有些用户可能没有设置头像，后端不会返回这个字段。
</details>

## 动手练习 Level 3

**目标**：使用 SwiftyJSON 动态访问一个多级嵌套的 JSON。

现在后端返回的数据比较复杂：

```json
{
    "company": "Acme",
    "employees": [
        {
            "name": "Alice",
            "skills": ["Swift", "Rust"]
        },
        {
            "name": "Bob",
            "skills": ["Python"]
        }
    ]
}
```

用 SwiftyJSON 提取第一个员工的第二个技能（结果是 "Rust"）。

<details>
<summary>点击查看答案</summary>

```swift
let json = try JSON(data: jsonData)
// 链式访问：先取 employees 数组，再取索引 0 的对象，再取 skills 数组的索引 1
let skill = json["employees"][0]["skills"][1].stringValue
print(skill)  // 输出: Rust
```

SwiftyJSON 的好处是，即使某个路径不存在，它只会返回空值而不会崩溃。这也是 SwiftyJSON 最大的卖点。
</details>

## 故障排查 FAQ

**Q1：解码时报 `keyNotFound` 错误怎么办？**

这说明 JSON 里的某个字段在你的模型中是非可选类型，但 JSON 里缺失了这个键。把该字段改成可选类型（加 `?`）或者在 JSON 中补充缺失的字段即可。

**Q2：解码时报 `typeMismatch` 错误怎么办？**

JSON 里的值和 Swift 类型对不上。比如后端返回 `"age": "30"`（字符串），而你的模型定义 `let age: Int`。检查实际 JSON 数据的类型，或在模型中使用 `String`。

**Q3：`try!` 导致程序崩溃，怎么快速修复？**

把 `try!` 改成 `do { try ... } catch { ... }`，包裹在 error handling 块内，让错误有机会被捕获。

**Q4：后端返回的字段名和我的 Swift 规范不一致怎么办？**

使用 `CodingKeys` 枚举做映射。枚举名用你的 Swift 命名，raw value 用后端的字段名。

**Q5：一段 JSON 不确定结构，该用哪种方式？**

先试 `JSONSerialization`，它返回 `[String: Any]`，你可以先用 `print` 查看结构，然后再决定要不要定义正式的 Codable 模型。

**Q6：SwiftyJSON 和 Codable 能混用吗？**

不太建议。SwiftyJSON 的设计思想是"不定义模型直接用"，Codable 的设计思想是"提前定义模型"。混用会让代码意图混乱。在同一个功能里选一种方式即可。

## 小结

- JSON 是跨语言的事实标准，Swift 提供了三种方式来处理它
- `JSONSerialization` 返回任意类型，最灵活但不安全
- `JSONDecoder` + `Codable` 是推荐方式，类型安全，编译期检查
- SwiftyJSON 擅长处理嵌套结构，用链式语法直接访问深层字段
- 永远不要用 `try!` 处理不可信的外部数据，用 `do/catch` 包裹

## 术语表

| 英文 | 中文 | 说明 |
|------|------|------|
| Codable | 可编解码 | Swift 协议，声明后可自动实现 JSON 的编码和解码 |
| CodingKeys | 键名枚举 | 用于映射 Swift 属性名和 JSON 字段名的枚举类型 |
| JSONSerialization | JSON 序列化器 | Foundation 框架提供的旧式 JSON 解析类 |
| JSONDecoder | JSON 解码器 | 将 JSON Data 解码为 Swift 类型的类 |
| JSONEncoder | JSON 编码器 | 将 Swift 类型编码为 JSON Data 的类 |
| SwiftyJSON | 第三方 JSON 库 | 提供链式访问语法的第三方处理库 |

## 知识检查

用三个问题检验你是否真正掌握了本节内容。

**问题一**：Codable 实际上是哪两个协议的组合？

<details>
<summary>查看答案</summary>

Codable = Decodable + Encodable。Decodable 负责 JSON 到 Swift 对象的解码，Encodable 负责 Swift 对象到 JSON 的编码。
</details>

**问题二**：如果一个 Swift 属性名叫 `createdAt`，但 JSON 字段名叫 `created_at`，应该如何配置 CodingKeys？

<details>
<summary>查看答案</summary>

```swift
enum CodingKeys: String, CodingKey {
    case createdAt = "created_at"
}
```

CodingKeys 作为 CodingKey 协议的枚举，用 raw value 指定 JSON 中的实际字段名。
</details>

**问题三**：SwiftyJSON 的 `.stringValue` 和 `.value` 有什么区别？

<details>
<summary>查看答案</summary>

`stringValue` 返回确定类型（String），如果实际类型不匹配则返回空字符串。`.value` 返回原始类型（Any），需要你手动做类型转换。日常开发优先用 `.stringValue`、`.intValue` 等类型化 accessor。
</details>

## 继续学习

JSON 处理完成后，你的数据已经从网络层面落入了 Swift 的世界。下一步，你需要知道如何把这些数据保存下来。

继续学习下一节：[文件操作](./file-operations.md)，你将学会如何用 FileManager 读写文件系统，以及 SwiftData 的持久化机制。
