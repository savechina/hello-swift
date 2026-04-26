# Implementation Plan: Swift Basic Tutorial Content Generation

**Branch**: `001-swift-basic-tutorials` | **Date**: 2026-04-26 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/Docs/specs/001-swift-basic-tutorials/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Generate 12 structured Chinese-language tutorial chapters (mdBook format) for Swift basic programming, mirroring the language style and document structure from hello-rust's tutorial (emoji headers, foldable answers, cross-language comparison tables, industrial usage scenarios, knowledge checks). Each chapter maps to existing `Sources/BasicSample/` code files. The output replaces the currently empty `Docs/src/basic/basic.md` with individual `.md` files per chapter.

## Technical Context

**Language/Version**: Swift 6.0 (swift-tools-version: 6.0)
**Primary Dependencies**: swift-argument-parser (CLI), swift-log, SwiftyBeaver (logging) — existing SPM dependencies in Package.swift
**Storage**: N/A — documentation-only feature
**Testing**: XCT test framework (existing HelloSampleTests, AlgoSampleTests); `swift test` for build validation
**Target Platform**: macOS (primary) and Linux (Swift 6.0 compatible)
**Project Type**: CLI tool + documentation (mdBook tutorial)
**Performance Goals**: `swift build --package-path .` compiles all sample code in <30s; `mdbook build Docs/` completes in <5 minutes
**Constraints**: All code examples must compile; no new SPM targets created; content must match existing `BasicSample/` source files (12 .swift files already present)
**Scale/Scope**: 12 tutorial chapters across `Docs/src/basic/`, targeting 8 hours total reading time

### Existing Code-to-Chapter Mapping

| # | Tutorial Chapter (中文)                    | Swift Source File                        | Status    |
|---|------------------------------------------- | --------------------------------------- | --------- |
| 1 | 变量与表达式                                | `ExpressionSample.swift`                | ✅ exists |
| 2 | 基础数据类型                                | `DatatypeSample.swift`                  | ✅ exists |
| 3 | 控制流                                      | `ControlFlowSample.swift` (new)    | ⚠️ new     |
| 4 | 函数                                        | `FunctionSample.swift`             | ⚠️ missing |
| 5 | 枚举                                        | `EnumSample.swift`                 | ⚠️ missing |
| 6 | 结构体                                      | `ClassSample.swift`                     | ✅ exists |
| 7 | 类与对象                                    | `ClassSample.swift`                     | ✅ exists |
| 8 | 协议                                        | `ExampleProtocol.swift`                 | ✅ exists |
| 9 | 泛型                                        | `GenericSample.swift`                   | ✅ exists |
| 10| 错误处理                                    | `ErrorsSample.swift`                    | ✅ exists |
| 11| 闭包                                        | `BasicSample.swift` (includes closures) | ✅ exists |
| 12| 并发编程                                    | `ConcurrencySample.swift`               | ✅ exists |

### Additional Existing Files (Advance/Review)

| Chapter                                | Swift Source File              | Status    |
|--------------------------------------- | ------------------------------ | --------- |
| 访问控制 (可见性)                        | `VisibleSample.swift`          | ✅ exists |
| 日志记录                                | `LoggerSample.swift`, `SwiftyBeaverLogHandler.swift` | ✅ exists |
| 模块系统                                | `ModuleSample/`                | ✅ exists |
| 阶段复习：基础部分                        | _(review chapter)_             | ⚠️ new    |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle                            | Status  | Evidence |
|------------------------------------- | ------- | -------- |
| **I. Code Quality**: Swift 6.0 idioms, no force unwrap, `swiftlint` clean | ✅ PASS | Code examples in `BasicSample/` already follow Swift 6.0 conventions. No `!` force unwraps in existing code |
| **II. Test-First**: >80% coverage, `swift test` passes | ✅ PASS | Existing `HelloSampleTests` and `AlgoSampleTests`. No new test requirements for documentation feature |
| **III. UX Consistency**: Chinese primary language, English technical terms, `--help` completeness | ✅ PASS | FR-004 and FR-006 directly enforce Chinese-first style with English parentheticals |
| **IV. Performance**: <50ms CLI startup, mdBook build <5 minutes | ✅ PASS | Documentation-only feature; `mdbook build` performance constraint tracked |
| **V. SDD Harness**: 8-phase workflow, triple quality gates | ✅ PASS | Plan follows speckit phases. `/speckit.tasks` and `/speckit.implement` will follow |

## Project Structure

### Documentation (this feature)

```text
Docs/specs/001-swift-basic-tutorials/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
Docs/src/
├── basic/
│   ├── basic-overview.md     ← 基础部分概览页 (like hello-rust)
│   ├── expression.md         ← 变量与表达式
│   ├── datatype.md           ← 基础数据类型
│   ├── control-flow.md       ← 控制流 (if/else, switch, for-in, while)
│   ├── functions.md          ← 函数
│   ├── enums.md              ← 枚举
│   ├── structs.md            ← 结构体
│   ├── classes-objects.md    ← 类与对象
│   ├── protocols.md          ← 协议
│   ├── generics.md           ← 泛型
│   ├── error-handling.md     ← 错误处理
│   ├── closures.md           ← 闭包
│   ├── concurrency.md        ← 并发编程 (async/await, Actor, Task)
│   └── review-basic.md       ← 阶段复习 (optional)
```

**Structure Decision**: Single mdBook project. All tutorial chapters go into `Docs/src/basic/` directory. Each chapter maps to one or more existing `Sources/BasicSample/` Swift files. No new SPM targets are created.

**Missing Swift Source Files** (require creation alongside docs):
- `Sources/BasicSample/ControlFlowSample.swift` — for 控制流 chapter (separate from DatatypeSample for clarity)
- `Sources/BasicSample/FunctionSample.swift` — for 函数 chapter
- `Sources/BasicSample/EnumSample.swift` — for 枚举 chapter

These are code-first tasks: the sample code must exist before the corresponding documentation can be written.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No violations detected. All 5 constitution principles pass.
