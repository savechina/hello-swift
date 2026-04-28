# Implementation Plan: Swift Advance Tutorial Content Generation (Phase 2 Expansion)

**Branch**: `002-swift-advance-tutorials` | **Date**: 2026-04-27 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/Docs/specs/002-swift-advance-tutorials/spec.md`
**Phase 1 Status**: ✅ COMPLETE (56 tasks, 4 chapters)
**Phase 2 Status**: Pending (60 tasks, 4 new chapters + source files)

## Summary

Expand Swift Advance tutorial from 4 chapters to 7-8 chapters by adding SwiftNIO async networking (2 chapters), system programming with Swift System Package and Process management (1 chapter), and XCTest testing framework (1 chapter). Phase 2 requires new source files (SwiftNIOSample.swift, SystemSample.swift, ProcessSample.swift, TestingSampleTests.swift) before documentation can reference them. Cross-platform priority ensures macOS and Linux compatibility.

## Technical Context

**Language/Version**: Swift 6.0 with Strict Concurrency checking  
**Primary Dependencies**: 
- Phase 1: SwiftyJSON 5.0.2+, swift-dotenv 2.0.0+, SwiftData (Apple framework macOS 14+)
- Phase 2: swift-nio 2.92.0+ (already declared in Package.swift), Swift System Package (new), XCTest (built-in)
**Storage**: SwiftData (ModelContainer SQLite), FileManager paths, swift-nio ByteBuffer  
**Testing**: swift build (compilation), swift test (XCTest), mdbook build Docs/ (documentation)  
**Target Platform**: macOS 12.0+ (Monterey) primary, macOS 14+ (Sonoma) for SwiftData, Linux (partial - no SwiftData)  
**Project Type**: Documentation + Source Code (Phase 2 adds 4 new Swift files)  
**Performance Goals**: mdBook build <30s per chapter, swift-nio Echo Server response <10ms  
**Constraints**: Chinese primary language, cross-platform (macOS/Linux), Swift 6.0 Strict Concurrency  
**Scale/Scope**: Phase 1 (4 chapters, 56 tasks) ✅ COMPLETE, Phase 2 (4 new chapters + 4 source files, 60 tasks)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Requirement | Status | Notes |
|-----------|-------------|--------|-------|
| I. Code Quality | Swift 6.0 Strict Concurrency | ✅ PASS | Phase 2 source files must conform to Sendable, actor isolation |
| I. Code Quality | Zero compiler warnings | ✅ PASS | New source files must compile clean |
| I. Code Quality | Documentation comments on public APIs | ⚠️ REVIEW | New source files need `///` comments |
| I. Code Quality | No force unwrap without invariant | ⚠️ REVIEW | New source files must avoid `!` without documented invariant |
| II. Test-First Development | Tests written before implementation | ⚠️ REVIEW | TestingSampleTests.swift is educational example (not production) |
| III. User Experience | Chinese primary + English terms | ✅ PASS | All chapters use Chinese with English parentheses |
| III. User Experience | 12-section template (15-section approved) | ✅ PASS | FR-002 allows hello-rust 15-section template |
| III. User Experience | 3+ code examples, 3+ quizzes | ✅ PASS | FR-007 requires this |
| III. User Experience | GitHub links to source | ⚠️ REVIEW | Phase 2 chapters need links to NEW source files |
| III. User Experience | mdbook build zero errors | ✅ PASS | FR-009 requires this |
| IV. Performance | No blocking in async | ⚠️ REVIEW | SwiftNIO examples must use proper EventLoop non-blocking |
| IV. Performance | Streaming for large datasets | ✅ PASS | Not applicable for tutorial examples |
| V. SDD Harness | Manual commit policy | ✅ PASS | No auto-commits, user reviews all changes |

**Gate Result**: ✅ PASS - No blocking violations. Phase 2 source files require review for Swift 6.0 Strict Concurrency compliance.

## Project Structure

### Documentation (Phase 2 - new files)

```text
Docs/specs/002-swift-advance-tutorials/
├── spec.md              # UPDATED: Added US5-US7, Clarifications, Phase 2 requirements
├── plan.md              # This file (Phase 2 expansion)
├── research.md          # NEEDS UPDATE: Add Phase 2 SwiftNIO/System decisions
├── data-model.md        # COMPLETE (Phase 1)
├── quickstart.md        # NEEDS UPDATE: Add Phase 2 setup steps
├── tasks.md             # UPDATED: Phase 1 (56 ✅), Phase 2 (60 pending)
└── checklists/
    └── requirements.md  # COMPLETE (Phase 1)

Docs/src/advance/
├── advance-overview.md  # NEEDS UPDATE: Expand chapter table (7-8 chapters)
├── json.md              # ✅ COMPLETE (Phase 1)
├── file-operations.md   # ✅ COMPLETE (Phase 1)
├── swift-data.md        # ✅ COMPLETE (Phase 1)
├── environment.md       # ✅ COMPLETE (Phase 1)
├── swift-nio-basics.md  # NEW: SwiftNIO fundamentals chapter
├── swift-nio-async.md   # NEW: SwiftNIO async/await integration chapter
├── system-programming.md # NEW: System + Process chapter
├── testing.md           # NEW: XCTest chapter
├── glossary-advance.md  # NEEDS UPDATE: Add Phase 2 terms
└── review-advance.md    # NEEDS UPDATE: Add Phase 2 quiz questions

Docs/src/SUMMARY.md      # NEEDS UPDATE: Add Phase 2 chapter navigation
```

### Source Code (Phase 2 - new files)

