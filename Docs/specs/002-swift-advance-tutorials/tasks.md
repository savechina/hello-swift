# Tasks: Swift Advance Tutorial Content Generation

**Input**: Design documents from `/Docs/specs/002-swift-advance-tutorials/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Tests**: NOT requested - this is a documentation-only feature. Validation via `mdbook build Docs/` and `swift build`.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

- **Documentation output**: `Docs/src/advance/`
- **Source reference**: `AdvanceSample/Sources/AdvanceSample/` (existing, no modifications)
- **Navigation**: `Docs/src/SUMMARY.md`

---

## Phase 1: Setup (Documentation Infrastructure)

**Purpose**: Prepare documentation structure and remove obsolete files

- [X] T001 Delete empty placeholder file `Docs/src/advance/advance.md`
- [X] T002 Update `advance-overview.md` chapter table to include SwiftData in `Docs/src/advance/advance-overview.md`
- [X] T003 Update SUMMARY.md advance section navigation in `Docs/src/SUMMARY.md`

---

## Phase 2: Foundational (Cross-Cutting Documentation)

**Purpose**: Documentation shared across all user stories

**⚠️ CRITICAL**: These files support all chapters and should be written after understanding all topics

- [X] T004 [P] Create advance section glossary with 20+ terms in `Docs/src/advance/glossary-advance.md`
- [X] T005 [P] Create advance section review chapter with quiz in `Docs/src/advance/review-advance.md`

**Checkpoint**: Foundational docs ready - chapter implementation can begin

---

## Phase 3: User Story 1 - JSON 处理 (Priority: P1) 🎯 MVP

**Goal**: 读者能够使用 JSONDecoder、Codable、SwiftyJSON 解析复杂 JSON 结构

**Independent Test**: `mdbook build Docs/` succeeds, chapter has 15 sections, 3+ exercises, 3+ quizzes

**Source Reference**: `AdvanceSample/Sources/AdvanceSample/AdvanceSample.swift` (jsonSample function)

### Implementation for User Story 1

- [X] T006 [US1] Write 开篇故事 section introducing JSON processing analogy in `Docs/src/advance/json.md`
- [X] T007 [US1] Write 本章适合谁 + 你会学到什么 + 前置要求 sections in `Docs/src/advance/json.md`
- [X] T008 [US1] Write 第一个例子 section with JSONDecoder example from `AdvanceSample/Sources/AdvanceSample/AdvanceSample.swift:54-75` in `Docs/src/advance/json.md`
- [X] T009 [US1] Write 原理解析 section explaining JSONSerialization vs JSONDecoder vs SwiftyJSON in `Docs/src/advance/json.md`
- [X] T010 [US1] Write 常见错误 section with 3+ errors (including `try!` anti-pattern from source) in `Docs/src/advance/json.md`
- [X] T011 [US1] Write Swift vs Rust/Python 对比表 section in `Docs/src/advance/json.md`
- [X] T012 [US1] Write 动手练习 Level 1-3 sections with hidden solutions in `Docs/src/advance/json.md`
- [X] T013 [US1] Write 故障排查 FAQ section with 5+ Q&A pairs in `Docs/src/advance/json.md`
- [X] T014 [US1] Write 小结 + 术语表 + 知识检查 sections in `Docs/src/advance/json.md`
- [X] T015 [US1] Write 继续学习 navigation section linking to next chapter in `Docs/src/advance/json.md`
- [X] T016 [US1] Validate chapter: verify 15 sections, 500+ chars, 3+ exercises, 3+ quizzes via `grep -c "^##" Docs/src/advance/json.md`

**Checkpoint**: User Story 1 complete - JSON chapter independently functional

---

## Phase 4: User Story 2 - 文件操作 (Priority: P2)

**Goal**: 读者能够使用 FileManager 获取路径、创建临时文件、流式读取大文件

**Independent Test**: `mdbook build Docs/` succeeds, chapter has 15 sections, references `FileOperationSample.swift`

**Source Reference**: `AdvanceSample/Sources/AdvanceSample/FileOperationSample.swift` (fileManagerPathSample, temporaryFileSample)

### Implementation for User Story 2

- [X] T017 [US2] Write 开篇故事 section introducing file I/O analogy in `Docs/src/advance/file-operations.md`
- [X] T018 [US2] Write 本章适合谁 + 你会学到什么 + 前置要求 sections in `Docs/src/advance/file-operations.md`
- [X] T019 [US2] Write 第一个例子 section with FileManager path example from `AdvanceSample/Sources/AdvanceSample/FileOperationSample.swift:10-96` in `Docs/src/advance/file-operations.md`
- [X] T020 [US2] Write 原理解析 section explaining Documents/Caches/Temp paths in `Docs/src/advance/file-operations.md`
- [X] T021 [US2] Write 常见错误 section with 3+ errors (path not found, permissions, Linux differences) in `Docs/src/advance/file-operations.md`
- [X] T022 [US2] Write Swift vs Rust/Python 对比表 section in `Docs/src/advance/file-operations.md`
- [X] T023 [US2] Write 动手练习 Level 1-3 sections with hidden solutions in `Docs/src/advance/file-operations.md`
- [X] T024 [US2] Write 故障排查 FAQ section with 5+ Q&A pairs in `Docs/src/advance/file-operations.md`
- [X] T025 [US2] Write 小结 + 术语表 + 知识检查 sections in `Docs/src/advance/file-operations.md`
- [X] T026 [US2] Write 继续学习 navigation section linking to next chapter in `Docs/src/advance/file-operations.md`
- [X] T027 [US2] Validate chapter: verify 15 sections, 500+ chars, 3+ exercises, 3+ quizzes

**Checkpoint**: User Stories 1 AND 2 complete - both chapters independently functional

---

## Phase 5: User Story 3 - SwiftData 持久化 (Priority: P3)

**Goal**: 读者能够使用 @Model、ModelContainer、ModelActor 构建 CRUD 应用

**Independent Test**: `mdbook build Docs/` succeeds, chapter has 15 sections, covers 5 SwiftData errors

**Source Reference**: `AdvanceSample/Sources/AdvanceSample/SwiftDataSample.swift` (ServerLog, ServiceMetrics, LogService, MetricsDataService)

### Implementation for User Story 3

- [X] T028 [US3] Write 开篇故事 section introducing persistence analogy in `Docs/src/advance/swift-data.md`
- [X] T029 [US3] Write 本章适合谁 + 你会学到什么 + 前置要求 sections (note macOS 14+ requirement) in `Docs/src/advance/swift-data.md`
- [X] T030 [US3] Write 第一个例子 section with @Model example from `AdvanceSample/Sources/AdvanceSample/SwiftDataSample.swift:12-26` in `Docs/src/advance/swift-data.md`
- [X] T031 [US3] Write 原理解析 section covering 8 subsections (@Model, ModelContainer, ModelContext, FetchDescriptor, #Predicate, ModelActor, Relationships, Migration) in `Docs/src/advance/swift-data.md`
- [X] T032 [US3] Write 常见错误 section with 5 SwiftData errors (ModelContainer registration, Context relationships, Predicate types, Actor isolation, missing init) in `Docs/src/advance/swift-data.md`
- [X] T033 [US3] Write Swift vs Rust/Python 对比表 section in `Docs/src/advance/swift-data.md`
- [X] T034 [US3] Write 动手练习 Level 1-3 sections with hidden solutions (CRUD, queries, import) in `Docs/src/advance/swift-data.md`
- [X] T035 [US3] Write 故障排查 FAQ section with 5+ Q&A pairs in `Docs/src/advance/swift-data.md`
- [X] T036 [US3] Write 小结 + 术语表 + 知识检查 sections in `Docs/src/advance/swift-data.md`
- [X] T037 [US3] Write 继续学习 navigation section linking to next chapter in `Docs/src/advance/swift-data.md`
- [X] T038 [US3] Validate chapter: verify 15 sections, 500+ chars, 3+ exercises, 3+ quizzes

**Checkpoint**: User Stories 1, 2, AND 3 complete - all three chapters independently functional

---

## Phase 6: User Story 4 - 环境配置 (Priority: P4)

**Goal**: 读者能够使用 ProcessInfo、swift-dotenv 安全管理配置参数

**Independent Test**: `mdbook build Docs/` succeeds, chapter has 15 sections, covers .env loading

**Source Reference**: `AdvanceSample/Sources/AdvanceSample/DotenvySample.swift` (processInfoEnvSample, dotenvSample)

### Implementation for User Story 4

- [X] T039 [US4] Write 开篇故事 section introducing environment config analogy in `Docs/src/advance/environment.md`
- [X] T040 [US4] Write 本章适合谁 + 你会学到什么 + 前置要求 sections in `Docs/src/advance/environment.md`
- [X] T041 [US4] Write 第一个例子 section with ProcessInfo example from `AdvanceSample/Sources/AdvanceSample/DotenvySample.swift:10-27` in `Docs/src/advance/environment.md`
- [X] T042 [US4] Write 原理解析 section explaining ProcessInfo vs Dotenv.configure() in `Docs/src/advance/environment.md`
- [X] T043 [US4] Write 常见错误 section with 3+ errors (.env missing, format error, dynamic lookup) in `Docs/src/advance/environment.md`
- [X] T044 [US4] Write Swift vs Rust/Python 对比表 section in `Docs/src/advance/environment.md`
- [X] T045 [US4] Write 动手练习 Level 1-3 sections with hidden solutions in `Docs/src/advance/environment.md`
- [X] T046 [US4] Write 故障排查 FAQ section with 5+ Q&A pairs in `Docs/src/advance/environment.md`
- [X] T047 [US4] Write 小结 + 术语表 + 知识检查 sections in `Docs/src/advance/environment.md`
- [X] T048 [US4] Write 继续学习 navigation section linking to review chapter in `Docs/src/advance/environment.md`
- [X] T049 [US4] Validate chapter: verify 15 sections, 500+ chars, 3+ exercises, 3+ quizzes

**Checkpoint**: All 4 user stories complete - full Advance section independently functional

---

## Phase 7: Polish & Validation

**Purpose**: Final validation and quality checks across all chapters

- [X] T050 Run `mdbook build Docs/` to verify zero errors, zero warnings
- [X] T051 Run `swift build` to verify all source references compile
- [X] T052 Verify all SUMMARY.md links resolve correctly
- [X] T053 Verify each chapter has Swift vs Rust/Python comparison table
- [X] T054 Verify each chapter has 3+ exercises with hidden solutions
- [X] T055 Run quickstart.md validation checklist
- [X] T056 Preview docs via `mdbook serve Docs/` and manual review

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Should complete after understanding all topics (but can run parallel with US1)
- **User Stories (Phase 3-6)**: Can proceed in parallel after Setup
  - Each story is independent (different chapter files)
  - Can be written sequentially in priority order (P1 → P2 → P3 → P4)
- **Polish (Phase 7)**: Depends on all user stories complete

### User Story Dependencies

- **User Story 1 (P1)**: Independent - `json.md` is standalone file
- **User Story 2 (P2)**: Independent - `file-operations.md` is standalone file
- **User Story 3 (P3)**: Independent - `swift-data.md` is standalone file
- **User Story 4 (P4)**: Independent - `environment.md` is standalone file

### Parallel Opportunities

- All Setup tasks (T001-T003) can run in sequence (same file dependencies)
- Foundational tasks (T004-T005) can run in parallel with first user story
- Once Setup complete, all 4 user stories can be written in parallel (4 different chapter files)
- Within a user story, tasks T006-T015 must be sequential (same file sections)
- All validation tasks (T050-T056) can run in parallel at end

---

## Parallel Example: User Stories

```bash
# After Setup complete, launch all chapters in parallel:
Task: "Write JSON chapter in Docs/src/advance/json.md"       # US1
Task: "Write File chapter in Docs/src/advance/file-operations.md"  # US2
Task: "Write SwiftData chapter in Docs/src/advance/swift-data.md" # US3
Task: "Write Environment chapter in Docs/src/advance/environment.md" # US4

