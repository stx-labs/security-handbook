{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      forAllSystems = f: nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ]
        (system: f nixpkgs.legacyPackages.${system});
    in {
      packages = forAllSystems (pkgs:
        let
          buildBook = inputs: withPdf: extra: pkgs.stdenvNoCC.mkDerivation ({
            src = pkgs.lib.cleanSource self;
            nativeBuildInputs = inputs;
            # mdbook-linkcheck2 initializes a TLS client even for offline checks.
            SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
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
              # Reference definitions are document-wide when chapters are joined.
              # Reject collisions rather than silently resolving links to the wrong URL.
              : > reference-labels
              sed -n 's/^[[:space:]]*- \[[^]]*\](\([^)]*\.md\)).*/\1/p' src/SUMMARY.md |
                while IFS= read -r chapter; do
                  sed -n 's/^[[:space:]]*\(\[[^]]*\]\):.*/\1/p' "book/markdown/$chapter" >> reference-labels
                done
              duplicates=$(tr '[:upper:]' '[:lower:]' < reference-labels | sort | uniq -d)
              if [ -n "$duplicates" ]; then
                echo "Duplicate Markdown reference labels in llms-full.txt:" >&2
                echo "$duplicates" >&2
                exit 1
              fi
              {
                printf '# Stacks Security Handbook\n\n'
                sed -n 's/^[[:space:]]*- \[[^]]*\](\([^)]*\.md\)).*/\1/p' src/SUMMARY.md |
                  while IFS= read -r chapter; do
                    cat "book/markdown/$chapter"
                    printf '\n\n'
                  done
              } > book/html/llms-full.txt
              # Check the rendered site as well: it includes generated files and
              # the actual heading IDs used by the browser.
              lychee --offline --include-fragments --no-progress --root-dir book/html 'book/html/**/*.html'
              cp book/html/llms.txt book/html/.llms-linkcheck.md
              lychee --offline --include-fragments --no-progress --root-dir book/html book/html/.llms-linkcheck.md
              rm book/html/.llms-linkcheck.md
              ${pkgs.lib.optionalString withPdf ''
                # Wrap long code lines instead of clipping them in a paged PDF.
                cat > pdf-print.css <<'EOF'
              pre, pre code {
                white-space: pre-wrap !important;
                overflow-wrap: anywhere;
              }
              EOF
                mkdir -p book/pdf
                weasyprint --stylesheet pdf-print.css book/html/print.html book/pdf/output.pdf
              ''}
              mv book $out
            '';
          } // extra);
        in {
          default = buildBook [ pkgs.mdbook pkgs.mdbook-linkcheck2 pkgs.lychee ] false { name = "mdBook"; };
          pdf = buildBook [ pkgs.mdbook pkgs.mdbook-linkcheck2 pkgs.lychee pkgs.python3Packages.weasyprint ] true {
            name = "mdBook-pdf";
            FONTCONFIG_FILE = pkgs.makeFontsConf { fontDirectories = [ pkgs.dejavu_fonts ]; };
          };
        });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShellNoCC { nativeBuildInputs = [ pkgs.mdbook pkgs.mdbook-linkcheck2 ]; };
        pdf = pkgs.mkShellNoCC {
          nativeBuildInputs = [ pkgs.mdbook pkgs.mdbook-linkcheck2 pkgs.python3Packages.weasyprint ];
        };
      });

      # The handbook build checks Markdown references and rendered local links.
      checks = forAllSystems (pkgs: {
        links = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      });

    };
}
