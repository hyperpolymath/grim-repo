// SPDX-License-Identifier: PMPL-1.0-or-later
// GrimTemplateEngine: Intelligent Repository Health Agent
// License: https://github.com/hyperpolymath/palimpsest-license
// Version: 1.0.0

// --- MODULE 1: PLATFORM DETECTION ---
module Platform = {
  type t =
    | GitHub
    | GitLab
    | Bitbucket
    | Codeberg
    | SourceHut
    | Unknown

  let detect = (): t => {
    let host = %raw(`window.location.hostname`)

    switch host {
    | h if Js.String2.includes(h, "github.com") => GitHub
    | h if Js.String2.includes(h, "gitlab.com") => GitLab
    | h if Js.String2.includes(h, "bitbucket.org") => Bitbucket
    | h if Js.String2.includes(h, "codeberg.org") => Codeberg
    | h if Js.String2.includes(h, "sr.ht") => SourceHut
    | _ => Unknown
    }
  }

  let name = (platform: t): string => {
    switch platform {
    | GitHub => "GitHub"
    | GitLab => "GitLab"
    | Bitbucket => "Bitbucket"
    | Codeberg => "Codeberg"
    | SourceHut => "SourceHut"
    | Unknown => "Unknown"
    }
  }
}

// --- MODULE 2: CONTEXT EXTRACTION ---
module Context = {
  type repoInfo = {
    owner: string,
    name: string,
    branch: string,
    platform: Platform.t,
    url: string,
  }

  // Extract repo details from URL
  let scan = (): option<repoInfo> => {
    let path = %raw(`window.location.pathname`)
    let url = %raw(`window.location.href`)
    let platform = Platform.detect()

    // Parse path: /owner/repo/...
    let parts = path
      ->Js.String2.split("/")
      ->Belt.Array.keep(s => s != "")

    if Belt.Array.length(parts) >= 2 {
      let owner = Belt.Array.getExn(parts, 0)
      let name = Belt.Array.getExn(parts, 1)

      // Try to detect default branch from DOM
      let branch = switch platform {
      | Platform.GitHub => {
          // GitHub shows branch in dropdown or URL
          let branchElem = %raw(`document.querySelector('[data-hotkey="w"] strong, .ref-selector-button-text-container')`)
          switch Js.Nullable.toOption(branchElem) {
          | Some(elem) => {
              let text = %raw(`elem.textContent`)
              text->Js.String2.trim
            }
          | None => "main"
          }
        }
      | Platform.GitLab => {
          let branchElem = %raw(`document.querySelector('.gl-dropdown-toggle-text')`)
          switch Js.Nullable.toOption(branchElem) {
          | Some(elem) => %raw(`elem.textContent`)->Js.String2.trim
          | None => "main"
          }
        }
      | _ => "main"
      }

      Some({owner, name, branch, platform, url})
    } else {
      None
    }
  }

  // Check if specific file exists in repo
  let hasFile = (filename: string, info: repoInfo): bool => {
    let selector = switch info.platform {
    | Platform.GitHub => `a[title="${filename}"], .react-directory-filename-column a[title="${filename}"], [aria-label="${filename}"]`
    | Platform.GitLab => `.tree-item-file-name a[title="${filename}"], a[href*="${filename}"]`
    | Platform.Bitbucket => `a[href*="${filename}"]`
    | Platform.Codeberg => `a[title="${filename}"]`
    | _ => `a[href*="${filename}"]`
    }

    let elem = %raw(`document.querySelector(selector)`)
    !Js.Nullable.isNullable(elem)
  }
}

// --- MODULE 3: SMART TEMPLATES ---
module Templates = {
  open Context

  // Security Policy (with context)
  let security = (info: repoInfo): string => {
    `# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

**Please DO NOT file a public issue.** Email security concerns to:

- **Email**: security@${info.owner}.dev
- **Response Time**: Within 48 hours

For more information, see our [Security Documentation](${info.url}/security).

## Security Measures

- All dependencies are regularly audited
- We use automated scanning (Dependabot, CodeQL)
- Security patches are prioritized

---

*This project follows the [OpenSSF Best Practices](https://bestpractices.coreinfrastructure.org/).*
`
  }

