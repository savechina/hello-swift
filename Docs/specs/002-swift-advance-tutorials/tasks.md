# Tasks: Swift Advance Tutorial Content Generation

**Input**: Design documents from `/Docs/specs/002-swift-advance-tutorials/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Tests**: NOT requested - validation via `mdbook build Docs/` and `swift build`.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4, US5, US6, US7)
- Include exact file paths in descriptions

## Path Conventions

- **Documentation output**: `Docs/src/advance/`
- **Source code**: `AdvanceSample/Sources/AdvanceSample/` (Phase 2 adds new files)
- **Tests**: `Tests/AdvanceSampleTests/` (Phase 2 adds test file)
- **Navigation**: `Docs/src/SUMMARY.md`

---

## Phase 1: Setup (Documentation Infrastructure) - ✅ COMPLETE

**Purpose**: Prepare documentation structure and remove obsolete files

- [X] T001 Delete empty placeholder file `Docs/src/advance/advance.md`
- [X] T002 Update `advance-overview.md` chapter table to include SwiftData in `Docs/src/advance/advance-overview.md`
- [X] T003 Update SUMMARY.md advance section navigation in `Docs/src/SUMMARY.md`

---

## Phase 2: Foundational (Cross-Cutting Documentation) - ✅ COMPLETE

**Purpose**: Documentation shared across all user stories

- [X] T004 [P] Create advance section glossary with 20+ terms in `Docs/src/advance/glossary-advance.md`
- [X] T005 [P] Create advance section review chapter with quiz in `Docs/src/advance/review-advance.md`

---

## Phase 3: User Story 1 - JSON 处理 (Priority: P1) - ✅ COMPLETE 🎯 MVP

**Goal**: 读者能够使用 JSONDecoder、Codable、SwiftyJSON 解析复杂 JSON 结构

**Independent Test**: `mdbook build Docs/` succeeds, chapter has 15 sections, 3+ exercises, 3+ quizzes

**Source Reference**: `AdvanceSample/Sources/AdvanceSample/AdvanceSample.swift` (jsonSample function)

### Implementation for User Story 1

- [X] T006-T016 [US1] Complete JSON chapter in `Docs/src/advance/json.md` (11 tasks)

---

## Phase 4: User Story 2 - 文件操作 (Priority: P2) - ✅ COMPLETE

**Goal**: 读者能够使用 FileManager 获取路径、创建临时文件、流式读取大文件

**Independent Test**: `mdbook build Docs/` succeeds, chapter has 15 sections

**Source Reference**: `AdvanceSample/Sources/AdvanceSample/FileOperationSample.swift`

### Implementation for User Story 2

- [X] T017-T027 [US2] Complete File Operations chapter in `Docs/src/advance/file-operations.md` (11 tasks)

---

## Phase 5: User Story 3 - SwiftData 持久化 (Priority: P3) - ✅ COMPLETE

**Goal**: 读者能够使用 @Model、ModelContainer、ModelActor 构建 CRUD 应用

**Independent Test**: `mdbook build Docs/` succeeds, chapter has 15 sections, covers 5 SwiftData errors

**Source Reference**: `AdvanceSample/Sources/AdvanceSample/SwiftDataSample.swift`

### Implementation for User Story 3

- [X] T028-T038 [US3] Complete SwiftData chapter in `Docs/src/advance/swift-data.md` (11 tasks)

---

## Phase 6: User Story 4 - 环境配置 (Priority: P4) - ✅ COMPLETE

**Goal**: 读者能够使用 ProcessInfo、swift-dotenv 安全管理配置参数

**Independent Test**: `mdbook build Docs/` succeeds, chapter has 15 sections

**Source Reference**: `AdvanceSample/Sources/AdvanceSample/DotenvySample.swift`

### Implementation for User Story 4

- [X] T039-T049 [US4] Complete Environment chapter in `Docs/src/advance/environment.md` (11 tasks)

---

## Phase 7: Polish & Validation (Phase 1) - ✅ COMPLETE

**Purpose**: Final validation and quality checks across all chapters

- [X] T050-T056 Complete validation tasks (7 tasks)

---

## Phase 8: Phase 2 Setup (New Source Files)

**Purpose**: Create new source files for SwiftNIO, System, Process, Testing chapters

**⚠️ CRITICAL**: Source code must compile on macOS and Linux before documentation can reference it

### Source Code Creation

- [ ] T057 [P] Create SwiftNIOSample.swift with Echo Server example in `AdvanceSample/Sources/AdvanceSample/SwiftNIOSample.swift`
- [ ] T058 [P] Create SystemSample.swift with Swift System Package cross-platform example in `AdvanceSample/Sources/AdvanceSample/SystemSample.swift`
- [ ] T059 [P] Create ProcessSample.swift with Process execution example in `AdvanceSample/Sources/AdvanceSample/ProcessSample.swift`
- [ ] T060 Update AdvanceSample.swift to call new sample functions in `AdvanceSample/Sources/AdvanceSample/AdvanceSample.swift`

### Tests Creation

- [ ] T061 [P] Create TestingSampleTests.swift with XCTest patterns example in `Tests/AdvanceSampleTests/TestingSampleTests.swift`

### Build Validation

- [ ] T062 Run `swift build` to verify new source files compile on macOS
- [ ] T063 Run `swift build` to verify SwiftNIO/System compile on Linux (if Linux available)

**Checkpoint**: Phase 2 source code ready - documentation can begin

---

## Phase 9: User Story 5 - SwiftNIO 异步网络 (Priority: P5) 🎯 Phase 2 MVP

**Goal**: 读者能够使用 SwiftNIO 创建 TCP 服务器、理解 Channel/EventLoop、与 async/await 集成

**Independent Test**: `mdbook build Docs/` succeeds, 2 chapters each with 15 sections, cross-platform verified

**Source Reference**: `AdvanceSample/Sources/AdvanceSample/SwiftNIOSample.swift` (NEW)

### Chapter 1: SwiftNIO 基础

- [ ] T064 [US5] Write 开篇故事 section introducing network programming analogy in `Docs/src/advance/swift-nio-basics.md`
- [ ] T065 [US5] Write 本章适合谁 + 你会学到什么 + 前置要求 sections (note macOS/Linux support) in `Docs/src/advance/swift-nio-basics.md`
- [ ] T066 [US5] Write 第一个例子 section with Echo Server from `AdvanceSample/Sources/AdvanceSample/SwiftNIOSample.swift` in `Docs/src/advance/swift-nio-basics.md`
- [ ] T067 [US5] Write 原理解析 section explaining Channel, EventLoop, ChannelPipeline, ByteBuffer in `Docs/src/advance/swift-nio-basics.md`
- [ ] T068 [US5] Write 常见错误 section with 3+ errors (backpressure, buffer leak, thread safety) in `Docs/src/advance/swift-nio-basics.md`
- [ ] T069 [US5] Write Swift vs Rust/Python 对比表 section (tokio vs SwiftNIO) in `Docs/src/advance/swift-nio-basics.md`
- [ ] T070 [US5] Write 动手练习 Level 1-3 sections with hidden solutions in `Docs/src/advance/swift-nio-basics.md`
- [ ] T071 [US5] Write 故障排查 FAQ section with 5+ Q&A pairs in `Docs/src/advance/swift-nio-basics.md`
- [ ] T072 [US5] Write 小结 + 术语表 + 知识检查 sections in `Docs/src/advance/swift-nio-basics.md`
- [ ] T073 [US5] Write 继续学习 navigation section linking to async chapter in `Docs/src/advance/swift-nio-basics.md`
- [ ] T074 [US5] Validate chapter: verify 15 sections, 500+ chars, 3+ exercises, 3+ quizzes

### Chapter 2: SwiftNIO Async/Await 集成

- [ ] T075 [US5] Write 开篇故事 section introducing async integration analogy in `Docs/src/advance/swift-nio-async.md`
- [ ] T076 [US5] Write 本章适合谁 + 你会学到什么 + 前置要求 sections in `Docs/src/advance/swift-nio-async.md`
- [ ] T077 [US5] Write 第一个例子 section with NIOAsyncChannel example in `Docs/src/advance/swift-nio-async.md`
- [ ] T078 [US5] Write 原理解析 section explaining NIOLoopBoundBox, Task integration in `Docs/src/advance/swift-nio-async.md`
- [ ] T079 [US5] Write 常见错误 section with 3+ errors (actor isolation, blocking EventLoop) in `Docs/src/advance/swift-nio-async.md`
- [ ] T080 [US5] Write Swift vs Rust/Python 对比表 section in `Docs/src/advance/swift-nio-async.md`
- [ ] T081 [US5] Write 动手练习 Level 1-3 sections with hidden solutions in `Docs/src/advance/swift-nio-async.md`
- [ ] T082 [US5] Write 故障排查 FAQ section with 5+ Q&A pairs in `Docs/src/advance/swift-nio-async.md`
- [ ] T083 [US5] Write 小结 + 术语表 + 知识检查 sections in `Docs/src/advance/swift-nio-async.md`
- [ ] T084 [US5] Write 继续学习 navigation section linking to next chapter in `Docs/src/advance/swift-nio-async.md`
- [ ] T085 [US5] Validate chapter: verify 15 sections, 500+ chars, 3+ exercises, 3+ quizzes

**Checkpoint**: User Story 5 complete - 2 SwiftNIO chapters independently functional

---

## Phase 10: User Story 6 - 系统编程与进程管理 (Priority: P6)

**Goal**: 读者能够使用 Process 执行外部命令、处理 Signal、了解 Swift System Package

**Independent Test**: `mdbook build Docs/` succeeds, chapter has 15 sections, cross-platform notes

**Source Reference**: `AdvanceSample/Sources/AdvanceSample/SystemSample.swift` + `ProcessSample.swift` (NEW)

### Implementation for User Story 6

- [ ] T086 [US6] Write 开篇故事 section introducing system programming analogy in `Docs/src/advance/system-programming.md`
- [ ] T087 [US6] Write 本章适合谁 + 你会学到什么 + 前置要求 sections (note POSIX/Glibc differences) in `Docs/src/advance/system-programming.md`
- [ ] T088 [US6] Write 第一个例子 section with Process example from `AdvanceSample/Sources/AdvanceSample/ProcessSample.swift` in `Docs/src/advance/system-programming.md`
- [ ] T089 [US6] Write 原理解析 section explaining Process, Signal handling, Swift System Package in `Docs/src/advance/system-programming.md`
- [ ] T090 [US6] Write 常见错误 section with 3+ errors (process timeout, signal race, path issues) in `Docs/src/advance/system-programming.md`
- [ ] T091 [US6] Write Swift vs Rust/Python 对比表 section (subprocess vs Process) in `Docs/src/advance/system-programming.md`
- [ ] T092 [US6] Write 动手练习 Level 1-3 sections with hidden solutions in `Docs/src/advance/system-programming.md`
- [ ] T093 [US6] Write 故障排查 FAQ section with 5+ Q&A pairs in `Docs/src/advance/system-programming.md`
- [ ] T094 [US6] Write 小结 + 术语表 + 知识检查 sections in `Docs/src/advance/system-programming.md`
- [ ] T095 [US6] Write 继续学习 navigation section linking to next chapter in `Docs/src/advance/system-programming.md`
- [ ] T096 [US6] Validate chapter: verify 15 sections, 500+ chars, 3+ exercises, 3+ quizzes

**Checkpoint**: User Stories 5 AND 6 complete - SwiftNIO + System chapters functional

---

## Phase 11: User Story 7 - 测试框架 (Priority: P7)

**Goal**: 读者能够使用 XCTest 编写单元测试、测试异步代码

**Independent Test**: `mdbook build Docs/` succeeds, chapter has 15 sections, `swift test --filter TestingSampleTests` passes

**Source Reference**: `Tests/AdvanceSampleTests/TestingSampleTests.swift` (NEW)

### Implementation for User Story 7

- [ ] T097 [US7] Write 开篇故事 section introducing testing analogy in `Docs/src/advance/testing.md`
- [ ] T098 [US7] Write 本章适合谁 + 你会学到什么 + 前置要求 sections in `Docs/src/advance/testing.md`
- [ ] T099 [US7] Write 第一个例子 section with XCTestCase example from `Tests/AdvanceSampleTests/TestingSampleTests.swift` in `Docs/src/advance/testing.md`
- [ ] T100 [US7] Write 原理解析 section explaining XCTestCase, async test methods, XCTAssert in `Docs/src/advance/testing.md`
- [ ] T101 [US7] Write 常见错误 section with 3+ errors (async race, assertion failure, test isolation) in `Docs/src/advance/testing.md`
- [ ] T102 [US7] Write Swift vs Rust/Python 对比表 section (pytest vs XCTest) in `Docs/src/advance/testing.md`
- [ ] T103 [US7] Write 动手练习 Level 1-3 sections with hidden solutions in `Docs/src/advance/testing.md`
- [ ] T104 [US7] Write 故障排查 FAQ section with 5+ Q&A pairs in `Docs/src/advance/testing.md`
- [ ] T105 [US7] Write 小结 + 术语表 + 知识检查 sections in `Docs/src/advance/testing.md`
- [ ] T106 [US7] Write 继续学习 navigation section linking to review chapter in `Docs/src/advance/testing.md`
- [ ] T107 [US7] Validate chapter: verify 15 sections, 500+ chars, 3+ exercises, 3+ quizzes

**Checkpoint**: All 7 user stories complete - full Advance section functional

---

## Phase 12: Phase 2 Polish & Cross-Cutting

**Purpose**: Update navigation, glossary, and final validation for Phase 2

- [ ] T108 Update advance-overview.md with expanded chapter table (7-8 chapters) in `Docs/src/advance/advance-overview.md`
- [ ] T109 Update SUMMARY.md to add SwiftNIO, System, Testing chapters in `Docs/src/SUMMARY.md`
- [ ] T110 [P] Update glossary-advance.md with SwiftNIO/System/Testing terms in `Docs/src/advance/glossary-advance.md`
- [ ] T111 [P] Update review-advance.md with Phase 2 quiz questions in `Docs/src/advance/review-advance.md`
- [ ] T112 Run `swift build` to verify all Phase 2 source compiles
- [ ] T113 Run `swift test --filter TestingSampleTests` to verify test examples work
- [ ] T114 Run `mdbook build Docs/` to verify zero errors, zero warnings
- [ ] T115 Verify all new SUMMARY.md links resolve correctly
- [ ] T116 Preview docs via `mdbook serve Docs/` and manual review

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1-7**: ✅ COMPLETE (56 tasks)
- **Phase 8 (Setup)**: No dependencies - source files can be created immediately
- **Phase 9-11 (User Stories 5-7)**: All depend on Phase 8 completion (source code must exist)
  - US5 (SwiftNIO) and US6 (System) can proceed in parallel after Phase 8
  - US7 (Testing) depends on T061 (test file creation)
- **Phase 12 (Polish)**: Depends on all Phase 2 user stories complete

### User Story Dependencies

- **User Story 5 (P5)**: Depends on T057 (SwiftNIOSample.swift), T062 (build verification)
- **User Story 6 (P6)**: Depends on T058-T059 (SystemSample.swift, ProcessSample.swift)
- **User Story 7 (P7)**: Depends on T061 (TestingSampleTests.swift), T113 (test verification)

### Parallel Opportunities

- T057-T061 can all run in parallel (different source files)
- After Phase 8, US5 (SwiftNIO basics) and US5 (SwiftNIO async) can be written in parallel
- After Phase 8, US6 (System) can be written in parallel with US5 chapters
- T110-T111 can run in parallel (glossary and review updates)

---

## Parallel Example: Phase 2 Source Code

```bash
# Launch all source file creation in parallel:
Task: "Create SwiftNIOSample.swift in AdvanceSample/Sources/AdvanceSample/"
Task: "Create SystemSample.swift in AdvanceSample/Sources/AdvanceSample/"
Task: "Create ProcessSample.swift in AdvanceSample/Sources/AdvanceSample/"
Task: "Create TestingSampleTests.swift in Tests/AdvanceSampleTests/"

