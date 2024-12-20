# TODO Rework module, requires preservation support.
{ config, lib, ... }:
let
  inherit (lib)
    mkIf
    mkOption
    mkEnableOption
    types
    ;
  cfg = config.walkure.services.samba;
in
{
  options.walkure.services.samba = {
    enable = mkEnableOption "Enable samba display file sharing";
    paths = mkOption {
      type = types.listOf types.path;
      example = lib.literalExpression "[/srv/share /mnt/media]";
      description = "Paths to share";
    };
  };

  config = mkIf cfg.enable {
    # Make shares visible for windows 10 clients
    services.samba-wsdd = {
      enable = true;
      #openFirewall = true;
    };
    services.samba = {
      enable = true;
      #openFirewall = true;

      settings = lib.foldl (
        acc: item:
        {
          # Workaround: SAMBA share does not work if there are "/" in the name.
          # TODO: Module should take attrset/submodule which specify options.
          "${config.networking.hostName}${lib.strings.stringAsChars (x: if x == "/" then "->" else x) item}" =
            {
              path = item;
              "read only" = "yes";
              "browseable" = "yes";
              "guest ok" = "yes";
              "force user" = "nobody";
              "force group" = "users";
            };
        }
        // acc
      ) { } cfg.paths;
    };

    # Replace with preservation:
    # walkure.tmpfiles = [ { inherit (cfg) paths; } ];
  };
}
