# PROJECT KNOWLEDGE BASE

**Generated:** 2026-04-26
**Commit:** e1963fa
**Branch:** main

## OVERVIEW
`hello-swift` — Swift 编程语言学习教程。CLI executable with sample codes for beginners learning Swift. Swift 6.0, Swift Package Manager, with 3 nested local packages.

## STRUCTURE
```
hello-swift/
├── Sources/
│   ├── HelloSample/        # @main entry point (ArgumentParser CLI)
│   ├── BasicSample/        # 12 Swift files: vars, expressions, classes, protocols, concurrency, logging
│   └── AlgoSample/         # 2 Swift files: algorithm examples, pi calculation
├── Tests/
│   ├── HelloSampleTests/   # 3 test files
│   └── AlgoSampleTests/    # 1 test file
├── AdvanceSample/          # Nested SPM package (SwiftyJSON, swift-nio, dotenv)
├── AwesomeSample/          # Nested SPM package (no external deps)
├── LeetCodeSample/         # Nested SPM package (LeetCode problems)
├── Docs/                   # mdBook documentation (src/ = source, book/ = generated)
├── Config/                 # Test resources (config.json)
├── Scripts/                # Build/utility scripts
├── Logs/                   # Log output dir
├── hello-swift.xcodeproj/  # Xcode project w/ CocoaPods
├── hello-swift.xcworkspace/
└── Package.swift           # Root SPM manifest
```

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| CLI entry / subcommands | Sources/HelloSample/HelloSample.swift | @main, ParsableCommand |
| Basic Swift samples | Sources/BasicSample/ | Variables, classes, protocols, generics, concurrency |
| Algorithm examples | Sources/AlgoSample/ | AddTwo, pi calculation |
| Advanced patterns (JSON, NIO, dotenv) | AdvanceSample/Sources/AdvanceSample/ | Separate SPM package |
| LeetCode problems | LeetCodeSample/Sources/LeetCodeSample/ | Separate SPM package |
| Third-party integrations | AwesomeSample/Sources/AwesomeSample/ | Separate SPM package |
| Test resources | Config/ | Referenced via `.process("../../Config")` |
| Documentation | Docs/src/ | mdBook source files |
| Logging config | Sources/BasicSample/LoggerSample.swift | SwiftyBeaver + swift-log |

## CODE MAP

| Symbol | Type | Location | Role |
|--------|------|----------|------|
| HelloSample | @main struct | Sources/HelloSample/HelloSample.swift:23 | CLI root command |
| SampleModule | enum | Sources/HelloSample/HelloSample.swift:14 | Module routing enum |
| InfoCommand | struct | HelloSample.swift:53 | Print module info |
| BasicCommand | struct | HelloSample.swift:112 | Run BasicSample |
| AdvanceCommand | struct | HelloSample.swift:129 | Run AdvanceSample |
| AwesomeCommand | struct | HelloSample.swift:151 | Run AwesomeSample |
| AlgoCommand | struct | HelloSample.swift:172 | Run AlgoSample |
| basicSample() | func | Sources/BasicSample/BasicSample.swift | Master orchestrator |
| advanceSample() | func | AdvanceSample/Sources/AdvanceSample/AdvanceSample.swift | Advanced orchestrator |
| awesomeSample() | func | AwesomeSample/Sources/AwesomeSample/AwesomeSample.swift | Awesome orchestrator |
| AlgoSample.AddTwo | func | Sources/AlgoSample/AlgoSample.swift | Simple addition |
| AlgorithmSample | class | Sources/BasicSample/ClassSample.swift | Class + property observer demo |
| ExampleProtocol | protocol | Sources/BasicSample/ExampleProtocol.swift | Protocol definition |
| SimpleStructure | struct | Sources/BasicSample/ExampleProtocol.swift | Value type protocol impl |
| SimpleClass | class | Sources/BasicSample/ExampleProtocol.swift | Reference type protocol impl |

## CONVENTIONS
- Swift 6.0 tools version across all Package.swift files
- All Package.swift use Apple default target/test naming
- Test resources use relative path traversal: `.process("../../Config")`
- Nested packages (AdvanceSample, AwesomeSample, LeetCodeSample) each have own Package.swift, .build/, .swiftpm/
- Mixed comments: English + Chinese throughout
- Function-level logging via `print("--- sample ...start ---")` pattern

## ANTI-PATTERNS (THIS PROJECT)
- Do NOT commit .build/ directories (already in .gitignore but found committed)
- Do NOT modify Config/config.json without updating HelloSampleTests references
- AdvanceSample has .travis.yml (legacy CI) — root uses GitHub Actions (mdbook.yml)
- .ruby-lsp/ committed — editor-specific config, treat as project artifact

## UNIQUE STYLES
- Orchestrator pattern: each Sample has a top-level func (`basicSample()`, `advanceSample()`, etc.) called from CLI
- `startSample()`/`endSample()` helper functions for sample lifecycle logging
- `SampleModule` enum routes CLI args to module descriptions
- AdvanceSample evolved from CocoaPods template (README mentions pods, has .travis.yml)
- mdBook for docs with FontAwesome theming

## COMMANDS
```bash
# Build all targets
swift build

# Run the CLI
swift run hello --help           # Show subcommands
swift run hello info <name>      # Module info
swift run hello basic            # Run BasicSample
swift run hello advance          # Run AdvanceSample
swift run hello awesome          # Run AwesomeSample
swift run hello algo             # Run AlgoSample

# Run tests
swift test

# Run specific test
swift test --filter HelloSampleTests

# Build with Xcode (CocoaPods required)
xcodebuild -project hello-swift.xcodeproj -scheme hello-swift

# Build docs (mdBook)
mdbook serve Docs/
```

## NOTES
- AdvanceSample is a nested SPM package — treat as separate module with its own deps (SwiftyJSON, swift-nio, swift-dotenv)
- `.env` file present at root — used by AdvanceSample's dotenv integration
- HelloSample depends on all other modules (BasicSample, AlgoSample, AdvanceSample, AwesomeSample, LeetCodeSample)
- mdBook builds to `Docs/book/` — generated HTML committed to repo (non-standard)
- Some BasicSample features have no CLI command (ConcurrencySample, DatatypeSample, ErrorsSample, etc.) — accessed programmatically only
