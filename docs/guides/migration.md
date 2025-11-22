# Migration Guide

Migrating to GrimRepo from other repository scaffolding and auditing tools.

## From npm/yarn init

If you're currently using `npm init` or `yarn init`:

### What GrimRepo Adds

| Feature | npm/yarn init | GrimRepo |
|---------|---------------|----------|
| Package files | ✅ package.json | ✅ All community standards |
| License | ⚠️  Single choice | ✅ Dual MIT + Palimpsest |
| README | ⚠️  Basic template | ✅ Comprehensive guide |
| Security | ❌ None | ✅ SECURITY.md, .well-known/security.txt |
| Conduct | ❌ None | ✅ CODE_OF_CONDUCT.md |
| Contribution | ❌ None | ✅ CONTRIBUTING.md with TPCF |
| Maintainer | ❌ None | ✅ MAINTAINERS.md with governance |
| Changelog | ❌ None | ✅ CHANGELOG.md (semver) |
| AI Policy | ❌ None | ✅ .well-known/ai.txt |
| Attribution | ❌ None | ✅ .well-known/humans.txt |

### Migration Steps

```bash
# 1. Add GrimRepo to your existing project
cd your-project

# 2. Run GrimRepo audit
# (Once userscript is published)

# 3. Review missing files
# GrimRepo will identify gaps

# 4. Generate missing files
# Use GrimRepo's scaffolding tools

# 5. Validate RSR compliance
just verify-rsr
```

## From cookiecutter/yeoman

If you're using template generators like cookiecutter or yeoman:

### Advantages of GrimRepo

1. **No upfront templates** - GrimRepo audits your existing structure
2. **Incremental adoption** - Add files as needed, not all at once
3. **Cross-platform** - Works on GitLab, GitHub, Bitbucket
4. **Offline-first** - No network calls, faster execution
5. **Type-safe** - ReScript ensures correctness

### Migration Steps

```bash
# 1. Keep your existing structure
# (GrimRepo doesn't force rewrites)

# 2. Run GrimRepo audit to see what's missing
just build
node -e "const { selfCheck } = require('./lib/index.js'); selfCheck();"

# 3. Add recommended files incrementally
# Start with:
# - LICENSE.txt (dual MIT + Palimpsest)
# - SECURITY.md
# - CONTRIBUTING.md

# 4. Achieve Bronze level RSR
# Then progress to Silver, Gold, Rhodium
```

## From GitHub's "community health files"

GitHub provides default community health files, but GrimRepo goes further:

### What GrimRepo Adds

| Feature | GitHub Defaults | GrimRepo |
|---------|-----------------|----------|
| LICENSE | ✅ Templates | ✅ Dual licensing (MIT + Palimpsest) |
| CODE_OF_CONDUCT | ✅ Contributor Covenant | ✅ Palimpsest-aligned (emotional safety) |
| CONTRIBUTING | ✅ Basic | ✅ TPCF governance model |
| SECURITY | ✅ Basic | ✅ Comprehensive policies + .well-known/ |
| MAINTAINERS | ❌ None | ✅ Governance structure |
| CHANGELOG | ❌ None | ✅ Semantic versioning |
| .well-known/ | ❌ None | ✅ RFC 9116 security.txt, ai.txt, humans.txt |
| Auditing | ❌ None | ✅ Automated RSR scoring |

### Migration Steps

```bash
# 1. GrimRepo works alongside GitHub defaults
# Keep your .github/ISSUE_TEMPLATE/, etc.

# 2. Add GrimRepo-specific files:
# - LICENSE.txt (replace LICENSE if needed)
# - MAINTAINERS.md
# - CHANGELOG.md
# - .well-known/security.txt
# - .well-known/ai.txt
# - .well-known/humans.txt

# 3. Enhance existing files:
# - CODE_OF_CONDUCT.md → Add Palimpsest provisions
# - CONTRIBUTING.md → Add TPCF model
# - SECURITY.md → Add .well-known/ cross-reference

# 4. Validate
just verify-rsr
```

## From repolinter/repo-linter

If you're using repolinter or similar linting tools:

### Key Differences

| Aspect | repolinter | GrimRepo |
|--------|------------|----------|
| Approach | Linter (enforces rules) | Auditor (suggests improvements) |
| Philosophy | Pass/fail | Progressive levels (Raw → Rhodium) |
| Emotional Safety | ❌ None | ✅ Palimpsest License provisions |
| Offline-first | ⚠️  Some network calls | ✅ Zero network dependencies |
| Type Safety | ⚠️  JavaScript | ✅ ReScript (sound types) |
| Performance | ⚠️  Good | ✅ WASM-ready (near-native) |

### Migration Steps

```bash
# 1. Run both tools side-by-side initially
# Keep repolinter for CI/CD enforcement
# Use GrimRepo for audit insights

# 2. Compare recommendations
# repolinter is stricter (pass/fail)
# GrimRepo is gentler (progressive levels)

# 3. Gradually replace repolinter rules with GrimRepo
# Start with Bronze level requirements
# Enforce Silver/Gold for mature projects

# 4. Automate with GitLab CI/CD
# GrimRepo's .gitlab-ci.yml validates RSR compliance
```

