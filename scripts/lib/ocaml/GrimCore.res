// GrimCore.res - Shared Infrastructure for Grimrepo Scripts
// SPDX-License-Identifier: MPL-2.0 OR LicenseRef-Palimpsest-0.5
//
// This module provides common utilities for all grimrepo userscripts.
// ReScript-first, compiles to clean JS for browser userscript managers.

// === External Bindings ===

module GM = {
  // Greasemonkey/Tampermonkey API bindings
  @val external getValue: (string, string) => Js.Promise.t<string> = "GM_getValue"
  @val external setValue: (string, string) => Js.Promise.t<unit> = "GM_setValue"
  @val external deleteValue: string => Js.Promise.t<unit> = "GM_deleteValue"
  @val external listValues: unit => Js.Promise.t<array<string>> = "GM_listValues"

  @val external xmlHttpRequest: {
    "method": string,
    "url": string,
    "headers": option<Js.Dict.t<string>>,
    "onload": option<{..} => unit>,
    "onerror": option<{..} => unit>,
  } => unit = "GM_xmlHttpRequest"

  @val external addStyle: string => unit = "GM_addStyle"
  @val external registerMenuCommand: (string, unit => unit) => unit = "GM_registerMenuCommand"
  @val external notification: {
    "title": string,
    "text": string,
    "timeout": option<int>,
  } => unit = "GM_notification"

  @val external getResourceText: string => string = "GM_getResourceText"
  @val external openInTab: (string, bool) => unit = "GM_openInTab"
}

// === Configuration ===

module Config = {
  type t = {
    version: string,
    debug: bool,
    prefix: string,
  }

  let default: t = {
    version: "1.0.0",
    debug: false,
    prefix: "grim",
  }

  let current = ref(default)

  let setDebug = (enabled: bool) => {
    current := {...current.contents, debug: enabled}
  }

  let isDebug = () => current.contents.debug
}

// === Logging ===

module Log = {
  let prefix = "[Grim]"

  let info = (msg: string) => {
    Js.Console.log2(prefix, msg)
  }

  let warn = (msg: string) => {
    Js.Console.warn2(prefix, msg)
  }

  let error = (msg: string) => {
    Js.Console.error2(prefix, msg)
  }

  let debug = (msg: string) => {
    if Config.isDebug() {
      Js.Console.log3(prefix, "[DEBUG]", msg)
    }
  }
}

// === DOM Utilities ===

module DOM = {
  @val external document: Dom.document = "document"
  @val external window: Dom.window = "window"

  // Query single element
  @send external querySelector: (Dom.document, string) => Js.Nullable.t<Dom.element> = "querySelector"

  // Query all elements
  @send external querySelectorAll: (Dom.document, string) => Dom.nodeList = "querySelectorAll"

  // Element creation
  @send external createElement: (Dom.document, string) => Dom.element = "createElement"

  // Element manipulation
  @send external appendChild: (Dom.element, Dom.element) => unit = "appendChild"
  @send external removeChild: (Dom.element, Dom.element) => unit = "removeChild"
  @send external remove: Dom.element => unit = "remove"

  // Attributes
  @send external getAttribute: (Dom.element, string) => Js.Nullable.t<string> = "getAttribute"
  @send external setAttribute: (Dom.element, string, string) => unit = "setAttribute"
  @send external hasAttribute: (Dom.element, string) => bool = "hasAttribute"

  // Classes
  @send external classListAdd: (Dom.element, string) => unit = "classList.add"
  @send external classListRemove: (Dom.element, string) => unit = "classList.remove"
  @send external classListToggle: (Dom.element, string) => bool = "classList.toggle"
  @send external classListContains: (Dom.element, string) => bool = "classList.contains"

  // Content
  @set external setInnerHTML: (Dom.element, string) => unit = "innerHTML"
  @get external getInnerHTML: Dom.element => string = "innerHTML"
  @set external setTextContent: (Dom.element, string) => unit = "textContent"
  @get external getTextContent: Dom.element => string = "textContent"