  // Code of Conduct (Contributor Covenant 2.1)
  let codeOfConduct = (info: repoInfo): string => {
    `# Contributor Covenant Code of Conduct

## Our Pledge

We as members, contributors, and leaders pledge to make participation in our
community a harassment-free experience for everyone, regardless of age, body
size, visible or invisible disability, ethnicity, sex characteristics, gender
identity and expression, level of experience, education, socio-economic status,
nationality, personal appearance, race, caste, color, religion, or sexual
identity and orientation.

## Our Standards

Examples of behavior that contributes to a positive environment:

* Demonstrating empathy and kindness toward other people
* Being respectful of differing opinions, viewpoints, and experiences
* Giving and gracefully accepting constructive feedback
* Accepting responsibility and apologizing to those affected by our mistakes
* Focusing on what is best not just for us as individuals, but for the overall community

## Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be
reported to the community leaders responsible for enforcement at:

- **Email**: conduct@${info.owner}.dev
- **Anonymous Form**: [Report Here](${info.url}/issues/new?template=code_of_conduct.md)

All complaints will be reviewed and investigated promptly and fairly.

## Attribution

This Code of Conduct is adapted from the [Contributor Covenant][homepage],
version 2.1, available at
[https://www.contributor-covenant.org/version/2/1/code_of_conduct.html][v2.1].

[homepage]: https://www.contributor-covenant.org
[v2.1]: https://www.contributor-covenant.org/version/2/1/code_of_conduct.html
`
  }

  // Contributing Guide
  let contributing = (info: repoInfo): string => {
    `# Contributing to ${info.name}

Thank you for your interest in contributing! 🎉

## Quick Links

- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Security Policy](SECURITY.md)
- [Issue Tracker](${info.url}/issues)
- [Pull Requests](${info.url}/pulls)

## Getting Started

1. **Fork the repository**
2. **Clone your fork**:
   \`\`\`bash
   git clone https://github.com/${info.owner}/${info.name}.git
   cd ${info.name}
   \`\`\`
3. **Create a branch**:
   \`\`\`bash
   git checkout -b feature/amazing-feature
   \`\`\`
4. **Make your changes**
5. **Commit your changes**:
   \`\`\`bash
   git commit -m "Add amazing feature"
   \`\`\`
6. **Push to your fork**:
   \`\`\`bash
   git push origin feature/amazing-feature
   \`\`\`
7. **Open a Pull Request**

## Code Style

- Follow existing code conventions
- Write clear, self-documenting code
- Add comments for complex logic
- Update documentation as needed

## Testing

Before submitting a PR, ensure:
- [ ] All tests pass
- [ ] New features have tests
- [ ] Documentation is updated

## Questions?

Feel free to [open an issue](${info.url}/issues/new) or reach out to the maintainers.

---

*Built with ❤️ by the ${info.name} community*
`
  }

  // Authors file
  let authors = (info: repoInfo): string => {
    `# Authors

This file lists the contributors to ${info.name}.

## Maintainers

- **${info.owner}** - Project Lead

## Contributors

<!-- Add contributors here -->
See [GitHub Contributors](${info.url}/graphs/contributors) for a full list.

## Acknowledgments

Thanks to all who have contributed to this project!

---

*Want to be listed here? See [CONTRIBUTING.md](CONTRIBUTING.md)*
`
  }

  // Changelog template
  let changelog = (info: repoInfo): string => {
    `# Changelog

All notable changes to ${info.name} will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release

## [1.0.0] - ${%raw(`new Date().toISOString().split('T')[0]`)}

### Added
- Core functionality
- Documentation
- Test suite

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- N/A

---

[unreleased]: ${info.url}/compare/v1.0.0...HEAD
[1.0.0]: ${info.url}/releases/tag/v1.0.0
`
  }

  // Citation file (CFF format)
  let citation = (info: repoInfo): string => {
    `cff-version: 1.2.0
message: "If you use ${info.name}, please cite it as below."
title: "${info.name}"
authors:
  - family-names: "${info.owner}"
repository-code: "${info.url}"
url: "${info.url}"
license: PMPL-1.0-or-later
date-released: ${%raw(`new Date().toISOString().split('T')[0]`)}
version: "1.0.0"
`
  }

