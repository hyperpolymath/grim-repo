// SPDX-License-Identifier: MPL-2.0
// GrimCIValidator.res - CI/CD Workflow Quality Checker
//
// Validates GitHub Actions workflows for security best practices,
// detects unpinned actions, missing permissions, and common misconfigurations.
//
// @name GrimCIValidator
// @version 1.0.0
// @namespace https://github.com/hyperpolymath
// @author Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
// @description GitHub Actions workflow validator
// @homepage https://github.com/hyperpolymath/grimrepo-scripts
// @supportURL https://github.com/hyperpolymath/grimrepo-scripts/issues
// @match *://github.com/*/.github/workflows/*
// @grant GM.getValue
// @grant GM.setValue
// @grant GM.addStyle
// @grant GM.xmlHttpRequest
// @run-at document-end
// @license MPL-2.0

open GrimCore

// === Types ===

type issueLevel =
  | Critical
  | Warning
  | Info

type ciIssue = {
  level: issueLevel,
  message: string,
  line: option<int>,
  suggestion: string,
}

type validationResult = {
  hasPermissions: bool,
  hasSPDXHeader: bool,
  unpinnedActions: array<string>,
  issues: array<ciIssue>,
  score: int,
}

// === Validation Logic ===

let checkPermissions = (content: string): bool => {
  Js.String2.includes(content, "permissions:")
}

let checkSPDXHeader = (content: string): bool => {
  Js.String2.includes(content, "SPDX-License-Identifier:")
}

let findUnpinnedActions = (content: string): array<string> => {
  let lines = Js.String2.split(content, "\n")
  let unpinned = []

  lines->Belt.Array.forEach(line => {
    if Js.String2.includes(line, "uses:") {
      // Check if using tag (@v1, @main) instead of SHA
      if Js.String2.match_(line, %re("/@[a-z0-9\\.\\-]+$/i"))->Belt.Option.isSome {
        let action = Js.String2.trim(Js.String2.replace(line, "uses:", ""))
        %raw(`unpinned.push(action)`)
      }
    }
  })

  unpinned
}

let detectIssues = (content: string): array<ciIssue> => {
  let issues = []

  // Critical: No permissions declaration
  if !checkPermissions(content) {
    let issue: ciIssue = {
      level: Critical,
      message: "Missing permissions declaration",
      line: None,
      suggestion: "Add 'permissions: read-all' at workflow level",
    }
    %raw(`issues.push(issue)`)
  }

  // Warning: No SPDX header
  if !checkSPDXHeader(content) {
    let issue: ciIssue = {
      level: Warning,
      message: "Missing SPDX-License-Identifier header",
      line: Some(1),
      suggestion: "Add '# SPDX-License-Identifier: MPL-2.0' as first line",
    }
    %raw(`issues.push(issue)`)
  }

  // Critical: Unpinned actions
  let unpinned = findUnpinnedActions(content)
  if Belt.Array.length(unpinned) > 0 {
    unpinned->Belt.Array.forEach(action => {
      let issue: ciIssue = {
        level: Critical,
        message: `Unpinned action: ${action}`,
        line: None,
        suggestion: "Pin to SHA: uses: owner/repo@SHA # v1",
      }
      %raw(`issues.push(issue)`)
    })
  }

  // Warning: Hardcoded secrets
  if Js.String2.match_(content, %re("/password|token|key|secret/i"))->Belt.Option.isSome &&
     !Js.String2.includes(content, "secrets.") {
    let issue: ciIssue = {
      level: Warning,
      message: "Potential hardcoded secret detected",
      line: None,
      suggestion: "Use GitHub secrets: ${{ secrets.SECRET_NAME }}",
    }
    %raw(`issues.push(issue)`)
  }

  issues
}

let calculateScore = (result: validationResult): int => {
  let baseScore = 100
  let deductions = ref(0)

  if !result.hasPermissions {
    deductions := deductions.contents + 30
  }

  if !result.hasSPDXHeader {
    deductions := deductions.contents + 10
  }

  deductions := deductions.contents + (Belt.Array.length(result.unpinnedActions) * 15)

  result.issues->Belt.Array.forEach(issue => {
    switch issue.level {
    | Critical => deductions := deductions.contents + 20
    | Warning => deductions := deductions.contents + 10
    | Info => deductions := deductions.contents + 5
    }
  })

  Js.Math.max_int(0, baseScore - deductions.contents)
}

