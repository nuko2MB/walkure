{
  lib,
  pkgs,
  config,
  inputs,
  hostname ? null,
  osConfig ? null,
  homename ? null,
  ...
}:
let
  nix-vscode = inputs.nix-vscode-extensions.extensions.${pkgs.system};
  ext-pinned = nix-vscode.vscode-marketplace-release;
  ext-nightly = nix-vscode.vscode-marketplace;
  ext-nixpkgs = pkgs.vscode-extensions;
in
{
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    extensions =
      (with ext-nightly; [
        jnoortheen.nix-ide
        tamasfe.even-better-toml
        mkhl.direnv
        bmalehorn.vscode-fish
        thenuprojectcontributors.vscode-nushell-lang
        kdl-org.kdl
      ])
      # Release pinned extensions
      ++ (with ext-pinned; [ rust-lang.rust-analyzer ]);
    # ++ [ pkgs.nuko.vscode-slint ]
    userSettings = {
      "window.titleBarStyle" = "custom";
      "editor.fontSize" = lib.mkDefault 16;
      "workbench.colorTheme" = lib.mkDefault "Default Dark Modern";
      "editor.fontLigatures" = true;
      "editor.fontFamily" = lib.mkIf (osConfig != null) (
        lib.mkDefault "'${builtins.head osConfig.fonts.fontconfig.defaultFonts.monospace}','monospace'"
      );
      "editor.formatOnSave" = true;
      "inlayHints.enabled" = "offUnlessPressed";
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nixfmt";
      "nix.hiddenLanguageServerErrors" = [
        "textDocument/definition"
      ];
      "nix.serverSettings" = {
        nixd = {
          options = {
            home-manager = {
              expr =
                let
                  name = if hostname != null then "${config.home.username}@${hostname}" else homename;
                in
                ''(builtins.getFlake \"~/walkure\").homeConfigurations."${name}".options'';
            };
          };
        };
      };
    };
  };
}