  // Support guide
  let support = (info: repoInfo): string => {
    `# Support

## Getting Help

- 📖 [Documentation](${info.url}#readme)
- 💬 [Discussions](${info.url}/discussions)
- 🐛 [Issue Tracker](${info.url}/issues)

## Before Opening an Issue

1. Search existing issues to avoid duplicates
2. Provide a clear description
3. Include reproduction steps if applicable
4. Specify your environment (OS, versions, etc.)

## Commercial Support

For commercial support, contact: support@${info.owner}.dev

## Community

- Follow [@${info.owner}](https://github.com/${info.owner}) for updates
- Star ⭐ the repo if you find it useful!

---

*Need help? Don't hesitate to ask!*
`
  }

  // Funding info
  let funding = (info: repoInfo): string => {
    `# Sponsor ${info.name}

If you find this project useful, consider sponsoring its development!

## Ways to Support

- ⭐ Star the repository
- 🐛 Report bugs and suggest features
- 💻 Contribute code
- 💰 Sponsor development

## GitHub Sponsors

Support via [GitHub Sponsors](https://github.com/sponsors/${info.owner})

## Other Platforms

- [Open Collective](https://opencollective.com/${info.owner})
- [Ko-fi](https://ko-fi.com/${info.owner})

---

*Every contribution helps make ${info.name} better!*
`
  }
}

// --- MODULE 4: STANDARDS DATABASE ---
module Standards = {
  type priority =
    | Critical    // Must have
    | Important   // Should have
    | Recommended // Nice to have

  type standard = {
    filename: string,
    description: string,
    priority: priority,
    generator: Context.repoInfo => string,
    category: string,
  }

  let all: array<standard> = [
    // Critical files
    {
      filename: "LICENSE",
      description: "Legal usage rights",
      priority: Critical,
      generator: _ => "PMPL-1.0-or-later\n\nSee: https://github.com/hyperpolymath/palimpsest-license",
      category: "Legal",
    },
    {
      filename: "SECURITY.md",
      description: "Vulnerability reporting",
      priority: Critical,
      generator: Templates.security,
      category: "Security",
    },
    {
      filename: "CODE_OF_CONDUCT.md",
      description: "Community standards",
      priority: Critical,
      generator: Templates.codeOfConduct,
      category: "Community",
    },

    // Important files
    {
      filename: "CONTRIBUTING.md",
      description: "Contribution guidelines",
      priority: Important,
      generator: Templates.contributing,
      category: "Community",
    },
    {
      filename: "CHANGELOG.md",
      description: "Version history",
      priority: Important,
      generator: Templates.changelog,
      category: "Documentation",
    },
    {
      filename: "AUTHORS.md",
      description: "Project contributors",
      priority: Important,
      generator: Templates.authors,
      category: "Community",
    },

    // Recommended files
    {
      filename: "CITATION.cff",
      description: "Academic citation",
      priority: Recommended,
      generator: Templates.citation,
      category: "Academic",
    },
    {
      filename: "SUPPORT.md",
      description: "Getting help",
      priority: Recommended,
      generator: Templates.support,
      category: "Community",
    },
    {
      filename: "FUNDING.yml",
      description: "Sponsorship info",
      priority: Recommended,
      generator: Templates.funding,
      category: "Sustainability",
    },
  ]

  // Calculate health score
  let calculateScore = (missing: array<standard>): int => {
    let totalScore = 100
    let deductions = missing->Belt.Array.reduce(0, (acc, std) => {
      let penalty = switch std.priority {
      | Critical => 30
      | Important => 15
      | Recommended => 5
      }
      acc + penalty
    })

    max(0, totalScore - deductions)
  }
}

// --- MODULE 5: URL GENERATOR ---
module URLGenerator = {
  open Context
  open Platform

  let encodeContent = (content: string): string => {
    %raw(`encodeURIComponent(content)`)
  }

