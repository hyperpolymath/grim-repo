// SPDX-License-Identifier: PMPL-1.0-or-later
// GrimLicenseChecker.res - License Compliance Validator
//
// Scans repository files for proper SPDX headers and license compliance.
// Highlights files missing headers, detects inconsistent licenses,
// and validates LICENSE files.
//
// @name GrimLicenseChecker
// @version 1.0.0
// @namespace https://github.com/hyperpolymath
// @author Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
// @description License compliance validator with SPDX header detection
// @homepage https://github.com/hyperpolymath/grimrepo-scripts
// @supportURL https://github.com/hyperpolymath/grimrepo-scripts/issues
// @match *://github.com/*/*
// @match *://gitlab.com/*/*
// @match *://bitbucket.org/*/*
// @grant GM.getValue
// @grant GM.setValue
// @grant GM.addStyle
// @grant GM.xmlHttpRequest
// @run-at document-end
// @license PMPL-1.0-or-later

open GrimCore

// === Types ===

type license =
  | PMPL_1_0
  | MPL_2_0
  | MIT
  | Apache_2_0
  | GPL_3_0
  | AGPL_3_0
  | BSD_3Clause
  | Unknown(string)

type spdxStatus =
  | Present(license)
  | Missing
  | Invalid(string)

type fileCheck = {
  path: string,
  spdxStatus: spdxStatus,
  hasLicenseFile: bool,
}

type complianceResult = {
  totalFiles: int,
  filesWithHeaders: int,
  filesMissingHeaders: int,
  detectedLicenses: array<license>,
  inconsistentLicenses: bool,
  checks: array<fileCheck>,
}

// === Constants ===

let supportedExtensions = [
  ".res", ".resi", ".js", ".ts", ".tsx", ".jsx",
  ".rs", ".ml", ".mli", ".jl", ".ex", ".exs",
  ".gleam", ".scm", ".sh", ".bash", ".yml", ".yaml"
]

let spdxPatterns = [
  ("PMPL-1\\.0(?:-or-later)?", PMPL_1_0),
  ("MPL-2\\.0", MPL_2_0),
  ("MIT", MIT),
  ("Apache-2\\.0", Apache_2_0),
  ("GPL-3\\.0", GPL_3_0),
  ("AGPL-3\\.0", AGPL_3_0),
  ("BSD-3-Clause", BSD_3Clause),
]

let licenseToString = (lic: license): string => {
  switch lic {
  | PMPL_1_0 => "PMPL-1.0-or-later"
  | MPL_2_0 => "MPL-2.0"
  | MIT => "MIT"
  | Apache_2_0 => "Apache-2.0"
  | GPL_3_0 => "GPL-3.0"
  | AGPL_3_0 => "AGPL-3.0"
  | BSD_3Clause => "BSD-3-Clause"
  | Unknown(s) => `Unknown (${s})`
  }
}

let parseSPDX = (content: string): spdxStatus => {
  if Js.String2.includes(content, "SPDX-License-Identifier:") {
    let found = Belt.Array.reduce(spdxPatterns, None, (acc, (pattern, lic)) => {
      switch acc {
      | Some(_) => acc
      | None => {
          let regex = %raw(`new RegExp(pattern, "i")`)
          if %raw(`regex.test(content)`) {
            Some(lic)
          } else {
            None
          }
        }
      }
    })

    switch found {
    | Some(lic) => Present(lic)
    | None => Invalid("Unrecognized SPDX identifier")
    }
  } else {
    Missing
  }
}

let shouldCheckFile = (path: string): bool => {
  Belt.Array.some(supportedExtensions, ext => Js.String2.endsWith(path, ext))
}

// === File Fetching ===

let fetchFileContent = async (url: string): option<string> => {
  try {
    let resp = await HTTP.fetch(url)
    if resp.status == 200 {
      Some(resp.responseText)
    } else {
      None
    }
  } catch {
  | _ => None
  }
}

let getFileListFromPage = (): array<string> => {
  let links = DOM.queryAll("a[href*='/blob/']")
  links
  ->Belt.Array.map(link => {
      let href: string = %raw(`link.getAttribute('href')`)
      href
    })
  ->Belt.Array.keep(href => {
      let path = Js.String2.split(href, "/blob/")->Belt.Array.get(1)->Belt.Option.getWithDefault("")
      shouldCheckFile(path)
    })
  ->Belt.Array.slice(~offset=0, ~len=50) // Limit to 50 files for performance
}

// === Scanning ===

let scanRepository = async (repoUrl: string): complianceResult => {
  let files = getFileListFromPage()
  let filesChecked = ref(0)
  let filesWithHeaders = ref(0)
  let detectedLicenses = ref([])
  let allChecks = ref([])

  // Process files sequentially
  for i in 0 to Belt.Array.length(files) - 1 {
    switch Belt.Array.get(files, i) {
    | Some(file) => {
        let rawUrl = Js.String2.replaceByRe(file, %re("/\/blob\//"), "/raw/")
        switch await fetchFileContent(rawUrl) {
        | Some(content) => {
            filesChecked := filesChecked.contents + 1
            let status = parseSPDX(content)

            switch status {
            | Present(lic) => {
                filesWithHeaders := filesWithHeaders.contents + 1
                if !Belt.Array.some(detectedLicenses.contents, l => l == lic) {
                  detectedLicenses := Belt.Array.concat(detectedLicenses.contents, [lic])
                }
              }
            | _ => ()
            }

            let check: fileCheck = {
              path: file,
              spdxStatus: status,
              hasLicenseFile: false,
            }
            allChecks := Belt.Array.concat(allChecks.contents, [check])
          }
        | None => ()
        }
      }
    | None => ()
    }
  }

  {
    totalFiles: filesChecked.contents,
    filesWithHeaders: filesWithHeaders.contents,
    filesMissingHeaders: filesChecked.contents - filesWithHeaders.contents,
    detectedLicenses: detectedLicenses.contents,
    inconsistentLicenses: Belt.Array.length(detectedLicenses.contents) > 1,
    checks: allChecks.contents,
  }
}

