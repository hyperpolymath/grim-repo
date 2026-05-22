# GreasyFork Upload Guide - Copy & Paste Ready

## Upload Order (Recommended)

Upload in this order to set up the ecosystem properly:
1. GrimGreaser (build system)
2. GrimPager (browsing helper)
3. GrimTemplateEngine (main tool)
4. GrimLicenseChecker (validation)
5. GrimCIValidator (validation)
6. GrimSecurityScanner (validation)

---

## Script 1: GrimGreaser

### Upload URL
https://greasyfork.org/en/scripts/new

### File to Upload
`userscripts/GrimGreaser.user.js`

### Description (Copy & Paste)
```
Pure ReScript build system with GreasyFork auto-publish capability. Meta-circular architecture allows ReScript to build itself into userscripts with automatic dependency bundling and minification.

Features:
• Self-hosting build system
• GreasyFork API integration
• Tree shaking & minification
• Single Source of Truth from deno.json

Part of the GrimRepo ecosystem for repository management.

Links:
• Homepage: https://github.com/hyperpolymath/grimrepo-scripts
• Documentation: https://github.com/hyperpolymath/grimrepo-scripts/tree/main/docs
• Report Issues: https://github.com/hyperpolymath/grimrepo-scripts/issues
```

### Tags (Space-separated)
```
build-tool automation developer-tools rescript
```

### After Posting - Webhook Sync Settings
- **Sync type**: GitHub
- **Repository**: `hyperpolymath/grimrepo-scripts`
- **Branch**: `main`
- **Path**: `userscripts/GrimGreaser.user.js`

---

## Script 2: GrimPager

### Upload URL
https://greasyfork.org/en/scripts/new

### File to Upload
`userscripts/GrimPager.user.js`

### Description (Copy & Paste)
```
Perpetual auto-paging engine that never stops scrolling. Uses homoiconic rule database with smart pagination detection fallback.

Features:
• 20+ pre-configured site rules (Google, GitHub, GitLab, Reddit, HN, etc.)
• Automatic pagination detection as fallback
• Visual loading indicators
• Non-intrusive infinite browsing

Never click "Next Page" again!

Supported Sites:
Google Search, GitHub Issues/PRs, GitLab, Reddit, Hacker News, Stack Overflow, npm, crates.io, PyPI, and more.

Links:
• Homepage: https://github.com/hyperpolymath/grimrepo-scripts
• Documentation: https://github.com/hyperpolymath/grimrepo-scripts/blob/main/docs/GrimPager.md
• Report Issues: https://github.com/hyperpolymath/grimrepo-scripts/issues
```

### Tags (Space-separated)
```
pagination auto-paging infinite-scroll browsing
```

### After Posting - Webhook Sync Settings
- **Sync type**: GitHub
- **Repository**: `hyperpolymath/grimrepo-scripts`
- **Branch**: `main`
- **Path**: `userscripts/GrimPager.user.js`

---

## Script 3: GrimTemplateEngine

### Upload URL
https://greasyfork.org/en/scripts/new

### File to Upload
`userscripts/GrimTemplateEngine.user.js`

### Description (Copy & Paste)
```
Intelligent repository health agent that detects missing community health files and generates customized templates with one click.

Features:
• Context-aware template generation (extracts owner/repo from URL)
• Health scoring system (0-100 points based on standards compliance)
• 9 community health file templates:
  - LICENSE, SECURITY.md, CODE_OF_CONDUCT.md
  - CONTRIBUTING.md, CHANGELOG.md, AUTHORS.md
  - CITATION.cff, SUPPORT.md, FUNDING.yml
• Priority system (Critical/Important/Recommended)
• LocalStorage persistence for dismissed repos
• One-click GitHub/GitLab editor pre-fill

Perfect for maintaining 100+ repositories at scale. Works on GitHub, GitLab, Bitbucket, Codeberg, and SourceHut.

Links:
• Homepage: https://github.com/hyperpolymath/grimrepo-scripts
• Documentation: https://github.com/hyperpolymath/grimrepo-scripts/blob/main/docs/GrimTemplateEngine.adoc
• Control Guide: https://github.com/hyperpolymath/grimrepo-scripts/blob/main/docs/REPOSITORY_CONTROL_GUIDE.adoc
• Report Issues: https://github.com/hyperpolymath/grimrepo-scripts/issues
```

### Tags (Space-separated)
```
github gitlab repository-management templates health-check
```

### After Posting - Webhook Sync Settings
- **Sync type**: GitHub
- **Repository**: `hyperpolymath/grimrepo-scripts`
- **Branch**: `main`
- **Path**: `userscripts/GrimTemplateEngine.user.js`

---

## Script 4: GrimLicenseChecker

### Upload URL
https://greasyfork.org/en/scripts/new

### File to Upload
`userscripts/GrimLicenseChecker.user.js`