```text
AdvanceSample/Sources/AdvanceSample/
├── AdvanceSample.swift      # NEEDS UPDATE: Call new sample functions
├── FileOperationSample.swift # ✅ EXISTS (Phase 1 reference)
├── SwiftDataSample.swift    # ✅ EXISTS (Phase 1 reference)
├── DotenvySample.swift      # ✅ EXISTS (Phase 1 reference)
├── SwiftNIOSample.swift     # NEW: Echo Server example
├── SystemSample.swift       # NEW: Swift System Package example
└── ProcessSample.swift      # NEW: Process execution example

Tests/AdvanceSampleTests/
├── AdvanceSampleTests.swift # ✅ EXISTS
└── TestingSampleTests.swift # NEW: XCTest patterns example
```

**Structure Decision**: Phase 2 adds 4 source files (3 in AdvanceSample/Sources/, 1 in Tests/) and 4 documentation chapters. Source files MUST be created and compile BEFORE documentation references them (Phase 8 prerequisite).

## Complexity Tracking

> Phase 2 adds SwiftNIO (already declared dependency) and Process (Foundation built-in). Swift System Package may need new dependency declaration.

| New Dependency | Why Needed | Alternatives Considered |
|----------------|------------|------------------------|
| Swift System Package | Cross-platform file/path abstraction | FileManager (platform-specific), POSIX direct calls (complex) |
| swift-nio 2.92.0+ | Already declared in AdvanceSample/Package.swift | Vapor (too heavy), Hummingbird (not in dependencies) |

## Phase 2 Research Questions (NEEDS CLARIFICATION)

1. **Swift System Package**: Is it already declared in AdvanceSample/Package.swift? If not, need to add dependency.
2. **SwiftNIO Echo Server**: Simplest example pattern for tutorial (ServerBootstrap + EchoHandler)?
3. **Process Signal Handling**: Foundation Signal API vs Darwin-specific signal handling?
4. **XCTest async test**: XCTestCase async test method patterns for Swift 6.0?
5. **Cross-platform verification**: How to verify swift-nio/System compile on Linux without Linux environment?

## Phase 2 Implementation Strategy

### Phase 8: Source Code Creation (Prerequisite)

**Order**: Source files MUST exist before documentation references them.

| Task ID | File | Purpose |
|---------|------|---------|
| T057 | SwiftNIOSample.swift | Echo Server with ServerBootstrap, ChannelHandler, ByteBuffer |
| T058 | SystemSample.swift | Swift System Package FilePath, cross-platform file operations |
| T059 | ProcessSample.swift | Process execution, stdout/stderr capture, error handling |
| T060 | AdvanceSample.swift | Update to call new sample functions |
| T061 | TestingSampleTests.swift | XCTestCase async test patterns |

**Build Verification**: `swift build` MUST pass after Phase 8 completion.

### Phase 9-11: Documentation Chapters

**Parallel Strategy**: After Phase 8, chapters can be written in parallel:
- US5 (SwiftNIO basics + async) = 2 chapters, 22 tasks
- US6 (System programming) = 1 chapter, 11 tasks
- US7 (Testing) = 1 chapter, 11 tasks

### Phase 12: Polish & Cross-Cutting

- Update advance-overview.md with expanded table
- Update SUMMARY.md navigation
- Update glossary-advance.md with Phase 2 terms
- Update review-advance.md with Phase 2 quizzes
- Final validation: `mdbook build Docs/`, `swift build`, `swift test`

## Dependencies & Execution Order

### Phase 2 Dependencies

- **Phase 8 (Source)**: BLOCKS Phase 9-11 (documentation cannot reference non-existent files)
- **Phase 9-11 (Chapters)**: Can proceed in parallel after Phase 8
- **Phase 12 (Polish)**: Depends on Phase 9-11 complete

### Cross-Platform Verification

- SwiftNIO: Already declared in AdvanceSample/Package.swift, should compile on macOS + Linux
- Swift System Package: Need to verify if declared; if not, add to Package.swift
- Process: Foundation built-in, works on macOS + Linux
- XCTest: swift test built-in, works on macOS + Linux

## Task Summary

| Phase | Tasks | Status | Dependencies |
|-------|-------|--------|--------------|
| Phase 1-7 (Phase 1) | 56 | ✅ COMPLETE | None |
| Phase 8 (Source Setup) | 7 | Pending | None (start immediately) |
| Phase 9 (US5 SwiftNIO) | 22 | Pending | Phase 8 |
| Phase 10 (US6 System) | 11 | Pending | Phase 8 |
| Phase 11 (US7 Testing) | 11 | Pending | Phase 8 |
| Phase 12 (Polish) | 9 | Pending | Phase 9-11 |
| **Phase 2 Total** | **60** | **Pending** | |
| **Grand Total** | **116** | **56 ✅, 60 pending** | |

## Next Steps

1. **Phase 8**: Create SwiftNIOSample.swift, SystemSample.swift, ProcessSample.swift, TestingSampleTests.swift
2. **Build Verification**: Run `swift build` to verify new source compiles
3. **Phase 9-11**: Write documentation chapters (can delegate to parallel agents)
4. **Phase 12**: Update navigation, glossary, review + final validation

---

## Notes

- Phase 1 (56 tasks) ✅ COMPLETE - JSON, File, SwiftData, Environment chapters
- Phase 2 (60 tasks) pending - SwiftNIO, System, Testing chapters + source files
- Source code creation is prerequisite for documentation (Phase 8 first)
- SwiftNIO already declared in Package.swift (advance dependency exists)
- Swift System Package may need dependency addition
- Manual commit policy applies - user reviews all changes before commit