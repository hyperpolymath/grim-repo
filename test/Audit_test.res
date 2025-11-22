// SPDX-License-Identifier: MIT AND Palimpsest-0.8
/**
 * Tests for Audit module
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
  Js.log("\n🧪 Running Audit Tests\n")

  // Test 1: Raw project level
  let result1 = Audit.auditRepository([], [])
  Js.log("Test 1: Empty repository should be Raw level")
  assertEqual(result1.level, Raw, "  Level should be Raw")
  assertEqual(result1.overallScore < 60, true, "  Score should be less than 60")

  // Test 2: Bronze level
  let result2 = Audit.auditRepository(
    ["src/", "tests/", "docs/", ".well-known/"],
    [
      "README.md",
      "LICENSE.txt",
      "SECURITY.md",
      "CONTRIBUTING.md",
      "CODE_OF_CONDUCT.md",
      "CHANGELOG.md",
    ],
  )
  Js.log("\nTest 2: Bronze level repository")
  assertEqual(
    result2.level == Bronze || result2.level == Silver || result2.level == Gold || result2.level == Rhodium,
    true,
    "  Should achieve at least Bronze level",
  )
  assertEqual(result2.overallScore >= 60, true, "  Score should be 60 or higher")

  // Test 3: Rhodium level (perfect repo)
  let result3 = Audit.auditRepository(
    ["src/", "tests/", "docs/", "examples/", ".gitlab/", ".github/", "scripts/", ".well-known/"],
    [
      "LICENSE.txt",
      "README.md",
      "CONTRIBUTING.md",
      "CODE_OF_CONDUCT.md",
      "SECURITY.md",
      "CHANGELOG.md",
      "MAINTAINERS.md",
      ".well-known/security.txt",
    ],
  )
  Js.log("\nTest 3: Rhodium level repository")
  assertEqual(result3.level == Gold || result3.level == Rhodium, true, "  Should achieve Gold or Rhodium level")
  assertEqual(result3.overallScore >= 85, true, "  Score should be 85 or higher")

  // Test 4: Recommendations generated
  Js.log("\nTest 4: Recommendations generation")
  assertEqual(Belt.Array.length(result1.recommendations) > 0, true, "  Should generate recommendations")

  // Test 5: Audit report generation
  let report = Audit.generateAuditReport(result2)
  Js.log("\nTest 5: Audit report generation")
  assertEqual(Js.String2.includes(report, "GrimRepo Audit Report"), true, "  Report should include title")
  assertEqual(Js.String2.includes(report, "Overall Score"), true, "  Report should include overall score")
  assertEqual(Js.String2.includes(report, "Quality Level"), true, "  Report should include quality level")

  // Test 6: Weighted scoring
  let result6a = Audit.auditRepository(["src/", "tests/"], [])
  let result6b = Audit.auditRepository([], ["README.md", "LICENSE.txt", "CONTRIBUTING.md"])
  Js.log("\nTest 6: Community files weighted more (60/40 split)")
  assertEqual(result6b.overallScore > result6a.overallScore, true, "  Community files should contribute more to score")

  Js.log("\n✅ Audit tests complete\n")
}

// Auto-run tests
runTests()
