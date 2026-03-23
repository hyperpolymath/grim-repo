// AibdpChecker.res - AIBDP Manifest Detection and Display
// SPDX-License-Identifier: PMPL-1.0-or-later OR LicenseRef-Palimpsest-0.5
//
// Detects and displays AIBDP (AI Boundary Declaration Protocol) status
// for any website. Shows consent status in a non-intrusive badge.
//
// @match *://*/*

open GrimCore

// === Types ===

type policyStatus =
  | Allowed
  | Refused
  | Conditional
  | Unknown

type policy = {
  status: policyStatus,
  conditions: array<string>,
}

type aibdpManifest = {
  version: string,
  contact: option<string>,
  expires: option<string>,
  training: policy,
  indexing: policy,
  summarization: policy,
  generativeReuse: policy,
  embedding: policy,
}

type detectionResult =
  | Found(aibdpManifest)
  | NotFound
  | Error(string)

// === Constants ===

let scriptInfo: Registry.scriptInfo = {
  name: "grim-aibdp-checker",
  version: "1.0.0",
  description: "Check and display AIBDP status for websites",
  matches: ["*://*/*"],
}

let aibdpPath = "/.well-known/aibdp.json"

// === Parsing ===

let parseStatus = (str: string): policyStatus => {
  switch Js.String2.toLowerCase(str) {
  | "allowed" => Allowed
  | "refused" => Refused
  | "conditional" => Conditional
  | _ => Unknown
  }
}

let parsePolicy = (json: Js.Json.t): policy => {
  let obj = json->Js.Json.decodeObject->Belt.Option.getWithDefault(Js.Dict.empty())

  let status = obj
    ->Js.Dict.get("status")
    ->Belt.Option.flatMap(Js.Json.decodeString)
    ->Belt.Option.map(parseStatus)
    ->Belt.Option.getWithDefault(Unknown)

  let conditions = obj
    ->Js.Dict.get("conditions")
    ->Belt.Option.flatMap(Js.Json.decodeArray)
    ->Belt.Option.map(arr =>
      arr->Belt.Array.keepMap(Js.Json.decodeString)
    )
    ->Belt.Option.getWithDefault([])

  {status, conditions}
}

let parseManifest = (json: Js.Json.t): option<aibdpManifest> => {
  switch Js.Json.decodeObject(json) {
  | Some(obj) => {
      let version = obj
        ->Js.Dict.get("aibdp_version")
        ->Belt.Option.flatMap(Js.Json.decodeString)
        ->Belt.Option.getWithDefault("unknown")

      let contact = obj
        ->Js.Dict.get("contact")
        ->Belt.Option.flatMap(Js.Json.decodeString)

      let expires = obj
        ->Js.Dict.get("expires")
        ->Belt.Option.flatMap(Js.Json.decodeString)

      let policies = obj
        ->Js.Dict.get("policies")
        ->Belt.Option.flatMap(Js.Json.decodeObject)
        ->Belt.Option.getWithDefault(Js.Dict.empty())

      let getPolicy = (name: string) =>
        policies
        ->Js.Dict.get(name)
        ->Belt.Option.map(parsePolicy)
        ->Belt.Option.getWithDefault({status: Unknown, conditions: []})

      Some({
        version,
        contact,
        expires,
        training: getPolicy("training"),
        indexing: getPolicy("indexing"),
        summarization: getPolicy("summarization"),
        generativeReuse: getPolicy("generative_reuse"),
        embedding: getPolicy("embedding"),
      })
    }
  | None => None
  }
}

// === Detection ===

let fetchAibdp = (): Js.Promise.t<detectionResult> => {
  let url = URL.locationHref->Js.String2.split("/")->Belt.Array.slice(~offset=0, ~len=3)->Js.Array2.joinWith("/") ++ aibdpPath

  Log.debug(`Fetching AIBDP from: ${url}`)

  HTTP.fetch(url)
  ->Js.Promise.then_((resp: HTTP.response) => {
    let httpStatus: int = resp.status
    if httpStatus == 200 {
      try {
        let json = Js.Json.parseExn(resp.responseText)
        switch parseManifest(json) {
        | Some(manifest) => Js.Promise.resolve(Found(manifest))
        | None => Js.Promise.resolve(Error("Invalid AIBDP format"))
        }
      } catch {
      | _ => Js.Promise.resolve(Error("Failed to parse AIBDP JSON"))
      }
    } else if httpStatus === 404 {
      Js.Promise.resolve(NotFound)
    } else {
      Js.Promise.resolve(Error(`HTTP ${Js.Int.toString(resp.status)}`))
    }
  }, _)
  ->Js.Promise.catch(_ => {
    Js.Promise.resolve(Error("Network error"))
  }, _)
}

