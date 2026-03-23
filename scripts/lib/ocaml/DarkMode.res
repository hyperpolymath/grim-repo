// DarkMode.res - Universal Dark Mode with Sinople Color Schemes
// SPDX-License-Identifier: PMPL-1.0-or-later OR LicenseRef-Palimpsest-0.5
//
// Applies RSR sinople color schemes as dark mode to any website.
// Supports 10 themes from the RSR ecosystem.
//
// @match *://*/*

open GrimCore

// === Types ===

type colorScheme = {
  name: string,
  primary: string,
  secondary: string,
  accent: string,
  background: string,
  text: string,
  textMuted: string,
  border: string,
}

// === Constants ===

let scriptInfo: Registry.scriptInfo = {
  name: "grim-dark-mode",
  version: "1.0.0",
  description: "Universal dark mode with sinople color schemes",
  matches: ["*://*/*"],
}

// Sinople color schemes
let schemes: array<colorScheme> = [
  {
    name: "fogbinder",
    primary: "#9b59b6",
    secondary: "#1a1a2e",
    accent: "#e17055",
    background: "#0f0f23",
    text: "#f8f9fa",
    textMuted: "#a0a0a0",
    border: "#2d2d4a",
  },
  {
    name: "conative",
    primary: "#6c5ce7",
    secondary: "#16213e",
    accent: "#00b894",
    background: "#0d1117",
    text: "#e6edf3",
    textMuted: "#8b949e",
    border: "#30363d",
  },
  {
    name: "rhodium",
    primary: "#cd7f32",
    secondary: "#1a1a1a",
    accent: "#00cec9",
    background: "#0d0d0d",
    text: "#f0f0f0",
    textMuted: "#888888",
    border: "#333333",
  },
  {
    name: "zotero",
    primary: "#cc2936",
    secondary: "#1a1a1a",
    accent: "#0984e3",
    background: "#121212",
    text: "#e0e0e0",
    textMuted: "#9e9e9e",
    border: "#2d2d2d",
  },
  {
    name: "echidna",
    primary: "#2980b9",
    secondary: "#1a1a2e",
    accent: "#f39c12",
    background: "#0a0a14",
    text: "#e8e8e8",
    textMuted: "#888888",
    border: "#2a2a3e",
  },
  {
    name: "wharf",
    primary: "#27ae60",
    secondary: "#1a2634",
    accent: "#e74c3c",
    background: "#0d1821",
    text: "#ecf0f1",
    textMuted: "#7f8c8d",
    border: "#2c3e50",
  },
  {
    name: "bastion",
    primary: "#8e44ad",
    secondary: "#1a2634",
    accent: "#3498db",
    background: "#0f1624",
    text: "#ecf0f1",
    textMuted: "#7f8c8d",
    border: "#2c3e50",
  },
  {
    name: "vext",
    primary: "#1abc9c",
    secondary: "#1a1a1a",
    accent: "#e74c3c",
    background: "#0d0d0d",
    text: "#f0f0f0",
    textMuted: "#888888",
    border: "#2d2d2d",
  },
  {
    name: "palimpsest",
    primary: "#5f27cd",
    secondary: "#151520",
    accent: "#ff9f43",
    background: "#0a0a10",
    text: "#f5f6fa",
    textMuted: "#8a8a9a",
    border: "#25253a",
  },
  {
    name: "kith",
    primary: "#10ac84",
    secondary: "#151520",
    accent: "#ee5253",
    background: "#0a0a10",
    text: "#f5f6fa",
    textMuted: "#8a8a9a",
    border: "#25253a",
  },
]

let defaultScheme = "fogbinder"

// === CSS Generation ===

