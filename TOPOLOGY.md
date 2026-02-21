<!-- SPDX-License-Identifier: PMPL-1.0-or-later -->
<!-- TOPOLOGY.md — Project architecture map and completion dashboard -->
<!-- Last updated: 2026-02-19 -->

# GrimRepo Scripts — Project Topology

## System Architecture

```
                        ┌─────────────────────────────────────────┐
                        │              USER / DEVELOPER           │
                        │        (Userscript UI / CLI / Nix)      │
                        └───────────────────┬─────────────────────┘
                                            │
                                            ▼
                        ┌─────────────────────────────────────────┐
                        │           GRIMREPO INTERFACE            │
                        │  ┌───────────┐  ┌───────────────────┐  │
                        │  │ Userscript│  │  CLI Wrapper      │  │
                        │  │ (dist/js) │  │  (Node/Deno)      │  │
                        │  └─────┬─────┘  └────────┬──────────┘  │
                        └────────│─────────────────│──────────────┘
                                 │                 │
                                 ▼                 ▼
                        ┌─────────────────────────────────────────┐
                        │           LOGIC LAYER (RESCRIPT)        │
                        │                                         │
                        │  ┌───────────┐  ┌───────────────────┐  │
                        │  │ Boot-     │  │  Community        │  │
                        │  │ strapper  │  │  Helper           │  │
                        │  └─────┬─────┘  └────────┬──────────┘  │
                        │        │                 │              │
                        │        └────────┬────────┘              │
                        │                 ▼                       │
                        │        ┌────────────────┐               │
                        │        │ Golden Registry│               │
                        │        │ Auditor        │               │
                        │        └────────┬────────┘              │
                        └─────────────────│───────────────────────┘
                                          │
                                          ▼
                        ┌─────────────────────────────────────────┐
                        │           TARGET REPOSITORY             │
                        │      (GitHub, GitLab, Bitbucket)        │
                        └─────────────────────────────────────────┘

                        ┌─────────────────────────────────────────┐
                        │          REPO INFRASTRUCTURE            │
                        │  Justfile           .machine_readable/  │
                        │  Nix / flake.nix    RSR Bronze (Certified)│
                        └─────────────────────────────────────────┘
```

## Completion Dashboard

```
COMPONENT                          STATUS              NOTES
─────────────────────────────────  ──────────────────  ─────────────────────────────────
CORE MODULES (RESCRIPT)
  Bootstrap (Structure)             ██████████ 100%    Essential scaffolding active
  Community Helper                  ██████████ 100%    License/MD auditing verified
  Audit (Golden Registry)           ██████████ 100%    Diagnostic checks stable
  GrimRepo Core                     ██████████ 100%    Main entry point verified

INTERFACES
  Userscript (JS Dist)              ██████████ 100%    GreasyFork ready
  Nix Development Shell             ██████████ 100%    Reproducible env stable
  CLI Wrapper                       ██████░░░░  60%    Standalone tool refining

REPO INFRASTRUCTURE
  Justfile Automation               ██████████ 100%    Standard build/verify tasks
  .machine_readable/                ██████████ 100%    STATE tracking active
  RSR Bronze Compliance             ██████████ 100%    616 LOC, zero deps verified

─────────────────────────────────────────────────────────────────────────────
OVERALL:                            █████████░  ~90%   Core scripts production-ready
```

## Key Dependencies

```
Nix Shell ──────► Just Build ──────► ReScript Comp ──────► Userscript
                                          │                 │
                                          ▼                 ▼
                                    Audit Modules ───► Target Repo
```

## Update Protocol

This file is maintained by both humans and AI agents. When updating:

1. **After completing a component**: Change its bar and percentage
2. **After adding a component**: Add a new row in the appropriate section
3. **After architectural changes**: Update the ASCII diagram
4. **Date**: Update the `Last updated` comment at the top of this file

Progress bars use: `█` (filled) and `░` (empty), 10 characters wide.
Percentages: 0%, 10%, 20%, ... 100% (in 10% increments).