### Description (Copy & Paste)
```
License compliance validator that scans repository files for SPDX headers and detects license inconsistencies.

Features:
• Scans source files for SPDX-License-Identifier headers
• Detects 7+ common licenses:
  - MPL-2.0, MPL-2.0, MIT, Apache-2.0
  - GPL-3.0, AGPL-3.0, BSD-3-Clause
• Shows compliance percentage (0-100%)
• Highlights files missing headers
• Supports 10+ file extensions (.res, .js, .ts, .rs, .ml, .jl, .ex, .gleam, .scm, .sh, .yml)

Compliance Ratings:
• 95%+ = Excellent
• 70-94% = Good
• <70% = Needs Work

Essential for maintaining license compliance across multiple repositories.

Links:
• Homepage: https://github.com/hyperpolymath/grimrepo-scripts
• Documentation: https://github.com/hyperpolymath/grimrepo-scripts/blob/main/docs/REPOSITORY_CONTROL_GUIDE.adoc
• Report Issues: https://github.com/hyperpolymath/grimrepo-scripts/issues
```

### Tags (Space-separated)
```
license compliance spdx repository-management legal
```

### After Posting - Webhook Sync Settings
- **Sync type**: GitHub
- **Repository**: `hyperpolymath/grimrepo-scripts`
- **Branch**: `main`
- **Path**: `userscripts/GrimLicenseChecker.user.js`

---

## Script 5: GrimCIValidator

### Upload URL
https://greasyfork.org/en/scripts/new

### File to Upload
`userscripts/GrimCIValidator.user.js`

### Description (Copy & Paste)
```
GitHub Actions workflow quality checker that validates CI/CD configurations for security best practices.

Features:
• Detects unpinned actions (recommends SHA pinning for security)
• Validates permissions declarations
• Checks for SPDX headers in workflows
• Finds potential hardcoded secrets
• Scores workflow quality (0-100)
• Categorizes issues by severity:
  - Critical: Missing permissions, unpinned actions
  - Warning: Missing SPDX header, potential secrets
  - Info: Suggestions for improvements

Score Interpretation:
• 80-100 = Well-secured workflow
• 50-79 = Needs improvements
• 0-49 = Critical issues present

Automatically displays when viewing .github/workflows/*.yml files.

Links:
• Homepage: https://github.com/hyperpolymath/grimrepo-scripts
• Documentation: https://github.com/hyperpolymath/grimrepo-scripts/blob/main/docs/REPOSITORY_CONTROL_GUIDE.adoc
• Report Issues: https://github.com/hyperpolymath/grimrepo-scripts/issues
```

### Tags (Space-separated)
```
github-actions ci-cd security validation devops
```

### After Posting - Webhook Sync Settings
- **Sync type**: GitHub
- **Repository**: `hyperpolymath/grimrepo-scripts`
- **Branch**: `main`
- **Path**: `userscripts/GrimCIValidator.user.js`

---

## Script 6: GrimSecurityScanner

### Upload URL
https://greasyfork.org/en/scripts/new

### File to Upload
`userscripts/GrimSecurityScanner.user.js`

### Description (Copy & Paste)
```
Security vulnerability detector that scans repositories for common security issues and missing security files.

Features:
• Detects hardcoded secrets and API keys:
  - API keys, secret keys, passwords, tokens
  - GitHub PATs, Stripe keys, AWS access keys
  - 32+ character hashes/keys
• Finds dangerous code patterns:
  - eval(), exec(), system()
  - innerHTML assignments (XSS risk)
  - document.write, dangerouslySetInnerHTML
• Checks for missing security files (SECURITY.md, CODE_OF_CONDUCT.md)
• Calculates risk score
• Categorizes by severity (High/Medium/Low)

Risk Score Interpretation:
• 0-20 = Low risk
• 20-50 = Medium risk
• 50+ = High risk

Trigger via userscript menu: "Run Security Scan"

Links:
• Homepage: https://github.com/hyperpolymath/grimrepo-scripts
• Documentation: https://github.com/hyperpolymath/grimrepo-scripts/blob/main/docs/REPOSITORY_CONTROL_GUIDE.adoc
• Report Issues: https://github.com/hyperpolymath/grimrepo-scripts/issues
```

### Tags (Space-separated)
```
security vulnerability-scanner repository-management code-quality
```

### After Posting - Webhook Sync Settings
- **Sync type**: GitHub
- **Repository**: `hyperpolymath/grimrepo-scripts`
- **Branch**: `main`
- **Path**: `userscripts/GrimSecurityScanner.user.js`

---

## Quick Upload Checklist

For each script:
- [ ] Go to https://greasyfork.org/en/scripts/new
- [ ] Click "Choose File" and select the .user.js file
- [ ] Set Language to "English"
- [ ] Paste the description
- [ ] Add the tags (space-separated)
- [ ] Click "Post script"
- [ ] Go to script edit page
- [ ] Scroll to "Sync" section
- [ ] Configure webhook settings
- [ ] Click "Update script"

## After All Scripts Are Uploaded

Commit the userscripts to GitHub to test the webhook:

```bash
cd $REPOS_DIR/grimrepo-scripts
git add userscripts/
git commit -m "Add GreasyFork userscripts with webhook sync"
git push origin main
```

The webhook will automatically update all scripts on GreasyFork! ✨
