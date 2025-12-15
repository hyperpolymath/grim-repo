;; SPDX-License-Identifier: AGPL-3.0-or-later
;; SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
;; ECOSYSTEM.scm — grim-repo

(ecosystem
  (version "1.0.0")
  (name "grim-repo")
  (type "project")
  (purpose "*Modular audit-grade tooling for narratable, scaffolded, and legible repositories*")

  (position-in-ecosystem
    "Part of hyperpolymath ecosystem. Follows RSR guidelines.")

  (related-projects
    (project (name "rhodium-standard-repositories")
             (url "https://github.com/hyperpolymath/rhodium-standard-repositories")
             (relationship "standard")))

  (what-this-is "*Modular audit-grade tooling for narratable, scaffolded, and legible repositories*")
  (what-this-is-not "- NOT exempt from RSR compliance"))
