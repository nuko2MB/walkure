# TODO:
#     - Static IPV6
#     - Use submodules to allow defining of multiple devices.
#     - Global options that apply to all submodules without knowing devices name.

{
  lib,
  config,
  hostname,
  ...
}:
let
  cfg = config.walkure.network;
  inherit (lib) mkIf mkOption mkEnableOption;
  inherit (lib.types) str bool;
in
{
  options.walkure.network = {
    enable = mkEnableOption "Network";
    device = mkOption {
      type = str;
    };
    staticIPV4 = {
      enable = mkOption {
        type = bool;
        default = cfg.staticIPV4.address != "";
      };
      address = mkOption {
        type = str;
        default = "";
      };
    };
    gateway = lib.mkOption {
      type = str;
      default = "10.10.10.1";
    };
    DNS = lib.mkOption {
      type = str;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    systemd.network = {
      enable = true;
      networks = {
        ${cfg.device} = {
          matchConfig.Name = cfg.device;
          networkConfig = {
            DHCP = if cfg.staticIPV4.enable then "ipv6" else "yes";
            Address = mkIf cfg.staticIPV4.enable cfg.staticIPV4.address;
            Gateway = mkIf cfg.staticIPV4.enable cfg.gateway;
            DNS = mkIf (cfg.DNS != "") cfg.DNS;
          };
        };
      };
      wait-online = {
        enable = false;
        timeout = 0;
      };
    };
    networking = {
      useNetworkd = true;
      useDHCP = false;
      hostName = hostname;
      wireless = {
        iwd = {
          enable = true;
          settings = {
            Network = {
              EnableIPv6 = true;
              NameResolvingService = "systemd";
            };
            Settings = {
              AutoConnect = true;
            };
          };
        };
      };
    };
  };
}
