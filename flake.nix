{
  description = "GrimRepo Scripts - ReScript + WASM implementation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # ReScript compiler
        rescript = pkgs.nodePackages.rescript;

        # Just task runner
        just = pkgs.just;

      in
      {
        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs_20
            rescript
            just
            git
            ocaml
            dune_3
          ];

          shellHook = ''
            echo "🔧 GrimRepo Development Environment (ReScript + WASM)"
            echo ""
            echo "ReScript: $(rescript -version)"
            echo "Node.js: $(node --version)"
            echo "just: $(just --version)"
            echo ""
            echo "Available commands:"
            echo "  just --list        Show all available tasks"
            echo "  just build         Build ReScript to JavaScript"
            echo "  just watch         Watch mode for development"
            echo "  just verify-rsr    Verify RSR compliance"
            echo ""
          '';
        };

        # Package definition
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "grimrepo-scripts";
          version = "1.0.0";

          src = ./.;

          buildInputs = [ rescript just ];

          buildPhase = ''
            rescript build
          '';

          installPhase = ''
            mkdir -p $out
            cp -r lib $out/
            cp -r src $out/
            cp README.md $out/
            cp LICENSE.txt $out/
            cp bsconfig.json $out/
          '';

          meta = with pkgs.lib; {
            description = "Modular audit-grade tooling for narratable repositories (ReScript + WASM)";
            homepage = "https://grimrepo.dev";
            license = [ licenses.mit ]; # Dual MIT + Palimpsest
            maintainers = [ ];
          };
        };

        # Checks
        checks = {
          build = self.packages.${system}.default;
        };
      }
    );
}
