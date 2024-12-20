{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    mkMerge
    ;
  cfg = config.walkure.bootloader;
in
{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  options.walkure.bootloader = {
    enable = mkEnableOption "Enable systemd bootloader";
    secureBoot = mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      boot.loader = {
        systemd-boot.enable = true;
        systemd-boot.consoleMode = lib.mkDefault "max";
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = lib.mkDefault "/efi";
        };
      };
    })

    (mkIf cfg.secureBoot {
      environment.systemPackages = [ pkgs.sbctl ];
      boot = {
        loader.systemd-boot = {
          enable = lib.mkForce false;
        };
        lanzaboote = {
          enable = true;
          pkiBundle = "/etc/secureboot";
        };
      };
    })
  ];
}
