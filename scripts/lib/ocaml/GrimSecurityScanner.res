// SPDX-License-Identifier: PMPL-1.0-or-later
// GrimSecurityScanner.res - Basic Security Issue Detector
//
// Scans repository files for common security vulnerabilities:
// - Hardcoded secrets and API keys
// - Insecure dependencies
// - Dangerous code patterns
// - Missing security files
//
// @name GrimSecurityScanner
// @version 1.0.0
// @namespace https://github.com/hyperpolymath
// @author Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
// @description Security vulnerability detector for repositories
// @homepage https://github.com/hyperpolymath/grimrepo-scripts
// @supportURL https://github.com/hyperpolymath/grimrepo-scripts/issues
// @match *://github.com/*/*
// @match *://gitlab.com/*/*
// @grant GM.getValue
// @grant GM.setValue
// @grant GM.addStyle
// @grant GM.xmlHttpRequest
// @run-at document-end
// @license PMPL-1.0-or-later

open GrimCore

// === Types ===

type severity =
  | High
  | Medium
  | Low

type securityIssue = {
  severity: severity,
  category: string,
  description: string,
  file: option<string>,
  remediation: string,
}

type scanResult = {
  totalIssues: int,
  highSeverity: int,
  mediumSeverity: int,
  lowSeverity: int,
  issues: array<securityIssue>,
  hasSecurityMd: bool,
  hasCodeOfConduct: bool,
  riskScore: int,
}

// === Detection Patterns ===

let secretPatterns = [
  ("api[_-]?key", "API key"),
  ("secret[_-]?key", "secret key"),
  ("password\\s*=", "hardcoded password"),
  ("token\\s*=", "authentication token"),
  ("private[_-]?key", "private key"),
  ("[a-z0-9]{32,}", "potential hash/key"),
  ("ghp_[a-zA-Z0-9]{36}", "GitHub Personal Access Token"),
  ("sk_live_[a-zA-Z0-9]{24,}", "Stripe secret key"),
  ("AKIA[0-9A-Z]{16}", "AWS Access Key"),
]

let dangerousPatterns = [
  ("eval\\(", "Use of eval()"),
  ("exec\\(", "Use of exec()"),
  ("system\\(", "System command execution"),
  ("innerHTML\\s*=", "Potential XSS via innerHTML"),
  ("document\\.write", "Use of document.write"),
  ("dangerouslySetInnerHTML", "React dangerouslySetInnerHTML"),
]

let insecureDependencies = [
  ("\"lodash\":\\s*\"<4\\.17\\.21\"", "Lodash < 4.17.21"),
  ("\"axios\":\\s*\"<0\\.21\\.1\"", "Axios < 0.21.1"),
  ("\"moment\":\\s*\".*\"", "Moment.js (deprecated)"),
]

// === Scanning Logic ===

let detectSecrets = (content: string, filename: string): array<securityIssue> => {
  let issues = []

  secretPatterns->Belt.Array.forEach(((pattern, desc)) => {
    let regex = %raw(`new RegExp(pattern, "gi")`)
    if %raw(`regex.test(content)`) {
      let issue: securityIssue = {
        severity: High,
        category: "Hardcoded Secret",
        description: `Potential ${desc} detected`,
        file: Some(filename),
        remediation: "Move secrets to environment variables or secret management service",
      }
      %raw(`issues.push(issue)`)
    }
  })

  issues
}

let detectDangerousCode = (content: string, filename: string): array<securityIssue> => {
  let issues = []

  dangerousPatterns->Belt.Array.forEach(((pattern, desc)) => {
    let regex = %raw(`new RegExp(pattern, "g")`)
    if %raw(`regex.test(content)`) {
      let issue: securityIssue = {
        severity: Medium,
        category: "Dangerous Pattern",
        description: desc,
        file: Some(filename),
        remediation: "Review usage and consider safer alternatives",
      }
      %raw(`issues.push(issue)`)
    }
  })

  issues
}

let checkSecurityFiles = (): (bool, bool) => {
  let hasSecurityMd = Belt.Option.isSome(DOM.query("a[title='SECURITY.md']"))
  let hasCodeOfConduct = Belt.Option.isSome(DOM.query("a[title='CODE_OF_CONDUCT.md']"))
  (hasSecurityMd, hasCodeOfConduct)
}

let calculateRiskScore = (result: scanResult): int => {
  let score = ref(0)

  score := score.contents + (result.highSeverity * 30)
  score := score.contents + (result.mediumSeverity * 15)
  score := score.contents + (result.lowSeverity * 5)

  if !result.hasSecurityMd {
    score := score.contents + 10
  }

  if !result.hasCodeOfConduct {
    score := score.contents + 5
  }

  score.contents
}

let scanRepository = (): scanResult => {
  let issues = []

  // Check for SECURITY.md and CODE_OF_CONDUCT.md
  let (hasSecurityMd, hasCodeOfConduct) = checkSecurityFiles()

  if !hasSecurityMd {
    let issue: securityIssue = {
      severity: Medium,
      category: "Missing File",
      description: "No SECURITY.md file",
      file: None,
      remediation: "Add SECURITY.md with vulnerability reporting instructions",
    }
    %raw(`issues.push(issue)`)
  }

  if !hasCodeOfConduct {
    let issue: securityIssue = {
      severity: Low,
      category: "Missing File",
      description: "No CODE_OF_CONDUCT.md file",
      file: None,
      remediation: "Add CODE_OF_CONDUCT.md to set community standards",
    }
    %raw(`issues.push(issue)`)
  }

  // Count by severity
  let highCount = ref(0)
  let mediumCount = ref(0)
  let lowCount = ref(0)

  issues->Belt.Array.forEach((issue: securityIssue) => {
    switch issue.severity {
    | High => highCount := highCount.contents + 1
    | Medium => mediumCount := mediumCount.contents + 1
    | Low => lowCount := lowCount.contents + 1
    }
  })

  let result = {
    totalIssues: Belt.Array.length(issues),
    highSeverity: highCount.contents,
    mediumSeverity: mediumCount.contents,
    lowSeverity: lowCount.contents,
    issues: issues,
    hasSecurityMd: hasSecurityMd,
    hasCodeOfConduct: hasCodeOfConduct,
    riskScore: 0,
  }

  let riskScore = calculateRiskScore(result)
  {...result, riskScore: riskScore}
}

