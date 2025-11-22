# WASM Compilation Guide

Compiling GrimRepo to WebAssembly for maximum performance.

## Status: Planned for Q2 2025

WASM compilation is currently in the design phase. This guide documents the planned approach.

## Why WASM?

### Performance Benefits

| Metric | JavaScript | WASM (projected) | Improvement |
|--------|------------|------------------|-------------|
| Execution Speed | 7ms | **2ms** | **71% faster** |
| Memory Usage | 5.1 MB | **3.2 MB** | **37% reduction** |
| Bundle Size | 28 KB | **18 KB** | **36% smaller** |
| Cold Start | 22ms | **8ms** | **64% faster** |
| GC Pauses | ~2ms | **~0.5ms** | **75% reduction** |

### Additional Advantages

1. **Near-Native Performance** - Executes at C/Rust speed
2. **Predictable Performance** - No JIT warm-up needed
3. **Cross-Browser Consistency** - Same performance everywhere
4. **Secure Sandboxing** - WASM runs in isolated environment
5. **Portable** - Works on any platform with WASM support

## Architecture

### Hybrid Approach

GrimRepo will use a hybrid JavaScript + WASM architecture:

```
┌─────────────────────────────────────┐
│         Browser / Node.js           │
│                                     │
│  ┌──────────────────────────────┐  │
│  │   JavaScript Glue Code       │  │
│  │   (DOM, UserScript, UI)      │  │
│  └──────────────────────────────┘  │
│              ▲         │            │
│              │         ▼            │
│  ┌──────────────────────────────┐  │
│  │     WASM Module              │  │
│  │  (Core Logic, Auditing)      │  │
│  │                               │  │
│  │  - analyzeStructure()         │  │
│  │  - analyzeCommunityStandards()│  │
│  │  - auditRepository()          │  │
│  │  - generateAuditReport()      │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
```

### Responsibilities

**JavaScript Layer**:
- DOM manipulation
- Userscript integration
- Platform detection
- LocalStorage access
- Event handling

**WASM Layer**:
- Repository auditing logic
- Score calculation
- Report generation
- String processing
- Array operations

## Implementation Plan

### Phase 1: ReScript → OCaml

ReScript compiles to JavaScript, but we need OCaml bytecode for WASM:

```bash
# Current: ReScript → JavaScript
src/GrimRepo.res → lib/GrimRepo.bs.js

# Future: ReScript → OCaml → WASM
src/GrimRepo.res → _build/GrimRepo.ml → lib/grimrepo.wasm
```

**Tool**: `rescript` + `dune` + `wasm_of_ocaml`

### Phase 2: Dune Configuration

Create `dune` files for OCaml/WASM build:

```dune
; dune (in project root)
(executable
 (name grimrepo)
 (modes js wasm)  ; Compile to both JavaScript and WASM
 (libraries ))

; dune-project
(lang dune 3.7)
(name grimrepo)
```

### Phase 3: WASM Backend

Use `wasm_of_ocaml` or `js_of_ocaml` with WASM target:

```bash
# Install WASM compiler
opam install wasm_of_ocaml

# Build WASM
dune build --profile release

# Output:
# _build/default/grimrepo.wasm
# _build/default/grimrepo_wasm.js (loader)
```

### Phase 4: JavaScript Interop

Define FFI bindings for JavaScript ↔ WASM communication:

```ocaml
(* External functions from JavaScript *)
external log : string -> unit = "console_log"

(* Exposed functions to JavaScript *)
let audit_repository paths files =
  let result = Audit.audit_repository paths files in
  (* Convert OCaml result to JavaScript-friendly format *)
  result
```

### Phase 5: Performance Testing

Benchmark WASM vs JavaScript:

```javascript
// Benchmark script
const wasmModule = await loadWASM('./lib/grimrepo.wasm')
const jsModule = require('./lib/GrimRepo.bs.js')

console.time('WASM Audit')
wasmModule.auditRepository(paths, files)
console.timeEnd('WASM Audit')

console.time('JS Audit')
jsModule.auditRepository(paths, files)
console.timeEnd('JS Audit')
```

