// SPDX-License-Identifier: PMPL-1.0-or-later
// Build script to generate .user.js files from compiled .mjs files

import { readFileSync, writeFileSync, mkdirSync, existsSync } from "node:fs";
import { join } from "node:path";

const distDir = "./dist";
if (!existsSync(distDir)) {
  mkdirSync(distDir, { recursive: true });
}

const scripts = [
  {
    name: "GrimGreaser",
    entry: "./src/scripts/greaser/GrimGreaser.mjs",
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
    entry: "./src/scripts/pager/GrimPager.mjs",
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
    entry: "./src/scripts/template/GrimTemplateEngine.mjs",
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
    entry: "./src/scripts/license/GrimLicenseChecker.mjs",
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
    entry: "./src/scripts/ci/GrimCIValidator.mjs",
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
    entry: "./src/scripts/security/GrimSecurityScanner.mjs",
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
];

function generateMetadataBlock(metadata: any): string {
  const lines = [
    "// ==UserScript==",
    `// @name         ${metadata.name}`,
    `// @namespace    ${metadata.namespace}`,
    `// @version      ${metadata.version}`,
    `// @description  ${metadata.description}`,
    `// @author       ${metadata.author}`,
    `// @homepage     ${metadata.homepage}`,
    `// @supportURL   ${metadata.supportURL}`,
  ];

  // Add all match patterns
  metadata.match.forEach((pattern: string) => {
    lines.push(`// @match        ${pattern}`);
  });

  // Add all grants
  metadata.grant.forEach((grant: string) => {
    lines.push(`// @grant        ${grant}`);
  });

  lines.push(`// @license      ${metadata.license}`);
  lines.push(`// @run-at       ${metadata.runAt}`);
  lines.push("// ==/UserScript==");
  lines.push("");

  return lines.join("\n");
}

console.log("Building userscripts...\n");

for (const script of scripts) {
  try {
    const code = readFileSync(script.entry, "utf-8");
    const header = generateMetadataBlock(script.metadata);
    const output = header + "\n" + code;

    const outputPath = join(distDir, `${script.name}.user.js`);
    writeFileSync(outputPath, output, "utf-8");

    console.log(`✓ Built ${script.name}.user.js`);
  } catch (error) {
    console.error(`✗ Failed to build ${script.name}:`, error);
  }
}

console.log(`\nAll userscripts built in ${distDir}/`);
console.log("\nTo publish to GreasyFork:");
console.log("1. Visit https://greasyfork.org/en/scripts/new");
console.log("2. Upload each .user.js file");
console.log("3. Fill in description and set language to 'English'");
console.log("4. Click 'Post script'");
