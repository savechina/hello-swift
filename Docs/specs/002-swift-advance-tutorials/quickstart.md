# Quickstart: Swift Advance Tutorial Content Generation

**Feature**: 002-swift-advance-tutorials
**Created**: 2026-04-26
**Purpose**: Setup instructions for implementing advance tutorial chapters

---

## Prerequisites

### Knowledge Requirements

- ✅ Completed Basic section tutorial (12 chapters)
- ✅ Swift syntax fundamentals (variables, control flow, functions, classes, protocols)
- ✅ Error handling basics (do/catch/try, throws)
- ✅ Concurrency basics (async/await, Task)

### Tool Requirements

| Tool | Version | Installation |
|------|---------|--------------|
| Swift | 6.0+ | `xcode-select --install` or [swift.org](https://swift.org) |
| mdBook | 0.4.52 | `brew install mdbook` |
| Git | 2.40+ | `brew install git` |

### Platform Requirements

| Platform | Requirement | Notes |
|----------|-------------|-------|
| macOS | 14.0+ (Sonoma) | SwiftData requires macOS 14 |
| macOS | 12.0+ (Monterey) | FileManager async APIs |
| Linux | Ubuntu 22.04+ | Partial support (no SwiftData, limited FileManager paths) |

---

## Environment Setup

### 1. Verify Swift Toolchain

```bash
swift --version
# Expected: Swift 6.0 or higher

swift build
# Expected: Build complete with zero warnings
```

### 2. Verify AdvanceSample Compilation

```bash
# From project root
cd AdvanceSample
swift build
# Expected: Compiles AdvanceSample with SwiftyJSON, swift-dotenv dependencies
```

### 3. Verify mdBook Installation

```bash
mdbook --version
# Expected: mdbook v0.4.52

# Test build
mdbook build Docs/
# Expected: Build succeeds with zero errors
```

### 4. Verify Existing Documentation

```bash
# Check advance section structure
ls Docs/src/advance/
# Expected: advance-overview.md, advance.md (empty), advance.md placeholder

# Preview current docs
mdbook serve Docs/
# Open http://localhost:3000 in browser
```

---

## Source Files Reference

### Existing Swift Source (Do NOT Modify)

| File | Location | Functions |
|------|----------|-----------|
| AdvanceSample.swift | `AdvanceSample/Sources/AdvanceSample/` | `jsonSample()`, `startSample()`, `endSample()` |
| FileOperationSample.swift | `AdvanceSample/Sources/AdvanceSample/` | `fileManagerPathSample()`, `temporaryFileSample()` |
| SwiftDataSample.swift | `AdvanceSample/Sources/AdvanceSample/` | `logServicesSample()`, `metricsDataServiceSample()` |
| DotenvySample.swift | `AdvanceSample/Sources/AdvanceSample/` | `processInfoEnvSample()`, `dotenvSample()` |

**Key Constraint**: FR-003 requires "All code examples MUST compile from existing AdvanceSample files" - **NO new Swift code needed**.

---

## Output Files to Create

### Chapter Files (6 files)

| File | Path | Content |
|------|------|---------|
| json.md | `Docs/src/advance/json.md` | JSON processing chapter |
| file-operations.md | `Docs/src/advance/file-operations.md` | FileManager + I/O chapter |
| swift-data.md | `Docs/src/advance/swift-data.md` | SwiftData persistence chapter |
| environment.md | `Docs/src/advance/environment.md` | ProcessInfo + dotenv chapter |
| review-advance.md | `Docs/src/advance/review-advance.md` | Stage review chapter |
| glossary-advance.md | `Docs/src/advance/glossary-advance.md` | Advance terminology |

### Files to Update (2 files)

| File | Path | Changes |
|------|------|---------|
| advance-overview.md | `Docs/src/advance/advance-overview.md` | Add SwiftData chapter, remove System Services |
| SUMMARY.md | `Docs/src/SUMMARY.md` | Add advance chapter navigation |

### File to Delete (1 file)

| File | Path | Reason |
|------|------|--------|
| advance.md | `Docs/src/advance/advance.md` | Empty placeholder (0 lines) |

---

## Chapter Template

Each chapter follows this 15-section structure:

```markdown
# [Chapter Title]

## 开篇故事
[Analogy-based opening, 2-3 paragraphs]

## 本章适合谁
- 有 [X] 基础的开发者
- 想学习 [Y] 的工程师

## 你会学到什么
- [Outcome 1]
- [Outcome 2]
- [Outcome 3]

## 前置要求
- macOS [version]+ / Linux
- Swift 6.0+
- 已完成 [previous chapters]

## 第一个例子
```swift
// Simple runnable example from source file
```

## 原理解析
[Concept explanation with diagrams]

## 常见错误
| 错误 | 原因 | 解决方案 |
|------|------|----------|
| [Error 1] | [Cause] | [Fix] |
| [Error 2] | [Cause] | [Fix] |
| [Error 3] | [Cause] | [Fix] |

## Swift vs Rust/Python 对比
| Swift | Rust | Python |
|-------|------|--------|
| [API] | [Equivalent] | [Equivalent] |

## 动手练习 Level 1
[Basic application exercise]

## 动手练习 Level 2
[Integrated scenario exercise]

## 动手练习 Level 3
[Extended challenge with hidden solution]

<details>
<summary>点击查看答案</summary>
[Solution code]
</details>

## 故障排查 FAQ
**Q: [Question 1]**
A: [Answer 1]

## 小结
- [Point 1]
- [Point 2]
- [Point 3]

## 术语表
| 中文 | 英文 | 说明 |
|------|------|------|
| [Term] | [English] | [Description] |

## 知识检查
1. [Question 1]
2. [Question 2]
3. [Question 3]

<details>
<summary>点击查看答案与解析</summary>
[Answers]
</details>

## 继续学习
**下一章**: [Next chapter link]
**返回**: [advance-overview.md link]
```

---

## Validation Commands

### After Each Chapter Written

```bash
# 1. Validate markdown syntax
mdbook build Docs/
# Expected: Zero errors, zero warnings

# 2. Validate internal links
mdbook build Docs/ 2>&1 | grep -i "warning"
# Expected: No output (all links valid)

# 3. Check chapter structure
grep -c "^##" Docs/src/advance/json.md
# Expected: 15 sections

# 4. Check minimum length
wc -c Docs/src/advance/json.md
# Expected: 500+ Chinese characters
```

### After All Chapters Complete

```bash
# Full documentation build
mdbook build Docs/

# Swift compilation verification
swift build

# Preview in browser
mdbook serve Docs/
```

---

## Troubleshooting

### Issue: mdBook build fails with "Duplicate file in SUMMARY.md"

**Cause**: Same file referenced twice in navigation
**Fix**: Check SUMMARY.md for duplicate entries

### Issue: SwiftData examples crash on macOS < 14

**Cause**: SwiftData requires macOS 14+
**Fix**: Add `#available(macOS 14.0, *)` guard in examples, document in 前置要求

### Issue: FileManager paths missing on Linux

**Cause**: Linux has no Documents/Caches sandbox paths
**Fix**: Use `FileManager.default.currentDirectoryPath` on Linux, document platform differences

### Issue: `try!` compilation warning in AdvanceSample.swift

**Cause**: Force unwrap without safety check
**Fix**: Use existing code as anti-pattern example in "常见错误" section (do NOT modify source)

---

## Time Estimates

| Task | Estimate | Notes |
|------|----------|-------|
| Write json.md | 45 min | Reference AdvanceSample.swift |
| Write file-operations.md | 40 min | Reference FileOperationSample.swift |
| Write swift-data.md | 60 min | Most complex, 8 subsections |
| Write environment.md | 30 min | Reference DotenvySample.swift |
| Write review-advance.md | 20 min | Summary + quiz |
| Write glossary-advance.md | 15 min | 20+ terms |
| Update advance-overview.md | 10 min | Replace chapter table |
| Update SUMMARY.md | 5 min | Add navigation entries |
| Delete advance.md | 1 min | Remove empty file |
| Validation & Testing | 15 min | mdbook build, swift build |
| **Total** | **~4 hours** | SC-005 target |

---

## Ready to Proceed

After completing this quickstart, proceed with:

```
/speckit.tasks
```

This will generate the task breakdown for implementing all chapters.