# Each source file is independent - can be delegated to different agents
```

---

## Implementation Strategy

### Phase 2 MVP (SwiftNIO Only)

1. Complete Phase 8: Source file creation (SwiftNIOSample.swift)
2. Complete Phase 9: User Story 5 (2 SwiftNIO chapters)
3. Run validation: `swift build`, `mdbook build Docs/`
4. Preview SwiftNIO chapters
5. **STOP** - Phase 2 MVP ready for early review

### Incremental Delivery

1. Phase 8 (Source) → Phase 9 (SwiftNIO) → Validate
2. Add Phase 10 (System) → Validate
3. Add Phase 11 (Testing) → Validate
4. Phase 12 (Polish) → Complete

### Delegation Strategy

With parallel agents:

1. Agent A: SwiftNIOSample.swift + SwiftNIO chapters (T057, T064-T085)
2. Agent B: SystemSample.swift + System chapter (T058-T059, T086-T096)
3. Agent C: TestingSampleTests.swift + Testing chapter (T061, T097-T107)
4. After all chapters: Phase 12 Polish tasks

---

## Task Summary

| Phase | Tasks | Status | Parallelizable |
|-------|-------|--------|----------------|
| Phase 1-7 (Phase 1) | 56 | ✅ COMPLETE | Sequential per story |
| Phase 8 (Phase 2 Setup) | 7 | Pending | T057-T061 parallel |
| Phase 9 (US5 SwiftNIO) | 22 | Pending | 2 chapters sequential |
| Phase 10 (US6 System) | 11 | Pending | Sequential (same file) |
| Phase 11 (US7 Testing) | 11 | Pending | Sequential (same file) |
| Phase 12 (Phase 2 Polish) | 9 | Pending | T110-T111 parallel |
| **Phase 2 Total** | **60** | **Pending** | **Parallel across stories** |
| **Grand Total** | **116** | **56 done, 60 pending** | |

---

## Notes

- **Phase 1 (56 tasks)**: ✅ COMPLETE - JSON, File, SwiftData, Environment chapters done
- **Phase 2 (60 tasks)**: Pending - SwiftNIO, System, Testing chapters
- Source code creation MUST precede documentation (cannot reference non-existent files)
- SwiftNIO chapters verify cross-platform (macOS + Linux)
- Testing chapter references test files (not production source)
- Chinese primary language with English technical terms
- Validation via `mdbook build Docs/` and `swift build`
- Commit after Phase 8 checkpoint for early review