  let generateCreateURL = (
    filename: string,
    content: string,
    info: repoInfo,
  ): string => {
    let encoded = encodeContent(content)
    let base = info.url

    switch info.platform {
    | GitHub => `${base}/new/${info.branch}?filename=${filename}&value=${encoded}`
    | GitLab => `${base}/-/new/${info.branch}?file_name=${filename}&content=${encoded}`
    | Codeberg => `${base}/new/${info.branch}?filename=${filename}&value=${encoded}`
    | _ => `${base}/new/${info.branch}?filename=${filename}`
    }
  }
}

// --- MODULE 6: STORAGE (LocalStorage Persistence) ---
module Storage = {
  type dismissedRepo = {
    url: string,
    timestamp: float,
  }

  @val @scope(("window", "localStorage"))
  external getItem: string => Js.Nullable.t<string> = "getItem"

  @val @scope(("window", "localStorage"))
  external setItem: (string, string) => unit = "setItem"

  let key = "grimtemplate_dismissed"

  let isDismissed = (url: string): bool => {
    let stored = getItem(key)->Js.Nullable.toOption

    switch stored {
    | Some(json) => {
        let parsed = %raw(`JSON.parse(json)`)
        %raw(`parsed.includes(url)`)
      }
    | None => false
    }
  }

  let dismiss = (url: string): unit => {
    let stored = getItem(key)->Js.Nullable.toOption
    let dismissed = switch stored {
    | Some(json) => %raw(`JSON.parse(json)`)
    | None => %raw(`[]`)
    }

    %raw(`dismissed.push(url)`)
    let updated = %raw(`JSON.stringify(dismissed)`)
    setItem(key, updated)
  }
}

// --- MODULE 7: UI ENGINE ---
module UI = {
  open Standards

