<!--
SYNC IMPACT REPORT
==================
Version Change: 1.1.1 → 2.0.0 (MAJOR: Full rewrite from Rust to Swift governance)
Modified Principles:
  - I. Code Quality: Rust 2024 idioms → Swift 6.0 Strict Concurrency + Sendable
  - II. Test-First Development: Rust tooling (proptest, criterion) → Swift Testing + XCTest
  - III. User Experience Consistency: Rust CLI (clap) → Swift ArgumentParser
  - IV. Performance Requirements: Rust async/runtime → Swift Concurrency (async/await, Actors)
  - V. SDD Harness Engineering: Rust toolchain → Swift Package Manager + Xcode tooling
Added Sections:
  - Swift 6.0 Strict Concurrency requirements (Sendable, actor isolation)
  - Swift Package Manager multi-package workspace conventions
  - Xcode project + CocoaPods integration guidance
  - Swift Testing framework (Xcode 16+) alongside XCTest
  - SwiftLint + SwiftFormat quality gates
  - Protocol-Oriented Programming (POP) as first-class design pattern
  - Nested SPM package architecture (AdvanceSample, AwesomeSample, LeetCodeSample)
Removed Sections:
  - Rust-specific: cargo clippy, cargo fmt, cargo test, cargo-nextest, cargo-tarpaulin
  - Rust async runtime: tokio, tokio::spawn_blocking, unbounded channels
  - Rust web framework: Axum, Tonic, SQLx, Diesel, rumqttc
  - Rust property-based testing: proptest
  - Rust benchmarking: criterion
  - Rust security: cargo-deny, cargo-audit
Templates Requiring Updates:
  - .specify/templates/plan-template.md: ✅ Language field updated via template (already generic)
  - .specify/templates/spec-template.md: ✅ No changes needed (technology-agnostic)
  - .specify/templates/tasks-template.md: ✅ No changes needed (already generic)
Follow-up TODOs: None
==================
-->

# Hello Swift Constitution

## Core Principles

### I. Code Quality (NON-NEGOTIABLE)

All code MUST prioritize clarity, maintainability, and idiomatic Swift 6.0 patterns.

**Requirements:**
- Follow Swift 6.0 language features and Strict Concurrency checking
- Zero compiler warnings in production builds (`swift build -c release`)
- Mandatory SwiftLint with all violations addressed or explicitly disabled with justification
- Maximum cyclomatic complexity: 15 per function (exceptions require architectural review)
- Documentation comments (`///`) on all public APIs with usage examples
- No `force unwrap` (`!`) without documented safety invariant and `precondition` guard
- No `try!` or `fatalError()` in production paths outside of invariant assertions

**Swift 6.0 Strict Concurrency:**
- All types crossing concurrency boundaries MUST conform to `Sendable`
- Actor isolation MUST be explicit; no implicit main-actor assumptions
- `@MainActor` annotated types MUST only be accessed from main thread
- `Task` and `TaskGroup` usage MUST include proper cancellation handling
- `async`/`await` preferred over legacy completion handlers and `DispatchQueue`

**Documentation Quality:**
- All code examples MUST be from real project code (no fictional examples)
- Code examples MUST include GitHub source links
- All examples MUST compile successfully with `swift build --package-path .`

**Rationale:** Learning resources must demonstrate best practices. Students learn from what they see. Swift 6.0's strict concurrency model prevents data races at compile time—examples must reflect this.

**Quality Gates:**
- `swiftlint` MUST pass with zero violations
- `swiftformat --lint` MUST pass
- `swift test` MUST pass with >80% code coverage
- `swift build -c release` MUST produce zero warnings
- All `TODO` and `FIXME` comments MUST have associated issues

### II. Test-First Development (NON-NEGOTIABLE)

Test-driven development is mandatory for all new features and bug fixes.

**Requirements:**
- Tests written and approved BEFORE implementation begins
- Red-Green-Refactor cycle strictly enforced
- Unit tests for all business logic (target: >80% coverage)
- Integration tests for all inter-module communication patterns
- Property-based tests for algorithmic code (using `swift-check` or equivalent)
- Performance benchmarks for critical paths (using `swift-benchmark`)

