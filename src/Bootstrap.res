// SPDX-License-Identifier: MIT AND Palimpsest-0.8
/**
 * Repo Structure Bootstrapper
 * Ensures essential directories exist with proper scaffolding
 */

open GrimRepoTypes

let standardDirectories: array<directoryCheck> = [
  {
    path: "src/",
    purpose: "Source code",
    priority: Required,
    template: Some("# Source Code\n\nMain application source code goes here."),
  },
  {
    path: "tests/",
    purpose: "Test files",
    priority: Required,
    template: Some("# Tests\n\nTest suites and test utilities go here."),
  },
  {
    path: "docs/",
    purpose: "Documentation",
    priority: Recommended,
    template: Some("# Documentation\n\nDetailed documentation, guides, and API references."),
  },
  {
    path: "examples/",
    purpose: "Example code",
    priority: Recommended,
    template: Some("# Examples\n\nUsage examples and sample applications."),
  },
  {
    path: ".gitlab/",
    purpose: "GitLab CI/CD config",
    priority: Optional,
    template: None,
  },
  {
    path: ".github/",
    purpose: "GitHub-specific config",
    priority: Optional,
    template: None,
  },
  {
    path: "scripts/",
    purpose: "Build and automation scripts",
    priority: Recommended,
    template: None,
  },
  {
    path: ".well-known/",
    purpose: "RFC-compliant metadata",
    priority: Recommended,
    template: None,
  },
]

let normalizePath = (path: string): string =>
  path->Js.String2.toLowerCase->Js.String2.replaceByRe(%re("/\/+$/"), "")

let analyzeStructure = (existingPaths: array<string>): repoStructure => {
  let pathSet = existingPaths->Belt.Array.map(normalizePath)->Belt.Set.String.fromArray

  let (missing, present) = standardDirectories->Belt.Array.reduce(([], []), (
    (missingAcc, presentAcc),
    dir,
  ) => {
    let normalized = normalizePath(dir.path)
    if pathSet->Belt.Set.String.has(normalized) {
      (missingAcc, presentAcc->Belt.Array.concat([dir.path]))
    } else {
      (missingAcc->Belt.Array.concat([dir]), presentAcc)
    }
  })

  // Calculate score
  let (maxPoints, earnedPoints) = standardDirectories->Belt.Array.reduce((0, 0), (
    (max, earned),
    dir,
  ) => {
    let points = priorityToWeight(dir.priority)
    let newMax = max + points
    let normalized = normalizePath(dir.path)
    let newEarned = if pathSet->Belt.Set.String.has(normalized) {
      earned + points
    } else {
      earned
    }
    (newMax, newEarned)
  })

  let score = if maxPoints > 0 {
    Float.toInt(Float.fromInt(earnedPoints) /. Float.fromInt(maxPoints) *. 100.0)
  } else {
    0
  }

  {
    missingDirs: missing,
    presentDirs: present,
    score: score,
  }
}

let generateDirectoryTemplate = (dir: directoryCheck): string =>
  switch dir.template {
  | Some(template) => template
  | None => `# ${dir.path}\n\n${dir.purpose}\n`
  }

let getStructureRecommendations = (structure: repoStructure): array<string> => {
  let recs = structure.missingDirs->Belt.Array.reduce([], (acc, missing) =>
    switch missing.priority {
    | Required => acc->Belt.Array.concat([`⚠️  Required: Create ${missing.path} for ${missing.purpose}`])
    | Recommended => acc->Belt.Array.concat([`💡 Recommended: Add ${missing.path} for ${missing.purpose}`])
    | Optional => acc
    }
  )

  let finalRec = if structure.score == 100 {
    "✅ Structure is complete!"
  } else if structure.score >= 80 {
    "✅ Structure is mostly complete"
  } else if structure.score >= 60 {
    "⚠️  Structure needs improvement"
  } else {
    "❌ Structure is incomplete"
  }

  recs->Belt.Array.concat([finalRec])
}
