# Contributor Onboarding Guide

Welcome to GrimRepo! This guide will help you make your first contribution.

## Quick Start (5 minutes)

```bash
# 1. Fork the repository on GitLab
# (Click "Fork" button on the GitLab page)

# 2. Clone your fork
git clone https://gitlab.com/YOUR-USERNAME/grimrepo-scripts.git
cd grimrepo-scripts

# 3. Set up development environment
nix develop  # If using Nix
# OR
# Install ReScript manually: npm install -g rescript

# 4. Build the project
just build

# 5. Make a change (e.g., fix a typo in README.md)

# 6. Verify your change
just verify-rsr

# 7. Commit and push
git checkout -b fix/readme-typo
git add README.md
git commit -m "docs: fix typo in installation instructions"
git push origin fix/readme-typo

# 8. Open a Merge Request on GitLab
```

Congratulations! You've made your first contribution! 🎉

## Understanding the Codebase

### Architecture Overview

GrimRepo is built with **ReScript** (a type-safe functional language) that compiles to JavaScript:

```
src/
├── GrimRepoTypes.res   # Type definitions (ADTs, records)
├── Bootstrap.res       # Directory structure auditing
├── Community.res       # Community standards auditing
├── Audit.res           # Overall repository scoring
├── GrimRepo.res        # Public API
└── Utils.res           # Helper functions

test/
├── Bootstrap_test.res  # Tests for Bootstrap module
├── Community_test.res  # Tests for Community module
├── Audit_test.res      # Tests for Audit module
└── RunAllTests.res     # Test runner

lib/
└── grimrepo.js         # Minimal JavaScript glue code (userscript)
```

### Key Concepts

**1. Algebraic Data Types (ADTs)**

ReScript uses ADTs for type-safe enums:

```rescript
type priority = Required | Recommended | Optional
type qualityLevel = Raw | Bronze | Silver | Gold | Rhodium
```

**2. Immutability**

All data structures are immutable by default:

```rescript
let structure = analyzeStructure(paths)
// `structure` cannot be modified after creation
```

**3. Pattern Matching**

Exhaustive case handling:

```rescript
switch level {
| Raw => "raw"
| Bronze => "bronze"
| Silver => "silver"
| Gold => "gold"
| Rhodium => "rhodium"
}
// Compiler ensures all cases are handled
```

## Common Contribution Types

### 1. Documentation Improvements

**Difficulty**: Beginner 🟢

**Examples**:
- Fix typos
- Add examples to README
- Clarify installation instructions
- Improve code comments

**How to**:
1. Edit `.md` files in the repository root or `docs/` directory
2. Use `just verify-rsr` to ensure compliance is maintained
3. Open a merge request

**Impact**: High! Good documentation helps everyone.

### 2. Bug Fixes

**Difficulty**: Intermediate 🟡

**Examples**:
- Fix scoring calculation errors
- Correct file detection logic
- Handle edge cases

**How to**:
1. Reproduce the bug locally
2. Write a failing test in `test/*_test.res`
3. Fix the bug in `src/*.res`
4. Verify test passes: `just build` (tests run automatically)
5. Open a merge request with:
   - Description of the bug
   - Steps to reproduce
   - Your fix
   - New test coverage

**Impact**: Critical for reliability.

### 3. New Features

**Difficulty**: Advanced 🔴

**Examples**:
- Add support for new file types
- Implement new auditing criteria
- Create new quality levels

**How to**:
1. **Discuss first**: Open an issue describing the feature
2. **Get feedback**: Wait for maintainer input before coding
3. **Design**: Write a design document (see `docs/` for examples)
4. **Implement**:
   - Add types to `GrimRepoTypes.res`
   - Implement logic in appropriate module
   - Add tests in `test/`
   - Update documentation
5. **Review**: Open a merge request with comprehensive description

**Impact**: Shapes the project's future.

### 4. Performance Optimizations

**Difficulty**: Advanced 🔴

**Examples**:
- Optimize scoring algorithms
- Reduce memory allocations
- Improve compilation speed

**How to**:
1. **Benchmark first**: Measure current performance
2. **Identify bottleneck**: Profile the code
3. **Optimize**: Apply ReScript best practices (see Performance Guide)
4. **Benchmark again**: Prove improvement
5. **Open MR with**:
   - Before/after benchmarks
   - Explanation of optimization
   - Trade-offs (if any)

**Impact**: Makes GrimRepo faster for everyone.

## Development Workflow

### Branch Naming

Use descriptive branch names:

