# Quickstart: Hello Swift Tutorial

**Feature**: 001-swift-basic-tutorials
**Date**: 2026-04-26

## Prerequisites

- macOS 14+ or Linux with Swift 6.0+ installed
- `mdBook` 0.4.52+ (`cargo install mdbook`)

## Build Documentation

```bash
# Clone repository
git clone https://github.com/savechina/hello-swift.git
cd hello-swift

# Build documentation
mdbook build Docs/
```

Output: `Docs/book/` — open `Docs/book/index.html` in browser.

## Hot-Reload Development

```bash
mdbook serve Docs/
# Opens http://localhost:3000
```

## Run Code Examples

```bash
# Build and run the CLI
swift run hello --help

# Run basic tutorial samples
swift run hello basic

# Run specific sample modules
swift run hello algo
```

## Tutorial Navigation

1. Start at [基础部分 (Basic)](../../src/basic/basic-overview.md)
2. Work through chapters in order (variables → types → control flow → functions → ...)
3. Use `swift build` to compile any code examples
4. Answer knowledge checks at the end of each chapter

## Project Structure

```
hello-swift/
├── Docs/src/basic/         ← Tutorial chapters (12 files)
├── Sources/BasicSample/    ← Runnable code examples (12 .swift files)
├── Tests/                  ← XCT test suite
└── Package.swift           ← Swift Package Manager manifest
```
