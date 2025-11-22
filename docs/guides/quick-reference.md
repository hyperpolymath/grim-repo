# Quick Reference Guide

Essential commands and concepts for daily use of GrimRepo.

## Commands Cheat Sheet

### Build & Development

```bash
# Build ReScript to JavaScript
just build

# Watch mode (auto-rebuild on file changes)
just watch-rescript

# Format code
just format

# Clean build artifacts
just clean

# Show all available commands
just --list
```

### Validation

```bash
# Verify RSR Bronze compliance
just verify-rsr

# Count lines of code
just loc

# Show project statistics
just stats
```

### Using Nix

```bash
# Enter development environment
nix develop

# Build with Nix
nix build

# Run checks
nix flake check
```

## RSR Compliance Levels

| Level | Score | Requirements |
|-------|-------|--------------|
| **Raw** | <60 | Basic repository |
| **Bronze** | 60-74 | Required files (LICENSE, README, SECURITY, CONTRIBUTING, CODE_OF_CONDUCT) |
| **Silver** | 75-84 | Bronze + .well-known/, MAINTAINERS, CHANGELOG |
| **Gold** | 85-94 | Silver + comprehensive docs, examples |
| **Rhodium** | 95-100 | Gold + exceptional clarity, submitted to Rhodium Register |

## Required Files for Bronze

Minimum files needed for RSR Bronze compliance:

- ✅ `LICENSE` or `LICENSE.txt` (Dual MIT + Palimpsest v0.8 recommended)
- ✅ `README.md` (Comprehensive project overview)
- ✅ `SECURITY.md` (Vulnerability reporting policy)
- ✅ `CONTRIBUTING.md` (Contribution guidelines)
- ✅ `CODE_OF_CONDUCT.md` (Community standards)

## Recommended Files for Silver

Additional files to reach Silver:

- 💡 `MAINTAINERS.md` (Governance structure)
- 💡 `CHANGELOG.md` (Version history)
- 💡 `.well-known/security.txt` (RFC 9116 security contact)
- 💡 `.well-known/ai.txt` (AI training policies)
- 💡 `.well-known/humans.txt` (Attribution)

## ReScript Syntax Quick Reference

### Types

```rescript
// Type alias
type username = string

// Record type
type user = {
  name: string,
  age: int,
  email: option<string>,
}

// Variant (ADT)
type status = Active | Inactive | Suspended

// Parametric type
type result<'a, 'e> = Ok('a) | Error('e)
```

### Functions

```rescript
// Basic function
let add = (x, y) => x + y

// With explicit type annotations
let greet = (name: string): string => `Hello, ${name}!`

// Curried function
let multiply = (x, y) => x * y
let double = multiply(2)  // Partial application

// Recursive function
let rec factorial = (n) =>
  if n <= 1 { 1 } else { n * factorial(n - 1) }
```

### Pattern Matching

```rescript
// Match on variant
let levelToString = (level: qualityLevel): string =>
  switch level {
  | Raw => "raw"
  | Bronze => "bronze"
  | Silver => "silver"
  | Gold => "gold"
  | Rhodium => "rhodium"
  }

// Match on option
let getOrDefault = (opt: option<int>, default: int): int =>
  switch opt {
  | Some(value) => value
  | None => default
  }

// Match on multiple values
let compare = (x, y) =>
  switch (x, y) {
  | (0, 0) => "both zero"
  | (0, _) => "x is zero"
  | (_, 0) => "y is zero"
  | (_, _) => "neither zero"
  }
```

### Arrays

```rescript
// Array literal
let numbers = [1, 2, 3, 4, 5]

// Array operations (Belt.Array)
let doubled = Belt.Array.map(numbers, x => x * 2)
let sum = Belt.Array.reduce(numbers, 0, (acc, x) => acc + x)
let evens = Belt.Array.keep(numbers, x => mod(x, 2) == 0)
```

### Options

