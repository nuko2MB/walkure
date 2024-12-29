{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    mkMerge
    mkEnableOption
    mkDefault
    types
    ;
  cfg = config.walkure.mpv;
in
{
  options.walkure.mpv = {
    enable = mkEnableOption "mpv";
    vulkanVideo = lib.mkOption {
      type = types.bool;
      default = true;
      description = "Enable vulkan video decoding";
    };
    dmabuf-wayland = lib.mkOption {
      type = types.bool;
      default = false;
      description = "Enable vulkan video decoding";
    };
    modernz.config = lib.mkOption {
      type = types.attrs;
      default = { };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.mpv = {
        enable = true;
        scripts = with pkgs.mpvScripts; [
          thumbfast
          modernz
          autoload
          mpris
        ];
        config = {
          osc = "no";
          gpu-context = "waylandvk";
          profile = "high-quality";
          gpu-api = "vulkan";
          vo = mkDefault "gpu-next";
          hwdec = mkDefault "auto-safe";

        };
      };
      walkure.mpv.modernz.config = {
        bottomhover = false;
      };

    }
    (mkIf cfg.vulkanVideo {
      home.sessionVariables.RADV_PERFTEST = "video_decode";
      programs.mpv.config.hwdec = "vulkan";
    })

    # Doesn't work with hwdec=vulkan
    # Results in artifacts in thumbfast.
    (mkIf cfg.dmabuf-wayland {
      programs.mpv.config.vo = "dmabuf-wayland";
    })

    # mpv.modernz.config
    (
      let
        renderOption =
          option:
          rec {
            int = toString option;
            float = int;
            bool = lib.hm.booleans.yesNo option;
            string = option;
          }
          .${lib.typeOf option};

        renderOptions = lib.generators.toKeyValue {
          mkKeyValue = lib.generators.mkKeyValueDefault { mkValueString = renderOption; } "=";
          listsAsDuplicateKeys = true;
        };
      in
      mkIf (cfg.modernz.config != { }) {
        xdg.configFile."mpv/script-opts/modernz.conf".text = renderOptions cfg.modernz.config;
      }
    )

    {
      assertions = [
        {
          assertion = cfg.vulkanVideo -> !cfg.dmabuf-wayland;
          message = "walkure.mpv: The vulkanVideo and dmabuf-wayland options are incompatible";
        }
      ];
    }
  ]);
}
