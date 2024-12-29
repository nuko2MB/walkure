{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    types
    mkIf
    ;
  cfg = config.walkure.xwayland-satellite;
in
{
  options.walkure.xwayland-satellite = {
    enable = mkEnableOption "Enable xwayand-satellite";
    package = mkPackageOption pkgs "xwayland-satellite" { };
    wantedBy = mkOption {
      type = types.str;
      default = "niri.service";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.xwayland-satellite = {
      Unit = {
        Description = "Xwayland outside your Wayland";
        BindsTo = "graphical-session.target";
        PartOf = "graphical-session.target";
        After = "graphical-session.target";
        Requisite = "graphical-session.target";
      };
      Service = {
        Type = "notify";
        NotifyAccess = "all";
        Environment = "PATH=${pkgs.xwayland}/bin";
        ExecStart = "${cfg.package}/bin/xwayland-satellite :0";
        StandardOutput = "journal";
      };
      Install.WantedBy = [ cfg.wantedBy ];
    };
  };
}