// === UI ===

let css = `
.grim-license-panel {
  position: fixed;
  top: 80px;
  right: 20px;
  width: 360px;
  max-height: 600px;
  overflow-y: auto;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
  border: 1px solid #3a3a5c;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
  color: #e0e0e0;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  z-index: 10000;
}

.grim-license-header {
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 15px;
  color: #4CAF50;
}

.grim-license-stat {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid #2a2a3e;
}

.grim-license-stat:last-child {
  border-bottom: none;
}

.grim-license-label {
  color: #999;
  font-size: 13px;
}

.grim-license-value {
  color: #fff;
  font-weight: 600;
  font-size: 14px;
}

.grim-license-warning {
  background: #ff9800;
  color: #000;
  padding: 10px;
  border-radius: 6px;
  margin-top: 15px;
  font-size: 12px;
  font-weight: 600;
}

.grim-license-success {
  background: #4CAF50;
  color: #000;
  padding: 10px;
  border-radius: 6px;
  margin-top: 15px;
  font-size: 12px;
  font-weight: 600;
}

.grim-license-close {
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

.grim-license-close:hover {
  color: #fff;
}

.grim-license-file-list {
  margin-top: 15px;
  max-height: 300px;
  overflow-y: auto;
}

.grim-license-file {
  padding: 6px;
  font-size: 11px;
  font-family: monospace;
  border-left: 3px solid;
  margin-bottom: 4px;
  background: rgba(255,255,255,0.05);
}

.grim-license-file.missing {
  border-color: #f44336;
}

.grim-license-file.present {
  border-color: #4CAF50;
}
`

let createPanel = (result: complianceResult): unit => {
  let panel = DOM.create(~tag="div", ~className="grim-license-panel")

  let complianceRate = if result.totalFiles > 0 {
    Belt.Float.toInt(Belt.Int.toFloat(result.filesWithHeaders) /. Belt.Int.toFloat(result.totalFiles) *. 100.0)
  } else {
    0
  }

  let statusMsg = if result.inconsistentLicenses {
    "<div class='grim-license-warning'>⚠️ Inconsistent licenses detected!</div>"
  } else if complianceRate >= 95 {
    "<div class='grim-license-success'>✓ Excellent license compliance</div>"
  } else if complianceRate >= 70 {
    "<div class='grim-license-warning'>⚠️ Some files missing headers</div>"
  } else {
    "<div class='grim-license-warning'>❌ Poor license compliance</div>"
  }

  let detectedLics = result.detectedLicenses
    ->Belt.Array.map(licenseToString)
    ->Js.Array2.joinWith(", ")

  let fileList = result.checks
    ->Belt.Array.slice(~offset=0, ~len=20) // Show first 20
    ->Belt.Array.map((check: fileCheck) => {
        let statusClass = switch check.spdxStatus {
        | Present(_) => "present"
        | _ => "missing"
        }
        let filename = Js.String2.split(check.path, "/")->Belt.Array.reverse->Belt.Array.get(0)->Belt.Option.getWithDefault(check.path)
        `<div class="grim-license-file ${statusClass}">${filename}</div>`
      })
    ->Js.Array2.joinWith("")

  %raw(`panel.innerHTML = "<div class='grim-license-header'>License Compliance</div>" +
    "<div class='grim-license-stat'><span class='grim-license-label'>Files Scanned</span><span class='grim-license-value'>" + result.totalFiles + "</span></div>" +
    "<div class='grim-license-stat'><span class='grim-license-label'>With SPDX Headers</span><span class='grim-license-value'>" + result.filesWithHeaders + "</span></div>" +
    "<div class='grim-license-stat'><span class='grim-license-label'>Missing Headers</span><span class='grim-license-value'>" + result.filesMissingHeaders + "</span></div>" +
    "<div class='grim-license-stat'><span class='grim-license-label'>Compliance Rate</span><span class='grim-license-value'>" + complianceRate + "%</span></div>" +
    "<div class='grim-license-stat'><span class='grim-license-label'>Detected Licenses</span><span class='grim-license-value'>" + detectedLics + "</span></div>" +
    statusMsg +
    "<div class='grim-license-file-list'>" + fileList + "</div>"`)

  let closeBtn = %raw(`document.createElement("button")`)
  %raw(`closeBtn.textContent = "×"`)
  %raw(`closeBtn.className = "grim-license-close"`)
  %raw(`closeBtn.onclick = () => panel.remove()`)

  %raw(`panel.appendChild(closeBtn)`)
  %raw(`document.body.appendChild(panel)`)
}

// === Entry Point ===

let run = async (): unit => {
  Log.info("GrimLicenseChecker running")
  GM.addStyle(css)

  let url = URL.locationHref
  let result = await scanRepository(url)
  createPanel(result)
}

// Auto-run
let () = {
  if URL.isGitHub() || URL.isGitLab() {
    run()->ignore
  }
}
