// SPDX-License-Identifier: MIT AND Palimpsest-0.8
/**
 * Community Standards Helper
 * Audits and assists with community health files
 */

open GrimRepoTypes

let standardFiles: array<fileCheck> = [
  {
    path: "LICENSE",
    purpose: "License terms",
    priority: Required,
    template: None,
  },
  {
    path: "LICENSE.txt",
    purpose: "License terms (alternative)",
    priority: Required,
    template: None,
  },
  {
    path: "README.md",
    purpose: "Project overview",
    priority: Required,
    template: None,
  },
  {
    path: "CONTRIBUTING.md",
    purpose: "Contribution guidelines",
    priority: Recommended,
    template: None,
  },
  {
    path: "CODE_OF_CONDUCT.md",
    purpose: "Community conduct standards",
    priority: Recommended,
    template: None,
  },
  {
    path: "SECURITY.md",
    purpose: "Security policies",
    priority: Recommended,
    template: None,
  },
  {
    path: "CHANGELOG.md",
    purpose: "Version history",
    priority: Recommended,
    template: None,
  },
  {
    path: "MAINTAINERS.md",
    purpose: "Project maintainers",
    priority: Optional,
    template: None,
  },
  {
    path: ".well-known/security.txt",
    purpose: "RFC 9116 security contact",
    priority: Recommended,
    template: None,
  },
]

let normalizeFilePath = (path: string): string =>
  path->Js.String2.toLowerCase->Js.String2.replaceByRe(%re("/\\\\/g"), "/")

let analyzeCommunityStandards = (existingFiles: array<string>): communityStandards => {
  let fileSet = existingFiles->Belt.Array.map(normalizeFilePath)->Belt.Set.String.fromArray

  let hasLicense =
    fileSet->Belt.Set.String.has("license") ||
    fileSet->Belt.Set.String.has("license.txt") ||
    fileSet->Belt.Set.String.has("license.md")

  let (missing, present) = standardFiles->Belt.Array.reduce(([], []), ((missingAcc, presentAcc), file) => {
    let normalized = normalizeFilePath(file.path)

    // Skip LICENSE.txt check if LICENSE exists
    if file.path == "LICENSE.txt" && hasLicense {
      (missingAcc, presentAcc)
    } else if file.path == "LICENSE" && fileSet->Belt.Set.String.has("license.txt") {
      (missingAcc, presentAcc)
    } else if fileSet->Belt.Set.String.has(normalized) {
      (missingAcc, presentAcc->Belt.Array.concat([file.path]))
    } else {
      (missingAcc->Belt.Array.concat([file]), presentAcc)
    }
  })

  // Calculate score
  let uniqueFiles = Belt.Set.String.fromArray(["LICENSE", "README.md", "CONTRIBUTING.md", "CODE_OF_CONDUCT.md", "SECURITY.md", "CHANGELOG.md", "MAINTAINERS.md", ".well-known/security.txt"])

  let maxPoints = uniqueFiles->Belt.Set.String.size * 10

  let earnedPoints = standardFiles->Belt.Array.reduce(0, (earned, file) => {
    let normalized = normalizeFilePath(file.path)
    let isPresent = present->Belt.Array.some(p => normalizeFilePath(p) == normalized)

    if isPresent {
      if file.path->Js.String2.startsWith("LICENSE") {
        let alreadyCounted = present->Belt.Array.some(p =>
          p != file.path && normalizeFilePath(p)->Js.String2.startsWith("license")
        )
        if !alreadyCounted {
          earned + priorityToWeight(file.priority)
        } else {
          earned
        }
      } else {
        earned + priorityToWeight(file.priority)
      }
    } else {
      earned
    }
  })

  let score = if maxPoints > 0 {
    Float.toInt(Float.fromInt(earnedPoints) /. Float.fromInt(maxPoints) *. 100.0)
  } else {
    0
  }

  {
    missingFiles: missing,
    presentFiles: present,
    score: score,
  }
}

let getCommunityRecommendations = (standards: communityStandards): array<string> => {
  let recs = standards.missingFiles->Belt.Array.reduce([], (acc, missing) =>
    switch missing.priority {
    | Required => acc->Belt.Array.concat([`⚠️  Required: Add ${missing.path} for ${missing.purpose}`])
    | Recommended => acc->Belt.Array.concat([`💡 Recommended: Add ${missing.path} for ${missing.purpose}`])
    | Optional => acc
    }
  )

  let finalRec = if standards.score == 100 {
    "✅ Community standards are complete!"
  } else if standards.score >= 80 {
    "✅ Community standards are mostly complete"
  } else if standards.score >= 60 {
    "⚠️  Community standards need improvement"
  } else {
    "❌ Community standards are incomplete"
  }

  recs->Belt.Array.concat([finalRec])
}

let checkRSRCompliance = (standards: communityStandards): bool => {
  let presentNormalized = standards.presentFiles->Belt.Array.map(normalizeFilePath)->Belt.Set.String.fromArray

  let hasReadme = presentNormalized->Belt.Set.String.has("readme.md")
  let hasLicense =
    presentNormalized->Belt.Set.String.has("license") ||
    presentNormalized->Belt.Set.String.has("license.txt")
  let hasSecurity = presentNormalized->Belt.Set.String.has("security.md")
  let hasContributing = presentNormalized->Belt.Set.String.has("contributing.md")
  let hasCodeOfConduct = presentNormalized->Belt.Set.String.has("code_of_conduct.md")

  hasReadme && hasLicense && hasSecurity && hasContributing && hasCodeOfConduct
}