# Each chapter file is independent - can be delegated to different agents
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (delete advance.md, update overview, update SUMMARY)
2. Complete Phase 3: User Story 1 (json.md)
3. Run validation: `mdbook build Docs/`
4. Preview and review JSON chapter
5. **STOP** - MVP ready for early review

### Incremental Delivery

1. Setup → User Story 1 → Validate (JSON chapter complete)
2. Add User Story 2 → Validate (File chapter complete)
3. Add User Story 3 → Validate (SwiftData chapter complete)
4. Add User Story 4 → Validate (Environment chapter complete)
5. Foundational (glossary + review) → Final Polish → Complete

### Delegation Strategy

With parallel agents:

1. Agent A: User Story 1 (json.md) - 11 tasks
2. Agent B: User Story 2 (file-operations.md) - 11 tasks
3. Agent C: User Story 3 (swift-data.md) - 11 tasks
4. Agent D: User Story 4 (environment.md) - 11 tasks
5. After all chapters: Foundational + Polish tasks

---

## Task Summary

| Phase | Tasks | Parallelizable |
|-------|-------|----------------|
| Phase 1: Setup | 3 | T001-T003 sequential |
| Phase 2: Foundational | 2 | T004-T005 parallel |
| Phase 3: US1 (JSON) | 11 | Sequential (same file) |
| Phase 4: US2 (File) | 11 | Sequential (same file) |
| Phase 5: US3 (SwiftData) | 11 | Sequential (same file) |
| Phase 6: US4 (Environment) | 11 | Sequential (same file) |
| Phase 7: Polish | 7 | T050-T056 parallel |
| **Total** | **56** | **Parallel across stories** |

---

## Notes

- This is a **documentation-only** feature - no Swift code changes needed
- All chapters reference existing source in `AdvanceSample/Sources/AdvanceSample/`
- Each chapter follows 15-section hello-rust template
- Chinese primary language with English technical terms
- Validation via `mdbook build Docs/` and `swift build`
- Manual review recommended after each chapter completion
- User can commit at any checkpoint for incremental delivery