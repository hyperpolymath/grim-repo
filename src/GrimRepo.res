// SPDX-License-Identifier: MIT AND Palimpsest-0.8
/**
 * Main entry point for GrimRepo
 * Exports public API for JavaScript interop
 */

open GrimRepoTypes

// Re-export types and modules
type t_priority = priority
type t_directoryCheck = directoryCheck
type t_repoStructure = repoStructure
type t_fileCheck = fileCheck
type t_communityStandards = communityStandards
type t_qualityLevel = qualityLevel
type t_auditResult = auditResult
type t_platform = platform
type t_platformContext = platformContext
type t_grimRepoConfig = grimRepoConfig

// Public API - exported for JavaScript

@genType
let analyzeStructure = Bootstrap.analyzeStructure

@genType
let analyzeCommunityStandards = Community.analyzeCommunityStandards

@genType
let auditRepository = Audit.auditRepository

@genType
let generateAuditReport = Audit.generateAuditReport

@genType
let checkRSRCompliance = Community.checkRSRCompliance

// Self-check functionality
@genType
let selfCheck = (): string => {
  let requiredFiles = [
    "README.md",
    "LICENSE.txt",
    "SECURITY.md",
    "CONTRIBUTING.md",
    "CODE_OF_CONDUCT.md",
    "MAINTAINERS.md",
    "CHANGELOG.md",
    ".well-known/security.txt",
    ".well-known/ai.txt",
    ".well-known/humans.txt",
  ]

  let requiredDirs = ["src/", "tests/", "docs/", ".well-known/"]

  let result = Audit.auditRepository(requiredDirs, requiredFiles)

  let output = []
  let output = output->Belt.Array.concat(["🔍 GrimRepo Self-Check (RSR Bronze Compliance)\n"])
  let output = output->Belt.Array.concat([
    `Overall Score: ${Belt.Int.toString(result.overallScore)}/100`,
  ])
  let output = output->Belt.Array.concat([
    `Quality Level: ${levelToString(result.level)->Js.String2.toUpperCase}\n`,
  ])

  let output = switch result.level {
  | Bronze | Silver | Gold | Rhodium =>
    output->Belt.Array.concat(["✅ This repository is RSR-compliant!"])
  | Raw => output->Belt.Array.concat(["❌ This repository is NOT yet RSR-compliant"])
  }

  let output = output->Belt.Array.concat(["\nRecommendations:"])
  let output = result.recommendations->Belt.Array.reduce(output, (acc, rec) =>
    acc->Belt.Array.concat([`  ${rec}`])
  )

  output->Js.Array2.joinWith("\n")
}

// Version
@genType
let version = "1.0.0"
