# Data Model: Swift Advance Tutorial Content Generation

**Feature**: 002-swift-advance-tutorials
**Created**: 2026-04-26
**Source**: [spec.md](../spec.md)

## Entities

### 1. Tutorial Chapter (教程章节)

**Purpose**: Single mdBook markdown file containing tutorial content for one Advance module.

| Field | Type | Description |
|-------|------|-------------|
| `fileName` | String | Markdown file name (e.g., `json.md`, `swift-data.md`) |
| `title` | String | Chinese chapter title with English term (e.g., "JSON 处理") |
| `sourceRef` | String | Swift source file path in `AdvanceSample/Sources/AdvanceSample/` |
| `sectionCount` | Int | Number of sections (target: 15) |
| `charCount` | Int | Chinese character count (min: 500) |
| `exercises` | Int | Number of exercises (min: 3) |
| `quizzes` | Int | Number of knowledge checks (min: 3) |
| `difficulty` | String | Difficulty rating (⭐⭐⭐ = intermediate) |
| `estimatedTime` | String | Learning time estimate (e.g., "45分钟") |

**Validation Rules**:
- `charCount >= 500` (FR-001, SC-001)
- `exercises >= 3` (FR-007, SC-004)
- `quizzes >= 3` (FR-007, SC-004)
- `sectionCount == 15` (follow hello-rust template)

**State**: Draft → Written → Validated → Published

---

### 2. Code Sample (代码示例)

**Purpose**: Swift source code referenced by tutorial chapters.

| Field | Type | Description |
|-------|------|-------------|
| `filePath` | String | Absolute path to Swift file |
| `moduleName` | String | Target module name (AdvanceSample) |
| `functions` | List<String> | Public function names in the file |
| `features` | List<String> | Swift features demonstrated |
| `compiles` | Bool | Whether `swift build` succeeds |

**Relationships**:
- `TutorialChapter.sourceRef` → `CodeSample.filePath`

**Validation Rules**:
- `compiles == true` (FR-003, SC-002)
- All `functions` have `///` documentation comments

---

### 3. Learning Path (学习路径)

**Purpose**: Ordered sequence of chapters defining prerequisite dependencies.

| Field | Type | Description |
|-------|------|-------------|
| `sequence` | Int | Order in advance section (1-4) |
| `chapter` | String | Chapter file name |
| `prerequisites` | List<String> | Required prior chapters |
| `nextChapter` | String | Following chapter |

**Current Path**:
```
1. json.md           → prerequisites: [basic/concurrency.md]
2. file-operations.md → prerequisites: [json.md]
3. swift-data.md     → prerequisites: [file-operations.md]
4. environment.md    → prerequisites: [swift-data.md]
```

**Validation Rules**:
- Each chapter linked in SUMMARY.md (FR-005)
- Prerequisites resolve to existing chapters

---

### 4. SwiftData Model (SwiftData 模型)

**Purpose**: @Model class used in SwiftData chapter examples.

| Field | Type | Description |
|-------|------|-------------|
| `modelName` | String | @Model class name (e.g., ServerLog, ServiceMetrics) |
| `properties` | List<String> | Property names with types |
| `macros` | List<String> | Swift macros used (@Model, @ModelActor) |
| `sourceRef` | String | Source file: `SwiftDataSample.swift` |

**Examples from Source**:
- `ServerLog`: id, timestamp, endpoint, responseCode
- `ServiceMetrics`: id, serviceName, responseTime, timestamp
- `LogService`: ModelContainer, ModelContext, CRUD operations
- `MetricsDataService`: @ModelActor, #Predicate, FetchDescriptor

---

### 5. Documentation Navigation (SUMMARY.md Entry)

**Purpose**: mdBook navigation structure for Advance section.

| Field | Type | Description |
|-------|------|-------------|
| `section` | String | Parent section name ("# 高级部分 (Advance)") |
| `entries` | List<Entry> | Chapter links with titles |

**Entry Structure**:
```markdown
- [高级进阶](./advance/advance-overview.md)
    - [JSON 处理](./advance/json.md) - JSONSerialization, Codable, SwiftyJSON
    - [文件操作](./advance/file-operations.md) - FileManager, 临时文件, 流式读取
    - [SwiftData 持久化](./advance/swift-data.md) - @Model, ModelContainer, ModelActor
    - [环境配置](./advance/environment.md) - ProcessInfo, swift-dotenv
```

---

## Entity Relationship Diagram

```
┌─────────────────┐     ┌─────────────────┐
│ TutorialChapter │────>│   CodeSample    │
│                 │     │                 │
│ - fileName      │     │ - filePath      │
│ - sourceRef     │     │ - functions     │
│ - exercises     │     │ - compiles      │
└─────────────────┘     └─────────────────┘
        │
        │
        v
┌─────────────────┐
│  LearningPath   │
│                 │
│ - sequence      │
│ - prerequisites │
│ - nextChapter   │
└─────────────────┘

┌─────────────────┐     ┌─────────────────┐
│ SwiftDataModel  │────>│   CodeSample    │
│                 │     │                 │
│ - modelName     │     │ - SwiftData     │
│ - properties    │     │   Sample.swift  │
│ - macros        │     │                 │
└─────────────────┘     └─────────────────┘
```

---

## File-to-Chapter Mapping

| Source File | Chapter File | Features Covered |
|-------------|--------------|------------------|
| `AdvanceSample.swift` | `json.md` | JSONSerialization, JSONDecoder/Codable, SwiftyJSON |
| `FileOperationSample.swift` | `file-operations.md` | FileManager paths, TemporaryFile, AsyncLineSequence |
| `SwiftDataSample.swift` | `swift-data.md` | @Model, ModelContainer, ModelContext, @ModelActor, FetchDescriptor, #Predicate |
| `DotenvySample.swift` | `environment.md` | ProcessInfo.processInfo, Dotenv.configure(), dynamic member lookup |

---

## Validation Checklist

- [ ] All chapters have `charCount >= 500`
- [ ] All chapters have `exercises >= 3` and `quizzes >= 3`
- [ ] All source files compile with `swift build`
- [ ] SUMMARY.md links all chapters
- [ ] advance-overview.md lists all 4 chapters with SwiftData
- [ ] Each chapter has Swift vs Rust/Python comparison table
- [ ] Each chapter has 3+ common errors with fixes