**Testing Frameworks:**
- **Swift Testing** (Xcode 16+): Primary framework for new tests (`@Test`, `#expect`)
- **XCTest**: Legacy support for existing tests, interoperable with Swift Testing
- Test files MUST live in `Tests/<TargetName>Tests/` matching SPM conventions
- Test doubles MUST use protocol-based mocking, not subclass overrides

**Documentation Testing:**
- Documentation code snippets MUST be executable
- Knowledge checkpoint questions MUST validate learning outcomes
- All examples MUST have corresponding test coverage

**Rationale:** Tests serve as executable specifications and living documentation. They catch regressions and validate learning outcomes.

**Testing Tiers:**
1. **Unit Tests**: Fast, isolated, comprehensive (target: hundreds of tests, <10s total)
2. **Integration Tests**: Module boundaries, nested SPM package interactions
3. **End-to-End Tests**: Full CLI workflows using `gstack` browser automation
4. **Performance Tests**: Benchmark critical paths, detect regressions

**Anti-Patterns:**
- `@available`-gated tests without documented platform reasons
- Tests that only pass on specific macOS versions without explicit deployment target checks
- Using `class` for test doubles when `struct` + protocols suffice
- Testing private implementation details instead of public interfaces

### III. User Experience Consistency

All user-facing interfaces MUST provide intuitive, consistent, and accessible experiences.

**Requirements:**
- CLI interfaces: Consistent argument parsing via `swift-argument-parser`, helpful error messages, `--help` completeness
- Documentation: Chinese primary language with English technical terms, searchable, runnable examples
- Error Messages: Actionable, specific, include context and remediation steps
- Response Times: <100ms for interactive CLI operations, <1s for complex queries

**Documentation Language Standards:**
- **Primary Language**: Chinese (Simplified) with English technical terms in parentheses
  - Example: 并发 (concurrency), 协议 (protocol), 泛型 (generics), 生命周期 (lifetime)
- **Writing Style**: Plain language, avoid academic jargon
- **Chapter Structure**: 12-section template for all tutorial chapters
- **Content Requirements**:
  - Minimum 500 Chinese characters per chapter
  - At least 3 executable code examples
  - At least 3 knowledge checkpoint questions
  - GitHub links to all source code examples

**CLI UX Principles:**
- **Discoverability**: Every subcommand accessible via `swift run hello --help`
- **Predictability**: Consistent verb-noun naming (`swift run hello basic`, `swift run hello advance`)
- **Recoverability**: Clear error messages with suggested fixes, no silent failures
- **Orchestrator Pattern**: Each sample module has a top-level function (`basicSample()`, `advanceSample()`) routed via `SampleModule` enum

**gstack Integration:**
- Use `/browse` for manual UX validation before deployment
- Use `/qa` for automated accessibility testing
- Use `/design-review` for visual consistency audits

**Documentation Build Quality:**
- `mdbook build Docs/` MUST pass with zero errors and warnings
- All links MUST be valid (no 404 errors)
- All code examples MUST render correctly with syntax highlighting

### IV. Performance Requirements

All code MUST meet defined performance standards and resource constraints.

**Requirements:**
- Memory: No unbounded collections without explicit limits; use `ContiguousArray` for performance-critical paths
- CPU: No blocking operations in `async` contexts (use `Task.detached` or `withCheckedContinuation` for C interop)
- I/O: Streaming for large datasets (use `AsyncSequence`, avoid full materialization)
- Concurrency: Use `withTaskGroup` for parallel work, bounded `AsyncChannel` for producer-consumer patterns
- Collections: Prefer `ArraySlice`, `Dictionary` views for zero-copy operations

**Performance Standards:**
- CLI startup: <50ms cold start, <10ms warm start
- Memory footprint: <100MB for demo applications, <500MB for nested packages with NIO
- Binary size: <20MB for CLI tools (release builds, stripped)
- mdBook build: <5 minutes full documentation, <30 seconds per chapter, <2 seconds hot reload