let generateCSS = (scheme: colorScheme): string => {
  `
  /* Grim Dark Mode - ${scheme.name} */

  :root {
    --grim-bg: ${scheme.background};
    --grim-text: ${scheme.text};
    --grim-text-muted: ${scheme.textMuted};
    --grim-primary: ${scheme.primary};
    --grim-secondary: ${scheme.secondary};
    --grim-accent: ${scheme.accent};
    --grim-border: ${scheme.border};
  }

  html.grim-dark-mode,
  html.grim-dark-mode body {
    background-color: var(--grim-bg) !important;
    color: var(--grim-text) !important;
  }

  html.grim-dark-mode *:not(
    img, video, picture, canvas, iframe, svg,
    [class*="icon"], [class*="logo"], [class*="avatar"],
    .grim-dark-mode-panel, .grim-dark-mode-panel *
  ) {
    background-color: inherit;
    color: inherit;
    border-color: var(--grim-border) !important;
  }

  /* Headers and text */
  html.grim-dark-mode h1,
  html.grim-dark-mode h2,
  html.grim-dark-mode h3,
  html.grim-dark-mode h4,
  html.grim-dark-mode h5,
  html.grim-dark-mode h6 {
    color: var(--grim-text) !important;
  }

  html.grim-dark-mode p,
  html.grim-dark-mode span,
  html.grim-dark-mode li,
  html.grim-dark-mode td,
  html.grim-dark-mode th,
  html.grim-dark-mode label {
    color: var(--grim-text) !important;
  }

  /* Muted text */
  html.grim-dark-mode .text-muted,
  html.grim-dark-mode .text-secondary,
  html.grim-dark-mode small,
  html.grim-dark-mode .meta,
  html.grim-dark-mode time,
  html.grim-dark-mode .date {
    color: var(--grim-text-muted) !important;
  }

  /* Links */
  html.grim-dark-mode a {
    color: var(--grim-primary) !important;
  }
  html.grim-dark-mode a:hover {
    color: var(--grim-accent) !important;
  }

  /* Backgrounds */
  html.grim-dark-mode div,
  html.grim-dark-mode section,
  html.grim-dark-mode article,
  html.grim-dark-mode header,
  html.grim-dark-mode footer,
  html.grim-dark-mode nav,
  html.grim-dark-mode aside,
  html.grim-dark-mode main {
    background-color: var(--grim-bg) !important;
  }

  /* Cards and panels */
  html.grim-dark-mode .card,
  html.grim-dark-mode .panel,
  html.grim-dark-mode .box,
  html.grim-dark-mode .container,
  html.grim-dark-mode .wrapper {
    background-color: var(--grim-secondary) !important;
    border-color: var(--grim-border) !important;
  }

  /* Inputs */
  html.grim-dark-mode input,
  html.grim-dark-mode textarea,
  html.grim-dark-mode select {
    background-color: var(--grim-secondary) !important;
    color: var(--grim-text) !important;
    border-color: var(--grim-border) !important;
  }
  html.grim-dark-mode input::placeholder,
  html.grim-dark-mode textarea::placeholder {
    color: var(--grim-text-muted) !important;
  }

  /* Buttons */
  html.grim-dark-mode button,
  html.grim-dark-mode .btn,
  html.grim-dark-mode [role="button"] {
    background-color: var(--grim-primary) !important;
    color: var(--grim-bg) !important;
    border-color: var(--grim-primary) !important;
  }
  html.grim-dark-mode button:hover,
  html.grim-dark-mode .btn:hover {
    background-color: var(--grim-accent) !important;
    border-color: var(--grim-accent) !important;
  }

  /* Code */
  html.grim-dark-mode pre,
  html.grim-dark-mode code {
    background-color: ${scheme.secondary} !important;
    color: ${scheme.accent} !important;
  }

  /* Tables */
  html.grim-dark-mode table {
    background-color: var(--grim-bg) !important;
  }
  html.grim-dark-mode th {
    background-color: var(--grim-secondary) !important;
  }
  html.grim-dark-mode tr:nth-child(even) {
    background-color: rgba(255, 255, 255, 0.02) !important;
  }
  html.grim-dark-mode tr:hover {
    background-color: rgba(255, 255, 255, 0.05) !important;
  }

  /* Scrollbar */
  html.grim-dark-mode ::-webkit-scrollbar {
    width: 10px;
    height: 10px;
  }
  html.grim-dark-mode ::-webkit-scrollbar-track {
    background: var(--grim-bg);
  }
  html.grim-dark-mode ::-webkit-scrollbar-thumb {
    background: var(--grim-border);
    border-radius: 5px;
  }
  html.grim-dark-mode ::-webkit-scrollbar-thumb:hover {
    background: var(--grim-text-muted);
  }

  /* Selection */
  html.grim-dark-mode ::selection {
    background: var(--grim-primary);
    color: var(--grim-bg);
  }

  /* Focus */
  html.grim-dark-mode *:focus {
    outline-color: var(--grim-primary) !important;
  }
  `
}