let validateWorkflow = (content: string): validationResult => {
  let hasPermissions = checkPermissions(content)
  let hasSPDXHeader = checkSPDXHeader(content)
  let unpinnedActions = findUnpinnedActions(content)
  let issues = detectIssues(content)

  let result = {
    hasPermissions: hasPermissions,
    hasSPDXHeader: hasSPDXHeader,
    unpinnedActions: unpinnedActions,
    issues: issues,
    score: 0,
  }

  let score = calculateScore(result)
  {...result, score: score}
}

// === UI ===

let css = `
.grim-ci-panel {
  position: fixed;
  top: 80px;
  right: 20px;
  width: 380px;
  max-height: 600px;
  overflow-y: auto;
  background: linear-gradient(135deg, #2c1a4d 0%, #1a1a2e 100%);
  border: 1px solid #5a4a7c;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
  color: #e0e0e0;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  z-index: 10000;
}

.grim-ci-header {
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 15px;
  color: #9c27b0;
}

.grim-ci-score {
  text-align: center;
  padding: 15px;
  margin-bottom: 15px;
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.05);
}

.grim-ci-score-value {
  font-size: 36px;
  font-weight: 700;
  margin-bottom: 5px;
}

.grim-ci-score-label {
  font-size: 11px;
  color: #999;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.grim-ci-issue {
  padding: 10px;
  margin-bottom: 8px;
  border-left: 3px solid;
  border-radius: 4px;
  background: rgba(255, 255, 255, 0.05);
}

.grim-ci-issue.critical {
  border-color: #f44336;
}

.grim-ci-issue.warning {
  border-color: #ff9800;
}

.grim-ci-issue.info {
  border-color: #2196f3;
}

.grim-ci-issue-message {
  font-size: 13px;
  font-weight: 600;
  margin-bottom: 4px;
}

.grim-ci-issue-suggestion {
  font-size: 11px;
  color: #999;
  font-style: italic;
}

.grim-ci-close {
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

.grim-ci-close:hover {
  color: #fff;
}
`

let levelToClass = (level: issueLevel): string => {
  switch level {
  | Critical => "critical"
  | Warning => "warning"
  | Info => "info"
  }
}

let createPanel = (result: validationResult): unit => {
  let panel = DOM.create(~tag="div", ~className="grim-ci-panel")

  let scoreColor = if result.score >= 80 {
    "#4CAF50"
  } else if result.score >= 50 {
    "#ff9800"
  } else {
    "#f44336"
  }

  let issuesList = result.issues
    ->Belt.Array.map((issue: ciIssue) => {
        let levelClass = levelToClass(issue.level)
        `<div class="grim-ci-issue ${levelClass}">
          <div class="grim-ci-issue-message">${issue.message}</div>
          <div class="grim-ci-issue-suggestion">${issue.suggestion}</div>
        </div>`
      })
    ->Js.Array2.joinWith("")

  %raw(`panel.innerHTML = "<div class='grim-ci-header'>CI/CD Quality Check</div>" +
    "<div class='grim-ci-score'><div class='grim-ci-score-value' style='color:" + scoreColor + "'>" + result.score + "</div><div class='grim-ci-score-label'>Workflow Score</div></div>" +
    issuesList`)

  let closeBtn = %raw(`document.createElement("button")`)
  %raw(`closeBtn.textContent = "×"`)
  %raw(`closeBtn.className = "grim-ci-close"`)
  %raw(`closeBtn.onclick = () => panel.remove()`)

  %raw(`panel.appendChild(closeBtn)`)
  %raw(`document.body.appendChild(panel)`)
}

// === Entry Point ===

let run = (): unit => {
  Log.info("GrimCIValidator running")
  GM.addStyle(css)

  // Get workflow content from page
  let codeBlock = DOM.query("pre code, .blob-code-inner")
  switch codeBlock {
  | Some(el) => {
      let content: string = %raw(`el.textContent || el.innerText`)
      let result = validateWorkflow(content)
      createPanel(result)
    }
  | None => Log.warn("Could not find workflow content")
  }
}

// Auto-run on workflow pages
let () = {
  if URL.isGitHub() && Js.String2.includes(URL.locationHref, "/.github/workflows/") {
    run()
  }
}
