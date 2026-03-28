; SPDX-License-Identifier: PMPL-1.0-or-later
;; guix.scm — GNU Guix package definition for grim-repo
;; Usage: guix shell -f guix.scm

(use-modules (guix packages)
             (guix build-system gnu)
             (guix licenses))

(package
  (name "grim-repo")
  (version "0.1.0")
  (source #f)
  (build-system gnu-build-system)
  (synopsis "grim-repo")
  (description "grim-repo — part of the hyperpolymath ecosystem.")
  (home-page "https://github.com/hyperpolymath/grim-repo")
  (license ((@@ (guix licenses) license) "PMPL-1.0-or-later"
             "https://github.com/hyperpolymath/palimpsest-license")))