**Performance Anti-Patterns:**
- `Thread.sleep()` in polling loops (use `Task.sleep` with `ContinuousClock` instead)
- Synchronous I/O in `async` functions (use `FileHandle` async APIs or `swift-nio`)
- Value type copy-on-write thrashing (pre-size arrays, use `reserveCapacity`)
- Unnecessary `class` usage when `struct` suffices (prefer value types)
- Force-bridging `[AnyObject]` to `[SwiftType]` without type verification

**Profiling Requirements:**
- Use Xcode Instruments (Time Profiler, Allocations, Leaks) for performance analysis
- Use `swift-benchmark` for reproducible critical path measurement
- Document performance characteristics in `AGENTS.md`
- Track BigNum precision operations in `AlgoSample` for algorithmic correctness

### V. SDD Harness Engineering

Specification Driven Development (SDD) workflows MUST follow the **8-Phase Development Lifecycle** with triple quality gates (Metis + Momus + GStack).

**Development Phases:**

**Phase 0: Product Strategy & Requirements**
- `/office-hours` — Product discovery (YC 6-question forcing framework)
- `/plan-ceo-review` — Scope challenge (4 modes: SCOPE EXPANSION/SELECTIVE/HOLD/REDUCTION)
- `/speckit.specify` — Generate feature specifications
- **Quality Gate**: Metis intent analysis + Momus spec review (≥8/10)

**Phase 1: Technical Architecture & Design**
- `/speckit.plan` — Technical design with constitution check
- `/plan-eng-review` — Engineering review (architecture/data flow/performance)
- `/design-consultation` + `/plan-design-review` — Design system (UI projects)
- **Quality Gate**: Metis deep planning + Momus plan review (≥8/10)

**Phase 2: Task Decomposition**
- `/speckit.tasks` — Granular task breakdown (<4hr per task)
- `/speckit.analyze` — Cross-artifact consistency analysis
- **Quality Gate**: No CRITICAL/HIGH inconsistencies

**Phase 3: Quality Checklists**
- `/speckit.checklist` — Multi-domain checklists (test/security/ux/performance/code-quality/architecture/ai-safety)
- **Quality Gate**: 100% checklist coverage

**Phase 4: Implementation**
- `/speckit.implement` — Test-first execution with task delegation
- **Quality Gate**: `swift build` + `swiftlint` + compilation success
- **Manual Review**: Changes MUST be manually reviewed before commit
- **Manual Commit**: ALL commits MUST be manually committed and pushed by user
- **Prohibited**: NO automatic commits or pushes to remote repositories

**Phase 5: Testing & Validation**
- `swift test` — Automated testing
- `/review` — Pre-landing PR review
- `/qa` — End-to-end QA testing with browser automation
- **Quality Gate**: 100% tests pass + no CRITICAL issues

**Phase 6: Delivery & Release**
- `/document-release` — Update all documentation
- `/ship` — Merge, version bump, create PR (with user approval)
- **Quality Gate**: All quality gates passed
- **Manual Verification**: User MUST verify all changes before deployment

**Phase 7: Retrospective**
- `/retro` — Engineering retro with trend analysis
- **Output**: Improvement action items for next iteration

**Triple Quality Gates:**

| Gate | Role | Timing | Purpose |
|------|------|--------|---------|
| **Metis** | Pre-planning consultant | Before each phase | Intent analysis, ambiguity detection, AI failure prediction, routing strategy |
| **Momus** | Post-delivery reviewer | After each phase | Clarity/verifiability/completeness/context evaluation, AI failure mode detection |
| **GStack** | Professional specialist | During execution | Domain-specific expertise (CEO review, eng review, design review, QA, PR review) |

**Skill Integration Matrix:**

