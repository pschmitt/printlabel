{
  description = "Brother P-Touch Cube printlabel wrapper";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nbx.url = "github:pschmitt/nbx";
    nbx.inputs.nixpkgs.follows = "nixpkgs";
    nbx.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, nbx }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        version =
          let
            rev =
              if self ? shortRev then
                self.shortRev
              else if self ? dirtyShortRev then
                self.dirtyShortRev
              else
                "unknown-dirty";
          in
          "${pkgs.lib.substring 0 8 self.lastModifiedDate}-${rev}";

        nbxPkg = nbx.packages.${system}.default;

        python = pkgs.python3.withPackages (ps: with ps; [
          pillow
          pybluez
        ]);

        printlabel = pkgs.stdenvNoCC.mkDerivation {
          pname = "printlabel";
          inherit version;
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
                pkgs.curl
                pkgs.fontconfig
                pkgs.fzf
                pkgs.imagemagick
                pkgs.jq
                pkgs.kitty
                nbxPkg
                pkgs.qrencode
                python
              ]} \
              --set PYTHONPATH "$out/libexec/printlabel" \
              --set PRINTLABEL_VERSION "${version}" \
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
            pkgs.curl
            pkgs.fontconfig
            pkgs.fzf
            pkgs.imagemagick
            pkgs.jq
            pkgs.kitty
            nbxPkg
            pkgs.qrencode
            pkgs.shellcheck
            python
          ];
        };
      }
    );
}
