{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; };

  outputs = { self, nixpkgs, ... }:
    let

      forAllSystems = function:
        nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ]
        (system: function nixpkgs.legacyPackages.${system});

    in rec {
      packages = forAllSystems (pkgs:
        let

          src = pkgs.lib.cleanSource self;
          buildPhase = ''
            mdbook build
            mv book $out;
          '';

          # Need version v0.5.0+ to fix broken links in PDF
          # TODO: Remove me once 0.5.0 lands in `nixpkgs`
          mdbook = pkgs.mdbook.overrideAttrs (drv: rec {
            version = "e5386f92308f3b974669a2a43d3e58abe0839202";

            src = pkgs.fetchFromGitHub {
              owner = "rust-lang";
              repo = "mdBook";
              rev = version;
              sha256 = "sha256-WX6U25ySRECmKr2dHrMNaYDUwdytt3gHesKknC+K0U4=";
            };

            cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
              inherit src;
              hash = "sha256-l6S+92+Zcnyc8SJbZ6ETkoysMY5c29nwmoodRsBdtNU=";
            };
          });

          # Need version > 0.1.11
          # TODO: Remove me once >0.1.11 lands in `nixpkgs`
          mdbook-pdf = pkgs.mdbook-pdf.overrideAttrs (drv: rec {
            version = "3682e7f3fc06d0dbc3f9ebad613fec2611f1abbb";

            src = pkgs.fetchFromGitHub {
              owner = "HollowMan6";
              repo = "mdbook-pdf";
              rev = version;
              sha256 = "sha256-7Ajb5Zc+ngVDcwrf51bBV60p2B+nVLyeIKg87BZNYSI";
            };

            # NOTE: This ugly machinery is due to the fact that mdbook-pdf 
            # does not vendor its Cargo.lock file.
            #
            # TODO: You can safely remove `./mdbook-pdf.Cargo.lock` when you
            # remove this code.`
            postPatch = ''
              ln -s ${./mdbook-pdf.Cargo.lock} Cargo.lock
            '';

            cargoDeps = pkgs.rustPlatform.importCargoLock {
              lockFile = ./mdbook-pdf.Cargo.lock;

              outputHashes = {
                "mdbook-core-0.5.0-alpha.1" =
                  "sha256-WX6U25ySRECmKr2dHrMNaYDUwdytt3gHesKknC+K0U4=";
              };
            };
          });

          buildInputs = [ pkgs.mdbook ];
          pdfBuildInputs = [ mdbook mdbook-pdf pkgs.ungoogled-chromium ];

        in {
          default = pkgs.stdenvNoCC.mkDerivation {
            inherit src buildPhase buildInputs;
            name = "mdBook";
          };

          # https://github.com/HollowMan6/mdbook-pdf/issues/59
          pdf = pkgs.stdenvNoCC.mkDerivation {
            inherit src buildPhase;
            name = "mdBook-pdf";
            configurePhase = ''
              export FONTCONFIG_FILE="${pkgs.fontconfig.out}/etc/fonts/fonts.conf"
            '';
            buildInputs = pdfBuildInputs;
          };

          devShells.default =
            pkgs.mkShellNoCC { nativeBuildInputs = buildInputs; };

          devShells.pdf =
            pkgs.mkShellNoCC { nativeBuildInputs = pdfBuildInputs; };
        });

      # Make `ddevShells` available in the top flake schema.
      devShells = forAllSystems (pkgs: packages.${pkgs.system}.devShells);
    };
}