// === UI ===

let statusToEmoji = (status: policyStatus): string => {
  switch status {
  | Allowed => "✓"
  | Refused => "🔒"
  | Conditional => "⚠️"
  | Unknown => "❓"
  }
}

let statusToVariant = (status: policyStatus): string => {
  switch status {
  | Allowed => "success"
  | Refused => "error"
  | Conditional => "warning"
  | Unknown => "info"
  }
}

let statusToText = (status: policyStatus): string => {
  switch status {
  | Allowed => "Allowed"
  | Refused => "Refused"
  | Conditional => "Conditional"
  | Unknown => "Unknown"
  }
}

let badgeCSS = `
  .grim-aibdp-badge {
    position: fixed;
    bottom: 20px;
    left: 20px;
    z-index: 99998;
    cursor: pointer;
    transition: transform 0.2s;
  }
  .grim-aibdp-badge:hover {
    transform: scale(1.1);
  }
  .grim-aibdp-detail {
    position: fixed;
    bottom: 60px;
    left: 20px;
    z-index: 99999;
    background: white;
    border: 1px solid #dfe6e9;
    border-radius: 8px;
    padding: 16px;
    min-width: 280px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
    font-size: 13px;
    display: none;
  }
  .grim-aibdp-detail.visible {
    display: block;
  }
  .grim-aibdp-detail h4 {
    margin: 0 0 12px 0;
    font-size: 14px;
    color: #2d3436;
  }
  .grim-aibdp-policy-row {
    display: flex;
    justify-content: space-between;
    padding: 6px 0;
    border-bottom: 1px solid #f1f3f4;
  }
  .grim-aibdp-policy-row:last-child {
    border-bottom: none;
  }
  .grim-aibdp-policy-name {
    font-weight: 500;
    color: #636e72;
  }
  .grim-aibdp-policy-status {
    font-weight: 600;
  }
  .grim-aibdp-status-allowed { color: #27ae60; }
  .grim-aibdp-status-refused { color: #e74c3c; }
  .grim-aibdp-status-conditional { color: #f39c12; }
  .grim-aibdp-status-unknown { color: #95a5a6; }
  .grim-aibdp-meta {
    margin-top: 12px;
    padding-top: 12px;
    border-top: 1px solid #dfe6e9;
    font-size: 11px;
    color: #95a5a6;
  }
`

let renderPolicyRow = (name: string, policy: policy): string => {
  let statusClass = switch policy.status {
  | Allowed => "allowed"
  | Refused => "refused"
  | Conditional => "conditional"
  | Unknown => "unknown"
  }

  `<div class="grim-aibdp-policy-row">
    <span class="grim-aibdp-policy-name">${name}</span>
    <span class="grim-aibdp-policy-status grim-aibdp-status-${statusClass}">
      ${statusToEmoji(policy.status)} ${statusToText(policy.status)}
    </span>
  </div>`
}

let createBadge = (result: detectionResult): unit => {
  GM.addStyle(badgeCSS)

  let (badgeText, badgeVariant) = switch result {
  | Found(manifest) => (
      `${statusToEmoji(manifest.training.status)} AIBDP`,
      statusToVariant(manifest.training.status)
    )
  | NotFound => ("❓ No AIBDP", "info")
  | Error(_) => ("⚠️ AIBDP Error", "warning")
  }

  // Create badge
  let badgeContainer = DOM.create(~tag="div", ~className="grim-aibdp-badge")
  let badge = UI.createBadge(~text=badgeText, ~variant=badgeVariant)
  DOM.appendChild(badgeContainer, badge)

  // Create detail panel
  let detailPanel = DOM.create(~tag="div", ~className="grim-aibdp-detail")

  let detailContent = switch result {
  | Found(manifest) => {
      let policies = [
        ("AI Training", manifest.training),
        ("Indexing", manifest.indexing),
        ("Summarization", manifest.summarization),
        ("Generative Reuse", manifest.generativeReuse),
        ("Embedding", manifest.embedding),
      ]

      let policyRows = policies
        ->Belt.Array.map(((name, policy)) => renderPolicyRow(name, policy))
        ->Js.Array2.joinWith("")

      let metaInfo = switch manifest.contact {
      | Some(contact) => `<div class="grim-aibdp-meta">Contact: ${contact}</div>`
      | None => ""
      }

      `<h4>🔐 AIBDP v${manifest.version}</h4>
       ${policyRows}
       ${metaInfo}`
    }
  | NotFound =>
      `<h4>❓ No AIBDP Found</h4>
       <p>This site has not published an AI Boundary Declaration Protocol manifest.</p>
       <p style="font-size: 11px; color: #95a5a6;">
         Learn more at <a href="https://aibdp.org" target="_blank">aibdp.org</a>
       </p>`
  | Error(msg) =>
      `<h4>⚠️ AIBDP Error</h4>
       <p>Could not fetch AIBDP manifest: ${msg}</p>`
  }

  DOM.setInnerHTML(detailPanel, detailContent)

  // Toggle detail on click
  DOM.addEventListener(badgeContainer, "click", _ => {
    DOM.classListToggle(detailPanel, "visible")->ignore
  })

  // Close detail when clicking outside
  DOM.addEventListener(DOM.body, "click", event => {
    let target: Dom.element = %raw(`event.target`)
    if !(%raw(`badgeContainer.contains(target)`) : bool) &&
       !(%raw(`detailPanel.contains(target)`) : bool) {
      DOM.classListRemove(detailPanel, "visible")
    }
  })

  DOM.appendChild(DOM.body, badgeContainer)
  DOM.appendChild(DOM.body, detailPanel)
}

