# Research: Swift Advance Tutorial Content Generation

**Feature**: 002-swift-advance-tutorials
**Created**: 2026-04-26
**Source**: [plan.md](./plan.md)

---

## Design Decisions

### Decision 1: Chapter Structure Template

**Decision**: Follow hello-rust 15-section template pattern for all Advance chapters.

**Rationale**: 
- hello-rust has proven 45 advance chapters with consistent structure (开篇故事, 常见错误, 动手练习 present in 38/45 files)
- Chinese learners expect familiar structure after completing Basic section
- Constitution III requires "12-section template" - hello-rust has 15 sections which provides more comprehensive coverage

**Template Sections** (15 total):
1. 开篇故事 - Analogy-based opening
2. 本章适合谁 - Target audience
3. 你会学到什么 - Learning outcomes
4. 前置要求 - Prerequisites
5. 第一个例子 - Runnable example
6. 原理解析 - Deep dive
7. 常见错误 - Common pitfalls (3+ required per FR-010)
8. Swift vs Rust/Python 对比 - Cross-language comparison (FR-006)
9. 动手练习 Level 1 - Basic application
10. 动手练习 Level 2 - Integrated scenario
11. 动手练习 Level 3 - Extended challenge
12. 故障排查 FAQ - Q&A pairs
13. 小结 - Recap
14. 术语表 - English/Chinese glossary
15. 知识检查 - Quiz with hidden answers

**Alternatives Considered**:
- Apple official docs structure (too sparse, no exercises)
- Medium article format (no quiz/FAQ sections)

---

### Decision 2: Chapter File Naming Convention

**Decision**: Use flat naming pattern: `{topic}.md` (e.g., `json.md`, `swift-data.md`)

**Rationale**:
- hello-rust advance uses subdirectories (`advance/data/json.md`, `advance/system/tempfile.md`) but has 45 chapters
- hello-swift has only 4 chapters - subdirectory nesting adds unnecessary complexity
- SUMMARY.md navigation simpler with flat structure
- Constitution requires "GitHub links to all source code examples" - flat names easier to reference

**File Names**:
- `json.md` - JSON processing chapter
- `file-operations.md` - FileManager + I/O chapter
- `swift-data.md` - SwiftData persistence chapter
- `environment.md` - ProcessInfo + dotenv chapter
- `review-advance.md` - Stage review chapter
- `glossary-advance.md` - Advance terminology glossary

**Alternatives Considered**:
- Nested structure (`advance/data/json.md`) - rejected for 4 chapters
- Numbered prefix (`01-json.md`) - rejected for flexibility

---

### Decision 3: Code-to-Chapter Mapping Strategy

**Decision**: Each chapter references exactly ONE Swift source file from `AdvanceSample/Sources/AdvanceSample/`.

**Mapping Table**:

| Chapter | Source File | Functions Covered |
|---------|-------------|-------------------|
| json.md | `AdvanceSample.swift` | `jsonSample()`, JSONSerialization, JSONDecoder, SwiftyJSON |
| file-operations.md | `FileOperationSample.swift` | `fileManagerPathSample()`, `temporaryFileSample()`, TemporaryFile class |
| swift-data.md | `SwiftDataSample.swift` | `logServicesSample()`, `metricsDataServiceSample()`, ServerLog, ServiceMetrics, LogService, MetricsDataService |
| environment.md | `DotenvySample.swift` | `processInfoEnvSample()`, `dotenvSample()`, Dotenv API |

**Rationale**:
- Constitution I requires "All code examples MUST be from real project code"
- Existing AdvanceSample files compile clean with `swift build`
- One-to-one mapping avoids duplicate examples across chapters
- Source files already have `///` documentation comments

**Alternatives Considered**:
- Extract functions into new sample files - rejected (creates maintenance burden)
- Create synthetic examples - rejected (constitution prohibits fictional examples)

---

### Decision 4: SwiftData Chapter Structure

**Decision**: 8 subsections for SwiftData covering @Model → ModelActor progression.

