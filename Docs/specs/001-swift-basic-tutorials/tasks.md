---

description: "Task list for generating Swift basic tutorial documentation"
---

# Tasks: Swift Basic Tutorial Content Generation

**Input**: Design documents from `/Docs/specs/001-swift-basic-tutorials/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Tests**: This is a documentation feature. "Testing" = `swift build` compilation + `mdbook build Docs/` validation gates per constitution principles. No separate unit test tasks generated.

**Organization**: Tasks are grouped by user story to enable independent writing and review of each story's chapters. Each user story delivers a complete, independently reviewable set of tutorial chapters.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Documentation**: `Docs/src/basic/` — mdBook chapter markdown files
- **Source Code**: `Sources/BasicSample/` — Swift sample code files referenced by tutorials
- **Config**: `Docs/book.toml` — mdBook configuration
- **Navigation**: `Docs/src/SUMMARY.md` — mdBook table of contents

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create chapter template and directory scaffold

- [x] T001 Create chapter template reference document in `Docs/specs/001-swift-basic-tutorials/chapter-template.md` — capture the 12-section structure copied from hello-rust (开篇故事、你会学到什么、前置要求、第一个例子、原理解析、常见错误、动手练习、知识扩展、小结、术语表、知识检查、延伸阅读)
- [x] T002 [P] Verify existing `Sources/BasicSample/*.swift` files compile with `swift build` — list all 12 existing files and note which are missing

**Checkpoint**: Directory scaffold ready, existing code verified compiling — chapter writing can begin

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create missing Swift source files that tutorial chapters depend on

**⚠️ CRITICAL**: US1's functions chapter and US2's enums chapter cannot be written until these source files exist.

- [x] T003 Create `Sources/BasicSample/FunctionSample.swift` — demonstrating Swift function syntax: parameter names (`name`/`_`) and argument labels, default parameters, variadic parameters, inout parameters, multiple return types (tuples), nested functions, closure expression syntax. Follow existing `ExpressionSample.swift` logging pattern (`startSample`/`endSample`).
- [x] T004 [P] Create `Sources/BasicSample/EnumSample.swift` — demonstrating Swift enum features: basic enum, associated values (like Result<Success, Failure>), raw values, pattern matching with switch, recursive enums with `indirect`, enum methods and computed properties, CaseIterable conformance. Follow existing `ExpressionSample.swift` logging pattern.
- [x] T005 Verify `swift build` passes with zero warnings after adding FunctionSample.swift and EnumSample.swift

**Checkpoint**: All 14 Swift source files compile — tutorial writing can begin without gaps

---

## Phase 3: User Story 1 — 学习 Swift 基础语法 (Priority: P1) 🎯 MVP

**Goal**: Deliver chapters 1-4 covering Swift basic syntax (variables, types, control flow, functions) — the core beginner content.

**Independent Test**: A reader can complete these 4 chapters in sequence, compile every inline code example, and write a simple Swift program with variables, conditionals, loops, and functions.

### Implementation for User Story 1

- [x] T006 [P] [US1] Create `Sources/BasicSample/ControlFlowSample.swift` — demonstrating if/else, switch/case with pattern matching, for-in (ranges, arrays, dictionaries), while/repeat-while, labeled statements, guard. Follow existing `ExpressionSample.swift` logging pattern. *(Dedicated file for control flow, separate from DatatypeSample.)*
- [x] T007 [US1] Write `Docs/src/basic/basic-overview.md` — 基础部分概览页: learning objectives, chapter table (难度+预计时间), learning path diagram, prerequisites, check-in points. Mirror hello-rust's `basic-overview.md` structure.
- [x] T008 [US1] Write `Docs/src/basic/expression.md` — 变量与表达式: cover `let` vs `var`, `let` immutability as default, variable shadowing, `print()` with string interpolation, basic arithmetic. Include: opening story, 3+ code examples, Swift vs Rust vs Python comparison table, 3 common compiler errors (`cannot assign to value`, `unused variable`), 3 exercises, glossary, 3 knowledge checks. Reference `Sources/BasicSample/ExpressionSample.swift`.
- [x] T009 [US1] Write `Docs/src/basic/datatype.md` — 基础数据类型: cover Int/UInt families, Float vs Double, Bool, String (interpolation, concatenation), Array/Set/Dictionary, tuples, type inference vs explicit types, Optionals introduction (`?` syntax). Include: 3+ code examples, Swift vs Rust type comparison (strong typing), 3 common errors (type mismatch, optional unwrapping), 3 exercises, glossary, 3 knowledge checks. Reference `Sources/BasicSample/DatatypeSample.swift`.
- [x] T010 [US1] Write `Docs/src/basic/control-flow.md` — 控制流: cover if/else conditions, switch/case with exhaustiveness + pattern matching, for-in (ranges, sequences, stride), while/repeat-while, guard statements, labeled loops/break/continue. Include: 3+ code examples, Swift vs Rust control flow comparison (no ternary, guard vs if-let), 3 common errors (non-exhaustive switch), 3 exercises, glossary, 3 knowledge checks. Reference `Sources/BasicSample/ControlFlowSample.swift`.
- [x] T011 [US1] Write `Docs/src/basic/functions.md` — 函数: cover `func` keyword, parameter labels (`name`/`_`), default values, variadic parameters, `inout` parameters, multiple return types (tuples), function types as parameters/return values, nested functions, @escaping. Include: 3+ code examples, Swift vs Rust/Python function comparison (parameter labels unique to Swift), 3 common errors (missing return type, label mismatch), 3 exercises, glossary, 3 knowledge checks. Reference `Sources/BasicSample/FunctionSample.swift`.
- [x] T012 [US1] Update `Docs/src/SUMMARY.md` — replace placeholder `[Basic Chapter]` with nested structure for chapters 1-4 (expression, datatype, control-flow, functions) with difficulty labels (🟢)

**Checkpoint**: At this point, US1 delivers 4 complete chapters + overview page + updated SUMMARY.md — a beginner can learn Swift basics from scratch

---

## Phase 4: User Story 2 — 理解 Swift 类型系统 (Priority: P2)

**Goal**: Deliver chapters 5-9 covering Swift's type system (enums, structs, classes, protocols, generics).

**Independent Test**: A reader can use enums to model multi-state data, choose between structs and classes correctly, define protocol interfaces, and write generic functions.

### Implementation for User Story 2

- [x] T013 [P] [US2] Write `Docs/src/basic/enums.md` — 枚举: cover basic enum definition, associated values (with Result<Success, Error> example), raw values (String/Int auto-assignment), pattern matching with switch, `indirect` recursive enums, enum methods and computed properties, CaseIterable protocol, optionals as syntactic sugar for `Optional<T>` enum. Include: 3+ code examples, Swift vs Rust enum comparison (Rust's `enum` = Swift's `enum`, associated values match), 3 common errors (exhaustive switch missing case), 3 exercises, glossary, 3 knowledge checks. Reference `Sources/BasicSample/EnumSample.swift`.
- [x] T014 [P] [US2] Write `Docs/src/basic/structs.md` — 结构体: cover struct definition and initialization, stored vs computed properties, property observers (`willSet`/`didSet`), value-type semantics (copy-on-write), `mutating` methods, memberwise initializers, static properties/methods, struct vs enum use cases. Include: 3+ code examples, Swift vs Rust struct comparison (Swift struct has copy semantics, no move semantics), 3 common errors (mutating method on `let` instance), 3 exercises, glossary, 3 knowledge checks. Reference `Sources/BasicSample/ClassSample.swift` (struct portion).
- [x] T015 [US2] Write `Docs/src/basic/classes-objects.md` — 类与对象: cover class definition and inheritance, designated vs convenience initializers, `deinit`, reference-type semantics, value vs reference type comparison, identity operators (`===`/`!==`), type casting (`is`, `as?`, `as!`, `as`), weak/unowned references for ARC. Include: 3+ code examples, Swift vs Rust class comparison (Rust has no classes — use struct+trait), 3 common errors (retain cycles, nil in force-unwrap), 3 exercises, glossary, 3 knowledge checks. Reference `Sources/BasicSample/ClassSample.swift` (class portion).
- [x] T016 [US2] Write `Docs/src/basic/protocols.md` — 协议: cover protocol definition (like interfaces), conforming types (struct, class, enum), protocol extensions with default implementations, protocol as types, Protocol-Oriented Programming (POP) philosophy, associated types (`associatedtype`), protocol composition (`ProtocolA & ProtocolB`), `some` keyword (opaque types). Include: 3+ code examples, Swift vs Rust trait comparison (associatedtype vs generics, POP vs trait-based), 3 common errors (associated type ambiguity), 3 exercises, glossary, 3 knowledge checks. Reference `Sources/BasicSample/ExampleProtocol.swift`.
- [x] T017 [US2] Write `Docs/src/basic/generics.md` — 泛型: cover generic function syntax `<T>`, generic type constraints (`T: Equatable`), where clauses, associated types in protocols, generic structs/enums, protocol vs generics tradeoffs. Include: 3+ code examples, Swift vs Rust generic comparison (generics vs traits, `where` clause similarity), 3 common errors (constraint violation), 3 exercises, glossary, 3 knowledge checks. Reference `Sources/BasicSample/GenericSample.swift`.
- [x] T018 [US2] Update `Docs/src/SUMMARY.md` — add nested structure for chapters 5-9 (enums, structs, classes-objects, protocols, generics) with difficulty labels (🟡)

**Checkpoint**: US1 AND US2 deliver 9 complete chapters — reader understands Swift's complete type system

---

## Phase 5: User Story 3 — 掌握 Swift 并发编程 (Priority: P3)

**Goal**: Deliver chapters 10-12 covering error handling, closures, and Swift 6.0 concurrency.

**Independent Test**: A reader can handle errors with `do/catch/try`, write closures with capture semantics, and use `async/await`, `Actor`, and `Task` for concurrent Swift code.

### Implementation for User Story 3

- [x] T019 [US3] Write `Docs/src/basic/error-handling.md` — 错误处理: cover `Error` protocol, `do/catch/try` patterns, `throws` keyword, `try?` and `try!`, custom error types with associated values, rethrow functions, `defer` blocks, Result type as alternative to throwing. Include: 3+ code examples, Swift vs Rust error comparison (`Result`/`?` operator vs Swift's `throws`), 3 common errors (unhandled throwing call), 3 exercises, glossary, 3 knowledge checks. Reference `Sources/BasicSample/ErrorsSample.swift`.
- [x] T020 [US3] Write `Docs/src/basic/closures.md` — 闭包: cover closure expression syntax (`{ }`), trailing closure syntax, capturing values, escaping vs non-escaping closures, autoclosures, closure type aliases, higher-order functions (`map`, `filter`, `reduce`, `sorted`). Include: 3+ code examples, Swift vs Rust closure comparison (capture semantics, `@escaping` vs move), 3 common errors (escaping closure captures mutating `self`), 3 exercises, glossary, 3 knowledge checks. Reference closure uses in `Sources/BasicSample/BasicSample.swift`.
- [x] T021 [US3] Write `Docs/src/basic/concurrency.md` — 并发编程: cover `async`/`await` syntax, `Task` and `Task.detached`, `TaskGroup` for parallel work, `@MainActor` and actor isolation, `Sendable` protocol requirements, Swift 6.0 Strict Concurrency as compile-time guarantee, `AsyncSequence`, `withCheckedContinuation` for bridging C callbacks, `actor` definition. Include: 3+ code examples, Swift vs Rust concurrency comparison (Swift async/await vs tokio runtime, actor vs Mutex), 3 common errors (Sendable violation, main actor isolation), 3 exercises, glossary, 3 knowledge checks. Reference `Sources/BasicSample/ConcurrencySample.swift`.
- [x] T022 [US3] Update `Docs/src/SUMMARY.md` — add nested structure for chapters 10-12 (error-handling, closures, concurrency) with difficulty labels (🟡/🔴)

**Checkpoint**: All 12 basic chapters complete — full beginner-to-intermediate Swift curriculum delivered

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Cross-cutting cleanup, build validation, and documentation quality polish

- [x] T023 Create `Docs/src/basic/review-basic.md` — 阶段复习: comprehensive review of all 12 chapters with summary of key concepts, cross-chapter exercises, "can you answer these" self-assessment checklist, links to [高级进阶](../advance/advance-overview.md) next steps
- [x] T024 [P] Validate all internal cross-links: run `mdbook build Docs/` and verify zero link errors, fix any broken `../some-chapter.md` references across all 14 markdown files
- [x] T025 [P] Validate code compilation: run `swift build` on root Package.swift and all nested packages to confirm every referenced source file compiles with zero warnings
- [x] T026 Add GitHub source links to each chapter's footer: link from doc chapter to corresponding `Sources/BasicSample/*.swift` file on `https://github.com/savechina/hello-swift/blob/main/`
- [x] T027 Run `mdbook build Docs/` — must produce zero errors and zero warnings; fix any remaining issues (broken links, syntax highlighting failures)
- [x] T028 Create `Docs/src/basic/glossary.md` — consolidated bilingual glossary of all 20+ Swift technical terms used across 12 chapters
- [x] T029 Validate all 12 mandatory sections across every chapter (per FR-002): for each of the 12 chapter files, verify presence of 开篇故事、你会学到什么、前置要求、第一个例子、原理解析、常见错误与修复、动手练习、知识检查、术语表 — mark any missing section as failed validation

**Checkpoint**: All quality gates passed — 12 chapters + overview + review + glossary, mdBook builds cleanly

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all user stories that reference missing source files
- **User Stories (Phase 3-5)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) — No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) — No dependencies on US1 chapters (each is independent)
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) — No dependencies on US1/US2 chapters

### Within Each User Story

- Overview/review pages before or after individual chapters (independent of chapter order)
- Summary.md updates after their respective chapters complete
- Each chapter is self-contained and can be written in parallel with siblings in the same story

### Parallel Opportunities

- T001-T002 in Setup can run independently
- T003-T004 in Foundational can run in parallel (different Swift files)
- Within each US phase: all chapter-writing tasks marked [P] can run in parallel (different `.md` files)
- T007-T011 (US1) can run in parallel
- T013-T017 (US2) can run in parallel
- T019-T021 (US3) can run in parallel
- T024-T025 (Polish) can run in parallel (build vs link check)

---

## Parallel Example: User Story 1

```bash
# Launch all chapter writing for US1 together:
task: "Write Docs/src/basic/expression.md — 变量与表达式"
task: "Write Docs/src/basic/datatype.md — 基础数据类型"
task: "Write Docs/src/basic/control-flow.md — 控制流"
task: "Write Docs/src/basic/functions.md — 函数"

# These are independent .md files with no cross-references between chapters.
# Only the SUMMARY.md and overview updates (T007, T012) must wait for chapters.
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL — blocks FunctionSample.swift)
3. Complete Phase 3: User Story 1 (4 chapters + overview)
4. **STOP and VALIDATE**: Run `mdbook build Docs/` — 4 chapters render correctly, links valid, SUMMARY.md navigable
5. Deploy/demo if ready — beginner readers can now learn Swift basics

### Incremental Delivery

1. Setup + Foundational → scaffold ready, all source files compile
2. Add US1 → Test mdbook build independently → Review first 4 chapters
3. Add US2 → Test mdbook build independently → Review type-system chapters
4. Add US3 → Test mdbook build independently → Review concurrency chapters
5. Polish → Final mdbook build passes with zero errors/warnings
6. Each story adds value without breaking previous chapters

### Parallel Team Strategy

With multiple writers/reviewers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Writer A: US1 (4 chapters — variables through functions)
   - Writer B: US2 (5 chapters — enums through generics)
   - Writer C: US3 (3 chapters — errors, closures, concurrency)
3. All polish tasks run after story completion
4. Each story's chapters are independently reviewable

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable (via mdbook build)
- No tests requested — compile and doc build are the validation gates
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
- All chapters follow hello-rust's 12-section template structure