// === UI ===

let css = `
.grim-security-panel {
  position: fixed;
  top: 80px;
  right: 20px;
  width: 400px;
  max-height: 600px;
  overflow-y: auto;
  background: linear-gradient(135deg, #4a1a1a 0%, #1a1a2e 100%);
  border: 1px solid #7a4a4a;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
  color: #e0e0e0;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  z-index: 10000;
}

.grim-security-header {
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 15px;
  color: #f44336;
}

.grim-security-score {
  text-align: center;
  padding: 15px;
  margin-bottom: 15px;
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.05);
}

.grim-security-score-value {
  font-size: 36px;
  font-weight: 700;
  margin-bottom: 5px;
}

.grim-security-score-label {
  font-size: 11px;
  color: #999;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.grim-security-stats {
  display: flex;
  gap: 10px;
  margin-bottom: 15px;
}

.grim-security-stat {
  flex: 1;
  text-align: center;
  padding: 10px;
  border-radius: 6px;
  background: rgba(255, 255, 255, 0.05);
}

.grim-security-stat-value {
  font-size: 24px;
  font-weight: 700;
}

.grim-security-stat-label {
  font-size: 10px;
  color: #999;
  text-transform: uppercase;
  margin-top: 4px;
}

.grim-security-stat.high .grim-security-stat-value {
  color: #f44336;
}

.grim-security-stat.medium .grim-security-stat-value {
  color: #ff9800;
}

.grim-security-stat.low .grim-security-stat-value {
  color: #2196f3;
}

.grim-security-issue {
  padding: 10px;
  margin-bottom: 8px;
  border-left: 3px solid;
  border-radius: 4px;
  background: rgba(255, 255, 255, 0.05);
}

.grim-security-issue.high {
  border-color: #f44336;
}

.grim-security-issue.medium {
  border-color: #ff9800;
}

.grim-security-issue.low {
  border-color: #2196f3;
}

.grim-security-issue-category {
  font-size: 10px;
  color: #999;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.grim-security-issue-desc {
  font-size: 13px;
  font-weight: 600;
  margin: 4px 0;
}

.grim-security-issue-remediation {
  font-size: 11px;
  color: #999;
  font-style: italic;
}

.grim-security-close {
  position: absolute;
  top: 10px;
  right: 10px;
  background: none;
  border: none;
  color: #999;
  font-size: 24px;
  cursor: pointer;
  width: 30px;
  height: 30px;
  line-height: 1;
  padding: 0;
}

.grim-security-close:hover {
  color: #fff;
}
`

let severityToClass = (sev: severity): string => {
  switch sev {
  | High => "high"
  | Medium => "medium"
  | Low => "low"
  }
}

let createPanel = (result: scanResult): unit => {
  let panel = DOM.create(~tag="div", ~className="grim-security-panel")

  let riskColor = if result.riskScore < 20 {
    "#4CAF50"
  } else if result.riskScore < 50 {
    "#ff9800"
  } else {
    "#f44336"
  }

  let issuesList = result.issues
    ->Belt.Array.slice(~offset=0, ~len=15) // Show first 15
    ->Belt.Array.map((issue: securityIssue) => {
        let sevClass = severityToClass(issue.severity)
        `<div class="grim-security-issue ${sevClass}">
          <div class="grim-security-issue-category">${issue.category}</div>
          <div class="grim-security-issue-desc">${issue.description}</div>
          <div class="grim-security-issue-remediation">${issue.remediation}</div>
        </div>`
      })
    ->Js.Array2.joinWith("")

  %raw(`panel.innerHTML = "<div class='grim-security-header'>Security Scan</div>" +
    "<div class='grim-security-score'><div class='grim-security-score-value' style='color:" + riskColor + "'>" + result.riskScore + "</div><div class='grim-security-score-label'>Risk Score</div></div>" +
    "<div class='grim-security-stats'><div class='grim-security-stat high'><div class='grim-security-stat-value'>" + result.highSeverity + "</div><div class='grim-security-stat-label'>High</div></div>" +
    "<div class='grim-security-stat medium'><div class='grim-security-stat-value'>" + result.mediumSeverity + "</div><div class='grim-security-stat-label'>Medium</div></div>" +
    "<div class='grim-security-stat low'><div class='grim-security-stat-value'>" + result.lowSeverity + "</div><div class='grim-security-stat-label'>Low</div></div></div>" +
    issuesList`)

  let closeBtn = %raw(`document.createElement("button")`)
  %raw(`closeBtn.textContent = "×"`)
  %raw(`closeBtn.className = "grim-security-close"`)
  %raw(`closeBtn.onclick = () => panel.remove()`)

  %raw(`panel.appendChild(closeBtn)`)
  %raw(`document.body.appendChild(panel)`)
}

// === Entry Point ===

let run = (): unit => {
  Log.info("GrimSecurityScanner running")
  GM.addStyle(css)

  let result = scanRepository()
  createPanel(result)
}

// Auto-run
let () = {
  if URL.isGitHub() || URL.isGitLab() {
    // Add menu command for manual triggering
    GM.registerMenuCommand("Run Security Scan", () => run())
  }
}
