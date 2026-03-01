{
  description = "Brother P-Touch Cube printlabel wrapper";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        python = pkgs.python3.withPackages (ps: with ps; [
          pillow
          pybluez
        ]);

        printlabel = pkgs.stdenvNoCC.mkDerivation {
          pname = "printlabel";
          version = "0.1.0";
          src = ./.;

          nativeBuildInputs = [
            pkgs.makeWrapper
          ];

          installPhase = ''
            runHook preInstall

            mkdir -p "$out/bin" "$out/libexec/printlabel"
            cp labelmaker.py "$out/libexec/printlabel/"
            cp labelmaker_encode.py "$out/libexec/printlabel/"
            cp packbits.py "$out/libexec/printlabel/"
            cp ptcbp.py "$out/libexec/printlabel/"
            cp ptstatus.py "$out/libexec/printlabel/"
            cp printlabel "$out/libexec/printlabel/"
            chmod +x "$out/libexec/printlabel/printlabel"

            makeWrapper "$out/libexec/printlabel/printlabel" "$out/bin/printlabel" \
              --prefix PATH : ${pkgs.lib.makeBinPath [
                pkgs.bluez
                pkgs.fontconfig
                pkgs.imagemagick
                pkgs.qrencode
                python
              ]} \
              --set PYTHONPATH "$out/libexec/printlabel" \
              --set-default PRINTLABEL_QR_SIZE 64 \
              --set-default PYTHONNOUSERSITE 1

            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "CLI wrapper for printing text, images, and QR codes to Brother P-Touch Cube printers";
            license = licenses.mit;
            platforms = platforms.linux;
            mainProgram = "printlabel";
          };
        };
      in
      {
        packages.default = printlabel;
        packages.printlabel = printlabel;

        apps.default = {
          type = "app";
          program = "${printlabel}/bin/printlabel";
        };

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.bluez
            pkgs.fontconfig
            pkgs.imagemagick
            pkgs.qrencode
            pkgs.shellcheck
            python
          ];
        };
      }
    );
}
