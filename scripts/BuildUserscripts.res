// SPDX-License-Identifier: PMPL-1.0-or-later
// Build script to generate .user.js files from compiled .mjs files

module Fs = {
  @module("node:fs") @val external readFileSync: (string, string) => string = "readFileSync"
  @module("node:fs") @val external writeFileSync: (string, string, string) => unit = "writeFileSync"
  @module("node:fs") @val external mkdirSync: (string, { "recursive": bool }) => unit = "mkdirSync"
  @module("node:fs") @val external existsSync: string => bool = "existsSync"
}

module Path = {
  @module("node:path") @val external join: (string, string) => string = "join"
}

let distDir = "./dist"

if !Fs.existsSync(distDir) {
  Fs.mkdirSync(distDir, { "recursive": true })
}

type metadata = {
  name: string,
  version: string,
  description: string,
  author: string,
  namespace: string,
  homepage: string,
  supportURL: string,
  match: array<string>,
  grant: array<string>,
  license: string,
  runAt: string,
}

type scriptDef = {
  name: string,
  entry: string,
  metadata: metadata,
}

let scripts = [
  {
    name: "GrimGreaser",
    entry: "./src/scripts/greaser/GrimGreaser.res.mjs",
    metadata: {
      name: "GrimGreaser",
      version: "1.0.0",
      description: "Pure ReScript build system with GreasyFork auto-publish",
      author: "Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>",
      namespace: "https://github.com/hyperpolymath",
      homepage: "https://github.com/hyperpolymath/grimrepo-scripts",
      supportURL: "https://github.com/hyperpolymath/grimrepo-scripts/issues",
      match: ["*://github.com/*/*", "*://gitlab.com/*/*"],
      grant: ["GM.getValue", "GM.setValue", "GM.addStyle", "GM.xmlHttpRequest"],
      license: "PMPL-1.0-or-later",
      runAt: "document-end",
    },
  },
  {
    name: "GrimPager",
    entry: "./src/scripts/pager/GrimPager.res.mjs",
    metadata: {
      name: "GrimPager",
      version: "1.0.0",
      description: "Perpetual auto-paging engine with smart detection",
      author: "Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>",
      namespace: "https://github.com/hyperpolymath",
      homepage: "https://github.com/hyperpolymath/grimrepo-scripts",
      supportURL: "https://github.com/hyperpolymath/grimrepo-scripts/issues",
      match: ["*://*/*"],
      grant: ["GM.getValue", "GM.setValue", "GM.addStyle"],
      license: "PMPL-1.0-or-later",
      runAt: "document-end",
    },
  },
  {
    name: "GrimTemplateEngine",
    entry: "./src/scripts/template/GrimTemplateEngine.res.mjs",
    metadata: {
      name: "GrimTemplateEngine",
      version: "1.0.0",
      description: "Intelligent repository health agent with context-aware templates",
      author: "Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>",
      namespace: "https://github.com/hyperpolymath",
      homepage: "https://github.com/hyperpolymath/grimrepo-scripts",
      supportURL: "https://github.com/hyperpolymath/grimrepo-scripts/issues",
      match: [
        "*://github.com/*/*",
        "*://gitlab.com/*/*",
        "*://bitbucket.org/*/*",
        "*://codeberg.org/*/*",
        "*://sr.ht/*/*",
      ],
      grant: ["GM.getValue", "GM.setValue", "GM.addStyle"],
      license: "PMPL-1.0-or-later",
      runAt: "document-end",
    },
  },
  {
    name: "GrimLicenseChecker",
    entry: "./src/scripts/license/GrimLicenseChecker.res.mjs",
    metadata: {
      name: "GrimLicenseChecker",
      version: "1.0.0",
      description: "License compliance validator with SPDX header detection",
      author: "Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>",
      namespace: "https://github.com/hyperpolymath",
      homepage: "https://github.com/hyperpolymath/grimrepo-scripts",
      supportURL: "https://github.com/hyperpolymath/grimrepo-scripts/issues",
      match: ["*://github.com/*/*", "*://gitlab.com/*/*", "*://bitbucket.org/*/*"],
      grant: ["GM.getValue", "GM.setValue", "GM.addStyle", "GM.xmlHttpRequest"],
      license: "PMPL-1.0-or-later",
      runAt: "document-end",
    },
  },
  {
    name: "GrimCIValidator",
    entry: "./src/scripts/ci/GrimCIValidator.res.mjs",
    metadata: {
      name: "GrimCIValidator",
      version: "1.0.0",
      description: "GitHub Actions workflow quality checker",
      author: "Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>",
      namespace: "https://github.com/hyperpolymath",
      homepage: "https://github.com/hyperpolymath/grimrepo-scripts",
      supportURL: "https://github.com/hyperpolymath/grimrepo-scripts/issues",
      match: ["*://github.com/*/.github/workflows/*"],
      grant: ["GM.getValue", "GM.setValue", "GM.addStyle"],
      license: "PMPL-1.0-or-later",
      runAt: "document-end",
    },
  },
  {
    name: "GrimSecurityScanner",
    entry: "./src/scripts/security/GrimSecurityScanner.res.mjs",
    metadata: {
      name: "GrimSecurityScanner",
      version: "1.0.0",
      description: "Security vulnerability detector for repositories",
      author: "Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>",
      namespace: "https://github.com/hyperpolymath",
      homepage: "https://github.com/hyperpolymath/grimrepo-scripts",
      supportURL: "https://github.com/hyperpolymath/grimrepo-scripts/issues",
      match: ["*://github.com/*/*", "*://gitlab.com/*/*"],
      grant: ["GM.getValue", "GM.setValue", "GM.addStyle", "GM.xmlHttpRequest", "GM.registerMenuCommand"],
      license: "PMPL-1.0-or-later",
      runAt: "document-end",
    },
  },
]

