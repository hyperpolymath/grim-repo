// SPDX-License-Identifier: MPL-2.0 AND Palimpsest-0.8
/**
 * Test runner - executes all test suites
 */

Js.log("
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║              GrimRepo Scripts - Test Suite                      ║
║              ReScript + WASM Architecture                       ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
")

// Run all test suites
Bootstrap_test.runTests()
Community_test.runTests()
Audit_test.runTests()

Js.log("
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║              ✅ All Test Suites Complete                        ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
")
