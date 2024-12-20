{ lib, config, ... }:
let
  cfg = config.walkure.firefox;
  inherit (lib)
    mkIf
    mkOption
    types
    mkMerge
    ;
in
{
  options.walkure.firefox = {
    enable = mkOption {
      type = types.bool;
      default = config.programs.firefox.enable;
    };
    declarative = mkOption {
      type = types.bool;
      default = cfg.enable;
    };
  };
  config = {
    programs.firefox = mkMerge [
      (mkIf cfg.enable {
        enable = true;
        profiles.nuko = {
          isDefault = true;
        };
      })

      (mkIf (cfg.enable && cfg.declarative) {
        profiles.nuko = {
          isDefault = true;

          settings = {
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          };

          userChrome = builtins.readFile ./userChrome.css;
          userContent = builtins.readFile ./userContent.css;
        };
      })
    ];
  };
}
