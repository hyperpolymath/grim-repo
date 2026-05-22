// SPDX-License-Identifier: MPL-2.0
// Build script using ReGrease

// Import ReGrease build system
// NOTE: In actual use, this would be:
// open ReGrease
// For this example, we'll use a local copy

open ReGrease

let main = async () => {
  Js.Console.log("🔧 Building with ReGrease...")

  await buildScript(
    ~entry="src/Main.bs.js",
    ~output="dist/my-userscript.user.js",
    ~minify=false,
  )
}

main()