// Panel CSS
let panelCSS = `
  .grim-dark-mode-panel {
    position: fixed;
    bottom: 20px;
    right: 20px;
    z-index: 999999;
    background: #1a1a2e !important;
    border: 1px solid #2d2d4a !important;
    border-radius: 12px;
    padding: 16px;
    min-width: 200px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    font-family: -apple-system, BlinkMacSystemFont, sans-serif !important;
    color: #f8f9fa !important;
  }
  .grim-dark-mode-panel * {
    color: #f8f9fa !important;
  }
  .grim-dark-mode-toggle {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 12px;
  }
  .grim-dark-mode-toggle-label {
    font-weight: 600;
    font-size: 14px !important;
  }
  .grim-dark-mode-switch {
    position: relative;
    width: 48px;
    height: 24px;
    background: #2d2d4a;
    border-radius: 12px;
    cursor: pointer;
    transition: background 0.2s;
  }
  .grim-dark-mode-switch.active {
    background: #6c5ce7;
  }
  .grim-dark-mode-switch::after {
    content: '';
    position: absolute;
    top: 2px;
    left: 2px;
    width: 20px;
    height: 20px;
    background: #f8f9fa;
    border-radius: 50%;
    transition: transform 0.2s;
  }
  .grim-dark-mode-switch.active::after {
    transform: translateX(24px);
  }
  .grim-dark-mode-schemes {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 6px;
  }
  .grim-dark-mode-scheme {
    width: 28px;
    height: 28px;
    border-radius: 6px;
    cursor: pointer;
    border: 2px solid transparent;
    transition: border-color 0.2s, transform 0.2s;
  }
  .grim-dark-mode-scheme:hover {
    transform: scale(1.1);
  }
  .grim-dark-mode-scheme.active {
    border-color: #f8f9fa;
  }
  .grim-dark-mode-scheme-name {
    font-size: 10px !important;
    color: #a0a0a0 !important;
    text-align: center;
    margin-top: 8px;
  }
  .grim-dark-mode-collapse {
    position: absolute;
    top: 8px;
    right: 8px;
    cursor: pointer;
    opacity: 0.6;
    font-size: 16px !important;
  }
  .grim-dark-mode-collapse:hover { opacity: 1; }
  .grim-dark-mode-panel.collapsed {
    min-width: auto;
    padding: 8px 12px;
  }
  .grim-dark-mode-panel.collapsed .grim-dark-mode-schemes,
  .grim-dark-mode-panel.collapsed .grim-dark-mode-scheme-name {
    display: none;
  }
`

// === State ===

let storageKey = "dark_mode"
let schemeKey = "dark_mode_scheme"
let styleElement: ref<option<Dom.element>> = ref(None)

// === Functions ===

let getScheme = (name: string): option<colorScheme> => {
  schemes->Belt.Array.getBy(s => s.name === name)
}

let applyScheme = (scheme: colorScheme): unit => {
  // Remove existing style
  switch styleElement.contents {
  | Some(el) => DOM.remove(el)
  | None => ()
  }

  // Add new style
  let style = DOM.create(~tag="style", ~id="grim-dark-mode-style")
  DOM.setInnerHTML(style, generateCSS(scheme))

  let head = DOM.query("head")
  switch head {
  | Some(h) => DOM.appendChild(h, style)
  | None => ()
  }

  styleElement := Some(style)

  // Add class to html
  switch DOM.query("html") {
  | Some(html) => DOM.classListAdd(html, "grim-dark-mode")
  | None => ()
  }

  Log.debug(`Applied scheme: ${scheme.name}`)
}

let removeScheme = (): unit => {
  switch styleElement.contents {
  | Some(el) => {
      DOM.remove(el)
      styleElement := None
    }
  | None => ()
  }

  switch DOM.query("html") {
  | Some(html) => DOM.classListRemove(html, "grim-dark-mode")
  | None => ()
  }
}

let isEnabled = (): Js.Promise.t<bool> => {
  Storage.get(~storage=Local, storageKey)
  ->Js.Promise.then_(value => {
    Js.Promise.resolve(value === Some("true"))
  }, _)
}

let getCurrentScheme = (): Js.Promise.t<string> => {
  Storage.get(~storage=Local, schemeKey)
  ->Js.Promise.then_(value => {
    Js.Promise.resolve(Belt.Option.getWithDefault(value, defaultScheme))
  }, _)
}

