// GitlabEnhanced.res - RSR-Focused GitLab Enhancements
// SPDX-License-Identifier: MPL-2.0 OR LicenseRef-Palimpsest-0.5
//
// Enhances GitLab with RSR awareness:
// - RSR tier badges
// - Language tier highlighting
// - AIBDP indicator
// - STATE.scm quick viewer
//
// @match *://gitlab.com/*
// @match *://*.gitlab.io/*

open GrimCore

// === Types ===

type rsrTier = Tier1 | Tier2 | Prohibited | Unknown

type languageInfo = {
  name: string,
  tier: rsrTier,
  emoji: string,
}

type repoInfo = {
  hasStateScm: bool,
  hasAibdp: bool,
  languages: array<languageInfo>,
  rsrCompliant: bool,
}

// === Constants ===

let scriptInfo: Registry.scriptInfo = {
  name: "grim-gitlab-enhanced",
  version: "1.0.0",
  description: "RSR-focused GitLab enhancements",
  matches: ["*://gitlab.com/*", "*://*.gitlab.io/*"],
}

// RSR Language Tiers
let tier1Languages = [
  ("Rust", "🦀"),
  ("Elixir", "💧"),
  ("Zig", "⚡"),
  ("Ada", "🔧"),
  ("SPARK", "🔧"),
  ("Haskell", "λ"),
  ("ReScript", "📜"),
  ("OCaml", "🐫"),
]

let tier2Languages = [
  ("Nickel", "🔩"),
  ("Racket", "🎾"),
  ("Scheme", "λ"),
  ("Guile", "λ"),
  ("Nix", "❄️"),
  ("Dhall", "📋"),
]

let prohibitedLanguages = [
  ("TypeScript", "🚫"),
  ("JavaScript", "🚫"),
  ("Python", "🐍"),
  ("Go", "🚫"),
  ("CUE", "🚫"),
]

let getLanguageTier = (lang: string): (rsrTier, string) => {
  let normalized = Js.String2.toLowerCase(lang)

  let findIn = (list: array<(string, string)>, tier: rsrTier) => {
    list->Belt.Array.getBy(((name, _)) =>
      Js.String2.toLowerCase(name) === normalized
    )->Belt.Option.map(((_, emoji)) => (tier, emoji))
  }

  findIn(tier1Languages, Tier1)
  ->Belt.Option.orElse(findIn(tier2Languages, Tier2))
  ->Belt.Option.orElse(findIn(prohibitedLanguages, Prohibited))
  ->Belt.Option.getWithDefault((Unknown, "📦"))
}

// === CSS ===

let css = `
  .grim-rsr-badge {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 2px 8px;
    border-radius: 4px;
    font-size: 11px;
    font-weight: 600;
    margin-left: 8px;
  }
  .grim-rsr-tier1 { background: #d4edda; color: #155724; }
  .grim-rsr-tier2 { background: #fff3cd; color: #856404; }
  .grim-rsr-prohibited { background: #f8d7da; color: #721c24; }
  .grim-rsr-unknown { background: #e9ecef; color: #495057; }

  .grim-lang-badge {
    display: inline-flex;
    align-items: center;
    gap: 2px;
    padding: 1px 6px;
    border-radius: 3px;
    font-size: 10px;
    margin: 2px;
  }

  .grim-state-viewer {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    background: #1e1e1e;
    color: #d4d4d4;
    padding: 20px;
    border-radius: 8px;
    max-width: 600px;
    max-height: 80vh;
    overflow: auto;
    z-index: 100000;
    font-family: 'JetBrains Mono', 'Fira Code', monospace;
    font-size: 13px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
  }
  .grim-state-viewer pre {
    margin: 0;
    white-space: pre-wrap;
  }
  .grim-state-viewer-close {
    position: absolute;
    top: 10px;
    right: 10px;
    cursor: pointer;
    font-size: 18px;
    opacity: 0.6;
  }
  .grim-state-viewer-close:hover { opacity: 1; }
  .grim-state-viewer-title {
    font-weight: 600;
    margin-bottom: 12px;
    color: #569cd6;
  }

  .grim-rsr-indicator {
    position: fixed;
    top: 60px;
    right: 20px;
    z-index: 99990;
    background: white;
    border: 1px solid #dfe6e9;
    border-radius: 8px;
    padding: 12px 16px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    font-size: 12px;
  }
  .grim-rsr-indicator-row {
    display: flex;
    align-items: center;
    gap: 8px;
    margin: 4px 0;
  }
  .grim-rsr-indicator-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
  }
  .grim-rsr-indicator-dot.green { background: #27ae60; }
  .grim-rsr-indicator-dot.yellow { background: #f39c12; }
  .grim-rsr-indicator-dot.red { background: #e74c3c; }
  .grim-rsr-indicator-dot.gray { background: #95a5a6; }
`

