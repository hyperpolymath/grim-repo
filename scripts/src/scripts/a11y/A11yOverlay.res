// A11yOverlay.res - Accessibility Testing Overlay
// SPDX-License-Identifier: MPL-2.0 OR LicenseRef-Palimpsest-0.5
//
// Quick accessibility audit overlay with WCAG 2.3 checks:
// - Color contrast (AAA 7:1 ratio)
// - Alt text for images
// - Form label associations
// - Heading hierarchy
// - Focus indicators
//
// @match *://*/*

open GrimCore

// === Types ===

type severity = Error | Warning | Info

type wcagCriterion = {
  id: string,
  level: string, // A, AA, AAA
  title: string,
}

type issue = {
  element: Dom.element,
  severity: severity,
  message: string,
  wcag: wcagCriterion,
  suggestion: option<string>,
}

type auditResult = {
  issues: array<issue>,
  passed: int,
  failed: int,
  warnings: int,
}

// === Constants ===

let scriptInfo: Registry.scriptInfo = {
  name: "grim-a11y-overlay",
  version: "1.0.0",
  description: "Accessibility testing overlay with WCAG checks",
  matches: ["*://*/*"],
}

// WCAG Criteria
let wcag_1_1_1 = {id: "1.1.1", level: "A", title: "Non-text Content"}
let wcag_1_4_3 = {id: "1.4.3", level: "AA", title: "Contrast (Minimum)"}
let wcag_1_4_6 = {id: "1.4.6", level: "AAA", title: "Contrast (Enhanced)"}
let wcag_1_3_1 = {id: "1.3.1", level: "A", title: "Info and Relationships"}
let wcag_2_4_1 = {id: "2.4.1", level: "A", title: "Bypass Blocks"}
let wcag_2_4_6 = {id: "2.4.6", level: "AA", title: "Headings and Labels"}
let wcag_2_4_7 = {id: "2.4.7", level: "AA", title: "Focus Visible"}
let wcag_4_1_2 = {id: "4.1.2", level: "A", title: "Name, Role, Value"}

// === CSS ===

let css = `
  .grim-a11y-overlay {
    position: fixed;
    top: 0;
    right: 0;
    width: 360px;
    height: 100vh;
    background: #ffffff;
    border-left: 1px solid #dfe6e9;
    z-index: 999999;
    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
    font-size: 13px;
    display: flex;
    flex-direction: column;
    box-shadow: -4px 0 12px rgba(0, 0, 0, 0.1);
  }
  .grim-a11y-header {
    padding: 16px;
    border-bottom: 1px solid #dfe6e9;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  .grim-a11y-header h3 {
    margin: 0;
    font-size: 16px;
    display: flex;
    align-items: center;
    gap: 8px;
  }
  .grim-a11y-close {
    cursor: pointer;
    font-size: 20px;
    opacity: 0.6;
    transition: opacity 0.2s;
  }
  .grim-a11y-close:hover { opacity: 1; }
  .grim-a11y-summary {
    padding: 12px 16px;
    background: #f8f9fa;
    display: flex;
    gap: 16px;
    border-bottom: 1px solid #dfe6e9;
  }
  .grim-a11y-stat {
    text-align: center;
  }
  .grim-a11y-stat-value {
    font-size: 24px;
    font-weight: 700;
  }
  .grim-a11y-stat-label {
    font-size: 11px;
    color: #636e72;
    text-transform: uppercase;
  }
  .grim-a11y-stat-error .grim-a11y-stat-value { color: #e74c3c; }
  .grim-a11y-stat-warning .grim-a11y-stat-value { color: #f39c12; }
  .grim-a11y-stat-passed .grim-a11y-stat-value { color: #27ae60; }
  .grim-a11y-issues {
    flex: 1;
    overflow-y: auto;
    padding: 0;
  }
  .grim-a11y-issue {
    padding: 12px 16px;
    border-bottom: 1px solid #f1f3f4;
    cursor: pointer;
    transition: background 0.2s;
  }
  .grim-a11y-issue:hover {
    background: #f8f9fa;
  }
  .grim-a11y-issue-header {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 4px;
  }
  .grim-a11y-issue-severity {
    width: 8px;
    height: 8px;
    border-radius: 50%;
  }
  .grim-a11y-issue-severity.error { background: #e74c3c; }
  .grim-a11y-issue-severity.warning { background: #f39c12; }
  .grim-a11y-issue-severity.info { background: #3498db; }
  .grim-a11y-issue-wcag {
    font-size: 10px;
    padding: 2px 6px;
    background: #e9ecef;
    border-radius: 3px;
    color: #495057;
  }
  .grim-a11y-issue-message {
    color: #2d3436;
    line-height: 1.4;
  }
  .grim-a11y-issue-suggestion {
    font-size: 11px;
    color: #636e72;
    margin-top: 4px;
    font-style: italic;
  }
  .grim-a11y-highlight {
    outline: 3px solid #e74c3c !important;
    outline-offset: 2px !important;
  }
  .grim-a11y-highlight-warning {
    outline: 3px solid #f39c12 !important;
    outline-offset: 2px !important;
  }
  .grim-a11y-actions {
    padding: 12px 16px;
    border-top: 1px solid #dfe6e9;
    display: flex;
    gap: 8px;
  }
  .grim-a11y-btn {
    flex: 1;
    padding: 8px 12px;
    border: none;
    border-radius: 4px;
    font-size: 12px;
    cursor: pointer;
    transition: background 0.2s;
  }
  .grim-a11y-btn-primary {
    background: #3498db;
    color: white;
  }
  .grim-a11y-btn-primary:hover { background: #2980b9; }
  .grim-a11y-btn-secondary {
    background: #e9ecef;
    color: #495057;
  }
  .grim-a11y-btn-secondary:hover { background: #dee2e6; }
`

