// SPDX-License-Identifier: PMPL-1.0-or-later
// Publish userscripts to GreasyFork

module Deno = {
  @val @scope("Deno") external readTextFile: string => promise<string> = "readTextFile"
  type env = {get: string => option<string>}
  @val @scope("Deno") external env: env = "env"
  @val @scope("Deno") external exit: int => 'a = "exit"
}

type formData
@new external makeFormData: unit => formData = "FormData"
@send external append: (formData, string, string) => unit = "append"

type response
@val external fetch: (string, 'options) => promise<response> = "fetch"
@get external ok: response => bool = "ok"

type fetchResult = {id: int}
@send external json: response => promise<fetchResult> = "json"
@send external text: response => promise<string> = "text"

@val external setTimeout: (unit => unit, int) => int = "setTimeout"
@new external makePromise: ((('a => unit), ('e => unit)) => unit) => promise<'a> = "Promise"

let apiBase = "https://greasyfork.org/api/v1"

let scripts = [
  "GrimGreaser",
  "GrimPager",
  "GrimTemplateEngine",
  "GrimLicenseChecker",
  "GrimCIValidator",
  "GrimSecurityScanner",
]

let publishScript = async (name: string, apiKey: string) => {
  let code = await Deno.readTextFile(`./dist/${name}.user.js`)

  let formData = makeFormData()
  formData->append("code", code)
  formData->append("locale", "en")

  let response = await fetch(
    `${apiBase}/scripts`,
    {
      "method": "POST",
      "headers": {
        "Authorization": `Bearer ${apiKey}`,
      },
      "body": formData,
    },
  )

  if response->ok {
    let result = await response->json
    Js.log(`✓ Published ${name} - ID: ${Js.Int.toString(result.id)}`)
    Js.log(`  URL: https://greasyfork.org/en/scripts/${Js.Int.toString(result.id)}`)
    Some(result.id)
  } else {
    let error = await response->text
    Js.Console.error2(`✗ Failed to publish ${name}:`, error)
    None
  }
}

let updateScript = async (scriptId: int, name: string, apiKey: string) => {
  let code = await Deno.readTextFile(`./dist/${name}.user.js`)

  let formData = makeFormData()
  formData->append("code", code)
  formData->append("changelog", "Initial release")

  let response = await fetch(
    `${apiBase}/scripts/${Js.Int.toString(scriptId)}/versions`,
    {
      "method": "POST",
      "headers": {
        "Authorization": `Bearer ${apiKey}`,
      },
      "body": formData,
    },
  )

  if response->ok {
    Js.log(`✓ Updated ${name}`)
    true
  } else {
    let error = await response->text
    Js.Console.error2(`✗ Failed to update ${name}:`, error)
    false
  }
}

let main = async () => {
  let apiKeyOpt = Deno.env.get("GREASYFORK_API_KEY")

  switch apiKeyOpt {
  | None =>
    Js.log("⚠️  GREASYFORK_API_KEY not set")
    Js.log("\nTo get your API key:")
    Js.log("1. Log in to https://greasyfork.org")
    Js.log("2. Go to https://greasyfork.org/en/users/edit")
    Js.log("3. Scroll to 'API' section")
    Js.log("4. Copy your API key")
    Js.log("\nThen run:")
    Js.log("  export GREASYFORK_API_KEY=your_key_here")
    Js.log("  deno run --allow-read --allow-net --allow-env publish-greasyfork.res.mjs")
    Js.log("\n=== OR MANUAL UPLOAD ===")
    Js.log("\nFor each file in dist/:")
    scripts->Js.Array2.forEach(script => {
      Js.log(`\n${script}.user.js:`)
      Js.log(`  1. Visit https://greasyfork.org/en/scripts/new`)
      Js.log(`  2. Click 'Choose File' and select dist/${script}.user.js`)
      Js.log(`  3. Set language to 'English'`)
      Js.log(`  4. Click 'Post script'`)
    })
    Deno.exit(1)
  | Some(apiKey) =>
    Js.log("Publishing to GreasyFork...\n")

    for i in 0 to Belt.Array.length(scripts) - 1 {
      let name = Belt.Array.getExn(scripts, i)
      let _ = await publishScript(name, apiKey)
      let _ = await makePromise((resolve, _reject) => {
        let _ = setTimeout(() => resolve(), 2000)
      })
    }

    Js.log("\n✓ All scripts published!")
    Js.log("\nNext steps:")
    Js.log("1. Check https://greasyfork.org/en/users/scripts")
    Js.log("2. Add screenshots to each script")
    Js.log("3. Add detailed descriptions")
    Js.log("4. Set appropriate tags")
  }
}

let _ = main()
