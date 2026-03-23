// SPDX-License-Identifier: PMPL-1.0-or-later
// Build.res: Example build script using GrimGreaser
// This demonstrates the self-hosting pattern

open GrimGreaser

// Example: Build with custom settings
let main = async () => {
  Js.Console.log("🚀 Custom Build Script")

  await buildScript(
    ~entry="src/scripts/example/MyScript.bs.js",
    ~output="dist/MyScript.user.js",
    ~minify=true,
  )
}

main()->ignore