  // Styles
  @set external setStyle: (Dom.element, string) => unit = "style.cssText"
  @send external setStyleProperty: (Dom.element, string, string) => unit = "style.setProperty"

  // Events
  @send external addEventListener: (Dom.element, string, Dom.event => unit) => unit = "addEventListener"
  @send external removeEventListener: (Dom.element, string, Dom.event => unit) => unit = "removeEventListener"

  // Helper: Query with option
  let query = (selector: string): option<Dom.element> => {
    querySelector(document, selector)->Js.Nullable.toOption
  }

  // Helper: Query all as array
  let queryAll = (selector: string): array<Dom.element> => {
    let nodeList = querySelectorAll(document, selector)
    // Convert NodeList to array
    %raw(`Array.from(nodeList)`)
  }

  // Helper: Create element with class
  let create = (~tag: string, ~className: string="", ~id: string=""): Dom.element => {
    let el = createElement(document, tag)
    if className !== "" {
      classListAdd(el, className)
    }
    if id !== "" {
      setAttribute(el, "id", id)
    }
    el
  }

  // Helper: Wait for element
  let waitFor = (selector: string, ~timeout: int=5000): Js.Promise.t<option<Dom.element>> => {
    Js.Promise.make((~resolve, ~reject as _) => {
      let startTime = Js.Date.now()

      let rec check = () => {
        switch query(selector) {
        | Some(el) => resolve(Some(el))
        | None =>
          if Js.Date.now() -. startTime > float_of_int(timeout) {
            resolve(None)
          } else {
            let _ = Js.Global.setTimeout(check, 100)
          }
        }
      }

      check()
    })
  }

  // Helper: Get body element
  @val external body: Dom.element = "document.body"
}

// === Storage ===

module Storage = {
  type storageType = Local | Session | GM

  let storagePrefix = "grim_"

  let prefixKey = (key: string) => storagePrefix ++ key

  // Local Storage
  @val @scope("localStorage") external localGet: string => Js.Nullable.t<string> = "getItem"
  @val @scope("localStorage") external localSet: (string, string) => unit = "setItem"
  @val @scope("localStorage") external localRemove: string => unit = "removeItem"

  // Session Storage
  @val @scope("sessionStorage") external sessionGet: string => Js.Nullable.t<string> = "getItem"
  @val @scope("sessionStorage") external sessionSet: (string, string) => unit = "setItem"
  @val @scope("sessionStorage") external sessionRemove: string => unit = "removeItem"

  let get = (~storage: storageType=Local, key: string): Js.Promise.t<option<string>> => {
    let prefixedKey = prefixKey(key)
    switch storage {
    | Local =>
      Js.Promise.resolve(localGet(prefixedKey)->Js.Nullable.toOption)
    | Session =>
      Js.Promise.resolve(sessionGet(prefixedKey)->Js.Nullable.toOption)
    | GM =>
      GM.getValue(prefixedKey, "")
      ->Js.Promise.then_(value => {
        Js.Promise.resolve(value === "" ? None : Some(value))
      }, _)
    }
  }

  let set = (~storage: storageType=Local, key: string, value: string): Js.Promise.t<unit> => {
    let prefixedKey = prefixKey(key)
    switch storage {
    | Local =>
      localSet(prefixedKey, value)
      Js.Promise.resolve()
    | Session =>
      sessionSet(prefixedKey, value)
      Js.Promise.resolve()
    | GM =>
      GM.setValue(prefixedKey, value)
    }
  }

  let remove = (~storage: storageType=Local, key: string): Js.Promise.t<unit> => {
    let prefixedKey = prefixKey(key)
    switch storage {
    | Local =>
      localRemove(prefixedKey)
      Js.Promise.resolve()
    | Session =>
      sessionRemove(prefixedKey)
      Js.Promise.resolve()
    | GM =>
      GM.deleteValue(prefixedKey)
    }
  }

