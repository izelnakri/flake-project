# Read about hercules CI caching and self-hosting CI system with logs & then Github CI for this
{
  description = "Development environment for whisper.cpp with Intel compilers and SYCL";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python312Full;

        getAllPkgConfigPaths = pkgs: inputs:
          let
            allDeps = pkgs.lib.closePropagation inputs;
          in
          pkgs.lib.makeSearchPathOutput "out" "lib/pkgconfig" allDeps + ":" +
          pkgs.lib.makeSearchPathOutput "out" "share/pkgconfig" allDeps + ":" +
          pkgs.lib.makeSearchPathOutput "dev" "lib/pkgconfig" allDeps + ":" +
          pkgs.lib.makeSearchPathOutput "dev" "share/pkgconfig" allDeps;
      in rec {
        checks = {
          default = pkgs.writeShellApplication { # Runnable via $ nix run ".#checks.x86_64-linux.default"
            name = "ma-default-check"; # required
            runtimeInputs = [ pkgs.deno ];
            text = ''
              make test
            '';
          };
        };


        devShells.default = pkgs.mkShell rec {
          name = "dev-default";
          
          # Access to statically or dynamically loaded libraries:
          # nativeBuildInputs = [
          #   pkgs.pkg-config
          #   pkgs.pango
          # ];

          # PKG_CONFIG_PATH = getAllPkgConfigPaths pkgs (buildInputs);
          # LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath buildInputs}:$LD_LIBRARY_PATH"; # Required for .so loading !! Try without FHSEnv
          
          shellHook = ''
            export ZDOTDIR=$(mktemp -d)
            cat > "$ZDOTDIR/.zshrc" << 'EOF'
              source ~/.zshrc # Source the original .zshrc, required.

              # NOTE: Only way to source/execute zsh code after sourcing ~/.zshrc:
              function parse_git_branch {
                git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\ ->\ \1/'
              }

              function display_jobs_count_if_needed {
                local job_count=$(jobs -s | wc -l | tr -d " ")

                if [ $job_count -gt 0 ]; then
                  echo "%B%F{yellow}%j| ";
                fi
              }

              PROMPT="%F{blue}$(date +%H:%M:%S) $(display_jobs_count_if_needed)%B%F{green}%n %F{blue}%~%F{cyan} ❄%F{yellow}$(parse_git_branch) %f%{$reset_color%}"
              PATH="${packages.backend}/bin:${packages.frontend}/bin:$PATH";

              # echo "🐍 Python: $(python3 --version)"
              # echo "⚡ uv: $(uv --version)"
              echo ""


              # source "/home/izelnakri/intel/oneapi/setvars.sh" --force 2>/dev/null || true
            EOF

            exec zsh -i
          '';
        };

        packages = rec {
          backend = pkgs.stdenv.mkDerivation rec {
            name = "flake-project-backend";

            buildInputs = [ pkgs.nodejs ];

            src = ./backend;

            buildPhase = "true";
            installPhase = ''
              mkdir -p $out/bin
              echo '#!${pkgs.runtimeShell}' > $out/bin/${name}
              echo 'exec ${pkgs.nodejs}/bin/node ${src}/index.js' >> $out/bin/${name}
              chmod +x $out/bin/${name}
            '';
          };
          frontend = pkgs.stdenv.mkDerivation rec {
            name = "flake-project-frontend";

            buildInputs = [ pkgs.nodejs ];

            src = ./frontend;

            buildPhase = "true";
            installPhase = ''
              mkdir -p $out/bin
              echo '#!${pkgs.runtimeShell}' > $out/bin/${name}
              echo 'exec ${pkgs.nodejs}/bin/node ${src}/index.js' >> $out/bin/${name}
              chmod +x $out/bin/${name}
            '';
          };
          default = pkgs.stdenv.mkDerivation rec { # Runnable via $ nix run .#
            name = "full-stack-launcher";

            buildCommand = ''
              mkdir -p $out/bin

              cat > $out/bin/${name}<<EOF
              #!${pkgs.runtimeShell}
              set -e

              # Start both backend and frontend in background
              ${backend}/bin/${backend.name} & BACK_PID=$!
              ${frontend}/bin/${frontend.name} & FRONT_PID=$!

              # When user presses Ctrl+C, stop both
              trap "kill \$BACK_PID \$FRONT_PID" SIGINT

              # Wait for both to exit
              wait \$BACK_PID \$FRONT_PID
              EOF

              chmod +x $out/bin/${name}
            '';
          };
        };
      });
}