// === Detection ===

let isRepoPage = (): bool => {
  let path = URL.locationPathname
  // Match patterns like /user/repo, /group/subgroup/repo
  let parts = path->Js.String2.split("/")->Belt.Array.keep(s => s !== "")
  parts->Belt.Array.length >= 2 &&
    !(path->Js.String2.includes("/explore")) &&
    !(path->Js.String2.includes("/dashboard"))
}

let getRepoPath = (): option<string> => {
  if isRepoPage() {
    let path = URL.locationPathname
    let parts = path->Js.String2.split("/")->Belt.Array.keep(s => s !== "")
    // Take first 2-3 parts as repo path
    let repoPath = parts->Belt.Array.slice(~offset=0, ~len=3)->Js.Array2.joinWith("/")
    Some(repoPath)
  } else {
    None
  }
}

let checkFile = (repoPath: string, filePath: string): Js.Promise.t<bool> => {
  let url = `https://gitlab.com/${repoPath}/-/raw/main/${filePath}`
  HTTP.fetch(url)
  ->Js.Promise.then_((resp: HTTP.response) => Js.Promise.resolve(resp.status === 200), _)
  ->Js.Promise.catch(_ => Js.Promise.resolve(false), _)
}

let fetchStateScm = (repoPath: string): Js.Promise.t<option<string>> => {
  let url = `https://gitlab.com/${repoPath}/-/raw/main/STATE.scm`
  HTTP.fetch(url)
  ->Js.Promise.then_((resp: HTTP.response) => {
    if resp.status === 200 {
      Js.Promise.resolve(Some(resp.responseText))
    } else {
      Js.Promise.resolve(None)
    }
  }, _)
  ->Js.Promise.catch(_ => Js.Promise.resolve(None), _)
}

let getRepoLanguages = (): array<string> => {
  // Try to extract languages from GitLab's language bar
  let langElements = DOM.queryAll(".repository-language-bar-tooltip, [data-testid='language-stats'] span")
  langElements->Belt.Array.map(el => DOM.getTextContent(el)->Js.String2.trim)
    ->Belt.Array.keep(s => s !== "" && !Js.String2.includes(s, "%"))
}

// === UI Components ===

let createRsrBadge = (tier: rsrTier, text: string): Dom.element => {
  let className = switch tier {
  | Tier1 => "grim-rsr-badge grim-rsr-tier1"
  | Tier2 => "grim-rsr-badge grim-rsr-tier2"
  | Prohibited => "grim-rsr-badge grim-rsr-prohibited"
  | Unknown => "grim-rsr-badge grim-rsr-unknown"
  }
  let badge = DOM.create(~tag="span", ~className)
  DOM.setTextContent(badge, text)
  badge
}

let createLanguageBadge = (lang: string): Dom.element => {
  let (tier, emoji) = getLanguageTier(lang)
  let className = switch tier {
  | Tier1 => "grim-lang-badge grim-rsr-tier1"
  | Tier2 => "grim-lang-badge grim-rsr-tier2"
  | Prohibited => "grim-lang-badge grim-rsr-prohibited"
  | Unknown => "grim-lang-badge grim-rsr-unknown"
  }
  let badge = DOM.create(~tag="span", ~className)
  DOM.setTextContent(badge, `${emoji} ${lang}`)
  badge
}

let showStateViewer = (content: string): unit => {
  // Remove existing viewer
  switch DOM.query(".grim-state-viewer") {
  | Some(el) => DOM.remove(el)
  | None => ()
  }

  let viewer = DOM.create(~tag="div", ~className="grim-state-viewer")
  DOM.setInnerHTML(viewer, `
    <span class="grim-state-viewer-close">✕</span>
    <div class="grim-state-viewer-title">📋 STATE.scm</div>
    <pre>${content}</pre>
  `)

  DOM.appendChild(DOM.body, viewer)

  // Close handler
  switch DOM.query(".grim-state-viewer-close") {
  | Some(closeBtn) =>
    DOM.addEventListener(closeBtn, "click", _ => DOM.remove(viewer))
  | None => ()
  }

  // ESC to close
  DOM.addEventListener(DOM.body, "keydown", event => {
    if %raw(`event.key === "Escape"`) {
      DOM.remove(viewer)
    }
  })
}