| Phase | Speckit Commands | GStack Skills | OhMyOpenCode Agents |
|-------|------------------|---------------|---------------------|
| Phase 0 | `specify` | `office-hours`, `plan-ceo-review` | `metis`, `librarian` |
| Phase 1 | `plan` | `plan-eng-review`, `design-consultation`, `plan-design-review` | `metis`, `oracle`, `explore` |
| Phase 2 | `tasks`, `analyze` | - | `metis`, `momus` |
| Phase 3 | `checklist` | - | `momus` |
| Phase 4 | `implement` | - | `task()` delegation |
| Phase 5 | - | `review`, `qa`, `browse` | `momus` |
| Phase 6 | - | `document-release`, `ship` | `momus` |
| Phase 7 | - | `retro` | `momus` |

**Workflow Requirements:**
- Feature specifications via `/speckit.specify` (mandatory for all features)
- Implementation plans via `/speckit.plan` (mandatory before coding)
- Constitution check at Phase 1 (verify all 5 principles)
- Test-first development enforced in Phase 4
- All quality gates MUST pass before proceeding to next phase
- Document all decisions in `docs/specs/{N}-{feature}/`
- **Manual Control**: User MUST manually review, commit, and push all changes

**Workflow Enforcement:**
- No direct commits to `main` branch (use feature branches with PRs)
- All PRs MUST reference a spec document in `docs/specs/`
- All code changes MUST have corresponding test updates
- Breaking changes MUST update version according to semver and migration guide
- **CRITICAL**: NO automatic commits or pushes - user maintains full control

**Automation Standards:**
- CI pipeline: Build → Test → Lint → Documentation → Deploy
- Deployment: Automated via GitHub Actions, rollback procedures documented
- Monitoring: Structured logging (`swift-log`, `os.Logger`), SwiftyBeaver integration
- Incident Response: Runbooks in `docs/runbooks/`, on-call rotation documented
- **Manual Gates**: User approval required at all deployment stages

**Tool Stack:**
- **Speckit Framework**: 8-phase SDD workflow (`specify`, `plan`, `tasks`, `analyze`, `checklist`, `implement`)
- **GStack Skills**: Quality automation (`office-hours`, `plan-ceo-review`, `plan-eng-review`, `design-consultation`, `plan-design-review`, `review`, `qa`, `browse`, `ship`, `retro`)
- **OhMyOpenCode Agents**: Triple quality gates (`metis` pre-planning, `momus` post-review, `oracle` architecture, `explore` codebase, `librarian` external research)
- **Swift Tooling**: `swift build`, `swift test`, `swiftlint`, `swiftformat`, Xcode Instruments
- **Manual Commit Policy**: ALL commits require user review and manual execution

## Technology Stack

**Core:**
- Language: Swift 6.0 with Strict Concurrency checking enabled
- Package Manager: Swift Package Manager (SPM) with 3 nested local packages
- CLI Framework: `swift-argument-parser`
- Concurrency: Swift Concurrency (`async`/`await`, `Actor`, `Task`, `TaskGroup`, `AsyncStream`)

**Dependencies:**
- Algorithms: `swift-algorithms`, `swift-numerics`, `swift-bignum`
- Logging: `swift-log`, `SwiftyBeaver`
- Collections: `swift-collections`
- JSON/Data: `SwiftyJSON`
- Networking/Async: `swift-nio`
- Configuration: `swift-dotenv`
- Testing: `swift-testing` (Xcode 16+), `XCTest` (legacy)
- Quality: `SwiftLint`, `SwiftFormat`

**Nested Packages:**
- `AdvanceSample/`: SwiftyJSON, swift-nio, swift-dotenv (separate SPM package)
- `AwesomeSample/`: Third-party integrations, no external deps
- `LeetCodeSample/`: LeetCode problem implementations (separate SPM package)

**Documentation:**
- mdBook 0.4.52 with FontAwesome theming
- Primary language: Chinese (Simplified) with English technical terms
- Deployed to: GitHub Pages (`savechina.github.io/hello-swift`)
- Build verification: `mdbook build Docs/` MUST pass with zero errors

**Build/CI:**
- CI: GitHub Actions (rust.yml legacy → migrating, mdbook.yml)
- Xcode project: `hello-swift.xcodeproj` with CocoaPods integration
- Test resources: `Config/config.json` via relative path traversal `.process("../../Config")`

