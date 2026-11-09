{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      forAllSystems = f: nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ]
        (system: f nixpkgs.legacyPackages.${system});
    in {
      packages = forAllSystems (pkgs:
        let
          buildBook = inputs: extra: pkgs.stdenvNoCC.mkDerivation ({
            src = pkgs.lib.cleanSource self;
            nativeBuildInputs = inputs;
            buildPhase = ''
              mdbook build
              # Publish processed Markdown at both chapter.md and chapter.html.md.
              cp -R book/markdown/. book/html/
              find book/markdown -name '*.md' -type f | while IFS= read -r file; do
                relative="''${file#book/markdown/}"
                cp "$file" "book/html/''${relative%.md}.html.md"
              done
              # mdBook also serves the first chapter as index.html.
              cp book/markdown/introduction.md book/html/index.md
              cp book/markdown/introduction.md book/html/index.html.md
              # Keep the agent index and complete text in the same order as the book.
              {
                printf '# Stacks Security Handbook\n\n'
                printf '> Security requirements and guidance for the Stacks ecosystem.\n\n'
                printf '## Chapters\n\n'
                sed -n 's/^[[:space:]]*- \(\[[^]]*\]([^)]*\.md)\).*/- \1/p' src/SUMMARY.md
                printf '\n## Complete handbook\n\n'
                printf '%s\n' '- [Full handbook](./llms-full.txt): All chapters in one file.'
              } > book/html/llms.txt
              {
                printf '# Stacks Security Handbook\n\n'
                sed -n 's/^[[:space:]]*- \[[^]]*\](\([^)]*\.md\)).*/\1/p' src/SUMMARY.md |
                  while IFS= read -r chapter; do
                    cat "book/markdown/$chapter"
                    printf '\n\n'
                  done
              } > book/html/llms-full.txt
              mv book $out
            '';
          } // extra);
        in {
          default = buildBook [ pkgs.mdbook ] { name = "mdBook"; };
        } // pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
          pdf = buildBook [ pkgs.mdbook pkgs.mdbook-pdf pkgs.ungoogled-chromium ] {
            name = "mdBook-pdf";
            FONTCONFIG_FILE = "${pkgs.fontconfig.out}/etc/fonts/fonts.conf";
          };
        });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShellNoCC { nativeBuildInputs = [ pkgs.mdbook ]; };
      } // pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        pdf = pkgs.mkShellNoCC {
          nativeBuildInputs = [ pkgs.mdbook pkgs.mdbook-pdf pkgs.ungoogled-chromium ];
        };
      });
    };
}
