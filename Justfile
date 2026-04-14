# GrimRepo Scripts - Task Automation (ReScript + WASM)
# Install just: https://github.com/casey/just

# List all available recipes
import? "contractile.just"

default:
    @just --list

# Build ReScript to JavaScript
build-rescript:
    @echo "🔨 Building ReScript..."
    rescript build

# Watch mode for ReScript
watch-rescript:
    @echo "👀 Watching ReScript files..."
    rescript build -w

# Clean build artifacts
clean:
    @echo "🧹 Cleaning build artifacts..."
    rescript clean
    rm -rf lib/*.bs.js src/*.bs.js

# Build everything
build: build-rescript
    @echo "✅ Build complete!"

# Format ReScript code
format:
    @echo "✨ Formatting ReScript code..."
    rescript format -all

# Count lines of code
loc:
    @echo "📏 Counting lines of ReScript code..."
    @find src -name '*.res' -exec wc -l {} + | tail -n 1

# Show project statistics
stats:
    @echo "📊 Project Statistics:"
    @echo ""
    @echo "ReScript Files:"
    @find src -name '*.res' | wc -l
    @echo ""
    @echo "JavaScript Files:"
    @find lib -name '*.js' | wc -l
    @echo ""
    @echo "Lines of ReScript:"
    @just loc

# Verify RSR Bronze compliance
verify-rsr:
    @echo "🏅 Verifying RSR Bronze Compliance..."
    @echo ""
    @echo "✅ Checking documentation files..."
    @test -f README.md && echo "  ✓ README.md" || echo "  ✗ README.md"
    @test -f LICENSE.txt && echo "  ✓ LICENSE.txt" || echo "  ✗ LICENSE.txt"
    @test -f SECURITY.md && echo "  ✓ SECURITY.md" || echo "  ✗ SECURITY.md"
    @test -f CONTRIBUTING.md && echo "  ✓ CONTRIBUTING.md" || echo "  ✗ CONTRIBUTING.md"
    @test -f CODE_OF_CONDUCT.md && echo "  ✓ CODE_OF_CONDUCT.md" || echo "  ✗ CODE_OF_CONDUCT.md"
    @test -f MAINTAINERS.md && echo "  ✓ MAINTAINERS.md" || echo "  ✗ MAINTAINERS.md"
    @test -f CHANGELOG.md && echo "  ✓ CHANGELOG.md" || echo "  ✗ CHANGELOG.md"
    @echo ""
    @echo "✅ Checking .well-known directory..."
    @test -f .well-known/security.txt && echo "  ✓ security.txt" || echo "  ✗ security.txt"
    @test -f .well-known/ai.txt && echo "  ✓ ai.txt" || echo "  ✗ ai.txt"
    @test -f .well-known/humans.txt && echo "  ✓ humans.txt" || echo "  ✗ humans.txt"
    @echo ""
    @echo "✅ Checking build system..."
    @test -f bsconfig.json && echo "  ✓ bsconfig.json" || echo "  ✗ bsconfig.json"
    @test -f justfile && echo "  ✓ justfile" || echo "  ✗ justfile"
    @test -f flake.nix && echo "  ✓ flake.nix" || echo "  ✗ flake.nix"
    @echo ""
    @echo "✅ Checking CI/CD..."
    @test -f .gitlab-ci.yml && echo "  ✓ .gitlab-ci.yml" || echo "  ✗ .gitlab-ci.yml"
    @echo ""
    @echo "✅ Checking ReScript source..."
    @test -d src && echo "  ✓ src/" || echo "  ✗ src/"
    @test -f src/GrimRepo.res && echo "  ✓ src/GrimRepo.res" || echo "  ✗ src/GrimRepo.res"
    @echo ""
    @echo "🎯 RSR Compliance Check Complete!"

# Development mode
dev: build
    @echo "🚀 Development build complete"

# Reinstall dependencies
reinstall: clean
    @echo "📦 Reinstalling ReScript..."
    @echo "Run: npm install -g rescript"

# Run panic-attacker pre-commit scan
assail:
    @command -v panic-attack >/dev/null 2>&1 && panic-attack assail . || echo "panic-attack not found — install from https://github.com/hyperpolymath/panic-attacker"

# Self-diagnostic — checks dependencies, permissions, paths
doctor:
    @echo "Running diagnostics for grim-repo..."
    @echo "Checking required tools..."
    @command -v just >/dev/null 2>&1 && echo "  [OK] just" || echo "  [FAIL] just not found"
    @command -v git >/dev/null 2>&1 && echo "  [OK] git" || echo "  [FAIL] git not found"
    @echo "Checking for hardcoded paths..."
    @grep -rn '$HOME\|$ECLIPSE_DIR' --include='*.rs' --include='*.ex' --include='*.res' --include='*.gleam' --include='*.sh' . 2>/dev/null | head -5 || echo "  [OK] No hardcoded paths"
    @echo "Diagnostics complete."

# Auto-repair common issues
heal:
    @echo "Attempting auto-repair for grim-repo..."
    @echo "Fixing permissions..."
    @find . -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    @echo "Cleaning stale caches..."
    @rm -rf .cache/stale 2>/dev/null || true
    @echo "Repair complete."

# Guided tour of key features
tour:
    @echo "=== grim-repo Tour ==="
    @echo ""
    @echo "1. Project structure:"
    @ls -la
    @echo ""
    @echo "2. Available commands: just --list"
    @echo ""
    @echo "3. Read README.adoc for full overview"
    @echo "4. Read EXPLAINME.adoc for architecture decisions"
    @echo "5. Run 'just doctor' to check your setup"
    @echo ""
    @echo "Tour complete! Try 'just --list' to see all available commands."

# Open feedback channel with diagnostic context
help-me:
    @echo "=== grim-repo Help ==="
    @echo "Platform: $(uname -s) $(uname -m)"
    @echo "Shell: $SHELL"
    @echo ""
    @echo "To report an issue:"
    @echo "  https://github.com/hyperpolymath/grim-repo/issues/new"
    @echo ""
    @echo "Include the output of 'just doctor' in your report."


# Print the current CRG grade (reads from READINESS.md '**Current Grade:** X' line)
crg-grade:
    @grade=$$(grep -oP '(?<=\*\*Current Grade:\*\* )[A-FX]' READINESS.md 2>/dev/null | head -1); \
    [ -z "$$grade" ] && grade="X"; \
    echo "$$grade"

# Generate a shields.io badge markdown for the current CRG grade
# Looks for '**Current Grade:** X' in READINESS.md; falls back to X
crg-badge:
    @grade=$$(grep -oP '(?<=\*\*Current Grade:\*\* )[A-FX]' READINESS.md 2>/dev/null | head -1); \
    [ -z "$$grade" ] && grade="X"; \
    case "$$grade" in \
      A) color="brightgreen" ;; B) color="green" ;; C) color="yellow" ;; \
      D) color="orange" ;; E) color="red" ;; F) color="critical" ;; \
      *) color="lightgrey" ;; esac; \
    echo "[![CRG $$grade](https://img.shields.io/badge/CRG-$$grade-$$color?style=flat-square)](https://github.com/hyperpolymath/standards/tree/main/component-readiness-grades)"