## Development Workflow

### Feature Development Lifecycle

1. **Specification** (`/speckit.specify`)
   - Create feature spec in `docs/specs/<###-feature-name>/spec.md`
   - Define user stories, acceptance criteria, success metrics
   - Quality checklist validation

2. **Planning** (`/speckit.plan`)
   - Technical design document
   - Architecture decisions with rationale
   - Constitution check (verify compliance with all 5 principles)
   - Dependency analysis across nested SPM packages

3. **Implementation** (`/speckit.tasks` → `/speckit.implement`)
   - Granular task breakdown (<4hr per task)
   - Test-first: Write tests → Tests fail → Implement → Tests pass
   - **Manual Review**: ALL changes MUST be manually reviewed
   - **Manual Commit**: User MUST execute all git commits
   - **Manual Push**: User MUST execute all git pushes
   - **Prohibited**: NO automatic commits or pushes

4. **Quality Assurance** (`/qa`)
   - Automated testing (`swift test`)
   - Visual validation (`/browse`, `/design-review`)
   - Performance benchmarks
   - Lint verification (`swiftlint`, `swiftformat --lint`)

5. **Review** (`/review`)
   - Pre-landing code review
   - Constitution compliance check
   - Strict Concurrency compliance verification
   - Documentation completeness

6. **Deploy**
   - Merge to `main` via PR
   - Automated CI/CD pipeline
   - Post-deploy monitoring
   - **Manual approval required at all stages**

### Branch Strategy

- `main`: Production-ready code, protected
- `<###-feature-name>`: Feature branches (sequential numbering from speckit)
- All branches MUST have associated spec document
- **Manual Control**: User decides when to create branches and merge

### Commit Conventions

 **DO NOT COMMIT and PUSH**
 **DO NOT COMMIT and PUSH**
 **DO NOT COMMIT and PUSH**

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`

**Manual Commit Examples:**
```bash
# User manually reviews and commits
git add <files>
# git commit -m "docs: amend constitution to v2.0.0 (Swift language adaptation)"
# git push origin main
```

**Prohibited:**
```bash
# DO NOT automatically commit or push
# git commit -m "auto: ..."  # FORBIDDEN
# git push origin main       # FORBIDDEN without user approval
```

## Governance

**Authority:**
This constitution supersedes all other development practices and guides. In case of conflict with team conventions, constitution principles take precedence.

**Amendment Process:**
1. Propose amendment via GitHub issue with rationale
2. Architectural review for impact assessment
3. Team discussion and approval (consensus required)
4. Update constitution with version bump (MAJOR.MINOR.PATCH)
5. Propagate changes to all dependent templates and documentation
6. Announce changes to all contributors
7. **Manual Execution**: All constitutional amendments require manual user approval and commit

**Versioning Policy:**
- **MAJOR**: Backward incompatible principle removals or redefinitions
- **MINOR**: New principle/section added or materially expanded guidance
- **PATCH**: Clarifications, wording improvements, typo fixes

**Compliance Review:**
- All PRs MUST verify constitution compliance via `/review` command
- Complexity exceptions MUST be justified in PR description with architectural approval
- Violations of NON-NEGOTIABLE principles block merge
- Strict Concurrency violations (non-Sendable types, actor isolation breaches) block merge
- **Manual Review**: User MUST verify all compliance checks before merge

**Runtime Guidance:**
- Use `AGENTS.md` for project-specific technical guidance
- Use `.specify/templates/` for workflow templates
- Use `Docs/` for user-facing documentation (Chinese primary)
- Nested SPM packages follow same conventions as root package

**Enforcement:**
- CI checks for linting, formatting, testing, documentation build
- Mandatory code review for all changes
- Quarterly constitution review and update cycle
- **Manual Control**: User has final approval on all changes to main branch

---

**Version**: 2.0.0 | **Ratified**: 2026-04-03 | **Last Amended**: 2026-04-26
