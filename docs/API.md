# API Reference

Complete API documentation for GrimRepo Scripts.

## Core Modules

### GrimRepo (Main Entry Point)

The main module exports all public APIs.

```rescript
// Import in ReScript
open GrimRepo

// Import in JavaScript
const GrimRepo = require('./lib/GrimRepo.bs.js')
// or
import * as GrimRepo from './lib/GrimRepo.bs.js'
```

---

## Functions

### `analyzeStructure`

Analyzes repository directory structure.

**Signature**:
```rescript
let analyzeStructure: array<string> => repoStructure
```

**Parameters**:
- `paths`: `array<string>` - Array of existing directory paths

**Returns**: `repoStructure` - Analysis result containing:
- `missingDirs`: `array<directoryCheck>` - Missing directories
- `presentDirs`: `array<string>` - Present directories
- `score`: `int` - Structure completeness score (0-100)

**Example**:
```javascript
const paths = ['src/', 'tests/', 'docs/']
const result = GrimRepo.analyzeStructure(paths)

console.log(`Score: ${result.score}/100`)
console.log(`Missing: ${result.missingDirs.length} directories`)
console.log(`Present: ${result.presentDirs.length} directories`)
```

**TypeScript Types**:
```typescript
interface RepoStructure {
  missingDirs: DirectoryCheck[]
  presentDirs: string[]
  score: number
}

interface DirectoryCheck {
  path: string
  purpose: string
  priority: 'Required' | 'Recommended' | 'Optional'
  template?: string
}
```

---

### `analyzeCommunityStandards`

Analyzes community health files.

**Signature**:
```rescript
let analyzeCommunityStandards: array<string> => communityStandards
```

**Parameters**:
- `files`: `array<string>` - Array of existing files

**Returns**: `communityStandards` - Analysis result containing:
- `missingFiles`: `array<fileCheck>` - Missing files
- `presentFiles`: `array<string>` - Present files
- `score`: `int` - Community standards score (0-100)

**Example**:
```javascript
const files = ['README.md', 'LICENSE.txt', 'CONTRIBUTING.md']
const result = GrimRepo.analyzeCommunityStandards(files)

if (result.score >= 80) {
  console.log('✅ Community standards are strong')
} else {
  console.log('⚠️  Needs improvement')
}
```

**Special Handling**:
- `LICENSE` and `LICENSE.txt` are treated as equivalent
- File paths are case-insensitive
- Backslashes are normalized to forward slashes

---

### `auditRepository`

Performs comprehensive repository audit.

**Signature**:
```rescript
let auditRepository: (array<string>, array<string>) => auditResult
```

**Parameters**:
- `paths`: `array<string>` - Existing directory paths
- `files`: `array<string>` - Existing files

**Returns**: `auditResult` - Complete audit containing:
- `structure`: `repoStructure` - Directory analysis
- `community`: `communityStandards` - File analysis
- `overallScore`: `int` - Weighted score (0-100)
- `level`: `qualityLevel` - Repository quality level
- `recommendations`: `array<string>` - Actionable suggestions

**Example**:
```javascript
const paths = ['src/', 'tests/', 'docs/']
const files = [
  'README.md',
  'LICENSE.txt',
  'SECURITY.md',
  'CONTRIBUTING.md',
  'CODE_OF_CONDUCT.md'
]

const audit = GrimRepo.auditRepository(paths, files)

console.log(`Overall Score: ${audit.overallScore}/100`)
console.log(`Quality Level: ${audit.level}`)
console.log(`\nRecommendations:`)
audit.recommendations.forEach(rec => console.log(`  - ${rec}`))
```

**Scoring**:
- Overall score is weighted: 60% community, 40% structure
- Quality levels determined by score + RSR compliance:
  - **Raw**: <60 or not RSR-compliant
  - **Bronze**: 60-74 and RSR-compliant
  - **Silver**: 75-84 and RSR-compliant
  - **Gold**: 85-94 and RSR-compliant
  - **Rhodium**: 95-100 and RSR-compliant