**Structure** (based on librarian research):
1. SwiftData 简介 - What is SwiftData, iOS 17+ / macOS 14+ requirement
2. 定义数据模型 (@Model) - @Model macro, property types, init requirements
3. 容器与上下文 (ModelContainer/Context) - ModelContainer configuration, ModelContext operations
4. 查询数据 (FetchDescriptor) - FetchDescriptor, SortDescriptor
5. 条件查询 (#Predicate) - #Predicate macro, compound queries
6. 后台并发 (@ModelActor) - ModelActor pattern, PersistentIdentifier, cross-actor data passing
7. 关系与迁移 - @Relationship, cascade delete, lightweight migration
8. 综合练习 - Complete CRUD application

**Common Errors to Document** (from research):
1.忘记将模型添加到 ModelContainer - Returns empty array
2. 在不同 Context 之间建立关系 - Crash: "Illegal attempt to establish relationship"
3. 在 Predicate 中使用不支持的类型 - EXC_BAD_ACCESS on array queries
4. 跨 Actor 传递模型对象 - Compilation error: model objects not Sendable
5. 忘记提供初始化器 - "@Model requires an initializer"

**Alternatives Considered**:
- Single chapter covering all concepts - rejected (too long, >1000 lines)
- Split into two chapters (basics + advanced) - rejected (4 chapters scope)

---

### Decision 5: Platform Compatibility Handling

**Decision**: Document macOS 14.0+ requirement for SwiftData, macOS 12.0+ for FileManager async APIs, Linux limitations in 前置要求 section.

**Platform Matrix**:

| Feature | macOS 14+ | macOS 12-13 | Linux |
|---------|-----------|-------------|-------|
| SwiftData (@Model) | ✅ Full support | ❌ Not available | ❌ Not available |
| FileManager async (AsyncLineSequence) | ✅ Full support | ✅ Available | ⚠️ Limited paths |
| FileManager standard paths (Documents/Caches) | ✅ Available | ✅ Available | ❌ No sandbox paths |
| ProcessInfo.processInfo | ✅ Available | ✅ Available | ✅ Available |
| swift-dotenv | ✅ Available | ✅ Available | ✅ Available |

**Edge Case Handling** (per spec):
- macOS < 14: Show `#available(macOS 14.0, *)` guard pattern in examples
- Linux: Document path differences (no Documents/Caches, use `currentDirectoryPath`)
- Temp files on crash: Document RAII pattern with `deinit` cleanup

**Alternatives Considered**:
- Skip SwiftData for Linux compatibility - rejected (key macOS feature)
- Create separate Linux chapter variants - rejected (out of scope)

---

### Decision 6: SUMMARY.md Navigation Structure

**Decision**: Nested navigation with chapter descriptions matching hello-rust pattern.

```markdown
# 高级部分 (Advance)

- [高级进阶](./advance/advance-overview.md)
    - [JSON 处理](./advance/json.md) - JSONSerialization, Codable, SwiftyJSON
    - [文件操作](./advance/file-operations.md) - FileManager, 临时文件, 流式读取
    - [SwiftData 持久化](./advance/swift-data.md) - @Model, ModelContainer, ModelActor
    - [环境配置](./advance/environment.md) - ProcessInfo, swift-dotenv
- [阶段复习：高级部分](./advance/review-advance.md)
```

**Rationale**:
- hello-rust SUMMARY.md advance section has descriptions after each link (e.g., "Box, Rc, RefCell, Arc")
- Provides quick topic preview without opening chapter
- Consistent with existing hello-swift SUMMARY.md basic section format

**Alternatives Considered**:
- Flat list without descriptions - rejected (less discoverable)
- Separate SUMMARY for advance section - rejected (mdBook requires single SUMMARY.md)

---

### Decision 7: advance-overview.md Update Strategy

**Decision**: Replace current overview's 5-chapter table with 4-chapter table including SwiftData.

**Current advance-overview.md Issue**:
- Lists "System Services" chapter (no source code)
- Lists "Async Programming" chapter (no SwiftNIO usage in source)
- Missing SwiftData chapter (SwiftDataSample.swift exists)

**Updated Table**:

| 章节 | 预计时间 | 难度 | 涉及知识点 |
|------|----------|------|------------|
| JSON 处理 | 45分钟 | ⭐⭐⭐ | JSONSerialization, Codable, SwiftyJSON |
| 文件操作 | 40分钟 | ⭐⭐⭐ | FileManager, 临时文件, AsyncLineSequence |
| SwiftData 持久化 | 60分钟 | ⭐⭐⭐⭐ | @Model, ModelContainer, ModelActor, #Predicate |
| 环境配置 | 30分钟 | ⭐⭐ | ProcessInfo, swift-dotenv, dynamic member lookup |

**Alternatives Considered**:
- Keep System Services as placeholder - rejected (FR-011 requires SwiftData inclusion)
- Add SwiftNIO chapter - rejected (no source code exists)

---

### Decision 8: Empty advance.md Resolution

**Decision**: Delete `advance.md` (empty file), use `advance-overview.md` as landing page.

**Rationale**:
- `advance.md` is 0 lines (empty placeholder from earlier project setup)
- `advance-overview.md` (85 lines) already serves as landing page with chapter table
- mdBook SUMMARY.md links to `advance-overview.md`, not `advance.md`
- Removing empty file simplifies documentation structure

**Alternatives Considered**:
- Populate advance.md with chapter summaries - rejected (duplicate content)
- Rename advance-overview.md to advance.md - rejected (breaks existing SUMMARY.md links)

---

## Dependencies Analysis

### Existing Dependencies (AdvanceSample/Package.swift)

| Package | Version | Used In | Chapter |
|---------|---------|---------|---------|
| SwiftyJSON | 5.0.2+ | AdvanceSample.swift | json.md |
| swift-nio | 2.92.0+ | **NOT USED** | Skip |
| swift-dotenv | 2.0.0+ | DotenvySample.swift | environment.md |
| SwiftData | Apple framework | SwiftDataSample.swift | swift-data.md |

### Documentation Dependencies

| Tool | Version | Purpose |
|------|---------|---------|
| mdBook | 0.4.52 | Documentation build |
| Swift 6.0 | toolchain | Code compilation verification |

---

## Quality Assurance

### Validation Checklist (Post-Research)

- [x] All NEEDS CLARIFICATION resolved in Technical Context
- [x] Constitution gates pass (see plan.md)
- [x] Chapter-to-source mapping defined (4 chapters → 4 source files)
- [x] SwiftData common errors identified (5 documented)
- [x] Platform compatibility matrix documented
- [x] SUMMARY.md structure defined
- [x] advance-overview.md update plan defined
- [x] Empty advance.md resolution defined

### Risks Identified

| Risk | Mitigation |
|------|------------|
| SwiftData requires macOS 14+ | Document #available guard, provide in-memory alternative |
| swift-nio declared but not used | Skip SwiftNIO chapter, keep dependency for future |
| FileManager paths differ on Linux | Document path differences in chapter |
| `try!` in AdvanceSample.swift | Use as anti-pattern example in "常见错误" section |

---

## Next Steps

Proceed to Phase 1:
1. ✅ data-model.md generated
2. Generate quickstart.md (setup instructions)
3. Update agent context via script
4. Proceed to `/speckit.tasks` for task breakdown