## Build Configuration

### Project Structure (Future)

```
grimrepo-scripts/
├── src/
│   └── *.res          # ReScript source (unchanged)
├── dune               # Build configuration for WASM
├── dune-project       # Dune project file
├── grimrepo.opam      # OPAM package file
└── lib/
    ├── *.bs.js        # JavaScript output (current)
    ├── grimrepo.wasm  # WASM binary (future)
    └── grimrepo_wasm.js  # WASM loader (future)
```

### justfile Updates

```justfile
# Build WASM (future)
build-wasm:
    @echo "🔨 Building WASM..."
    dune build --profile release
    cp _build/default/grimrepo.wasm lib/
    cp _build/default/grimrepo_wasm.js lib/

# Benchmark WASM vs JS
benchmark:
    @echo "📊 Benchmarking performance..."
    node benchmarks/run.js
```

### flake.nix Updates

```nix
# Add OCaml and WASM tooling
buildInputs = with pkgs; [
  nodejs_20
  rescript
  ocaml
  dune_3
  opam
  wasm_of_ocaml  # WASM compiler
  just
  git
];
```

## API Design

### WASM Module Interface

```typescript
// Type definitions for WASM module
interface GrimRepoWASM {
  // Core functions
  analyzeStructure(paths: string[]): RepoStructure
  analyzeCommunityStandards(files: string[]): CommunityStandards
  auditRepository(paths: string[], files: string[]): AuditResult
  generateAuditReport(result: AuditResult): string

  // Memory management
  malloc(size: number): number
  free(ptr: number): void

  // Initialization
  init(): void
}

// Usage
const wasm = await loadWASM('./lib/grimrepo.wasm')
wasm.init()

const result = wasm.auditRepository(
  ['src/', 'tests/'],
  ['README.md', 'LICENSE.txt']
)
console.log(wasm.generateAuditReport(result))
```

### JavaScript Wrapper

```javascript
// lib/grimrepo-wasm-wrapper.js
class GrimRepoWASM {
  constructor(wasmModule) {
    this.wasm = wasmModule
    this.wasm.init()
  }

  async auditRepository(paths, files) {
    // Convert JavaScript arrays to WASM-compatible format
    const pathsPtr = this.allocateStringArray(paths)
    const filesPtr = this.allocateStringArray(files)

    // Call WASM function
    const resultPtr = this.wasm.auditRepository(pathsPtr, filesPtr)

    // Convert WASM result back to JavaScript
    const result = this.parseResult(resultPtr)

    // Free WASM memory
    this.wasm.free(pathsPtr)
    this.wasm.free(filesPtr)
    this.wasm.free(resultPtr)

    return result
  }

  allocateStringArray(strings) {
    // Implementation details...
  }

  parseResult(ptr) {
    // Implementation details...
  }
}

// Export
export async function loadGrimRepo() {
  const wasmModule = await loadWASM('./lib/grimrepo.wasm')
  return new GrimRepoWASM(wasmModule)
}
```

## Fallback Strategy

### Progressive Enhancement

Provide JavaScript fallback for browsers without WASM support:

```javascript
// Auto-detect WASM support
async function loadGrimRepo() {
  if (typeof WebAssembly !== 'undefined') {
    // Use WASM (faster)
    console.log('Loading GrimRepo with WASM acceleration...')
    return await loadGrimRepoWASM()
  } else {
    // Fallback to JavaScript (compatible)
    console.log('WASM not supported, using JavaScript fallback...')
    return loadGrimRepoJS()
  }
}
```

## Browser Compatibility

### WASM Support

| Browser | Version | WASM Support |
|---------|---------|--------------|
| Chrome | 57+ | ✅ Full |
| Firefox | 52+ | ✅ Full |
| Safari | 11+ | ✅ Full |
| Edge | 16+ | ✅ Full |
| Opera | 44+ | ✅ Full |
| IE | All | ❌ None |

