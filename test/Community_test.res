// SPDX-License-Identifier: MIT AND Palimpsest-0.8
/**
 * Tests for Community module
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

// Run tests
let runTests = () => {
  Js.log("\n🧪 Running Community Tests\n")

  // Test 1: Empty repository
  let result1 = Community.analyzeCommunityStandards([])
  Js.log("Test 1: Empty repository")
  assertEqual(result1.score < 100, true, "  Score should be less than 100")
  assertEqual(Belt.Array.length(result1.missingFiles) > 0, true, "  Should have missing files")

  // Test 2: LICENSE and LICENSE.txt equivalence
  let result2a = Community.analyzeCommunityStandards(["LICENSE", "README.md"])
  let result2b = Community.analyzeCommunityStandards(["LICENSE.txt", "README.md"])
  Js.log("\nTest 2: LICENSE equivalence")
  assertEqual(result2a.score == result2b.score, true, "  LICENSE and LICENSE.txt should score equally")

  // Test 3: Complete community standards
  let result3 = Community.analyzeCommunityStandards([
    "LICENSE.txt",
    "README.md",
    "CONTRIBUTING.md",
    "CODE_OF_CONDUCT.md",
    "SECURITY.md",
    "CHANGELOG.md",
    "MAINTAINERS.md",
    ".well-known/security.txt",
  ])
  Js.log("\nTest 3: Complete community standards")
  assertEqual(result3.score >= 90, true, "  Score should be 90 or higher")

  // Test 4: RSR compliance check
  let result4 = Community.analyzeCommunityStandards([
    "README.md",
    "LICENSE.txt",
    "SECURITY.md",
    "CONTRIBUTING.md",
    "CODE_OF_CONDUCT.md",
  ])
  let isCompliant = Community.checkRSRCompliance(result4)
  Js.log("\nTest 4: RSR compliance check")
  assertEqual(isCompliant, true, "  Should be RSR compliant with required files")

  // Test 5: Non-compliant repository
  let result5 = Community.analyzeCommunityStandards(["README.md"])
  let notCompliant = Community.checkRSRCompliance(result5)
  Js.log("\nTest 5: Non-compliant repository")
  assertEqual(notCompliant, false, "  Should not be RSR compliant with only README")

  // Test 6: Case insensitivity
  let result6 = Community.analyzeCommunityStandards(["readme.md", "license", "security.md"])
  Js.log("\nTest 6: Case insensitivity")
  assertEqual(Belt.Array.length(result6.presentFiles) >= 3, true, "  Should recognize lowercase filenames")

  Js.log("\n✅ Community tests complete\n")
}

// Auto-run tests
runTests()