  // JSON helpers
  let getJson = (~storage: storageType=Local, key: string): Js.Promise.t<option<Js.Json.t>> => {
    get(~storage, key)
    ->Js.Promise.then_(value => {
      switch value {
      | Some(str) =>
        try {
          Js.Promise.resolve(Some(Js.Json.parseExn(str)))
        } catch {
        | _ => Js.Promise.resolve(None)
        }
      | None => Js.Promise.resolve(None)
      }
    }, _)
  }

  let setJson = (~storage: storageType=Local, key: string, value: Js.Json.t): Js.Promise.t<unit> => {
    set(~storage, key, Js.Json.stringify(value))
  }
}

// === HTTP Utilities ===

module HTTP = {
  type response = {
    status: int,
    statusText: string,
    responseText: string,
    responseHeaders: string,
  }

  type method = GET | POST | PUT | DELETE | PATCH

  let methodToString = (m: method): string => {
    switch m {
    | GET => "GET"
    | POST => "POST"
    | PUT => "PUT"
    | DELETE => "DELETE"
    | PATCH => "PATCH"
    }
  }

  let fetch = (
    ~method: method=GET,
    ~headers: option<Js.Dict.t<string>>=?,
    url: string
  ): Js.Promise.t<response> => {
    Js.Promise.make((~resolve, ~reject) => {
      GM.xmlHttpRequest({
        "method": methodToString(method),
        "url": url,
        "headers": headers,
        "onload": Some(resp => {
          resolve({
            status: %raw(`resp.status`),
            statusText: %raw(`resp.statusText`),
            responseText: %raw(`resp.responseText`),
            responseHeaders: %raw(`resp.responseHeaders`),
          })
        }),
        "onerror": Some(err => {
          reject(Js.Exn.raiseError(%raw(`err.statusText || "Network error"`)))
        }),
      })
    })
  }

  let fetchJson = (
    ~method: method=GET,
    ~headers: option<Js.Dict.t<string>>=?,
    url: string
  ): Js.Promise.t<Js.Json.t> => {
    fetch(~method, ~headers?, url)
    ->Js.Promise.then_(resp => {
      Js.Promise.resolve(Js.Json.parseExn(resp.responseText))
    }, _)
  }
}

// === UI Components ===

module UI = {
  // Base CSS for all UI components
  let baseCSS = `
    .grim-panel {
      position: fixed;
      z-index: 99999;
      background: #ffffff;
      border: 1px solid #dfe6e9;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      font-size: 14px;
      color: #2d3436;
    }
    .grim-panel-header {
      padding: 12px 16px;
      border-bottom: 1px solid #dfe6e9;
      font-weight: 600;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .grim-panel-body {
      padding: 16px;
      max-height: 400px;
      overflow-y: auto;
    }
    .grim-panel-close {
      cursor: pointer;
      opacity: 0.6;
      transition: opacity 0.2s;
    }
    .grim-panel-close:hover {
      opacity: 1;
    }
    .grim-badge {
      display: inline-flex;
      align-items: center;
      padding: 4px 8px;
      border-radius: 4px;
      font-size: 12px;
      font-weight: 500;
    }
    .grim-badge-success { background: #d4edda; color: #155724; }
    .grim-badge-warning { background: #fff3cd; color: #856404; }
    .grim-badge-error { background: #f8d7da; color: #721c24; }
    .grim-badge-info { background: #cce5ff; color: #004085; }
    .grim-toast {
      position: fixed;
      bottom: 20px;
      right: 20px;
      padding: 12px 24px;
      background: #2d3436;
      color: #ffffff;
      border-radius: 8px;
      z-index: 100000;
      animation: grim-toast-in 0.3s ease;
    }
    @keyframes grim-toast-in {
      from { transform: translateY(100%); opacity: 0; }
      to { transform: translateY(0); opacity: 1; }
    }
    .grim-toast-out {
      animation: grim-toast-out 0.3s ease forwards;
    }
    @keyframes grim-toast-out {
      from { transform: translateY(0); opacity: 1; }
      to { transform: translateY(100%); opacity: 0; }
    }
  `

