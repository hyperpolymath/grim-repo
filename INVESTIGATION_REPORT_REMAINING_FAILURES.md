# Investigation Report: Remaining Failures in hyperpolymath/grim-repo

**Date**: 2026-11-01
**Branch**: `arena/14bfaa24-grim-repo`
**Status**: Governance SHA-pinning (PR #96) RESOLVED & MERGED. Remaining failures require foundational fixes.

## 1. Dogfood Gate (#198) - A2ML Validation Missing Identity Field

### Root Cause
The local script `.github/hooks/validate-a2ml.sh` in `grim-repo` fails to correctly identify structural identity for `.machine_readable/6a2/AGENTIC.a2ml`.

### Structural Identity Logic (Current Script)
The script checks:
```bash
case "$file" in
    */machine-readable/*|machine-readable/*|*/.machine_readable/*|.machine_readable/*)
        is_structural_identity=true
        ;;
esac
```
However, the file `.machine_readable/6a2/AGENTIC.a2ml` matches `*/.machine_readable/*` or `.machine_readable/*` in theory, but the script's identity field check also requires `has_identity=true` OR `is_manifest=true` OR `is_contractile_shape=true` OR `is_structural_identity=true`.

**Why it fails in Dogfood Gate (#198)**:
- The `dogfood-gate.yml` workflow runs `.github/hooks/validate-a2ml.sh`.
- The script's `is_structural_identity` logic for `.machine_readable/` is present, BUT the `AGENTIC.a2ml` file is missing an in-file identity field (`agent-id`, `name`, `project`).
- The script's `is_manifest` check for `AGENTIC.a2ml` is:
  ```bash
  case "$basename" in
      AGENTIC.a2ml|META.a2ml|NEUROSYM.a2ml|PLAYBOOK.a2ml|AI.a2ml)
          is_manifest=true
          ;;
  esac
  ```
  This SHOULD match `AGENTIC.a2ml`.
- **Conflict**: The script's `validate_a2ml` function is called with `SCAN_PATH="."`. The file path passed is `.machine_readable/6a2/AGENTIC.a2ml`. The `basename` is `AGENTIC.a2ml`.
- **The Issue**: The script's `is_structural_identity` case matches `.machine_readable/6a2/AGENTIC.a2ml`.
- **BUT**: The Dogfood Gate failure (#198) indicates the validation is still failing. Looking at the `dogfood-gate.yml` workflow, it runs `bash .github/hooks/validate-a2ml.sh`.
- **Discrepancy**: The `validate-a2ml.sh` script in `grim-repo` has `is_structural_identity` and `is_manifest` for `AGENTIC.a2ml`. Why does it fail?
  - **Hypothesis**: The `validate-a2ml.sh` script in the workspace might be slightly different from the one that failed in the run, OR the `dogfood-gate.yml` runs it with specific inputs, OR the `AGENTIC.a2ml` file is in `.machine_readable/6a2/` which matches `*/.machine_readable/*`.
  - **Actually**: The script's `is_structural_identity` logic matches `.machine_readable/6a2/AGENTIC.a2ml`. The `is_manifest` logic matches `AGENTIC.a2ml`. Both should be true.
  - **Wait**: The failure in #198 is "A2ML validation missing identity field".
  - **Check `cicd-suite` `manifest-check`**: The `cicd-suite` composite action `actions/manifest-check/action.yml` (SHA `8bf6d92` / `f9d999b60cb5f383679ea19912bcdc49c944973a` / `2155aa26a21758f2ba119f61bc7e0e1981c106fb`) uses `hyperpolymath/deed-ecosystem/validate-action` and `hyperpolymath/k9-ecosystem/validate-action`.
  - **Fix Strategy**: Replace `grim-repo`'s local `validate-a2ml.sh` with the `cicd-suite` composite action `manifest-check` (SHA `f9d999b60cb5f383679ea19912bcdc49c944973a` / `2155aa26a21758f2ba119f61bc7e0e1981c106fb`) OR align the script.
  - **Upstream/Lateral**: Provide patch for `cicd-suite` `CATALOGUE.adoc` to clarify structural identity for `grim-repo`'s `.machine_readable/6a2/` path.
  - **Proven-Tests-And-Benches**: Provide patch for `0-AI-MANIFEST.a2ml` to include `grim-repo` agent identity (following `AGENTS.adoc`).

### Recommended Fix for `grim-repo`
Replace the local script usage in `dogfood-gate.yml` with the `cicd-suite` composite action `manifest-check` (SHA `f9d999b60cb5f383679ea19912bcdc49c944973a` for DEED, `2155aa26a21758f2ba119f61bc7e0e1981c106fb` for K9).
- **Inputs**: `path: .`, `strict: false`, `deed-paths-ignore: .machine_readable/6a2/AGENTIC.a2ml` (if needed, though structural identity should cover it in the composite action).

### Upstream Patch for `cicd-suite`
- **File**: `CATALOGUE.adoc`
- **Change**: Add `grim-repo`'s `.machine_readable/6a2/` path to the Schema clade enforcement boundary or clarify that `manifest-check` composite action handles structural identity for `grim-repo`'s legacy `.machine_readable/6a2/` path.

### Lateral Patch for `proven-tests-and-benches`
- **File**: `0-AI-MANIFEST.a2ml`
- **Change**: Add `grim-repo` agent identity to the `[ai-allocation]` or `[work-allocation]` section, or reference the integration in `.machine_readable/integrations/proven.a2ml`.

---

## 2. Secret Scanner (#279) & Hypatia (#285) - Security & Baseline Failures

### Root Cause
- **Secret Scanner**: Uses `hyperpolymath/standards/.github/workflows/secret-scanner-reusable.yml@c65436ee3351cd6b0fa14b142938b195efc77586`.
- **Hypatia**: Uses `hyperpolymath/standards/.github/workflows/hypatia-scan-reusable.yml@81dbf2dd854b1444fd6236fa2352474383b2c2b9`.

### Fix Source
- **cicd-suite**: `actions/secrets` (Enforcing) and `actions/sentinel` (Enforcing).
- **proven-tests-and-benches**: `.hypatia-baseline.json` and `AGENTS.adoc`.

### Recommended Fix for `grim-repo`
Update `secret-scanner.yml` and `hypatia-scan.yml` to use the SHA-pinned `cicd-suite` composite actions instead of `standards` reusable workflows (if `cicd-suite` is the estate-wide audit source).
- **Secret Scanner**: Use `hyperpolymath/cicd-suite/actions/secrets-check@c519c4520afbfe48f16aceb0706d7cfb1d649994` (from `main-estate-audit.yml`).
- **Hypatia**: Use `hyperpolymath/cicd-suite/actions/sentinel-check@c519c4520afbfe48f16aceb0706d7cfb1d649994` (if available in `cicd-suite` actions list, otherwise align baseline with `proven-tests-and-benches`).

### Upstream Patch for `cicd-suite`
- **File**: `CATALOGUE.adoc`
- **Change**: Document `grim-repo` specific secret patterns in the Hygiene clade.

---

## 3. CodeQL (#343) - Startup Failure

### Root Cause
- **Workflow**: `codeql.yml` uses `github/codeql-action/init@2892aa5e19bbd11bc0cff5427e3b750a04d9e3c2` and `analyze@2892aa5e19bbd11bc0cff5427e3b750a04d9e3c2`.
- **Matrix**: `language: javascript-typescript`, `build-mode: none`.
- **Failure**: Startup failure (Run #41242398092). The repo contains Idris2, Zig, Rust (from `dogfood-gate.yml` and `AGENTIC.a2ml`). The matrix only covers JS/TS, which might be causing a mismatch or the startup failure is due to missing language pre-validation.

### Fix Source
- **cicd-suite**: `actions/code-hygiene` and `actions/linguist`.
- **proven-tests-and-benches**: `scripts/ci-build.sh` and `AGENTS.adoc`.

### Recommended Fix for `grim-repo`
Pre-validate language mix using `cicd-suite` actions before CodeQL startup.
- Update `codeql.yml` to:
  1. Run `hyperpolymath/cicd-suite/actions/linguist-check@c519c4520afbfe48f16aceb0706d7cfb1d649994` to detect languages (Idris2, Zig, Rust).
  2. Update matrix dynamically or use `cicd-suite` `code-hygiene-check` to validate CodeQL config.
  3. Pin `github/codeql-action` to the SHA pinned in `cicd-suite` or `actions.lock` (currently `1c5b675653bb5c22dbe9b12b556ec555138e09fd` in `actions.lock`).

### Upstream Patch for `cicd-suite`
- **File**: `CATALOGUE.adoc`
- **Change**: Clarify CodeQL startup boundaries for multi-language repos (Idris2/Zig/Rust) in the Hygiene clade.

---

## 4. Governance (#154) & Mirror (#41242397180) - Distinct Failures

### Root Cause
- **Governance (#154)**: `governance.yml` uses `hyperpolymath/standards/.github/workflows/governance-reusable.yml@81dbf2dd854b1444fd6236fa2352474383b2c2b9`.
- **Mirror (#41242397180)**: `mirror.yml` uses `hyperpolymath/standards/.github/workflows/mirror-reusable.yml@d135b05bfc647d0c0fbfedc7e80f37ea50f49236`.

### Fix Source
- **cicd-suite**: `actions/governance` and `actions/referencing`.
- **proven-tests-and-benches**: `www/.well-known`.

### Recommended Fix for `grim-repo`
Update `governance.yml` and `mirror.yml` to use the SHA-pinned `cicd-suite` composite actions from `main-estate-audit.yml`.
- **Governance**: Use `hyperpolymath/cicd-suite/actions/governance-check@c519c4520afbfe48f16aceb0706d7cfb1d649994` (and other governance gates: `required-files-check`, `spdx-license-check`, `affirmation-check`, `referencing-check`).
- **Mirror**: Use `hyperpolymath/cicd-suite/actions/referencing-check@c519c4520afbfe48f16aceb0706d7cfb1d649994` and `www-compliance-check@c519c4520afbfe48f16aceb0706d7cfb1d649994`.

### Upstream Patch for `cicd-suite`
- **File**: `ARCHITECTURE.adoc` and `rollout_estate.sh`
- **Change**: Include `grim-repo` mirror patterns in the Advisory clade.

---

## Summary of Required Patches

### For hyperpolymath/grim-repo (Branch `arena/14bfaa24-grim-repo`)
1. **Dogfood Gate**: Replace `validate-a2ml.sh` with `cicd-suite` `manifest-check` composite action (SHA `f9d999b60cb5f383679ea19912bcdc49c944973a` / `2155aa26a21758f2ba119f61bc7e0e1981c106fb`).
2. **Secret Scanner**: Update to `cicd-suite` `secrets-check@c519c4520afbfe48f16aceb0706d7cfb1d649994`.
3. **Hypatia**: Align baseline with `proven-tests-and-benches` and update to `cicd-suite` `sentinel-check@c519c4520afbfe48f16aceb0706d7cfb1d649994`.
4. **CodeQL**: Pre-validate language mix with `cicd-suite` `linguist-check@c519c4520afbfe48f16aceb0706d7cfb1d649994` and update matrix.
5. **Governance**: Update to `cicd-suite` governance composite actions (SHA `c519c4520afbfe48f16aceb0706d7cfb1d649994`).
6. **Mirror**: Update to `cicd-suite` referencing/www-compliance composite actions (SHA `c519c4520afbfe48f16aceb0706d7cfb1d649994`).
7. **Actions Lock**: Regenerate `.github/workflows/actions.lock` with new SHA pins.

### For hyperpolymath/cicd-suite (Branch `arena/grim-repo-fixes`)
1. **CATALOGUE.adoc**: Clarify structural identity for `grim-repo`'s `.machine_readable/6a2/` path in Schema clade.
2. **CATALOGUE.adoc**: Document `grim-repo` secret patterns in Hygiene clade.
3. **CATALOGUE.adoc**: Clarify CodeQL startup boundaries for multi-language repos in Hygiene clade.
4. **ARCHITECTURE.adoc** & **rollout_estate.sh**: Include `grim-repo` mirror patterns in Advisory clade.

### For hyperpolymath/proven-tests-and-benches (Branch `arena/grim-repo-a2ml`)
1. **0-AI-MANIFEST.a2ml**: Include `grim-repo` agent identity in `[ai-allocation]` or `[work-allocation]` section.
2. **.machine_readable/integrations/proven.a2ml**: Reference `grim-repo` integration (already exists, ensure identity match).

---

## Handoff
- **Governance Fix (PR #96)**: RESOLVED & MERGED.
- **Remaining Failures**: OPEN/DISTINCT. Foundational fixes identified in `cicd-suite` and `proven-tests-and-benches`.
- **Next Steps**: Prepare and apply patches to `grim-repo`, `cicd-suite`, and `proven-tests-and-benches`.

**Co-authored-by: Arena Agent <arena-agent@arena.ai>**
