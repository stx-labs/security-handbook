{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; };

  outputs = { self, nixpkgs, ... }:
    let

      forAllSystems = function:
        nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ]
        (system: function nixpkgs.legacyPackages.${system});

    in {
      packages = forAllSystems (pkgs: {
        default = pkgs.stdenvNoCC.mkDerivation {
          name = "mdBook";
          src = pkgs.lib.cleanSource self;
          buildInputs = [ pkgs.mdbook ];
          buildPhase = ''
            mdbook build
            mv book $out;
          '';
        };
        devShell =
          pkgs.mkShellNoCC { nativeBuildInputs = with pkgs; [ mdbook ]; };
      });
    };
}
