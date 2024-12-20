{
  config,
  lib,
  pkgs,
  inputs,
  options,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    ;
  cfg = config.walkure.ephemeral;
in
{
  imports = [
    inputs.preservation.nixosModules.default
  ];

  options.walkure.ephemeral = {
    enable = mkEnableOption "Ephemeral system via preservation";
    preserveAt = mkOption {
      type = lib.types.str;
      default = "/state";
    };
    preserve = mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    preservation = {
      enable = true;
      preserveAt.${config.walkure.ephemeral.preserveAt} =
        lib.mkAliasDefinitions options.walkure.ephemeral.preserve;
    };
    fileSystems.${cfg.preserveAt}.neededForBoot = true;

    boot.initrd.systemd = {
      enable = lib.mkDefault true;
      extraBin = {
        find = "${pkgs.findutils}/bin/find";
        sed = "${pkgs.busybox}/bin/sed";
        xargs = "${pkgs.findutils}/bin/xargs";
      };
    };

    # https://github.com/lilyinstarlight/foosteros/blob/0a9baef84a4cdf190a24711e7f0f1992e9e1bd02/config/ephemeral.nix
    boot.initrd.systemd.services.create-root = {
      description = "Rolling over and creating new filesystem root";

      requires = [ "initrd-root-device.target" ];
      after = [
        "local-fs-pre.target"
        "initrd-root-device.target"
      ];
      requiredBy = [ "initrd-root-fs.target" ];
      before = [ "sysroot.mount" ];

      unitConfig = {
        AssertPathExists = "/etc/initrd-release";
        DefaultDependencies = false;
      };

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      # Keep snapshots of the last 30 boots in /btrfsroot/oldroots
      # Requires btrfs root partition named @root
      script = ''
        mkdir -p /run/rootvol
        mount -t btrfs -o rw,subvol=/ ${
          lib.escapeShellArg (
            config.fileSystems."/".device or "/dev/disk/by-label/${config.fileSystems."/".label}"
          )
        } /run/rootvol

        mkdir -p /run/rootvol/oldroots
        num="$(printf '%s\n' "$(find /run/rootvol/oldroots -mindepth 1 -maxdepth 1 -type d -name '@root-*')" | sed -e 's#^\s*$#0#' -e 's#^/run/rootvol/oldroots/@root-\(.*\)$#\1#' | sort -n | tail -n 1 | xargs -I '{}' expr 1 + '{}')"

        mv /run/rootvol/@root /run/rootvol/oldroots/@root-"$num"
        btrfs property set /run/rootvol/oldroots/@root-"$num" ro true

        btrfs subvolume create /run/rootvol/@root

        find /run/rootvol/oldrootsfion -mindepth 1 -maxdepth 1 -type d -name '@root-*' | sed -e 's#^/run/rootvol/oldroots/@root-\(.*\)$#\1#' | sort -n | head -n -30 | xargs -I '{}' sh -c "btrfs property set '/run/rootvol/oldroots/@root-{}' ro false && btrfs subvolume list -o '/run/rootvol/oldroots/@root-{}' | cut -d' ' -f9- | xargs -I '[]' btrfs subvolume delete '/run/rootvol/oldroots/[]' && btrfs subvolume delete '/run/rootvol/oldroots/@root-{}'"

        umount /run/rootvol
        rmdir /run/rootvol
      '';
    };
  };
}