```
feat/add-wasm-compilation
fix/scoring-calculation-bug
docs/improve-readme
refactor/simplify-audit-logic
chore/update-dependencies
```

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add WASM compilation support
fix: correct LICENSE file detection
docs: add migration guide from npm init
refactor: simplify scoring algorithm
chore: update ReScript to v11.0
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting (no logic change)
- `refactor`: Code restructuring
- `perf`: Performance improvement
- `test`: Adding or updating tests
- `chore`: Maintenance (dependencies, build, etc.)

### Code Style

**ReScript Conventions**:

1. **Module names**: PascalCase (`Bootstrap`, `Community`)
2. **Function names**: camelCase (`analyzeStructure`, `checkRSRCompliance`)
3. **Type names**: camelCase (`directoryCheck`, `auditResult`)
4. **Constants**: camelCase (`standardDirectories`)

**Formatting**:
```bash
just format  # Auto-formats all ReScript code
```

**Best Practices**:
- Prefer immutability
- Use pattern matching over if/else
- Keep functions small and focused
- Document public APIs with comments
- Write tests for all new logic

### Testing

**Running Tests**:
```bash
just build  # Tests run during compilation
```

**Writing Tests**:

Add tests to `test/*_test.res`:

```rescript
// Test helper
let assertEqual = (actual, expected, testName) => {
  if actual == expected {
    Js.log(`✓ ${testName}`)
  } else {
    Js.log(`✗ ${testName}: expected ${expected}, got ${actual}`)
  }
}

// Test case
let runTests = () => {
  Js.log("\n🧪 Running My Tests\n")

  let result = myFunction(input)
  assertEqual(result, expectedOutput, "should return expected output")

  Js.log("\n✅ My tests complete\n")
}

runTests()
```

**Test Coverage**:
- Aim for 100% coverage of new code
- Include edge cases (empty inputs, boundary values)
- Test error handling

### Code Review

**As a Contributor**:
1. **Self-review**: Read your own code before requesting review
2. **Test locally**: Ensure `just verify-rsr` passes
3. **Address feedback**: Respond to reviewer comments promptly
4. **Be patient**: Maintainers are volunteers

**As a Reviewer**:
1. **Be constructive**: Suggest improvements, don't just criticize
2. **Explain why**: Help contributors learn
3. **Approve generously**: Perfect is the enemy of good
4. **Thank contributors**: Appreciate their time

## Emotional Safety

Per our [Palimpsest License](../../LICENSE.txt), we prioritize emotional safety:

### Right to Reversibility
- **Experiments are OK**: If your PR doesn't work out, no problem!
- **Abandon freely**: Close a PR without guilt if you lose interest
- **No permanent marks**: Failed attempts don't count against you

### Anxiety Reduction
- **Ask questions**: There are no "stupid questions"
- **Request help**: "I'm stuck" is a valid comment
- **Take breaks**: Contributing should be enjoyable, not stressful

### Constructive Critique
- **Code reviews focus on code**, not the person
- **Disagreement is welcome**, personal attacks are not
- **We assume good faith** in all interactions

## Resources

### Learning ReScript

- [ReScript Documentation](https://rescript-lang.org/docs/manual/latest/introduction)
- [ReScript by Example](https://rescript-lang.org/try)
- [Pattern Matching Guide](https://rescript-lang.org/docs/manual/latest/pattern-matching-destructuring)

### GrimRepo Internals

- [Architecture Documentation](../architecture.md)
- [ROADMAP](../ROADMAP.md)
- [Migration Guide](migration.md)

### Communication

- **Issues**: Ask questions, report bugs, propose features
- **Merge Requests**: Submit code changes
- **Discussions**: (coming soon) Long-form conversations

## Advanced Topics

### WASM Compilation

(Future feature - documentation coming)

GrimRepo is designed to compile to WebAssembly for performance:

```bash
# (Not yet implemented)
just build-wasm
```

This will enable near-native performance in the browser.

### Nix Development

For reproducible builds:

```bash
# Enter Nix shell with all dependencies
nix develop

# All tools are now available:
# - rescript
# - just
# - git
# - dune (for future WASM compilation)

# Build normally
just build
```

## Next Steps

After your first contribution:

1. **Introduce yourself** in an issue (tell us about your background!)
2. **Pick a second issue** (labeled `good-first-issue` or `help-wanted`)
3. **Help others** (review someone else's MR)
4. **Propose a feature** (share your ideas!)

---

**Thank you for contributing to GrimRepo!** Every contribution, no matter how small, makes the project better. 🎉
