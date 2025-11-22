// SPDX-License-Identifier: MIT AND Palimpsest-0.8
/**
 * Tests for Bootstrap module
 */

open GrimRepoTypes

// Test helper
let assertEqual = (actual, expected, testName) => {
  if actual == expected {
    Js.log(`✓ ${testName}`)
  } else {
    Js.log(`✗ ${testName}: expected ${Js.String.make(expected)}, got ${Js.String.make(actual)}`)
  }
}

let assertArrayLength = (arr, expected, testName) => {
  let actual = Belt.Array.length(arr)
  if actual == expected {
    Js.log(`✓ ${testName}`)
  } else {
    Js.log(`✗ ${testName}: expected length ${Belt.Int.toString(expected)}, got ${Belt.Int.toString(actual)}`)
  }
}

// Run tests
let runTests = () => {
  Js.log("\n🧪 Running Bootstrap Tests\n")

  // Test 1: Empty repository should have missing directories
  let result1 = Bootstrap.analyzeStructure([])
  Js.log(
    "Test 1: Empty repository should identify missing directories"
  )
  assertEqual(result1.score < 100, true, "  Score should be less than 100")
  assertEqual(Belt.Array.length(result1.missingDirs) > 0, true, "  Should have missing directories")
  assertEqual(Belt.Array.length(result1.presentDirs), 0, "  Should have no present directories")

  // Test 2: Repository with required dirs should score higher
  let result2 = Bootstrap.analyzeStructure(["src/", "tests/"])
  Js.log("\nTest 2: Repository with src/ and tests/")
  assertEqual(result2.score > 0, true, "  Score should be greater than 0")
  assertEqual(Belt.Array.length(result2.presentDirs), 2, "  Should have 2 present directories")

  // Test 3: Complete repository should score 100
  let result3 = Bootstrap.analyzeStructure([
    "src/",
    "tests/",
    "docs/",
    "examples/",
    ".gitlab/",
    ".github/",
    "scripts/",
    ".well-known/",
  ])
  Js.log("\nTest 3: Complete repository structure")
  assertEqual(result3.score, 100, "  Score should be 100")
  assertEqual(Belt.Array.length(result3.missingDirs), 0, "  Should have no missing directories")

  // Test 4: Template generation
  let dir: directoryCheck = {
    path: "src/",
    purpose: "Source code",
    priority: Required,
    template: Some("# Custom Template"),
  }
  let template = Bootstrap.generateDirectoryTemplate(dir)
  Js.log("\nTest 4: Template generation")
  assertEqual(template == "# Custom Template", true, "  Should use custom template")

  // Test 5: Recommendations
  let result5 = Bootstrap.analyzeStructure(["src/"])
  let recs = Bootstrap.getStructureRecommendations(result5)
  Js.log("\nTest 5: Recommendations generation")
  assertEqual(Belt.Array.length(recs) > 0, true, "  Should generate recommendations")

  Js.log("\n✅ Bootstrap tests complete\n")
}

// Auto-run tests
runTests()
