# TODO: Finish when oo7 is in a more usable state.
{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.walkure.oo7;
in
{
  options.walkure.oo7.enable = lib.mkEnableOption "Enable oo7 secret manager";

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ pkgs.oo7 ];
    xdg.portal.extraPortals = [ pkgs.oo7 ];

    # Daemon is not in nixpkgs yet.
    /*
      systemd.services.oo7 = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          RestartSec = 1;
          Restart = "on-failure";
          execStart = "${lib.getExe oo7}";
        };
      };
    */
  };
}
