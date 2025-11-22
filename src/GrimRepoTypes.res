// SPDX-License-Identifier: MIT AND Palimpsest-0.8
/**
 * Core types for GrimRepo
 * Type-safe, immutable data structures
 */

type priority = Required | Recommended | Optional

type directoryCheck = {
  path: string,
  purpose: string,
  priority: priority,
  template: option<string>,
}

type repoStructure = {
  missingDirs: array<directoryCheck>,
  presentDirs: array<string>,
  score: int,
}

type fileCheck = {
  path: string,
  purpose: string,
  priority: priority,
  template: option<string>,
}

type communityStandards = {
  missingFiles: array<fileCheck>,
  presentFiles: array<string>,
  score: int,
}

type qualityLevel = Raw | Bronze | Silver | Gold | Rhodium

type auditResult = {
  structure: repoStructure,
  community: communityStandards,
  overallScore: int,
  level: qualityLevel,
  recommendations: array<string>,
}

type platform = GitLab | GitHub | Bitbucket | Unknown

type platformContext = {
  platform: platform,
  repoOwner: string,
  repoName: string,
  currentPath: string,
}

type grimRepoConfig = {
  enabled: bool,
  autoSuggest: bool,
  strictMode: bool,
  customDirs: array<directoryCheck>,
  customFiles: array<fileCheck>,
}

// Helper functions for working with types

let priorityToWeight = (priority: priority): int =>
  switch priority {
  | Required => 10
  | Recommended => 5
  | Optional => 1
  }

let levelToString = (level: qualityLevel): string =>
  switch level {
  | Raw => "raw"
  | Bronze => "bronze"
  | Silver => "silver"
  | Gold => "gold"
  | Rhodium => "rhodium"
  }

let platformToString = (platform: platform): string =>
  switch platform {
  | GitLab => "gitlab"
  | GitHub => "github"
  | Bitbucket => "bitbucket"
  | Unknown => "unknown"
  }
