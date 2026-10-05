{
  description = "haoxiangliew/website development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      treefmt-nix,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forEachSystem = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: import nixpkgs { inherit system; };

      treefmtFor =
        system:
        treefmt-nix.lib.evalModule (pkgsFor system) {
          programs = {
            actionlint.enable = true;
            nixfmt.enable = true;
            shellcheck.enable = true;
            shfmt.enable = true;
            zizmor.enable = true;
          };
        };
    in
    {
      formatter = forEachSystem (
        system:
        let
          pkgs = pkgsFor system;
        in
        pkgs.writeShellApplication {
          name = "fmt";
          runtimeInputs = [
            (treefmtFor system).config.build.wrapper
            pkgs.bun
          ];
          text = ''
            treefmt "$@"
            if [[ " $* " == *" --ci "* ]]; then
              bun run format:check
              bun run lint
            else
              bun run format
              bun run lint:fix
            fi
            bun run check
          '';
        }
      );

      devShells = forEachSystem (
        system:
        let
          pkgs = pkgsFor system;

          languages = (pkgs.formats.toml { }).generate "languages.toml" {
            language = [
              {
                name = "svelte";
                auto-format = true;
                language-servers = [
                  {
                    name = "svelteserver";
                    except-features = [ "format" ];
                  }
                  "oxlint-language-server"
                  "oxfmt-language-server"
                  "tailwindcss-ls"
                ];
              }
              {
                name = "typescript";
                auto-format = true;
                language-servers = [
                  {
                    name = "tsgo";
                    except-features = [ "format" ];
                  }
                  "oxlint-language-server"
                  "oxfmt-language-server"
                ];
              }
              {
                name = "javascript";
                auto-format = true;
                language-servers = [
                  {
                    name = "tsgo";
                    except-features = [ "format" ];
                  }
                  "oxlint-language-server"
                  "oxfmt-language-server"
                ];
              }
              {
                name = "json";
                language-servers = [
                  {
                    name = "vscode-json-language-server";
                    except-features = [ "format" ];
                  }
                  "oxfmt-language-server"
                ];
              }
              {
                name = "jsonc";
                language-servers = [
                  {
                    name = "vscode-json-language-server";
                    except-features = [ "format" ];
                  }
                  "oxfmt-language-server"
                ];
              }
              {
                name = "css";
                language-servers = [
                  {
                    name = "vscode-css-language-server";
                    except-features = [ "format" ];
                  }
                  "tailwindcss-ls"
                  "oxfmt-language-server"
                ];
              }
              {
                name = "nix";
                auto-format = true;
                language-servers = [ "nixd" ];
              }
              {
                name = "toml";
                auto-format = true;
              }
            ];

            language-server = {
              tsgo = {
                command = "node_modules/.bin/tsc";
                args = [
                  "--lsp"
                  "--stdio"
                ];
              };
              oxlint-language-server = {
                command = "node_modules/.bin/oxlint";
                args = [ "--lsp" ];
              };
              oxfmt-language-server = {
                command = "node_modules/.bin/oxfmt";
                args = [ "--lsp" ];
              };
              # tailwind v4 at-rules (@theme, @apply, @custom-variant)
              vscode-css-language-server.config.css.lint.unknownAtRules = "ignore";
              nixd.config.nixd.nixpkgs.expr = "import ${nixpkgs} { }";
            };
          };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              # node
              bun
              nodejs

              # svelte
              svelte-language-server

              # css / json
              tailwindcss-language-server
              vscode-langservers-extracted

              # bash
              bash-language-server
              shellcheck
              shfmt

              # nix
              nixd
              nixfmt

              # markdown
              marksman

              # toml
              taplo

              # scripts
              fd
              git
              imagemagick
              resvg
              ripgrep
            ];

            shellHook = ''
              mkdir -p .helix
              ln -sf ${languages} .helix/languages.toml

              if [ ! -d node_modules ]; then
                echo "node_modules not found, run 'bun install'"
              fi
            '';
          };
        }
      );
    };
}