  let initialized = ref(false)

  let init = () => {
    if !initialized.contents {
      GM.addStyle(baseCSS)
      initialized := true
      Log.debug("UI initialized")
    }
  }

  // Create floating panel
  let createPanel = (
    ~title: string,
    ~position: (int, int)=(20, 20),
    ~draggable: bool=true
  ): Dom.element => {
    init()

    let (top, right) = position
    let panel = DOM.create(~tag="div", ~className="grim-panel")
    DOM.setStyle(panel, `top: ${Js.Int.toString(top)}px; right: ${Js.Int.toString(right)}px;`)

    DOM.setInnerHTML(panel, `
      <div class="grim-panel-header">
        <span>${title}</span>
        <span class="grim-panel-close">✕</span>
      </div>
      <div class="grim-panel-body"></div>
    `)

    // Close button handler
    switch DOM.query(".grim-panel-close") {
    | Some(btn) =>
      DOM.addEventListener(btn, "click", _ => {
        DOM.remove(panel)
      })
    | None => ()
    }

    DOM.appendChild(DOM.body, panel)
    panel
  }

  // Show toast notification
  let toast = (~message: string, ~duration: int=3000): unit => {
    init()

    let toastEl = DOM.create(~tag="div", ~className="grim-toast")
    DOM.setTextContent(toastEl, message)
    DOM.appendChild(DOM.body, toastEl)

    let _ = Js.Global.setTimeout(() => {
      DOM.classListAdd(toastEl, "grim-toast-out")
      let _ = Js.Global.setTimeout(() => {
        DOM.remove(toastEl)
      }, 300)
    }, duration)
  }

  // Create badge
  let createBadge = (~text: string, ~variant: string="info"): Dom.element => {
    let badge = DOM.create(~tag="span", ~className=`grim-badge grim-badge-${variant}`)
    DOM.setTextContent(badge, text)
    badge
  }
}

// === Script Registry ===

module Registry = {
  type scriptInfo = {
    name: string,
    version: string,
    description: string,
    matches: array<string>,
  }

  let scripts: Js.Dict.t<scriptInfo> = Js.Dict.empty()

  let register = (name: string, info: scriptInfo): unit => {
    Js.Dict.set(scripts, name, info)
    Log.debug(`Registered script: ${name}`)
  }

  let get = (name: string): option<scriptInfo> => {
    Js.Dict.get(scripts, name)
  }

  let list = (): array<string> => {
    Js.Dict.keys(scripts)
  }
}

// === URL Utilities ===

module URL = {
  @val external locationHref: string = "location.href"
  @val external locationHost: string = "location.host"
  @val external locationPathname: string = "location.pathname"
  @val external locationSearch: string = "location.search"
  @val external locationHash: string = "location.hash"

  let isGitLab = (): bool => {
    Js.String2.includes(locationHost, "gitlab")
  }

  let isGitHub = (): bool => {
    Js.String2.includes(locationHost, "github")
  }

  let isCodeberg = (): bool => {
    Js.String2.includes(locationHost, "codeberg")
  }

  let matchesPattern = (pattern: string): bool => {
    // Simple glob pattern matching
    let regex = pattern
      ->Js.String2.replaceByRe(%re("/\*/g"), ".*")
      ->Js.String2.replaceByRe(%re("/\?/g"), ".")
    Js.Re.test_(Js.Re.fromString(regex), locationHref)
  }
}

// === Initialization ===

let init = (~debug: bool=false): unit => {
  Config.setDebug(debug)
  Log.info("GrimCore initialized v" ++ Config.default.version)
}
