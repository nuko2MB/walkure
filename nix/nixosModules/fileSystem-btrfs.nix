{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    ;
  cfg = config.walkure.fileSystem.btrfs;
  inherit (config.walkure) ephemeral;
in
{
  imports = [ inputs.disko.nixosModules.disko ];

  options.walkure.fileSystem.btrfs = {
    enable = mkEnableOption "Enable btrfs filesystem using disko";
    device = mkOption { type = lib.types.str; };
  };

  config = mkIf cfg.enable {
    disko.devices = {
      disk = {
        main = {
          inherit (cfg) device;
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                name = "efi";
                label = "efi";
                size = "3G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/efi";
                  mountOptions = [ "umask=0077" ];
                };
              };
              root = {
                size = "100%";
                name = "nix";
                label = "nix";
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ]; # Override existing partition
                  subvolumes = {
                    "@root" = {
                      mountpoint = "/";
                      mountOptions = [ "compress-force=zstd" ];
                    };
                    "@nix" = {
                      mountOptions = [
                        "compress-force=zstd"
                        "noatime"
                      ];
                      mountpoint = "/nix";
                    };
                    "@state" = {
                      mountpoint = ephemeral.preserveAt;
                      mountOptions = [ "compress-force=zstd" ];
                    };
                  };
                  mountpoint = "/btrfsroot";
                };
              };
            };
          };
        };
      };
    };
  };
}
