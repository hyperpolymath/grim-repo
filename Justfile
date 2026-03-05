# GrimRepo Scripts - Task Automation (ReScript + WASM)
# Install just: https://github.com/casey/just

# List all available recipes
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

# [AUTO-GENERATED] Multi-arch / RISC-V target
build-riscv:
	@echo "Building for RISC-V..."
	cross build --target riscv64gc-unknown-linux-gnu