let createRsrIndicator = (info: repoInfo): unit => {
  let indicator = DOM.create(~tag="div", ~className="grim-rsr-indicator")

  let rows = [
    (info.hasStateScm, "STATE.scm"),
    (info.hasAibdp, "AIBDP"),
  ]

  let rowsHtml = rows->Belt.Array.map(((present, label)) => {
    let dotClass = present ? "green" : "gray"
    let status = present ? "✓" : "✗"
    `<div class="grim-rsr-indicator-row">
      <span class="grim-rsr-indicator-dot ${dotClass}"></span>
      <span>${status} ${label}</span>
    </div>`
  })->Js.Array2.joinWith("")

  // Language summary
  let hasTier1 = info.languages->Belt.Array.some(l => l.tier === Tier1)
  let hasProhibited = info.languages->Belt.Array.some(l => l.tier === Prohibited)

  let complianceClass = if hasProhibited { "red" }
    else if hasTier1 { "green" }
    else { "yellow" }

  let complianceText = if hasProhibited { "⚠️ Has prohibited languages" }
    else if hasTier1 { "✓ RSR Tier 1" }
    else { "○ Unknown tier" }

  DOM.setInnerHTML(indicator, `
    <strong>RSR Status</strong>
    ${rowsHtml}
    <div class="grim-rsr-indicator-row">
      <span class="grim-rsr-indicator-dot ${complianceClass}"></span>
      <span>${complianceText}</span>
    </div>
  `)

  DOM.appendChild(DOM.body, indicator)
}

// === Main Logic ===

let enhanceRepoPage = (repoPath: string): unit => {
  Log.info(`Enhancing repo: ${repoPath}`)

  // Check for RSR files
  Js.Promise.all2((
    checkFile(repoPath, "STATE.scm"),
    checkFile(repoPath, ".well-known/aibdp.json"),
  ))
  ->Js.Promise.then_(((hasState, hasAibdp)) => {
    let languages = getRepoLanguages()->Belt.Array.map(name => {
      let (tier, emoji) = getLanguageTier(name)
      {name, tier, emoji}
    })

    let info = {
      hasStateScm: hasState,
      hasAibdp: hasAibdp,
      languages,
      rsrCompliant: hasState && hasAibdp,
    }

    createRsrIndicator(info)

    // Add STATE.scm viewer button if present
    if hasState {
      GM.registerMenuCommand("View STATE.scm", () => {
        fetchStateScm(repoPath)
        ->Js.Promise.then_(content => {
          switch content {
          | Some(c) => showStateViewer(c)
          | None => UI.toast(~message="Failed to load STATE.scm")
          }
          Js.Promise.resolve()
        }, _)
        ->ignore
      })
    }

    Js.Promise.resolve()
  }, _)
  ->ignore

  // Enhance language badges in the UI
  let langBar = DOM.query(".repository-languages, [data-testid='language-stats']")
  switch langBar {
  | Some(el) => {
      let langNames = getRepoLanguages()
      langNames->Belt.Array.forEach(name => {
        let badge = createLanguageBadge(name)
        DOM.appendChild(el, badge)
      })
    }
  | None => ()
  }
}

let enhanceProjectList = (): unit => {
  // Enhance project cards in lists
  let projectCards = DOM.queryAll(".project-card, .project-row")
  projectCards->Belt.Array.forEach(card => {
    // Extract project path from card
    let link = %raw(`card.querySelector('a.project')`)
    if !Js.Nullable.isNullable(link) {
      let href: string = %raw(`link.getAttribute('href')`)
      // Could check for RSR files here, but would be many requests
      // Instead, just add tier badges for visible languages
    }
  })
}

// === Entry Point ===

let run = (): unit => {
  if URL.isGitLab() {
    Log.info("GitLab Enhanced running")
    GM.addStyle(css)

    switch getRepoPath() {
    | Some(repoPath) => enhanceRepoPage(repoPath)
    | None => enhanceProjectList()
    }

    // Register menu commands
    GM.registerMenuCommand("Show RSR Info", () => {
      switch getRepoPath() {
      | Some(path) => UI.toast(~message=`Repo: ${path}`)
      | None => UI.toast(~message="Not on a repo page")
      }
    })
  }
}

// Register and run
let () = {
  Registry.register(scriptInfo.name, scriptInfo)

  if %raw(`document.readyState === "complete"`) {
    run()
  } else {
    DOM.addEventListener(DOM.body, "DOMContentLoaded", _ => run())
  }
}
