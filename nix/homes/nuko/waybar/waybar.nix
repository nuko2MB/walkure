{ lib, ... }:
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "bottom";
        height = 30;

        modules-left = [
          "hyprland/workspaces"
          "wlr/taskbar"
        ];
        modules-center = [ "mpris" ];
        modules-right = [
          "tray"
          "idle_inhibitor"
          "clock"
        ];

        "wlr/taskbar" = {
          tooltip-format = "{title} | {app_id}";
          on-click = "activate";
          on-click-middle = "close";
        };

        tray = {
          icon-size = 20;
          spacing = 7;
        };

        clock = {
          format = "{:%I:%M %p}";
        };

        mpris = {
          format = "{player_icon}  {dynamic}";
          format-paused = "{status_icon}  <i>{dynamic}</i>";
          dynamic-order = [
            "artist"
            "title"
          ];
          player-icons = {
            default = "󰏤";
          };
          status-icons = {
            paused = "󰐊";
          };
          max-length = 1000;
          # interval = 1;
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "󰆪";
            deactivated = "󰗥";
          };
        };
      };
    };
    style = lib.mkAfter (builtins.readFile ./waybar.css);
  };
}