## From ossf/scorecard

OpenSSF Scorecard focuses on security, GrimRepo adds emotional safety and narratability:

### Complementary Strengths

Use both! GrimRepo complements OpenSSF Scorecard:

| Aspect | OpenSSF Scorecard | GrimRepo |
|--------|-------------------|----------|
| Security | ✅ Comprehensive | ✅ .well-known/security.txt, SECURITY.md |
| Code Review | ✅ Enforced | ⚠️  Recommended (TPCF) |
| Dependencies | ✅ Up-to-date checks | ⚠️  Manual audit |
| Emotional Safety | ❌ None | ✅ Palimpsest License, CoC |
| Narratability | ❌ None | ✅ Core principle |
| Community | ⚠️  Basic | ✅ TPCF governance |

### Migration Steps

```bash
# 1. Keep OpenSSF Scorecard for security metrics
# 2. Add GrimRepo for community health
# 3. Aim for high scores on both:
#    - OpenSSF: 8+ score
#    - GrimRepo: Gold/Rhodium level

# 4. Cross-reference in documentation
# README.md:
# [![OpenSSF Scorecard](...)](#)
# [![RSR Compliant](...)](#)
```

## From manual setup

If you've been manually creating files:

### GrimRepo Advantages

1. **Consistency** - Standardized templates across projects
2. **Completeness** - Never forget a file
3. **Progressive** - Achieve Bronze, then level up
4. **Validation** - `just verify-rsr` ensures compliance

### Migration Steps

```bash
# 1. Inventory existing files
ls -la *.md .well-known/

# 2. Run GrimRepo audit
just build
# Check what's missing

# 3. Add missing files using GrimRepo templates
# (Once scaffolding tools are built)

# 4. Standardize across repositories
# Use GrimRepo for all projects
```

## Best Practices

### Incremental Adoption

Don't try to go from Raw to Rhodium overnight:

1. **Week 1: Bronze** - Add required files (LICENSE, README, SECURITY, CONTRIBUTING, CODE_OF_CONDUCT)
2. **Week 2: Silver** - Add .well-known directory, MAINTAINERS, CHANGELOG
3. **Month 2: Gold** - Enhance documentation, add examples, improve tests
4. **Month 6: Rhodium** - Polish everything, submit to Rhodium Register

### Prioritization

Focus on high-impact files first:

**Priority 1 (Legal & Safety)**:
- LICENSE.txt
- SECURITY.md
- CODE_OF_CONDUCT.md

**Priority 2 (Contribution)**:
- CONTRIBUTING.md
- README.md

**Priority 3 (Maintenance)**:
- MAINTAINERS.md
- CHANGELOG.md

**Priority 4 (Metadata)**:
- .well-known/security.txt
- .well-known/ai.txt
- .well-known/humans.txt

### Automation

Integrate GrimRepo into your workflow:

**Git Hooks**:
```bash
# .git/hooks/pre-commit
#!/bin/bash
just verify-rsr || echo "Warning: RSR compliance degraded"
```

**CI/CD**:
```yaml
# .gitlab-ci.yml
rsr-compliance:
  script:
    - just verify-rsr
  allow_failure: false  # Enforce Bronze minimum
```

**Pre-release Checklist**:
```bash
# Before tagging a release:
1. Update CHANGELOG.md
2. Run: just verify-rsr
3. Ensure Bronze+ level
4. Tag release
```

## Common Pitfalls

### 1. Boilerplate Fatigue

**Problem**: Copying templates without customization

**Solution**: GrimRepo's templates are starting points. Customize:
- README.md: Describe YOUR project
- CONTRIBUTING.md: Reflect YOUR workflow
- CODE_OF_CONDUCT.md: Adapt to YOUR community

### 2. License Confusion

**Problem**: Mixing incompatible licenses

**Solution**: GrimRepo's dual MIT + Palimpsest is designed for compatibility:
- MIT: Permissive open source
- Palimpsest: Adds emotional safety (non-exclusive)

Both licenses apply simultaneously (not "either-or").

### 3. Ignoring .well-known/

**Problem**: Treating .well-known/ as optional

**Solution**: `.well-known/` is RFC-compliant metadata:
- security.txt: Industry standard (RFC 9116)
- ai.txt: Emerging standard for AI training policies
- humans.txt: Attribution (https://humanstxt.org)

These files make your repository machine-readable and discoverable.

### 4. Perfectionism Paralysis

**Problem**: Waiting for "perfect" documentation before publishing

**Solution**: GrimRepo's progressive levels allow:
- Bronze: Good enough to ship
- Silver/Gold/Rhodium: Iterative improvements

Ship Bronze, improve over time.

## Next Steps

After migrating to GrimRepo:

1. **Share Your Journey** - Blog about achieving RSR compliance
2. **Contribute Templates** - Help others with organization-specific examples
3. **Submit to Rhodium Register** - Showcase exemplary repositories
4. **Mentor Others** - Guide projects from Raw to Bronze+

---

**Questions?** Open an issue: https://gitlab.com/extensions-library/monkey-scripts/grimrepo-scripts/-/issues