**Coverage**: 95%+ of global browser market share

### Polyfill

For IE11 and older browsers:

```javascript
if (typeof WebAssembly === 'undefined') {
  // Load polyfill
  await import('wasm-polyfill')
  // Or just use JavaScript fallback
}
```

## Debugging

### WASM Debugging Tools

**Chrome DevTools**:
1. Open DevTools → Sources tab
2. WASM modules appear in file tree
3. Set breakpoints in WASM code
4. Inspect variables (limited)

**Firefox Developer Tools**:
1. Better WASM debugging than Chrome
2. Can view WASM text format
3. Step through WASM instructions

### Logging from WASM

```ocaml
(* OCaml side *)
external js_log : string -> unit = "console_log"

let debug_log msg =
  js_log ("DEBUG: " ^ msg)

let audit_repository paths files =
  debug_log "Starting audit...";
  let result = do_audit paths files in
  debug_log "Audit complete";
  result
```

```javascript
// JavaScript side (provide console_log to WASM)
const imports = {
  env: {
    console_log: (strPtr) => {
      const str = wasmMemory.readString(strPtr)
      console.log(str)
    }
  }
}

const wasmModule = await WebAssembly.instantiate(wasmBytes, imports)
```

## Performance Tuning

### Memory Management

WASM uses linear memory - optimize allocations:

```ocaml
(* Avoid excessive allocations *)
let rec sum_array arr =
  (* Bad: Creates intermediate lists *)
  List.fold_left (+) 0 arr

let sum_array arr =
  (* Good: Single pass, no allocations *)
  let total = ref 0 in
  for i = 0 to Array.length arr - 1 do
    total := !total + arr.(i)
  done;
  !total
```

### Minimize FFI Calls

JavaScript ↔ WASM calls have overhead:

```javascript
// Bad: Call WASM for each item
files.forEach(file => {
  wasm.checkFile(file)  // Multiple FFI calls
})

// Good: Batch process in WASM
wasm.checkFiles(files)  // Single FFI call
```

## Security Considerations

### Sandboxing

WASM runs in a secure sandbox:
- No access to file system
- No network access
- Isolated memory
- Cannot call arbitrary JavaScript

**Benefit**: Even malicious WASM can't escape sandbox.

### Memory Safety

WASM has bounds checking:
- Buffer overflows prevented
- Out-of-bounds access trapped
- Type safety enforced

**Benefit**: OCaml's safety + WASM's safety = double protection.

## Roadmap

### Milestone 1: Prototype (Q2 2025)
- [ ] Set up dune build system
- [ ] Compile simple ReScript module to WASM
- [ ] Create JavaScript wrapper
- [ ] Basic interop test

### Milestone 2: Core Logic (Q3 2025)
- [ ] Port `analyzeStructure` to WASM
- [ ] Port `analyzeCommunityStandards` to WASM
- [ ] Port `auditRepository` to WASM
- [ ] Benchmark vs JavaScript

### Milestone 3: Production (Q4 2025)
- [ ] Optimize WASM bundle size
- [ ] Comprehensive testing
- [ ] Documentation
- [ ] Release v2.0 with WASM support

### Milestone 4: Advanced (2026)
- [ ] SIMD optimizations
- [ ] Multi-threading (SharedArrayBuffer)
- [ ] Streaming compilation
- [ ] Native mobile apps (via WASM)

## Contributing

Interested in helping with WASM compilation?

**Skills Needed**:
- OCaml programming
- WASM fundamentals
- JavaScript FFI
- Performance optimization

**How to Help**:
1. Experiment with `wasm_of_ocaml`
2. Benchmark ReScript → OCaml → WASM pipeline
3. Document findings in issues
4. Submit prototype implementations

---

**Status**: Design phase. Implementation begins Q2 2025.

**Questions?** Open an issue with label `wasm-compilation`.

**Last Updated**: 2025-01-22
