// SPDX-License-Identifier: MPL-2.0
// Example UserScript built with ReGrease

// Build-time constants injected from deno.json
@val external version: string = "METADATA_VERSION"
@val external name: string = "METADATA_NAME"

// Greasemonkey API bindings
module GM = {
  @scope("GM") @val
  external getValue: (string, string) => promise<string> = "getValue"

  @scope("GM") @val
  external setValue: (string, string) => promise<unit> = "setValue"

  @scope("GM") @val
  external deleteValue: string => promise<unit> = "deleteValue"

  @scope("GM") @val
  external listValues: unit => promise<array<string>> = "listValues"
}

// Main application logic
let main = async () => {
  Js.Console.log(`🚀 ${name} v${version} starting...`)

  // Example: Persistent storage
  let savedValue = await GM.getValue("lastVisit", "never")
  Js.Console.log(`Last visit: ${savedValue}`)

  // Update with current timestamp
  let now = Js.Date.now()->Js.Float.toString
  await GM.setValue("lastVisit", now)

  // Your UserScript functionality here...
  Js.Console.log("✅ Initialization complete")
}

// Execute on page load
main()->ignore