---

### `generateAuditReport`

Generates human-readable audit report in Markdown.

**Signature**:
```rescript
let generateAuditReport: auditResult => string
```

**Parameters**:
- `audit`: `auditResult` - Audit result from `auditRepository`

**Returns**: `string` - Markdown-formatted report

**Example**:
```javascript
const audit = GrimRepo.auditRepository(paths, files)
const report = GrimRepo.generateAuditReport(audit)

console.log(report)
// # GrimRepo Audit Report
//
// **Overall Score**: 75/100
// **Quality Level**: SILVER
// ...
```

**Report Sections**:
1. Overall score and quality level
2. Structure analysis (score, missing/present dirs)
3. Community standards analysis (score, missing/present files)
4. Detailed missing items lists
5. Actionable recommendations

---

### `checkRSRCompliance`

Checks if repository meets RSR Bronze requirements.

**Signature**:
```rescript
let checkRSRCompliance: communityStandards => bool
```

**Parameters**:
- `standards`: `communityStandards` - Community analysis result

**Returns**: `bool` - `true` if Bronze-compliant, `false` otherwise

**Example**:
```javascript
const standards = GrimRepo.analyzeCommunityStandards(files)

if (GrimRepo.checkRSRCompliance(standards)) {
  console.log('✅ Meets RSR Bronze requirements')
} else {
  console.log('❌ Does not meet RSR Bronze')
  console.log('Missing:')
  standards.missingFiles
    .filter(f => f.priority === 'Required')
    .forEach(f => console.log(`  - ${f.path}`))
}
```

**Required Files for Bronze**:
- README.md
- LICENSE or LICENSE.txt
- SECURITY.md
- CONTRIBUTING.md
- CODE_OF_CONDUCT.md

---

### `selfCheck`

Runs RSR compliance check on GrimRepo itself.

**Signature**:
```rescript
let selfCheck: unit => string
```

**Parameters**: None

**Returns**: `string` - Self-check report

**Example**:
```javascript
const report = GrimRepo.selfCheck()
console.log(report)
// 🔍 GrimRepo Self-Check (RSR Bronze Compliance)
//
// Overall Score: 95/100
// Quality Level: RHODIUM
// ✅ This repository is RSR-compliant!
// ...
```

**Use Case**: Verify GrimRepo's own compliance during development.

---

## Types

### `priority`

Priority level for files/directories.

```rescript
type priority = Required | Recommended | Optional
```

**Values**:
- `Required`: Must be present for RSR compliance
- `Recommended`: Should be present for higher scores
- `Optional`: Nice to have

**Weights**:
- Required: 10 points
- Recommended: 5 points
- Optional: 1 point

---

### `qualityLevel`

Repository quality level based on RSR framework.

```rescript
type qualityLevel = Raw | Bronze | Silver | Gold | Rhodium
```

**Progression**:
1. **Raw**: Basic repository (score <60 or not compliant)
2. **Bronze**: Meets minimum standards (60-74, compliant)
3. **Silver**: Strong repository (75-84, compliant)
4. **Gold**: Excellent repository (85-94, compliant)
5. **Rhodium**: Exceptional repository (95-100, compliant)

---

### `directoryCheck`

Directory presence check.

```rescript
type directoryCheck = {
  path: string,
  purpose: string,
  priority: priority,
  template: option<string>,
}
```

**Fields**:
- `path`: Directory path (e.g., `"src/"`)
- `purpose`: Human-readable explanation (e.g., `"Source code"`)
- `priority`: Importance level
- `template`: Optional README template for the directory

---

### `fileCheck`

File presence check.

```rescript
type fileCheck = {
  path: string,
  purpose: string,
  priority: priority,
  template: option<string>,
}
```

