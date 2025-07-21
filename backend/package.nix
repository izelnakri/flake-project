# NOTE: Demonstrating this for example purposes: or maybe rename this to flake.nix
# could be called in root flake.nix like: pkgs.callPackage ./backend/package.nix
{ pkgs, backend, frontend }:

pkgs.stdenv.mkDerivation rec {
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