// === Cache ===

let cacheKey = "aibdp_cache"

type cachedResult = {
  host: string,
  result: string, // JSON stringified
  timestamp: float,
}

let getCached = (): Js.Promise.t<option<detectionResult>> => {
  Storage.getJson(~storage=Local, cacheKey)
  ->Js.Promise.then_(cached => {
    switch cached {
    | Some(json) => {
        let obj = json->Js.Json.decodeObject->Belt.Option.getWithDefault(Js.Dict.empty())
        let host = obj->Js.Dict.get("host")->Belt.Option.flatMap(Js.Json.decodeString)
        let timestamp = obj->Js.Dict.get("timestamp")->Belt.Option.flatMap(Js.Json.decodeNumber)

        // Check if cache is for this host and not expired (1 hour)
        switch (host, timestamp) {
        | (Some(h), Some(t)) if h === URL.locationHost && Js.Date.now() -. t < 3600000.0 => {
            let resultStr = obj->Js.Dict.get("result")->Belt.Option.flatMap(Js.Json.decodeString)
            switch resultStr {
            | Some("not_found") => Js.Promise.resolve(Some(NotFound))
            | Some(r) => {
                try {
                  let parsed = Js.Json.parseExn(r)
                  switch parseManifest(parsed) {
                  | Some(m) => Js.Promise.resolve(Some(Found(m)))
                  | None => Js.Promise.resolve(None)
                  }
                } catch {
                | _ => Js.Promise.resolve(None)
                }
              }
            | None => Js.Promise.resolve(None)
            }
          }
        | _ => Js.Promise.resolve(None)
        }
      }
    | None => Js.Promise.resolve(None)
    }
  }, _)
}

let setCache = (result: detectionResult): Js.Promise.t<unit> => {
  let resultStr = switch result {
  | Found(_) => "found" // TODO: stringify manifest
  | NotFound => "not_found"
  | Error(_) => "error"
  }

  let cache = Js.Dict.empty()
  Js.Dict.set(cache, "host", Js.Json.string(URL.locationHost))
  Js.Dict.set(cache, "result", Js.Json.string(resultStr))
  Js.Dict.set(cache, "timestamp", Js.Json.number(Js.Date.now()))

  Storage.setJson(~storage=Local, cacheKey, Js.Json.object_(cache))
}

// === Entry Point ===

let run = (): unit => {
  Log.info("AIBDP Checker running")

  // Check cache first
  getCached()
  ->Js.Promise.then_(cached => {
    switch cached {
    | Some(result) => {
        Log.debug("Using cached AIBDP result")
        createBadge(result)
        Js.Promise.resolve()
      }
    | None => {
        fetchAibdp()
        ->Js.Promise.then_(result => {
          createBadge(result)
          setCache(result)->ignore
          Js.Promise.resolve()
        }, _)
      }
    }
  }, _)
  ->ignore
}

// Register and auto-run
let () = {
  Registry.register(scriptInfo.name, scriptInfo)

  // Wait for page load
  DOM.addEventListener(DOM.body, "load", _ => {
    run()
  })

  // Also run immediately if document already loaded
  if %raw(`document.readyState === "complete"`) {
    run()
  }
}
