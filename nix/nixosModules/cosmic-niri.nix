{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.walkure.cosmic-niri;
in
{
  options = {
    walkure.cosmic-niri = {
      enable = lib.mkEnableOption "COSMIC session with niri compositor";
    };
  };

  imports = [ inputs.nixos-cosmic.nixosModules.default ];
  config = lib.mkIf cfg.enable {
    # Make sure nixos-cosmic binary cache is enabled.
    nix.settings = {
      substituters = [ "https://cosmic.cachix.org/" ];
      trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
    };

    services.desktopManager.cosmic = {
      enable = true;
      xwayland.enable = lib.mkDefault false;
    };

    programs.niri.enable = true;
    services.displayManager.sessionPackages = [ pkgs.cosmic-ext-niri ];
    environment.systemPackages = with pkgs; [
      cosmic-ext-niri
      cosmic-ext-alternative-startup
    ];
  };
}
