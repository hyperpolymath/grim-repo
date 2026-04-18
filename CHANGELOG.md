# Changelog

All notable changes to GrimRepo will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Browser extension versions (Firefox, Chrome)
- GitHub Action integration
- GitLab CI/CD template library
- Rhodium Register publication
- Badge generation service
- VS Code extension
- CLI standalone tool

## [1.0.0] - 2025-01-22

### Added - RSR Bronze Compliance

**Core Implementation**:
- Repo Structure Bootstrapper module (TypeScript)
- Community Standards Helper module (TypeScript)
- Golden Registry Auditor module (TypeScript)
- Offline-first architecture (zero network dependencies)
- Type-safe implementation (TypeScript strict mode)
- Comprehensive test suite (100% pass rate)

**Documentation**:
- README.md with comprehensive project overview
- LICENSE.txt (dual MIT + Palimpsest v0.8)
- SECURITY.md with vulnerability reporting procedures
- CONTRIBUTING.md with TPCF (Tri-Perimeter Contribution Framework)
- CODE_OF_CONDUCT.md with emotional safety provisions
- MAINTAINERS.md with governance structure
- CHANGELOG.md (this file)

**.well-known Directory**:
- security.txt (RFC 9116 compliant)
- ai.txt (AI training policies)
- humans.txt (attribution and credits)

**Build System**:
- Justfile with 20+ automation recipes
- package.json with npm scripts
- TypeScript configuration (strict mode)
- ESLint and Prettier setup
- Nix flake for reproducible builds

**CI/CD**:
- .gitlab-ci.yml with comprehensive pipeline
- Automated testing on every push
- Type checking and linting
- Security scanning (SAST, secret detection)
- RSR compliance validation

**Tests**:
- Unit tests for all core modules
- Integration tests for module interactions
- 100% test coverage goal
- Automated test runs in CI/CD

### Infrastructure
- GitLab repository established
- Issue templates for bugs, features, security
- Merge request templates
- Community health files

### Compliance
- **RSR Bronze Level** achieved
- **TPCF Perimeter 3** (Community Sandbox)
- **Offline-first** verified
- **Type safety** via TypeScript
- **Memory safety** via immutable patterns
- **Zero runtime dependencies**

---

## Version History

### Versioning Scheme

We use [Semantic Versioning](https://semver.org/):

**MAJOR.MINOR.PATCH**

- **MAJOR**: Breaking changes (incompatible API changes)
- **MINOR**: New features (backwards-compatible)
- **PATCH**: Bug fixes (backwards-compatible)

### Release Types

- **Stable Releases** (1.0.0, 1.1.0, etc.): Production-ready
- **Pre-releases** (1.0.0-beta.1, 1.0.0-rc.2): Testing only
- **Development** (unreleased): Main branch, unstable

### Categories

Changes are categorized as:

- **Added**: New features
- **Changed**: Changes to existing functionality
- **Deprecated**: Soon-to-be-removed features
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security vulnerability fixes

### Breaking Changes

Breaking changes are always:
- Highlighted in **bold** with "**BREAKING:**" prefix
- Documented in upgrade guides
- Accompanied by major version bump
- Announced with migration period (when possible)

---

## Links

- [GitLab Repository](https://gitlab.com/extensions-library/monkey-scripts/grimrepo-scripts)
- [Issue Tracker](https://gitlab.com/extensions-library/monkey-scripts/grimrepo-scripts/-/issues)
- [Releases](https://gitlab.com/extensions-library/monkey-scripts/grimrepo-scripts/-/releases)
- [Security Advisories](https://gitlab.com/extensions-library/monkey-scripts/grimrepo-scripts/-/security/advisories)

---

**Maintained by**: GrimRepo Contributors
**Last Updated**: 2025-01-22