let setEnabled = (enabled: bool, schemeName: string): Js.Promise.t<unit> => {
  if enabled {
    switch getScheme(schemeName) {
    | Some(scheme) => applyScheme(scheme)
    | None => ()
    }
  } else {
    removeScheme()
  }

  Storage.set(~storage=Local, storageKey, enabled ? "true" : "false")
  ->Js.Promise.then_(_ => {
    Storage.set(~storage=Local, schemeKey, schemeName)
  }, _)
}

// === UI ===

let createPanel = (enabled: bool, schemeName: string): unit => {
  GM.addStyle(panelCSS)

  let panel = DOM.create(~tag="div", ~className="grim-dark-mode-panel")

  let schemesHtml = schemes->Belt.Array.map(scheme => {
    let activeClass = scheme.name === schemeName ? "active" : ""
    `<div class="grim-dark-mode-scheme ${activeClass}"
          data-scheme="${scheme.name}"
          style="background: linear-gradient(135deg, ${scheme.primary}, ${scheme.accent})"
          title="${scheme.name}"></div>`
  })->Js.Array2.joinWith("")

  let switchClass = enabled ? "active" : ""

  DOM.setInnerHTML(panel, `
    <span class="grim-dark-mode-collapse">−</span>
    <div class="grim-dark-mode-toggle">
      <span class="grim-dark-mode-toggle-label">🌙 Dark Mode</span>
      <div class="grim-dark-mode-switch ${switchClass}" id="grim-dark-toggle"></div>
    </div>
    <div class="grim-dark-mode-schemes">
      ${schemesHtml}
    </div>
    <div class="grim-dark-mode-scheme-name">${schemeName}</div>
  `)

  DOM.appendChild(DOM.body, panel)

  // Toggle handler
  switch DOM.query("#grim-dark-toggle") {
  | Some(toggle) => {
      DOM.addEventListener(toggle, "click", _ => {
        let isActive = DOM.classListContains(toggle, "active")
        let newEnabled = !isActive

        if newEnabled {
          DOM.classListAdd(toggle, "active")
        } else {
          DOM.classListRemove(toggle, "active")
        }

        getCurrentScheme()
        ->Js.Promise.then_(scheme => {
          setEnabled(newEnabled, scheme)
        }, _)
        ->ignore
      })
    }
  | None => ()
  }

  // Scheme selection handlers
  DOM.queryAll(".grim-dark-mode-scheme")->Belt.Array.forEach(schemeEl => {
    DOM.addEventListener(schemeEl, "click", _ => {
      let name = DOM.getAttribute(schemeEl, "data-scheme")->Js.Nullable.toOption
      switch name {
      | Some(schemeName) => {
          // Update active class
          DOM.queryAll(".grim-dark-mode-scheme")->Belt.Array.forEach(el => {
            DOM.classListRemove(el, "active")
          })
          DOM.classListAdd(schemeEl, "active")

          // Update name display
          switch DOM.query(".grim-dark-mode-scheme-name") {
          | Some(nameEl) => DOM.setTextContent(nameEl, schemeName)
          | None => ()
          }

          // Apply if enabled
          isEnabled()
          ->Js.Promise.then_(enabled => {
            if enabled {
              setEnabled(true, schemeName)->ignore
            } else {
              Storage.set(~storage=Local, schemeKey, schemeName)->ignore
            }
            Js.Promise.resolve()
          }, _)
          ->ignore
        }
      | None => ()
      }
    })
  })

  // Collapse handler
  switch DOM.query(".grim-dark-mode-collapse") {
  | Some(btn) => {
      DOM.addEventListener(btn, "click", _ => {
        DOM.classListToggle(panel, "collapsed")->ignore
        let isCollapsed = DOM.classListContains(panel, "collapsed")
        DOM.setTextContent(btn, isCollapsed ? "+" : "−")
      })
    }
  | None => ()
  }
}

// === Entry Point ===

let run = (): unit => {
  Log.info("Dark Mode running")

  Js.Promise.all2((isEnabled(), getCurrentScheme()))
  ->Js.Promise.then_(((enabled, schemeName)) => {
    if enabled {
      switch getScheme(schemeName) {
      | Some(scheme) => applyScheme(scheme)
      | None => ()
      }
    }

    createPanel(enabled, schemeName)
    Js.Promise.resolve()
  }, _)
  ->ignore
}

// Register
let () = {
  Registry.register(scriptInfo.name, scriptInfo)

  if %raw(`document.readyState === "complete"`) {
    run()
  } else {
    DOM.addEventListener(DOM.body, "DOMContentLoaded", _ => run())
  }
}
