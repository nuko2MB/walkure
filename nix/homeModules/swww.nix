{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    types
    mkOption
    mkEnableOption
    mkPackageOption
    mkIf
    ;
  cfg = config.services.swww;

  # Script uses ~/Pictures/walls at runtime.
  # I would like to avoid having lots of images in the flake without support for lazy trees and git lfs.
  slideshow = pkgs.writeScriptBin "swww-slideshow" ''
    #!${lib.getExe pkgs.nushell}
    let delay = ${cfg.slideshowDelay}
    let files = ls "~/Pictures/walls" | where type == file

    let extensions = ["jpeg" "jpg" "png" "gif" "webp" "tiff" "tga" "bmp"]
    def check_ext [file] {
        for ext in $extensions {
            if $file.name ends-with $ext {
               return true
            }
        }
    }

    let wallpapers = $files | filter {|file| check_ext $file}
    loop {
        let shuffled = $wallpapers | shuffle
        for image in $shuffled {
            swww img $image.name -t outer --transition-fps 144 --transition-pos 0.9,0.9
            sleep $delay
        }
    }
  '';
in
{
  options.services.swww = {
    enable = mkEnableOption "swww: A Solution to your Wayland Wallpaper Woes";

    package = mkPackageOption pkgs "swww" { };

    systemdTarget = mkOption {
      type = types.str;
      default = "graphical-session.target";
      example = "hyprland-session.target";
      description = ''
        The systemd target that will automatically start the swww service.

        When setting this value to `"hyprland-session.target"`,
        make sure to also enable {option}`wayland.windowManager.hyprland.systemd.enable`,
        otherwise the service may never be started.
      '';
    };

    slideshow = mkOption {
      type = types.bool;
      default = false;
    };

    slideshowDelay = mkOption {
      type = types.str;
      default = "1hr";
    };

    startupWallpaper = mkOption {
      type = types.nullOr types.path;
      description = "A wallpaper to set on inital startup of the daemon";
      default = null;
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services = {
      swww = {
        Unit = {
          Description = "swww Wallpaper daemon";
          Documentation = "man:swww(1)";
          PartOf = [ "graphical-session.target" ];
          After = [ cfg.systemdTarget ];
        };

        Service = {
          Environment = [
            "PATH=${cfg.package}/bin" # Required for swww to spawn swww-daemon

            #TODO: Add to preservation
            "XDG_CACHE_HOME=${config.home.homeDirectory}/.cache" # Daemon will use this to know where to cache images.
          ];
          Restart = "always"; # on-failure
          RestartSec = "1000ms";
          ExecStart = lib.getExe' cfg.package "swww-daemon";
          ExecStop = "${lib.getExe cfg.package} kill";
          ExecStartPost = mkIf (
            cfg.startupWallpaper != null
          ) "${cfg.package}/bin/swww img ${cfg.startupWallpaper}";
        };
        Install = {
          WantedBy = [ cfg.systemdTarget ];
        };
      };

      swww-slideshow =

        mkIf cfg.slideshow {
          Unit = {
            Description = "swww slideshow script";
            PartOf = [ "swww.target" ];
            After = [ "swww.target" ];
          };

          Service = {
            Environment = [ "PATH=${cfg.package}/bin" ];
            Restart = "always"; # on-failure
            RestartSec = "5000ms";
            ExecStart = lib.getExe slideshow;
          };
          Install = {
            WantedBy = [ cfg.systemdTarget ];
          };
        };
    };

    home.packages = [
      cfg.package
      slideshow
    ];
  };
}
