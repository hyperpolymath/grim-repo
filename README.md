# GrimRepo Scripts

**Modular audit-grade tooling for narratable, scaffolded, and legible repositories**

[![RSR Compliant](https://img.shields.io/badge/RSR-Bronze-cd7f32)](https://rhodium-standard.org)
[![License](https://img.shields.io/badge/license-MIT%20%2B%20Palimpsest%20v0.8-blue.svg)](LICENSE.txt)
[![TPCF](https://img.shields.io/badge/TPCF-Perimeter%203-green)](CONTRIBUTING.md)

## Overview

GrimRepo is a modular toolkit for elevating repositories to professional standards across GitLab, GitHub, and Bitbucket. The project embodies the principle that **repositories should be narratable, audit-grade, and emotionally legible**.

## Core Modules

### 1. Repo Structure Bootstrapper
Ensures essential directories exist with proper scaffolding:
- Source code directories (`src/`, `lib/`)
- Test directories (`tests/`, `spec/`)
- Documentation (`docs/`, `examples/`)
- Community standards (`.github/`, `.gitlab/`)
- Build and CI/CD infrastructure

### 2. Community Standards Helper
Audits and assists with:
- LICENSE compliance
- CONTRIBUTING.md guidelines
- CODE_OF_CONDUCT.md
- SECURITY.md policies
- MAINTAINERS.md documentation

### 3. Golden Registry Auditor
Runs diagnostic checks for:
- Documentation completeness
- Build system presence
- Test coverage
- Security configurations
- Dependency analysis

## Philosophy

GrimRepo operates on a **progression model**:

1. **Raw Project** → Initial state
2. **Golden Repo** → Passes core audits
3. **Rhodium Register** → Exceptionally clear, narratable projects

Structure is not just organization — it's about **clarity, onboarding, and symbolic trust**.

## Installation

### Prerequisites
- ReScript compiler (`npm install -g rescript`)
- Git
- just (task runner)
- (Optional) Nix with flakes enabled for reproducible builds

### Quick Start

```bash
# Clone the repository
git clone https://gitlab.com/extensions-library/monkey-scripts/grimrepo-scripts.git
cd grimrepo-scripts

# Build ReScript to JavaScript
just build

# Or use Nix
nix develop
just build

# Validate RSR compliance
just verify-rsr
```

### As Userscript

Install via [GreasyFork](https://greasyfork.org) (coming soon) or manually:

1. Install a userscript manager (Tampermonkey, Violentmonkey, Greasemonkey)
2. Load `dist/grimrepo.user.js`
3. Visit any GitLab/GitHub/Bitbucket repository
4. Access GrimRepo tools via the injected UI

## Features

### Offline-First Architecture
- **Zero external dependencies** at runtime
- **No network calls** required for core functionality
- **Air-gapped compatible** for secure environments

### Type Safety
- **ReScript implementation** with sound type system
- **Compile-time guarantees** - no runtime type errors
- **Pattern matching exhaustiveness** checked at compile-time

### Memory Safety
- **No buffer overflows** - immutable data structures
- **No null pointer exceptions** - explicit null handling
- **Predictable resource cleanup** - proper disposal patterns

## RSR Compliance

This project achieves **Bronze-level** Rhodium Standard Repository compliance:

- ✅ **616 lines of ReScript code** (515% over 100-line minimum!) with zero runtime dependencies
- ✅ **Type safety** via ReScript's sound type system
- ✅ **Memory safety** through immutable-by-default functional programming
- ✅ **Offline-first** - no network dependencies
- ✅ **Complete documentation** (README, LICENSE, SECURITY, CONTRIBUTING, CODE_OF_CONDUCT)
- ✅ **.well-known/** directory (security.txt, ai.txt, humans.txt)
- ✅ **Build system** (ReScript compiler, justfile, Nix flake)
- ✅ **CI/CD pipeline** (.gitlab-ci.yml with ReScript builds)
- ✅ **WASM-ready** architecture for performance
- ✅ **TPCF Perimeter 3** - Community Sandbox (open contribution)

## Project Structure

```
grimrepo-scripts/
├── .well-known/
│   ├── security.txt          # RFC 9116 security contact
│   ├── ai.txt               # AI training policies
│   └── humans.txt           # Attribution and credits
├── src/
│   ├── GrimRepoTypes.res    # Core type definitions
│   ├── Bootstrap.res        # Repo structure bootstrapper
│   ├── Community.res        # Community standards helper
│   ├── Audit.res            # Golden registry auditor
│   └── GrimRepo.res         # Main entry point & public API
├── lib/
│   └── grimrepo.js          # Minimal JavaScript glue code
├── docs/
│   ├── ROADMAP.md           # Comprehensive 6-phase roadmap
│   └── architecture.md      # System design documentation
├── .gitlab-ci.yml           # CI/CD pipeline (ReScript builds)
├── justfile                 # Build automation (ReScript tasks)
├── flake.nix                # Nix reproducible builds
├── bsconfig.json            # ReScript configuration
├── LICENSE.txt              # Dual MIT + Palimpsest v0.8
├── SECURITY.md              # Security policies
├── CONTRIBUTING.md          # Contribution guidelines
├── CODE_OF_CONDUCT.md      # Community conduct
├── MAINTAINERS.md           # Project maintainers
├── CHANGELOG.md             # Version history
└── README.md                # This file
```

## Development

```bash
# Build ReScript
just build

# Watch mode for development
just watch-rescript

# Format code
just format

# Verify RSR compliance
just verify-rsr

# Count lines of code
just loc

# Show project statistics
just stats

# Clean build artifacts
just clean
```

## Using Just

We use [just](https://github.com/casey/just) for task automation:

```bash
# Show all available recipes
just --list

# Build the project (ReScript to JavaScript)
just build

# Development mode with watch
just watch-rescript

# Verify RSR Bronze compliance
just verify-rsr

# Clean build artifacts
just clean
```

## Using Nix

Reproducible builds with Nix:

```bash
# Enter development shell
nix develop

# Build the project
nix build

# Run checks
nix flake check
```

## Contributing

We welcome contributions! This project follows the **Tri-Perimeter Contribution Framework (TPCF)**:

- **Perimeter 3 (Community Sandbox)**: Open to all contributors
- See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines
- Review [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before participating

## Security

Security is paramount. Please see [SECURITY.md](SECURITY.md) for:
- Reporting vulnerabilities
- Security update policy
- Supported versions
- Contact information (also in `.well-known/security.txt`)

## License

Dual-licensed under:
- **MIT License** (permissive open source)
- **Palimpsest License v0.8** (emotional safety guarantees)

See [LICENSE.txt](LICENSE.txt) for complete terms.

## Maintainers

See [MAINTAINERS.md](MAINTAINERS.md) for current project maintainers and governance structure.

## Roadmap

- [ ] Browser extension version (Firefox, Chrome)
- [ ] GitHub Action integration
- [ ] GitLab CI/CD template library
- [ ] Rhodium Register publication
- [ ] Badge generation service
- [ ] VS Code extension
- [ ] CLI standalone tool

## Acknowledgments

See [.well-known/humans.txt](.well-known/humans.txt) for complete attribution.

## Links

- **GitLab**: https://gitlab.com/extensions-library/monkey-scripts/grimrepo-scripts
- **Documentation**: https://grimrepo.dev (coming soon)
- **Issue Tracker**: https://gitlab.com/extensions-library/monkey-scripts/grimrepo-scripts/-/issues
- **Rhodium Standard**: https://rhodium-standard.org
- **Palimpsest License**: https://palimpsest.dev

---

**Built with rhodium-standard clarity. Emotionally legible by design.**
