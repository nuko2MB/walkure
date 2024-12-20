{
  config,
  pkgs,
  ...
}:
{
  imports = [ ./waybar/waybar.nix ];

  # TODO: Make service for xwayland-satellite
  home.packages = [
    pkgs.xwayland-satellite
  ];

  xdg.configFile."niri/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/walkure/dots/niri/config.kdl";

  services = {
    swayosd.enable = true;
  };

  programs = {
    fuzzel = {
      enable = true;
      settings.main = {
        lines = 6;
        line-height = 32;
        width = 24;
        terminal = "${pkgs.alacritty}/bin/alacritty";
      };
    };

    wlogout = {
      enable = true;
      layout = [
        {
          "label" = "lock";
          "action" = "loginctl lock-session";
          "text" = "Lock";
          "keybind" = "l";
        }
        {
          "label" = "hibernate";
          "action" = "systemctl hibernate";
          "text" = "Hibernate";
          "keybind" = "h";
        }
        {
          "label" = "logout";
          "action" = "loginctl terminate-user $USER";
          "text" = "Logout";
          "keybind" = "e";
        }
        {
          "label" = "shutdown";
          "action" = "systemctl poweroff";
          "text" = "Shutdown";
          "keybind" = "s";
        }
        {
          "label" = "suspend";
          "action" = "systemctl suspend";
          "text" = "Suspend";
          "keybind" = "u";
        }
        {
          "label" = "reboot";
          "action" = "systemctl reboot";
          "text" = "Reboot";
          "keybind" = "r";
        }
      ];
    };
  };
}
