# Data Model: Swift Basic Tutorial Entities

**Feature**: 001-swift-basic-tutorials
**Date**: 2026-04-26

## Entities

### Tutorial Chapter (教程章节)

Represents a single mdBook `.md` file in `Docs/src/basic/`.

| Field               | Type                  | Description                               |
| ------------------- | --------------------- | ---------------------------------------- |
| `title`             | String                | Chinese chapter title with English term   |
| `filename`          | String                | Markdown filename (kebab-case)            |
| `difficulty`        | Enum (🟢/🟡/🔴)       | Learning difficulty level                  |
| `estimatedTime`     | Integer (minutes)     | Expected completion time                  |
| `prerequisites`     | [String]              | List of prerequisite chapter filenames     |
| `sourceFiles`       | [String]              | Paths to `Sources/BasicSample/*.swift`    |
| `sections`          | [Section]             | Required content sections (see below)     |

**Validation Rules**:
- Each chapter MUST have ≥3 code examples
- Each chapter MUST have ≥3 knowledge check questions
- Each chapter MUST be ≥500 Chinese characters
- All `sourceFiles` MUST exist and compile via `swift build`

### Section (章节内容块)

Represents one of the 12 mandatory content sections within a chapter.

| Field               | Type                  | Description                               |
| ------------------- | --------------------- | ---------------------------------------- |
| `type`              | Enum                  | One of the 12 mandatory section types      |
| `content`           | Markdown              | The section's content                     |
| `codeExamples`      | [CodeExample]         | Inline code blocks within this section    |

### CodeExample (代码示例)

Represents an inline Swift code block in documentation.

| Field               | Type                  | Description                               |
| ------------------- | --------------------- | ---------------------------------------- |
| `source`            | Enum                  | `inline` (in-doc) or `linked` (from file) |
| `sourceFile`        | String (nullable)     | Path to Swift source if `linked`          |
| `compilable`        | Boolean               | Whether the example compiles standalone   |
| `language`          | String                | Always "swift"                            |

### Learning Path (学习路径)

Defines the sequential ordering and dependency graph of chapters.

| Field               | Type                    | Description                            |
| ------------------- | ---------------------- | -------------------------------------- |
| `chapters`          | [TutorialChapter]      | Ordered list of chapters                |
| `totalTime`         | Integer (minutes)      | Sum of all chapter estimated times      |
| `entryPoint`        | String                 | First chapter filename                  |
| `branchingPoints`   | [String]               | Chapters with multiple next options      |

**State Transitions**:
- `Draft` → `Complete`: When all 12 sections are filled and code compiles
- `Complete` → `Published`: When mdBook build passes with zero errors/warnings
