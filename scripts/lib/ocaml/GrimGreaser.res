// SPDX-License-Identifier: PMPL-1.0-or-later
// ReGrease: Pure ReScript Build System for UserScripts
// Meta-circular: ReScript building ReScript

// --- 1. Bindings (Teaching ReScript about Deno & Esbuild) ---

// Deno APIs
@scope("Deno") @val external exit: int => unit = "exit"
@scope("Deno") @val external readTextFile: string => promise<string> = "readTextFile"
@scope("Deno") @val external writeTextFile: (string, string) => promise<unit> = "writeTextFile"
@scope("Deno") @val external cwd: unit => string = "cwd"

// Esbuild types and bindings
type esbuildOptions = {
  entryPoints: array<string>,
  bundle: bool,
  outfile: string,
  banner: option<Js.Dict.t<string>>,
  define: option<Js.Dict.t<string>>,
  format: string,
  minify: option<bool>,
  target: option<string>,
}

@module("esbuild") external build: esbuildOptions => promise<unit> = "build"
@module("esbuild") external stop: unit => unit = "stop"

// --- 2. Config Parser (Reading deno.json metaiconic config) ---

type userScriptMeta = {
  namespace: string,
  description: string,
  match: array<string>,
  grant: array<string>,
  runAt: string,
}

type denoConfig = {
  name: string,
  version: string,
  license: string,
  userScript: userScriptMeta,
}

let parseConfig = (jsonStr: string): option<denoConfig> => {
  try {
    let json = Js.Json.parseExn(jsonStr)
    let obj = json->Js.Json.decodeObject->Belt.Option.getExn

    let name = obj
      ->Js.Dict.get("name")
      ->Belt.Option.flatMap(Js.Json.decodeString)
      ->Belt.Option.getExn

    let version = obj
      ->Js.Dict.get("version")
      ->Belt.Option.flatMap(Js.Json.decodeString)
      ->Belt.Option.getExn

    let license = obj
      ->Js.Dict.get("license")
      ->Belt.Option.flatMap(Js.Json.decodeString)
      ->Belt.Option.getExn

    let userScriptObj = obj
      ->Js.Dict.get("userScript")
      ->Belt.Option.flatMap(Js.Json.decodeObject)
      ->Belt.Option.getExn

    let namespace = userScriptObj
      ->Js.Dict.get("namespace")
      ->Belt.Option.flatMap(Js.Json.decodeString)
      ->Belt.Option.getExn

    let description = userScriptObj
      ->Js.Dict.get("description")
      ->Belt.Option.flatMap(Js.Json.decodeString)
      ->Belt.Option.getExn

    let match = userScriptObj
      ->Js.Dict.get("match")
      ->Belt.Option.flatMap(Js.Json.decodeArray)
      ->Belt.Option.map(arr => arr->Belt.Array.keepMap(Js.Json.decodeString))
      ->Belt.Option.getExn

    let grant = userScriptObj
      ->Js.Dict.get("grant")
      ->Belt.Option.flatMap(Js.Json.decodeArray)
      ->Belt.Option.map(arr => arr->Belt.Array.keepMap(Js.Json.decodeString))
      ->Belt.Option.getExn

    let runAt = userScriptObj
      ->Js.Dict.get("runAt")
      ->Belt.Option.flatMap(Js.Json.decodeString)
      ->Belt.Option.getExn

    Some({
      name,
      version,
      license,
      userScript: {
        namespace,
        description,
        match,
        grant,
        runAt,
      },
    })
  } catch {
  | _ => None
  }
}

// --- 3. Header Generation (Single Source of Truth) ---

let generateHeader = (config: denoConfig): string => {
  let matchLines = config.userScript.match
    ->Belt.Array.map(url => `// @match       ${url}`)
    ->Js.Array2.joinWith("\n")

  let grantLines = config.userScript.grant
    ->Belt.Array.map(perm => `// @grant       ${perm}`)
    ->Js.Array2.joinWith("\n")

  `// ==UserScript==
// @name        ${config.name}
// @namespace   ${config.userScript.namespace}
// @version     ${config.version}
// @description ${config.userScript.description}
// @license     ${config.license}
${matchLines}
${grantLines}
// @run-at      ${config.userScript.runAt}
// @noframes
// ==/UserScript==

`
}

// --- 4. Build Orchestration ---

let buildScript = async (~entry: string, ~output: string, ~minify: bool=false) => {
  Js.Console.log("🔸 [ReGrease] Starting Pure ReScript Build...")

  // Read metaiconic config
  let configPath = `${cwd()}/deno.json`
  let configStr = await readTextFile(configPath)

  let config = switch parseConfig(configStr) {
  | Some(c) => c
  | None => {
      Js.Console.error("❌ Failed to parse deno.json")
      exit(1)
      Js.Exn.raiseError("Config parse failed") // Unreachable but satisfies type checker
    }
  }

  Js.Console.log(`🔹 Building: ${config.name} v${config.version}`)

  // Generate header from SSOT
  let header = generateHeader(config)

  // Prepare esbuild options
  let bannerDict = Js.Dict.empty()
  Js.Dict.set(bannerDict, "js", header)

  let defineDict = Js.Dict.empty()
  Js.Dict.set(defineDict, "METADATA_VERSION", `"${config.version}"`)
  Js.Dict.set(defineDict, "METADATA_NAME", `"${config.name}"`)

  try {
    await build({
      entryPoints: [entry],
      bundle: true,
      outfile: output,
      banner: Some(bannerDict),
      define: Some(defineDict),
      format: "iife",
      minify: Some(minify),
      target: Some("es2020"),
    })

    Js.Console.log(`✅ Build Complete: ${output}`)
  } catch {
  | exn => {
      Js.Console.error("❌ Build Failed:")
      Js.Console.error(exn)
      exit(1)
    }
  }

  stop()
}

// --- 5. Public API ---

let run = async () => {
  await buildScript(
    ~entry="src/Main.bs.js",
    ~output="dist/userscript.user.js",
    ~minify=false,
  )
}

// Auto-execute when run as main module
run()->ignore