let generateMetadataBlock = (metadata: metadata) => {
  let lines = [
    "// ==UserScript==",
    `// @name         ${metadata.name}`,
    `// @namespace    ${metadata.namespace}`,
    `// @version      ${metadata.version}`,
    `// @description  ${metadata.description}`,
    `// @author       ${metadata.author}`,
    `// @homepage     ${metadata.homepage}`,
    `// @supportURL   ${metadata.supportURL}`,
  ]

  metadata.match->Js.Array2.forEach(pattern => {
    let _ = Js.Array2.push(lines, `// @match        ${pattern}`)
  })

  metadata.grant->Js.Array2.forEach(grant => {
    let _ = Js.Array2.push(lines, `// @grant        ${grant}`)
  })

  let _ = Js.Array2.push(lines, `// @license      ${metadata.license}`)
  let _ = Js.Array2.push(lines, `// @run-at       ${metadata.runAt}`)
  let _ = Js.Array2.push(lines, "// ==/UserScript==")
  let _ = Js.Array2.push(lines, "")

  Js.Array2.joinWith(lines, "\n")
}

Js.log("Building userscripts...\n")

scripts->Js.Array2.forEach(script => {
  try {
    let code = Fs.readFileSync(script.entry, "utf-8")
    let header = generateMetadataBlock(script.metadata)
    let output = header ++ "\n" ++ code

    let outputPath = Path.join(distDir, `${script.name}.user.js`)
    Fs.writeFileSync(outputPath, output, "utf-8")

    Js.log(`✓ Built ${script.name}.user.js`)
  } catch {
  | exn => Js.Console.error2(`✗ Failed to build ${script.name}:`, exn)
  }
})

Js.log(`\nAll userscripts built in ${distDir}/`)
Js.log("\nTo publish to GreasyFork:")
Js.log("1. Visit https://greasyfork.org/en/scripts/new")
Js.log("2. Upload each .user.js file")
Js.log("3. Fill in description and set language to 'English'")
Js.log("4. Click 'Post script'")