// === Color Contrast ===

// Parse color string to RGB
let parseColor = (color: string): option<(float, float, float)> => {
  // Handle rgb(r, g, b) format
  let rgbMatch = %raw(`color.match(/rgb\((\d+),\s*(\d+),\s*(\d+)\)/)`)
  if !Js.Nullable.isNullable(rgbMatch) {
    let r = %raw(`parseFloat(rgbMatch[1])`)
    let g = %raw(`parseFloat(rgbMatch[2])`)
    let b = %raw(`parseFloat(rgbMatch[3])`)
    Some((r, g, b))
  } else {
    // Handle rgba
    let rgbaMatch = %raw(`color.match(/rgba\((\d+),\s*(\d+),\s*(\d+),\s*[\d.]+\)/)`)
    if !Js.Nullable.isNullable(rgbaMatch) {
      let r = %raw(`parseFloat(rgbaMatch[1])`)
      let g = %raw(`parseFloat(rgbaMatch[2])`)
      let b = %raw(`parseFloat(rgbaMatch[3])`)
      Some((r, g, b))
    } else {
      None
    }
  }
}

// Calculate relative luminance (WCAG formula)
let relativeLuminance = ((r, g, b): (float, float, float)): float => {
  let adjust = (c: float) => {
    let c' = c /. 255.0
    if c' <= 0.03928 {
      c' /. 12.92
    } else {
      Js.Math.pow_float(~base=(c' +. 0.055) /. 1.055, ~exp=2.4)
    }
  }
  0.2126 *. adjust(r) +. 0.7152 *. adjust(g) +. 0.0722 *. adjust(b)
}

// Calculate contrast ratio
let contrastRatio = (l1: float, l2: float): float => {
  let lighter = Js.Math.max_float(l1, l2)
  let darker = Js.Math.min_float(l1, l2)
  (lighter +. 0.05) /. (darker +. 0.05)
}

// Get computed style color
@val external getComputedStyle: Dom.element => {..} = "getComputedStyle"

let getElementColors = (el: Dom.element): option<(string, string)> => {
  let style = getComputedStyle(el)
  let fg: string = %raw(`style.color`)
  let bg: string = %raw(`style.backgroundColor`)
  Some((fg, bg))
}

// === Audit Functions ===

let checkImageAlt = (): array<issue> => {
  let images = DOM.queryAll("img")
  images->Belt.Array.keepMap(img => {
    let alt = DOM.getAttribute(img, "alt")
    let src = DOM.getAttribute(img, "src")->Js.Nullable.toOption->Belt.Option.getWithDefault("")

    // Skip tracking pixels and icons
    if Js.String2.includes(src, "pixel") || Js.String2.includes(src, "tracking") {
      None
    } else {
      switch Js.Nullable.toOption(alt) {
      | None => Some({
          element: img,
          severity: Error,
          message: "Image missing alt attribute",
          wcag: wcag_1_1_1,
          suggestion: Some("Add descriptive alt text or alt=\"\" for decorative images"),
        })
      | Some("") => Some({
          element: img,
          severity: Info,
          message: "Image has empty alt (decorative)",
          wcag: wcag_1_1_1,
          suggestion: None,
        })
      | Some(_) => None
      }
    }
  })
}

let checkContrast = (): array<issue> => {
  let textElements = DOM.queryAll("p, span, a, h1, h2, h3, h4, h5, h6, li, td, th, label, button")
  textElements->Belt.Array.keepMap(el => {
    switch getElementColors(el) {
    | Some((fg, bg)) => {
        switch (parseColor(fg), parseColor(bg)) {
        | (Some(fgRgb), Some(bgRgb)) => {
            let fgLum = relativeLuminance(fgRgb)
            let bgLum = relativeLuminance(bgRgb)
            let ratio = contrastRatio(fgLum, bgLum)

            if ratio < 4.5 {
              Some({
                element: el,
                severity: Error,
                message: `Contrast ratio ${Js.Float.toFixedWithPrecision(ratio, ~digits=2)}:1 below 4.5:1 minimum`,
                wcag: wcag_1_4_3,
                suggestion: Some("Increase contrast between text and background colors"),
              })
            } else if ratio < 7.0 {
              Some({
                element: el,
                severity: Warning,
                message: `Contrast ratio ${Js.Float.toFixedWithPrecision(ratio, ~digits=2)}:1 below 7:1 (AAA)`,
                wcag: wcag_1_4_6,
                suggestion: Some("Consider higher contrast for AAA compliance"),
              })
            } else {
              None
            }
          }
        | _ => None
        }
      }
    | None => None
    }
  })
}

let checkFormLabels = (): array<issue> => {
  let inputs = DOM.queryAll("input, select, textarea")
  inputs->Belt.Array.keepMap(input => {
    let inputType = DOM.getAttribute(input, "type")->Js.Nullable.toOption->Belt.Option.getWithDefault("text")

    // Skip hidden and submit inputs
    if inputType === "hidden" || inputType === "submit" || inputType === "button" {
      None
    } else {
      let id = DOM.getAttribute(input, "id")->Js.Nullable.toOption
      let ariaLabel = DOM.getAttribute(input, "aria-label")->Js.Nullable.toOption
      let ariaLabelledBy = DOM.getAttribute(input, "aria-labelledby")->Js.Nullable.toOption

      // Check for associated label
      let hasLabel = switch id {
      | Some(inputId) => {
          let label = DOM.query(`label[for="${inputId}"]`)
          Belt.Option.isSome(label)
        }
      | None => false
      }

      if !hasLabel && Belt.Option.isNone(ariaLabel) && Belt.Option.isNone(ariaLabelledBy) {
        Some({
          element: input,
          severity: Error,
          message: "Form input missing associated label",
          wcag: wcag_4_1_2,
          suggestion: Some("Add <label for=\"id\"> or aria-label attribute"),
        })
      } else {
        None
      }
    }
  })
}

let checkHeadingHierarchy = (): array<issue> => {
  let headings = DOM.queryAll("h1, h2, h3, h4, h5, h6")
  let levels = headings->Belt.Array.map(h => {
    let tag = (%raw(`h.tagName`): string)
    let levelStr = Js.String2.charAt(tag, 1)
    let level = Belt.Int.fromString(levelStr)->Belt.Option.getWithDefault(0)
    (h, level)
  })

  let issues: array<issue> = []
  let prevLevel = ref(0)

  levels->Belt.Array.forEach(((el, level)) => {
    if level > prevLevel.contents + 1 && prevLevel.contents > 0 {
      let _ = Js.Array2.push(issues, {
        element: el,
        severity: Warning,
        message: `Skipped heading level: h${Js.Int.toString(prevLevel.contents)} to h${Js.Int.toString(level)}`,
        wcag: wcag_1_3_1,
        suggestion: Some("Maintain sequential heading levels for screen reader navigation"),
      })
    }
    prevLevel := level
  })

  issues
}

let checkSkipLinks = (): array<issue> => {
  let skipLink = DOM.query("a[href='#main'], a[href='#content'], .skip-link, .skip-to-content")
  switch skipLink {
  | Some(_) => []
  | None => [{
      element: DOM.body,
      severity: Warning,
      message: "No skip link found",
      wcag: wcag_2_4_1,
      suggestion: Some("Add a skip link at the start of the page to bypass navigation"),
    }]
  }
}

let checkFocusIndicators = (): array<issue> => {
  // This is harder to test statically - would need to check :focus styles
  let focusableElements = DOM.queryAll("a, button, input, select, textarea, [tabindex]")
  // For now, just check if outline: none is used without alternative
  focusableElements->Belt.Array.keepMap(el => {
    let style = getComputedStyle(el)
    let outline: string = %raw(`style.outlineStyle`)
    let boxShadow: string = %raw(`style.boxShadow`)

    if outline === "none" && boxShadow === "none" {
      Some({
        element: el,
        severity: Warning,
        message: "Element may have no visible focus indicator",
        wcag: wcag_2_4_7,
        suggestion: Some("Ensure focus is visible with outline or box-shadow"),
      })
    } else {
      None
    }
  })
}

// === Run Full Audit ===

let runAudit = (): auditResult => {
  Log.info("Running accessibility audit")

  let allIssues = Belt.Array.concatMany([
    checkImageAlt(),
    checkContrast(),
    checkFormLabels(),
    checkHeadingHierarchy(),
    checkSkipLinks(),
    // checkFocusIndicators(), // Can be noisy
  ])

  let errors = allIssues->Belt.Array.keep(i => i.severity === Error)->Belt.Array.length
  let warnings = allIssues->Belt.Array.keep(i => i.severity === Warning)->Belt.Array.length

  {
    issues: allIssues,
    passed: 0, // Would need to count passing checks
    failed: errors,
    warnings,
  }
}

// === UI ===

let severityToClass = (s: severity): string => {
  switch s {
  | Error => "error"
  | Warning => "warning"
  | Info => "info"
  }
}

let renderIssue = (issue: issue, index: int): string => {
  let suggestion = switch issue.suggestion {
  | Some(s) => `<div class="grim-a11y-issue-suggestion">💡 ${s}</div>`
  | None => ""
  }

  `<div class="grim-a11y-issue" data-issue-index="${Js.Int.toString(index)}">
    <div class="grim-a11y-issue-header">
      <span class="grim-a11y-issue-severity ${severityToClass(issue.severity)}"></span>
      <span class="grim-a11y-issue-wcag">WCAG ${issue.wcag.id} (${issue.wcag.level})</span>
    </div>
    <div class="grim-a11y-issue-message">${issue.message}</div>
    ${suggestion}
  </div>`
}

let rec showOverlay = (result: auditResult): unit => {
  // Remove existing overlay
  switch DOM.query(".grim-a11y-overlay") {
  | Some(el) => DOM.remove(el)
  | None => ()
  }

  let overlay = DOM.create(~tag="div", ~className="grim-a11y-overlay")

  let issuesHtml = result.issues
    ->Belt.Array.mapWithIndex((i, issue) => renderIssue(issue, i))
    ->Js.Array2.joinWith("")

  DOM.setInnerHTML(overlay, `
    <div class="grim-a11y-header">
      <h3>♿ Accessibility Audit</h3>
      <span class="grim-a11y-close">✕</span>
    </div>
    <div class="grim-a11y-summary">
      <div class="grim-a11y-stat grim-a11y-stat-error">
        <div class="grim-a11y-stat-value">${Js.Int.toString(result.failed)}</div>
        <div class="grim-a11y-stat-label">Errors</div>
      </div>
      <div class="grim-a11y-stat grim-a11y-stat-warning">
        <div class="grim-a11y-stat-value">${Js.Int.toString(result.warnings)}</div>
        <div class="grim-a11y-stat-label">Warnings</div>
      </div>
      <div class="grim-a11y-stat grim-a11y-stat-passed">
        <div class="grim-a11y-stat-value">${Js.Int.toString(result.issues->Belt.Array.length)}</div>
        <div class="grim-a11y-stat-label">Total</div>
      </div>
    </div>
    <div class="grim-a11y-issues">
      ${issuesHtml}
    </div>
    <div class="grim-a11y-actions">
      <button class="grim-a11y-btn grim-a11y-btn-primary" id="grim-a11y-rerun">
        🔄 Re-run Audit
      </button>
      <button class="grim-a11y-btn grim-a11y-btn-secondary" id="grim-a11y-export">
        📋 Export
      </button>
    </div>
  `)

  DOM.appendChild(DOM.body, overlay)

  // Close handler
  switch DOM.query(".grim-a11y-close") {
  | Some(btn) => DOM.addEventListener(btn, "click", _ => {
      // Remove highlights
      DOM.queryAll(".grim-a11y-highlight, .grim-a11y-highlight-warning")
        ->Belt.Array.forEach(el => {
          DOM.classListRemove(el, "grim-a11y-highlight")
          DOM.classListRemove(el, "grim-a11y-highlight-warning")
        })
      DOM.remove(overlay)
    })
  | None => ()
  }

  // Issue click handlers
  DOM.queryAll(".grim-a11y-issue")->Belt.Array.forEach(issueEl => {
    DOM.addEventListener(issueEl, "click", _ => {
      let indexStr = DOM.getAttribute(issueEl, "data-issue-index")->Js.Nullable.toOption
      switch indexStr {
      | Some(idx) => {
          let index = Belt.Int.fromString(idx)->Belt.Option.getWithDefault(0)
          switch result.issues->Belt.Array.get(index) {
          | Some(issue) => {
              // Remove previous highlights
              DOM.queryAll(".grim-a11y-highlight, .grim-a11y-highlight-warning")
                ->Belt.Array.forEach(el => {
                  DOM.classListRemove(el, "grim-a11y-highlight")
                  DOM.classListRemove(el, "grim-a11y-highlight-warning")
                })

              // Highlight and scroll to element
              let highlightClass = issue.severity === Error
                ? "grim-a11y-highlight"
                : "grim-a11y-highlight-warning"
              DOM.classListAdd(issue.element, highlightClass)
              %raw(`issue.element.scrollIntoView({behavior: 'smooth', block: 'center'})`)
            }
          | None => ()
          }
        }
      | None => ()
      }
    })
  })

  // Re-run handler
  switch DOM.query("#grim-a11y-rerun") {
  | Some(btn) => DOM.addEventListener(btn, "click", _ => {
      DOM.remove(overlay)
      run()
    })
  | None => ()
  }

  // Export handler
  switch DOM.query("#grim-a11y-export") {
  | Some(btn) => DOM.addEventListener(btn, "click", _ => {
      let report = result.issues->Belt.Array.map(issue => {
        `[${severityToClass(issue.severity)->Js.String2.toUpperCase}] WCAG ${issue.wcag.id}: ${issue.message}`
      })->Js.Array2.joinWith("\n")

      // Copy to clipboard
      %raw(`navigator.clipboard.writeText(report)`)
      UI.toast(~message="Report copied to clipboard")
    })
  | None => ()
  }
}

// === Entry Point ===

and run = (): unit => {
  Log.info("A11y Overlay running")
  GM.addStyle(css)

  let result = runAudit()
  showOverlay(result)
}

// Register
let () = {
  Registry.register(scriptInfo.name, scriptInfo)

  // Register menu command to run audit
  GM.registerMenuCommand("Run Accessibility Audit", run)
}