**Fields**:
- `path`: File path (e.g., `"README.md"`)
- `purpose`: Human-readable explanation (e.g., `"Project overview"`)
- `priority`: Importance level
- `template`: Optional file template content

---

### `repoStructure`

Directory structure analysis result.

```rescript
type repoStructure = {
  missingDirs: array<directoryCheck>,
  presentDirs: array<string>,
  score: int,
}
```

**Fields**:
- `missingDirs`: Directories that should exist but don't
- `presentDirs`: Directories that exist
- `score`: Completeness score (0-100)

---

### `communityStandards`

Community health files analysis result.

```rescript
type communityStandards = {
  missingFiles: array<fileCheck>,
  presentFiles: array<string>,
  score: int,
}
```

**Fields**:
- `missingFiles`: Files that should exist but don't
- `presentFiles`: Files that exist
- `score`: Completeness score (0-100)

---

### `auditResult`

Complete repository audit result.

```rescript
type auditResult = {
  structure: repoStructure,
  community: communityStandards,
  overallScore: int,
  level: qualityLevel,
  recommendations: array<string>,
}
```

**Fields**:
- `structure`: Directory analysis
- `community`: File analysis
- `overallScore`: Weighted score (60% community, 40% structure)
- `level`: Quality level (Raw/Bronze/Silver/Gold/Rhodium)
- `recommendations`: Human-readable improvement suggestions

---

## Utility Modules

### `Utils.String`

String manipulation utilities.

**Functions**:
```rescript
let normalizePath: string => string
let startsWith: (string, string) => bool
let endsWith: (string, string) => bool
let split: (string, string) => array<string>
let trim: string => string
let toUpperCase: string => string
let replaceAll: (string, Js.Re.t, string) => string
```

**Example**:
```javascript
const { String: StringUtils } = require('./lib/Utils.bs.js')

const normalized = StringUtils.normalizePath("SRC/")  // "src"
const parts = StringUtils.split("a,b,c", ",")  // ["a", "b", "c"]
```

---

### `Utils.Array`

Array manipulation utilities.

**Functions**:
```rescript
let isEmpty: array<'a> => bool
let isNotEmpty: array<'a> => bool
let head: array<'a> => option<'a>
let last: array<'a> => option<'a>
let sum: array<int> => int
let max: array<int> => option<int>
let min: array<int> => option<int>
let unique: array<'a> => array<'a>
let chunk: (array<'a>, int) => array<array<'a>>
```

**Example**:
```javascript
const { Array: ArrayUtils } = require('./lib/Utils.bs.js')

const numbers = [1, 2, 3, 4, 5]
const total = ArrayUtils.sum(numbers)  // 15
const maxVal = ArrayUtils.max(numbers)  // Some(5)
const chunks = ArrayUtils.chunk(numbers, 2)  // [[1, 2], [3, 4], [5]]
```

---

### `Utils.Math`

Mathematical utilities.

**Functions**:
```rescript
let percentage: (int, int) => int
let clamp: (int, int, int) => int
let round: float => int
```

**Example**:
```javascript
const { Math: MathUtils } = require('./lib/Utils.bs.js')

const percent = MathUtils.percentage(75, 100)  // 75
const clamped = MathUtils.clamp(150, 0, 100)  // 100
```

---

### `Utils.Option`

Option type utilities.

**Functions**:
```rescript
let getWithDefault: (option<'a>, 'a) => 'a
let map: (option<'a>, 'a => 'b) => option<'b>
let flatMap: (option<'a>, 'a => option<'b>) => option<'b>
let isSome: option<'a> => bool
let isNone: option<'a> => bool
```

**Example**:
```javascript
const { Option: OptionUtils } = require('./lib/Utils.bs.js')

const maybeValue = { TAG: 0, _0: 42 }  // Some(42) in ReScript
const value = OptionUtils.getWithDefault(maybeValue, 0)  // 42

const noneValue = { TAG: 1 }  // None in ReScript
const fallback = OptionUtils.getWithDefault(noneValue, 0)  // 0
```