  let createPanel = (missing: array<standard>, info: Context.repoInfo): unit => {
    // Check if already dismissed
    if Storage.isDismissed(info.url) {
      Js.Console.log("✓ GrimTemplate: Panel dismissed for this repo")
      ()
    } else {
      let score = calculateScore(missing)

      // Create container
      let panel = %raw(`document.createElement("div")`)
      %raw(`panel.id = "grimtemplate-panel"`)
      %raw(`panel.style.cssText = "position:fixed;bottom:20px;right:20px;background:linear-gradient(135deg, #1a1a1a 0%, #2a2a2a 100%);color:#eee;padding:20px;border-radius:12px;box-shadow:0 10px 40px rgba(0,0,0,0.6);z-index:999999;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Helvetica,Arial,sans-serif;width:380px;border:1px solid #333;backdrop-filter:blur(10px);"`)

      // Header
      let header = %raw(`document.createElement("div")`)
      let scoreColor = if score >= 80 {
        "#4caf50"
      } else if score >= 50 {
        "#ff9800"
      } else {
        "#f44336"
      }

      %raw(`header.innerHTML = "<div style='display:flex;justify-content:space-between;align-items:center;margin-bottom:15px;'><div><strong style='font-size:16px;'>GrimTemplate</strong><div style='font-size:12px;color:#999;margin-top:2px;'>" + info.name + "</div></div><div style='text-align:right;'><div style='font-size:24px;font-weight:bold;color:" + scoreColor + ";'>" + score + "</div><div style='font-size:10px;color:#999;'>HEALTH SCORE</div></div></div>"`)

      let closeBtn = %raw(`document.createElement("button")`)
      %raw(`closeBtn.textContent = "×"`)
      %raw(`closeBtn.style.cssText = "position:absolute;top:10px;right:10px;background:none;border:none;color:#999;font-size:24px;cursor:pointer;padding:0;width:30px;height:30px;line-height:1;"`)
      %raw(`closeBtn.onclick = () => { panel.remove(); Storage.dismiss(info.url); }`)

      %raw(`panel.appendChild(header)`)
      %raw(`panel.appendChild(closeBtn)`)

      if Belt.Array.length(missing) == 0 {
        let success = %raw(`document.createElement("div")`)
        %raw(`success.innerHTML = "<div style='text-align:center;padding:20px;'><div style='font-size:48px;'>✨</div><div style='font-size:18px;color:#4caf50;margin-top:10px;'>Golden Repository!</div><div style='font-size:12px;color:#999;margin-top:5px;'>All standards met</div></div>"`)
        %raw(`panel.appendChild(success)`)

        // Auto-dismiss after 5 seconds
        %raw(`setTimeout(() => { panel.remove(); Storage.dismiss(info.url); }, 5000)`)
      } else {
        // Category grouping
        let critical = missing->Belt.Array.keep(s => s.priority == Critical)
        let important = missing->Belt.Array.keep(s => s.priority == Important)
        let recommended = missing->Belt.Array.keep(s => s.priority == Recommended)

        let renderCategory = (title, items, color) => {
          if Belt.Array.length(items) > 0 {
            let categoryDiv = %raw(`document.createElement("div")`)
            %raw(`categoryDiv.innerHTML = "<div style='font-size:11px;color:" + color + ";font-weight:bold;margin:15px 0 8px;text-transform:uppercase;letter-spacing:1px;'>" + title + "</div>"`)
            %raw(`panel.appendChild(categoryDiv)`)

            items->Belt.Array.forEach(std => {
              let item = %raw(`document.createElement("div")`)
              %raw(`item.style.cssText = "display:flex;justify-content:space-between;align-items:center;margin-bottom:10px;padding:10px;background:#222;border-radius:6px;border-left:3px solid " + color + ";"`)

              let label = %raw(`document.createElement("div")`)
              %raw(`label.innerHTML = "<div style='font-size:13px;font-weight:500;'>" + std.filename + "</div><div style='font-size:11px;color:#999;margin-top:2px;'>" + std.description + "</div>"`)

              let content = std.generator(info)
              let url = URLGenerator.generateCreateURL(std.filename, content, info)

              let btn = %raw(`document.createElement("a")`)
              %raw(`btn.textContent = "Create"`)
              %raw(`btn.href = url`)
              %raw(`btn.target = "_blank"`)
              %raw(`btn.style.cssText = "background:" + color + ";color:white;text-decoration:none;padding:6px 14px;border-radius:6px;font-size:12px;font-weight:600;transition:transform 0.2s;"`)
              %raw(`btn.onmouseenter = () => { btn.style.transform = 'scale(1.05)'; }`)
              %raw(`btn.onmouseleave = () => { btn.style.transform = 'scale(1)'; }`)

              %raw(`item.appendChild(label)`)
              %raw(`item.appendChild(btn)`)
              %raw(`panel.appendChild(item)`)
            })
          }
        }

        renderCategory("Critical", critical, "#f44336")
        renderCategory("Important", important, "#ff9800")
        renderCategory("Recommended", recommended, "#2196f3")

        // Footer
        let footer = %raw(`document.createElement("div")`)
        %raw(`footer.innerHTML = "<div style='margin-top:15px;padding-top:15px;border-top:1px solid #333;font-size:11px;color:#666;text-align:center;'>Powered by <a href='https://github.com/hyperpolymath/grimrepo-scripts' style='color:#2196f3;text-decoration:none;'>GrimRepo-Scripts</a></div>"`)
        %raw(`panel.appendChild(footer)`)
      }

      %raw(`document.body.appendChild(panel)`)
    }
  }
}

// --- MODULE 8: ENTRY POINT ---
@val external version: string = "METADATA_VERSION"

let init = () => {
  Js.Console.log(`🎨 GrimTemplateEngine v${version} - Repository Health Agent`)

  // Detect context
  switch Context.scan() {
  | Some(info) => {
      Js.Console.log(`✓ Detected: ${info.owner}/${info.name} on ${Platform.name(info.platform)}`)

      // Audit standards
      let missing = Standards.all->Belt.Array.keep(std => {
        !Context.hasFile(std.filename, info)
      })

      Js.Console.log(`📊 Health Score: ${Belt.Int.toString(Standards.calculateScore(missing))}/100`)
      Js.Console.log(`📄 Missing ${Belt.Int.toString(Belt.Array.length(missing))} files`)

      // Render UI
      UI.createPanel(missing, info)
    }
  | None => Js.Console.log("ℹ️ No repository detected in current page")
  }
}

// Auto-initialize
init()