```rescript
// Creating options
let some = Some(42)
let none = None

// Using options
let value = switch some {
| Some(x) => x
| None => 0
}

// Option helpers (Belt.Option)
let result = Belt.Option.map(some, x => x * 2)  // Some(84)
let default = Belt.Option.getWithDefault(none, 0)  // 0
```

## Common Patterns

### Validating Input

```rescript
let validateEmail = (email: string): result<string, string> =>
  if Js.String2.includes(email, "@") {
    Ok(email)
  } else {
    Error("Invalid email: missing @ symbol")
  }
```

### Transforming Data

```rescript
let normalizeAndFilter = (paths: array<string>): array<string> =>
  paths
  ->Belt.Array.map(Js.String2.toLowerCase)
  ->Belt.Array.map(Js.String2.trim)
  ->Belt.Array.keep(path => path != "")
```

### Building Pipelines

```rescript
let processFiles = (files: array<string>): int =>
  files
  ->Belt.Array.keep(file => Js.String2.endsWith(file, ".md"))
  ->Belt.Array.map(Js.String2.length)
  ->Belt.Array.reduce(0, (acc, len) => acc + len)
```

## File Structure

```
grimrepo-scripts/
├── src/              # ReScript source files (.res)
│   ├── GrimRepoTypes.res
│   ├── Bootstrap.res
│   ├── Community.res
│   ├── Audit.res
│   ├── GrimRepo.res
│   └── Utils.res
├── test/             # ReScript tests
│   ├── Bootstrap_test.res
│   ├── Community_test.res
│   ├── Audit_test.res
│   └── RunAllTests.res
├── lib/              # JavaScript output + glue code
│   └── grimrepo.js
├── docs/             # Documentation
│   ├── ROADMAP.md
│   ├── architecture.md
│   └── guides/
├── .well-known/      # RFC metadata
│   ├── security.txt
│   ├── ai.txt
│   └── humans.txt
├── bsconfig.json     # ReScript configuration
├── justfile          # Task automation
├── flake.nix         # Nix build
└── .gitlab-ci.yml    # CI/CD pipeline
```

## Troubleshooting

### Build Errors

**Problem**: `rescript: command not found`

**Solution**:
```bash
npm install -g rescript@latest
# OR
nix develop  # Use Nix environment
```

**Problem**: ReScript compilation errors

**Solution**:
```bash
# Clean and rebuild
just clean
just build

# Check for syntax errors in .res files
rescript format -all
```

### RSR Validation Failures

**Problem**: `just verify-rsr` shows missing files

**Solution**:
1. Check which files are missing (output lists them)
2. Create missing files using templates (see docs/guides/)
3. Re-run `just verify-rsr`

**Problem**: Score doesn't improve despite adding files

**Solution**:
- Ensure filenames match exactly (case-sensitive on some systems)
- Check file is not empty
- Verify file is in correct location (root directory vs subdirectory)

## Performance Tips

### ReScript Compilation

- **Use** `just watch-rescript` during development (faster rebuilds)
- **Avoid** frequent `just clean` (only when necessary)
- **Enable** incremental compilation (default in ReScript)

### Runtime Performance

- **Prefer** immutable operations (compiler optimizes well)
- **Use** Belt.Array for efficient array operations
- **Avoid** unnecessary allocations (reuse constants)

## Getting Help

### Documentation

- **README**: Project overview
- **Architecture**: System design (`docs/architecture.md`)
- **Roadmap**: Future plans (`docs/ROADMAP.md`)
- **Migration**: Moving from other tools (`docs/guides/migration.md`)
- **Onboarding**: Contributing guide (`docs/guides/contributor-onboarding.md`)

### Support

- **Issues**: https://gitlab.com/extensions-library/monkey-scripts/grimrepo-scripts/-/issues
- **Email**: (coming soon) support@grimrepo.dev
- **Community**: (coming soon) Discord/Matrix

---

**Last Updated**: 2025-01-22