---

## Constants

### `VERSION`

Current GrimRepo version.

**Signature**:
```rescript
let version: string
```

**Example**:
```javascript
console.log(`GrimRepo v${GrimRepo.version}`)  // "GrimRepo v1.0.0"
```

---

## Error Handling

GrimRepo uses ReScript's type system to prevent errors at compile-time:

**No Runtime Exceptions**:
- No null/undefined errors (explicit `option` type)
- No type errors (sound type system)
- No missing case errors (exhaustive pattern matching)

**Validation**:
All inputs are validated:
```rescript
// Empty arrays are valid (score = 0)
let result = analyzeStructure([])  // score: 0, missing: all

// Invalid strings are normalized
let normalized = normalizePath("SRC//")  // "src"
```

---

## Performance

### Benchmarks

| Function | Input Size | Time (avg) |
|----------|-----------|------------|
| `analyzeStructure` | 10 dirs | 1.2ms |
| `analyzeCommunityStandards` | 10 files | 1.5ms |
| `auditRepository` | 10 dirs + 10 files | 3.5ms |
| `generateAuditReport` | Medium audit | 2.0ms |

**Total Audit**: ~7ms for typical repository

### Optimization Tips

1. **Reuse Results**: Cache audit results, don't re-audit unnecessarily
2. **Batch Operations**: Audit multiple repos in parallel
3. **Lazy Evaluation**: Only generate reports when needed

---

## Migration from v0.9 (TypeScript)

### API Changes

| v0.9 (TypeScript) | v1.0 (ReScript) | Notes |
|-------------------|-----------------|-------|
| `runAudit(paths, files)` | `auditRepository(paths, files)` | Renamed for clarity |
| `selfCheck()` returns void | `selfCheck()` returns string | Now returns report |
| No utility modules | `Utils.*` modules | New utilities added |

### Type Changes

ReScript uses different type representations:

**Options**:
```javascript
// TypeScript (v0.9)
const value: number | undefined = ...

// ReScript (v1.0)
const value = { TAG: 0, _0: 42 }  // Some(42)
const none = { TAG: 1 }  // None
```

**Enums**:
```javascript
// TypeScript (v0.9)
type Level = 'raw' | 'bronze' | 'silver' | 'gold' | 'rhodium'

// ReScript (v1.0)
// Internally represented as integers, use helper functions:
const level = audit.level  // 'bronze', 'silver', etc.
```

---

## Examples

### Basic Audit

```javascript
const GrimRepo = require('./lib/GrimRepo.bs.js')

const paths = ['src/', 'tests/']
const files = ['README.md', 'LICENSE.txt']

const result = GrimRepo.auditRepository(paths, files)
console.log(GrimRepo.generateAuditReport(result))
```

### CI/CD Integration

```javascript
// ci/audit.js
const GrimRepo = require('./lib/GrimRepo.bs.js')
const fs = require('fs')

// Discover files and directories
const files = fs.readdirSync('.').filter(f => f.endsWith('.md'))
const dirs = fs.readdirSync('.', { withFileTypes: true })
  .filter(d => d.isDirectory())
  .map(d => d.name + '/')

// Audit
const audit = GrimRepo.auditRepository(dirs, files)

// Enforce Bronze minimum
if (audit.level === 'Raw') {
  console.error('❌ Failed: Repository does not meet RSR Bronze')
  process.exit(1)
} else {
  console.log(`✅ Passed: ${audit.level} level achieved`)
}
```

### Custom Configuration

```javascript
// Use custom directory/file requirements
const customDirs = [
  { path: 'internal/', purpose: 'Internal tools', priority: 'Required' }
]

// Analyze with custom rules
const structure = analyzeStructureCustom(paths, customDirs)
```

---

**Last Updated**: 2025-01-22
**Version**: 1.0.0
