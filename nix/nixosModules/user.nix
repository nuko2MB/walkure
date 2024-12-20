{
  config,
  lib,
  hostname,
  pkgs,
  nixDir,
  inputs,
  inputs',
  flakelight,
  ...
}:
let
  inherit (lib)
    mkIf
    mkOption
    types
    ;
  inherit (types) str package;

  cfg = config.walkure.user;
  inherit (cfg) username;

  homes = import "${nixDir}/homes/homes.nix";
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  options.walkure.user = {
    username = mkOption {
      type = str;
      default = "nuko";
    };

    shell = mkOption {
      type = package;
      default = pkgs.fish;
    };
    hashedPasswordFile = mkOption {
      type = str;
      default = "";
    };
  };

  config = {
    users = {
      mutableUsers = false;

      users.${username} = {
        inherit (cfg) shell;

        isNormalUser = true;

        hashedPasswordFile = mkIf (cfg.hashedPasswordFile != "") cfg.hashedPasswordFile;

        # initialPassword = "password";
        extraGroups = [ "wheel" ];
        home = "/home/${username}";
      };
    };

    programs.fish.enable = true;

    home-manager = mkIf (homes ? "${username}@${hostname}") {
      sharedModules = lib.attrValues inputs.self.homeModules;
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "homebak";
      users.${username} = {
        imports = homes."${username}@${hostname}".modules;
      };
      extraSpecialArgs = {
        inherit inputs inputs' hostname;
      };
    };
  };
}
