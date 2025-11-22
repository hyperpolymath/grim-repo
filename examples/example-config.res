// SPDX-License-Identifier: MIT AND Palimpsest-0.8
/**
 * Example configuration for custom GrimRepo rules
 */

open GrimRepoTypes

// Example: Custom directory requirements for a Rust project
let rustProjectDirs: array<directoryCheck> = [
  {
    path: "src/",
    purpose: "Source code",
    priority: Required,
    template: Some("# Source Code\n\nRust source files go here."),
  },
  {
    path: "tests/",
    purpose: "Integration tests",
    priority: Required,
    template: Some("# Tests\n\nIntegration tests for Cargo."),
  },
  {
    path: "benches/",
    purpose: "Benchmarks",
    priority: Recommended,
    template: Some("# Benchmarks\n\nPerformance benchmarks using criterion."),
  },
  {
    path: "examples/",
    purpose: "Usage examples",
    priority: Recommended,
    template: Some("# Examples\n\nShowcase programs demonstrating library usage."),
  },
  {
    path: ".cargo/",
    purpose: "Cargo configuration",
    priority: Optional,
    template: None,
  },
]

// Example: Custom file requirements for an enterprise project
let enterpriseFiles: array<fileCheck> = [
  {
    path: "LICENSE.txt",
    purpose: "Dual MIT + Palimpsest licensing",
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
    path: "SECURITY.md",
    purpose: "Security policies and vulnerability reporting",
    priority: Required,
    template: None,
  },
  {
    path: "CONTRIBUTING.md",
    purpose: "Contribution guidelines with TPCF",
    priority: Required,
    template: None,
  },
  {
    path: "CODE_OF_CONDUCT.md",
    purpose: "Community conduct standards",
    priority: Required,
    template: None,
  },
  {
    path: "CODEOWNERS",
    purpose: "GitHub/GitLab code ownership",
    priority: Recommended,
    template: Some("# Code owners for automatic review requests\n\n* @org/team-leads\n"),
  },
  {
    path: ".github/dependabot.yml",
    purpose: "Automated dependency updates",
    priority: Recommended,
    template: None,
  },
  {
    path: "GOVERNANCE.md",
    purpose: "Project governance and decision-making",
    priority: Optional,
    template: None,
  },
]

// Example: Strict mode configuration
let strictConfig: grimRepoConfig = {
  enabled: true,
  autoSuggest: true,
  strictMode: true, // Fail on missing optional items
  customDirs: [],
  customFiles: [],
}

// Example: Lenient mode configuration
let lenientConfig: grimRepoConfig = {
  enabled: true,
  autoSuggest: false, // Don't show suggestions automatically
  strictMode: false,  // Only warn on missing required items
  customDirs: [],
  customFiles: [],
}

// Example: Organization-specific configuration
let orgConfig: grimRepoConfig = {
  enabled: true,
  autoSuggest: true,
  strictMode: false,
  customDirs: [
    {
      path: "internal/",
      purpose: "Internal company tooling",
      priority: Required,
      template: Some("# Internal\n\nCompany-specific utilities (not for public release)."),
    },
  ],
  customFiles: [
    {
      path: "COMPLIANCE.md",
      purpose: "Regulatory compliance documentation",
      priority: Required,
      template: None,
    },
  ],
}
